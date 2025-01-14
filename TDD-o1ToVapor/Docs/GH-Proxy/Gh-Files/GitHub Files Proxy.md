Below is **comprehensive, production-ready documentation** for a **GitHub Files/Contents Proxy** Vapor 4 application implementing the **OpenAPI** specification you provided. It covers **CRUD** operations on **repository files** (get content, create/update, delete), secured by **Bearer** authentication. As with previous examples, we’ll detail a typical Vapor project structure and **why** each file exists.

---

# GitHub Files Proxy

## 1. Overview

**Name**: `GitHub Files Proxy`  
**Description**: A Vapor 4 application that **proxies** requests to GitHub’s [Contents REST API](https://docs.github.com/en/rest/repos/contents). It supports:

1. **Get file or directory content**  
2. **Create or update a file**  
3. **Delete a file**  

All routes require **Bearer** authentication.

---

## 2. Project Layout

A common Vapor 4 layout for this proxy app might be:

```
GitHubFilesProxy/
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
│   │       └── GitHubFileController.swift
└── Tests
    └── AppTests
```

We’ll show **full code** snippets for each file, describing their purpose.

---

## 3. `Package.swift`

The Swift Package Manager manifest listing **Vapor 4** as a dependency.

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "GitHubFilesProxy",
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

- **Vapor 4** is pulled from `"https://github.com/vapor/vapor.git"`.  
- We define a library target (`App`) and an executable target (`Run`).

---

## 4. `main.swift` (Entry Point)

In `Sources/Run/main.swift`. Vapor’s main entry point.

```swift
import Vapor

@main
struct Main {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let app = Application(env)
        defer { app.shutdown() }

        // Optionally store the app globally for usage in controllers/services
        GlobalAppRef.shared.app = app

        try configure(app)
        try app.run()
    }
}
```

**Key Points**:

- **`Environment.detect()`** picks up environment variables and command-line options.  
- **`LoggingSystem.bootstrap`** sets up SwiftLog.  
- **`app.run()`** starts the Vapor server.  
- We store `app` in **GlobalAppRef** (optional pattern) so we can retrieve it in controllers.

---

## 5. `configure.swift`

In `Sources/App/configure.swift`. Register routes and any server config.

```swift
import Vapor

public func configure(_ app: Application) throws {
    // e.g. override port: app.http.server.configuration.port = 8080

    // Register routes
    try routes(app)
}
```

**Explanation**:

- Customize `hostname` or `port` if desired.  
- We call `routes(app)` to configure endpoints in `routes.swift`.

---

## 6. `routes.swift`

In `Sources/App/routes.swift`. Defines REST endpoints for file management, secured by `BearerAuthMiddleware`.

```swift
import Vapor

public func routes(_ app: Application) throws {
    let fileController = GitHubFileController()

    // Group behind BearerAuthMiddleware
    let protected = app.grouped(BearerAuthMiddleware())

    // 1) Get File or Directory Content
    // GET /repos/{owner}/{repo}/contents/{path}
    protected.get("repos", ":owner", ":repo", "contents", "**", use: fileController.getFileContent)
    // Explanation: we might use "**" to capture subdirectories in the path, or handle URL-encoding.

    // 2) Create or Update File
    // PUT /repos/{owner}/{repo}/contents/{path}
    protected.put("repos", ":owner", ":repo", "contents", "**", use: fileController.createOrUpdateFile)

    // 3) Delete File
    // DELETE /repos/{owner}/{repo}/contents/{path}
    protected.delete("repos", ":owner", ":repo", "contents", "**", use: fileController.deleteFile)
}
```

**Note**:  

- In Vapor, if you need to handle multiple path components (`foo/bar/baz.txt`), you can use a catchall parameter like `"**"` or pass custom logic to preserve slashes in the path. Alternatively, you might just use `":path"` if you expect a single segment or URL-encode slashes.  
- The code above is a simplified approach—**adjust** if you need different slash handling.

---

## 7. `GlobalAppRef.swift`

In `Sources/App/GlobalAppRef.swift`. A minimal “service locator.”

```swift
import Vapor

class GlobalAppRef {
    static let shared = GlobalAppRef()
    var app: Application?

    private init() {}
}
```

**Explanation**:

- We do `GlobalAppRef.shared.app = app` in `main.swift`.  
- The controller can fetch `app` from here to create the `GitHubProxyService`.

---

## 8. `BearerAuthMiddleware.swift`

In `Sources/App/Middlewares/BearerAuthMiddleware.swift`. Checks for a `Bearer` token in the `Authorization` header.

```swift
import Vapor

struct BearerAuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let authHeader = request.headers[.authorization].first,
              authHeader.lowercased().starts(with: "bearer ") else {
            throw Abort(.unauthorized, reason: "Missing or invalid Bearer token.")
        }
        // Optionally validate the token

        return try await next.respond(to: request)
    }
}
```

**Notes**:

- If absent or malformed, returns `401 Unauthorized`.  
- In production, parse/verify the token for real security.

---

## 9. `GitHubProxyService.swift`

In `Sources/App/Services/GitHubProxyService.swift`. Manages HTTP calls to GitHub’s API, logs them, and handles errors.

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
        // e.g. "https://api.github.com" or from environment
        self.baseURL = Environment.get("GITHUB_API_BASE_URL") ?? "https://api.github.com"
        self.client = app.client
        self.logger = app.logger
    }

    // GET
    func get(path: String, req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)
        var headers = buildHeaders(from: req)
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.get(uri, headers: headers)
        logger.info("[GitHubProxyService] GET \(uri) -> \(response.status.code)")
        try await handleErrorsIfNeeded(response)
        return response
    }

    // PUT (Create or Update)
    func put(path: String, body: ByteBuffer?, req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)
        var headers = buildHeaders(from: req)
        headers.add(name: .contentType, value: "application/json")
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.put(uri, headers: headers) { outReq in
            if let safeBody = body {
                outReq.body = .init(buffer: safeBody)
            }
        }
        logger.info("[GitHubProxyService] PUT \(uri) -> \(response.status.code)")
        try await handleErrorsIfNeeded(response)
        return response
    }

    // DELETE
    func delete(path: String, req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)
        var headers = buildHeaders(from: req)
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.delete(uri, headers: headers)
        logger.info("[GitHubProxyService] DELETE \(uri) -> \(response.status.code)")
        try await handleErrorsIfNeeded(response)
        return response
    }

    // Forward the Authorization header
    private func buildHeaders(from req: Request) -> HTTPHeaders {
        var headers = HTTPHeaders()
        if let authHeader = req.headers[.authorization].first {
            headers.add(name: .authorization, value: authHeader)
        }
        return headers
    }

    private func handleErrorsIfNeeded(_ response: ClientResponse) async throws {
        switch response.status {
        case .ok, .created, .accepted, .noContent:
            // success
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

    private func parseError(_ response: ClientResponse) async throws -> String? {
        guard let data = response.body.data else {
            return nil
        }
        if let errorBody = try? JSONDecoder().decode(GitHubErrorResponse.self, from: data) {
            return errorBody.message
        }
        return nil
    }
}
```

**Explanation**:

- We define methods `get`, `put`, and `delete` to match the GitHub endpoints for files.  
- **`buildHeaders`** extracts `Authorization` from the request to forward to GitHub.  
- **`handleErrorsIfNeeded`** checks common statuses (`401`, `404`, `422`) and logs the request.  

---

## 10. `GitHubFileController.swift`

In `Sources/App/Controllers/GitHubFileController.swift`. Defines route-handling functions for file or directory content, create/update file, and delete file.

```swift
import Vapor

final class GitHubFileController {
    private let service: GitHubProxyService

    init() {
        guard let app = GlobalAppRef.shared.app else {
            fatalError("GlobalAppRef.shared.app not set in main.swift.")
        }
        self.service = GitHubProxyService(app: app)
    }

    // MARK: - 1) Get File/Directory Content
    // GET /repos/{owner}/{repo}/contents/{path}
    func getFileContent(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)

        // Using a catchall param if you used "**" in routes.
        let filePath = try req.parameters.requireCatchall().joined(separator: "/")

        let githubPath = "/repos/\(owner)/\(repo)/contents/\(filePath)"
        let githubResponse = try await service.get(path: githubPath, req: req)

        return formatProxyResponse(githubResponse, req)
    }

    // MARK: - 2) Create or Update File
    // PUT /repos/{owner}/{repo}/contents/{path}
    func createOrUpdateFile(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let filePath = try req.parameters.requireCatchall().joined(separator: "/")

        let bodyBuffer = try await req.body.collect().map { $0 } ?? ByteBuffer()
        let githubPath = "/repos/\(owner)/\(repo)/contents/\(filePath)"

        let githubResponse = try await service.put(path: githubPath, body: bodyBuffer, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // MARK: - 3) Delete File
    // DELETE /repos/{owner}/{repo}/contents/{path}?message=...&sha=...&branch=...
    func deleteFile(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let filePath = try req.parameters.requireCatchall().joined(separator: "/")

        // Query params for message, sha, branch
        guard let message = req.query[String.self, at: "message"] else {
            throw Abort(.badRequest, reason: "Missing required 'message' query param")
        }
        guard let sha = req.query[String.self, at: "sha"] else {
            throw Abort(.badRequest, reason: "Missing required 'sha' query param")
        }
        let branch = req.query[String.self, at: "branch"]

        // Build the path with query params
        var pathWithQueries = "/repos/\(owner)/\(repo)/contents/\(filePath)?message=\(message.urlEncoded)&sha=\(sha.urlEncoded)"
        if let b = branch?.urlEncoded, !b.isEmpty {
            pathWithQueries += "&branch=\(b)"
        }

        let githubResponse = try await service.delete(path: pathWithQueries, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // Convert `ClientResponse` -> `Response`
    private func formatProxyResponse(_ githubResponse: ClientResponse, _ req: Request) -> Response {
        return Response(
            status: githubResponse.status,
            version: req.version,
            headers: githubResponse.headers,
            body: githubResponse.body
        )
    }
}

// A small String extension for URL-encoding, if needed
private extension String {
    var urlEncoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
```

**Explanation**:

1. **`getFileContent`**:  
   - Reads `owner`, `repo`, and a catchall `filePath`.  
   - Calls `service.get("/repos/owner/repo/contents/filePath")`.  
   - Returns the result.

2. **`createOrUpdateFile`**:  
   - Reads `owner`, `repo`, and `filePath`.  
   - Reads a JSON body with `message`, `content` (Base64-encoded), `branch`, and `sha` (if updating).  
   - Calls a **PUT** request to GitHub, returning `201` (created) or `200` (updated).

3. **`deleteFile`**:  
   - Query params: `message`, `sha`, optional `branch`.  
   - If `message` or `sha` is missing, we throw `400 BadRequest`.  
   - We pass those as query params to `/repos/owner/repo/contents/filePath?message=...&sha=...&branch=...`.  
   - `DELETE` returns `204` on success.

---

## 11. Usage

Once **built** and **run** (`swift build && swift run`), the app listens on **port 8080** by default. You can test these endpoints with `curl`, providing a **Bearer** token:

1. **Get File or Directory**  
   ```bash
   curl -X GET "http://localhost:8080/repos/apple/swift/contents/README.md" \
        -H "Authorization: Bearer YOUR_TOKEN"
   ```
   - Returns file content in JSON, or a list of files if `README.md` is actually a directory name.

2. **Create or Update File**  
   ```bash
   curl -X PUT "http://localhost:8080/repos/apple/swift/contents/newfile.txt" \
        -H "Authorization: Bearer YOUR_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
             "message": "Add a new file",
             "content": "SGVsbG8gV29ybGQh", 
             "branch": "main"
           }'
   ```
   - `content` is Base64-encoded file data.  
   - If the file doesn’t exist, GitHub creates it (`201`). If it exists and you include `"sha": "<file sha>"`, GitHub updates it (`200`).

3. **Delete File**  
   ```bash
   curl -X DELETE "http://localhost:8080/repos/apple/swift/contents/newfile.txt?message=Remove%20file&sha=abc123&branch=main" \
        -H "Authorization: Bearer YOUR_TOKEN"
   ```
   - Expects `204 No Content` if the file is successfully deleted.

---

## 12. Error Handling & Logging

- **Logging**: Each request logs as:
  ```
  [GitHubProxyService] PUT https://api.github.com/repos/apple/swift/contents/newfile.txt -> 201
  ```
- **GitHub Errors**:  
  - On `401`, `404`, `422`, etc., the code attempts to parse GitHub’s JSON error message.  
  - Vapor will return an appropriate HTTP code to the client.  
- **Bearer Token**:  
  - If missing or invalid, the request fails with `401`.

---

## 13. Production Considerations

1. **Bearer Token Validation**:  
   - Currently, `BearerAuthMiddleware` only checks if an `Authorization` header with “Bearer” is present. Add real checks for production (JWT validation, token store, etc.).

2. **Rate Limits**:  
   - For large file operations, you may hit GitHub rate limits quickly. Consider caching or rate-limiting your own usage.

3. **Branching**:  
   - When creating/updating/deleting a file, specifying `branch` is optional. If absent, GitHub modifies the default branch.

4. **Base64 Content**:  
   - GitHub expects the file’s binary content in Base64. Make sure the client properly encodes it.

5. **Subdirectories**:  
   - If you want to support subdirectories in `:path`, ensure the route captures them (e.g., using a “catchall” or URL-encoded path segments).

---

## Summary

The **GitHub Files Proxy** Vapor 4 application:

- **Implements** the **OpenAPI** specification for file content management:
  1. **Get** file or directory (`GET /repos/:owner/:repo/contents/:path`)  
  2. **Create/Update** file (`PUT /repos/:owner/:repo/contents/:path`)  
  3. **Delete** file (`DELETE /repos/:owner/:repo/contents/:path`)  

- **Requires** a Bearer token for all routes.  
- **Logs** each request and handles GitHub’s error responses.  
- **Returns** the appropriate GitHub status code (e.g. 200, 201, 204, 404).

This structure can be **extended** to handle further advanced logic (e.g., retrieving commits, pulling raw file data, etc.). Enjoy your new **GitHub repository content** proxy!