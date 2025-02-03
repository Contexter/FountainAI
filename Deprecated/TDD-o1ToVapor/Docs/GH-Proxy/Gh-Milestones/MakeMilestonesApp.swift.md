Below is a **single Swift script**—we’ll call it **`MakeMilestonesApp.swift`**—that, when executed, **creates** a Vapor 4 project named **`GitHubMilestonesProxy`** on disk. The generated code matches the *production-grade* app outlined in the documentation for **GitHub Milestones**.

# MakeMilestonesApp.swift

> **How to use**  
> 1. Create a file named `MakeMilestonesApp.swift` (or a name you prefer) and paste the code below.  
> 2. (Optional) Make it executable: `chmod +x MakeMilestonesApp.swift`.  
> 3. Run it: `swift MakeMilestonesApp.swift` (or `./MakeMilestonesApp.swift`).  
> 4. It will create a folder **`GitHubMilestonesProxy`** containing all the necessary Vapor files.  
> 5. `cd GitHubMilestonesProxy` -> `swift build` -> `swift run` to start the server.

---

```swift
#!/usr/bin/env swift
import Foundation

/// A helper function that creates a file at `path` with the given `content`.
/// If the directory structure doesn't exist, this will create it. It overwrites if the file exists.
func createFile(at path: String, content: String) throws {
    let directory = (path as NSString).deletingLastPathComponent
    try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
    let url = URL(fileURLWithPath: path)
    try content.write(to: url, atomically: true, encoding: .utf8)
}

/// The name of our new Vapor project
let projectName = "GitHubMilestonesProxy"
/// Absolute path to where the project will be created
let rootPath = FileManager.default.currentDirectoryPath + "/" + projectName

print("Creating project at \(rootPath)")

// 1) Package.swift
let packageSwift = #"""
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "GitHubMilestonesProxy",
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

        // Store the application globally if needed
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
    // e.g. app.http.server.configuration.port = 8080
    try routes(app)
}
"""#

// 4) routes.swift
let routesSwift = #"""
import Vapor

public func routes(_ app: Application) throws {
    let milestoneController = GitHubMilestoneController()

    // Group everything behind BearerAuthMiddleware
    let protected = app.grouped(BearerAuthMiddleware())

    // 1) Create Milestone (POST)
    protected.post("repos", ":owner", ":repo", "milestones",
                   use: milestoneController.createMilestone)

    // 2) List Milestones (GET)
    protected.get("repos", ":owner", ":repo", "milestones",
                  use: milestoneController.listMilestones)

    // 3) Get Milestone (GET)
    protected.get("repos", ":owner", ":repo", "milestones", ":milestone_number",
                  use: milestoneController.getMilestone)

    // 4) Update Milestone (PATCH)
    protected.patch("repos", ":owner", ":repo", "milestones", ":milestone_number",
                    use: milestoneController.updateMilestone)

    // 5) Delete Milestone (DELETE)
    protected.delete("repos", ":owner", ":repo", "milestones", ":milestone_number",
                     use: milestoneController.deleteMilestone)
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
        // In production, parse/verify the token here.
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
        // e.g. set via env var GITHUB_API_BASE_URL, else default to public GitHub
        self.baseURL = Environment.get("GITHUB_API_BASE_URL") ?? "https://api.github.com"
        self.client = app.client
        self.logger = app.logger
    }

    // GET
    func get(path: String, req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)
        var headers = buildHeaders(req: req)
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.get(uri, headers: headers)
        logger.info("[GitHubProxyService] GET \(uri) -> \(response.status.code)")
        try await handleErrorsIfNeeded(response)
        return response
    }

    // POST
    func post(path: String, body: ByteBuffer?, req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)
        var headers = buildHeaders(req: req)
        headers.add(name: .contentType, value: "application/json")
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.post(uri, headers: headers) { outReq in
            if let buffer = body {
                outReq.body = .init(buffer: buffer)
            }
        }
        logger.info("[GitHubProxyService] POST \(uri) -> \(response.status.code)")
        try await handleErrorsIfNeeded(response)
        return response
    }

    // PATCH
    func patch(path: String, body: ByteBuffer?, req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)
        var headers = buildHeaders(req: req)
        headers.add(name: .contentType, value: "application/json")
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.patch(uri, headers: headers) { outReq in
            if let buffer = body {
                outReq.body = .init(buffer: buffer)
            }
        }
        logger.info("[GitHubProxyService] PATCH \(uri) -> \(response.status.code)")
        try await handleErrorsIfNeeded(response)
        return response
    }

    // DELETE
    func delete(path: String, req: Request) async throws -> ClientResponse {
        let uri = URI(string: baseURL + path)
        var headers = buildHeaders(req: req)
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.delete(uri, headers: headers)
        logger.info("[GitHubProxyService] DELETE \(uri) -> \(response.status.code)")
        try await handleErrorsIfNeeded(response)
        return response
    }

    // Forward Bearer authorization if present
    private func buildHeaders(req: Request) -> HTTPHeaders {
        var headers = HTTPHeaders()
        if let auth = req.headers[.authorization].first {
            headers.add(name: .authorization, value: auth)
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

// 8) GitHubMilestoneController.swift
let gitHubMilestoneControllerSwift = #"""
import Vapor

final class GitHubMilestoneController {
    private let service: GitHubProxyService

    init() {
        guard let app = GlobalAppRef.shared.app else {
            fatalError("GlobalAppRef.shared.app not set. Did you assign it in main.swift?")
        }
        self.service = GitHubProxyService(app: app)
    }

    // 1) Create Milestone
    func createMilestone(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)

        let bodyBuffer = try await req.body.collect().map { $0 } ?? ByteBuffer()
        let path = "/repos/\(owner)/\(repo)/milestones"

        let githubResponse = try await service.post(path: path, body: bodyBuffer, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // 2) List Milestones
    func listMilestones(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)

        let path = "/repos/\(owner)/\(repo)/milestones"
        let githubResponse = try await service.get(path: path, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // 3) Get a Milestone
    func getMilestone(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let milestoneNumber = try req.parameters.require("milestone_number", as: Int.self)

        let path = "/repos/\(owner)/\(repo)/milestones/\(milestoneNumber)"
        let githubResponse = try await service.get(path: path, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // 4) Update Milestone
    func updateMilestone(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let milestoneNumber = try req.parameters.require("milestone_number", as: Int.self)

        let bodyBuffer = try await req.body.collect().map { $0 } ?? ByteBuffer()
        let path = "/repos/\(owner)/\(repo)/milestones/\(milestoneNumber)"

        let githubResponse = try await service.patch(path: path, body: bodyBuffer, req: req)
        return formatProxyResponse(githubResponse, req)
    }

    // 5) Delete Milestone
    func deleteMilestone(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let milestoneNumber = try req.parameters.require("milestone_number", as: Int.self)

        let path = "/repos/\(owner)/\(repo)/milestones/\(milestoneNumber)"
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

do {
    // Create directories & files
    try createFile(at: rootPath + "/Package.swift", content: packageSwift)
    try createFile(at: rootPath + "/Sources/Run/main.swift", content: mainSwift)
    try createFile(at: rootPath + "/Sources/App/configure.swift", content: configureSwift)
    try createFile(at: rootPath + "/Sources/App/routes.swift", content: routesSwift)
    try createFile(at: rootPath + "/Sources/App/GlobalAppRef.swift", content: globalAppRefSwift)
    try createFile(at: rootPath + "/Sources/App/Middlewares/BearerAuthMiddleware.swift", content: bearerAuthMiddlewareSwift)
    try createFile(at: rootPath + "/Sources/App/Services/GitHubProxyService.swift", content: gitHubProxyServiceSwift)
    try createFile(at: rootPath + "/Sources/App/Controllers/GitHubMilestoneController.swift", content: gitHubMilestoneControllerSwift)

    print("✅ Project files successfully created in \(rootPath).")
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

Running `swift MakeMilestonesApp.swift` (or `./MakeMilestonesApp.swift`) will produce a **Vapor 4** application named **`GitHubMilestonesProxy`**, containing all the files needed for **CRUD** on GitHub milestones:

- **POST** `/repos/:owner/:repo/milestones` (create)  
- **GET** `/repos/:owner/:repo/milestones` (list)  
- **GET** `/repos/:owner/:repo/milestones/:milestone_number` (get)  
- **PATCH** `/repos/:owner/:repo/milestones/:milestone_number` (update)  
- **DELETE** `/repos/:owner/:repo/milestones/:milestone_number` (delete)

All requests require a **Bearer** token (checked by `BearerAuthMiddleware`). Enjoy your new **GitHub Milestones Proxy** app!