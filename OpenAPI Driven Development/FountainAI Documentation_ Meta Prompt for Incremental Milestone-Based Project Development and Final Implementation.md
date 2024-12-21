# **FountainAI Documentation: Meta Prompt for Incremental Milestone-Based Project Development and Final Implementation**

## **Objective**

Design a **modular and maintainable project tree** for a Swift Vapor-based application that integrates the **Swift OpenAPI Generator plugin**. The structure must facilitate clean separation of generated and handwritten code while supporting **scalability**, **extensibility**, and adherence to **Swift and Vapor conventions**.

---

## **Meta Prompt**

### **Task:**

Create a **project tree** for a Swift Vapor application using the **Swift OpenAPI Generator plugin**. The solution must:

---

### **1. Gather Necessary Inputs:**

- Request a **specific OpenAPI specification file** (`openapi.yaml`) to define the API contract.
- Validate and confirm the **OpenAPI contract structure** aligns with the implementation.

---

### **2. Meet the Overall Goals:**

- **Clean and Maintainable Structure:** Design scalable and modular code components.
- **Seamless Integration:** Combine **generated files** (`Server.swift`, `Types.swift`) with **custom logic**.
- **Incremental Development:** Ensure each milestone **extends the previous state** and supports progressive development.

---

### **3. Follow Swift Package and Vapor Conventions:**

- Organize code under `Sources/` for **modularity**.
- Directories to include:
  - **Handlers:** Implements business logic for API operations.
  - **Routes:** Registers routes and middleware.
  - **Models and Migrations:** Defines database entities and schema changes.
  - **Services:** Encapsulates reusable business logic.
  - **Tests:** Implements **unit**, **integration**, and **contract compliance tests**.

---

### **4. Plugin Setup and OpenAPI Integration:**

- Include `openapi-generator-config.yaml` to guide code generation.
- Place generated files (`Server.swift`, `Types.swift`) where they integrate seamlessly.
- Use **OpenAPIVapor** to simplify route registration based on generated schemas.

---

### **5. Typesense Integration:**

- Integrate the [Typesense Swift Client](https://github.com/typesense/typesense-swift.git) for **fast, typo-tolerant search capabilities**.

---

### **6. Incremental Milestones and Compliance Checks:**

- Each milestone must:
  - Introduce **working code** that compiles successfully.
  - Provide **unit and integration tests** validating correctness.
  - Include **cURL examples** to verify routes manually.
  - Verify compliance with the **OpenAPI contract** by comparing outputs with schemas.

---

### **7. Error Handling and Scalability Focus:**

- Implement reusable **error models** (e.g., `ErrorResponse`, `TypesenseErrorResponse`).
- Add middleware to log and process errors in a unified format.
- Design database migrations with constraints to support **scalability**.

---

### **8. Inputs:**

#### **1. OpenAPI Specification**

- Require a specific OpenAPI specification file (`openapi.yaml`) as the contract.

#### **2. Templated Package.swift**

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "{{ProjectName}}",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.5.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-vapor.git", from: "1.0.1"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.3.0"),
        .package(url: "https://github.com/typesense/typesense-swift.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "{{ProjectName}}",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Typesense", package: "typesense-swift")
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        )
    ]
)
```

---

### **9. Example Project Tree (Milestone Updates):**

```
{{ProjectName}}/
├── Package.swift
├── Sources/
│   ├── {{ProjectName}}/
│   │   ├── main.swift
│   │   ├── configure.swift
│   │   ├── Routes/
│   │   ├── Handlers/
│   │   ├── Services/
│   │   ├── Models/
│   │   ├── Migrations/
│   │   ├── openapi.yaml
│   │   └── openapi-generator-config.yaml
├── Generated/
├── Tests/
└── README.md
```
_Note: At each milestone, this tree view is updated to reflect the current state of implementation, showing incremental progress until the full implementation is complete._

---




## **Conclusion**

This meta prompt ensures a **modular, test-driven, and scalable design** for a Swift Vapor application. Each milestone progressively builds functionality while verifying compliance with the **OpenAPI contract**. Use this framework as a guide for building extensible API-driven applications.

