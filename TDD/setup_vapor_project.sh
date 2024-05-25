#!/bin/bash

# Create project structure
mkdir -p VaporAppDeploy/Sources/App/Controllers
mkdir -p VaporAppDeploy/Sources/App/Models
mkdir -p VaporAppDeploy/Sources/App/Migrations
mkdir -p VaporAppDeploy/Tests/AppTests

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

public func routes(_ app: Application) throws {
    let scriptController = ScriptController()
    try app.register(collection: scriptController)
}
EOL

# Create Script model
cat <<EOL > VaporAppDeploy/Sources/App/Models/Script.swift
import Vapor
import Fluent

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
EOL

# Create CreateScript migration
cat <<EOL > VaporAppDeploy/Sources/App/Migrations/CreateScript.swift
import Fluent

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

# Create ScriptController
cat <<EOL > VaporAppDeploy/Sources/App/Controllers/ScriptController.swift
import Vapor
import Fluent

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
            .flatMap { script in
                script?.delete(on: req.db).transform(to: .ok) ?? req.eventLoop.future(.notFound)
            }
    }
}
EOL

# Create test file
cat <<EOL > VaporAppDeploy/Tests/AppTests/ScriptControllerTests.swift
import XCTVapor
@testable import App

final class ScriptControllerTests: XCTestCase {
    func testCreateScript() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.POST, "scripts", beforeRequest: { req in
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

    func testGetAllScripts() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

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

    func testDeleteScript() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

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

# Navigate to project directory and initialize the project
cd VaporAppDeploy
swift package update
swift build

# Create the PostgreSQL database
psql -U postgres -c "CREATE DATABASE vapor;"

# Run migrations
swift run Run migrate

echo "Project setup completed."
