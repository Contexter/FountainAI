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

5. **Support Development and Testing**:
   - Provide directories for unit and integration tests.
   - Allow space for future configurations and extensions.

6. **Ensure Generated Route Registration Supports Modularity**:
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

2. **Constant `Package.swift`**:
```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MyVaporApp",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // OpenAPI Generator
        .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.5.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),

        // Fluent and SQLite Driver
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "MyVaporApp",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
            ],
            path: "Sources",
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        )
    ]
)
```

3. **Expected Plugin Outputs**:
   - `Types.swift`: Defines models for OpenAPI schemas.
   - `Server.swift`: Contains server stubs for OpenAPI-defined operations.

4. **Requirements**:
   - Include space for handwritten code such as handlers, routes, models, and services.
   - Ensure modularity and extensibility.

---

### **Example Project Tree**

```
MyVaporApp/
├── Package.swift                              # Swift package manager configuration
├── Sources/
│   ├── MyVaporApp/                            # Main application module
│   │   ├── main.swift                         # Entry point for the Vapor application
│   │   ├── configure.swift                    # Application setup (routes, middleware)
│   │   ├── Routes/                            # Route registration
│   │   │   ├── Routes.swift                   # Registers all routes
│   │   │   ├── ResourceRoutes.swift           # Routes for specific resources
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
│   ├── MyVaporAppTests/
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
   - Place `openapi.yaml` in `Sources/MyVaporApp/` as the OpenAPI specification.
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
   - Verify that `Server.swift` and `Types.swift` are generated in the `Generated/` directory.

4. **Integrate Generated Routes**:
   - Use `Server.swift` to modularly register generated routes in `Routes/Routes.swift`:
     ```swift
     import Vapor
     import Generated

     func registerRoutes(_ app: Application) throws {
         // Generated routes
         try app.register(collection: Generated.Server())

         // Additional custom route registrations
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
   - Write tests in `Tests/MyVaporAppTests/` to validate both generated routes and handwritten logic.
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
This meta prompt facilitates the creation of a modular, maintainable project tree that integrates the Swift OpenAPI Generator plugin seamlessly. It ensures generated route registration aligns with modular handlers, providing scalability and ease of incremental API development. Use this as a comprehensive guide for structuring similar Vapor-based projects while focusing on the continuous development of your OpenAPI contract.

