# FountainAI Documentation: Meta Prompt for Creating a Final Project Tree

#### **Objective**

Design a modular and maintainable **project tree** for a Swift Vapor-based application that integrates the **Swift OpenAPI Generator plugin**. The structure should facilitate clean separation of generated and handwritten code while supporting scalability, extensibility, and adherence to Swift and Vapor conventions.

---

### **Meta Prompt**

**Task:**
Create a **project tree** for a Swift Vapor application using the **Swift OpenAPI Generator plugin**. The solution must:

1. **Gather Necessary Inputs**:

   - Ask the user to provide a specific OpenAPI specification file (`openapi.yaml`) that defines the API contract.
   - Confirm the OpenAPI contract to be implemented and validate its core structure.

2. **Meet the Overall Goal**:

   - Facilitate a clean and maintainable project structure.
   - Integrate generated files (`Server.swift`, `Types.swift`) seamlessly with handwritten logic.

3. **Follow Swift Package and Vapor Conventions**:

   - Organize code under `Sources/` for modularity.
   - Include directories for:
     - **Handlers**: Implements business logic for API operations.
     - **Routes**: Registers routes and middleware.
     - **Models and Migrations**: Defines database entities and schema changes.
     - **Services**: Encapsulates reusable business logic.

4. **Integrate the Plugin Setup**:

   - Include `openapi-generator-config.yaml` to guide code generation.
   - Place generated files (`Server.swift`, `Types.swift`) where they integrate seamlessly.

5. **Incorporate OpenAPIVapor Use Case**:

   - Use the [swift-openapi-vapor](https://github.com/swift-server/swift-openapi-vapor.git) library to simplify the integration of OpenAPI-generated code with Vapor.
   - The `OpenAPIVapor` target enables direct routing and request/response handling by leveraging the OpenAPI specification, ensuring alignment with defined API contracts and reducing boilerplate code.
   - Example:
     ```swift
     import OpenAPIVapor
     import Vapor

     func registerRoutes(_ app: Application) throws {
         let openAPIRoutes = OpenAPIRoutes(
             server: Generated.Server(),
             handler: CustomHandler()
         )
         app.register(openAPIRoutes)
     }
     ```
   - This library streamlines the transition from OpenAPI schema to a fully operational API by offering pre-defined routing and middleware patterns that adhere to OpenAPI standards.

6. **Integrate Typesense Client Use Case**:

   - Use the [Typesense Swift Client](https://github.com/typesense/typesense-swift.git) to integrate fast and typo-tolerant search capabilities within the application.
   - This client enables seamless indexing, querying, and searching of data, making it suitable for scenarios requiring real-time search features.
   - Example:
     ```swift
     import Typesense

     func configureSearch() throws {
         let client = try Typesense.Client(configuration: Configuration(
             nodes: [Node(protocol: "http", host: "localhost", port: 8108)],
             apiKey: "api-key",
             connectionTimeoutSeconds: 2
         ))

         // Create an example schema
         let schema = Schema(name: "documents", fields: [
             Field(name: "title", type: "string"),
             Field(name: "content", type: "string")
         ])

         try client.createSchema(schema: schema)

         // Index a document
         let document = ["title": "Example Document", "content": "This is a test."]
         try client.indexDocument(document, schemaName: "documents")
     }
     ```
   - Incorporate Typesense into service layers to provide efficient search functionality for indexed data.

7. **Support Development and Testing**:

   - Provide directories for unit and integration tests.
   - Allow space for future configurations and extensions.

8. **Ensure Generated Route Registration Supports Modularity**:

   - Leverage the structure of `Server.swift` to modularly register routes that are implemented in specific handlers.
   - Configure handlers in a way that focuses on incremental API development without disrupting the generated route bindings.

---

### **Inputs**

1. **Specific OpenAPI Specification**:

   - The user must provide a concrete OpenAPI specification file (`openapi.yaml`) that defines the API contract to be implemented.
   - Example:
     ```yaml
     openapi: 3.1.0
     info:
       title: My API
       version: 1.0.0
     paths:
       /example:
         get:
           summary: Example endpoint
           responses:
             '200':
               description: Success
     ```

2. **Templated `Package.swift`**:

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "{{ProjectName}}", // Replace with your project's name
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // OpenAPI Generator
        .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.5.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-vapor.git", from: "1.0.1"),

        // Vapor
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),

        // Fluent and SQLite Driver
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.3.0"),

        // Typesense Client
        .package(url: "https://github.com/typesense/typesense-swift.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "{{ProjectName}}", // Replace with your target name
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Typesense", package: "typesense-swift"),
            ],
            path: "Sources/{{ProjectName}}", // Replace with your project's source path
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        )
    ]
)
```

   **Instructions for Templating**:

   - Replace `{{ProjectName}}` with the actual name of your project.
   - Update the `path` field (`Sources/{{ProjectName}}`) to reflect your source directory structure.
   - Ensure that the target name matches the `name` field in your Swift Package.

3. **Expected Plugin Outputs**:

   - `Types.swift`: Defines models for OpenAPI schemas.
   - `Server.swift`: Contains server stubs for OpenAPI-defined operations.

4. **Requirements**:

   - Include space for handwritten code such as handlers, routes, models, and services.
   - Ensure modularity and extensibility.

---

### **Example Project Tree**

```
{{ProjectName}}/
├── Package.swift                              # Swift package manager configuration
├── Sources/
│   ├── {{ProjectName}}/                      # Main application module
│   │   ├── main.swift                         # Entry point for the Vapor application
│   │   ├── configure.swift                    # Application setup (routes, middleware)
│   │   ├── Routes/                            # Route registration
│   │   │   ├── Routes.swift                   # Registers all routes
│   │   │   ├── ResourceRoutes.swift           # Routes for specific resources
│   │   │   ├── GeneratedRoutes.swift          # Automatically generated OpenAPI routes
│   │   │   └── MiddlewareRoutes.swift         # Middleware-related routes
│   │   ├── Handlers/                          # Implements API logic
│   │   │   ├── ResourceHandler.swift
│   │   │   ├── ExampleHandler.swift
│   │   │   └── AnotherHandler.swift
│   │   ├── Services/                          # Reusable components (e.g., database access)
│   │   │   ├── DatabaseService.swift
│   │   │   └── ExternalAPIService.swift
│   │   ├── Models/                            # Database models and migrations
│   │   │   ├── Resource.swift                 # Database model
│   │   │   └── Migrations/
│   │   │       ├── CreateResource.swift       # Database migration for the resource
│   │   │       └── CreateAnotherTable.swift   # Another migration
│   │   ├── openapi.yaml                       # OpenAPI specification
│   │   └── openapi-generator-config.yaml      # Generator configuration
├── Generated/                                 # Plugin-generated files
│   ├── Server.swift                           # Server stubs for OpenAPI operations
│   ├── Types.swift                            # Models for OpenAPI schemas
├── Tests/
│   ├── {{ProjectName}}Tests/
│   │   ├── ResourceTests.swift                # Tests for resource operations
│   │   ├── MiddlewareTests.swift              # Tests for middleware
│   │   └── IntegrationTests.swift             # End-to-end tests
└── README.md                                  # Documentation for the project
```

---

### **Integration Instructions**

1. **Set Up the Plugin in `Package.swift`**:

   - Ensure `Package.swift` includes the Swift OpenAPI Generator plugin.

2. **Create Configuration Files**:

   - Place `openapi.yaml` in `Sources/{{ProjectName}}/` as the OpenAPI specification.
   - Add `openapi-generator-config.yaml` in the same directory with content such as:
     ```yaml
     generate:
       - types
       - server
     namingStrategy: idiomatic
     accessModifier: public
     ```

3. **Generate Code**:

   - Run the following command to trigger code generation:
     ```bash
     swift build
     ```
   - Verify that `Server.swift` and `Types.swift` are placed in the `Generated/` directory.

4. **Integrate Generated Routes**:

   - **Hybrid Approach**:
     Use a combination of automatically generated OpenAPI routes and manually registered custom routes. Example:
     ```swift
     import Vapor
     import OpenAPIVapor

     func routes(_ app: Application) throws {
         // Automatically register OpenAPI-generated routes
         let openAPIRoutes = OpenAPIRoutes(server: Generated.Server(), handler: CustomHandler())
         app.register(openAPIRoutes)

         // Manually register additional routes
         let api = app.grouped("api", "v1")
         api.get("custom-endpoint", use: CustomHandler.customLogic)
         api.post("another-endpoint", use: AnotherHandler.anotherLogic)
     }
     ```

5. **Implement Modular Handlers**:

   - Focus on creating modular handlers in `Handlers/`. Each handler should implement only the business logic and interface with the generated types.
   - Example:
     ```swift
     import Vapor

     struct ResourceHandler {
         func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
             let input = try req.content.decode(Resource.self) // Generated type
             // Perform business logic
             return req.eventLoop.future(.ok)
         }
     }
     ```

6. **Add Middleware and Services**:

   - Configure error handling or preprocessing using custom middleware in `MiddlewareRoutes.swift`:
     ```swift
     struct CustomErrorMiddleware: Middleware {
         func respond(to req: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
             return next.respond(to: req).flatMapErrorThrowing { error in
                 req.logger.report(error: error)
                 return req.response(error: error)
             }
         }
     }
     ```
   - Reuse components for database access, Typesense interactions, etc., in `Services/`.

7. **Testing**:

   - Write tests in `Tests/{{ProjectName}}Tests/` to validate both generated routes and handwritten logic.
   - Example:
     ```swift
     import XCTVapor

     final class ResourceTests: XCTestCase {
         func testCreateResource() throws {
             let app = Application(.testing)
             defer { app.shutdown() }
             try configure(app)

             try app.test(.POST, "/resource", beforeRequest: { req in
                 try req.content.encode(["name": "Example"])
             }, afterResponse: { res in
                 XCTAssertEqual(res.status, .ok)
             })
         }
     }
     ```

---

### **Conclusion**

This meta prompt facilitates the creation of a modular, maintainable project tree that integrates the Swift OpenAPI Generator plugin seamlessly. By adopting a hybrid approach to route registration, it ensures generated route registration aligns with modular handlers while allowing for customization and scalability. Use this as a comprehensive guide for structuring similar Vapor-based projects while focusing on the continuous development of your OpenAPI contract.

