# Episode 3: Creating an OpenAPI-based Vapor Wrapper App around "gh"

## Table of Contents

1. [Introduction](#introduction)
2. [Why Create This App?](#why-create-this-app)
   - [Enhancing Software Development](#enhancing-software-development)
   - [Usefulness in AI-Aided Development](#usefulness-in-ai-aided-development)
   - [Example Scenario](#example-scenario)
3. [OpenAPI Specification](#openapi-specification)
4. [Implementing the Vapor App](#implementing-the-vapor-app)
   - [Project Setup](#project-setup)
   - [Writing Tests](#writing-tests)
   - [Define Routes and Controllers](#define-routes-and-controllers)
   - [Handling GitHub CLI Commands](#handling-github-cli-commands)
5. [Dockerizing the Vapor App](#dockerizing-the-vapor-app)
6. [Conclusion](#conclusion)

## Introduction

In this episode, we will create a Vapor app that acts as a wrapper around the GitHub CLI (`gh`). This app will provide a web interface for interacting with GitHub repositories, including listing contents, fetching file contents, and managing GitHub secrets. We will start by defining our API using the OpenAPI specification, implement the Vapor app, dockerize the app, and secure it using JWT-based bearer authentication.

> read also: [Enhancing Application Security with GitHub Secrets and Vapor's JWT Implementation](https://github.com/Contexter/fountainAI/blob/editorial/episodes/Episode3/Enhancing%20Application%20Security%20with%20GitHub%20Secrets%20and%20Vapor's%20JWT%20Implementation.md)


## Why Create This App?

### Enhancing Software Development

This GitHub CLI Wrapper app is designed to simplify and enhance the software development process by providing a web interface to interact with GitHub repositories. By wrapping the `gh` CLI in a web API, we make it easier to:

- **Automate Repository Management**: Automate tasks such as listing contents, fetching file data, and managing branches without needing to manually run commands in the terminal.
- **Integrate with Other Tools**: Easily integrate repository management tasks into other tools and systems via HTTP requests.

### Usefulness in AI-Aided Development

When developing software with the assistance of AI models like GPT-4, having a structured and automated way to interact with your code repositories is invaluable. This app can be particularly useful for:

- **Custom GPT in ChatGPT**: When using OpenAI's custom GPTs in ChatGPT, you can create custom workflows and automations that interact with GitHub repositories directly through the chat interface. This can help streamline tasks such as code reviews, fetching code snippets, and more.
- **Prompting GPT-4**: You can prompt GPT-4 to execute specific repository tasks via this web interface, making it easier to automate repetitive tasks and improve productivity.

### Example Scenario

Imagine you are working on a project and need to quickly review the structure of a repository, fetch specific files, or list the latest commits. Instead of manually navigating the GitHub interface or running multiple `gh` commands, you can use this app to perform these actions with simple HTTP requests. This seamless integration can be particularly powerful when combined with AI-driven development workflows.

## OpenAPI Specification

The OpenAPI specification serves as a blueprint for our API, detailing the endpoints, parameters, responses, and security. Here’s the OpenAPI specification we will use:

```yaml
openapi: 3.1.0
info:
  title: GitHub CLI Wrapper
  version: 1.0.0
  description: A Vapor app that wraps GitHub CLI commands for repository management, including secrets management
servers:
  - url: https://gh.fountain.coach
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
  schemas:
    RepositoryTree:
      type: object
      properties:
        path:
          type: string
        type:
          type: string
    FileContent:
      type: object
      properties:
        content:
          type: string
    RepositoryDetails:
      type: object
      properties:
        full_name:
          type: string
        description:
          type: string
        owner:
          type: object
          properties:
            login:
              type: string
        private:
          type: boolean
    Branch:
      type: object
      properties:
        name:
          type: string
    Commit:
      type: object
      properties:
        sha:
          type: string
        commit:
          type: object
          properties:
            message:
              type: string
    Contributor:
      type: object
      properties:
        login:
          type: string
    PullRequest:
      type: object
      properties:
        number:
          type: integer
        title:
          type: string
    Issue:
      type: object
      properties:
        number:
          type: integer
        title:
          type: string
paths:
  /repo/tree:
    get:
      summary: Fetch repository tree
      description: Fetches the tree structure of a repository.
      operationId: fetchRepoTree
      parameters:
        - name: repo
          in: query
          required: true
          schema:
            type: string
          description: The repository in the format owner/repo
        - name: branch
          in: query
          required: false
          schema:
            type: string
          description: The branch to fetch the tree from (default is "main")
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Successfully fetched repository tree
          content:
            application/json:
              schema:
                type: string
  /repo/contents:
    get:
      summary: List repository contents
      description: Lists the contents of a repository directory.
      operationId: listRepoContents
      parameters:
        - name: repo
          in: query
          required: true
          schema:
            type: string
          description: The repository in the format owner/repo
        - name: path
          in: query
          required: false
          schema:
            type: string
          description: The directory path to list contents of (default is root)
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Successfully listed contents
          content:
            application/json:
              schema:
                type: string
  /repo/file:
    get:
      summary: Fetch file content
      description: Fetches the content of a specific file in the repository.
      operationId: fetchFileContent
      parameters:
        - name: repo
          in: query
          required: true
          schema:
            type: string
          description: The repository in the format owner/repo
        - name: path
          in: query
          required: true
          schema:
            type: string
          description: The path to the file to fetch content from
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Successfully fetched file content
          content:
            text/plain:
              schema:
                type: string
  /repo/details:
    get:
      summary: Get repository details
      description: Fetches details about the repository.
      operationId: getRepoDetails
      parameters:
        - name: repo
          in: query
          required: true
          schema:
            type: string
          description: The repository in the format owner/repo
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Successfully fetched repository details
          content:
            application/json:
              schema:
                type: string
  /repo/branches:
    get:
      summary: List repository branches
      description: Lists the branches of a repository.
      operationId: listRepoBranches
      parameters:
        - name: repo
          in: query
          required: true
          schema:
            type: string
          description: The repository in the format owner/repo
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Successfully listed branches
          content:
            application/json:
              schema:
                type: string
  /repo/commits:
    get:
      summary: List repository commits
      description: Lists the commits of a repository.
      operationId: listRepoCommits
      parameters:
        - name: repo
          in: query
          required: true
          schema:
            type: string
          description: The repository in the format owner/repo
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Successfully listed commits
          content:
            application/json:
              schema:
                type: string
  /repo/contributors:
    get:
      summary: List repository contributors
      description: Lists the contributors of a repository.
      operationId: listRepoContributors
      parameters:
        - name: repo
          in: query
          required: true
          schema:
            type: string
          description: The repository in the format owner/repo
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Successfully listed contributors
          content:
            application/json:
              schema:
                type: string
  /repo/pulls:
    get:
      summary: List repository pull requests
      description: Lists the pull requests of a repository.
      operationId: listRepoPullRequests
      parameters:
        - name: repo
          in: query
          required: true
          schema:
            type: string
          description: The repository in the format owner/repo
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Successfully listed pull requests
          content:
            application/json:
              schema:
                type: string
  /repo/issues:
    get:
      summary: List repository issues
      description: Lists the issues of a repository.
      operationId: listRepoIssues
      parameters:
        - name: repo
          in: query
          required: true
          schema:
            type: string
          description: The repository in the format owner/repo
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Successfully listed issues
          content:
            application/json:
              schema:
                type: string
  /repo/secrets:
    get:
      summary: List repository secrets
      description: Lists the secrets of a repository.
      operationId: listRepoSecrets
      parameters:
        - name: repo
          in: query
          required: true
          schema:
            type: string
          description: The repository in the format owner/repo
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Successfully listed secrets
          content:
            application/json:
              schema:
                type: string
  /repo/secrets:
    post:
      summary: Create or update a repository secret
      description: Creates or updates a secret in a repository.
      operationId: createOrUpdateRepoSecret
      parameters:
        - name: repo
          in: query
          required: true
          schema:
            type: string
          description: The repository in the format owner/repo
        - name: secret_name
          in: query
          required: true
          schema:
            type: string
          description: The name of the secret
        - name: secret_value
          in: query
          required: true
          schema:
            type: string
          description: The value of the secret
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Successfully created or updated secret
          content:
            application/json:
              schema:
                type: string
```

## Implementing the Vapor App

### Project Setup

1. **Install Vapor**: Ensure you have Vapor installed. If not, you can install it using Homebrew:
   ```bash
   brew install vapor
   ```

2. **Create a new Vapor project**:
   ```bash
   vapor new GitHubCLIWrapper --template=api
   cd GitHubCLIWrapper
   ```

3. **Modify `Package.swift`** to include necessary dependencies:
   ```swift
   // swift-tools-version:5.3
   import PackageDescription

   let package = Package(
       name: "GitHubCLIWrapper",
       platforms: [
           .macOS(.v10_15)
       ],
       dependencies: [
           .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
           .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0")
       ],
       targets: [
           .target(name: "App", dependencies: [
               .product(name: "Vapor", package: "vapor"),
               .product(name: "JWT", package: "jwt")
           ]),
           .target(name: "Run", dependencies: [.target(name: "App")]),
           .testTarget(name: "AppTests", dependencies: [
               .target(name: "App"),
               .product(name: "XCTVapor", package: "vapor"),
           ])
       ]
   )
   ```

### Writing Tests

We'll start by writing tests to ensure our Vapor app works as expected, including tests for JWT authentication.

**Create a `GitHubControllerTests.swift` file** in the `Tests/AppTests` directory:

```swift
import XCTVapor
@testable import App

final class GitHubControllerTests: XCTestCase {
    func testFetchRepoTree() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        try app.test(.GET, "/repo/tree?repo=owner/repo&branch=main", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testListContents() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        try app.test(.GET, "/repo/contents?repo=owner/repo&path=", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testFetchFileContent() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        try app.test(.GET, "/repo/file?repo=owner/repo&path=README.md", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testGetRepoDetails() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        try app.test(.GET, "/repo/details?repo=owner/repo", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testListBranches() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        try app.test(.GET, "/repo/branches?repo=owner/repo", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testListCommits() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        try app.test(.GET, "/repo/commits?repo=owner/repo", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testListContributors() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        try app.test(.GET, "/repo/contributors?repo=owner/repo", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testListPullRequests() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        try app.test(.GET, "/repo/pulls?repo=owner/repo", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testListIssues() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        try app.test(.GET, "/repo/issues?repo=owner/repo", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testListSecrets() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        try app.test(.GET, "/repo/secrets?repo=owner/repo", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testCreateOrUpdateSecret() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        try app.test(.POST, "/repo/secrets?repo=owner/repo&secret_name=SECRET_KEY&secret_value=SECRET_VALUE", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    private func generateJWTToken() throws -> String {
        let signers = JWTSigners()
        try signers.use(.hs256(key: "secret"))
        let payload = MyPayload(sub: .init(value: "user123"), exp: .init(value: .distantFuture))
        return try signers.sign(payload)
    }
}
```

Running these tests initially will result in failures since we haven't implemented the functionality yet. This aligns with the Test-Driven Development (TDD) approach, where tests are written first and then the functionality is implemented to make them pass.

To run these tests, use the following command:

```bash
swift test
```

### Define Routes and Controllers

**Create a `GitHubController.swift` file** in the `Sources/App/Controllers` directory:

```swift
import Vapor
import JWT

struct GitHubController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let repoRoutes = routes.grouped("repo").grouped(JWTMiddleware())
        repoRoutes.get("tree", use: fetchRepoTree)
        repoRoutes.get("contents", use: listContents)
        repoRoutes.get("file", use: fetchFileContent)
        repoRoutes.get("details", use: getRepoDetails)
        repoRoutes.get("branches", use: listBranches)
        repoRoutes.get("commits", use: listCommits)
        repoRoutes.get("contributors", use: listContributors)
        repoRoutes.get("pulls", use: listPullRequests)
        repoRoutes.get("issues", use: listIssues)
        repoRoutes.get("secrets", use: listSecrets)
        repoRoutes.post("secrets", use: createOrUpdateSecret)
    }

    func fetchRepoTree(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let branch = try req.query.get(String.self, at: "branch") ?? "main"
        let url = URI(string: "https://api.github.com/repos/\(repo)/git/trees/\(branch)?recursive=1")
        return try makeGHRequest(req: req, url: url)
    }

    func listContents(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let path = try req.query.get(String.self, at: "path") ?? ""
        let url = URI(string: "https://api.github.com/repos/\(repo)/contents/\(path)")
        return try makeGHRequest(req: req, url: url)
    }

    func fetchFileContent(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let path = try req.query.get(String.self, at: "path")
        let url = URI(string: "https://api.github.com/repos/\(repo)/contents/\(path)")
        return try makeGHRequest(req: req, url: url)
    }

    func getRepoDetails(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)")
        return try makeGHRequest(req: req, url: url)
    }

    func listBranches(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/branches")
        return try makeGHRequest(req: req, url: url)
    }

    func listCommits(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/commits")
        return try makeGHRequest(req: req, url: url)
    }

    func listContributors(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/contributors")
        return try makeGHRequest(req: req, url: url)
    }

    func listPullRequests(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/pulls")
        return try makeGHRequest(req: req, url: url)
    }

    func listIssues(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/issues")
        return try makeGHRequest(req: req, url: url)
    }

    func listSecrets(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/actions/secrets")
        return try makeGHRequest(req: req, url: url)
    }

    func createOrUpdateSecret(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let secretName = try req.query.get(String.self, at: "secret_name")
        let secretValue = try req.query.get(String.self, at: "secret_value")
        let url = URI(string: "https://api.github.com/repos/\(repo)/actions/secrets/\(secretName)")
        return try makeGHRequest(req: req, url: url, method: .put, body: secretValue)
    }

    private func makeGHRequest(req: Request, url: URI, method: HTTPMethod = .get, body: String? = nil) throws -> EventLoopFuture<ClientResponse> {
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer \(Environment.get("GITHUB_TOKEN")!)")
        headers.add(name: .userAgent, value: "VaporApp")
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        let clientReq = ClientRequest(
            method: method,
            url: url,
            headers: headers,
            body: body != nil ? .init(string: body!) : nil
        )
        return req.client.send(clientReq)
    }
}
```

**Create a `JWTMiddleware.swift` file** in the `Sources/App/Middleware` directory:

```swift
import Vapor
import JWT

struct JWTMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let token = request.headers.bearerAuthorization?.token else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Missing Bearer Token"))
        }
        
        do {
            let jwt = try request.jwt.verify(token, as: MyPayload.self)
            // Add verified JWT to request storage or context as needed
            request.storage[JWTStorageKey.self] = jwt
            return next.respond(to: request)
        } catch {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Invalid or expired Bearer Token"))
        }
    }
}

struct MyPayload: JWTPayload {
    var sub: SubjectClaim
    var exp: ExpirationClaim
    
    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}

struct JWTStorageKey: StorageKey {
    typealias Value = MyPayload
}
```

**Update `configure.swift` to register the new controller and configure JWT**:

```swift
import Vapor
import JWT

public func configure(_ app: Application) throws {
    // JWT Configuration
    let signers = JWTSigners()
    try signers.use(.hs256(key: Environment.get("JWT_SECRET")!))
    app.jwt.signers = signers

    // Register routes
    let gitHubController = GitHubController()
    try app.register(collection: gitHubController)
}
```

**Update `routes.swift` to register the controller routes**:

```swift
import Vapor

func routes(_ app: Application) throws {
    let gitHubController = GitHubController()
    try app.register(collection: gitHubController)
}
```

### Dockerizing the Vapor App

1. **Create a `Dockerfile`** in the root directory of your project:

    ```dockerfile
    # Stage 1 - Build
    FROM swift:5.5-focal as builder
    WORKDIR /app
    COPY . .
    RUN swift build --disable-sandbox -c release

    # Stage 2 - Run
    FROM swift:5.5-focal-slim
    WORKDIR /app
    COPY --from=builder /app/.build/release /app
    ENV GITHUB_TOKEN=${GITHUB_TOKEN}
    ENV JWT_SECRET=${JWT_SECRET}
    ENTRYPOINT ["/app/Run"]
    ```

2. **Create a `.dockerignore`** file to exclude unnecessary files from the Docker image:

    ```dockerignore
    .build/
    .swiftpm/
    Packages/
    Package.resolved
    Tests/
    ```

3. **Build and run the Docker container locally**:

    ```bash
    docker build -t github-cli-wrapper .
    docker run -p 8080:8080 -e GITHUB_TOKEN=your_github_token_here -e JWT_SECRET=your_jwt_secret_here github-cli-wrapper
    ```

## Conclusion

In this episode, we created a fully functional Vapor app that wraps GitHub CLI commands and interacts with the GitHub API. We followed TDD principles by writing tests first and then implementing the features to make the tests pass. We also dockerized the app and implemented JWT-based bearer authentication to secure the API. This setup ensures that only authorized users can access and perform operations on the API.