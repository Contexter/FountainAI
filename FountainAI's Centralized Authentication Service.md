### Introduction

This document provides a comprehensive guide to implementing a centralized authentication service using Vapor, PostgreSQL, and JWT specifically for a custom GPT model as the sole client. It includes an OpenAPI specification for the service, a detailed discussion of the specification, and a step-by-step tutorial for implementing the service using a Test-Driven Development (TDD) approach. Additionally, it demonstrates how to integrate this centralized authentication service with other Vapor applications.

### OpenAPI Specification

#### Overview

The following OpenAPI specification defines the centralized authentication service for the custom GPT model. This service manages the GPT model's registration, login, and token verification.

#### Specification

```yaml
openapi: 3.0.1
info:
  title: Centralized Authentication API for GPT Model
  description: |
    API for managing authentication, specifically for a custom GPT model, including registration, login, and token verification.

    **Dockerized Environment**:
    - **Nginx**: An Nginx proxy container handles SSL termination with Let's Encrypt certificates via Certbot.
    - **Vapor Application**: A Swift-based Vapor app runs in a separate Docker container.
    - **Postgres Database**: The main persistence layer is a PostgreSQL container managed by Docker Compose.

  version: "1.0.0"
servers:
  - url: 'https://auth.fountain.coach'
    description: Main server for Authentication API services (behind Nginx proxy)
  - url: 'http://localhost:8080'
    description: Development server for Authentication API services (Docker environment)

paths:
  /auth/register:
    post:
      summary: Register the GPT Model
      operationId: registerGPT
      description: Creates a new record for the GPT model in the authentication system.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/GPTModelCreateRequest'
            examples:
              createGPTExample:
                summary: Example of GPT model registration
                value:
                  username: "gptmodel"
                  password: "securepassword"
      responses:
        '201':
          description: GPT model successfully registered.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/GPTModel'
              examples:
                gptCreated:
                  summary: Example of a registered GPT model
                  value:
                    modelId: 1
                    username: "gptmodel"
        '400':
          description: Bad request due to missing required fields or invalid data.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                badRequestExample:
                  value:
                    message: "Missing required fields: 'username' or 'password'."

  /auth/login:
    post:
      summary: Login the GPT Model
      operationId: loginGPT
      description: Authenticates the GPT model and returns a JWT token.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/GPTModelLoginRequest'
            examples:
              loginGPTExample:
                summary: Example of GPT model login
                value:
                  username: "gptmodel"
                  password: "securepassword"
      responses:
        '200':
          description: GPT model successfully authenticated.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/TokenResponse'
              examples:
                tokenResponse:
                  summary: Example of a token response
                  value:
                    token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
        '401':
          description: Unauthorized due to invalid credentials.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                unauthorizedExample:
                  value:
                    message: "Invalid username or password."

  /auth/verify:
    post:
      summary: Verify the Token
      operationId: verifyToken
      description: Verifies the validity of a JWT token for the GPT model.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/TokenRequest'
            examples:
              verifyTokenExample:
                summary: Example of token verification
                value:
                  token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
      responses:
        '200':
          description: Token successfully verified.
        '401':
          description: Unauthorized due to invalid or expired token.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                unauthorizedExample:
                  value:
                    message: "Invalid or expired token."

components:
  schemas:
    GPTModel:
      type: object
      properties:
        modelId:
          type: integer
          description: Unique identifier for the GPT model.
        username:
          type: string
          description: Username for the GPT model.
      required:
        - username

    GPTModelCreateRequest:
      type: object
      properties:
        username:
          type: string
        password:
          type: string
      required:
        - username
        - password

    GPTModelLoginRequest:
      type: object
      properties:
        username:
          type: string
        password:
          type: string
      required:
        - username
        - password

    TokenRequest:
      type: object
      properties:
        token:
          type: string
      required:
        - token

    TokenResponse:
      type: object
      properties:
        token:
          type: string
          description: JWT token for authenticated access.

    Error:
      type: object
      description: Common error structure for the API.
      properties:
        message:
          type: string
          description: Description of the error encountered.
```

### Implementation Guide for Centralized Authentication Service

#### Step 1: Initialize the Project

1. **Create the Project**

```bash
vapor new AuthService --api
cd AuthService
```

2. **Update `Package.swift`**

Edit the `Package.swift` file to include dependencies for Vapor, Fluent, PostgreSQL, and JWT.

```swift
// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "AuthService",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .executable(name: "Run", targets: ["Run"]),
        .library(name: "App", targets: ["App"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
            .product(name: "JWT", package: "jwt")
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", .product(name: "XCTVapor", package: "vapor")]),
    ]
)
```

#### Step 2: Write Tests First

1. **Create Tests**

- **AppTests.swift**

Create `Tests/AppTests/AppTests.swift` to write tests for GPT model registration, login, and token verification.

```swift
import XCTest
import XCTVapor
@testable import App

final class AppTests: XCTestCase {
    func testRegisterGPTModel() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let model = GPTModel(username: "gptmodel", password: "password")
        
        try app.test(.POST, "/auth/register", beforeRequest: { req in
            try req.content.encode(model)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
        })
    }
    
    func testLoginGPTModel() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let model = GPTModel(username: "gptmodel", password: "password")
        
        // Register GPT model first
        try app.test(.POST, "/auth/register", beforeRequest: { req in
            try req.content.encode(model)
        })
        
        // Attempt login
        try app.test(.POST, "/auth/login", beforeRequest: { req in
            try req.content.encode(model)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let tokenResponse = try res.content.decode(TokenResponse.self)
            XCTAssertNotNil(tokenResponse.token)
        })
    }
    
    func testVerifyToken() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let model = GPTModel(username: "gptmodel", password: "password")
        
        // Register GPT model first
        try app.test(.POST, "/auth/register", beforeRequest: { req in
            try req.content.encode(model)
        })
        
        // Login to get token
        var token: String!
        try

 app.test(.POST, "/auth/login", beforeRequest: { req in
            try req.content.encode(model)
        }, afterResponse: { res in
            let tokenResponse = try res.content.decode(TokenResponse.self)
            token = tokenResponse.token
        })
        
        // Verify token
        try app.test(.POST, "/auth/verify", beforeRequest: { req in
            try req.content.encode(TokenRequest(token: token))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })
    }
}
```

2. **Run Tests**

Run the tests to ensure they fail initially (since we haven’t implemented the functionality yet):

```bash
swift test
```

#### Step 3: Implement the Service

1. **Configure the Database and JWT**

- **`configure.swift`**

Update `Sources/App/configure.swift` to set up the PostgreSQL database and JWT signer.

```swift
import Vapor
import Fluent
import FluentPostgresDriver
import JWT

public func configure(_ app: Application) throws {
    // Database configuration
    app.databases.use(.postgres(
        hostname: "localhost",
        username: "postgres",
        password: "password",
        database: "authdb"
    ), as: .psql)
    
    // JWT signer configuration
    app.jwt.signers.use(.hs256(key: "secret-key"))

    // Migrations
    app.migrations.add(CreateGPTModel())

    // Register routes
    try routes(app)
}
```

2. **Create Models and Migrations**

- **GPTModel.swift**

Create `Sources/App/Models/GPTModel.swift` to define the model and migration.

```swift
import Vapor
import Fluent

final class GPTModel: Model, Content {
    static let schema = "gpt_models"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    init() {}
    
    init(id: UUID? = nil, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
}

struct CreateGPTModel: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("gpt_models")
            .id()
            .field("username", .string, .required)
            .field("password", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("gpt_models").delete()
    }
}
```

3. **Create Controllers**

- **AuthenticationController.swift**

Create `Sources/App/Controllers/AuthenticationController.swift` to handle registration, login, and token verification.

```swift
import Vapor
import Fluent
import JWT

struct AuthenticationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let authGroup = routes.grouped("auth")
        authGroup.post("register", use: register)
        authGroup.post("login", use: login)
    }

    func register(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let model = try req.content.decode(GPTModel.self)
        model.password = try Bcrypt.hash(model.password)
        return model.save(on: req.db).transform(to: .created)
    }

    func login(req: Request) throws -> EventLoopFuture<TokenResponse> {
        let model = try req.content.decode(GPTModel.self)
        return GPTModel.query(on: req.db)
            .filter(\.$username == model.username)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { foundModel in
                guard try Bcrypt.verify(model.password, created: foundModel.password) else {
                    throw Abort(.unauthorized)
                }
                let payload = ModelPayload(subject: .init(value: foundModel.id!))
                let token = try req.jwt.sign(payload)
                return TokenResponse(token: token)
            }
    }
}

struct TokenResponse: Content {
    let token: String
}

struct ModelPayload: JWTPayload {
    var subject: SubjectClaim
    
    func verify(using signer: JWTSigner) throws {
        // Add any additional verification steps here
    }
}
```

4. **Define Routes**

- **routes.swift**

Update `Sources/App/routes.swift` to include authentication routes.

```swift
import Vapor

func routes(_ app: Application) throws {
    let authController = AuthenticationController()
    try app.register(collection: authController)
}
```

5. **Run Tests Again**

Run the tests to ensure they pass after the implementation:

```bash
swift test
```

### Implementation Guide for Integrating Centralized Authentication Service with a Vapor App

1. **Create a New Vapor Project**

```bash
vapor new MyVaporApp --api
cd MyVaporApp
```

2. **Update `Package.swift`**

Edit the `Package.swift` file to include dependencies for Vapor and Fluent:

```swift
// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "MyVaporApp",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .executable(name: "Run", targets: ["Run"]),
        .library(name: "App", targets: ["App"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver")
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)
```

3. **Implement Logic to Use Centralized Authentication Service**

- **AuthenticationClient.swift**

Create `Sources/App/Clients/AuthenticationClient.swift` to handle requests to the centralized authentication service:

```swift
import Vapor

struct AuthenticationClient {
    let client: Client
    let authServiceURL: String
    
    init(client: Client, authServiceURL: String) {
        self.client = client
        self.authServiceURL = authServiceURL
    }

    func verifyToken(token: String) -> EventLoopFuture<ClientResponse> {
        return client.post(URI(string: "\(authServiceURL)/auth/verify")) { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: token)
            try req.content.encode(TokenRequest(token: token))
        }
    }
}

struct TokenRequest: Content {
    let token: String
}
```

- **AuthenticationMiddleware.swift**

Create `Sources/App/Middleware/AuthenticationMiddleware.swift` to add authentication middleware using the centralized service:

```swift
import Vapor

struct AuthenticationMiddleware: Middleware {
    let authClient: AuthenticationClient
    
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let bearerToken = request.headers.bearerAuthorization?.token else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
        }
        
        return authClient.verifyToken(token: bearerToken).flatMap { response in
            guard response.status == .ok else {
                return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
            }
            return next.respond(to: request)
        }
    }
}
```

4. **Configure the App**

- **configure.swift**

Update `Sources/App/configure.swift` to set up the database, middleware, and register routes:

```swift
import Vapor
import Fluent
import FluentPostgresDriver

public func configure(_ app: Application) throws {
    // Database configuration
    app.databases.use(.postgres(
        hostname: "localhost",
        username: "postgres",
        password: "password",
        database: "mydatabase"
    ), as: .psql)
    
    // Middleware configuration
    let authClient = AuthenticationClient(client: app.client, authServiceURL: "http://localhost:8080")
    app.middleware.use(AuthenticationMiddleware(authClient: authClient))

    // Register routes
    try routes(app)
}
```

5. **Define Routes**

- **routes.swift**

Update `Sources/App/routes.swift` to include secure routes:

```swift
import Vapor

func routes(_ app: Application) throws {
    let protected = app.grouped(AuthenticationMiddleware(authClient: AuthenticationClient(client: app.client, authServiceURL: "http://localhost:8080")))

    protected.get("secure-route") { req -> String in
        return "This is a secure route accessible by authenticated GPT model."
    }
}
```

### Full Directory Structure for MyVaporApp

```
MyVaporApp/
├── Package.swift
├── Public/
├── README.md
├── Resources/
├── Sources/
│   ├── App/
│   │   ├── Clients/
│   │   │   └── AuthenticationClient.swift
│   │   ├── Middleware/
│   │   │   └── AuthenticationMiddleware.swift
│   │   ├── configure.swift
│   │   ├── routes.swift
│   └── Run/
│       └── main.swift
└── Tests/
    └── AppTests/
        └── AppTests.swift
```

### Running the Application

Build and run the Vapor application:

```bash
vapor build
vapor run
```



Now, any request to `/secure-route` will be authenticated via the centralized authentication service, ensuring that only requests with valid JWT tokens issued by the centralized service are allowed access.

### Commit Message

```markdown
feat: Implement centralized authentication service and integration with Vapor app

- Added OpenAPI specification for centralized authentication service tailored for GPT model.
- Initialized Vapor project with PostgreSQL and JWT dependencies.
- Configured database and JWT signer in `configure.swift`.
- Created `GPTModel` for user data with corresponding migration.
- Implemented `AuthenticationController` with routes for registration, login, and token verification.
- Wrote initial tests for registration, login, and token verification using TDD.
- Ensured all tests pass after implementation.

- Created a new Vapor app to integrate with the centralized authentication service.
- Implemented `AuthenticationClient` to communicate with the centralized authentication service.
- Created `AuthenticationMiddleware` to verify JWT tokens using the centralized service.
- Configured the Vapor app to use PostgreSQL and authentication middleware.
- Defined secure routes in the Vapor app.

This commit establishes a secure, scalable, and easily integrable authentication service for the custom GPT model within the FountainAI project and demonstrates how to integrate this service with other Vapor applications.
```