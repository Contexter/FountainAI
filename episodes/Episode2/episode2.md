# Episode 2: Creating an OpenAPI-based Vapor Wrapper App around "gh"

## Table of Contents

1. [Introduction](#introduction)
2. [Why Create This App?](#why-create-this-app)
   - [Enhancing Software Development](#enhancing-software-development)
   - [Usefulness in AI-Aided Development](#usefulness-in-ai-aided-development)
   - [Example Scenario](#example-scenario)
3. [OpenAPI Specification](#openapi-specification)
4. [Security Requirements](#security-requirements)
   - [Why Use a GitHub Token](#why-use-a-github-token)
   - [Why Use JWT Authentication](#why-use-jwt-authentication)
   - [Generating JWT Secret](#generating-jwt-secret)
   - [Using GitHub Secrets](#using-github-secrets)
5. [Implementing the Vapor App](#implementing-the-vapor-app)
   - [Project Setup](#project-setup)
   - [Setting Up the CI/CD Pipeline](#setting-up-the-cicd-pipeline)
   - [Writing Tests](#writing-tests)
   - [Define Routes and Controllers](#define-routes-and-controllers)
   - [Handling GitHub CLI Commands](#handling-github-cli-commands)
6. [Dockerizing the Vapor App](#dockerizing-the-vapor-app)
7. [Running the Application with Docker Compose](#running-the-application-with-docker-compose)
8. [Conclusion](#conclusion)

## Introduction

In this episode, we will create a Vapor app that acts as a wrapper around the GitHub CLI (`gh`). This app will provide a web interface for interacting with GitHub repositories, including listing contents, fetching file contents, and managing GitHub secrets. We will start by defining our API using the OpenAPI specification, implement the Vapor app, dockerize the app, and secure it using JWT-based bearer authentication.

> read also: [Enhancing Application Security with GitHub Secrets and Vapor's JWT Implementation](https://github.com/Contexter/fountainAI/blob/editorial/episodes/Episode3/Enhancing%20Application%20Security%20with%20GitHub%20Secrets%20and%20Vapor's%20JWT%20Implementation.md) & [GitHub CLI Manual](https://cli.github.com/manual/)

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

The OpenAPI specification serves as a blueprint for our API, detailing the endpoints, parameters, responses, and security. You can find the detailed OpenAPI specification [here](https://github.com/Contexter/fountainAI/blob/editorial/openAPI/Tools%20openAPI/vapor_gl_wrapper.yaml).

## Security Requirements

### Why Use a GitHub Token

A GitHub token is required for authenticating requests made to the GitHub API. This token ensures that only authorized users can access and manipulate GitHub repositories. By using a GitHub token:

- **Secure API Requests**: It ensures that the API requests are authenticated and authorized.
- **Access Control**: It restricts access to the repositories based on the permissions granted to the token.
- **Rate Limiting**: It allows tracking and managing the rate limits imposed by GitHub for API requests.

The GitHub token is essential for the `gh` CLI commands to interact with the GitHub API securely. Without the token, the app cannot perform actions like listing repository contents, fetching file data, or managing secrets.

### Why Use JWT Authentication

JWT (JSON Web Token) authentication is used to secure the Vapor app and ensure that only authorized users can access the API endpoints. By implementing JWT authentication:

- **Stateless Authentication**: JWTs provide a stateless authentication mechanism, reducing the need for server-side sessions.
- **Enhanced Security**: JWTs can be signed and optionally encrypted to ensure the integrity and confidentiality of the data.
- **Scalability**: JWTs are self-contained, making them ideal for distributed systems and microservices.

JWT authentication ensures that only users with a valid token can access the endpoints of the Vapor app, protecting the app from unauthorized access and potential misuse.

### Generating JWT Secret

To secure the JWT tokens, you need to generate a secret key. This key will be used to sign the tokens and ensure their integrity. Here’s how you can generate a JWT secret:

1. **Generate a Secret Key**:
   - You can generate a secure random key using various tools. For example, using OpenSSL:
     ```bash
     openssl rand -base64 32
     ```
   - Alternatively, you can use online tools like [JWT.io](https://jwt.io/) to generate a secret key.

2. **Store the Secret Key Securely**:
   - Save the generated key in a secure location, such as a password manager or a secure environment variable.

### Using GitHub Secrets

To securely manage the GitHub token and JWT secret, we will use GitHub Secrets. This allows us to store sensitive information securely and use it in our application without exposing it in the source code.

#### Step 1: Store Secrets in GitHub

1. **Navigate to Your Repository Settings**:
   - Go to your GitHub repository in your web browser.
   - Click on **Settings**.

2. **Access Secrets and Variables**:
   - In the left sidebar, click on **Secrets and variables**.
   - Click on **Actions**.

3. **Add New Repository Secrets**:
   - Add a new secret for the GitHub token:
     - **Name**: `GITHUB_TOKEN`
     - **Value**: `your_generated_github_token`
   - Add a new secret for the JWT secret:
     - **Name**: `JWT_SECRET`
     - **Value**: `your_generated_jwt_secret`

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

### Setting Up the CI/CD Pipeline

To ensure continuous integration and deployment, we will set up a CI/CD pipeline using GitHub Actions. This pipeline will build, test, and push the Docker image to the GitHub Container Registry.

#### Step 1: Create GitHub Actions Workflow

1. **Create Workflow Directory**:
   - In the root of your repository, create a directory named `.github/workflows`.

2. **Create Workflow File**:
   - Inside the `.github/workflows` directory, create a file named `ci-cd.yml`.

3. **Add Workflow Configuration**:
   - Add the following configuration to the `ci-cd.yml` file:

```yaml
name: CI/CD

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v1

    - name: Log in to GitHub Container Registry
      uses: docker/login-action@v1
      with:
        registry: ghcr.io
        username: ${{ github.repository_owner }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: Set up Swift
      uses: fwal/setup-swift@v1

    - name: Build the app
      run: swift build --disable-sandbox -c release

    - name: Run tests
      run: swift test

    - name: Build and push Docker image
      run: |
        docker-compose build
        echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin
        docker-compose push
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        JWT_SECRET: ${{ secrets.JWT_SECRET }}
```

This configuration ensures that the secrets are securely passed to the Docker Compose process during the build and push stages.

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

### Running the Application with Docker Compose

1. **Create a `docker-compose.yml` file** in the root directory of your project:

    ```yaml
    version: '3.8'

    services:
      vapor:
        build:
          context: .
          dockerfile: Dockerfile
        ports:
          - "8080:8080"
        environment:
          GITHUB_TOKEN: ${GITHUB_TOKEN}
          JWT_SECRET: ${JWT_SECRET}
    ```

2. **Run the application**:

    To run the application using Docker Compose, ensure the environment variables are injected from GitHub Secrets during the pipeline execution.

### Setting Up Runtime Injection in the CI/CD Pipeline

To ensure the environment variables are securely managed, we'll use GitHub Secrets in our pipeline to pass them to the Docker Compose.

#### Step 1: Modify GitHub Actions Workflow

Update the `ci-cd.yml` file to use Docker Compose with GitHub Secrets:

```yaml
name: CI/CD

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v1

    - name: Log in to GitHub Container Registry
      uses: docker/login-action@v1
      with:
        registry: ghcr.io
        username: ${{ github.repository_owner }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: Set up Swift
      uses: fwal/setup-swift@v1

    - name: Build the app
      run: swift build --disable-sandbox -c release

    - name: Run tests
      run: swift test

    - name: Build and push Docker image
      run: |
        docker-compose build
        echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin
        docker-compose push
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        JWT_SECRET: ${{ secrets.JWT_SECRET }}
```

This configuration ensures that the secrets are securely passed to the Docker Compose process during the build and push stages.

## Conclusion

In this episode, we created a fully functional Vapor app that wraps GitHub CLI commands and interacts with the GitHub API. We followed TDD principles by writing tests first and then implementing the features to make them pass. We also dockerized the app and implemented JWT-based bearer authentication to secure the API. This setup ensures that only authorized users can access and perform operations on the API. We also set up a CI/CD pipeline to automate the build and deployment process, ensuring continuous integration and delivery of our application. Additionally, we integrated Docker Compose to simplify the process of managing multi-container applications, enhancing the development workflow by providing a consistent environment for running the application both locally and in production. By using GitHub Secrets, we ensured that sensitive information is handled securely.

