### `episodes/episode3.md`

# Episode 3: Enhancing Security for Your OpenAPI-based Vapor Wrapper App around "gh"

## Table of Contents

**Part A: Introduction and Security Requirements**

1. [Introduction](#introduction)
2. [Security Requirements](#security-requirements)
   - [Avoid Hardcoding Credentials and Secrets](#avoid-hardcoding-credentials-and-secrets)
   - [Secure JWT Secret Management](#secure-jwt-secret-management)
   - [Implement Token Expiry and Scope](#implement-token-expiry-and-scope)
   - [Use Strong Basic Authentication](#use-strong-basic-authentication)

**Part B: Implementing Security Enhancements**

3. [Protect Routes with JWT Middleware](#protect-routes-with-jwt-middleware)
4. [Comprehensive Error Handling and Logging](#comprehensive-error-handling-and-logging)
5. [GitHub Actions Security](#github-actions-security)
6. [Docker Security](#docker-security)
7. [Network Security](#network-security)
8. [Implementing Static Code Analysis](#implementing-static-code-analysis)
9. [Setting Up GitHub Monitoring and Alerts](#setting-up-github-monitoring-and-alerts)
10. [Patching the Project](#patching-the-project)

**Conclusion**

11. [Conclusion](#conclusion)

## Part A: Introduction and Security Requirements

### 1. Introduction

In this episode, we will enhance the security of our Vapor app that wraps the GitHub CLI (`gh`). This app provides a web interface for interacting with GitHub repositories, including listing contents, fetching file contents, and managing GitHub secrets. We'll focus on securing the app using best practices, including managing sensitive information, implementing robust authentication and authorization, improving error handling and logging, and securing the deployment pipeline.

### 2. Security Requirements

#### Avoid Hardcoding Credentials and Secrets

Ensure all sensitive information such as GitHub tokens, JWT secrets, and basic authentication credentials are managed using environment variables and GitHub Secrets.

#### Secure JWT Secret Management

Generate a secure random key for the JWT secret using tools like OpenSSL and store it using a secret management service.

```bash
openssl rand -base64 32
```

#### Implement Token Expiry and Scope

Ensure JWT tokens have a defined expiry time to minimize risks associated with token theft. Assign minimal permissions required for the tokens to limit potential damage in case of compromise.

#### Use Strong Basic Authentication

Employ strong, randomly generated passwords for basic authentication and manage them securely using a secret manager.

## Part B: Implementing Security Enhancements

### 3. Protect Routes with JWT Middleware

Ensure all routes that need to be secured are protected using JWT middleware to prevent unauthorized access.

**File:** `Sources/App/routes.swift`

```swift
import Vapor

func routes(_ app: Application) throws {
    let protected = app.grouped(JWTMiddleware())
    let gitHubController = GitHubController()
    try protected.register(collection: gitHubController)
}
```

### 4. Comprehensive Error Handling and Logging

Implement proper error handling to ensure API failures are managed gracefully without exposing sensitive information. Avoid logging sensitive information such as tokens, passwords, or user data.

**File:** `Sources/App/Controllers/GitHubController.swift`

```swift
import Vapor

struct GitHubController: RouteCollection {
    // This function registers all the routes for the GitHubController
    func boot(routes: RoutesBuilder) throws {
        // Group all routes under "repo" and protect them with JWT middleware
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

    // Function to make a GitHub API request
    func makeGHRequest(req: Request, url: URI, method: HTTPMethod = .get, body: String? = nil) throws -> EventLoopFuture<ClientResponse> {
        var headers = HTTPHeaders()
        // Adding the GitHub token to the request headers for authentication
        headers.add(name: .authorization, value: "Bearer \(Environment.get("GH_TOKEN")!)")
        headers.add(name: .userAgent, value: "VaporApp")
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        // Creating the client request with the necessary headers and body
        let clientReq = ClientRequest(
            method: method,
            url: url,
            headers: headers,
            body: body != nil ? .init(string: body!) : nil
        )
        return req.client.send(clientReq).flatMapThrowing { response in
            // Check if the response status is OK, otherwise throw an error
            guard response.status == .ok else {
                // Log the error without exposing sensitive information
                req.logger.error("GitHub API request failed with status \(response.status)")
                throw Abort(.badRequest, reason: "GitHub API request failed with status \(response.status)")
            }
            return response
        }
    }
    
    // Function to fetch the repository tree
    func fetchRepoTree(req: Request) throws -> EventLoopFuture<ClientResponse> {
        // Constructing the GitHub API URL to fetch the repository tree
        let repo = try req.query.get(String.self, at: "repo")
        let branch = try req.query.get(String.self, at: "branch") ?? "main"
        let url = URI(string: "https://api.github.com/repos/\(repo)/git/trees/\(branch)?recursive=1")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to list contents of a repository
    func listContents(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let path = try req.query.get(String.self, at: "path") ?? ""
        let url = URI(string: "https://api.github.com/repos/\(repo)/contents/\(path)")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to fetch the content of a file
    func fetchFileContent(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let path = try req.query.get(String.self, at: "path")
        let url = URI(string: "https://api.github.com/repos/\(repo)/contents/\(path)")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to get repository details
    func getRepoDetails(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to list branches of a repository
    func listBranches(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/branches")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to list commits of a repository
    func listCommits(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/commits")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to list contributors to a repository
    func listContributors(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/contributors")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to list pull requests of a repository
    func listPullRequests(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/pulls")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to list issues of a repository
    func listIssues(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/issues")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to list secrets of a repository
    func listSecrets(req: Request) throws ->

 EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/actions/secrets")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to create or update a secret in a repository
    func createOrUpdateSecret(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let secretName = try req.query.get(String.self, at: "secret_name")
        let secretValue = try req.query.get(String.self, at: "secret_value")
        let url = URI(string: "https://api.github.com/repos/\(repo)/actions/secrets/\(secretName)")
        return try makeGHRequest(req: req, url: url, method: .put, body: secretValue)
    }
}
```

### 5. GitHub Actions Security

Limit permissions of the `GH_TOKEN` used in GitHub Actions. Use GitHub Secrets for securely storing sensitive information and ensure these secrets are not exposed in logs.

**File:** `.github/workflows/ci-cd.yml`

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
        password: ${{ secrets.GH_TOKEN }}

    - name: Set up Swift
      uses: fwal/setup-swift@v1

    - name: Build the app
      run: swift build --disable-sandbox -c release

    - name: Run tests
      run: swift test

    - name: Build and push Docker image
      run: |
        docker-compose build
        echo "${{ secrets.GH_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin
        docker-compose push
      env:
        GH_TOKEN: ${{ secrets.GH_TOKEN }}
        JWT_SECRET: ${{ secrets.JWT_SECRET }}
        BASIC_AUTH_USERNAME: ${{ secrets.BASIC_AUTH_USERNAME }}
        BASIC_AUTH_PASSWORD: ${{ secrets.BASIC_AUTH_PASSWORD }}
```

### 6. Docker Security

Use the smallest possible base image to minimize the attack surface. Run the application as a non-root user inside the Docker container.

**File:** `Dockerfile`

```dockerfile
FROM swift:5.5-focal-slim
WORKDIR /app
COPY --from=builder /app/.build/release /app
USER appuser
ENTRYPOINT ["/app/Run"]
```

### 7. Network Security

Protect API endpoints behind a firewall or use network policies to restrict access to trusted sources. Use HTTPS to encrypt data in transit.

### 8. Implementing Static Code Analysis

Use static code analysis tools to automatically detect and address security issues in the codebase.

1. **SwiftLint**: A tool to enforce Swift style and conventions, helping to avoid common coding issues.

**File:** `.github/workflows/swiftlint.yml`

```yaml
name: SwiftLint

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  lint:
    runs-on: macos-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Install SwiftLint
      run: brew install swiftlint

    - name: Run SwiftLint
      run: swiftlint
```

2. **SonarQube**: A tool to analyze code quality and security for multiple programming languages.

```bash
# Example command for running SonarQube analysis
sonar-scanner
```

### 9. Setting Up GitHub Monitoring and Alerts

Implement logging and monitoring to detect and respond to security incidents promptly using GitHub's built-in monitoring tools and services like GitHub Actions and GitHub Advanced Security.

1. **GitHub Advanced Security**:
   - Use GitHub Advanced Security features to monitor and scan your repositories for security vulnerabilities and issues.
   - Set up alerts and notifications for potential security incidents.

**File:** `.github/dependabot.yml`

```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
```

2. **GitHub Actions for Monitoring**:
   - Set up GitHub Actions workflows to run regular security scans and checks on your codebase.

**File:** `.github/workflows/security.yml`

```yaml
name: Security Checks

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  security:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Run npm audit
      run: npm audit --audit-level=high

    - name: Set up Snyk
      uses: snyk/actions/setup@v2
      with:
        token: ${{ secrets.SNYK_TOKEN }}

    - name: Run Snyk test
      run: snyk test
```

### 10. Patching the Project

The following shell script will patch the project to match the security scan suggestions and create the necessary additional files while ensuring the controller remains functional.

```bash
#!/bin/bash

# Ensure the script stops on the first error encountered
set -e

# Function to patch existing files
patch_files() {
    echo "Patching existing files..."

    # Patch routes.swift to include JWT middleware
    if ! grep -q "let protected = app.grouped(JWTMiddleware())" Sources/App/routes.swift; then
        cat <<EOF > Sources/App/routes.swift
import Vapor

func routes(_ app: Application) throws {
    let protected = app.grouped(JWTMiddleware())
    let gitHubController = GitHubController()
    try protected.register(collection: gitHubController)
}
EOF
        echo "Patched Sources/App/routes.swift to include JWT middleware."
    else
        echo "JWT middleware already included in Sources/App/routes.swift."
    fi

    # Patch GitHubController.swift to enhance error handling and logging
    cat <<EOF > Sources/App/Controllers/GitHubController.swift
import Vapor

struct GitHubController: RouteCollection {
    // This function registers all the routes for the GitHubController
    func boot(routes: RoutesBuilder) throws {
        // Group all routes under "repo" and protect them with JWT middleware
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

    // Function to make a GitHub API request
    func makeGHRequest(req: Request, url: URI, method: HTTPMethod = .get, body: String? = nil) throws -> EventLoopFuture<ClientResponse> {
        var headers = HTTPHeaders()
        // Adding the GitHub token to the request headers for authentication
        headers.add(name: .authorization, value: "Bearer \(Environment.get("GH_TOKEN")!)")
        headers.add(name: .userAgent, value: "VaporApp")
        headers.add(name: .accept, value: "application/vnd.github.v3+json")

        // Creating the client request with the necessary headers and body
        let clientReq = ClientRequest(
            method: method,
            url: url,
            headers: headers,
            body: body != nil ? .init(string: body!) : nil
        )
        return req.client.send(clientReq).flatMapThrowing { response in
            // Check if the response status is OK, otherwise throw an error
            guard response.status == .ok else {
                // Log the error without exposing sensitive information
                req.logger.error("GitHub API request failed with status \(response.status)")
                throw Abort(.badRequest, reason: "GitHub API request failed with status \(response.status)")
            }
            return response
        }
    }
    
    // Function to fetch the repository tree
    func fetchRepoTree(req: Request) throws -> EventLoopFuture<ClientResponse> {
        // Constructing the GitHub API URL to fetch the repository tree
        let repo = try req.query.get(String.self, at: "repo")
        let branch = try req.query.get(String.self, at: "branch") ?? "main"
        let url = URI(string: "https://api.github.com/repos/\(repo)/git/trees/\(branch)?recursive=1")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to list contents of a repository
    func listContents(req: Request) throws -> EventLoopFuture<ClientResponse

> {
        let repo = try req.query.get(String.self, at: "repo")
        let path = try req.query.get(String.self, at: "path") ?? ""
        let url = URI(string: "https://api.github.com/repos/\(repo)/contents/\(path)")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to fetch the content of a file
    func fetchFileContent(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let path = try req.query.get(String.self, at: "path")
        let url = URI(string: "https://api.github.com/repos/\(repo)/contents/\(path)")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to get repository details
    func getRepoDetails(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to list branches of a repository
    func listBranches(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/branches")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to list commits of a repository
    func listCommits(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/commits")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to list contributors to a repository
    func listContributors(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/contributors")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to list pull requests of a repository
    func listPullRequests(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/pulls")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to list issues of a repository
    func listIssues(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/issues")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to list secrets of a repository
    func listSecrets(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let url = URI(string: "https://api.github.com/repos/\(repo)/actions/secrets")
        return try makeGHRequest(req: req, url: url)
    }

    // Function to create or update a secret in a repository
    func createOrUpdateSecret(req: Request) throws -> EventLoopFuture<ClientResponse> {
        let repo = try req.query.get(String.self, at: "repo")
        let secretName = try req.query.get(String.self, at: "secret_name")
        let secretValue = try req.query.get(String.self, at: "secret_value")
        let url = URI(string: "https://api.github.com/repos/\(repo)/actions/secrets/\(secretName)")
        return try makeGHRequest(req: req, url: url, method: .put, body: secretValue)
    }
}
EOF

    echo "Patched Sources/App/Controllers/GitHubController.swift to enhance error handling and logging."
}

# Function to create new files
create_files() {
    echo "Creating new files..."

    # Create .github/workflows/ci-cd.yml
    mkdir -p .github/workflows
    cat <<EOF > .github/workflows/ci-cd.yml
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
        password: \${{ secrets.GH_TOKEN }}

    - name: Set up Swift
      uses: fwal/setup-swift@v1

    - name: Build the app
      run: swift build --disable-sandbox -c release

    - name: Run tests
      run: swift test

    - name: Build and push Docker image
      run: |
        docker-compose build
        echo "\${{ secrets.GH_TOKEN }}" | docker login ghcr.io -u \${{ github.repository_owner }} --password-stdin
        docker-compose push
      env:
        GH_TOKEN: \${{ secrets.GH_TOKEN }}
        JWT_SECRET: \${{ secrets.JWT_SECRET }}
        BASIC_AUTH_USERNAME: \${{ secrets.BASIC_AUTH_USERNAME }}
        BASIC_AUTH_PASSWORD: \${{ secrets.BASIC_AUTH_PASSWORD }}
EOF

    echo "Created .github/workflows/ci-cd.yml."

    # Create .github/workflows/security.yml
    cat <<EOF > .github/workflows/security.yml
name: Security Checks

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  security:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Run npm audit
      run: npm audit --audit-level=high

    - name: Set up Snyk
      uses: snyk/actions/setup@v2
      with:
        token: \${{ secrets.SNYK_TOKEN }}

    - name: Run Snyk test
      run: snyk test
EOF

    echo "Created .github/workflows/security.yml."

    # Create .github/workflows/swiftlint.yml
    cat <<EOF > .github/workflows/swiftlint.yml
name: SwiftLint

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  lint:
    runs-on: macos-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Install SwiftLint
      run: brew install swiftlint

    - name: Run SwiftLint
      run: swiftlint
EOF

    echo "Created .github/workflows/swiftlint.yml."

    # Create .github/dependabot.yml
    cat <<EOF > .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
EOF

    echo "Created .github/dependabot.yml."
}

# Main function to execute all steps
main() {
    patch_files
    create_files

    # Commit the changes with a comprehensive message
    git add .
    git commit -m "Enhance security for the Vapor app:
- Add JWT middleware to routes
- Improve error handling and logging in GitHubController
- Set up GitHub Actions workflows for CI/CD, security scans, and SwiftLint
- Configure Dependabot for dependency updates"
}

main
```

## Conclusion

Using GitHub Secrets as a security manager is a valid and secure approach for managing sensitive information in GitHub repositories. By managing sensitive information securely, implementing robust authentication and authorization mechanisms, following secure coding practices, and ensuring secure deployment and CI/CD processes, the app can be protected from unauthorized access and potential misuse. Continuous monitoring and static analysis further enhance the security posture of the application, providing an additional layer of defense against emerging threats. This approach provides a secure, integrated solution for managing secrets in CI/CD workflows and enhancing overall security posture.