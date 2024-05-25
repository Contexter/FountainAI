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
