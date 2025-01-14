Below is a **single Swift script** that, when run (e.g. `swift MakeIssuesApp.swift`), **writes out** a complete Vapor 4 application named **`GitHubIssuesProxy`** to the disk. The generated code matches the **production-grade** example from our previous documentation, including `Package.swift`, the `App` and `Run` targets, controllers, services, middleware, etc.

# MakeIssuesApp.swift

> **How to use**  
> 1. Create a file named `MakeIssuesApp.swift` (or a name of your choosing) and paste the script below.  
> 2. (Optional) Run `chmod +x MakeIssuesApp.swift` to make it executable.  
> 3. Run it: `swift MakeIssuesApp.swift` (or `./MakeIssuesApp.swift`).  
> 4. This creates a folder **`GitHubIssuesProxy`** containing all the necessary files.  
> 5. `cd GitHubIssuesProxy && swift build && swift run` to start the server.

---

```swift
#!/usr/bin/env swift
import Foundation

/// A helper function to create a file at `path` with the given `content`.
/// Overwrites if it already exists, and creates directories if needed.
func createFile(at path: String, content: String) throws {
    let directory = (path as NSString).deletingLastPathComponent
    try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
    let url = URL(fileURLWithPath: path)
    try content.write(to: url, atomically: true, encoding: .utf8)
}

/// Our new project folder name
let projectName = "GitHubIssuesProxy"
/// Absolute path to where the folder will be created
let rootPath = FileManager.default.currentDirectoryPath + "/" + projectName

print("Creating project at \(rootPath)")

// 1) Package.swift
let packageSwift = #"""
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "GitHubIssuesProxy",
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

        // Optionally store the application globally
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
    // Customize server if needed:
    // app.http.server.configuration.port = 8080

    // Register the routes
    try routes(app)
}
"""#

// 4) routes.swift
let routesSwift = #"""
import Vapor

public func routes(_ app: Application) throws {
    let issueController = GitHubIssueController()

    // All routes are protected by BearerAuthMiddleware
    let protected = app.grouped(BearerAuthMiddleware())

    // 1) Create Issue (POST)
    protected.post("repos", ":owner", ":repo", "issues", use: issueController.createIssue)

    // 2) List Issues (GET)
    protected.get("repos", ":owner", ":repo", "issues", use: issueController.listIssues)

    // 3) Get Issue (GET)
    protected.get("repos", ":owner", ":repo", "issues", ":issue_number",
                  use: issueController.getIssue)

    // 4) Update Issue (PATCH)
    protected.patch("repos", ":owner", ":repo", "issues", ":issue_number",
                    use: issueController.updateIssue)

    // 5) Delete Issue (DELETE)
    protected.delete("repos", ":owner", ":repo", "issues", ":issue_number",
                     use: issueController.deleteIssue)
}
"""#

// 5) GlobalAppRef.swift
let globalAppRefSwift = #"""
import Vapor

class GlobalAppRef {
    static let shared = GlobalAppRef()
    var app: Application?

    private init() {}
}
"""#

// 6) BearerAuthMiddleware.swift
let bearerAuthMiddlewareSwift = #"""
import Vapor

struct BearerAuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let authHeader = request.headers[.authorization].first,
              authHeader.lowercased().hasPrefix("bearer ") else {
            throw Abort(.unauthorized, reason: "Missing or invalid Bearer token.")
        }
        return try await next.respond(to: request)
    }
}
"""#

// 7) GitHubProxyService.swift
let gitHubProxyServiceSwift = #"""
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
        // E.g. "https://api.github.com" or custom for GitHub Enterprise
        self.baseURL = Environment.get("GITHUB_API_BASE_URL") ?? "https://api.github.com"
        self.client = app.client
        self.logger = app.logger
    }

    // MARK: - GET
    func get(path: String, req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)
        var headers = buildHeaders(req: req)
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.get(uri, headers: headers)
        logger.info("[GitHubProxyService] GET \(uri) -> \(response.status.code)")
        try await handleErrorsIfNeeded(response: response)
        return response
    }

    // MARK: - POST
    func post(path: String, body: ByteBuffer?, req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)
        var headers = buildHeaders(req: req)
        headers.add(name: .contentType, value: "application/json")
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.post(uri, headers: headers) { outReq in
            if let safeBody = body {
                outReq.body = .init(buffer: safeBody)
            }
        }

        logger.info("[GitHubProxyService] POST \(uri) -> \(response.status.code)")
        try await handleErrorsIfNeeded(response: response)
        return response
    }

    // MARK: - PATCH
    func patch(path: String, body: ByteBuffer?, req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)
        var headers = buildHeaders(req: req)
        headers.add(name: .contentType, value: "application/json")
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.patch(uri, headers: headers) { outReq in
            if let safeBody = body {
                outReq.body = .init(buffer: safeBody)
            }
        }

        logger.info("[GitHubProxyService] PATCH \(uri) -> \(response.status.code)")
        try await handleErrorsIfNeeded(response: response)
        return response
    }

    // MARK: - DELETE
    func delete(path: String, req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)
        var headers = buildHeaders(req: req)
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.delete(uri, headers: headers)
        logger.info("[GitHubProxyService] DELETE \(uri) -> \(response.status.code)")
        try await handleErrorsIfNeeded(response: response)
        return response
    }

    // MARK: - Build headers from request
    private func buildHeaders(req: Request) -> HTTPHeaders {
        var headers = HTTPHeaders()
        if let authHeader = req.headers[.authorization].first {
            headers.add(name: .authorization, value: authHeader)
        }
        return headers
    }

    // MARK: - Handle potential errors from GitHub
    private func handleErrorsIfNeeded(response: ClientResponse) async throws {
        switch response.status {
        case .ok, .created, .accepted, .noContent:
            return
        case .unauthorized:
            let msg = try await parseError(response: response) ?? "Unauthorized request to GitHub."
            throw GitHubProxyError.unauthorized(msg)
        case .notFound:
            let msg = try await parseError(response: response) ?? "Resource not found on GitHub."
            throw GitHubProxyError.notFound(msg)
        case .unprocessableEntity:
            let msg = try await parseError(response: response) ?? "Validation failed."
            throw GitHubProxyError.validationFailed(msg)
        default:
            let msg = try await parseError(response: response) ?? "Unexpected error \(response.status.code)"
            throw GitHubProxyError.generalError(msg)
        }
    }

    private func parseError(response: ClientResponse) async throws -> String? {
        guard let data = response.body.data else {
            return nil
        }
        if let errorBody = try? JSONDecoder().decode(GitHubErrorResponse.self, from: data) {
            return errorBody.message
        }
        return nil
    }
}
"""#

// 8) GitHubIssueController.swift
let gitHubIssueControllerSwift = #"""
import Vapor

final class GitHubIssueController {
    private let service: GitHubProxyService

    init() {
        guard let app = GlobalAppRef.shared.app else {
            fatalError("GlobalAppRef.shared.app not set. Make sure it's assigned in main.swift.")
        }
        self.service = GitHubProxyService(app: app)
    }

    // MARK: - 1) Create Issue
    // POST /repos/{owner}/{repo}/issues
    func createIssue(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)

        let bodyBuffer = try await req.body.collect().map { $0 } ?? ByteBuffer()
        let path = "/repos/\(owner)/\(repo)/issues"

        let githubResponse = try await service.post(path: path, body: bodyBuffer, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // MARK: - 2) List Issues
    // GET /repos/{owner}/{repo}/issues
    func listIssues(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)

        let path = "/repos/\(owner)/\(repo)/issues"
        let githubResponse = try await service.get(path: path, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // MARK: - 3) Get Issue
    // GET /repos/{owner}/{repo}/issues/{issue_number}
    func getIssue(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let issueNumber = try req.parameters.require("issue_number", as: Int.self)

        let path = "/repos/\(owner)/\(repo)/issues/\(issueNumber)"
        let githubResponse = try await service.get(path: path, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // MARK: - 4) Update Issue
    // PATCH /repos/{owner}/{repo}/issues/{issue_number}
    func updateIssue(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let issueNumber = try req.parameters.require("issue_number", as: Int.self)

        let bodyBuffer = try await req.body.collect().map { $0 } ?? ByteBuffer()
        let path = "/repos/\(owner)/\(repo)/issues/\(issueNumber)"

        let githubResponse = try await service.patch(path: path, body: bodyBuffer, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // MARK: - 5) Delete Issue
    // DELETE /repos/{owner}/{repo}/issues/{issue_number}
    func deleteIssue(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let issueNumber = try req.parameters.require("issue_number", as: Int.self)

        let path = "/repos/\(owner)/\(repo)/issues/\(issueNumber)"
        let githubResponse = try await service.delete(path: path, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    private func formatProxyResponse(_ githubResponse: ClientResponse, _ req: Request) -> Response {
        return Response(
            status: githubResponse.status,
            version: req.version,
            headers: githubResponse.headers,
            body: githubResponse.body
        )
    }
}
"""#

// Create the directory structure and files
do {
    try createFile(at: rootPath + "/Package.swift", content: packageSwift)
    try createFile(at: rootPath + "/Sources/Run/main.swift", content: mainSwift)
    try createFile(at: rootPath + "/Sources/App/configure.swift", content: configureSwift)
    try createFile(at: rootPath + "/Sources/App/routes.swift", content: routesSwift)
    try createFile(at: rootPath + "/Sources/App/GlobalAppRef.swift", content: globalAppRefSwift)
    try createFile(at: rootPath + "/Sources/App/Middlewares/BearerAuthMiddleware.swift", content: bearerAuthMiddlewareSwift)
    try createFile(at: rootPath + "/Sources/App/Services/GitHubProxyService.swift", content: gitHubProxyServiceSwift)
    try createFile(at: rootPath + "/Sources/App/Controllers/GitHubIssueController.swift", content: gitHubIssueControllerSwift)

    print("✅ Successfully created project files in \(rootPath).")
    print("Next steps:")
    print("  1) cd \(projectName)")
    print("  2) swift build")
    print("  3) swift run")
    print("Your Vapor app will start on port 8080 by default.")
} catch {
    print("❌ Error writing files: \(error.localizedDescription)")
    exit(1)
}
```

---

### Summary

After running this script, you’ll have a **Vapor 4** application named **`GitHubIssuesProxy`** in the current directory. The application implements the **OpenAPI** spec for GitHub **Issues**:

- **Create** an issue (POST)  
- **List** issues (GET)  
- **Get** an issue (GET)  
- **Update** an issue (PATCH)  
- **Delete** an issue (DELETE)

All **secured** with **Bearer** authentication via `BearerAuthMiddleware`. Enjoy!