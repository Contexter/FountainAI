
# Build a Hummingbird App with OpenAPI and Fluent ORM

This tutorial walks you through creating a Swift app using:
- **Hummingbird** for the web framework,
- **Swift OpenAPI Generator** for API specification integration,
- **Fluent ORM** for database management,
- **SQLite** as the database backend.

---

## **1. Initialize the Project**

### **Steps**
1. Create a new directory and initialize it as a Swift package:
   ```bash
   mkdir MyHummingbirdApp
   cd MyHummingbirdApp
   swift package init --type executable
   ```

2. Verify the generated project structure:
   ```
   MyHummingbirdApp/
   ├── Package.swift
   ├── Sources/
   │   └── MyHummingbirdApp/
   │       └── main.swift
   ├── Tests/
   │   └── MyHummingbirdAppTests/
   │       └── MyHummingbirdAppTests.swift
   ```

---

## **2. Add Dependencies**

### **Steps**
1. Open `Package.swift` and update it with the required dependencies for:
   - **Hummingbird** for the web server,
   - **Swift OpenAPI Generator** for OpenAPI integration,
   - **Fluent ORM** and **SQLite driver** for database management.

2. Replace the content of `Package.swift` with:
   ```swift
   // swift-tools-version: 5.9
   import PackageDescription

   let package = Package(
       name: "MyHummingbirdApp",
       platforms: [.macOS(.v12)],
       products: [
           .executable(name: "MyHummingbirdApp", targets: ["MyHummingbirdApp"]),
       ],
       dependencies: [
           .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
           .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "1.7.0"),
           .package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.7.0"),
           .package(url: "https://github.com/swift-server/swift-openapi-hummingbird.git", from: "2.0.0"),
           .package(url: "https://github.com/vapor/fluent.git", from: "4.5.0"),
           .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.1.0"),
       ],
       targets: [
           .executableTarget(
               name: "MyHummingbirdApp",
               dependencies: [
                   .product(name: "Hummingbird", package: "hummingbird"),
                   .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                   .product(name: "OpenAPIHummingbird", package: "swift-openapi-hummingbird"),
                   .product(name: "Fluent", package: "fluent"),
                   .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
               ],
               plugins: [
                   .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
               ],
               resources: [
                   .process("openapi.yaml"),
                   .process("openapi-generator-config.yaml"),
               ]
           ),
           .testTarget(
               name: "MyHummingbirdAppTests",
               dependencies: ["MyHummingbirdApp"]
           ),
       ]
   )
   ```

3. Build the project:
   ```bash
   swift build
   ```

---

## **3. Define the OpenAPI Specification and Plugin Configuration**

### **Add the OpenAPI Specification**
1. Create `Sources/MyHummingbirdApp/openapi.yaml`.
2. Add the following content:
   ```yaml
   openapi: 3.0.0
   info:
     title: My API
     version: 1.0.0
   paths:
     /items:
       get:
         summary: Get all items
         operationId: listItems
         responses:
           '200':
             description: A list of items
             content:
               application/json:
                 schema:
                   type: array
                   items:
                     type: string
   ```

### **Add the Plugin Configuration**
1. Create `Sources/MyHummingbirdApp/openapi-generator-config.yaml`.
2. Add the following content:
   ```yaml
   generate:
     - types
     - server
   accessModifier: public
   ```

### **Explanation**
- **`openapi.yaml`**: Defines the API contract (endpoints, methods, and response types).
- **`openapi-generator-config.yaml`**:
  - Configures the OpenAPI Generator to:
    - Generate Swift types and server code.
    - Use `public` access modifiers, ensuring the generated code is accessible from your application.

---

## **4. Configure Fluent ORM**

### **4.1 Create the Database Model**
1. Create `Sources/MyHummingbirdApp/Item.swift`:
   ```swift
   import Fluent

   final class Item: Model {
       static let schema = "items"

       @ID(key: .id)
       var id: UUID?

       @Field(key: "name")
       var name: String

       init() {}
       init(id: UUID? = nil, name: String) {
           self.id = id
           self.name = name
       }
   }
   ```

---

### **4.2 Define the Migration**
1. Create `Sources/MyHummingbirdApp/ItemMigration.swift`:
   ```swift
   import Fluent

   extension Item {
       struct Create: AsyncMigration {
           func prepare(on database: Database) async throws {
               try await database.schema("items")
                   .id()
                   .field("name", .string, .required)
                   .create()
           }

           func revert(on database: Database) async throws {
               try await database.schema("items").delete()
           }
       }
   }
   ```

---

### **4.3 Configure the Database**
Update `main.swift`:
```swift
import Hummingbird
import Fluent
import FluentSQLiteDriver

@main
struct App {
    static func main() async throws {
        let app = HBApplication()

        // Configure Fluent with SQLite
        app.databases.use(.sqlite(.memory), as: .sqlite)

        // Register migrations
        app.migrations.add(Item.Create())

        // Apply migrations
        try await app.autoMigrate().get()

        // Start the server
        try app.start()
    }
}
```

---

## **5. Implement the API**

### **5.1 Implement `APIProtocol`**
Add the API logic in `main.swift`:
```swift
import OpenAPIHummingbird

struct MyAPI: APIProtocol {
    func listItems() async throws -> [String] {
        // Fetch all items from the database
        let items = try await Item.query(on: HBApplication().db).all()
        return items.map { $0.name }
    }
}
```

---

### **5.2 Register the API**
Add the router integration in `main.swift`:
```swift
// Register API handlers
let api = MyAPI()
try api.registerHandlers(on: app.router)
```

---

## **6. Final `main.swift`**

Here’s the **complete `main.swift`** file after step 5.2:

```swift
// File: Sources/MyHummingbirdApp/main.swift

import Hummingbird
import Fluent
import FluentSQLiteDriver
import OpenAPIHummingbird

@main
struct App {
    static func main() async throws {
        let app = HBApplication()

        // Configure Fluent with SQLite
        app.databases.use(.sqlite(.memory), as: .sqlite)

        // Register migrations
        app.migrations.add(Item.Create())

        // Apply migrations
        try await app.autoMigrate().get()

        // Define and register the API implementation
        let api = MyAPI()
        try api.registerHandlers(on: app.router)

        // Start the Hummingbird server
        try app.start()
    }
}

import Fluent

final class Item: Model {
    static let schema = "items"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    init() {}
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

extension Item {
    struct Create: AsyncMigration {
        func prepare(on database: Database) async throws {
            try await database.schema("items")
                .id()
                .field("name", .string, .required)
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("items").delete()
        }
    }
}

struct MyAPI: APIProtocol {
    func listItems() async throws -> [String] {
        let items = try await Item.query(on: HBApplication().db).all()
        return items.map { $0.name }
    }
}
```

---

## **7. Build and Run**

1. Build the app:
   ```bash
   swift build
   ```

2. Run the app:
   ```bash
   swift run MyHummingbirdApp
   ```

3. Test the `/items` endpoint:
   ```bash
   curl http://localhost:8080/items
   ```

---

## **8. Final Project Structure**

```
MyHummingbirdApp/
├── Package.swift
├── Sources/
│   └── MyHummingbirdApp/
│       ├── main.swift
│       ├── openapi.yaml
│       ├── openapi-generator-config.yaml
│       ├── Item.swift
│       └── ItemMigration.swift
├── Tests/
│   └── MyHummingbirdAppTests/
│       └── MyHummingbirdAppTests.swift
```


# **Conclusion**

Congratulations! 🎉 You've successfully built a Hummingbird-based Swift application that leverages modern server-side technologies:

- **Swift OpenAPI Generator** to define and implement your API contract.
- **Fluent ORM** and **SQLite** for robust database management and persistence.
- **Hummingbird** as the lightweight, high-performance web framework.

This project gives you a scalable and extensible foundation for building RESTful APIs. Whether you’re adding more database models, expanding your API, or integrating external services, this tutorial has set up a clear path for future refactoring and enhancements.

For additional insights into OpenAPI with Hummingbird, explore the excellent resource: [Swift on Server: Using OpenAPI with Hummingbird](https://swiftonserver.com/using-openapi-with-hummingbird/). It provides detailed information about OpenAPI configurations and advanced use cases.


# Addendum: Integrating Typesense for Full-Text Search

Adding **Typesense** to your application enhances it with powerful full-text search capabilities. This section provides complete file views for integrating Typesense into your project.


##  `Package.swift`

Ensure your `Package.swift` includes all dependencies for Hummingbird, OpenAPI, Fluent ORM, SQLite, and Typesense.

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyHummingbirdApp",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "MyHummingbirdApp", targets: ["MyHummingbirdApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "1.7.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.7.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.5.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.1.0"),
        .package(url: "https://github.com/typesense/swift-typesense.git", from: "0.4.0"),
    ],
    targets: [
        .executableTarget(
            name: "MyHummingbirdApp",
            dependencies: [
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIHummingbird", package: "swift-openapi-hummingbird"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Typesense", package: "swift-typesense"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ],
            resources: [
                .process("openapi.yaml"),
                .process("openapi-generator-config.yaml"),
            ]
        ),
        .testTarget(
            name: "MyHummingbirdAppTests",
            dependencies: ["MyHummingbirdApp"]
        ),
    ]
)
```


##  `TypesenseConfig.swift`

Create a new file: `Sources/MyHummingbirdApp/TypesenseConfig.swift`.

```swift
import Typesense

struct TypesenseManager {
    static let client: Client = {
        let configuration = Configuration(
            nodes: [
                Node(protocol: .http, host: "localhost", port: 8108) // Replace with your Typesense server details
            ],
            apiKey: "YOUR_API_KEY", // Replace with your Typesense API key
            connectionTimeoutSeconds: 2
        )
        return Client(configuration: configuration)
    }()
}
```

## **Complete `main.swift`**

Here’s the full `main.swift` file with the `/search` endpoint and Typesense integration.

```swift
import Hummingbird
import Fluent
import FluentSQLiteDriver
import OpenAPIHummingbird
import Typesense

@main
struct App {
    static func main() async throws {
        let app = HBApplication()

        // Configure Fluent with SQLite
        app.databases.use(.sqlite(.memory), as: .sqlite)

        // Register migrations
        app.migrations.add(Item.Create())

        // Apply migrations
        try await app.autoMigrate().get()

        // Define and register the API implementation
        let api = MyAPI()
        try api.registerHandlers(on: app.router)

        // Add search endpoint using Typesense
        app.router.get("/search") { req -> EventLoopFuture<[String]> in
            let query = req.query.get(String.self, at: "query") ?? ""
            let searchParameters = SearchParameters(
                query: query,
                queryBy: "name"
            )
            return TypesenseManager.client.collection(name: "items")
                .documents()
                .search(parameters: searchParameters)
                .map { response in
                    response.hits.compactMap { $0.document["name"] as? String }
                }
        }

        // Start the Hummingbird server
        try app.start()
    }
}

import Fluent

final class Item: Model {
    static let schema = "items"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    init() {}
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

extension Item {
    struct Create: AsyncMigration {
        func prepare(on database: Database) async throws {
            try await database.schema("items")
                .id()
                .field("name", .string, .required)
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema("items").delete()
        }
    }
}

struct MyAPI: APIProtocol {
    func listItems() async throws -> [String] {
        let items = try await Item.query(on: HBApplication().db).all()
        return items.map { $0.name }
    }
}
```

## **5. Create Typesense Collection Schema**

Before running the application, ensure you’ve created the `items` collection in Typesense.

Run the following command to create the collection:
```bash
curl -X POST "http://localhost:8108/collections" \
-H "X-TYPESENSE-API-KEY: YOUR_API_KEY" \
-H "Content-Type: application/json" \
-d '{
  "name": "items",
  "fields": [
    {"name": "id", "type": "string"},
    {"name": "name", "type": "string"}
  ]
}'
```

---

## **6. Test the Application**

1. Build the app:
   ```bash
   swift build
   ```

2. Run the app:
   ```bash
   swift run MyHummingbirdApp
   ```

3. Test the `/search` endpoint by adding some items to the database (and indexing them in Typesense). Then run:
   ```bash
   curl "http://localhost:8080/search?query=item"
   ```


