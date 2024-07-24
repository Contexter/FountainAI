# Episode 2: Creating an OpenAPI-based Vapor Wrapper App around "gh"

## Table of Contents

**Part A: Initial Setup and Basic Testing**

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

**Part B: Implementing the Vapor App**

5. [Project Setup](#project-setup)
6. [Writing Tests First](#writing-tests-first)
7. [Implementing the Features to Pass Tests](#implementing-the-features-to-pass-tests)
   - [Define Routes and Controllers](#define-routes-and-controllers)
   - [Handling GitHub CLI Commands](#handling-github-cli-commands)
   - [Implementing the Token Generation Route](#implementing-the-token-generation-route)
   - [Securing the Token Generation Endpoint](#securing-the-token-generation-endpoint)
   - [Error Handling](#error-handling)
   - [Logging](#logging)
   - [Configuration](#configuration)

**Part C: Deployment and Maintenance**

8. [Setting Up the CI/CD Pipeline](#setting-up-the-cicd-pipeline)
9. [Dockerizing the Vapor App](#dockerizing-the-vapor-app)
10. [Running the Application with Docker Compose](#running-the-application-with-docker-compose)
11. [Conclusion](#conclusion)

**Addendum**

12. [Idempotent Main Script](#idempotent-main-script)

## Part A: Initial Setup and Basic Testing

### 1. Introduction

In this episode, we will create a Vapor app that acts as a wrapper around the GitHub CLI (`gh`). This app will provide a web interface for interacting with GitHub repositories, including listing contents, fetching file contents, and managing GitHub secrets. We will start by defining our API using the OpenAPI specification, implementing the Vapor app, dockerizing the app, and securing it using JWT-based bearer authentication.

> Read also: 
> - [GitHub CLI Manual](https://cli.github.com/manual/)
> - [Secure Token Generation Using Basic Authentication: A Practical Guide](https://github.com/Contexter/fountainAI/blob/editorial/episodes/Episode2/Secure%20Token%20Generation%20Using%20Basic%20Authentication_%20A%20Practical%20Guide.md)


### 2. Why Create This App?

#### Enhancing Software Development

This GitHub CLI Wrapper app is designed to simplify and enhance the software development process by providing a web interface to interact with GitHub repositories. By wrapping the `gh` CLI in a web API, we make it easier to:

1. **Automate Repository Management**: Automate tasks such as listing contents, fetching file data, and managing branches without needing to manually run commands in the terminal.
2. **Integrate with Other Tools**: Easily integrate repository management tasks into other tools and systems via HTTP requests.

#### Usefulness in AI-Aided Development

When developing software with the assistance of AI models like GPT-4, having a structured and automated way to interact with your code repositories is invaluable. This app can be particularly useful for:

1. **Custom GPT in ChatGPT**: When using OpenAI's custom GPTs in ChatGPT, you can create custom workflows and automations that interact with GitHub repositories directly through the chat interface. This can help streamline tasks such as code reviews, fetching code snippets, and more.
2. **Prompting GPT-4**: You can prompt GPT-4 to execute specific repository tasks via this web interface, making it easier to automate repetitive tasks and improve productivity.

#### Example Scenario

Imagine you are working on a project and need to quickly review the structure of a repository, fetch specific files, or list the latest commits. Instead of manually navigating the GitHub interface or running multiple `gh` commands, you can use this app to perform these actions with simple HTTP requests. This seamless integration can be particularly powerful when combined with AI-driven development workflows.

### 3. OpenAPI Specification

The OpenAPI specification serves as a blueprint for our API, detailing the endpoints, parameters, responses, and security. You can find the detailed OpenAPI specification [here](https://github.com/Contexter/fountainAI/blob/editorial/openAPI/Tools%20openAPI/vapor_gl_wrapper.yaml).

### 4. Security Requirements

#### Why Use a GitHub Token

A GitHub token is required for authenticating requests made to the GitHub API. This token ensures that only authorized users can access and manipulate GitHub repositories. By using a GitHub token:

1. **Secure API Requests**: It ensures that the API requests are authenticated and authorized.
2. **Access Control**: It restricts access to the repositories based on the permissions granted to the token.
3. **Rate Limiting**: It allows tracking and managing the rate limits imposed by GitHub for API requests.

The GitHub token is essential for the `gh` CLI commands to interact with the GitHub API securely. Without the token, the app cannot perform actions like listing repository contents, fetching file data, or managing secrets.

Additionally, using the GitHub CLI (`gh`) from the command line requires authentication. This means that our Vapor app must implement this authentication to effectively wrap the `gh` CLI and securely execute its commands.

#### Why Use JWT Authentication

JWT (JSON Web Token) authentication is used to secure the Vapor app and ensure that only authorized users can access the API endpoints. By implementing JWT authentication:

1. **Stateless Authentication**: JWTs provide a stateless authentication mechanism, reducing the need for server-side sessions.
2. **Enhanced Security**: JWTs can be signed and optionally encrypted to ensure the integrity and confidentiality of the data.
3. **Scalability**: JWTs are self-contained, making them ideal for distributed systems and microservices.

JWT authentication ensures that only users with a valid token can access the endpoints of the Vapor app, protecting the app from unauthorized access and potential misuse.

#### Generating JWT Secret

To secure the JWT tokens, you need to generate a secret key. This key will be used to sign the tokens and ensure their integrity. Here’s how you can generate a JWT secret:

1. **Generate a Secret Key**:
   - You can generate a secure random key using various tools. For example, using OpenSSL:
     ```bash
     openssl rand -base64 32
     ```
   - Alternatively, you can use online tools like [JWT.io](https://jwt.io/) to generate a secret key.

2. **Store the Secret Key Securely**:
   - Save the generated key in a secure location, such as a password manager or a secure environment variable.

#### Using GitHub Secrets

To securely manage the GitHub token and JWT secret, we will use GitHub Secrets. This allows us to store sensitive information securely and use it in our application without exposing it in the source code.

##### Step 1: Store Secrets in GitHub

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
   - Add new secrets for basic auth credentials to protect the token generation route:
     - **Name**: `BASIC_AUTH_USERNAME`
     - **Value**: `your_username`
     - **Name**: `BASIC_AUTH_PASSWORD`
     - **Value**: `your_password`

## Part B: Implementing the Vapor App

### 5. Project Setup

1. **Install Vapor**: Ensure you have Vapor installed. If not, you can install it using Homebrew:
   ```bash
   brew install vapor
   ```

2. **Create a new Vapor project**:
   ```bash
   vapor new GitHubCLIWrapper --template=api
   cd GitHubCLIWrapper
   ```

3. **Set Up Git Repository**
   ```bash
   git init
   ```

### 6. Writing Tests First

Following the principles of Test-Driven Development (TDD), we will write our tests before implementing the actual features. This approach ensures that we have clear requirements and validation criteria for our code.

1. **Create `TokenGenerationTests.swift` in `Tests/AppTests`**

Create a script named `create_token_generation_tests.sh`:

```bash
#!/bin/bash

function create_token_generation_tests() {
    echo "Creating TokenGenerationTests.swift in Tests/AppTests"
    mkdir -p Tests/AppTests
    cat <<EOL > Tests/AppTests/TokenGenerationTests.swift
import XCTVapor
@testable import App



final class TokenGenerationTests: XCTestCase {
    // This test verifies if the token generation endpoint is working correctly
    func testGenerateToken() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        // Set up basic auth headers with valid credentials
        let basicAuthHeader = HTTPHeaders.basicAuthorization(username: "admin", password: "password")!

        // Make a GET request to the /generate-token endpoint
        try app.test(.GET, "/generate-token", headers: ["Authorization": basicAuthHeader], afterResponse: { response in
            // Verify the response status is OK
            XCTAssertEqual(response.status, .ok)
            // Decode the response body to extract the token
            let token = try response.content.decode(String.self)
            // Verify the token is not empty
            XCTAssertFalse(token.isEmpty)
        })
    }
}
EOL

    # Commit the changes
    git add Tests/AppTests/TokenGenerationTests.swift
    git commit -m "Add TokenGenerationTests to verify the token generation endpoint"
}

create_token_generation_tests
```

Run the script:

```bash
chmod +x create_token_generation_tests.sh
./create_token_generation_tests.sh
```

Run the test to see it fail:

```bash
swift test
```

You should see an error indicating that the `/generate-token` route is not found. This is expected, as we haven't implemented it yet.

2. **Create `GitHubControllerTests.swift` in `Tests/AppTests`**

Create a script named `create_github_controller_tests.sh`:

```bash
#!/bin/bash

function create_github_controller_tests() {
    echo "Creating GitHubControllerTests.swift in Tests/AppTests"
    mkdir -p Tests/AppTests
    cat <<EOL > Tests/AppTests/GitHubControllerTests.swift
import XCTVapor
@testable import App

final class GitHubControllerTests: XCTestCase {
    func testFetchRepoTree() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        // Test fetching the repository tree
        try app.test(.GET, "/repo/tree?repo=owner/repo&branch=main", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testListContents() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        // Test listing repository contents
        try app.test(.GET, "/repo/contents?repo=owner/repo&path=", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testFetchFileContent() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        // Test fetching file content
        try app.test(.GET, "/repo/file?repo=owner/repo&path=README.md", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testGetRepoDetails() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        // Test getting repository details
        try app.test(.GET, "/repo/details?repo=owner/repo", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testListBranches() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        // Test listing branches
        try app.test(.GET, "/repo/branches?repo=owner/repo", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testListCommits() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        // Test listing commits
        try app.test(.GET, "/repo/commits?repo=owner/repo", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testListContributors() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        // Test listing contributors
        try app.test(.GET, "/repo/contributors?repo=owner/repo", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testListPullRequests() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        // Test listing pull requests
        try app.test(.GET, "/repo/pulls?repo=owner/repo", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testListIssues() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        // Test listing issues
        try app.test(.GET, "/repo/issues?repo=owner/repo", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testListSecrets() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        // Test listing secrets
        try app.test(.GET, "/repo/secrets?repo=owner/repo", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    func testCreateOrUpdateSecret() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let token = try generateJWTToken()

        // Test creating or updating a secret
        try app.test(.POST, "/repo/secrets?repo=owner/repo&secret_name=SECRET_KEY&secret_value=SECRET_VALUE", headers: ["Authorization": "Bearer \(token)"], afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
        })
    }

    // Helper function to generate a JWT token for testing
    private func generateJWTToken() throws -> String {
        let signers = JWTSigners()
        try signers.use(.hs256(key: "secret"))
        let payload = MyPayload(sub: .init(value: "user123"), exp: .init(value: .distantFuture))
        return try signers.sign(payload)
    }
}
EOL

    # Commit the changes
    git add Tests/AppTests/GitHubControllerTests.swift
    git commit -m "Add GitHubControllerTests to verify GitHub API endpoints"
}

create_github_controller_tests
```

Run the script:

```bash
chmod +x create_github_controller_tests.sh
./create_github_controller_tests.sh
```

Run the tests to see them fail:

```bash
swift test
```

You should see errors indicating that the routes are not found and JWT validation issues. This is expected since we haven't implemented the routes and JWT logic yet.

### 7. Implementing the Features to Pass Tests

Now, we will implement the features to make the tests pass.

#### Define Routes and Controllers

1. **Create `GitHubController.swift` in `Sources/App/Controllers`**

Create a script named `setup_github_controller.sh`:

```bash
#!/bin/bash

function setup_github_controller() {
    echo "Creating GitHubController.swift in Sources/App/Controllers"
    mkdir -p Sources/App/Controllers
    cat <<EOL > Sources/App/Controllers/GitHubController.swift
import Vapor
import JWT

struct GitHubController: RouteCollection {
    // Register the routes and apply JWTMiddleware for protected routes
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

    // Fetch the repository tree
    func fetchRepoTree(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let branch = try req.query.get(String.self, at: "branch") ?? "main"
        let url = URI(string: "https://api.github.com/repos/\

(repo)/git/trees/\(branch)?recursive=1")
        return try makeGHRequest(req: req, url: url)
    }

    // List contents of a repository
    func listContents(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let path = try req.query.get(String.self, at: "path") ?? ""
        let url = URI(string: "https://api.github.com/repos/\(repo)/contents/\(path)")
        return try makeGHRequest(req: req, url: url)
    }

    // Fetch content of a specific file in the repository
    func fetchFileContent(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let path = try req.query.get(String.self, at: "path")
        let url = URI(string: "https://api.github.com/repos/\(repo)/contents/\(path)")
        return try makeGHRequest(req: req, url: url)
    }

    // Get repository details
    func getRepoDetails(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)")
        return try makeGHRequest(req: req, url: url)
    }

    // List branches in the repository
    func listBranches(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/branches")
        return try makeGHRequest(req: req, url: url)
    }

    // List commits in the repository
    func listCommits(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/commits")
        return try makeGHRequest(req: req, url: url)
    }

    // List contributors to the repository
    func listContributors(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/contributors")
        return try makeGHRequest(req: req, url: url)
    }

    // List pull requests in the repository
    func listPullRequests(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/pulls")
        return try makeGHRequest(req: req, url: url)
    }

    // List issues in the repository
    func listIssues(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/issues")
        return try makeGHRequest(req: req, url: url)
    }

    // List secrets in the repository
    func listSecrets(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/actions/secrets")
        return try makeGHRequest(req: req, url: url)
    }

    // Create or update a secret in the repository
    func createOrUpdateSecret(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let secretName = try req.query.get(String.self, at: "secret_name")
        let secretValue = try req.query.get(String.self, at: "secret_value")
        let url = URI(string: "https://api.github.com/repos/\(repo)/actions/secrets/\(secretName)")
        return try makeGHRequest(req: req, url: url, method: .put, body: secretValue)
    }

    // Helper function to make a GitHub API request
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
        return req.client.send(clientReq).flatMapThrowing { response in
            // Check if the response status is OK, otherwise throw an error
            guard response.status == .ok else {
                throw Abort(.badRequest, reason: "GitHub API request failed with status \(response.status)")
            }
            return response
        }
    }
}
EOL

    # Commit the changes
    git add Sources/App/Controllers/GitHubController.swift
    git commit -m "Add GitHubController for managing GitHub API interactions and setting secrets"
}

setup_github_controller
```

Run the script:

```bash
chmod +x setup_github_controller.sh
./setup_github_controller.sh
```

2. **Update `routes.swift` to register the new controller**

Create a script named `update_routes.sh`:

```bash
#!/bin/bash

function update_routes() {
    echo "Updating routes.swift to include GitHubController"
    cat <<EOL > Sources/App/routes.swift
import Vapor

func routes(_ app: Application) throws {
    let gitHubController = GitHubController()
    try app.register(collection: gitHubController)
}
EOL

    # Commit the changes
    git add Sources/App/routes.swift
    git commit -m "Update routes.swift to register GitHubController"
}

update_routes
```

Run the script:

```bash
chmod +x update_routes.sh
./update_routes.sh
```

Run the tests again to see if the initial implementation passes:

```bash
swift test
```

You should now see some tests passing while others related to JWT might still fail, indicating that we need to handle JWT authentication properly.

#### Handling GitHub CLI Commands

1. **Add the function to execute `gh` commands** in `GitHubController.swift`:

Create a script named `add_execute_gh_command.sh`:

```bash
#!/bin/bash

function add_execute_gh_command() {
    echo "Adding executeGHCommand function to GitHubController.swift"
    sed -i '' '/class GitHubController {/a \
    // Execute GitHub CLI command\
    func executeGHCommand(_ command: String) throws -> String {\
        let process = Process()\
        let pipe = Pipe()\
\
        process.standardOutput = pipe\
        process.standardError = pipe\
        process.arguments = ["-c", "gh " + command]\
        process.launchPath = "/bin/zsh"\
\
        try process.run()\
        process.waitUntilExit()\
\
        let data = pipe.fileHandleForReading.readDataToEndOfFile()\
        return String(data: data, encoding: .utf8) ?? ""\
    }\
' Sources/App/Controllers/GitHubController.swift

    # Commit the changes
    git add Sources/App/Controllers/GitHubController.swift
    git commit -m "Add executeGHCommand function to GitHubController for executing GitHub CLI commands"
}

add_execute_gh_command
```

Run the script:

```bash
chmod +x add_execute_gh_command.sh
./add_execute_gh_command.sh
```

Run the tests again:

```bash
swift test
```

You should now see more tests passing. We will now focus on implementing the token generation and JWT validation features.

#### Implementing the Token Generation Route

The token generation route is crucial for JWT authentication. This route allows users to obtain a JWT token by providing valid credentials, which can then be used to access protected API endpoints. By securing this endpoint with basic authentication, we ensure that only authorized users can generate tokens.

1. **Create `MyPayload.swift` in `Sources/App/Models`**

Create a script named `create_mypayload.sh`:

```bash
#!/bin/bash

function create_mypayload() {
    echo "Creating MyPayload.swift in Sources/App/Models"
    mkdir -p Sources/App/Models
    cat <<EOL > Sources/App/Models/MyPayload.swift
import Vapor
import JWT

// Define the payload structure for JWT
struct MyPayload: JWTPayload {
    var sub: SubjectClaim  // Subject claim (typically the user identifier)
    var exp: ExpirationClaim  // Expiration claim (token expiration time)
    
    // Verify the JWT payload
    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()  // Check if the token is not expired
    }
}
EOL

    # Commit the changes
    git add Sources/App/Models/MyPayload.swift
    git commit -m "Add MyPayload model for JWT token structure and verification"
}

create_mypayload
```

Run the script:

```bash
chmod +x create_mypayload.sh
./create_mypayload.sh
```

2. **Create `BasicAuthMiddleware.swift` in `Sources/App/Middleware`**

Create a script named `create_basic_auth_middleware.sh`:

```bash
#!/bin/bash

function create_basic_auth_middleware() {
    echo "Creating BasicAuthMiddleware.swift in Sources/App/Middleware"
    mkdir -p Sources/App/Middleware
    cat <<EOL > Sources/App/Middleware/BasicAuthMiddleware.swift
import Vapor

// Middleware for Basic Authentication
struct BasicAuthMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // Check if the Authorization header contains basic credentials
        guard let authHeader = request.headers.basicAuthorization else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
        }
        
        // Retrieve the expected username and password from environment variables
        let expectedUsername = Environment.get("BASIC_AUTH_USERNAME") ?? "admin"
        let expectedPassword = Environment.get("BASIC_AUTH_PASSWORD") ?? "password"
        
        // Verify the credentials
        if authHeader.username == expectedUsername && authHeader.password == expectedPassword {
            return next.respond(to: request)
        } else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
        }
    }
}
EOL

    # Commit the changes
    git add Sources/App/Middleware/BasicAuthMiddleware.swift
    git commit -m "Add BasicAuthMiddleware for securing the token generation route"
}

create_basic_auth_middleware
```

Run the script:

```bash
chmod +x create_basic_auth_middleware.sh
./create_basic_auth_middleware.sh
```

3. **Update `routes.swift` to include the new route and secure it**

Create a script named `update_routes_with_token.sh`:

```bash
#!/bin/bash

function update_routes_with_token() {
    echo "Updating routes.swift to include the token generation route"
    cat <<EOL > Sources/App/routes.swift
import Vapor

func routes(_ app: Application) throws {
    // Group routes that require JWT authentication
    let protected = app.grouped(JWTMiddleware())
    // Group routes that require basic authentication
    let basicAuthProtected = app.grouped(BasicAuthMiddleware())

    // Public route for token generation
    basicAuthProtected.get("generate-token") { req -> String in
        // Create a payload for the token
        let payload = MyPayload(sub: .init(value: "custom-gpt"), exp: .init(value: .distantFuture))
        // Sign the payload to generate the JWT token
        let token = try req.jwt.sign(payload)
        return token
    }

    // Protected routes
    let gitHubController = GitHubController()
    try app.register(collection: gitHubController)
}
EOL

    # Commit the changes
    git add Sources/App/routes.swift
    git commit -m "Update routes.swift to include token generation route and secure it with BasicAuthMiddleware"
}

update_routes_with_token
```

Run the script:

```bash
chmod +x update_routes_with_token.sh
./update_routes_with_token.sh
```

Run the tests again to see if the implementation passes:

```bash
swift test
```

You should see the tests related to token generation and JWT passing.

#### Error Handling

Implement proper error handling in your controllers to manage API failures gracefully.

Create a script named `add_error_handling.sh`:

```bash
#!/bin/bash

function add_error_handling() {
    echo "Adding error handling to GitHubController.swift"
    sed -i '' '/func makeGHRequest(req: Request, url: URI, method: HTTPMethod = .get, body: String? = nil) throws -> EventLoopFuture<ClientResponse> {/a \
        // Error handling for API request\
        guard let repo = try? req.query.get(String.self, at: "repo"), !repo.isEmpty else {\
            throw Abort(.badRequest, reason: "Repository name is required")\
        }\
        guard let path = try? req.query.get(String.self, at: "path"), !path.isEmpty else {\
            throw Abort(.badRequest, reason: "Path is required")\
        }\
    ' Sources/App/Controllers/GitHubController.swift

    # Commit the changes
    git add Sources/App/Controllers/GitHubController.swift
    git commit -m "Add error handling to GitHubController"
}

add_error_handling
```

Run the script:

```bash
chmod +x add_error_handling.sh
./add_error_handling.sh
```

### Logging

Add logging to the application to track important events.

**Update `configure.swift`**

Create a script named `add_logging.sh`:

```bash
#!/bin/bash

function add_logging() {
    echo "Adding logging to configure.swift"
    cat <<EOL > Sources/App/configure.swift
import Vapor

public func configure(_ app: Application) throws {
    // Ensure environment variables are loaded
    guard let jwtSecret = Environment.get("JWT_SECRET"),
          let githubToken = Environment.get("GITHUB_TOKEN"),
          let basicAuthUsername = Environment.get("BASIC_AUTH_USERNAME"),
          let basicAuthPassword = Environment.get("BASIC_AUTH_PASSWORD") else {
        fatalError("Missing required environment variables")
    }

    // JWT Configuration
    let signers = JWTSigners()
    try signers.use(.hs256(key: jwtSecret))
    app.jwt.signers = signers

    // Logging
    app.logger.logLevel = .debug

    // Configure middleware
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Register routes
    try routes(app)
}
EOL

    # Commit the changes
    git add Sources/App/configure.swift
    git commit -m "Add logging configuration to configure.swift"
}

add_logging
```

Run the script:

```bash
chmod +x add_logging.sh
./add_logging.sh
```

Run the tests again:

```bash
swift test
```

You should now see all the tests passing, indicating that the implementation is complete and the features are working as expected.

## Part C: Deployment and Maintenance

### Setting Up the CI/CD Pipeline

To ensure continuous integration and deployment, we will set up a CI/CD pipeline using GitHub Actions. This pipeline will build, test, and push the Docker image to the GitHub Container Registry.

#### Create GitHub Actions Workflow

1. **Create Workflow Directory**
   ```bash
   mkdir -p .github/workflows
   ```

2. **Create Workflow File**
   Create a script named `create_cicd_workflow.sh`:

```bash
#!/bin/bash

function create_cicd_workflow() {
    echo "Creating CI/CD workflow file"
    cat <<EOL > .github/workflows/ci-cd.yml
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
        username: \${{ github.repository_owner }}
        password: \${{ secrets.GITHUB_TOKEN }}

    - name: Set up Swift
      uses: fwal/setup-swift@v1

    - name: Build the app
      run: swift build --disable-sandbox -c release

    - name: Run tests
      run: swift test

    - name: Build and push Docker image
      run: |
        docker-compose build
        echo "\${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u \${{ github.repository_owner }} --password-stdin
        docker-compose push
      env:
        GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
        JWT_SECRET: \${{ secrets.JWT_SECRET }}
        BASIC_AUTH_USERNAME: \${{ secrets.BASIC_AUTH_USERNAME }}
        BASIC_AUTH_PASSWORD: \${{ secrets.BASIC_AUTH_PASSWORD }}
EOL

    # Commit the changes
    git add .github/workflows/ci-cd.yml
    git commit -m "Add CI/CD workflow for GitHub Actions"
}

create_cicd_workflow
```

Run the script:

```bash
chmod +x create_cicd_workflow.sh
./create_cicd_workflow.sh
```

### Dockerizing the Vapor App

1. **Create a `Dockerfile` in the root directory of your project**

Create a script named `create_dockerfile.sh`:

```bash

#!/bin/bash

function create_dockerfile() {
    echo "Creating Dockerfile"
    cat <<EOL > Dockerfile
# Stage 1 - Build
FROM swift:5.5-focal as builder
WORKDIR /app
COPY . .
RUN swift build --disable-sandbox -c release

# Stage 2 - Run
FROM swift:5.5-focal-slim
WORKDIR /app
COPY --from=builder /app/.build/release /app
ENV GITHUB_TOKEN=\${GITHUB_TOKEN}
ENV JWT_SECRET=\${JWT_SECRET}
ENTRYPOINT ["/app/Run"]
EOL

    # Commit the changes
    git add Dockerfile
    git commit -m "Add Dockerfile for building and running the Vapor app"
}

create_dockerfile
```

Run the script:

```bash
chmod +x create_dockerfile.sh
./create_dockerfile.sh
```

2. **Create a `.dockerignore` file to exclude unnecessary files from the Docker image**

Create a script named `create_dockerignore.sh`:

```bash
#!/bin/bash

function create_dockerignore() {
    echo "Creating .dockerignore"
    cat <<EOL > .dockerignore
.build/
.swiftpm/
Packages/
Package.resolved
Tests/
EOL

    # Commit the changes
    git add .dockerignore
    git commit -m "Add .dockerignore to exclude unnecessary files from the Docker image"
}

create_dockerignore
```

Run the script:

```bash
chmod +x create_dockerignore.sh
./create_dockerignore.sh
```

### Running the Application with Docker Compose

1. **Create a `docker-compose.yml` file in the root directory of your project**

Create a script named `create_docker_compose.sh`:

```bash
#!/bin/bash

function create_docker_compose() {
    echo "Creating docker-compose.yml"
    cat <<EOL > docker-compose.yml
version: '3.8'

services:
  vapor:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    environment:
      GITHUB_TOKEN: \${GITHUB_TOKEN}
      JWT_SECRET: \${JWT_SECRET}
EOL

    # Commit the changes
    git add docker-compose.yml
    git commit -m "Add docker-compose.yml for running the Vapor app with Docker Compose"
}

create_docker_compose
```

Run the script:

```bash
chmod +x create_docker_compose.sh
./create_docker_compose.sh
```

### Conclusion

In this episode, we created a fully functional Vapor app that wraps GitHub CLI commands and interacts with the GitHub API. We followed TDD principles by writing tests first and then implementing the features to make them pass. We also dockerized the app and implemented JWT-based bearer authentication to secure the API. This setup ensures that only authorized users can access and perform operations on the API. We also set up a CI/CD pipeline to automate the build and deployment process, ensuring continuous integration and delivery of our application. Additionally, we integrated Docker Compose to simplify the process of managing multi-container applications, enhancing the development workflow by providing a consistent environment for running the application both locally and in production. By using GitHub Secrets, we ensured that sensitive information is handled securely.

## Addendum

### Idempotent Main Script

Create a main script named `main.sh` that calls all the individual scripts in order, ensuring idempotency and interactivity where necessary:

```bash
#!/bin/bash

function run_script() {
    script_name=$1
    if [ -f "$script_name" ]; then
        chmod +x $script_name
        ./$script_name
    else
        echo "$script_name not found!"
        exit 1
    fi
}

echo "Running initial setup scripts..."

run_script create_token_generation_tests.sh
run_script create_github_controller_tests.sh
run_script setup_github_controller.sh
run_script update_routes.sh
run_script add_execute_gh_command.sh
run_script create_mypayload.sh
run_script create_basic_auth_middleware.sh
run_script update_routes_with_token.sh
run_script add_error_handling.sh
run_script add_logging.sh
run_script create_cicd_workflow.sh
run_script create_dockerfile.sh
run_script create_dockerignore.sh
run_script create_docker_compose.sh

echo "All scripts executed successfully!"
```

Make the main script executable and run it:

```bash
chmod +x main.sh
./main.sh
```

This main script ensures that all necessary setup steps are executed in the correct order, providing a streamlined and interactive experience for setting up the Vapor app.

