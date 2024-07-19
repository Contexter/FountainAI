### Recomposition Strategy for Implementing Complex OpenAPI Specification

To effectively manage the complexity of the given OpenAPI specification, we can break down the problem into smaller, more manageable components. By decomposing the OpenAPI spec into single model CRUD APIs and using CI/CD pipelines, custom GitHub Actions, and Docker Compose, we can incrementally build and integrate the components required for the full specification. Here's a structured approach:

### Step-by-Step Implementation Strategy

#### 1. **Decompose the OpenAPI Specification**

Break down the complex OpenAPI specification into individual model CRUD APIs. Each model will have its own set of endpoints (Create, Read, Update, Delete), and these can be developed, tested, and deployed independently.

**Example Models:**
- Script
- SectionHeading
- Action
- Character
- SpokenWord
- Transition
- Paraphrase

#### 2. **Implement Single Model CRUD APIs**

For each model, implement the necessary CRUD operations in separate modules. This ensures that each module can be developed and tested independently before integration.

**Example: Script API Implementation**
- **Model:** Define the `Script` model.
- **Controller:** Implement CRUD operations for `Script`.
- **Routes:** Set up routes for `Script` operations.
- **Migration:** Create database migration for the `Script` model.

**Script.swift**
```swift
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

    init() {}

    init(id: UUID? = nil, title: String, description: String, author: String, sequence: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.author = author
        self.sequence = sequence
    }
}
```

**ScriptController.swift**
```swift
import Vapor

struct ScriptController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let scripts = routes.grouped("scripts")
        scripts.get(use: index)
        scripts.post(use: create)
        scripts.group(":scriptID") { script in
            script.get(use: show)
            script.put(use: update)
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

    func show(req: Request) throws -> EventLoopFuture<Script> {
        return Script.find(req.parameters.get("scriptID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func update(req: Request) throws -> EventLoopFuture<Script> {
        let updatedScript = try req.content.decode(Script.self)
        return Script.find(req.parameters.get("scriptID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { script in
                script.title = updatedScript.title
                script.description = updatedScript.description
                script.author = updatedScript.author
                script.sequence = updatedScript.sequence
                return script.save(on: req.db).map { script }
            }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Script.find(req.parameters.get("scriptID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { script in
                script.delete(on: req.db)
            }.transform(to: .noContent)
    }
}
```

**CreateScript.swift Migration**
```swift
import Fluent

struct CreateScript: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("scripts")
            .id()
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("author", .string, .required)
            .field("sequence", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("scripts").delete()
    }
}
```

#### 3. **CI/CD Pipeline Setup**

Set up a CI/CD pipeline using GitHub Actions to automate the build, test, and deployment processes for each model. This ensures that each component is continuously integrated and tested.

**.github/workflows/development.yml**
```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - development

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Swift
        uses: fwal/setup-swift@v1
        with:
          swift-version: '5.3'

      - name: Build and test
        run: swift test

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Run Secret Manager
        uses: ./.github/actions/run-secret-manager
        with:
          repo-owner: ${{ secrets.REPO_OWNER }}
          repo-name: ${{ secrets.REPO_NAME }}
          token: ${{ secrets.GITHUB_TOKEN }}
          secret-name: ${{ secrets.SECRET_NAME }}
          secret-value: ${{ secrets.SECRET_VALUE }}

      - name: Deploy to Docker
        run: |
          docker-compose -f docker-compose.dev.yml up --build -d
```

#### 4. **Custom GitHub Actions**

Create custom GitHub Actions for managing secrets, running tests, and deploying applications. This modular approach allows for reuse and better organization of CI/CD tasks.

**.github/actions/run-secret-manager/action.yml**
```yaml
name: 'Run Secret Manager'
description: 'Action to run the Secret Manager command-line tool'
inputs:
  repo-owner:
    description: 'GitHub repository owner'
    required: true
  repo-name:
    description: 'GitHub repository name'
    required: true
  token:
    description: 'GitHub token'
    required: true
  secret-name:
    description: 'Name of the secret'
    required: true
  secret-value:
    description: 'Value of the secret'
    required: true
runs:
  using: 'docker'
  image: 'Dockerfile'
  args:
    - create
    - --repo-owner
    - ${{ inputs.repo-owner }}
    - --repo-name
    - ${{ inputs.repo-name }}
    - --token
    - ${{ inputs.token }}
    - --secret-name
    - ${{ inputs.secret-name }}
    - --secret-value
```

**.github/actions/run-secret-manager/Dockerfile**
```Dockerfile
# Use the official Swift image to build the app
FROM swift:5.3 as builder

# Copy the Swift package and build it
WORKDIR /app
COPY . .
RUN swift build --disable-sandbox --configuration release

# Create a slim runtime image
FROM swift:5.3-slim

# Copy the built executable
COPY --from=builder /app/.build/release/SecretManager /usr/local/bin/SecretManager

# Set the entry point
ENTRYPOINT ["SecretManager"]
```

#### 5. **Docker Compose for Integration**

Use Docker Compose to manage the integration of different services such as the Vapor application, PostgreSQL, Redis, and RedisAI. This allows for easy setup and consistent environments across development, testing, and production.

**docker-compose.dev.yml**
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgres://user:password@db:5432/database
      - REDIS_URL=redis://redis:6379

  db:
    image: postgres:13
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: database
    ports:
      - "5432:5432"

  redis:
    image: redis:latest
    ports:
      - "6379:6379"

  redisai:
    image: redisai/redisai:latest
    ports:
      - "6378:6378"
    environment:
      - REDISAI=1
```

### Benefits of This Approach:

1. **Incremental Development:**
   - Breaking down the specification into individual models allows for incremental development and testing, reducing complexity and potential errors.

2. **Modular CI/CD Pipelines:**
   - Using modular CI/CD pipelines for each component ensures continuous integration and delivery, allowing for quicker identification and resolution of issues.

3. **Reusable Custom Actions:**
   - Custom GitHub Actions can be reused across different pipelines, improving consistency and reducing duplication of effort.

4. **Consistent Environments:**
   - Docker Compose ensures that all services are consistently configured and can be easily replicated across different environments.

5. **Scalability:**
   - This approach scales well as new models or features can be added independently without disrupting the existing setup.

By following this structured approach, the complex OpenAPI specification can be effectively managed, ensuring a robust and maintainable implementation.

## Configure Common Services 

Given we have a one to one mapping of vapor app and openAPI model - can these apps use the same dockerized services ? - 
Yes, these apps can use the same dockerized services. When implementing a one-to-one mapping of each model from the OpenAPI specification to a separate Vapor application, you can configure these applications to share common services such as PostgreSQL, Redis, and RedisAI. This approach ensures consistency and efficient resource utilization.

### How to Share Dockerized Services Among Multiple Apps

1. **Docker Network Configuration:**
   - Ensure all Docker services and applications are on the same Docker network so they can communicate with each other.

2. **Environment Variables:**
   - Use environment variables to configure each Vapor application to connect to the shared services.

3. **Docker Compose Setup:**
   - Define a single `docker-compose.yml` file that includes all services and applications. Each application will be a separate service in the compose file.

### Example Docker Compose Configuration

Below is an example `docker-compose.yml` configuration that demonstrates how to set up shared services and multiple Vapor applications:

**docker-compose.yml**
```yaml
version: '3.8'

services:
  # Shared PostgreSQL database
  db:
    image: postgres:13
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: database
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - app-network

  # Shared Redis cache
  redis:
    image: redis:latest
    ports:
      - "6379:6379"
    networks:
      - app-network

  # Shared RedisAI service
  redisai:
    image: redisai/redisai:latest
    ports:
      - "6378:6378"
    environment:
      - REDISAI=1
    networks:
      - app-network

  # Vapor app for managing Scripts
  script-app:
    build:
      context: ./script-app
    environment:
      - DATABASE_URL=postgres://user:password@db:5432/database
      - REDIS_URL=redis://redis:6379
    networks:
      - app-network
    depends_on:
      - db
      - redis
      - redisai
    ports:
      - "8081:8080"

  # Vapor app for managing SectionHeadings
  section-heading-app:
    build:
      context: ./section-heading-app
    environment:
      - DATABASE_URL=postgres://user:password@db:5432/database
      - REDIS_URL=redis://redis:6379
    networks:
      - app-network
    depends_on:
      - db
      - redis
      - redisai
    ports:
      - "8082:8080"

  # Additional Vapor apps can be added similarly...

networks:
  app-network:
    driver: bridge

volumes:
  db-data:
```

### Directory Structure

To support this setup, you should organize your directory structure to include separate directories for each Vapor application:

```
/project-root
  /script-app
    Dockerfile
    Sources/
    ...
  /section-heading-app
    Dockerfile
    Sources/
    ...
  /additional-apps
    Dockerfile
    Sources/
    ...
  docker-compose.yml
```

### Dockerfiles for Each App

Ensure each Vapor application has its own `Dockerfile`. Here is an example for `script-app`:

**script-app/Dockerfile**
```Dockerfile
# Use the official Swift image to build the app
FROM swift:5.3 as builder

# Create a working directory
WORKDIR /app

# Copy the source code to the container
COPY . .

# Build the Vapor app
RUN swift build --enable-test-discovery -c release

# Create a runtime image
FROM swift:5.3-slim
WORKDIR /app
COPY --from=builder /app/.build/release /app

# Expose the port the app runs on
EXPOSE 8080

# Run the Vapor app
CMD ["./Run"]
```

### Environment Configuration

Each application needs to be configured to use the shared services. The environment variables in the `docker-compose.yml` file ensure that each app points to the correct service URLs.

### Conclusion

By sharing dockerized services among multiple Vapor applications, you ensure a consistent environment and efficient resource usage. This setup supports the modular development of each model's CRUD API while maintaining a cohesive system architecture. Using Docker Compose allows for easy orchestration of these services, making the development, testing, and deployment processes more streamlined and manageable.

## Enter Stage: The Migrations Manager

To enable multiple Vapor applications to manage migrations on a shared PostgreSQL database, you need to ensure that the migrations are coordinated properly. Here's a structured approach to handle database migrations in a shared, dockerized PostgreSQL environment:

### Approach

1. **Centralized Migration Management:**
   - Choose one of the Vapor applications to act as the migration manager. This application will be responsible for running all migrations, including those from other applications.
   - Alternatively, create a separate migration manager service that runs migrations for all applications.

2. **Shared Database Schema:**
   - Ensure that all applications are aware of the database schema and that migrations are idempotent (i.e., they can be run multiple times without causing issues).

3. **Migration Scripts:**
   - Write migration scripts for each application and ensure they are included in the migration manager.

4. **Docker Compose Configuration:**
   - Configure Docker Compose to run migrations before starting the services.

### Example Setup

#### 1. **Directory Structure:**
```
/project-root
  /script-app
    Dockerfile
    Sources/
    Migrations/
    ...
  /section-heading-app
    Dockerfile
    Sources/
    Migrations/
    ...
  /migration-manager
    Dockerfile
    Sources/
    Migrations/
    ...
  docker-compose.yml
```

#### 2. **Migration Manager Application:**

Create a new Vapor application or designate one of the existing applications to handle all migrations. This application will include migrations from all other applications.

**migration-manager/Sources/App/Migrations/CreateScripts.swift**
```swift
import Fluent

struct CreateScripts: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("scripts")
            .id()
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("author", .string, .required)
            .field("sequence", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("scripts").delete()
    }
}
```

**migration-manager/Sources/App/Migrations/CreateSectionHeadings.swift**
```swift
import Fluent

struct CreateSectionHeadings: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("section_headings")
            .id()
            .field("script_id", .uuid, .required, .references("scripts", "id"))
            .field("title", .string, .required)
            .field("sequence", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("section_headings").delete()
    }
}
```

Include similar migration scripts for other applications.

**migration-manager/Sources/App/configure.swift**
```swift
import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) throws {
    // Configure the database connection
    app.databases.use(.postgres(
        hostname: Environment.get("DB_HOST") ?? "localhost",
        username: Environment.get("DB_USER") ?? "user",
        password: Environment.get("DB_PASS") ?? "password",
        database: Environment.get("DB_NAME") ?? "database"
    ), as: .psql)
    
    // Register migrations
    app.migrations.add(CreateScripts())
    app.migrations.add(CreateSectionHeadings())
    // Add other migrations here

    // Run migrations automatically
    try app.autoMigrate().wait()
}
```

#### 3. **Docker Compose Configuration:**

Update your `docker-compose.yml` to include the migration manager service.

**docker-compose.yml**
```yaml
version: '3.8'

services:
  # Shared PostgreSQL database
  db:
    image: postgres:13
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: database
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - app-network

  # Shared Redis cache
  redis:
    image: redis:latest
    ports:
      - "6379:6379"
    networks:
      - app-network

  # Shared RedisAI service
  redisai:
    image: redisai/redisai:latest
    ports:
      - "6378:6378"
    environment:
      - REDISAI=1
    networks:
      - app-network

  # Migration manager service
  migration-manager:
    build:
      context: ./migration-manager
    environment:
      - DB_HOST=db
      - DB_USER=user
      - DB_PASS=password
      - DB_NAME=database
    networks:
      - app-network
    depends_on:
      - db
    command: ["vapor", "migrate"]

  # Vapor app for managing Scripts
  script-app:
    build:
      context: ./script-app
    environment:
      - DATABASE_URL=postgres://user:password@db:5432/database
      - REDIS_URL=redis://redis:6379
    networks:
      - app-network
    depends_on:
      - db
      - redis
      - redisai
    ports:
      - "8081:8080"

  # Vapor app for managing SectionHeadings
  section-heading-app:
    build:
      context: ./section-heading-app
    environment:
      - DATABASE_URL=postgres://user:password@db:5432/database
      - REDIS_URL=redis://redis:6379
    networks:
      - app-network
    depends_on:
      - db
      - redis
      - redisai
    ports:
      - "8082:8080"

  # Additional Vapor apps can be added similarly...

networks:
  app-network:
    driver: bridge

volumes:
  db-data:
```

#### 4. **Build and Run the Docker Compose Setup:**

Run the Docker Compose setup to build the images and start the containers. The migration manager will run the migrations before starting the other services.

```sh
docker-compose up --build
```

### Conclusion

By centralizing the migration management in a dedicated service or one of the Vapor applications, you can ensure that migrations are coordinated properly across all applications sharing the same PostgreSQL database. This approach helps maintain a consistent database schema and avoids potential conflicts or duplications in migrations. The Docker Compose setup orchestrates the services, ensuring that migrations are applied before the applications start, leading to a smooth and reliable deployment process.
