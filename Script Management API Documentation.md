## Script Management API Documentation

### Overview

This document provides a comprehensive guide to the Script Management API project, including the implementation details, Docker setup, OpenAPI specification, and future steps.

### Project Overview

The Script Management API is designed to manage screenplay scripts, including creation, retrieval, updating, and deletion. The API is built using the Vapor framework in Swift and leverages Docker for containerization.

### Project Structure

```
VaporAppDeploy/
├── Dockerfile
├── Package.swift
├── README.md
├── Sources/
│   ├── App/
│   │   ├── Controllers/
│   │   │   └── ScriptController.swift
│   │   ├── Models/
│   │   │   └── Script.swift
│   │   ├── configure.swift
│   │   └── routes.swift
│   └── Run/
│       └── main.swift
├── Tests/
│   └── AppTests/
│       └── ScriptControllerTests.swift
├── docker-compose.yml
└── openapi.yml
```

### Convenience Shell Script

To set up the project, use the following shell script:

```bash
#!/bin/bash

# Set up the project directory
PROJECT_DIR="VaporAppDeploy"
mkdir $PROJECT_DIR
cd $PROJECT_DIR

# Create the project structure
mkdir -p Sources/App/Controllers
mkdir -p Sources/App/Models
mkdir -p Sources/App/Configuration
mkdir -p Sources/App/Routes
mkdir -p Sources/Run
mkdir -p Tests/AppTests

# Initialize a new Vapor project
swift package init --type executable

# Add dependencies to Package.swift
cat <<EOL > Package.swift
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "VaporAppDeploy",
    platforms: [
       .macOS(.v12)
    ],
    products: [
        .executable(name: "VaporAppDeploy", targets: ["App"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
            .product(name: "Vapor", package: "vapor")
        ]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
EOL

# Create main.swift
cat <<EOL > Sources/Run/main.swift
import App
import Vapor
import Fluent

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.run()
EOL

# Create configure.swift
cat <<EOL > Sources/App/configure.swift
import Vapor
import Fluent
import FluentPostgresDriver

public func configure(_ app: Application) throws {
    app.databases.use(.postgres(
        hostname: "localhost",
        port: 5432,
        username: "postgres",
        password: "password",
        database: "vapor"
    ), as: .psql)

    app.migrations.add(CreateScript())

    try routes(app)
}
EOL

# Create Script.swift
cat <<EOL > Sources/App/Models/Script.swift
import Fluent
import Vapor

final class Script: Model, Content {
    static let schema = "scripts"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "description")
    var description: String

    @Field(key: "author")
    var author: String

    @Field(key: "sequence")
    var sequence: Int

    init() { }

    init(id: UUID? = nil, title: String, description: String, author: String, sequence: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.author = author
        self.sequence = sequence
    }
}

struct CreateScript: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("scripts")
            .id()
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("author", .string, .required)
            .field("sequence", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("scripts").delete()
    }
}
EOL

# Create ScriptController.swift
cat <<EOL > Sources/App/Controllers/ScriptController.swift
import Fluent
import Vapor

struct ScriptController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let scripts = routes.grouped("scripts")
        scripts.get(use: index)
        scripts.post(use: create)
        scripts.group(":scriptID") { script in
            script.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[Script]> {
        return Script.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Script> {
        let script = try req.content.decode(Script.self)
        return script.save(on: req.db).map { script }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Script.find(req.parameters.get("scriptID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
EOL

# Create routes.swift
cat <<EOL > Sources/App/routes.swift
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: ScriptController())
}
EOL

# Create ScriptControllerTests.swift
cat <<EOL > Tests/AppTests/ScriptControllerTests.swift
@testable import App
import XCTVapor

final class ScriptControllerTests: XCTestCase {
    func testCreateScript() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.POST, "scripts", beforeRequest: { req in
            try req.content.encode(Script(title: "Test", description: "Test description", author: "Test author", sequence: 1))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let script = try res.content.decode(Script.self)
            XCTAssertEqual(script.title, "Test")
        })
    }

    func testDeleteScript() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let script = Script(title: "Test", description: "Test description", author: "Test author", sequence: 1)
        try script.save(on: app.db).wait()

        try app.test(.DELETE, "scripts/\(script.id!)", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })
    }

    func testGetAllScripts() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let script = Script(title: "Test", description: "Test description", author: "Test author", sequence: 1)
        try script.save(on: app.db).wait()

        try app.test(.GET, "scripts", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let scripts = try res.content.decode([Script].self)
            XCTAssertEqual(scripts.count, 1)
        })
    }
}
EOL

# Create Dockerfile
cat <<EOL > Dockerfile
FROM swift:5.5-focal AS build
WORKDIR /app

# Copy entire repo into container
COPY . .

# Install dependencies and build application
RUN swift package resolve
RUN swift build --configuration release --disable-sandbox

# Copy build artifacts to separate clean image
FROM swift:5.5-focal-slim
WORKDIR /app
COPY --from=build /app/.build/release /app

EXPOSE 8080
CMD ["./run"]
EOL

# Create docker-compose.yml
cat <<EOL > docker-compose.yml
version: '3'
services:
  web:
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - db
  db:
    image: postgres:13
    environment:
      POSTGRES_DB: vapor
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
EOL

# Create openapi.yml
cat <<EOL > openapi.yml
openapi: 3.0.1
info:
  title: Script Management API
  description: |
    API for managing screenplay scripts, including creation, retrieval, updating, and deletion.
    **Dockerized Environment**:
    - **Nginx**: An Nginx proxy container handles SSL termination with Let's Encrypt certificates via Certbot.
    - **Vapor Application**: A Swift-based Vapor app runs

 in a separate Docker container.
    - **Postgres Database**: The main persistence layer is a PostgreSQL container managed by Docker Compose.
    - **Redis Cache**: A Redis container is used for caching script data, optimizing performance for frequent queries.
    - **RedisAI Middleware**: RedisAI provides enhanced analysis, recommendations, and validation for script management.
  version: "1.1.0"
servers:
  - url: 'https://script.fountain.coach'
    description: Main server for Script Management API services (behind Nginx proxy)
  - url: 'http://localhost:8080'
    description: Development server for Script Management API services (Docker environment)
paths:
  /scripts:
    get:
      summary: Retrieve All Scripts
      operationId: listScripts
      description: |
        Lists all screenplay scripts stored within the system. This endpoint leverages Redis caching for improved query performance.
      responses:
        '200':
          description: An array of scripts.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Script'
              examples:
                allScripts:
                  summary: Example of retrieving all scripts
                  value:
                    - scriptId: 1
                      title: "Sunset Boulevard"
                      description: "A screenplay about Hollywood and faded glory."
                      author: "Billy Wilder"
                      sequence: 1
    post:
      summary: Create a New Script
      operationId: createScript
      description: |
        Creates a new screenplay script record in the system. RedisAI provides recommendations and validation during creation.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ScriptCreateRequest'
            examples:
              createScriptExample:
                summary: Example of script creation
                value:
                  title: "New Dawn"
                  description: "A story about renewal and second chances."
                  author: "Jane Doe"
                  sequence: 1
      responses:
        '201':
          description: Script successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Script'
              examples:
                scriptCreated:
                  summary: Example of a created script
                  value:
                    scriptId: 2
                    title: "New Dawn"
                    description: "A story about renewal and second chances."
                    author: "Jane Doe"
                    sequence: 1
        '400':
          description: Bad request due to missing required fields.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                badRequestExample:
                  value:
                    message: "Missing required fields: 'title' or 'author'."
  /scripts/{scriptId}:
    get:
      summary: Retrieve a Script by ID
      operationId: getScriptById
      description: |
        Retrieves the details of a specific screenplay script by its unique identifier (scriptId). Redis caching improves retrieval performance.
      parameters:
        - name: scriptId
          in: path
          required: true
          description: Unique identifier of the screenplay script to retrieve.
          schema:
            type: integer
      responses:
        '200':
          description: Detailed information about the requested script.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Script'
              examples:
                retrievedScript:
                  summary: Example of a retrieved script
                  value:
                    scriptId: 1
                    title: "Sunset Boulevard"
                    description: "A screenplay about Hollywood and faded glory."
                    author: "Billy Wilder"
                    sequence: 1
        '404':
          description: The script with the specified ID was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundExample:
                  value:
                    message: "Script not found with ID: 3"
    put:
      summary: Update a Script by ID
      operationId: updateScript
      description: |
        Updates an existing screenplay script with new details. RedisAI provides recommendations and validation for updating script content.
      parameters:
        - name: scriptId
          in: path
          required: true
          description: Unique identifier of the screenplay script to update.
          schema:
            type: integer
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ScriptUpdateRequest'
            examples:
              updateScriptExample:
                summary: Example of updating a script
                value:
                  title: "Sunset Boulevard Revised"
                  description: "Updated description with more focus on character development."
                  author: "Billy Wilder"
                  sequence: 2
      responses:
        '200':
          description: Script successfully updated.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Script'
              examples:
                scriptUpdated:
                  summary: Example of an updated script
                  value:
                    scriptId: 1
                    title: "Sunset Boulevard Revised"
                    description: "Updated description with more focus on character development."
                    author: "Billy Wilder"
                    sequence: 2
        '400':
          description: Bad request due to invalid input data.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                badRequestUpdateExample:
                  value:
                    message: "Invalid input data: 'sequence' must be a positive number."
        '404':
          description: The script with the specified ID was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundUpdateExample:
                  value:
                    message: "Script not found with ID: 4"
    delete:
      summary: Delete a Script by ID
      operationId: deleteScript
      description: Deletes a specific screenplay script from the system, identified by its scriptId.
      parameters:
        - name: scriptId
          in: path
          required: true
          description: Unique identifier of the screenplay script to delete.
          schema:
            type: integer
      responses:
        '204':
          description: Script successfully deleted.
        '404':
          description: The script with the specified ID was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundDeleteExample:
                  value:
                    message: "Script not found with ID: 5"
components:
  schemas:
    Script:
      type: object
      properties:
        scriptId:
          type: integer
          description: Unique identifier for the screenplay script.
        title:
          type: string
          description: Title of the screenplay script.
        description:
          type: string
          description: Brief description or summary of the screenplay script.
        author:
          type: string
          description: Author of the screenplay script.
        sequence:
          type: integer
          description: Sequence number representing the script's order or version.
      required:
        - title
        - author
    ScriptCreateRequest:
      type: object
      properties:
        title:
          type: string
        description:
          type: string
        author:
          type: string
        sequence:
          type: integer
      required:
        - title
        - author
    ScriptUpdateRequest:
      type: object
      properties:
        title:
          type: string
        description:
          type: string
        author:
          type: string
        sequence:
          type: integer
    Error:
      type: object
      description: Common error structure for the API.
      properties:
        message:
          type: string
          description: Description of the error encountered.
EOL

# Initialize the Vapor project
swift build
EOL

# Make the script executable
chmod +x setup.sh
```

### Docker Configuration

#### `Dockerfile`

```Dockerfile
FROM swift:5.5-focal AS build
WORKDIR /app

# Copy entire repo into container
COPY . .

# Install dependencies and build application
RUN swift package resolve
RUN swift build --configuration release --disable-sandbox

# Copy build artifacts to separate clean image
FROM swift:5.5-focal-slim
WORKDIR /app
COPY --from=build /app/.build/release /app

EXPOSE 8080
CMD ["./run"]
```

#### `docker-compose.yml`

```yaml
version: '3'
services:
  web:
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - db
  db:
    image: postgres:13
    environment:
      POSTGRES_DB: vapor
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
```

### OpenAPI Specification

#### `openapi.yml`

```yaml
openapi: 3.0.1
info:
  title: Script Management API
  description: |
    API for managing screenplay scripts, including creation, retrieval, updating, and deletion.

    **Dockerized Environment**:
    - **Nginx**: An Nginx proxy container handles SSL termination with Let's Encrypt certificates via Certbot.
    - **Vapor Application**: A Swift-based Vapor app runs in a separate Docker container.
    - **Postgres Database**: The main persistence layer is a PostgreSQL container managed by Docker Compose.
    - **Redis Cache**: A Redis container is used for caching script data, optimizing performance

 for frequent queries.
    - **RedisAI Middleware**: RedisAI provides enhanced analysis, recommendations, and validation for script management.

  version: "1.1.0"
servers:
  - url: 'https://script.fountain.coach'
    description: Main server for Script Management API services (behind Nginx proxy)
  - url: 'http://localhost:8080'
    description: Development server for Script Management API services (Docker environment)

paths:
  /scripts:
    get:
      summary: Retrieve All Scripts
      operationId: listScripts
      description: |
        Lists all screenplay scripts stored within the system. This endpoint leverages Redis caching for improved query performance.
      responses:
        '200':
          description: An array of scripts.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Script'
              examples:
                allScripts:
                  summary: Example of retrieving all scripts
                  value:
                    - scriptId: 1
                      title: "Sunset Boulevard"
                      description: "A screenplay about Hollywood and faded glory."
                      author: "Billy Wilder"
                      sequence: 1
    post:
      summary: Create a New Script
      operationId: createScript
      description: |
        Creates a new screenplay script record in the system. RedisAI provides recommendations and validation during creation.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ScriptCreateRequest'
            examples:
              createScriptExample:
                summary: Example of script creation
                value:
                  title: "New Dawn"
                  description: "A story about renewal and second chances."
                  author: "Jane Doe"
                  sequence: 1
      responses:
        '201':
          description: Script successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Script'
              examples:
                scriptCreated:
                  summary: Example of a created script
                  value:
                    scriptId: 2
                    title: "New Dawn"
                    description: "A story about renewal and second chances."
                    author: "Jane Doe"
                    sequence: 1
        '400':
          description: Bad request due to missing required fields.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                badRequestExample:
                  value:
                    message: "Missing required fields: 'title' or 'author'."

  /scripts/{scriptId}:
    get:
      summary: Retrieve a Script by ID
      operationId: getScriptById
      description: |
        Retrieves the details of a specific screenplay script by its unique identifier (scriptId). Redis caching improves retrieval performance.
      parameters:
        - name: scriptId
          in: path
          required: true
          description: Unique identifier of the screenplay script to retrieve.
          schema:
            type: integer
      responses:
        '200':
          description: Detailed information about the requested script.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Script'
              examples:
                retrievedScript:
                  summary: Example of a retrieved script
                  value:
                    scriptId: 1
                    title: "Sunset Boulevard"
                    description: "A screenplay about Hollywood and faded glory."
                    author: "Billy Wilder"
                    sequence: 1
        '404':
          description: The script with the specified ID was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundExample:
                  value:
                    message: "Script not found with ID: 3"
    put:
      summary: Update a Script by ID
      operationId: updateScript
      description: |
        Updates an existing screenplay script with new details. RedisAI provides recommendations and validation for updating script content.
      parameters:
        - name: scriptId
          in: path
          required: true
          description: Unique identifier of the screenplay script to update.
          schema:
            type: integer
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ScriptUpdateRequest'
            examples:
              updateScriptExample:
                summary: Example of updating a script
                value:
                  title: "Sunset Boulevard Revised"
                  description: "Updated description with more focus on character development."
                  author: "Billy Wilder"
                  sequence: 2
      responses:
        '200':
          description: Script successfully updated.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Script'
              examples:
                scriptUpdated:
                  summary: Example of an updated script
                  value:
                    scriptId: 1
                    title: "Sunset Boulevard Revised"
                    description: "Updated description with more focus on character development."
                    author: "Billy Wilder"
                    sequence: 2
        '400':
          description: Bad request due to invalid input data.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                badRequestUpdateExample:
                  value:
                    message: "Invalid input data: 'sequence' must be a positive number."
        '404':
          description: The script with the specified ID was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundUpdateExample:
                  value:
                    message: "Script not found with ID: 4"
    delete:
      summary: Delete a Script by ID
      operationId: deleteScript
      description: Deletes a specific screenplay script from the system, identified by its scriptId.
      parameters:
        - name: scriptId
          in: path
          required: true
          description: Unique identifier of the screenplay script to delete.
          schema:
            type: integer
      responses:
        '204':
          description: Script successfully deleted.
        '404':
          description: The script with the specified ID was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundDeleteExample:
                  value:
                    message: "Script not found with ID: 5"

components:
  schemas:
    Script:
      type: object
      properties:
        scriptId:
          type: integer
          description: Unique identifier for the screenplay script.
        title:
          type: string
          description: Title of the screenplay script.
        description:
          type: string
          description: Brief description or summary of the screenplay script.
        author:
          type: string
          description: Author of the screenplay script.
        sequence:
          type: integer
          description: Sequence number representing the script's order or version.
      required:
        - title
        - author

    ScriptCreateRequest:
      type: object
      properties:
        title:
          type: string
        description:
          type: string
        author:
          type: string
        sequence:
          type: integer
      required:
        - title
        - author

    ScriptUpdateRequest:
      type: object
      properties:
        title:
          type: string
        description:
          type: string
        author:
          type: string
        sequence:
          type: integer

    Error:
      type: object
      description: Common error structure for the API.
      properties:
        message:
          type: string
          description: Description of the error encountered.
```

### Future Steps and Missing Implementation

1. **Enhance Validation and Error Handling**: Currently, basic validation is performed. Implement more robust validation logic and detailed error handling to ensure data integrity and provide better feedback to API consumers.

2. **Redis Integration**: Integrate Redis for caching frequently accessed script data to improve performance. Implement RedisAI for enhanced recommendations and validation.

3. **Authentication and Authorization**: Implement authentication and authorization mechanisms to secure the API endpoints. Consider using JWT (JSON Web Tokens) for stateless authentication.

4. **Logging and Monitoring**: Set up logging and monitoring tools to keep track of API usage and performance metrics. Integrate with tools like ELK Stack (Elasticsearch, Logstash, Kibana) or Prometheus and Grafana.

5. **Automated Testing and CI/CD**: Enhance test coverage and set up a CI/CD pipeline using tools like GitHub Actions or Jenkins to automate the build, test, and deployment processes.

6. **Deployment**: Set up deployment scripts and configurations for different environments (development, staging, production). Use Docker and Kubernetes for scalable and reliable deployments.

### Conclusion

This documentation provides a comprehensive guide to setting up and extending the Script Management API project. The provided scripts and configurations should help streamline the setup process, and the future steps outline key areas for further development to enhance the API's functionality and performance.