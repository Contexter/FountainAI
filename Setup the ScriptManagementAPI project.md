```
feat: Add setup script for ScriptManagementAPI project

- Check if Docker is running.
- Clean up the Docker environment.
- Create the project structure with necessary directories.
- Generate Swift files including Package.swift, main.swift, configure.swift, and other necessary files.
- Build and run the project using Docker.
- Test the API to ensure it is running correctly.
```
```
#!/bin/bash

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to clean up Docker environment
cleanup_docker() {
    echo "Cleaning up Docker environment..."
    docker-compose down -v --remove-orphans || true
    docker system prune -af --volumes || true
    rm -rf .build
    rm -rf Packages
}

# Function to create project structure
create_project_structure() {
    echo "Creating project structure..."
    mkdir -p ScriptManagementAPI/Sources/Run
    mkdir -p ScriptManagementAPI/Sources/App
    mkdir -p ScriptManagementAPI/Sources/App/Models
    mkdir -p ScriptManagementAPI/Sources/App/Controllers
    mkdir -p ScriptManagementAPI/Sources/App/Migrations
    mkdir -p ScriptManagementAPI/Tests/AppTests
}

# Function to create Swift files
create_swift_files() {
    echo "Creating Swift files..."
    
    # Create Package.swift
    cat <<EOL > ScriptManagementAPI/Package.swift
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ScriptManagementAPI",
    platforms: [
       .macOS(.v11)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.32.0"),
        .package(url: "https://github.com/apple/swift-nio-extras.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOExtras", package: "swift-nio-extras"),
                .product(name: "Collections", package: "swift-collections")
            ],
            path: "Sources/App"
        ),
        .executableTarget(
            name: "Run",
            dependencies: [.target(name: "App")],
            path: "Sources/Run"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            path: "Tests/AppTests"
        )
    ]
)
EOL

    # Create main.swift
    cat <<EOL > ScriptManagementAPI/Sources/Run/main.swift
import App
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
// Set the hostname to 0.0.0.0 to listen on all network interfaces
app.http.server.configuration.hostname = "0.0.0.0"
try app.run()
EOL

    # Create configure.swift
    cat <<EOL > ScriptManagementAPI/Sources/App/configure.swift
import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) throws {
    app.databases.use(.postgres(
        hostname: Environment.get("DB_HOST") ?? "localhost",
        port: Environment.get("DB_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DB_USER") ?? "vapor_username",
        password: Environment.get("DB_PASS") ?? "vapor_password",
        database: Environment.get("DB_NAME") ?? "vapor_database"
    ), as: .psql)

    app.migrations.add(CreateScript())

    // Apply migrations on startup
    try app.autoMigrate().wait()

    try routes(app)
}
EOL

    # Create routes.swift
    cat <<EOL > ScriptManagementAPI/Sources/App/routes.swift
import Vapor

func routes(_ app: Application) throws {
    let scriptController = ScriptController()
    app.get("scripts", use: scriptController.index)
    app.post("scripts", use: scriptController.create)
}
EOL

    # Create Script.swift
    cat <<EOL > ScriptManagementAPI/Sources/App/Models/Script.swift
import Fluent
import Vapor

final class Script: Model, Content {
    static let schema = "scripts"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "content")
    var content: String

    init() { }

    init(id: UUID? = nil, name: String, content: String) {
        self.id = id
        self.name = name
        self.content = content
    }
}
EOL

    # Create CreateScript.swift
    cat <<EOL > ScriptManagementAPI/Sources/App/Migrations/CreateScript.swift
import Fluent

struct CreateScript: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("scripts")
            .id()
            .field("name", .string, .required)
            .field("content", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("scripts").delete()
    }
}
EOL

    # Create ScriptController.swift
    cat <<EOL > ScriptManagementAPI/Sources/App/Controllers/ScriptController.swift
import Fluent
import Vapor

struct ScriptController {
    func index(req: Request) throws -> EventLoopFuture<[Script]> {
        Script.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Script> {
        let script = try req.content.decode(Script.self)
        return script.save(on: req.db).map { script }
    }
}
EOL

    # Create AppTests.swift
    cat <<EOL > ScriptManagementAPI/Tests/AppTests/AppTests.swift
@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    
    override func setUpWithError() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        // Revert and migrate the database
        try app.autoRevert().wait()
        try app.autoMigrate().wait()
    }

    func testCreateScript() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let script = Script(name: "Test Script", content: "This is a test script.")
        try app.test(.POST, "scripts", beforeRequest: { req in
            try req.content.encode(script)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let receivedScript = try res.content.decode(Script.self)
            XCTAssertEqual(receivedScript.name, script.name)
            XCTAssertEqual(receivedScript.content, script.content)
        })
    }

    func testGetScripts() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let script = Script(name: "Test Script", content: "This is a test script.")
        try script.save(on: app.db).wait()

        try app.test(.GET, "scripts", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let scripts = try res.content.decode([Script].self)
            XCTAssertEqual(scripts.count, 1)
            XCTAssertEqual(scripts[0].name, script.name)
            XCTAssertEqual(scripts[0].content, script.content)
        })
    }
}
EOL

    # Create Dockerfile
    cat <<EOL > ScriptManagementAPI/Dockerfile
# Build stage
FROM swift:5.8 as builder
WORKDIR /app
COPY . .
RUN swift build --configuration release

# Run stage
FROM swift:5.8-slim
WORKDIR /app
COPY --from=builder /app/.build/release /app/.build/release
COPY --from=builder /app/Sources/Run /app/Sources/Run
CMD ["/app/.build/release/Run"]
EOL

    # Create docker-compose.yml
    cat <<EOL > ScriptManagementAPI/docker-compose.yml
version: '3.9'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      DB_HOST: db
      DB_USER: postgres
      DB_PASS: password
      DB_NAME: vapor
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_DB: vapor
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  tests:
    image: swift:5.8
    environment:
      DB_HOST: db
      DB_USER: postgres
      DB_PASS: password
      DB_NAME: vapor
    depends_on:
      - db
    volumes:
      - .:/app
    working_dir: /app
    command: ["swift", "test"]
EOL

    # Create .env file
    cat <<EOL > ScriptManagementAPI/.env
DB_HOST=db
DB_USER=postgres
DB_PASS=password
DB_NAME=vapor
EOL
}

# Function to build and run Docker containers
build_and_run() {
    cd ScriptManagementAPI
    echo "Building and running the project..."
    docker-compose up --build -d
}

# Function to test if server is running
test_server() {
    echo "Testing if server is running..."
    sleep 10  # Wait for server to start

    # Test creating a script
    create_response=$(curl -s -X POST -H "Content-Type: application/json" -d '{"name": "Test Script", "content": "This is a test script."}' http://localhost:8080/scripts)
    echo "Create script response: $create_response"

    # Test fetching scripts
    fetch_response=$(curl -s http://localhost:8080/scripts)
    echo "Fetch scripts response: $fetch_response"
}

# Function to run Swift tests
run_swift_tests() {
    echo "Running Swift tests..."
    docker-compose run tests
}

# Execute functions
check_docker
cleanup_docker
create_project_structure
create_swift_files
build_and_run
test_server
run_swift_tests

echo "Project setup completed."

```
