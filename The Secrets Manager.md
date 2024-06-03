### Commit Message

```markdown
feat: Add GitHub Secrets Management API

- Implemented the GitHub Secrets Management API with endpoints for creating, retrieving, updating, and deleting secrets.
- Defined OpenAPI specification for the Secrets Management API.
- Created Vapor application with models, controllers, and routes to handle secret management operations.
- Added example usage in another Vapor app to interact with the Secrets Management Service.
- Provided comprehensive documentation and examples for each endpoint.

OpenAPI Specification:
- Endpoint to create or update a secret in a GitHub repository.
- Endpoint to retrieve a specific secret by name.
- Endpoint to delete a specific secret by name.

Vapor App Implementation:
- Created `SecretCreateRequest`, `SecretResponse`, and `Secret` models.
- Implemented `SecretsController` with methods to handle secret management.
- Configured application with database setup (if needed) and registered routes.

API Call Example:
- Example client in another Vapor app to interact with the Secrets Manager Service.
- Routes for creating, retrieving, and deleting secrets in the consuming Vapor app.
```

This commit sets up the foundation for managing GitHub secrets programmatically within the FountainAI ecosystem, enabling secure and streamlined secret management across various applications.


### OpenAPI Specification

```yaml
openapi: 3.0.1
info:
  title: GitHub Secrets Management API
  description: |
    API for managing GitHub secrets, including creation, retrieval, updating, and deletion.

    **Dockerized Environment**:
    - **Nginx**: An Nginx proxy container handles SSL termination with Let's Encrypt certificates via Certbot.
    - **Vapor Application**: A Swift-based Vapor app runs in a separate Docker container.
    - **Postgres Database**: The main persistence layer is a PostgreSQL container managed by Docker Compose.

  version: "1.0.0"
servers:
  - url: 'https://secrets.fountain.coach'
    description: Main server for GitHub Secrets Management API services (behind Nginx proxy)
  - url: 'http://localhost:8080'
    description: Development server for GitHub Secrets Management API services (Docker environment)

paths:
  /secrets:
    post:
      summary: Create or Update GitHub Secret
      operationId: createOrUpdateSecret
      description: |
        Creates or updates a GitHub secret in the specified repository.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/SecretCreateRequest'
            examples:
              createOrUpdateSecretExample:
                summary: Example of creating or updating a GitHub secret
                value:
                  repoOwner: "exampleOwner"
                  repoName: "exampleRepo"
                  secretName: "MY_SECRET"
                  secretValue: "superSecretValue"
      responses:
        '200':
          description: GitHub secret successfully created or updated.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SecretResponse'
              examples:
                secretCreated:
                  summary: Example of a successfully created or updated secret
                  value:
                    message: "Secret successfully created or updated."
        '400':
          description: Bad request due to missing required fields or invalid data.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                badRequestExample:
                  value:
                    message: "Missing required fields or invalid data."

  /secrets/{repoOwner}/{repoName}/{secretName}:
    get:
      summary: Retrieve a GitHub Secret
      operationId: getSecret
      description: |
        Retrieves the details of a specific GitHub secret by its name.
      parameters:
        - name: repoOwner
          in: path
          required: true
          description: Owner of the GitHub repository.
          schema:
            type: string
        - name: repoName
          in: path
          required: true
          description: Name of the GitHub repository.
          schema:
            type: string
        - name: secretName
          in: path
          required: true
          description: Name of the GitHub secret to retrieve.
          schema:
            type: string
      responses:
        '200':
          description: Detailed information about the requested secret.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Secret'
              examples:
                retrievedSecret:
                  summary: Example of a retrieved secret
                  value:
                    repoOwner: "exampleOwner"
                    repoName: "exampleRepo"
                    secretName: "MY_SECRET"
                    secretValue: "superSecretValue"
        '404':
          description: The secret with the specified name was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundExample:
                  value:
                    message: "Secret not found with name: MY_SECRET"

    delete:
      summary: Delete a GitHub Secret
      operationId: deleteSecret
      description: Deletes a specific GitHub secret from the specified repository.
      parameters:
        - name: repoOwner
          in: path
          required: true
          description: Owner of the GitHub repository.
          schema:
            type: string
        - name: repoName
          in: path
          required: true
          description: Name of the GitHub repository.
          schema:
            type: string
        - name: secretName
          in: path
          required: true
          description: Name of the GitHub secret to delete.
          schema:
            type: string
      responses:
        '204':
          description: Secret successfully deleted.
        '404':
          description: The secret with the specified name was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundDeleteExample:
                  value:
                    message: "Secret not found with name: MY_SECRET"

components:
  schemas:
    SecretCreateRequest:
      type: object
      properties:
        repoOwner:
          type: string
          description: Owner of the GitHub repository.
        repoName:
          type: string
          description: Name of the GitHub repository.
        secretName:
          type: string
          description: Name of the secret to create or update.
        secretValue:
          type: string
          description: Value of the secret.
      required:
        - repoOwner
        - repoName
        - secretName
        - secretValue

    Secret:
      type: object
      properties:
        repoOwner:
          type: string
          description: Owner of the GitHub repository.
        repoName:
          type: string
          description: Name of the GitHub repository.
        secretName:
          type: string
          description: Name of the GitHub secret.
        secretValue:
          type: string
          description: Value of the GitHub secret.

    SecretResponse:
      type: object
      properties:
        message:
          type: string
          description: Success or error message.
          
    Error:
      type: object
      description: Common error structure for the API.
      properties:
        message:
          type: string
          description: Description of the error encountered.
```

### Vapor App Implementation

#### Models

Create `Sources/App/Models/Secret.swift`:

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

#### Controllers

Create `Sources/App/Controllers/SecretsController.swift`:

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
    }

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

    func getPublicKey(req: Request, repoOwner: String, repoName: String, githubToken: String) -> EventLoopFuture<PublicKeyResponse> {
        let url = "https://api.github.com/repos/\(repoOwner)/\(repoName)/actions/secrets/public-key"
        
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer \(

githubToken)")
        headers.add(name: .userAgent, value: "Swift Vapor App")
        
        return req.client.get(URI(string: url), headers: headers).flatMapThrowing { response in
            guard response.status == .ok else {
                throw Abort(.internalServerError, reason: "Failed to fetch public key")
            }
            return try response.content.decode(PublicKeyResponse.self)
        }
    }

    func encrypt(secret: String, publicKey: String) throws -> String {
        let publicKeyData = Data(base64Encoded: publicKey)!
        let secretData = secret.data(using: .utf8)!

        let sealedBox = try ChaChaPoly.seal(secretData, using: .publicKey(from: publicKeyData))
        return sealedBox.ciphertext.base64EncodedString()
    }

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
}

extension P256.KeyAgreement.PublicKey {
    init(from data: Data) throws {
        let attributes = [kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                          kSecAttrKeyClass: kSecAttrKeyClassPublic,
                          kSecAttrKeySizeInBits: 256] as CFDictionary
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(data as CFData, attributes, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        self = try P256.KeyAgreement.PublicKey(secKeyRepresentation: secKey)
    }
}
```

#### Configuration

Update `Sources/App/configure.swift`:

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

Update `Sources/App/routes.swift`:

```swift
import Vapor

func routes(_ app: Application) throws {
    let secretsController = SecretsController()
    try app.register(collection: secretsController)
}
```

### Example Usage in Another Vapor App

Create a client in another Vapor app to interact with the Secrets Manager Service:

Create `Sources/App/Clients/SecretsManagerClient.swift`:

```swift
import Vapor

struct SecretsManagerClient {
    let client: Client
    let secretsServiceURL: String

    func createOrUpdateSecret(repoOwner: String, repoName: String, secretName: String, secretValue: String) -> EventLoopFuture<String> {
        let url = URI(string: "\(secretsServiceURL)/secrets")
        let secretRequest = SecretCreateRequest(repoOwner: repoOwner, repoName: repoName, secretName: secretName, secretValue: secretValue)

        return client.post(url) { req in
            try req.content.encode(secretRequest)
        }.flatMapThrowing { response in
            guard response.status == .ok else {
                throw Abort(.internalServerError, reason: "Failed to create or update secret")
            }
            let secretResponse = try response.content.decode(SecretResponse.self)
            return secretResponse.message
        }
    }

    func getSecret(repoOwner: String, repoName: String, secretName: String) -> EventLoopFuture<Secret> {
        let url = URI(string: "\(secretsServiceURL)/secrets/\(repoOwner)/\(repoName)/\(secretName)")

        return client.get(url).flatMapThrowing { response in
            guard response.status == .ok else {
                throw Abort(.notFound, reason: "Secret not found")
            }
            return try response.content.decode(Secret.self)
        }
    }

    func deleteSecret(repoOwner: String, repoName: String, secretName: String) -> EventLoopFuture<HTTPStatus> {
        let url = URI(string: "\(secretsServiceURL)/secrets/\(repoOwner)/\(repoName)/\(secretName)")

        return client.delete(url).transform(to: .noContent)
    }
}
```

Use the client in a route in `Sources/App/routes.swift`:

```swift
import Vapor

func routes(_ app: Application) throws {
    let secretsClient = SecretsManagerClient(client: app.client, secretsServiceURL: "https://secrets.fountain.coach")

    app.post("create-secret") { req -> EventLoopFuture<String> in
        let createRequest = try req.content.decode(SecretCreateRequest.self)
        return secretsClient.createOrUpdateSecret(
            repoOwner: createRequest.repoOwner,
            repoName: createRequest.repoName,
            secretName: createRequest.secretName,
            secretValue: createRequest.secretValue
        )
    }

    app.get("get-secret", ":repoOwner", ":repoName", ":secretName") { req -> EventLoopFuture<Secret> in
        let repoOwner = try req.parameters.require("repoOwner")
        let repoName = try req.parameters.require("repoName")
        let secretName = try req.parameters.require("secretName")
        return secretsClient.getSecret(repoOwner: repoOwner, repoName: repoName, secretName: secretName)
    }

    app.delete("delete-secret", ":repoOwner", ":repoName", ":secretName") { req -> EventLoopFuture<HTTPStatus> in
        let repoOwner = try req.parameters.require("repoOwner")
        let repoName = try req.parameters.require("repoName")
        let secretName = try req.parameters.require("secretName")
        return secretsClient.deleteSecret(repoOwner: repoOwner, repoName: repoName, secretName: secretName)
    }
}
```

### Summary

- Added OpenAPI specification for GitHub Secrets Management API.
- Implemented Vapor application for managing GitHub secrets with endpoints for creating, retrieving, updating, and deleting secrets.
- Provided example client and routes for another Vapor app to interact with the Secrets Manager Service.

This setup enables secure and streamlined secret management across various applications within the FountainAI project.