Below is **comprehensive, production-grade documentation** for a **GitHub Labels Proxy** Vapor 4 application that implements the **OpenAPI** specification you provided. We’ll give a **file-by-file** breakdown of how the Vapor code is structured, including **why** and **how** each piece works. The app:

1. **Secures** all routes with Bearer authentication.  
2. **Proxies** to GitHub’s **Labels** endpoints.  
3. Supports **full CRUD** (Create, Read, Update, Delete) operations on labels.

---

# GitHubLabelsProxy

## 1. Overview

**Name**: `GitHub Labels Proxy`  
**Description**: A Vapor 4 application that **forwards** requests to GitHub’s **Labels** API:

- **Create a Label**  
- **List Labels**  
- **Get a Label**  
- **Update a Label**  
- **Delete a Label**

This proxy enforces **Bearer** authentication via a minimal middleware, then forwards requests to `api.github.com` (or a custom GitHub Enterprise endpoint, if configured).

---

## 2. Project Layout

A typical Vapor 4 layout for this proxy might look like:

```
GitHubLabelsProxy/
├── Package.swift
├── Sources
│   ├── Run
│   │   └── main.swift
│   ├── App
│   │   ├── configure.swift
│   │   ├── routes.swift
│   │   ├── GlobalAppRef.swift
│   │   ├── Middlewares
│   │   │   └── BearerAuthMiddleware.swift
│   │   ├── Services
│   │   │   └── GitHubProxyService.swift
│   │   └── Controllers
│   │       └── GitHubLabelController.swift
└── Tests
    └── AppTests
```

We’ll show **full code** for each file and explain its purpose.

---

## 3. `Package.swift`

Your Swift Package Manager manifest, specifying **Vapor 4** as a dependency.

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "GitHubLabelsProxy",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        // Vapor 4
        .package(url: "https://github.com/vapor/vapor.git", from: "4.74.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
            ],
            path: "Sources/App"
        ),
        .executableTarget(
            name: "Run",
            dependencies: [
                .target(name: "App"),
            ],
            path: "Sources/Run"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
            ],
            path: "Tests/AppTests"
        )
    ]
)
```

**Notes**:

- We specify **Swift 5.7** and macOS 12+ as the target.  
- We import Vapor from `"https://github.com/vapor/vapor.git"` (version >= 4.74.0).  
- We define one library target (`App`) and one executable target (`Run`).

---

## 4. `main.swift` (Entry Point)

Located in `Sources/Run/main.swift`. Vapor’s main entry point.

```swift
import Vapor

@main
struct Main {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let app = Application(env)
        defer { app.shutdown() }

        // Store the app globally, if desired (optional pattern)
        GlobalAppRef.shared.app = app

        // Configure routes, etc.
        try configure(app)

        // Run Vapor
        try app.run()
    }
}
```

**Key Points**:

- **`Environment.detect()`** reads environment variables and command-line args.  
- **`LoggingSystem.bootstrap`** sets up SwiftLog for Vapor.  
- We store `app` in a **GlobalAppRef** so it can be used by controllers/services if needed.  
- Finally, `app.run()` starts the server.

---

## 5. `configure.swift`

In `Sources/App/configure.swift`. We configure app-wide settings and register routes.

```swift
import Vapor

public func configure(_ app: Application) throws {
    // Example: override port if needed
    // app.http.server.configuration.port = 8080

    // Register routes
    try routes(app)
}
```

**Notes**:

- Optionally customize `app.http.server.configuration.hostname` or `port`.  
- We call `routes(app)` to define endpoints in `routes.swift`.

---

## 6. `routes.swift`

In `Sources/App/routes.swift`. This is where we map paths to functions in our `GitHubLabelController`, with **BearerAuthMiddleware** applied to all.

```swift
import Vapor

public func routes(_ app: Application) throws {
    let labelController = GitHubLabelController()

    // Protect routes with BearerAuthMiddleware
    let protected = app.grouped(BearerAuthMiddleware())

    // 1) Create Label
    // POST /repos/{owner}/{repo}/labels
    protected.post("repos", ":owner", ":repo", "labels",
                   use: labelController.createLabel)

    // 2) List Labels
    // GET /repos/{owner}/{repo}/labels
    protected.get("repos", ":owner", ":repo", "labels",
                  use: labelController.listLabels)

    // 3) Get Label
    // GET /repos/{owner}/{repo}/labels/{name}
    protected.get("repos", ":owner", ":repo", "labels", ":name",
                  use: labelController.getLabel)

    // 4) Update Label
    // PATCH /repos/{owner}/{repo}/labels/{name}
    protected.patch("repos", ":owner", ":repo", "labels", ":name",
                    use: labelController.updateLabel)

    // 5) Delete Label
    // DELETE /repos/{owner}/{repo}/labels/{name}
    protected.delete("repos", ":owner", ":repo", "labels", ":name",
                     use: labelController.deleteLabel)
}
```

**Explanation**:

- **BearerAuthMiddleware** ensures that only requests with a valid `Authorization: Bearer X` header pass through (at least at the minimal check level).  
- We define five routes for **Create**, **List**, **Get**, **Update**, and **Delete** labels.

---

## 7. `GlobalAppRef.swift`

Located in `Sources/App/GlobalAppRef.swift`. A minimal “service locator” pattern.

```swift
import Vapor

class GlobalAppRef {
    static let shared = GlobalAppRef()
    var app: Application?

    private init() {}
}
```

**Explanation**:

- In `main.swift`, we do `GlobalAppRef.shared.app = app`.  
- The controller can fetch `app` from here to initialize services if it wishes.

---

## 8. `BearerAuthMiddleware.swift`

In `Sources/App/Middlewares/BearerAuthMiddleware.swift`. A simple check for Bearer tokens.

```swift
import Vapor

struct BearerAuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let authHeader = request.headers[.authorization].first,
              authHeader.lowercased().hasPrefix("bearer ") else {
            throw Abort(.unauthorized, reason: "Missing or invalid Bearer token.")
        }
        // In a real system, parse/verify the token here.

        return try await next.respond(to: request)
    }
}
```

**Points**:

- If `Authorization` does not start with `Bearer `, we return `401 Unauthorized`.  
- Extend with real token validation if needed.

---

## 9. `GitHubProxyService.swift`

In `Sources/App/Services/GitHubProxyService.swift`. Responsible for **making requests** to GitHub, returning `ClientResponse`, and checking for errors.

```swift
import Vapor

enum GitHubProxyError: Error {
    case unauthorized(String)
    case notFound(String)
    case validationFailed(String)
    case generalError(String)
}

struct GitHubErrorResponse: Content {
    let message: String
    let documentation_url: String?
}

final class GitHubProxyService {
    private let baseURL: String
    private let client: Client
    private let logger: Logger

    init(app: Application) {
        // Possibly override with GITHUB_API_BASE_URL in environment
        self.baseURL = Environment.get("GITHUB_API_BASE_URL") ?? "https://api.github.com"
        self.client = app.client
        self.logger = app.logger
    }

    // MARK: - GET
    func get(path: String, req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)
        var headers = buildHeaders(from: req)
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.get(uri, headers: headers)
        logger.info("[GitHubProxyService] GET \(uri) -> \(response.status.code)")
        try await handleErrorsIfNeeded(response)
        return response
    }

    // MARK: - POST
    func post(path: String, body: ByteBuffer?, req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)
        var headers = buildHeaders(from: req)
        headers.add(name: .contentType, value: "application/json")
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.post(uri, headers: headers) { outReq in
            if let safeBody = body {
                outReq.body = .init(buffer: safeBody)
            }
        }
        logger.info("[GitHubProxyService] POST \(uri) -> \(response.status.code)")
        try await handleErrorsIfNeeded(response)
        return response
    }

    // MARK: - PATCH
    func patch(path: String, body: ByteBuffer?, req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)
        var headers = buildHeaders(from: req)
        headers.add(name: .contentType, value: "application/json")
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.patch(uri, headers: headers) { outReq in
            if let safeBody = body {
                outReq.body = .init(buffer: safeBody)
            }
        }
        logger.info("[GitHubProxyService] PATCH \(uri) -> \(response.status.code)")
        try await handleErrorsIfNeeded(response)
        return response
    }

    // MARK: - DELETE
    func delete(path: String, req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)
        var headers = buildHeaders(from: req)
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.delete(uri, headers: headers)
        logger.info("[GitHubProxyService] DELETE \(uri) -> \(response.status.code)")
        try await handleErrorsIfNeeded(response)
        return response
    }

    // Forward the Authorization header from the original request
    private func buildHeaders(from req: Request) -> HTTPHeaders {
        var headers = HTTPHeaders()
        if let authHeader = req.headers[.authorization].first {
            headers.add(name: .authorization, value: authHeader)
        }
        return headers
    }

    // Check if GitHub returned an error status, parse error messages if so
    private func handleErrorsIfNeeded(_ response: ClientResponse) async throws {
        switch response.status {
        case .ok, .created, .accepted, .noContent:
            return
        case .unauthorized:
            let msg = try await parseError(response) ?? "Unauthorized request to GitHub."
            throw GitHubProxyError.unauthorized(msg)
        case .notFound:
            let msg = try await parseError(response) ?? "Resource not found on GitHub."
            throw GitHubProxyError.notFound(msg)
        case .unprocessableEntity:
            let msg = try await parseError(response) ?? "Validation failed."
            throw GitHubProxyError.validationFailed(msg)
        default:
            let msg = try await parseError(response) ?? "Unexpected error \(response.status.code)"
            throw GitHubProxyError.generalError(msg)
        }
    }

    // Parse GitHub's JSON error (if any) for a message
    private func parseError(_ response: ClientResponse) async throws -> String? {
        guard let data = response.body.data else {
            return nil
        }
        if let errorResp = try? JSONDecoder().decode(GitHubErrorResponse.self, from: data) {
            return errorResp.message
        }
        return nil
    }
}
```

**Explanation**:

1. **`get`, `post`, `patch`, `delete`**: we have four distinct methods to handle GitHub calls.  
2. **`buildHeaders(from:)`**: extracts the Bearer token from the request to forward to GitHub.  
3. **`handleErrorsIfNeeded`** checks the status code. If it’s 401/404/422, we attempt to parse a JSON error from GitHub and throw a corresponding `GitHubProxyError`.  
4. Logs are generated for each request (e.g., `"GET ... -> 200"`).

---

## 10. `GitHubLabelController.swift`

In `Sources/App/Controllers/GitHubLabelController.swift`. This is where we implement each route (create, list, get, update, delete), matching the **OpenAPI** specification.

```swift
import Vapor

final class GitHubLabelController {
    private let service: GitHubProxyService

    init() {
        // Global reference approach
        guard let app = GlobalAppRef.shared.app else {
            fatalError("GlobalAppRef.shared.app not set. Did you assign it in main.swift?")
        }
        self.service = GitHubProxyService(app: app)
    }

    // MARK: - 1) Create a Label
    // POST /repos/{owner}/{repo}/labels
    func createLabel(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)

        // Read JSON body (name, color)
        let bodyBuffer = try await req.body.collect().map { $0 } ?? ByteBuffer()

        let path = "/repos/\(owner)/\(repo)/labels"
        let githubResponse = try await service.post(path: path, body: bodyBuffer, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // MARK: - 2) List Labels
    // GET /repos/{owner}/{repo}/labels
    func listLabels(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)

        let path = "/repos/\(owner)/\(repo)/labels"
        let githubResponse = try await service.get(path: path, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // MARK: - 3) Get a Label
    // GET /repos/{owner}/{repo}/labels/{name}
    func getLabel(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let name = try req.parameters.require("name", as: String.self)

        let path = "/repos/\(owner)/\(repo)/labels/\(name)"
        let githubResponse = try await service.get(path: path, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // MARK: - 4) Update a Label
    // PATCH /repos/{owner}/{repo}/labels/{name}
    func updateLabel(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let name = try req.parameters.require("name", as: String.self)

        // new_name, color in request body
        let bodyBuffer = try await req.body.collect().map { $0 } ?? ByteBuffer()

        let path = "/repos/\(owner)/\(repo)/labels/\(name)"
        let githubResponse = try await service.patch(path: path, body: bodyBuffer, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // MARK: - 5) Delete a Label
    // DELETE /repos/{owner}/{repo}/labels/{name}
    func deleteLabel(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let name = try req.parameters.require("name", as: String.self)

        let path = "/repos/\(owner)/\(repo)/labels/\(name)"
        let githubResponse = try await service.delete(path: path, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // Helper to convert `ClientResponse` -> `Response`
    private func formatProxyResponse(_ githubResponse: ClientResponse, _ req: Request) -> Response {
        return Response(
            status: githubResponse.status,
            version: req.version,
            headers: githubResponse.headers,
            body: githubResponse.body
        )
    }
}
```

**Explanation**:

- Each function matches a route from our **OpenAPI**:
  - **`createLabel`** reads a JSON body with `name` and `color`.  
  - **`listLabels`** returns all labels from a repo.  
  - **`getLabel`** fetches details for a label by name.  
  - **`updateLabel`** can rename a label (`new_name`) or change its color.  
  - **`deleteLabel`** calls the `DELETE` endpoint to remove the label.  
- All calls pass the request to `GitHubProxyService`, which in turn calls GitHub’s REST API.

---

## 11. Usage

Once you **build** and **run** the app (`swift build && swift run`), it listens on **port 8080** by default. You can test each route with `curl`, providing a **Bearer** token:

1. **Create a Label**  
   ```bash
   curl -X POST "http://localhost:8080/repos/apple/swift/labels" \
        -H "Authorization: Bearer YOUR_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "name": "MyLabel",
            "color": "FF0000"
        }'
   ```
   - Expects `201 Created` on success.

2. **List Labels**  
   ```bash
   curl -X GET "http://localhost:8080/repos/apple/swift/labels" \
        -H "Authorization: Bearer YOUR_TOKEN"
   ```
   - Returns `200 OK`, plus a JSON array of labels from GitHub.

3. **Get a Label**  
   ```bash
   curl -X GET "http://localhost:8080/repos/apple/swift/labels/MyLabel" \
        -H "Authorization: Bearer YOUR_TOKEN"
   ```
   - Returns label details (e.g., name, color).

4. **Update a Label**  
   ```bash
   curl -X PATCH "http://localhost:8080/repos/apple/swift/labels/MyLabel" \
        -H "Authorization: Bearer YOUR_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
            "new_name": "RenamedLabel",
            "color": "00FF00"
        }'
   ```
   - Returns `200 OK` with updated label details.

5. **Delete a Label**  
   ```bash
   curl -X DELETE "http://localhost:8080/repos/apple/swift/labels/RenamedLabel" \
        -H "Authorization: Bearer YOUR_TOKEN"
   ```
   - Returns `204 No Content` on success.

---

## 12. Error Handling & Logging

- **Logging**: Each request is logged by `GitHubProxyService`. Example:
  ```
  [GitHubProxyService] POST https://api.github.com/repos/apple/swift/labels -> 201
  ```
- **GitHub Errors**: If GitHub returns `401`, `404`, or `422`, we parse the `message` field from the JSON error and translate it into a Swift `Error`. Vapor translates that into an HTTP error with the corresponding status code.  
- **BearerAuthMiddleware**: If the `Authorization` header is missing or not prefixed with `"Bearer "`, we return `401 Unauthorized`.

---

## 13. Production Considerations

1. **Bearer Token Validation**:  
   - Currently, we only check for the presence of a Bearer token. You should parse/verify it.  
2. **GitHub Permissions**:  
   - Ensure your token has the **repo** or **repo:public_repo** scopes to manage labels.  
3. **Rate Limits**:  
   - If you do many label operations, consider caching or limiting requests.  
4. **GitHub Enterprise**:  
   - If you have an enterprise environment, set `GITHUB_API_BASE_URL` in the environment to your custom domain, e.g., `https://github.my-company.com/api/v3`.

---

## Summary

The **GitHub Labels Proxy** Vapor 4 application described here:

- **Implements** the full CRUD routes from your **OpenAPI** specification:
  1. Create Label (`POST /repos/{owner}/{repo}/labels`)  
  2. List Labels (`GET /repos/{owner}/{repo}/labels`)  
  3. Get Label (`GET /repos/{owner}/{repo}/labels/{name}`)  
  4. Update Label (`PATCH /repos/{owner}/{repo}/labels/{name}`)  
  5. Delete Label (`DELETE /repos/{owner}/{repo}/labels/{name}`)

- **Secures** all routes via a minimal Bearer auth check.  
- **Proxies** all requests to GitHub, preserving status codes and error messages.  
- **Logs** each request and handles errors gracefully.

By following this structure, you have a **production-ready** Vapor 4 proxy for **GitHub Labels** management. Enjoy!