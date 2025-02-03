Below is **comprehensive, production-grade documentation** for a **GitHub Commits Proxy** Vapor 4 application. It includes **full code listings** (similar to previous examples) for each file you’d typically have in a Vapor project, explaining both **how** the code works and **why** it’s structured this way.

---

# GitHub Commits Proxy 

## 1. Project Structure

A typical directory layout for this Vapor 4 app might be:

```
GitHubCommitsProxy/
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
│   │       └── GitHubCommitController.swift
└── Tests
    └── AppTests
```

Below, you’ll find the **full source** for each file. This application implements the following OpenAPI-specified routes related to **Commits**:

1. **List Commits**: `GET /repos/{owner}/{repo}/commits`
2. **Get Commit**: `GET /repos/{owner}/{repo}/commits/{sha}`
3. **Compare Commits**: `GET /repos/{owner}/{repo}/compare/{base}...{head}`

All routes require a **Bearer** token in the `Authorization` header.

---

## 2. `Package.swift`

The Swift Package Manager manifest. Here we declare our dependencies, including **Vapor 4**.

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "GitHubCommitsProxy",
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

Key points:

- We rely on **Swift 5.7** and **macOS 12** or later.  
- We pull in Vapor from `"https://github.com/vapor/vapor.git", from: "4.74.0"`.  
- We define an **App** target for our code and a **Run** target for the executable.

---

## 3. `main.swift` (entry point)

Located in `Sources/Run/main.swift`. This is where Vapor starts the application. We set up logging, instantiate the `Application`, then run it.

```swift
import Vapor

@main
struct Main {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let app = Application(env)
        defer { app.shutdown() }

        // Store our application in a global reference for usage in controllers/services
        GlobalAppRef.shared.app = app

        // Configure routes, etc.
        try configure(app)

        // Run the application
        try app.run()
    }
}
```

**Explanation**:

- **`Environment.detect()`** picks up environment variables, command line arguments, etc.  
- **`LoggingSystem.bootstrap`** configures logs, e.g., for Vapor.  
- **`Application(env)`** instantiates Vapor’s app.  
- We store the `app` in a **global reference** so we can access it in our controllers if needed (optional pattern).

---

## 4. `configure.swift`

Located in `Sources/App/configure.swift`. Here we can customize the server’s hostname/port, register our routes, and perform other app-wide configurations.

```swift
import Vapor

public func configure(_ app: Application) throws {
    // Example: override the default hostname and port if desired
    // app.http.server.configuration.hostname = "0.0.0.0"
    // app.http.server.configuration.port = 8080

    // Register application routes
    try routes(app)
}
```

**Explanation**:

- You can uncomment or adjust the hostname/port in production (e.g., behind Docker or a load balancer).  
- We call `routes(app)` at the end to register our route handlers.

---

## 5. `routes.swift`

Located in `Sources/App/routes.swift`. This file wires up the commit-related endpoints to our **GitHubCommitController** methods, **protected** by a Bearer token.

```swift
import Vapor

public func routes(_ app: Application) throws {
    let commitController = GitHubCommitController()

    // Group routes under BearerAuthMiddleware so all require a Bearer token
    let protected = app.grouped(BearerAuthMiddleware())

    // 1) List Commits
    protected.get("repos", ":owner", ":repo", "commits",
                  use: commitController.listCommits)

    // 2) Get Commit
    protected.get("repos", ":owner", ":repo", "commits", ":sha",
                  use: commitController.getCommit)

    // 3) Compare Commits
    // e.g. GET /repos/owner/repo/compare/base...head
    protected.get("repos", ":owner", ":repo", "compare", ":base...:head",
                  use: commitController.compareCommits)
}
```

**Explanation**:

- We create an instance of `GitHubCommitController` (defined below).  
- We group the routes with `BearerAuthMiddleware`, so any request to these routes **must** have a valid Bearer token.  
- We define the paths:  
  - **`GET /repos/{owner}/{repo}/commits`** => `listCommits`  
  - **`GET /repos/{owner}/{repo}/commits/{sha}`** => `getCommit`  
  - **`GET /repos/{owner}/{repo}/compare/{base}...{head}`** => `compareCommits`

---

## 6. `GlobalAppRef.swift`

Located in `Sources/App/GlobalAppRef.swift`. This is a simple utility class to store a reference to the **Application** globally, if you prefer that pattern.

```swift
import Vapor

class GlobalAppRef {
    static let shared = GlobalAppRef()
    var app: Application?

    private init() {}
}
```

**Explanation**:  

- We do this to avoid passing `Application` around in initializers or using a more advanced DI approach.  
- In `main.swift`, we set `GlobalAppRef.shared.app = app`. Controllers or services can retrieve it from here.

---

## 7. `BearerAuthMiddleware.swift`

Located in `Sources/App/Middlewares/BearerAuthMiddleware.swift`. This minimal middleware checks for a **Bearer** token in the `Authorization` header.

```swift
import Vapor

struct BearerAuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let authHeader = request.headers[.authorization].first,
              authHeader.lowercased().hasPrefix("bearer ") else {
            throw Abort(.unauthorized, reason: "Missing or invalid Bearer token.")
        }
        // Optionally parse/validate the token
        // let token = String(authHeader.dropFirst("bearer ".count))

        return try await next.respond(to: request)
    }
}
```

**Explanation**:

- If `Authorization` is not present or not starting with `"Bearer "`, we throw `401 Unauthorized`.  
- In a real production system, you might parse a JWT or check the token against a database.

---

## 8. `GitHubProxyService.swift`

Located in `Sources/App/Services/GitHubProxyService.swift`. This service does **all** actual HTTP calls to GitHub, including error handling, logging, and forwarding the `Authorization` header. It handles **GET** requests for commits, as well as other methods you might add in the future.

```swift
import Vapor

enum GitHubProxyError: Error {
    case unauthorized(String)
    case notFound(String)
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
        // If you have a custom GitHub Enterprise URL, set this in env:
        // e.g. "https://github.my-company.com/api/v3"
        self.baseURL = Environment.get("GITHUB_API_BASE_URL") ?? "https://api.github.com"
        self.client = app.client
        self.logger = app.logger
    }

    // MARK: - GET request
    /// Executes a GET to the given path on GitHub, returning the raw `ClientResponse`.
    func get(path: String, queries: [(String, String?)]? = nil, req: Request) async throws -> ClientResponse {
        // Build the full URL
        var urlString = baseURL + path

        // If we have query parameters, let's add them
        if let queries = queries, !queries.isEmpty {
            // Example: &sha=main, &path=README.md, etc.
            let queryString = queries
                .compactMap { (key, value) -> String? in
                    guard let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                        return nil
                    }
                    guard let val = value, let encodedVal = val.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                        return "\(encodedKey)=" // if nil, pass empty or skip entirely
                    }
                    return "\(encodedKey)=\(encodedVal)"
                }
                .joined(separator: "&")
            if !queryString.isEmpty {
                urlString += "?\(queryString)"
            }
        }

        let uri = URI(string: urlString)

        // Prepare headers
        var headers = HTTPHeaders()
        if let authHeader = req.headers[.authorization].first {
            headers.add(name: .authorization, value: authHeader)
        }
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        // Perform the request
        let response = try await client.get(uri, headers: headers)
        logger.info("[GitHubProxyService] GET \(uri) -> \(response.status.code)")

        // Check for errors
        try await handleErrorsIfNeeded(response: response)
        return response
    }

    // MARK: - Common error handling
    private func handleErrorsIfNeeded(response: ClientResponse) async throws {
        switch response.status {
        case .ok, .created, .accepted, .noContent, .partialContent:
            // typical success codes
            return
        case .unauthorized:
            let message = try await parseError(response: response) ?? "Unauthorized request to GitHub."
            throw GitHubProxyError.unauthorized(message)
        case .notFound:
            let message = try await parseError(response: response) ?? "Resource not found on GitHub."
            throw GitHubProxyError.notFound(message)
        default:
            let message = try await parseError(response: response) ?? "Unexpected error \(response.status.code)"
            throw GitHubProxyError.generalError(message)
        }
    }

    private func parseError(response: ClientResponse) async throws -> String? {
        guard let data = response.body.data else {
            return nil
        }
        let decoder = JSONDecoder()
        if let errorBody = try? decoder.decode(GitHubErrorResponse.self, from: data) {
            return errorBody.message
        }
        // If parsing fails, just return nil
        return nil
    }
}
```

**Explanation**:

- `GitHubProxyService` is the core “proxy” logic.  
- We define an enum `GitHubProxyError` for typical error cases.  
- `get(path:queries:req:)` can accept optional query parameters (e.g. `sha=main`, `path=README.md`, etc.) and appends them to the URL.  
- We forward the `Authorization` header if present.  
- We handle standard GitHub error statuses (`401`, `404`, etc.), decoding the JSON error if available.  
- If a non-standard code appears, we throw a general error with the status code.

---

## 9. `GitHubCommitController.swift`

Located in `Sources/App/Controllers/GitHubCommitController.swift`. This controller wires the **OpenAPI** routes to the **GitHubProxyService**:

1. **List Commits**  
2. **Get Commit**  
3. **Compare Commits**

```swift
import Vapor

final class GitHubCommitController {
    private let service: GitHubProxyService

    init() {
        guard let app = GlobalAppRef.shared.app else {
            fatalError("GlobalAppRef.shared.app not set. Did you assign it in main.swift?")
        }
        self.service = GitHubProxyService(app: app)
    }

    // MARK: - 1) List Commits
    // GET /repos/{owner}/{repo}/commits?sha=xxx&path=xxx&author=xxx
    func listCommits(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)

        // Prepare optional query parameters
        let sha = req.query[String.self, at: "sha"]
        let path = req.query[String.self, at: "path"]
        let author = req.query[String.self, at: "author"]

        // Collect them in a form that GitHubProxyService can handle
        let queries: [(String, String?)] = [
            ("sha", sha),
            ("path", path),
            ("author", author)
        ]
        
        let githubPath = "/repos/\(owner)/\(repo)/commits"

        // Perform the GET request
        let githubResponse = try await service.get(
            path: githubPath,
            queries: queries,
            req: req
        )

        // Convert ClientResponse -> Vapor Response
        return formatProxyResponse(from: githubResponse, on: req)
    }

    // MARK: - 2) Get Commit
    // GET /repos/{owner}/{repo}/commits/{sha}
    func getCommit(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let sha = try req.parameters.require("sha", as: String.self)

        let githubPath = "/repos/\(owner)/\(repo)/commits/\(sha)"

        let githubResponse = try await service.get(
            path: githubPath,
            queries: nil,
            req: req
        )

        return formatProxyResponse(from: githubResponse, on: req)
    }

    // MARK: - 3) Compare Commits
    // GET /repos/{owner}/{repo}/compare/{base}...{head}
    func compareCommits(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        
        // Because the route path is "compare/:base...:head",
        // Vapor merges that into a single parameter named "base...head".
        // However, we can define two placeholders in routes.swift:
        // "compare", ":base...:head"
        // We'll parse them with a small trick:
        let baseAndHead = try req.parameters.require("base...head", as: String.self)
        
        // This should be something like "main...feature-branch"
        // We'll pass it directly to GitHub's compare endpoint
        let githubPath = "/repos/\(owner)/\(repo)/compare/\(baseAndHead)"

        let githubResponse = try await service.get(
            path: githubPath,
            queries: nil,
            req: req
        )

        return formatProxyResponse(from: githubResponse, on: req)
    }

    // MARK: - Helper to convert `ClientResponse` -> `Response`
    private func formatProxyResponse(from githubResponse: ClientResponse, on req: Request) -> Response {
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

1. **`listCommits`**:
   - Reads optional query params: `sha`, `path`, `author` from the request query.  
   - Calls `service.get` with those query parameters.  
   - Returns the proxied response.  

2. **`getCommit`**:
   - Reads `sha` from the route parameter.  
   - Performs a GET to `"/repos/owner/repo/commits/sha"`.  

3. **`compareCommits`**:
   - Reads the combined parameter `base...head` from the route.  
   - Calls `service.get` on `"/repos/owner/repo/compare/base...head"`.  

4. **`formatProxyResponse`** is a small helper to convert the raw `ClientResponse` from `NIO` to a Vapor `Response`.

---

## 10. Usage

After **building** and **running** (`swift build && swift run`), the app listens on **port 8080** by default. Test the routes:

1. **List Commits**:
   ```bash
   curl -X GET "http://localhost:8080/repos/apple/swift/commits?sha=main&author=apple" \
        -H "Authorization: Bearer YOUR_TOKEN"
   ```
   - This proxies a GET request to `GET https://api.github.com/repos/apple/swift/commits?sha=main&author=apple`, returning a list of commits filtered by author, branch, etc.

2. **Get Commit**:
   ```bash
   curl -X GET "http://localhost:8080/repos/apple/swift/commits/abcdef123456" \
        -H "Authorization: Bearer YOUR_TOKEN"
   ```
   - Returns commit details for `abcdef123456`.

3. **Compare Commits**:
   ```bash
   curl -X GET "http://localhost:8080/repos/apple/swift/compare/main...feature-branch" \
        -H "Authorization: Bearer YOUR_TOKEN"
   ```
   - Returns the comparison between `main` and `feature-branch`.

---

## 11. Error Handling & Logging

- **Logging**:  
  - The `GitHubProxyService` logs each request like:  
    ```
    [GitHubProxyService] GET https://api.github.com/repos/... -> 200
    ```
- **GitHub Errors**:
  - If GitHub replies with 401, 404, etc., the service decodes the JSON body into `GitHubErrorResponse` and throws an error with the message.  
  - Vapor automatically turns thrown errors into HTTP responses (e.g. 401, 404).  
- **Bearer Token**:
  - If the `Authorization` header is missing or not prefixed with `Bearer `, the app returns 401 immediately.

---

## 12. Production Considerations

1. **Bearer Token Validation**:  
   - Currently, we only check for the presence of “Bearer”. In a real system, parse the token or verify it is valid (JWT or otherwise).  

2. **CORS & TLS**:  
   - If you’re exposing this publically, configure CORS or HTTPS as needed.  

3. **Pagination**:  
   - GitHub commit lists are paginated. You can pass `?page=2&per_page=50` etc. in the same style as `sha`, `path`, `author`.  

4. **Environment**:  
   - On a real host (e.g., Docker), set `PORT` or `GITHUB_API_BASE_URL` if needed.  

---

## 13. Summary

This **GitHub Commits Proxy** Vapor 4 application:

1. **Implements** routes to **list commits**, **get commit details**, and **compare commits** (matching your OpenAPI specification).  
2. **Uses** a straightforward `GitHubProxyService` to manage all interactions with the GitHub API.  
3. **Secures** requests via `BearerAuthMiddleware`.  
4. **Logs** requests and handles GitHub’s error responses gracefully.

With this code, you can **extend** the proxy to handle more commit operations or additional GitHub endpoints. Just create new functions in `GitHubCommitController` (or additional controllers), wire them up in `routes.swift`, and call the appropriate method on `GitHubProxyService`. 

Enjoy your new **GitHub Commits Proxy**!