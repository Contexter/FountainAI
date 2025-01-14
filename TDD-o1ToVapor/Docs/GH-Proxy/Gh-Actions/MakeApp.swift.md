# MakeApp.swift

Below is a **single Swift script** that, when run (e.g. `swift MakeApp.swift`), **writes out** a complete Vapor 4 application—matching the production-grade code previously provided—onto disk. This script creates the necessary directory structure, writes each file (including `Package.swift` and all relevant Swift files), and sets you up to `swift build` and run the app.

> **How to use**  
> 1. Create a file named `MakeApp.swift` (or any name you prefer) and paste the script below.  
> 2. Run `chmod +x MakeApp.swift` to make it executable (optional).  
> 3. Run `swift MakeApp.swift` (or `./MakeApp.swift` after `chmod +x`) to generate the project folder, `GitHubActionsProxy`.  
> 4. `cd GitHubActionsProxy` and run `swift build`, then `swift run` to launch the Vapor server.

---

```swift
#!/usr/bin/env swift
import Foundation

/// Convenience function to create a file at `path` with the given `content`.
/// Overwrites if it already exists.
func createFile(at path: String, content: String) throws {
    let directory = (path as NSString).deletingLastPathComponent
    try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
    let url = URL(fileURLWithPath: path)
    try content.write(to: url, atomically: true, encoding: .utf8)
}

/// The root directory of our new project
let projectName = "GitHubActionsProxy"
let rootPath = FileManager.default.currentDirectoryPath + "/" + projectName

print("Creating project at \(rootPath)")

// 1) Package.swift
let packageSwift = #"""
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
"""#

// 2) main.swift
let mainSwift = #"""
import Vapor

@main
struct Main {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let app = Application(env)
        defer { app.shutdown() }

        // Store in a global reference if needed by controllers
        GlobalAppRef.shared.app = app

        try configure(app)
        try app.run()
    }
}
"""#

// 3) configure.swift
let configureSwift = #"""
import Vapor

public func configure(_ app: Application) throws {
    // Example: Customize server config
    // app.http.server.configuration.hostname = "0.0.0.0"
    // app.http.server.configuration.port = 8080

    // Register the routes
    try routes(app)
}
"""#

// 4) routes.swift
let routesSwift = #"""
import Vapor

public func routes(_ app: Application) throws {
    let gitHubActionsController = GitHubActionsController()
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
"""#

// 5) BearerAuthMiddleware.swift
let bearerMiddlewareSwift = #"""
import Vapor

struct BearerAuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let authHeader = request.headers[.authorization].first,
              authHeader.lowercased().starts(with: "bearer ") else {
            throw Abort(.unauthorized, reason: "Missing or invalid Bearer token.")
        }
        return try await next.respond(to: request)
    }
}
"""#

// 6) GitHubProxyService.swift
let gitHubProxyServiceSwift = #"""
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
        self.baseURL = Environment.get("GITHUB_API_BASE_URL") ?? "https://api.github.com"
        self.client = app.client
        self.logger = app.logger
    }

    func get(path: String, on req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)
        var headers = HTTPHeaders()
        if let authorizationHeader = req.headers[.authorization].first {
            headers.add(name: .authorization, value: authorizationHeader)
        }
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.get(uri, headers: headers)
        logger.info("[GitHubProxyService] GET \(uri) -> status: \(response.status.code)")

        try await handleErrorsIfNeeded(response: response)
        return response
    }

    private func handleErrorsIfNeeded(response: ClientResponse) async throws {
        switch response.status {
        case .ok, .created, .accepted, .partialContent:
            // successful response
            return
        case .unauthorized:
            if let errorData = response.body.data,
               let gitHubError = try? JSONDecoder().decode(GitHubErrorResponse.self, from: errorData) {
                throw GitHubProxyError.unauthorized(gitHubError.message)
            }
            throw GitHubProxyError.unauthorized("Unauthorized request to GitHub.")
        case .notFound:
            if let errorData = response.body.data,
               let gitHubError = try? JSONDecoder().decode(GitHubErrorResponse.self, from: errorData) {
                throw GitHubProxyError.notFound(gitHubError.message)
            }
            throw GitHubProxyError.notFound("Resource not found on GitHub.")
        default:
            if let errorData = response.body.data,
               let gitHubError = try? JSONDecoder().decode(GitHubErrorResponse.self, from: errorData) {
                throw GitHubProxyError.generalError(gitHubError.message)
            }
            throw GitHubProxyError.generalError("Unexpected error \(response.status.code)")
        }
    }
}
"""#

// 7) GitHubActionsController.swift
let gitHubActionsControllerSwift = #"""
import Vapor

final class GitHubActionsController {
    private let service: GitHubProxyService

    init() {
        guard let app = GlobalAppRef.shared.app else {
            fatalError("GlobalAppRef.shared.app not set. Make sure it's assigned in main.swift.")
        }
        self.service = GitHubProxyService(app: app)
    }

    // 1) List Workflows
    func listWorkflows(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let path = "/repos/\(owner)/\(repo)/actions/workflows"
        return try await proxy(path: path, req: req)
    }

    // 2) Get Workflow
    func getWorkflow(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let workflowID = try req.parameters.require("workflow_id", as: Int.self)
        let path = "/repos/\(owner)/\(repo)/actions/workflows/\(workflowID)"
        return try await proxy(path: path, req: req)
    }

    // 3) List Workflow Runs
    func listWorkflowRuns(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let path = "/repos/\(owner)/\(repo)/actions/runs"
        return try await proxy(path: path, req: req)
    }

    // 4) Get Workflow Run
    func getWorkflowRun(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let runID = try req.parameters.require("run_id", as: Int.self)
        let path = "/repos/\(owner)/\(repo)/actions/runs/\(runID)"
        return try await proxy(path: path, req: req)
    }

    // 5) Download Workflow Logs
    func downloadWorkflowLogs(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let runID = try req.parameters.require("run_id", as: Int.self)
        let path = "/repos/\(owner)/\(repo)/actions/runs/\(runID)/logs"
        return try await proxy(path: path, req: req)
    }

    // Helper for proxying GET requests to GitHub
    private func proxy(path: String, req: Request) async throws -> Response {
        let githubResponse = try await service.get(path: path, on: req)
        return Response(status: githubResponse.status,
                        version: req.version,
                        headers: githubResponse.headers,
                        body: githubResponse.body)
    }
}
"""#

// 8) GlobalAppRef.swift (optional pattern for storing app reference)
let globalAppRefSwift = #"""
import Vapor

class GlobalAppRef {
    static let shared = GlobalAppRef()
    var app: Application?

    private init() {}
}
"""#

// Write them all out
do {
    try createFile(at: rootPath + "/Package.swift", content: packageSwift)
    try createFile(at: rootPath + "/Sources/Run/main.swift", content: mainSwift)
    try createFile(at: rootPath + "/Sources/App/configure.swift", content: configureSwift)
    try createFile(at: rootPath + "/Sources/App/routes.swift", content: routesSwift)
    try createFile(at: rootPath + "/Sources/App/Middlewares/BearerAuthMiddleware.swift", content: bearerMiddlewareSwift)
    try createFile(at: rootPath + "/Sources/App/Services/GitHubProxyService.swift", content: gitHubProxyServiceSwift)
    try createFile(at: rootPath + "/Sources/App/Controllers/GitHubActionsController.swift", content: gitHubActionsControllerSwift)
    try createFile(at: rootPath + "/Sources/App/GlobalAppRef.swift", content: globalAppRefSwift)

    print("✅ Project files successfully created in \(rootPath).")
    print("Next steps:")
    print("  1) cd \(projectName)")
    print("  2) swift build")
    print("  3) swift run")
    print("Enjoy your new Vapor application!")
} catch {
    print("❌ Error writing files: \(error.localizedDescription)")
    exit(1)
}
```

---

### What this script does

1. **Creates** a folder named **`GitHubActionsProxy`** in the current working directory.  
2. **Creates** subfolders like `Sources/Run`, `Sources/App/Controllers`, `Sources/App/Services`, `Sources/App/Middlewares`, etc.  
3. **Writes** each Swift file exactly as shown above.  
4. **Outputs** usage instructions.

### After Running

- You’ll have a **Vapor 4** project with the code from our production-ready GitHub Actions proxy example.  
- Change into `GitHubActionsProxy` and do a standard Vapor build:  
  ```bash
  cd GitHubActionsProxy
  swift build
  swift run
  ```  
- The application should start up, listening on the default port (8080). Then you can test the routes like:
  - `GET /repos/ownerName/repoName/actions/workflows`  
  - etc.  

Feel free to modify environment variables (e.g. `GITHUB_API_BASE_URL`) or the Bearer auth logic to suit your needs.