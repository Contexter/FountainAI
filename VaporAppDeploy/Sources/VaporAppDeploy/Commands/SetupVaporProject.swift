import Foundation
import ArgumentParser
import Yams

/// Sets up the Vapor project using an OpenAPI specification.
struct SetupVaporProject: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Set up the Vapor project using an OpenAPI specification."
    )

    /// The project directory.
    @Option(name: .shortAndLong, help: "The project directory.")
    var projectDirectory: String

    /// The OpenAPI specification file.
    @Option(name: .shortAndLong, help: "The OpenAPI specification file.")
    var openAPIFile: String

    /// Runs the command to set up the Vapor project.
    func run() {
        validateProjectDirectory(projectDirectory)
        validateOpenAPIFile(openAPIFile)
        
        let openAPISpec = readOpenAPISpec(openAPIFile)

        createPackageSwift()
        createMainSwift()
        createConfigureSwift()
        createRoutesSwift(openAPISpec)
        createModels(openAPISpec)
        createControllers(openAPISpec)
    }

    /// Reads the OpenAPI specification file.
    /// - Parameter filePath: The path to the OpenAPI file.
    /// - Returns: A dictionary representation of the OpenAPI specification.
    private func readOpenAPISpec(_ filePath: String) -> [String: Any] {
        guard let content = try? String(contentsOfFile: filePath),
              let yaml = try? Yams.load(yaml: content) as? [String: Any] else {
            fatalError("Failed to read or parse OpenAPI file")
        }
        return yaml
    }

    /// Creates the `Package.swift` file.
    private func createPackageSwift() {
        let content = """
        // swift-tools-version:5.3
        import PackageDescription

        let package = Package(
            name: "VaporApp",
            platforms: [
               .macOS(.v10_15)
            ],
            dependencies: [
                .package(name: "vapor", url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
                .package(name: "fluent", url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
                .package(name: "fluent-postgres-driver", url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
                .package(url: "https://github.com/vapor/redis.git", from: "4.0.0"),
                .package(url: "https://github.com/RedisAI/redisai-vapor", from: "1.0.0")
            ],
            targets: [
                .target(
                    name: "App",
                    dependencies: [
                        .product(name: "Vapor", package: "vapor"),
                        .product(name: "Fluent", package: "fluent"),
                        .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                        .product(name: "Redis", package: "redis"),
                        .product(name: "RedisAI", package: "redisai-vapor")
                    ],
                    path: "Sources/App"
                )
            ]
        )
        """

        try! content.write(toFile: "\(projectDirectory)/Package.swift", atomically: true, encoding: .utf8)
        print("Package.swift created.")
    }

    /// Creates the `main.swift` file.
    private func createMainSwift() {
        let content = """
        import Vapor

        var env = try Environment.detect()
        let app = Application(env)
        defer { app.shutdown() }
        try configure(app)
        try app.run()
        """

        try! content.write(toFile: "\(projectDirectory)/Sources/App/main.swift", atomically: true, encoding: .utf8)
        print("main.swift created.")
    }

    /// Creates the `configure.swift` file.
    private func createConfigureSwift() {
        let content = """
        import Vapor
        import Fluent
        import FluentPostgresDriver
        import Redis
        import RedisAI

        public func configure(_ app: Application) throws {
            app.databases.use(.postgres(
                hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                username: Environment.get("DATABASE_USERNAME") ?? "postgres",
                password: Environment.get("DATABASE_PASSWORD") ?? "password",
                database: Environment.get("DATABASE_NAME") ?? "scriptdb"
            ), as: .psql)

            let redisConfig = RedisConfiguration(
                hostname: Environment.get("REDIS_HOST") ?? "localhost",
                port: Int(Environment.get("REDIS_PORT") ?? "6379")!
            )
            app.redis.configuration = redisConfig

            app.migrations.add(CreateScript())

            try routes(app)
        }
        """

        try! content.write(toFile: "\(projectDirectory)/Sources/App/configure.swift", atomically: true, encoding: .utf8)
        print("configure.swift created.")
    }

    /// Creates the `routes.swift` file based on the OpenAPI specification.
    /// - Parameter openAPISpec: The OpenAPI specification dictionary.
    private func createRoutesSwift(_ openAPISpec: [String: Any]) {
        var routesContent = """
        import Vapor

        func routes(_ app: Application) throws {
        """
        
        // Generate routes based on OpenAPI spec
        if let paths = openAPISpec["paths"] as? [String: Any] {
            for (path, pathDetails) in paths {
                if let pathDetails = pathDetails as? [String: Any] {
                    for (method, methodDetails) in pathDetails {
                        if let methodDetails = methodDetails as? [String: Any],
                           let operationId = methodDetails["operationId"] as? String {
                            let functionName = operationId.camelCased()
                            routesContent += """
                            
                            app.\(method.lowercased())("\(path.replacingOccurrences(of: "{", with: ":").replacingOccurrences(of: "}", with: ""))", use: \(functionName))
                            """
                        }
                    }
                }
            }
        }
        
        routesContent += "\n}"
        
        try! routesContent.write(toFile: "\(projectDirectory)/Sources/App/routes.swift", atomically: true, encoding: .utf8)
        print("routes.swift created.")
    }

    /// Creates model files based on the OpenAPI specification.
    /// - Parameter openAPISpec: The OpenAPI specification dictionary.
    private func createModels(_ openAPISpec: [String: Any]) {
        if let components = openAPISpec["components"] as? [String: Any],
           let schemas = components["schemas"] as? [String: Any] {
            for (schemaName, schemaDetails) in schemas {
                if let schemaDetails = schemaDetails as? [String: Any] {
                    var modelContent = """
                    import Vapor
                    import Fluent

                    final class \(schemaName): Model, Content {
                        static let schema = "\(schemaName.lowercased())s"

                        @ID(key: .id)
                        var id: UUID?
                    """
                    
                    if let properties = schemaDetails["properties"] as? [String: Any] {
                        for (propertyName, propertyDetails) in properties {
                            if let propertyDetails = propertyDetails as? [String: Any],
                               let propertyType = propertyDetails["type"] as? String {
                                let swiftType = mapOpenAPITypeToSwiftType(propertyType)
                                modelContent += """
                                
                                @Field(key: "\(propertyName)")
                                var \(propertyName): \(swiftType)
                                """
                            }
                        }
                    }
                    
                    modelContent += """
                    
                        init() {}
                    
                        init(id: UUID? = nil"""
                    
                    if let properties = schemaDetails["properties"] as? [String: Any] {
                        for (propertyName, _) in properties {
                            modelContent += ", \(propertyName): \(mapOpenAPITypeToSwiftType(propertyType))"
                        }
                    }
                    
                    modelContent += ") {"
                    
                    if let properties = schemaDetails["properties"] as? [String: Any] {
                        for (propertyName, _) in properties {
                            modelContent += """
                            
                            self.\(propertyName) = \(propertyName)
                            """
                        }
                    }
                    
                    modelContent += """
                        }
                    }
                    """
                    
                    try! modelContent.write(toFile: "\(projectDirectory)/Sources/App/Models/\(schemaName).swift", atomically: true, encoding: .utf8)
                    print("\(schemaName).swift created.")
                }
            }
        }
    }

    /// Creates controller files based on the OpenAPI specification.
    /// - Parameter openAPISpec: The OpenAPI specification dictionary.
    private func createControllers(_ openAPISpec: [String: Any]) {
        if let paths = openAPISpec["paths"] as? [String: Any] {
            for (path, pathDetails) in paths {
                if let pathDetails = pathDetails as? [String: Any] {
                    for (method, methodDetails) in pathDetails {
                        if let methodDetails = methodDetails as? [String: Any],
                           let operationId = methodDetails["operationId"] as? String {
                            let functionName = operationId.camelCased()
                            let controllerContent = generateControllerContent(functionName: functionName, method: method, path: path, methodDetails: methodDetails)
                            
                            try! controllerContent.write(toFile: "\(projectDirectory)/Sources/App/Controllers/\(function

Name.capitalized)Controller.swift", atomically: true, encoding: .utf8)
                            print("\(functionName.capitalized)Controller.swift created.")
                        }
                    }
                }
            }
        }
    }
    
    /// Generates the content of a controller method based on the OpenAPI specification.
    /// - Parameters:
    ///   - functionName: The name of the function.
    ///   - method: The HTTP method.
    ///   - path: The API path.
    ///   - methodDetails: The details of the method from the OpenAPI specification.
    /// - Returns: The generated content of the controller method.
    private func generateControllerContent(functionName: String, method: String, path: String, methodDetails: [String: Any]) -> String {
        var content = """
        import Vapor
        import Fluent
        import Redis
        import RedisAI

        final class \(functionName.capitalized)Controller {
            func \(functionName)(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        """
        
        // Example logic, this should be expanded based on the OpenAPI details
        if method.lowercased() == "get" {
            content += """
                // Implement GET logic here
                return req.eventLoop.future(.ok)
            }
            """
        } else if method.lowercased() == "post" {
            content += """
                // Implement POST logic here
                return req.eventLoop.future(.created)
            }
            """
        }
        
        content += """
        }
        """
        
        return content
    }

    /// Validates the presence of the OpenAPI file.
    /// - Parameter filePath: The path to the OpenAPI file.
    private func validateOpenAPIFile(_ filePath: String) {
        if !FileManager.default.fileExists(atPath: filePath) {
            fatalError("Error: OpenAPI file not found at \(filePath)")
        }
    }

    /// Maps OpenAPI types to Swift types.
    /// - Parameter openAPIType: The OpenAPI type.
    /// - Returns: The corresponding Swift type.
    private func mapOpenAPITypeToSwiftType(_ openAPIType: String) -> String {
        switch openAPIType {
        case "string":
            return "String"
        case "integer":
            return "Int"
        case "boolean":
            return "Bool"
        default:
            return "String" // Defaulting to String for simplicity, should handle more types
        }
    }
}

extension String {
    /// Converts a snake_case string to camelCase.
    /// - Returns: The camelCase version of the string.
    func camelCased() -> String {
        return self.split(separator: "_").enumerated().map { index, element in
            index == 0 ? element.lowercased() : element.capitalized
        }.joined()
    }
}
