Below is a **single Swift script**—let’s call it **`MakeLabelsApp.swift`**—that, when run, **creates** a complete Vapor 4 application named **`GitHubLabelsProxy`** in your current directory. The generated code **matches** the production-grade example from our previous documentation (covering GitHub Labels full CRUD operations).

# MakeLabelsApp.swift

> **How to use**  
> 1. Create a file named `MakeLabelsApp.swift` (or use a name you like) and paste the script below.  
> 2. (Optional) Make it executable: `chmod +x MakeLabelsApp.swift`.  
> 3. Run it: `swift MakeLabelsApp.swift` (or `./MakeLabelsApp.swift`).  
> 4. It will create a **`GitHubLabelsProxy`** folder containing all the necessary files.  
> 5. `cd GitHubLabelsProxy && swift build && swift run` to start the Vapor app.

---

```swift
#!/usr/bin/env swift
import Foundation

/// A helper function to create a file at `path` with the given `content`.
/// Overwrites if it already exists. Creates intermediate directories if needed.
func createFile(at path: String, content: String) throws {
    let directory = (path as NSString).deletingLastPathComponent
    try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
    let url = URL(fileURLWithPath: path)
    try content.write(to: url, atomically: true, encoding: .utf8)
}

/// Project folder name
let projectName = "GitHubLabelsProxy"
/// Absolute path to the project location
let rootPath = FileManager.default.currentDirectoryPath + "/" + projectName

print("Creating project at \(rootPath)")

// 1) Package.swift
let packageSwift = #"""
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

        // Store the app globally if needed
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
    // For example, override server port:
    // app.http.server.configuration.port = 8080

    // Register routes
    try routes(app)
}
"""#

// 4) routes.swift
let routesSwift = #"""
import Vapor

public func routes(_ app: Application) throws {
    let labelController = GitHubLabelController()

    // Protect with BearerAuthMiddleware
    let protected = app.grouped(BearerAuthMiddleware())

    // 1) Create Label (POST)
    protected.post("repos", ":owner", ":repo", "labels",
                   use: labelController.createLabel)

    // 2) List Labels (GET)
    protected.get("repos", ":owner", ":repo", "labels",
                  use: labelController.listLabels)

    // 3) Get Label (GET)
    protected.get("repos", ":owner", ":repo", "labels", ":name",
                  use: labelController.getLabel)

    // 4) Update Label (PATCH)
    protected.patch("repos", ":owner", ":repo", "labels", ":name",
                    use: labelController.updateLabel)

    // 5) Delete Label (DELETE)
    protected.delete("repos", ":owner", ":repo", "labels", ":name",
                     use: labelController.deleteLabel)
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
        // For production, parse or validate the token here.

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
        // Possibly override via an env var, e.g. "https://github.myorg.com/api/v3"
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

    // Helper: forward the Bearer token
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
        if let errorResp = try? JSONDecoder().decode(GitHubErrorResponse.self, from: data) {
            return errorResp.message
        }
        return nil
    }
}
"""#

// 8) GitHubLabelController.swift
let gitHubLabelControllerSwift = #"""
import Vapor

final class GitHubLabelController {
    private let service: GitHubProxyService

    init() {
        guard let app = GlobalAppRef.shared.app else {
            fatalError("GlobalAppRef.shared.app not set in main.swift.")
        }
        self.service = GitHubProxyService(app: app)
    }

    // 1) Create a Label
    // POST /repos/{owner}/{repo}/labels
    func createLabel(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)

        // Collect JSON body for label creation
        let bodyBuffer = try await req.body.collect().map { $0 } ?? ByteBuffer()
        let path = "/repos/\(owner)/\(repo)/labels"

        let githubResponse = try await service.post(path: path, body: bodyBuffer, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // 2) List Labels
    // GET /repos/{owner}/{repo}/labels
    func listLabels(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)

        let path = "/repos/\(owner)/\(repo)/labels"
        let githubResponse = try await service.get(path: path, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // 3) Get a Label
    // GET /repos/{owner}/{repo}/labels/{name}
    func getLabel(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let name = try req.parameters.require("name", as: String.self)

        let path = "/repos/\(owner)/\(repo)/labels/\(name)"
        let githubResponse = try await service.get(path: path, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // 4) Update a Label
    // PATCH /repos/{owner}/{repo}/labels/{name}
    func updateLabel(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let name = try req.parameters.require("name", as: String.self)

        // new_name, color in JSON body
        let bodyBuffer = try await req.body.collect().map { $0 } ?? ByteBuffer()

        let path = "/repos/\(owner)/\(repo)/labels/\(name)"
        let githubResponse = try await service.patch(path: path, body: bodyBuffer, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // 5) Delete a Label
    // DELETE /repos/{owner}/{repo}/labels/{name}
    func deleteLabel(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let name = try req.parameters.require("name", as: String.self)

        let path = "/repos/\(owner)/\(repo)/labels/\(name)"
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

// Finally, create the folder structure and write files
do {
    try createFile(at: rootPath + "/Package.swift", content: packageSwift)
    try createFile(at: rootPath + "/Sources/Run/main.swift", content: mainSwift)
    try createFile(at: rootPath + "/Sources/App/configure.swift", content: configureSwift)
    try createFile(at: rootPath + "/Sources/App/routes.swift", content: routesSwift)
    try createFile(at: rootPath + "/Sources/App/GlobalAppRef.swift", content: globalAppRefSwift)
    try createFile(at: rootPath + "/Sources/App/Middlewares/BearerAuthMiddleware.swift", content: bearerAuthMiddlewareSwift)
    try createFile(at: rootPath + "/Sources/App/Services/GitHubProxyService.swift", content: gitHubProxyServiceSwift)
    try createFile(at: rootPath + "/Sources/App/Controllers/GitHubLabelController.swift", content: gitHubLabelControllerSwift)

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

Running this script generates a **Vapor 4** application named **`GitHubLabelsProxy`** that:

- **Proxies** GitHub Label operations (Create, List, Get, Update, Delete).  
- **Requires** a Bearer token (`Authorization: Bearer ...`).  
- **Logs** requests and handles GitHub errors.

Just `cd GitHubLabelsProxy && swift build && swift run` to get started. Enjoy!