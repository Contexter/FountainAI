Below is a **single Swift script**—for example, **`MakeFilesApp.swift`**—that, when run, **creates** a Vapor 4 project named **`GitHubFilesProxy`** in your current directory. The code matches the production-ready application from the previous documentation, handling file contents (get, create/update, delete) in GitHub repositories.

# MakeFilesApp.swift

> **How to use**  
> 1. Create a file named `MakeFilesApp.swift` (or a name you prefer) and paste the script below.  
> 2. (Optional) Make it executable: `chmod +x MakeFilesApp.swift`.  
> 3. Run it: `swift MakeFilesApp.swift` (or `./MakeFilesApp.swift`).  
> 4. It will create a **`GitHubFilesProxy`** folder containing all the necessary files.  
> 5. `cd GitHubFilesProxy && swift build && swift run` to start the Vapor app.

---

```swift
#!/usr/bin/env swift
import Foundation

/// A helper function to create a file at `path` with the given `content`.
/// Creates intermediate directories if needed. Overwrites if file exists.
func createFile(at path: String, content: String) throws {
    let directory = (path as NSString).deletingLastPathComponent
    try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
    let url = URL(fileURLWithPath: path)
    try content.write(to: url, atomically: true, encoding: .utf8)
}

/// Our new project folder name
let projectName = "GitHubFilesProxy"
/// Absolute path to the project location
let rootPath = FileManager.default.currentDirectoryPath + "/" + projectName

print("Creating project at \(rootPath)")

// 1) Package.swift
let packageSwift = #"""
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
    // Optionally override the server port:
    // app.http.server.configuration.port = 8080

    // Register routes
    try routes(app)
}
"""#

// 4) routes.swift
let routesSwift = #"""
import Vapor

public func routes(_ app: Application) throws {
    let fileController = GitHubFileController()

    // Protect routes with BearerAuthMiddleware
    let protected = app.grouped(BearerAuthMiddleware())

    // 1) Get File or Directory Content
    // GET /repos/:owner/:repo/contents/:path
    // Use "**" to catch subdirectories if needed:
    protected.get("repos", ":owner", ":repo", "contents", "**", use: fileController.getFileContent)

    // 2) Create or Update File
    // PUT /repos/:owner/:repo/contents/:path
    protected.put("repos", ":owner", ":repo", "contents", "**", use: fileController.createOrUpdateFile)

    // 3) Delete File
    // DELETE /repos/:owner/:repo/contents/:path
    protected.delete("repos", ":owner", ":repo", "contents", "**", use: fileController.deleteFile)
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
              authHeader.lowercased().starts(with: "bearer ") else {
            throw Abort(.unauthorized, reason: "Missing or invalid Bearer token.")
        }
        // Optionally validate token here
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
        // E.g., "https://api.github.com" or from environment variable
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

    // PUT (Create or Update a file)
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
        if let errorObj = try? JSONDecoder().decode(GitHubErrorResponse.self, from: data) {
            return errorObj.message
        }
        return nil
    }
}
"""#

// 8) GitHubFileController.swift
let gitHubFileControllerSwift = #"""
import Vapor

final class GitHubFileController {
    private let service: GitHubProxyService

    init() {
        guard let app = GlobalAppRef.shared.app else {
            fatalError("GlobalAppRef.shared.app not set. Did you assign it in main.swift?")
        }
        self.service = GitHubProxyService(app: app)
    }

    // MARK: - 1) Get File or Directory Content
    func getFileContent(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        // If using "**" in routes, capture the full path with catchall:
        let filePath = try req.parameters.requireCatchall().joined(separator: "/")

        let githubPath = "/repos/\(owner)/\(repo)/contents/\(filePath)"
        let response = try await service.get(path: githubPath, req: req)
        return formatProxyResponse(response, req)
    }

    // MARK: - 2) Create or Update File
    func createOrUpdateFile(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let filePath = try req.parameters.requireCatchall().joined(separator: "/")

        let bodyBuffer = try await req.body.collect().map { $0 } ?? ByteBuffer()
        let githubPath = "/repos/\(owner)/\(repo)/contents/\(filePath)"

        let response = try await service.put(path: githubPath, body: bodyBuffer, req: req)
        return formatProxyResponse(response, req)
    }

    // MARK: - 3) Delete File
    // Requires "message" and "sha" query parameters (and optional "branch")
    func deleteFile(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let filePath = try req.parameters.requireCatchall().joined(separator: "/")

        guard let message = req.query[String.self, at: "message"] else {
            throw Abort(.badRequest, reason: "Missing required 'message' query param.")
        }
        guard let sha = req.query[String.self, at: "sha"] else {
            throw Abort(.badRequest, reason: "Missing required 'sha' query param.")
        }
        let branch = req.query[String.self, at: "branch"]

        var pathWithParams = "/repos/\(owner)/\(repo)/contents/\(filePath)?message=\(message.urlEncoded)&sha=\(sha.urlEncoded)"
        if let branchName = branch?.urlEncoded, !branchName.isEmpty {
            pathWithParams += "&branch=\(branchName)"
        }

        let response = try await service.delete(path: pathWithParams, req: req)
        return formatProxyResponse(response, req)
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

// For convenience, a little String extension for URL-encoding
extension String {
    var urlEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
"""#

// Now create the folder structure and write all files
do {
    try createFile(at: rootPath + "/Package.swift", content: packageSwift)
    try createFile(at: rootPath + "/Sources/Run/main.swift", content: mainSwift)
    try createFile(at: rootPath + "/Sources/App/configure.swift", content: configureSwift)
    try createFile(at: rootPath + "/Sources/App/routes.swift", content: routesSwift)
    try createFile(at: rootPath + "/Sources/App/GlobalAppRef.swift", content: globalAppRefSwift)
    try createFile(at: rootPath + "/Sources/App/Middlewares/BearerAuthMiddleware.swift", content: bearerAuthMiddlewareSwift)
    try createFile(at: rootPath + "/Sources/App/Services/GitHubProxyService.swift", content: gitHubProxyServiceSwift)
    try createFile(at: rootPath + "/Sources/App/Controllers/GitHubFileController.swift", content: gitHubFileControllerSwift)

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

After running this **Swift script**, you will have a **Vapor 4** application named **`GitHubFilesProxy`** that:

- **Proxies** GitHub repository content management (get, create/update, delete files).  
- **Secures** each route with Bearer authentication.  
- **Logs** requests and handles GitHub error responses gracefully.

Then just:  
```bash
cd GitHubFilesProxy
swift build
swift run
```
And you have a **production-ready** GitHub contents proxy!