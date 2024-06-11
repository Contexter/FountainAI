## Technical Paper: FountainAI Secrets Manager with CI/CD Workflow Generator

### Abstract

This paper presents the design and implementation of the FountainAI Secrets Manager, a Vapor-based application that integrates GitHub secrets management and CI/CD workflow generation. This application provides a comprehensive solution for securely managing secrets and automating CI/CD processes for multiple Vapor applications.

### Introduction

In modern software development, managing secrets securely and automating CI/CD pipelines are critical for maintaining the integrity and efficiency of the development lifecycle. The FountainAI Secrets Manager addresses these needs by offering a centralized service for secrets management and dynamic CI/CD workflow generation using GitHub Actions.

### System Design

#### Overview

The FountainAI Secrets Manager is built using Vapor, a web framework for Swift. The application consists of the following key components:

- **Secrets Management**: Allows creating, retrieving, updating, and deleting secrets in GitHub repositories.
- **CI/CD Workflow Generator**: Dynamically generates GitHub Actions workflow configuration files based on application configurations.
- **VPS Verification**: Ensures the VPS meets the necessary requirements before deployment.

#### OpenAPI Specification

The API is defined using OpenAPI, ensuring that the endpoints are well-documented and easily consumable by clients.

### OpenAPI Specification

```yaml
openapi: 3.0.1
info:
  title: FountainAI Secrets Manager API
  description: API for managing GitHub secrets, generating CI/CD workflows, and verifying VPS requirements.
  version: "1.0.0"
servers:
  - url: 'https://secrets.fountain.coach'
    description: Main server for Secrets Manager API services
  - url: 'http://localhost:8080'
    description: Development server for Secrets Manager API services
paths:
  /secrets:
    post:
      summary: Create or Update GitHub Secret
      operationId: createOrUpdateSecret
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/SecretCreateRequest'
      responses:
        '200':
          description: Secret successfully created or updated
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SecretResponse'
  /secrets/{repoOwner}/{repoName}/{secretName}:
    get:
      summary: Retrieve a GitHub Secret
      operationId: getSecret
      parameters:
        - name: repoOwner
          in: path
          required: true
          schema:
            type: string
        - name: repoName
          in: path
          required: true
          schema:
            type: string
        - name: secretName
          in: path
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Secret details
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Secret'
    delete:
      summary: Delete a GitHub Secret
      operationId: deleteSecret
      parameters:
        - name: repoOwner
          in: path
          required: true
          schema:
            type: string
        - name: repoName
          in: path
          required: true
          schema:
            type: string
        - name: secretName
          in: path
          required: true
          schema:
            type: string
      responses:
        '204':
          description: Secret successfully deleted
  /secrets/generate-cicd-workflow:
    post:
      summary: Generate CI/CD Workflow
      operationId: generateCICDWorkflow
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CICDWorkflowRequest'
      responses:
        '200':
          description: CI/CD workflow configuration generated
          content:
            application/json:
              schema:
                type: string
                example: |
                  name: CI/CD Pipeline for FountainAI
                  on:
                    push:
                      branches:
                        - main
                  jobs:
                    ...
  /vps/verify:
    post:
      summary: Verify VPS Requirements
      operationId: verifyVPS
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/VPSVerificationRequest'
      responses:
        '200':
          description: VPS verification results
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/VPSVerificationResponse'
components:
  schemas:
    SecretCreateRequest:
      type: object
      properties:
        repoOwner:
          type: string
        repoName:
          type: string
        secretName:
          type: string
        secretValue:
          type: string
      required:
        - repoOwner
        - repoName
        - secretName
        - secretValue
    SecretResponse:
      type: object
      properties:
        message:
          type: string
    Secret:
      type: object
      properties:
        repoOwner:
          type: string
        repoName:
          type: string
        secretName:
          type: string
        secretValue:
          type: string
    CICDWorkflowRequest:
      type: object
      properties:
        apps:
          type: array
          items:
            $ref: '#/components/schemas/AppConfig'
        githubRepositoryOwner:
          type: string
        githubRepositoryName:
          type: string
      required:
        - apps
        - githubRepositoryOwner
        - githubRepositoryName
    AppConfig:
      type: object
      properties:
        name:
          type: string
        secrets:
          type: object
          additionalProperties:
            type: string
      required:
        - name
        - secrets
    VPSVerificationRequest:
      type: object
      properties:
        vpsUsername:
          type: string
        vpsIP:
          type: string
      required:
        - vpsUsername
        - vpsIP
    VPSVerificationResponse:
      type: object
      properties:
        results:
          type: array
          items:
            $ref: '#/components/schemas/VPSVerificationResult'
    VPSVerificationResult:
      type: object
      properties:
        requirement:
          type: string
        status:
          type: string
```

### Implementation

#### 1. Setting up the Vapor Project

First, create a new Vapor project.

```bash
vapor new FountainAISecretsManager --branch=main
cd FountainAISecretsManager
```

#### 2. Models

Create models for handling secrets, CI/CD workflow requests, and VPS verification.

**Models/SecretCreateRequest.swift**

```swift
import Vapor

struct SecretCreateRequest: Content {
    let repoOwner: String
    let repoName: String
    let secretName: String
    let secretValue: String
}

struct SecretResponse: Content {
    let message: String
}

struct Secret: Content {
    let repoOwner: String
    let repoName: String
    let secretName: String
    let secretValue: String
}
```

**Models/CICDWorkflowRequest.swift**

```swift
import Vapor

struct CICDWorkflowRequest: Content {
    let apps: [AppConfig]
    let githubRepositoryOwner: String
    let githubRepositoryName: String
}

struct AppConfig: Content {
    let name: String
    let secrets: [String: String]
}
```

**Models/VPSVerificationRequest.swift**

```swift
import Vapor

struct VPSVerificationRequest: Content {
    let vpsUsername: String
    let vpsIP: String
}

struct VPSVerificationResponse: Content {
    let results: [VPSVerificationResult]
}

struct VPSVerificationResult: Content {
    let requirement: String
    let status: String
}
```

#### 3. Controllers

Create a controller to handle secrets management, CI/CD workflow generation, and VPS verification logic.

**Controllers/SecretsController.swift**

```swift
import Vapor
import Crypto

struct PublicKeyResponse: Content {
    let key: String
    let key_id: String
}

class SecretsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let secretsRoute = routes.grouped("secrets")
        secretsRoute.post(use: createOrUpdateSecret)
        secretsRoute.get(":repoOwner", ":repoName", ":secretName", use: getSecret)
        secretsRoute.delete(":repoOwner", ":repoName", ":secretName", use: deleteSecret)
        secretsRoute.post("generate-cicd-workflow", use: generateCICDWorkflow)
        
        let vpsRoute = routes.grouped("vps")
        vpsRoute.post("verify", use: verifyVPS)
    }

    // Endpoint to create or update a secret
    func createOrUpdateSecret(req: Request) throws -> EventLoopFuture<SecretResponse> {
        let createRequest = try req.content.decode(SecretCreateRequest.self)
        let githubToken = "YOUR_GITHUB_TOKEN"

        return getPublicKey(req: req, repoOwner: createRequest.repoOwner, repoName: createRequest.repoName, githubToken: githubToken).flatMap { publicKeyResponse in
            do {
                let encryptedValue = try self.encrypt(secret: createRequest.secretValue, publicKey: publicKeyResponse.key)
                return self.setSecret(req: req, repoOwner: createRequest.repoOwner, repoName: createRequest.repoName, secretName: createRequest.secretName, encryptedValue: encryptedValue, keyID: publicKeyResponse.key_id, githubToken: githubToken).map {
                    return SecretResponse(message: "Secret successfully created or updated.")
                }
            } catch {
                return req.eventLoop.future(error: error)
            }
        }
    }

    // Helper

 function to fetch the public key for the repository
    func getPublicKey(req: Request, repoOwner: String, repoName: String, githubToken: String) -> EventLoopFuture<PublicKeyResponse> {
        let url = "https://api.github.com/repos/\(repoOwner)/\(repoName)/actions/secrets/public-key"
        
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer \(githubToken)")
        headers.add(name: .userAgent, value: "Swift Vapor App")
        
        return req.client.get(URI(string: url), headers: headers).flatMapThrowing { response in
            guard response.status == .ok else {
                throw Abort(.internalServerError, reason: "Failed to fetch public key")
            }
            return try response.content.decode(PublicKeyResponse.self)
        }
    }

    // Helper function to encrypt a secret using the public key
    func encrypt(secret: String, publicKey: String) throws -> String {
        let publicKeyData = Data(base64Encoded: publicKey)!
        let secretData = secret.data(using: .utf8)!

        let sealedBox = try ChaChaPoly.seal(secretData, using: .publicKey(from: publicKeyData))
        return sealedBox.ciphertext.base64EncodedString()
    }

    // Helper function to set the secret in the GitHub repository
    func setSecret(req: Request, repoOwner: String, repoName: String, secretName: String, encryptedValue: String, keyID: String, githubToken: String) -> EventLoopFuture<Void> {
        let url = "https://api.github.com/repos/\(repoOwner)/\(repoName)/actions/secrets/\(secretName)"
        let secretRequest = ["encrypted_value": encryptedValue, "key_id": keyID]

        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer \(githubToken)")
        headers.add(name: .userAgent, value: "Swift Vapor App")
        headers.add(name: .contentType, value: "application/json")

        return req.client.put(URI(string: url), headers: headers) { req in
            try req.content.encode(secretRequest)
        }.transform(to: ())
    }

    // Endpoint to retrieve a secret
    func getSecret(req: Request) throws -> EventLoopFuture<Secret> {
        let repoOwner = try req.parameters.require("repoOwner")
        let repoName = try req.parameters.require("repoName")
        let secretName = try req.parameters.require("secretName")
        let githubToken = "YOUR_GITHUB_TOKEN"

        let url = "https://api.github.com/repos/\(repoOwner)/\(repoName)/actions/secrets/\(secretName)"
        
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer \(githubToken)")
        headers.add(name: .userAgent, value: "Swift Vapor App")

        return req.client.get(URI(string: url), headers: headers).flatMapThrowing { response in
            guard response.status == .ok else {
                throw Abort(.notFound, reason: "Secret not found")
            }
            return Secret(repoOwner: repoOwner, repoName: repoName, secretName: secretName, secretValue: "encrypted")
        }
    }

    // Endpoint to delete a secret
    func deleteSecret(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let repoOwner = try req.parameters.require("repoOwner")
        let repoName = try req.parameters.require("repoName")
        let secretName = try req.parameters.require("secretName")
        let githubToken = "YOUR_GITHUB_TOKEN"

        let url = "https://api.github.com/repos/\(repoOwner)/\(repoName)/actions/secrets/\(secretName)"
        
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer \(githubToken)")
        headers.add(name: .userAgent, value: "Swift Vapor App")

        return req.client.delete(URI(string: url), headers: headers).transform(to: .noContent)
    }

    // Endpoint to generate CI/CD workflow
    func generateCICDWorkflow(req: Request) throws -> EventLoopFuture<Response> {
        let cicdRequest = try req.content.decode(CICDWorkflowRequest.self)
        let workflowContent = generateWorkflowContent(request: cicdRequest)
        
        return req.eventLoop.future(Response(status: .ok, body: .init(string: workflowContent)))
    }

    // Helper function to generate the CI/CD workflow content
    private func generateWorkflowContent(request: CICDWorkflowRequest) -> String {
        var jobs = ""

        for app in request.apps {
            let envContent = generateEnvContent(appConfig: app)
            jobs += generateJobSection(appConfig: app, envContent: envContent, githubRepositoryOwner: request.githubRepositoryOwner)
        }

        return """
        name: CI/CD Pipeline for FountainAI

        on:
          push:
            branches:
              - main

        jobs:
        \(jobs)
        """
    }

    // Helper function to generate environment variable content
    private func generateEnvContent(appConfig: AppConfig) -> String {
        var content = ""
        for (key, value) in appConfig.secrets {
            content += "\(key)=${{ secrets.\(value) }}\n"
        }
        return content
    }

    // Helper function to generate job sections for CI/CD workflow
    private func generateJobSection(appConfig: AppConfig, envContent: String, githubRepositoryOwner: String) -> String {
        let appName = appConfig.name
        return """
        build-\(appName):
          runs-on: ubuntu-latest

          steps:
            - uses: actions/checkout@v2

            - name: Set up Docker Buildx
              uses: docker/setup-buildx-action@v1

            - name: Create .env file for \(appName)
              run: |
                echo "\(envContent)" > .env

            - name: Log in to GitHub Container Registry for \(appName)
              run: echo "${{ secrets.\(appName)_GHCR_TOKEN }}" | docker login ghcr.io -u \(githubRepositoryOwner) --password-stdin

            - name: Build and Push Docker Image for \(appName)
              run: |
                IMAGE_NAME=ghcr.io/\(githubRepositoryOwner)/\(appName)
                docker build -f Dockerfile.\(appName) -t $IMAGE_NAME .
                docker push $IMAGE_NAME

        unit-test-\(appName):
          needs: build-\(appName)
          runs-on: ubuntu-latest

          steps:
            - uses: actions/checkout@v2

            - name: Set up Docker Buildx
              uses: docker/setup-buildx-action@v1

            - name: Create .env file for \(appName)
              run: |
                echo "\(envContent)" > .env

            - name: Log in to GitHub Container Registry for \(appName)
              run: echo "${{ secrets.\(appName)_GHCR_TOKEN }}" | docker login ghcr.io -u \(githubRepositoryOwner) --password-stdin

            - name: Run Unit Tests for \(appName)
              run: |
                IMAGE_NAME=ghcr.io/\(githubRepositoryOwner)/\(appName)
                docker run --env-file .env $IMAGE_NAME swift test --disable-sandbox

        integration-test-\(appName):
          needs: build-\(appName)
          runs-on: ubuntu-latest

          steps:
            - uses: actions/checkout@v2

            - name: Set up Docker Buildx
              uses: docker/setup-buildx-action@v1

            - name: Create .env file for \(appName)
              run: |
                echo "\(envContent)" > .env

            - name: Log in to GitHub Container Registry for \(appName)
              run: echo "${{ secrets.\(appName)_GHCR_TOKEN }}" | docker login ghcr.io -u \(githubRepositoryOwner) --password-stdin

            - name: Run Integration Tests for \(appName)
              run: |
                IMAGE_NAME=ghcr.io/\(githubRepositoryOwner)/\(appName)
                docker run --env-file .env $IMAGE_NAME swift test --filter IntegrationTests --disable-sandbox

        end-to-end-test-\(appName):
          needs: integration-test-\(appName)
          runs-on: ubuntu-latest

          steps:
            - uses: actions/checkout@v2

            - name: Set up Docker Buildx
              uses: docker/setup-buildx-action@v1

            - name: Create .env file for \(appName)
              run: |
                echo "\(envContent)" > .env

            - name: Log in to GitHub Container Registry for \(appName)
              run: echo "${{ secrets.\(appName)_GHCR_TOKEN }}" | docker login ghcr.io -u \(githubRepositoryOwner) --password-stdin

            - name: Run End-to-End Tests for \(appName)
              run: |
                IMAGE_NAME=ghcr.io/\(githubRepositoryOwner)/\(appName)
                docker run --env-file .env $IMAGE_NAME swift test --filter EndToEndTests --disable-sandbox

        deploy-\(appName):
          needs: [unit-test-\(appName), integration-test-\(appName), end-to-end-test-\(appName)]
          runs-on: ubuntu-latest

          steps:
            - name: Set up SSH for \(appName)
              uses: webfactory/ssh-agent@v0.5.3
              with:
                ssh-private-key: "${{ secrets.\(appName)_VPS_SSH_KEY }}"

            - name:

 Deploy Docker Image to VPS for \(appName)
              run: |
                ssh ${{ secrets.\(appName)_VPS_USERNAME }}@${{ secrets.\(appName)_VPS_IP }} << 'EOF'
                IMAGE_NAME=ghcr.io/\(githubRepositoryOwner)/\(appName)
                docker pull $IMAGE_NAME
                docker stop \(appName) || true
                docker rm \(appName) || true
                docker run -d --env-file .env -p 8080:8080 --name \(appName) $IMAGE_NAME
                EOF

            - name: Verify Nginx and SSL Configuration for \(appName)
              run: |
                ssh ${{ secrets.\(appName)_VPS_USERNAME }}@${{ secrets.\(appName)_VPS_IP }} << 'EOF'
                if ! systemctl is-active --quiet nginx; then
                  echo "Nginx is not running"
                  exit 1
                fi

                if ! openssl s_client -connect ${{ secrets.\(appName)_DOMAIN_NAME }}:443 -servername ${{ secrets.\(appName)_DOMAIN_NAME }} </dev/null 2>/dev/null | openssl x509 -noout -dates; then
                  echo "SSL certificate is not valid"
                  exit 1
                fi

                if ! curl -k https://${{ secrets.\(appName)_DOMAIN_NAME }} | grep -q "Expected content or response"; then
                  echo "Domain is not properly configured"
                  exit 1
                fi
                EOF
        """
    }

    // Endpoint to verify VPS requirements
    func verifyVPS(req: Request) throws -> EventLoopFuture<VPSVerificationResponse> {
        let verificationRequest = try req.content.decode(VPSVerificationRequest.self)

        let sshCommand = "ssh \(verificationRequest.vpsUsername)@\(verificationRequest.vpsIP)"

        let requirements = [
            ("docker --version", "Docker"),
            ("docker-compose --version", "Docker Compose"),
            ("swift --version", "Swift"),
            ("systemctl is-active --quiet nginx", "Nginx"),
            ("systemctl is-active --quiet certbot", "Certbot")
        ]

        var results: [EventLoopFuture<VPSVerificationResult>] = []

        for (command, requirement) in requirements {
            let fullCommand = "\(sshCommand) '\(command)'"
            let result = req.eventLoop.future()
                .flatMapThrowing {
                    let process = Process()
                    process.launchPath = "/bin/bash"
                    process.arguments = ["-c", fullCommand]

                    let pipe = Pipe()
                    process.standardOutput = pipe
                    process.launch()
                    process.waitUntilExit()

                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8) ?? ""

                    return VPSVerificationResult(
                        requirement: requirement,
                        status: process.terminationStatus == 0 ? "Passed" : "Failed: \(output)"
                    )
                }

            results.append(result)
        }

        return results.flatten(on: req.eventLoop)
            .map { VPSVerificationResponse(results: $0) }
    }
}
```

#### 4. Configuration

Update `configure.swift` to register the new routes:

**configure.swift**

```swift
import Vapor
import Fluent
import FluentPostgresDriver

public func configure(_ app: Application) throws {
    // Database configuration (if needed)
    app.databases.use(.postgres(
        hostname: "localhost",
        username: "postgres",
        password: "password",
        database: "secretsdb"
    ), as: .psql)
    
    // Register routes
    let secretsController = SecretsController()
    try app.register(collection: secretsController)
}
```

### Conclusion

The FountainAI Secrets Manager provides a robust solution for managing GitHub secrets, automating CI/CD workflows, and verifying VPS requirements. By integrating these functionalities into a single Vapor application, developers can streamline their development processes and maintain a high level of security and reliability for their applications.

### Commit Message

```markdown
feat: Add Secrets Management, CI/CD Workflow Generator, and VPS Verification

- Implemented endpoints for creating, retrieving, updating, and deleting GitHub secrets.
- Added functionality to dynamically generate CI/CD workflows using GitHub Actions based on application configurations.
- Added endpoint to verify VPS requirements.
- Defined OpenAPI specification for the Secrets Management, CI/CD Workflow Generator, and VPS Verification API.
- Created comprehensive documentation for setting up and using the FountainAI Secrets Manager.
```

This concludes the detailed implementation and documentation for the FountainAI Secrets Manager with CI/CD Workflow Generator and VPS Verification.