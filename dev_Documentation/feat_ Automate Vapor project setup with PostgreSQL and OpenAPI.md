### Commit Message

```
feat: Automate Vapor project setup with PostgreSQL and OpenAPI

- Create project structure with directories for controllers, models, migrations, and tests.
- Generate Package.swift for dependency management.
- Add main.swift, configure.swift, routes.swift for application setup.
- Implement Script model and CreateScript migration.
- Add ScriptController for managing scripts.
- Include test cases for ScriptController.
- Add OpenAPI YAML file for API documentation.
- Initialize PostgreSQL database and run migrations.
```

### Complete Script with Documentation

```bash
#!/bin/bash

# Introduction:
# This script automates the creation and setup of a Vapor-based web application project.
# It sets up the necessary project structure, including directories for controllers, models, migrations, and tests.
# The script also generates key files such as Package.swift for dependency management, configuration files,
# and model and controller files for a basic Script management API. Additionally, it includes an OpenAPI YAML file
# for API documentation. The script initializes a PostgreSQL database and runs the necessary migrations to set up
# the database schema. By executing this script, developers can quickly bootstrap a Vapor project with a predefined
# structure and configuration, allowing them to focus on implementing application-specific logic.

# Create project structure
mkdir -p VaporAppDeploy/Sources/App/Controllers
mkdir -p VaporAppDeploy/Sources/App/Models
mkdir -p VaporAppDeploy/Sources/App/Migrations
mkdir -p VaporAppDeploy/Tests/AppTests
mkdir -p VaporAppDeploy/openAPI

# Create Package.swift
cat <<EOL > VaporAppDeploy/Package.swift
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "VaporAppDeploy",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
        ]),
        .executableTarget(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ]),
    ]
)
EOL

# Create main.swift
mkdir -p VaporAppDeploy/Sources/Run
cat <<EOL > VaporAppDeploy/Sources/Run/main.swift
import App
import Vapor

/// Main entry point for the application
var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.run()
EOL

# Create configure.swift
cat <<EOL > VaporAppDeploy/Sources/App/configure.swift
import Fluent
import FluentPostgresDriver
import Vapor

/// Configures the Vapor application
///
/// - Parameter app: The application to configure
/// - Throws: An error if configuration fails
public func configure(_ app: Application) throws {
    app.databases.use(.postgres(
        hostname: Environment.get("DB_HOST") ?? "localhost",
        username: Environment.get("DB_USER") ?? "postgres",
        password: Environment.get("DB_PASS") ?? "password",
        database: Environment.get("DB_NAME") ?? "vapor"
    ), as: .psql)

    app.migrations.add(CreateScript())

    try app.autoMigrate().wait()
    try routes(app)
}
EOL

# Create routes.swift
cat <<EOL > VaporAppDeploy/Sources/App/routes.swift
import Vapor

/// Registers routes for the Vapor application
///
/// - Parameter app: The application to configure
/// - Throws: An error if route registration fails
public func routes(_ app: Application) throws {
    let scriptController = ScriptController()
    try app.register(collection: scriptController)
}
EOL

# Create Script model
cat <<EOL > VaporAppDeploy/Sources/App/Models/Script.swift
import Vapor
import Fluent

/// Represents a Script model
final class Script: Model, Content {
    static let schema = "scripts"

    /// The unique identifier for the script
    @ID(key: .id)
    var id: UUID?

    /// The title of the script
    @Field(key: "title")
    var title: String

    /// The description of the script
    @Field(key: "description")
    var description: String

    /// The author of the script
    @Field(key: "author")
    var author: String

    /// The sequence number of the script
    @Field(key: "sequence")
    var sequence: Int

    /// Initializes a new script
    init() { }

    /// Initializes a new script with specified parameters
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the script
    ///   - title: The title of the script
    ///   - description: The description of the script
    ///   - author: The author of the script
    ///   - sequence: The sequence number of the script
    init(id: UUID? = nil, title: String, description: String, author: String, sequence: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.author = author
        self.sequence = sequence
    }
}
EOL

# Create CreateScript migration
cat <<EOL > VaporAppDeploy/Sources/App/Migrations/CreateScript.swift
import Fluent

/// Migration to create the scripts table
struct CreateScript: Migration {
    /// Prepares the database schema for the migration
    ///
    /// - Parameter database: The database to prepare
    /// - Returns: A future that completes when the preparation is done
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("scripts")
            .id()
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("author", .string, .required)
            .field("sequence", .int, .required)
            .create()
    }

    /// Reverts the database schema changes made by this migration
    ///
    /// - Parameter database: The database to revert
    /// - Returns: A future that completes when the revert is done
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("scripts").delete()
    }
}
EOL

# Create ScriptController
cat <<EOL > VaporAppDeploy/Sources/App/Controllers/ScriptController.swift
import Vapor
import Fluent

/// Controller for managing scripts
struct ScriptController: RouteCollection {
    /// Bootstraps the routes for this controller
    ///
    /// - Parameter routes: The routes builder to use
    /// - Throws: An error if route bootstrapping fails
    func boot(routes: RoutesBuilder) throws {
        let scripts = routes.grouped("scripts")
        scripts.get(use: index)
        scripts.post(use: create)
        scripts.group(":scriptID") { script in
            script.delete(use: delete)
        }
    }

    /// Retrieves all scripts
    ///
    /// - Parameter req: The request
    /// - Returns: A future containing the list of scripts
    func index(req: Request) throws -> EventLoopFuture<[Script]> {
        return Script.query(on: req.db).all()
    }

    /// Creates a new script
    ///
    /// - Parameter req: The request
    /// - Returns: A future containing the created script
    func create(req: Request) throws -> EventLoopFuture<Response> {
        let script = try req.content.decode(Script.self)
        return script.save(on: req.db).map {
            var headers = HTTPHeaders()
            headers.replaceOrAdd(name: .contentType, value: "application/json")
            return Response(status: .created, headers: headers, body: .init(data: try! JSONEncoder().encode(script)))
        }
    }

    /// Deletes a script
    ///
    /// - Parameter req: The request
    /// - Returns: A future containing the HTTP status
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Script.find(req.parameters.get("scriptID"), on: req.db)
            .flatMap { script in
                script?.delete(on: req.db).transform(to: .ok) ?? req.eventLoop.future(.notFound)
            }
    }
}
EOL

# Create test file
cat <<EOL > VaporAppDeploy/Tests/AppTests/ScriptControllerTests.swift
import XCTV

apor
@testable import App

/// Tests for ScriptController
final class ScriptControllerTests: XCTestCase {

    var app: Application!

    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
        // Clear the scripts table before each test
        try Script.query(on: app.db).delete().wait()
    }

    override func tearDownWithError() throws {
        app.shutdown()
    }

    /// Tests creating a script
    func testCreateScript() throws {
        try app.test(.POST, "scripts", beforeRequest: { req in
            req.headers.contentType = .json
            try req.content.encode(Script(title: "Test Title", description: "Test Description", author: "Test Author", sequence: 1))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
            let script = try res.content.decode(Script.self)
            XCTAssertEqual(script.title, "Test Title")
            XCTAssertEqual(script.description, "Test Description")
            XCTAssertEqual(script.author, "Test Author")
            XCTAssertEqual(script.sequence, 1)
        })
    }

    /// Tests retrieving all scripts
    func testGetAllScripts() throws {
        // Pre-create a script
        let script = Script(title: "Test Title", description: "Test Description", author: "Test Author", sequence: 1)
        try script.save(on: app.db).wait()

        try app.test(.GET, "scripts", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let scripts = try res.content.decode([Script].self)
            XCTAssertEqual(scripts.count, 1)
            XCTAssertEqual(scripts[0].title, "Test Title")
        })
    }

    /// Tests deleting a script
    func testDeleteScript() throws {
        // Pre-create a script
        let script = Script(title: "Test Title", description: "Test Description", author: "Test Author", sequence: 1)
        try script.save(on: app.db).wait()

        try app.test(.DELETE, "scripts/\(script.id!)", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })

        // Ensure script is deleted
        let remainingScripts = try Script.query(on: app.db).all().wait()
        XCTAssertEqual(remainingScripts.count, 0)
    }
}
EOL

# Create OpenAPI YAML file
cat <<EOL > VaporAppDeploy/openAPI/openapi.yaml
openapi: 3.0.1
info:
  title: Script Management API
  description: |
    API for managing screenplay scripts, including creation, retrieval, updating, and deletion.

    **Dockerized Environment**:
    - **Nginx**: An Nginx proxy container handles SSL termination with Let's Encrypt certificates via Certbot.
    - **Vapor Application**: A Swift-based Vapor app runs in a separate Docker container.
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
          type:

 string
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

# Navigate to project directory and initialize the project
cd VaporAppDeploy
swift package update
swift build

# Create the PostgreSQL database
psql -U postgres -c "CREATE DATABASE vapor;"

# Run migrations
swift run Run migrate

echo "Project setup completed."
```

You can now run this script to set up your Vapor project with all the necessary configurations, models, controllers, tests, and OpenAPI documentation.
