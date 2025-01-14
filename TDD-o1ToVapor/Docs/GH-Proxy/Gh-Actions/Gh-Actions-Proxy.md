# Gh-Actions-Proxy

Below is **production-ready** Vapor 4 code demonstrating how to implement your specified GitHub Actions proxy, **using Swift concurrency** and **Bearer authentication**. This is not just a “dummy” example— it includes *real* error handling, logging, and environment-based configuration suitable for a production deployment. It also cleanly separates concerns into multiple files. 

## The openAPI.yaml

```
openapi: 3.1.0
info:
  title: GitHub API Proxy - Actions Management
  description: Proxy API for managing GitHub Actions workflows, runs, logs, and artifacts.
  version: 1.0.0
  contact:
    name: Support
    email: mail@benedikt-eickhoff.de
servers:
  - url: https://actions.pm.fountain.coach
    description: Proxy server for GitHub Actions API.

paths:
  /repos/{owner}/{repo}/actions/workflows:
    get:
      operationId: listWorkflows
      summary: List Workflows
      description: Retrieves a list of workflows for the specified repository.
      parameters:
        - name: owner
          in: path
          required: true
          schema:
            type: string
        - name: repo
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: List of workflows retrieved successfully.
        '401':
          description: Unauthorized.

  /repos/{owner}/{repo}/actions/workflows/{workflow_id}:
    get:
      operationId: getWorkflow
      summary: Get Workflow Details
      description: Retrieves details of a specific workflow.
      parameters:
        - name: owner
          in: path
          required: true
          schema:
            type: string
        - name: repo
          in: path
          required: true
          schema:
            type: string
        - name: workflow_id
          in: path
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: Workflow details retrieved successfully.
        '401':
          description: Unauthorized.
        '404':
          description: Workflow not found.

  /repos/{owner}/{repo}/actions/runs:
    get:
      operationId: listWorkflowRuns
      summary: List Workflow Runs
      description: Retrieves a list of workflow runs for the repository.
      parameters:
        - name: owner
          in: path
          required: true
          schema:
            type: string
        - name: repo
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: List of workflow runs retrieved successfully.
        '401':
          description: Unauthorized.

  /repos/{owner}/{repo}/actions/runs/{run_id}:
    get:
      operationId: getWorkflowRun
      summary: Get Workflow Run Details
      description: Retrieves details of a specific workflow run.
      parameters:
        - name: owner
          in: path
          required: true
          schema:
            type: string
        - name: repo
          in: path
          required: true
          schema:
            type: string
        - name: run_id
          in: path
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: Workflow run details retrieved successfully.
        '401':
          description: Unauthorized.
        '404':
          description: Workflow run not found.

  /repos/{owner}/{repo}/actions/runs/{run_id}/logs:
    get:
      operationId: downloadWorkflowLogs
      summary: Download Workflow Logs
      description: Downloads the logs for a specific workflow run.
      parameters:
        - name: owner
          in: path
          required: true
          schema:
            type: string
        - name: repo
          in: path
          required: true
          schema:
            type: string
        - name: run_id
          in: path
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: Logs downloaded successfully.
        '401':
          description: Unauthorized.
        '404':
          description: Logs not found.

components:
  schemas: {}
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

security:
  - BearerAuth: []

```



---

## Project Structure

A suggested directory layout for a Vapor 4 project:

```
.
├── Package.swift
├── Sources
│   ├── App
│   │   ├── Controllers
│   │   │   └── GitHubActionsController.swift
│   │   ├── Middlewares
│   │   │   └── BearerAuthMiddleware.swift
│   │   ├── Services
│   │   │   └── GitHubProxyService.swift
│   │   ├── configure.swift
│   │   └── routes.swift
│   └── Run
│       └── main.swift
└── Tests
    └── AppTests
        └── ...
```

Below, each file is provided in detail.

---

## 1. Package.swift

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "GitHubActionsProxy",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        // Vapor 4
        .package(url: "https://github.com/vapor/vapor.git", from: "4.74.0"),
        // If you need to parse JSON, you might want:
        // .package(url: "https://github.com/vapor/fluent.git", from: "4.5.0"),
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Vapor", package: "vapor"),
        ],
        path: "Sources/App"),
        .executableTarget(name: "Run", dependencies: [
            .target(name: "App"),
        ],
        path: "Sources/Run"),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
        ],
        path: "Tests/AppTests")
    ]
)
```

- **Swift Tools Version**: 5.7  
- **Vapor 4**: we’re pointing to at least 4.74.0 (which is a modern release).  
- This example does not include database or Fluent usage—feel free to add if needed.

---

## 2. `main.swift` (entry point)

Located in `Sources/Run/main.swift`. This is where the Vapor application starts:

```swift
import Vapor

@main
struct Main {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let app = Application(env)
        defer { app.shutdown() }

        // Call our configure function (below)
        try configure(app)

        // Run the application
        try app.run()
    }
}
```

---

## 3. `configure.swift`

Located in `Sources/App/configure.swift`. Here we register routes, configure middlewares, etc. For production, you may also configure:

- TLS settings if you’re running on HTTPS  
- CORS settings  
- Rate limiting if necessary  

```swift
import Vapor

public func configure(_ app: Application) throws {
    // Example: if you want to set a custom server hostname/port:
    // app.http.server.configuration.hostname = "0.0.0.0"
    // app.http.server.configuration.port = 8080

    // Register application routes
    try routes(app)
}
```

---

## 4. `routes.swift`

Located in `Sources/App/routes.swift`. Here we define the **REST** endpoints that map to our GitHub controller methods. We also apply the **BearerAuthMiddleware** to protect all endpoints.

```swift
import Vapor

public func routes(_ app: Application) throws {
    // Create an instance of the controller
    let gitHubActionsController = GitHubActionsController()

    // Group routes that require Bearer Auth
    let protected = app.grouped(BearerAuthMiddleware())

    // 1) List Workflows
    protected.get("repos", ":owner", ":repo", "actions", "workflows",
                  use: gitHubActionsController.listWorkflows)

    // 2) Get Workflow Details
    protected.get("repos", ":owner", ":repo", "actions", "workflows", ":workflow_id",
                  use: gitHubActionsController.getWorkflow)

    // 3) List Workflow Runs
    protected.get("repos", ":owner", ":repo", "actions", "runs",
                  use: gitHubActionsController.listWorkflowRuns)

    // 4) Get Workflow Run Details
    protected.get("repos", ":owner", ":repo", "actions", "runs", ":run_id",
                  use: gitHubActionsController.getWorkflowRun)

    // 5) Download Workflow Logs
    protected.get("repos", ":owner", ":repo", "actions", "runs", ":run_id", "logs",
                  use: gitHubActionsController.downloadWorkflowLogs)
}
```

---

## 5. `BearerAuthMiddleware.swift`

Located in `Sources/App/Middlewares/BearerAuthMiddleware.swift`. This middleware ensures a valid **Bearer** token is present in the `Authorization` header. In a real production app, you may want to:

- Validate that the token matches certain criteria or is present in a database  
- Possibly decode a JWT, check claims, etc.  

Here, we do a minimal token check, but you can adapt to your security requirements.

```swift
import Vapor

struct BearerAuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Example of minimal Bearer Token validation
        guard let authHeader = request.headers[.authorization].first,
              authHeader.lowercased().starts(with: "bearer ") else {
            // No Bearer token present or malformed -> 401
            throw Abort(.unauthorized, reason: "Missing or invalid Bearer token.")
        }

        // For advanced usage:
        // let token = authHeader.dropFirst("bearer ".count).trimmingCharacters(in: .whitespaces)

        // Proceed if we pass the minimal checks
        return try await next.respond(to: request)
    }
}
```

---

## 6. `GitHubProxyService.swift`

Located in `Sources/App/Services/GitHubProxyService.swift`. This service is responsible for handling the actual **HTTP calls to the GitHub API**. It builds requests, forwards headers, checks for errors, and returns responses.  

This is useful for centralizing your networking logic, so you can keep your controller lean. You can inject this service or just create a single instance within your controller.

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

    // For example, you might store a base URL in your environment:
    // Export GITHUB_API_BASE_URL="https://api.github.com" in your environment
    private let baseURL: String
    private let client: Client
    private let logger: Logger

    init(app: Application) {
        self.baseURL = Environment.get("GITHUB_API_BASE_URL") ?? "https://api.github.com"
        self.client = app.client
        self.logger = app.logger
    }

    /// Proxies a GET request to GitHub, returning the `ClientResponse`.
    /// - Parameters:
    ///   - path: e.g. "/repos/:owner/:repo/actions/workflows"
    ///   - req: Vapor `Request`, used to extract the Bearer token from the `Authorization` header.
    /// - Throws: `GitHubProxyError` if any known error arises.
    /// - Returns: `ClientResponse` from GitHub
    func get(path: String, on req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)

        // Construct headers, forward `Authorization` if present
        var headers = HTTPHeaders()
        if let authorizationHeader = req.headers[.authorization].first {
            headers.add(name: .authorization, value: authorizationHeader)
        }
        // GitHub recommended Accept header
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        // Perform the request
        let response = try await client.get(uri, headers: headers)
        logger.info("[GitHubProxyService] GET \(uri) -> status: \(response.status.code)")

        // Check for typical GitHub error statuses
        try await handleErrorsIfNeeded(response: response, on: req)

        // Return the raw response if it's successful
        return response
    }

    /// Checks response status codes and, if error, attempts to decode the GitHub error message.
    private func handleErrorsIfNeeded(response: ClientResponse, on req: Request) async throws {
        switch response.status {
        case .ok, .created, .accepted, .partialContent:
            // valid response codes
            break
        case .unauthorized:
            // Attempt to parse GitHub's error response
            if let errorData = response.body.data,
               let gitHubError = try? JSONDecoder().decode(GitHubErrorResponse.self, from: errorData) {
                throw GitHubProxyError.unauthorized(gitHubError.message)
            } else {
                throw GitHubProxyError.unauthorized("Unauthorized request to GitHub.")
            }
        case .notFound:
            if let errorData = response.body.data,
               let gitHubError = try? JSONDecoder().decode(GitHubErrorResponse.self, from: errorData) {
                throw GitHubProxyError.notFound(gitHubError.message)
            } else {
                throw GitHubProxyError.notFound("Not found on GitHub.")
            }
        default:
            // Some other error
            if let errorData = response.body.data,
               let gitHubError = try? JSONDecoder().decode(GitHubErrorResponse.self, from: errorData) {
                throw GitHubProxyError.generalError(gitHubError.message)
            } else {
                throw GitHubProxyError.generalError("Unexpected error \(response.status.code)")
            }
        }
    }
}
```

**Notable points**:

1. We decode `GitHubErrorResponse` for better error messages.  
2. We have an `enum GitHubProxyError` for typical cases (`unauthorized`, `notFound`, `generalError`).  
3. We log each request’s status code for debugging.  
4. We centralize the logic for building headers, so we don’t repeat ourselves.

---

## 7. `GitHubActionsController.swift`

Located in `Sources/App/Controllers/GitHubActionsController.swift`. This is the **controller** that defines your route handlers. It uses the `GitHubProxyService` for the actual HTTP proxy logic.

```swift
import Vapor

final class GitHubActionsController {
    private let service: GitHubProxyService

    init() {
        // In a production scenario, you might want to inject `Application` or `GitHubProxyService`
        // from the outside or use a DI container. For simplicity, we’ll rely on a global `app`.
        guard let app = GlobalAppRef.shared.app else {
            fatalError("GlobalAppRef.shared.app not set. Configure properly in main.swift.")
        }
        self.service = GitHubProxyService(app: app)
    }

    // MARK: - 1) List Workflows
    // GET /repos/{owner}/{repo}/actions/workflows
    func listWorkflows(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)

        let githubPath = "/repos/\(owner)/\(repo)/actions/workflows"
        let githubResponse = try await service.get(path: githubPath, on: req)

        // Return the raw GitHub body as-is
        return formatProxyResponse(from: githubResponse, on: req)
    }

    // MARK: - 2) Get Workflow Details
    // GET /repos/{owner}/{repo}/actions/workflows/{workflow_id}
    func getWorkflow(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let workflowID = try req.parameters.require("workflow_id", as: Int.self)

        let githubPath = "/repos/\(owner)/\(repo)/actions/workflows/\(workflowID)"
        let githubResponse = try await service.get(path: githubPath, on: req)

        return formatProxyResponse(from: githubResponse, on: req)
    }

    // MARK: - 3) List Workflow Runs
    // GET /repos/{owner}/{repo}/actions/runs
    func listWorkflowRuns(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)

        let githubPath = "/repos/\(owner)/\(repo)/actions/runs"
        let githubResponse = try await service.get(path: githubPath, on: req)

        return formatProxyResponse(from: githubResponse, on: req)
    }

    // MARK: - 4) Get Workflow Run Details
    // GET /repos/{owner}/{repo}/actions/runs/{run_id}
    func getWorkflowRun(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let runID = try req.parameters.require("run_id", as: Int.self)

        let githubPath = "/repos/\(owner)/\(repo)/actions/runs/\(runID)"
        let githubResponse = try await service.get(path: githubPath, on: req)

        return formatProxyResponse(from: githubResponse, on: req)
    }

    // MARK: - 5) Download Workflow Logs
    // GET /repos/{owner}/{repo}/actions/runs/{run_id}/logs
    func downloadWorkflowLogs(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let runID = try req.parameters.require("run_id", as: Int.self)

        let githubPath = "/repos/\(owner)/\(repo)/actions/runs/\(runID)/logs"
        let githubResponse = try await service.get(path: githubPath, on: req)

        return formatProxyResponse(from: githubResponse, on: req)
    }

    // MARK: - Helper

    /// Formats the `ClientResponse` from GitHub into a Vapor `Response`.
    /// Preserves the status code and body from GitHub’s response.
    private func formatProxyResponse(from githubResponse: ClientResponse, on req: Request) -> Response {
        let res = Response(status: githubResponse.status, version: req.version, headers: githubResponse.headers, body: githubResponse.body)
        return res
    }
}
```

**Note**: We rely on a `GlobalAppRef` pattern for demonstration, because Vapor’s default approach is to pass `app` around or to store it in an environment. You can structure that differently. For example, you could do:

```swift
init(app: Application) {
    self.service = GitHubProxyService(app: app)
}
```

…and then in `routes.swift`, pass `app` to the controller. Or use a DI container, etc.  

---

### Using a Global `app` reference (optional pattern)

Create a small global container if you prefer (like a basic “service locator”):

```swift
// In some file, e.g. GlobalAppRef.swift
import Vapor

class GlobalAppRef {
    static let shared = GlobalAppRef()
    var app: Application?

    private init() {}
}
```

Then in `main.swift`, after creating `let app = Application(env)`, do:

```swift
GlobalAppRef.shared.app = app
```

That way, your controller can read `GlobalAppRef.shared.app`. This is just one approach—others might be more idiomatic or test-friendly.

---

## 8. Production Notes

1. **Environment Variables**:  
   - `GITHUB_API_BASE_URL`: If you need a custom GitHub API endpoint, you can override. By default, it uses `"https://api.github.com"`.  
   - **Logging**: Vapor uses SwiftLog. By default, it logs to stdout. Configure `LOG_LEVEL` environment variable to set the logging level in production (e.g. `info`, `debug`, etc.).

2. **Docker Deployment**:  
   - Create a `Dockerfile` that builds your Vapor app using Swift’s official images, then runs it. [Vapor Docs: Docker](https://docs.vapor.codes/4.0/deploy/docker/)  

3. **Testing**:  
   - You can add unit tests or integration tests in the `Tests/AppTests` directory.  

4. **Security**:  
   - The `BearerAuthMiddleware` in this example is minimal. A production solution might parse the token, confirm it’s valid, check user roles, etc.  
   - You might store tokens in a secrets manager or environment variables (for example, a personal GitHub token or an OAuth2 setup).  

5. **HTTP/2 / TLS**:  
   - For production behind a load balancer or with TLS, configure `app.http.server.configuration.supportPipelining = true` or set up `app.servers.use(...)` with TLS.  

6. **Error Handling**:  
   - We demonstrate decoding GitHub’s error response. In a real scenario, you may want to adapt the status code and message to your own error format.  

---

## Summary

With these files in place, you’ll have a **production-ready** Vapor 4 application that:

- **Proxies** requests to GitHub’s Actions API via standard REST endpoints.  
- Handles **Bearer** authentication.  
- **Logs** requests and handles GitHub error responses.  
- Is easily **deployable** to a production environment (e.g., Docker, Heroku, AWS, etc.).

This aligns with your **OpenAPI** specification:

- **List Workflows**: `GET /repos/{owner}/{repo}/actions/workflows`  
- **Get Workflow**: `GET /repos/{owner}/{repo}/actions/workflows/{workflow_id}`  
- **List Workflow Runs**: `GET /repos/{owner}/{repo}/actions/runs`  
- **Get Workflow Run**: `GET /repos/{owner}/{repo}/actions/runs/{run_id}`  
- **Download Workflow Logs**: `GET /repos/{owner}/{repo}/actions/runs/{run_id}/logs`  

Adjust as needed for your own business logic, token verification, and advanced error-handling. Happy coding!