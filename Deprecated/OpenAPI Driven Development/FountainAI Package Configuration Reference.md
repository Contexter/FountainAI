# FountainAI Package Configuration Reference

Below is the **verbatim copy** of the `Package.swift` file, serving as the foundational configuration for the CentralSequenceService microservice, part of the FountainAI ecosystem. This configuration is critical for implementers as it ensures scalability and standardization across the entire FountainAI system. By following the principles outlined here, developers can maintain consistency and facilitate seamless integration among the ten FountainAI microservices.

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CentralSequenceService",
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
            name: "CentralSequenceService",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Typesense", package: "typesense-swift"),
            ],
            path: "Sources",
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        )
    ]
)
```

## Purpose
This configuration file provides the foundation for building the **CentralSequenceService** microservice, a key component of the **FountainAI** system. It illustrates how to:

1. Define dependencies for modern Swift-based web services.
2. Leverage OpenAPI specifications for contract-first development.
3. Integrate with database systems and search backends using Fluent and Typesense.
4. Adopt a modular architecture compatible with all FountainAI microservices.

The principles here can be extended to configure other services in the FountainAI ecosystem, ensuring consistency and maintainability.

## Key Configuration Elements

### Swift Tools Version
```swift
// swift-tools-version:5.9
```
Specifies the minimum Swift tools version required. Ensures compatibility with language features introduced in Swift 5.9.

### Package Name
```swift
name: "CentralSequenceService"
```
Identifies the microservice. Replace this name with the appropriate service name when configuring other FountainAI services.

### Supported Platforms
```swift
platforms: [
    .macOS(.v10_15)
]
```
Targets macOS version 10.15 or higher. Ensure all platform-dependent code adheres to this runtime constraint.

### Dependencies
#### OpenAPI Libraries
The OpenAPI libraries included in this configuration complement each other by streamlining API development. `swift-openapi-generator` handles the generation of server and client code based on the OpenAPI specification, ensuring consistency across implementations. `swift-openapi-runtime` provides the necessary runtime utilities to manage request and response transformations seamlessly, while `swift-openapi-vapor` integrates these capabilities directly into Vapor's framework, enabling efficient endpoint handling and reducing boilerplate code.
```swift
.package(url: "https://github.com/apple/swift-openapi-generator.git", from: "1.5.0"),
.package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.5.0"),
.package(url: "https://github.com/swift-server/swift-openapi-vapor.git", from: "1.0.1"),
```
- **swift-openapi-generator**: Automates generation of server and client code from OpenAPI specs.
- **swift-openapi-runtime**: Provides runtime utilities for OpenAPI-based services.
- **swift-openapi-vapor**: Facilitates integration with Vapor’s web framework.

#### Vapor Framework
```swift
.package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
```
A high-performance web framework for routing, middleware, and request/response handling.

#### Persistence Layer
```swift
.package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
.package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.3.0"),
```
- **Fluent**: Object-Relational Mapping (ORM) for Swift.
- **FluentSQLiteDriver**: A lightweight SQLite driver for local development and persistence.

#### Search Engine Integration
```swift
.package(url: "https://github.com/typesense/typesense-swift.git", from: "1.0.0"),
```
Integrates the Typesense search engine for typo-tolerant, fast, and relevant search capabilities.

### Target Definition
#### Executable Target

This target is defined as executable to allow the `CentralSequenceService` to run independently as a standalone server process. This design aligns with the FountainAI system’s architecture, where each microservice operates autonomously while integrating seamlessly with the broader ecosystem. By enabling a modular and independent deployment strategy, implementers can achieve scalability and flexibility across the ten services in the FountainAI suite.
```swift
.executableTarget(
    name: "CentralSequenceService",
    dependencies: [
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
        .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
        .product(name: "Vapor", package: "vapor"),
        .product(name: "Fluent", package: "fluent"),
        .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
        .product(name: "Typesense", package: "typesense-swift"),
    ],
    path: "Sources",
    plugins: [
        .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
    ]
)
```
Defines `CentralSequenceService` as an executable target. Includes dependencies essential for OpenAPI, web server, persistence, and search functionality. Specifies the `Sources` directory for implementation code. Utilizes the OpenAPI Generator plugin for code generation from the specification.

## Implementation Guidance

### Modular Code Structure
Organize the code into clear directories:
- `Controllers/` for HTTP controllers and route handlers.
- `Models/` for database schema and ORM models.
- `Routes/` for defining route mappings.
- `Config/` for environment-specific configurations.

### OpenAPI Integration
Use `swift-openapi-generator` to generate stubs and maintain alignment with the API specification. Implement business logic in generated controllers, preserving the API contract.

### Database Configuration
Use Fluent’s migration tools to manage database schema updates. Configure SQLite persistence in `configure.swift` or equivalent setup files.

### Search Integration with Typesense

Index data in Typesense for fast and accurate searches. Implement retry mechanisms to handle indexing failures. For example:

```swift
func indexDataWithRetry(client: TypesenseClient, data: [String: Any], maxRetries: Int = 3) {
    var attempts = 0
    while attempts < maxRetries {
        do {
            try client.indexData(data)
            print("Data indexed successfully.")
            break
        } catch {
            attempts += 1
            print("Indexing failed. Attempt \(attempts) of \(maxRetries). Error: \(error)")
            if attempts == maxRetries {
                print("Max retries reached. Could not index data.")
            }
        }
    }
}
```

This retry mechanism attempts to index data up to a maximum number of retries and logs the progress. Such error-handling patterns can improve resilience and reliability in production environments.
Index data in Typesense for fast and accurate searches. Implement retry mechanisms to handle indexing failures.

### Environment-Specific Deployment
Leverage environment variables for configuration (e.g., database paths, API keys). Use Vapor’s built-in tools for production-readiness (logging, error handling, etc.).

## References
For additional guidance and technical details, refer to:

- **Example Projects and Tutorials:**
  - [Swift Package Manager Examples](https://www.swift.org/package-manager/#examples)
  - [Vapor Framework Tutorials](https://docs.vapor.codes/getting-started/)
  - [OpenAPI Generator Demo](https://github.com/apple/swift-openapi-generator#demo)
  - [Typesense Integration Examples](https://typesense.org/docs/overview/)

- **Swift Package Manager:** [https://www.swift.org/package-manager/](https://www.swift.org/package-manager/)
- **OpenAPI Generator:** [https://github.com/apple/swift-openapi-generator](https://github.com/apple/swift-openapi-generator)
- **Vapor Framework:** [https://docs.vapor.codes/](https://docs.vapor.codes/)
- **Fluent ORM:** [https://docs.vapor.codes/fluent/overview/](https://docs.vapor.codes/fluent/overview/)
- **Typesense:** [https://typesense.org/docs/](https://typesense.org/docs/)

