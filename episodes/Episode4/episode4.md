
### `episodes/episode4.md`

# Episode 4: Automating Secrets Management with a Swift Command-Line Tool

## Table of Contents

1. [Introduction](#introduction)
2. [Rationale for Automating Secrets Management](#rationale-for-automating-secrets-management)
3. [Developing the Command-Line Tool in Swift](#developing-the-command-line-tool-in-swift)
4. [Dockerizing the Command-Line Tool](#dockerizing-the-command-line-tool)
5. [Creating the Custom GitHub Action](#creating-the-custom-github-action)
6. [Integrating the Tool with CI/CD Workflows](#integrating-the-tool-with-cicd-workflows)
7. [Managing Secrets](#managing-secrets)
8. [Conclusion](#conclusion)

---

## Introduction

In the previous episode, we focused on creating a basic "Hello, World!" Vapor application, Dockerizing it, and integrating it into our CI/CD pipeline. We introduced Docker Compose to manage multiple containers and ensured a smooth deployment process. This integration utilized secrets management to handle sensitive information securely.

In this episode, we will build on that foundation by enhancing our CI/CD pipeline with a Swift-based command-line tool to manage GitHub secrets. This tool will be Dockerized and managed using Docker Compose, allowing seamless integration into our CI/CD workflows. This enhancement will provide better automation and security for secrets management in our CI/CD process.

## Rationale for Automating Secrets Management

Manually managing secrets for each repository's CI/CD pipeline can lead to several issues:
1. **Duplication of Effort**: Repeatedly managing secrets across multiple repositories is tedious and error-prone.
2. **Security Risks**: Manual processes increase the risk of exposing sensitive information.
3. **Inconsistency**: Manually updating secrets can lead to inconsistencies across different environments.

By automating secrets management, we can:
1. **Increase Efficiency**: Automate repetitive tasks to save time and reduce errors.
2. **Enhance Security**: Use encrypted storage and automated processes to handle secrets securely.
3. **Ensure Consistency**: Maintain consistent secret values across multiple environments.

## Developing the Command-Line Tool in Swift

First, we need to develop the Swift-based command-line tool to manage GitHub secrets.

### Step 1: Create a Swift Package

Create a new directory for the command-line tool and initialize a Swift package within it.

```sh
cd path/to/your/fountainAI
mkdir SecretManager
cd SecretManager
swift package init --type executable --name SecretManager
```

Edit `Package.swift` to include dependencies for making HTTP requests and handling JSON.

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SecretManager",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.32.2"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.16.1"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.1"),
    ],
    targets: [
        .target(
            name: "SecretManager",
            dependencies: ["NIO", "NIOHTTP1", "NIOFoundationCompat", "NIOSSL", "SwiftyJSON", "CryptoKit"]),
        .testTarget(
            name: "SecretManagerTests",
            dependencies: ["SecretManager"]),
    ]
)
```

The `Package.swift` file now includes dependencies for `NIO` (for networking), `NIOSSL` (for SSL/TLS), `SwiftyJSON` (for JSON handling), and `CryptoKit` (for encryption).

### Step 2: Implement the Command-Line Tool

Update `Sources/SecretManager/main.swift` to implement the command-line tool functionality using `CryptoKit` for encryption.

```swift
import Foundation
import NIO
import NIOHTTP1
import NIOSSL
import SwiftyJSON
import CryptoKit

// Define a struct to manage GitHub secrets
struct GitHubSecretManager {
    let token: String?
    let repoOwner: String
    let repoName: String
    let publicKeyURL: String
    let secretsURL: String

    // Initialize the struct with the necessary parameters
    init(token: String?, repoOwner: String, repoName: String) {
        guard let token = token else {
            print("Error: GitHub token is not provided.")
            exit(1)
        }
        self.token = token
        self.repoOwner = repoOwner
        self.repoName = repoName
        self.publicKeyURL = "https://api.github.com/repos/\(repoOwner)/\(repoName)/actions/secrets/public-key"
        self.secretsURL = "https://api.github.com/repos/\(repoOwner)/\(repoName)/actions/secrets"
    }

    // Fetch the public key for the repository to encrypt secrets
    func getPublicKey(completion: @escaping (String, String) -> Void) {
        var request = URLRequest(url: URL(string: publicKeyURL)!)
        request.httpMethod = "GET"
        request.setValue("token \(token!)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Error fetching public key: \(String(describing: error))")
                return
            }
            if let json = try? JSON(data: data) {
                let key = json["key"].stringValue
                let keyId = json["key_id"].stringValue
                completion(key, keyId)
            }
        }
        task.resume()
    }

    // Encrypt the secret using the public key
    func encryptSecret(publicKey: String, secret: String) -> String? {
        guard let publicKeyData = Data(base64Encoded: publicKey) else {
            return nil
        }
        let sealedBox = try? Curve25519.KeyAgreement.PublicKey(rawRepresentation: publicKeyData)
            .sealedBox(using: SymmetricKey(size: .bits256), data: Data(secret.utf8))
        return sealedBox?.combined.base64EncodedString()
    }

    // Create or update a secret in the GitHub repository
    func createOrUpdateSecret(secretName: String, secretValue: String) {
        getPublicKey { publicKey, keyId in
            if let encryptedSecret = self.encryptSecret(publicKey: publicKey, secret: secretValue) {
                var request = URLRequest(url: URL(string: "\(self.secretsURL)/\(secretName)")!)
                request.httpMethod = "PUT"
                request.setValue("token \(self.token!)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let json = JSON(["encrypted_value": encryptedSecret, "key_id": keyId])
                request.httpBody = try? json.rawData()

                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error creating/updating secret: \(error)")
                        return
                    }
                    print("Secret \(secretName) created/updated successfully.")
                }
                task.resume()
            }
        }
    }
}

// Parse command-line arguments
let arguments = CommandLine.arguments
guard arguments.count > 1 else {
    print("Usage: SecretManager <action> --repo-owner <owner> --repo-name <name> --token <token> --secret-name <name> --secret-value <value>")
    exit(1)
}

let action = arguments[1]
let repoOwner = arguments[3]
let repoName = arguments[5]
let token = arguments.count > 7 ? arguments[7] : nil

let manager = GitHubSecretManager(token: token, repoOwner: repoOwner, repoName: repoName)

// Execute the appropriate action based on the command-line arguments
switch action {
case "create", "update":
    guard arguments.count > 9 else {
        print("Usage: SecretManager <action> --repo-owner <owner> --repo-name <name> --token <token> --secret-name <name> --secret-value <value>")
        exit(1)
    }
    let secretName = arguments[9]
    let secretValue = arguments[11]
    manager.createOrUpdateSecret(secretName: secretName, secretValue: secretValue)
default:
    print("Unsupported action: \(action)")
    exit(1)
}
```

### Explanation

1. **Importing Libraries**:
   - The script imports necessary libraries including `Foundation`, `NIO`, `NIOHTTP1`, `NIOSSL`, `SwiftyJSON`, and `CryptoKit`.

2. **GitHubSecretManager Struct**:
   - This struct is responsible for managing GitHub secrets.
   - The `init` method initializes the struct with the necessary parameters including the GitHub token, repository owner, and repository name. It now checks if the token is provided and exits if not.
   - `getPublicKey` fetches the public key for the repository to encrypt secrets.
   - `encryptSecret` encrypts the secret using the public key.
   - `createOrUpdateSecret` creates or updates a secret in the GitHub repository.

3. **Main Script**:
   - The script parses command-line arguments to get the action, repository owner, repository name, token, secret name, and secret value.
   - It initializes a `GitHubSecretManager` instance and calls the appropriate method based on the action.

4. **Handling Missing GitHub Token**:
   - The script checks if the GitHub token is provided. If the token is not provided, it prints an error message and exits the program.

## Dockerizing the Command-Line Tool

Create a `Dockerfile` for the command-line tool:

```dockerfile
# Use the official Swift image to build the app
FROM swift:5.3 as builder

# Copy the Swift package and build it
WORKDIR /app
COPY . .
RUN swift build --disable-sandbox --configuration release

# Create a slim runtime image
FROM swift:5.3-slim

# Copy the built executable
COPY --from=builder /app/.build/release/SecretManager /usr/local/bin/SecretManager

# Set the entry point
ENTRYPOINT ["SecretManager"]
```

### Explanation

1. **Build Stage**:
   - Uses the official Swift image to build the Swift package.
   - Copies the Swift package into the container and builds it in release mode.

2. **Runtime Stage**:
   - Creates a slim runtime image using `swift:5.3-slim`.
   - Copies the built executable from the build stage to the runtime image.
   - Sets the entry point to the `SecretManager` executable.

## Creating the Custom GitHub Action

Let's create a shell script to generate the custom GitHub action named `run-secret-manager` properly. This script will create the necessary files and directories and ensure the action is correctly set up in the repository.

Save this script as `create_run_secret_manager_action.sh` in the root directory of the `fountainAI` repository:

```sh
#!/bin/bash

# Define the path for the custom action
ACTION_DIR=".github/actions/run-secret-manager"

# Create the directory for the custom action
mkdir -p ${ACTION_DIR}

# Create the action.yml file
cat <<EOF > ${ACTION_DIR}/action.yml
name: 'Run Secret Manager'
description: 'Action to run the Secret Manager command-line tool'
inputs:
  repo-owner:
    description: 'GitHub repository owner'
    required: true
  repo-name:
    description: 'GitHub repository name'
    required: true
  token:
    description: 'GitHub token'
    required: true
  secret-name:
    description: 'Name of the secret'
    required: true
  secret-value:
    description: 'Value of the secret'
    required: true
runs:
  using: 'docker'
  image: 'Dockerfile'
  args:
    - create
    - --repo-owner
    - \${{ inputs.repo-owner }}
    - --repo-name
    - \${{ inputs.repo-name }}
    - --token
    - \${{ inputs.token }}
    - --secret-name
    - \${{ inputs.secret-name }}
    - --secret-value
    - \${{ inputs.secret-value }}
EOF

# Create the Dockerfile for the custom action
cat <<EOF > ${ACTION_DIR}/Dockerfile
# Use the official Swift image to build the app
FROM swift:5.3 as builder

# Copy the Swift package and build it
WORKDIR /app
COPY . .
RUN swift build --disable-sandbox --configuration release

# Create a slim runtime image
FROM swift:5.3-slim

# Copy the built executable
COPY --from=builder /app/.build/release/SecretManager /usr/local/bin/SecretManager

# Set the entry point
ENTRYPOINT ["SecretManager"]
EOF

echo "Custom GitHub action 'run-secret-manager' created successfully."
```

### Explanation

1. **Action Directory**:
   - Defines the path for the custom action directory.
   - Creates the directory for the custom action.

2. **Action Metadata**:
   - Creates the `action.yml` file with the necessary metadata for the custom action, including name, description, inputs, and execution details.
   - Specifies that the action uses Docker and provides the Dockerfile to build the image.
   - Defines the inputs required by the action, including the repository owner, repository name, GitHub token, secret name, and secret value.
   - Passes the inputs as arguments to the Docker container.

3. **Dockerfile**:
   - Creates the `Dockerfile` for the custom action.
   - Uses the official Swift image to build the Swift package.
   - Copies the Swift package into the container and builds it in release mode.
   - Creates a slim runtime image using `swift:5.3-slim`.
   - Copies the built executable from the build stage to the runtime image.
   - Sets the entry point to the `SecretManager` executable.

**Note**: Unlike previous custom actions, this action does not require an `index.js` file because it runs the `SecretManager` executable directly in the Docker container. The `Dockerfile` handles building and running the Swift application, making the `index.js` file unnecessary.

### Usage

1. **Make the Script Executable**:
   ```sh
   chmod +x create_run_secret_manager_action.sh
   ```

2. **Run the Script**:
   ```sh
   ./create_run_secret_manager_action.sh
   ```

This script will create the custom GitHub action named `run-secret-manager` in the `.github/actions/run-secret-manager` directory. Now, you can integrate this action into your CI/CD workflows as needed.

## Integrating the Tool with CI/CD Workflows

Create a shell script to update CI/CD workflows. Save this script as `fit_secrets_manager_into_cicd_pipeline.sh` in the root directory of the `fountainAI` repository.

```sh
#!/bin/bash

# Define the workflow paths
WORKFLOW_PATHS=(
  ".github/workflows/development.yml"
  ".github/workflows/testing.yml"
  ".github/workflows/staging.yml"
  ".github/workflows/production.yml"
)

# Define the workflow content
WORKFLOW_CONTENT=$(cat <<EOF
name: Manage Secrets Workflow

on:
  push:
    branches:
      - development
      - testing
      - staging
      - main

jobs:
  manage-secrets:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Run Secret Manager
        uses: ./.github/actions/run-secret-manager
        with:
          repo-owner: \${{ secrets.REPO_OWNER }}
          repo-name: \${{ secrets.REPO_NAME }}
          token: \${{ secrets.GITHUB_TOKEN }}
          secret-name: \${{ secrets.SECRET_NAME }}
          secret-value: \${{ secrets.SECRET_VALUE }}
EOF
)

# Update each workflow file
for WORKFLOW_PATH in "${WORKFLOW_PATHS[@]}"; do
  echo "${WORKFLOW_CONTENT}" > "${WORKFLOW_PATH}"
done

echo "CI/CD workflows updated successfully."
```

### Explanation

1. **Define Workflow Paths**:
   - Lists the paths of the workflow files to be updated.

2. **Define Workflow Content**:
   - Specifies the content of the workflow files.

3. **Update Each Workflow File**:
   - Iterates over each workflow path and writes the workflow content to the respective file.

4. **Usage**:
   - Make the script executable and run it to update the CI/CD workflows.

```sh
chmod +x fit_secrets_manager_into_cicd_pipeline.sh
./fit_secrets_manager_into_cicd_pipeline.sh
```

## Managing Secrets

### Creating a Secret

To create a secret, use the command-line tool with the `create` action.

1. **Run the Docker container to create a secret**:

   ```sh
   docker-compose run secret-manager create --repo-owner YourUsername --repo-name YourRepo --token $GITHUB_TOKEN --secret-name SECRET_NAME --secret-value SECRET_VALUE
   ```

### Explanation

1. **Create a Secret**:
   - Use `docker-compose run` to run the `secret-manager` service and create a secret.
   - The command specifies the `create` action, repository owner, repository name, GitHub token, secret name, and secret value.

2. **CI/CD Integration**:
   - The CI/CD workflow uses the `create` action for managing secrets.
   - The workflow checks out the code and runs the `secret-manager` service to create a secret.

### Updating a Secret

To update a secret, use the command-line tool with the `update` action.

1. **Run the Docker container to update a secret**:

   ```sh
   docker-compose run secret-manager update --repo-owner YourUsername --repo-name YourRepo --token $GITHUB_TOKEN --secret-name SECRET_NAME --secret-value NEW_SECRET_VALUE
   ```

### Explanation

1. **Update a Secret**:
   - Use `docker-compose run` to run the `secret-manager` service and update a secret.
   - The command specifies the `update` action, repository owner, repository name, GitHub token, secret name, and new secret value.

2. **CI/CD Integration**:
   - The CI/CD workflow uses the `update` action for managing secrets.
   - The workflow checks out the code and runs the `secret-manager` service to update a secret.

## Handling Missing GitHub Token

If you call the command-line tool without setting the GitHub token, the program will print an error message and exit. Here's the relevant part of the code that handles this:

```swift
struct GitHubSecret

Manager {
    let token: String?
    let repoOwner: String
    let repoName: String
    let publicKeyURL: String
    let secretsURL: String

    // Initialize the struct with the necessary parameters
    init(token: String?, repoOwner: String, repoName: String) {
        guard let token = token else {
            print("Error: GitHub token is not provided.")
            exit(1)
        }
        self.token = token
        self.repoOwner = repoOwner
        self.repoName = repoName
        self.publicKeyURL = "https://api.github.com/repos/\(repoOwner)/\(repoName)/actions/secrets/public-key"
        self.secretsURL = "https://api.github.com/repos/\(repoOwner)/\(repoName)/actions/secrets"
    }
}
```

In the `init` method of the `GitHubSecretManager` struct, the code checks if the `token` parameter is `nil`. If it is, the program prints an error message: `Error: GitHub token is not provided.` and then exits using `exit(1)`.

### Running the Tool without the GitHub Token

```sh
./SecretManager create --repo-owner YourUsername --repo-name YourRepo --secret-name SECRET_NAME --secret-value SECRET_VALUE
```

### Expected Output

```
Error: GitHub token is not provided.
```

### Tool Exits with Code

The program will exit with a status code of `1`, indicating an error.

This behavior ensures that the tool does not proceed with any operations that require the GitHub token, preventing potential issues or failures due to the missing token.

## Conclusion

In this episode, we enhanced our CI/CD pipeline by developing a Swift-based command-line tool for managing GitHub secrets. We Dockerized the tool and integrated it into our CI/CD workflows, enabling automated secrets management. This approach ensures better security, reduces manual effort, and maintains consistency across different environments.

By following these steps, we have created a more flexible and secure CI/CD pipeline that can be easily adapted for future projects. Stay tuned for the next episode, where we will delve deeper into the implementation of FountainAI, building upon the solid groundwork established in this episode.

---

**Commit Message for this Episode Update**:
```
feat: Add Swift-based Secret Manager for CI/CD Pipeline

- Developed a Swift-based command-line tool for managing GitHub secrets
- Dockerized the command-line tool for easy integration
- Created a custom GitHub action named 'run-secret-manager'
- Updated CI/CD workflows to use the new secret management tool
- Provided detailed explanations and usage instructions
- Added error handling for missing GitHub token

This update enhances the security and automation of secrets management in the CI/CD pipeline.
```