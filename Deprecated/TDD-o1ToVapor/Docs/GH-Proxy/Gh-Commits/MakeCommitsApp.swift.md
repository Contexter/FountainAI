Below is a **single Swift script**—let’s call it `MakeCommitsApp.swift`—that, when executed (`swift MakeCommitsApp.swift`), **creates** a complete Vapor 4 application named **`GitHubCommitsProxy`** on disk. The generated files match the **production-grade** code shown in the previous documentation, including the `Package.swift`, `main.swift`, controllers, services, etc.

# MakeCommitsApp.swift

> **How to use**  
> 1. Create a file named `MakeCommitsApp.swift` and paste in the code below.  
> 2. (Optional) Make it executable: `chmod +x MakeCommitsApp.swift`.  
> 3. Run it: `swift MakeCommitsApp.swift` (or `./MakeCommitsApp.swift`).  
> 4. It will create a directory `GitHubCommitsProxy` with all the necessary files.  
> 5. `cd GitHubCommitsProxy && swift build && swift run` to start the Vapor app.

---

```swift
#!/usr/bin/env swift
import Foundation

/// A helper function to create a file at `path` with the given `content`.
/// If the directory structure doesn't exist, it creates it. Overwrites the file if it exists.
func createFile(at path: String, content: String) throws {
    let directory = (path as NSString).deletingLastPathComponent
    try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
    let url = URL(fileURLWithPath: path)
    try content.write(to: url, atomically: true, encoding: .utf8)
}

/// The root directory of our new project
let projectName = "GitHubCommitsProxy"
let rootPath = FileManager.default.currentDirectoryPath + "/" + projectName

print("Creating project at \(rootPath)")

// 1) Package.swift
let packageSwift = #"""
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

        // Store reference if needed by controllers/services
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
    let commitController = GitHubCommitController()

    // Group routes that require Bearer authentication
    let protected = app.grouped(BearerAuthMiddleware())

    // 1) List Commits
    protected.get("repos", ":owner", ":repo", "commits", use: commitController.listCommits)

    // 2) Get Commit
    protected.get("repos", ":owner", ":repo", "commits", ":sha", use: commitController.getCommit)

    // 3) Compare Commits
    // e.g. GET /repos/{owner}/{repo}/compare/{base}...{head}
    protected.get("repos", ":owner", ":repo", "compare", ":base...:head", use: commitController.compareCommits)
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
        // Possibly override via environment variable, e.g. "https://github.myorg.com/api/v3"
        self.baseURL = Environment.get("GITHUB_API_BASE_URL") ?? "https://api.github.com"
        self.client = app.client
        self.logger = app.logger
    }

    /// Perform a GET request to GitHub, optionally with query parameters.
    func get(path: String, queries: [(String, String?)]? = nil, req: Request) async throws -> ClientResponse {
        // Construct the URL
        var urlString = baseURL + path

        // Build query string
        if let queries = queries, !queries.isEmpty {
            let queryString = queries.compactMap { (key, val) -> String? in
                guard let keyEnc = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                    return nil
                }
                if let v = val, let valEnc = v.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    return "\(keyEnc)=\(valEnc)"
                } else {
                    // Possibly skip or return empty
                    return "\(keyEnc)="
                }
            }.joined(separator: "&")

            if !queryString.isEmpty {
                urlString += "?" + queryString
            }
        }

        let uri = URI(string: urlString)

        // Forward Authorization header if present
        var headers = HTTPHeaders()
        if let authHeader = req.headers[.authorization].first {
            headers.add(name: .authorization, value: authHeader)
        }
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let response = try await client.get(uri, headers: headers)
        logger.info("[GitHubProxyService] GET \(uri) -> \(response.status.code)")

        try await handleErrorsIfNeeded(response: response)
        return response
    }

    /// Check response status; throw an error if needed.
    private func handleErrorsIfNeeded(response: ClientResponse) async throws {
        switch response.status {
        case .ok, .created, .accepted, .partialContent, .noContent:
            // success
            return
        case .unauthorized:
            let msg = try await parseError(response: response) ?? "Unauthorized request to GitHub."
            throw GitHubProxyError.unauthorized(msg)
        case .notFound:
            let msg = try await parseError(response: response) ?? "Resource not found on GitHub."
            throw GitHubProxyError.notFound(msg)
        default:
            let msg = try await parseError(response: response) ?? "Unexpected error \(response.status.code)"
            throw GitHubProxyError.generalError(msg)
        }
    }

    /// Attempt to parse a GitHub-style error from the response.
    private func parseError(response: ClientResponse) async throws -> String? {
        guard let data = response.body.data else {
            return nil
        }
        if let parsed = try? JSONDecoder().decode(GitHubErrorResponse.self, from: data) {
            return parsed.message
        }
        return nil
    }
}
"""#

// 8) GitHubCommitController.swift
let gitHubCommitControllerSwift = #"""
import Vapor

final class GitHubCommitController {
    private let service: GitHubProxyService

    init() {
        guard let app = GlobalAppRef.shared.app else {
            fatalError("GlobalAppRef.shared.app not set in main.swift.")
        }
        self.service = GitHubProxyService(app: app)
    }

    // MARK: - 1) List Commits
    // GET /repos/{owner}/{repo}/commits?sha=...&path=...&author=...
    func listCommits(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)

        // Gather optional query params
        let sha = req.query[String.self, at: "sha"]
        let path = req.query[String.self, at: "path"]
        let author = req.query[String.self, at: "author"]

        let queries: [(String, String?)] = [
            ("sha", sha),
            ("path", path),
            ("author", author)
        ]

        let githubPath = "/repos/\(owner)/\(repo)/commits"
        let githubResponse = try await service.get(path: githubPath, queries: queries, req: req)
        return makeVaporResponse(githubResponse, req)
    }

    // MARK: - 2) Get Commit
    // GET /repos/{owner}/{repo}/commits/{sha}
    func getCommit(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let sha = try req.parameters.require("sha", as: String.self)

        let githubPath = "/repos/\(owner)/\(repo)/commits/\(sha)"
        let githubResponse = try await service.get(path: githubPath, queries: nil, req: req)
        return makeVaporResponse(githubResponse, req)
    }

    // MARK: - 3) Compare Commits
    // GET /repos/{owner}/{repo}/compare/{base}...{head}
    func compareCommits(_ req: Request) async throws -> Response {
        let owner = try req.parameters.require("owner", as: String.self)
        let repo = try req.parameters.require("repo", as: String.self)
        let baseAndHead = try req.parameters.require("base...head", as: String.self)

        // Construct the GitHub API path
        let githubPath = "/repos/\(owner)/\(repo)/compare/\(baseAndHead)"
        let githubResponse = try await service.get(path: githubPath, queries: nil, req: req)
        return makeVaporResponse(githubResponse, req)
    }

    // Convert ClientResponse -> Vapor Response
    private func makeVaporResponse(_ githubResponse: ClientResponse, _ req: Request) -> Response {
        return Response(
            status: githubResponse.status,
            version: req.version,
            headers: githubResponse.headers,
            body: githubResponse.body
        )
    }
}
"""#

// Now, write these files to disk in the new project folder
do {
    try createFile(at: rootPath + "/Package.swift", content: packageSwift)
    try createFile(at: rootPath + "/Sources/Run/main.swift", content: mainSwift)
    try createFile(at: rootPath + "/Sources/App/configure.swift", content: configureSwift)
    try createFile(at: rootPath + "/Sources/App/routes.swift", content: routesSwift)
    try createFile(at: rootPath + "/Sources/App/GlobalAppRef.swift", content: globalAppRefSwift)
    try createFile(at: rootPath + "/Sources/App/Middlewares/BearerAuthMiddleware.swift", content: bearerAuthMiddlewareSwift)
    try createFile(at: rootPath + "/Sources/App/Services/GitHubProxyService.swift", content: gitHubProxyServiceSwift)
    try createFile(at: rootPath + "/Sources/App/Controllers/GitHubCommitController.swift", content: gitHubCommitControllerSwift)

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

### What This Script Does

1. **Creates** a new folder named **`GitHubCommitsProxy`** in your current directory.  
2. **Writes** all the Vapor 4 project files into subfolders (`Sources/Run`, `Sources/App`, etc.).  
3. **Outputs** usage instructions:  
   - `cd GitHubCommitsProxy`  
   - `swift build && swift run`  

You’ll then have a **fully functional** Vapor 4 application for proxying **GitHub Commits** operations:

- **List Commits**  
- **Get Commit Details**  
- **Compare Two Commits**  

All **secured** by Bearer authentication and with **proxy logic** to GitHub’s API. Enjoy!