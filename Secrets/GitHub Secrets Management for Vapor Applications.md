# GitHub Secrets Management for Vapor Applications

## Introduction

GitHub Secrets are a secure way to store sensitive information such as API keys, tokens, passwords, and other confidential data needed by your repositories. They are encrypted and can be used in GitHub Actions workflows. This documentation covers the concept of GitHub Secrets, their importance, and how to use them in a Vapor application, including automation using the GitHub API with shell commands.

## What are GitHub Secrets?

GitHub Secrets allow you to store sensitive information securely in your repository. These secrets are encrypted and can be accessed by workflows running in GitHub Actions. Secrets help you avoid hardcoding sensitive information in your codebase, thus maintaining security and confidentiality.

### Key Terminologies

- **GitHub**: A platform for version control and collaboration. It allows multiple people to work on projects at the same time, using Git for version control.
- **GitHub Actions**: A CI/CD (Continuous Integration and Continuous Deployment) service provided by GitHub to automate workflows. It allows you to build, test, and deploy your code directly from GitHub.
- **API Key**: A code passed in by computer programs calling an API (Application Programming Interface) to identify the calling program, its developer, or its user to the API.
- **Tokens**: Small pieces of data that serve as a digital identity for a user or application. Often used for authentication and authorization purposes.
- **Encrypted**: The process of converting information or data into a code, especially to prevent unauthorized access.
- **Repository (repo)**: A central location in which data is stored and managed. In the context of GitHub, a repository is where your project files are stored.
- **Workflows**: Automated procedures defined in YAML files to run tasks such as CI/CD pipelines in GitHub Actions. Workflows consist of one or more jobs that run sequentially or in parallel.
- **YAML**: A human-readable data-serialization language. It is commonly used for configuration files and in applications where data is being stored or transmitted.
- **Settings**: The configuration section of a GitHub repository where you can manage options like branches, webhooks, and secrets.
- **Context**: A way to access data in GitHub Actions. It is used to get information about the workflow run, like secrets, environment variables, and event payload.
- **`secrets` Context**: A special context in GitHub Actions that is used to reference secrets stored in the repository's settings. For example, `secrets.MY_SECRET` accesses the secret named `MY_SECRET`.
- **Checkout**: A step in GitHub Actions to clone your repository to the runner so that you can work with the code in subsequent steps.
- **Environment Variable**: A dynamic-named value that can affect the way running processes will behave on a computer. In GitHub Actions, you can set environment variables and access them in workflows.
- **Rotation of Secrets**: The practice of periodically updating and replacing secrets to enhance security. It ensures that even if a secret is compromised, it will be valid only for a short period.
- **Principle of Least Privilege**: A security best practice that recommends granting users the minimum levels of access—or permissions—needed to perform their job functions.
- **Audit**: A systematic review or assessment of something. In the context of GitHub Secrets, auditing refers to reviewing the usage and access patterns of secrets to ensure they are used appropriately and securely.
- **Unauthorized Access**: Access to systems, data, or resources without permission. In the context of GitHub Secrets, it means accessing the secrets without being granted explicit permission.
- **Continuous Integration (CI)**: A development practice where developers integrate code into a shared repository frequently, preferably several times a day. Each integration can then be verified by an automated build and automated tests.
- **Continuous Deployment (CD)**: A software release process that uses automated testing to validate if changes to a codebase are correct and stable for immediate autonomous deployment to a production environment.
- **Secret Value**: The actual sensitive data (such as an API key or password) stored in a GitHub Secret.

## Using GitHub Secrets

### Step 1: Create a Secret

1. **Navigate to your repository**: Go to the GitHub repository where you want to add a secret.
2. **Settings**: Click on the "Settings" tab.
3. **Secrets and variables**: In the left sidebar, click on "Secrets and variables".
4. **Actions**: Select "Actions" under "Secrets and variables".
5. **New repository secret**: Click on the "New repository secret" button.
6. **Add your secret**: Provide a name for your secret and the secret value. Click "Add secret".

### Step 2: Use Secrets in GitHub Actions

To use the secrets in your GitHub Actions workflows, you reference them using the `secrets` context.

Example workflow that uses a secret:

```yaml
name: Example Workflow

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Run a script that requires a secret
        run: echo ${{ secrets.MY_SECRET }}
```

In this example:
- `MY_SECRET` is the name of the secret you created.
- `${{ secrets.MY_SECRET }}` is how you reference the secret in the workflow.

### Best Practices for Using GitHub Secrets

1. **Limit access**: Only give access to secrets to those who absolutely need it.
2. **Rotate secrets**: Regularly update and rotate your secrets to maintain security.
3. **Use minimal scope**: Apply the principle of least privilege; the secrets should have only the necessary permissions for their purpose.
4. **Monitor usage**: Regularly audit and monitor the use of secrets to detect any unauthorized access.

## Using GitHub Secrets in a Vapor Application

To use GitHub Secrets for managing environment variables and configuration in a Vapor application created from an OpenAPI example, you need to securely store sensitive information such as database credentials, API keys, and other configuration settings.

### Example OpenAPI

```yaml
openapi: 3.0.1
info:
  title: Script Management API
  description: |
    API for managing screenplay scripts, including creation, retrieval, updating, and deletion.

    **Dockerized Environment**:
    - **Nginx**: An Nginx proxy container handles SSL termination with Let's Encrypt certificates via Certbot.
    - **Vapor Application**: A Swift-based Vapor app runs in a separate Docker container.
    - **Postgres Database**: The main persistence layer is a PostgreSQL container managed by Docker Compose.
    - **Redis Cache**: A Redis container is used for caching script data, optimizing performance for frequent queries.
    - **RedisAI Middleware**: RedisAI provides enhanced analysis, recommendations, and validation for script management.

  version: "1.1.0"
servers:
  - url: 'https://script.fountain.coach'
    description: Main server for Script Management API services (behind Nginx proxy)
  - url: 'http://localhost:8080'
    description: Development server for Script Management API services (Docker environment)

paths:
  /scripts:
    get:
      summary: Retrieve All Scripts
      operationId: listScripts
      description: |
        Lists all screenplay scripts stored within the system. This endpoint leverages Redis caching for improved query performance.
      responses:
        '200':
          description: An array of scripts.
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Script'
              examples:
                allScripts:
                  summary: Example of retrieving all scripts
                  value:
                    - scriptId: 1
                      title: "Sunset Boulevard"
                      description: "A screenplay about Hollywood and faded glory."
                      author: "Billy Wilder"
                      sequence: 1
    post:
      summary: Create a New Script
      operationId: createScript
      description: |
        Creates a new screenplay script record in the system. RedisAI provides recommendations and validation during creation.
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ScriptCreateRequest'
            examples:
              createScriptExample:
                summary: Example of script creation
                value:
                  title: "New Dawn"
                  description: "A story about renewal and second chances."
                  author: "Jane Doe"
                  sequence: 1
      responses:
        '201':
          description: Script successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Script'
              examples:
                scriptCreated:
                  summary: Example of a created script
                  value:
                    scriptId: 2
                    title: "New Dawn"
                    description: "A story about renewal and second chances."
                    author: "Jane Doe"
                    sequence: 1
        '400':
          description: Bad request due to missing required fields.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                badRequestExample:
                  value:
                    message: "Missing required fields: 'title' or 'author'."

  /scripts/{scriptId}:
    get:
      summary: Retrieve a Script by ID
      operationId: getScriptById
      description: |
        Retrieves the details of a specific screenplay script by its unique identifier (scriptId). Redis caching improves retrieval performance.
      parameters:
        - name: scriptId
          in: path
          required: true
          description: Unique identifier of the screenplay script to retrieve.
          schema:
            type: integer


      responses:
        '200':
          description: Detailed information about the requested script.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Script'
              examples:
                retrievedScript:
                  summary: Example of a retrieved script
                  value:
                    scriptId: 1
                    title: "Sunset Boulevard"
                    description: "A screenplay about Hollywood and faded glory."
                    author: "Billy Wilder"
                    sequence: 1
        '404':
          description: The script with the specified ID was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundExample:
                  value:
                    message: "Script not found with ID: 3"
    put:
      summary: Update a Script by ID
      operationId: updateScript
      description: |
        Updates an existing screenplay script with new details. RedisAI provides recommendations and validation for updating script content.
      parameters:
        - name: scriptId
          in: path
          required: true
          description: Unique identifier of the screenplay script to update.
          schema:
            type: integer
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ScriptUpdateRequest'
            examples:
              updateScriptExample:
                summary: Example of updating a script
                value:
                  title: "Sunset Boulevard Revised"
                  description: "Updated description with more focus on character development."
                  author: "Billy Wilder"
                  sequence: 2
      responses:
        '200':
          description: Script successfully updated.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Script'
              examples:
                scriptUpdated:
                  summary: Example of an updated script
                  value:
                    scriptId: 1
                    title: "Sunset Boulevard Revised"
                    description: "Updated description with more focus on character development."
                    author: "Billy Wilder"
                    sequence: 2
        '400':
          description: Bad request due to invalid input data.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                badRequestUpdateExample:
                  value:
                    message: "Invalid input data: 'sequence' must be a positive number."
        '404':
          description: The script with the specified ID was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundUpdateExample:
                  value:
                    message: "Script not found with ID: 4"
    delete:
      summary: Delete a Script by ID
      operationId: deleteScript
      description: Deletes a specific screenplay script from the system, identified by its scriptId.
      parameters:
        - name: scriptId
          in: path
          required: true
          description: Unique identifier of the screenplay script to delete.
          schema:
            type: integer
      responses:
        '204':
          description: Script successfully deleted.
        '404':
          description: The script with the specified ID was not found.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundDeleteExample:
                  value:
                    message: "Script not found with ID: 5"

components:
  schemas:
    Script:
      type: object
      properties:
        scriptId:
          type: integer
          description: Unique identifier for the screenplay script.
        title:
          type: string
          description: Title of the screenplay script.
        description:
          type: string
          description: Brief description or summary of the screenplay script.
        author:
          type: string
          description: Author of the screenplay script.
        sequence:
          type: integer
          description: Sequence number representing the script's order or version.
      required:
        - title
        - author

    ScriptCreateRequest:
      type: object
      properties:
        title:
          type: string
        description:
          type: string
        author:
          type: string
        sequence:
          type: integer
      required:
        - title
        - author

    ScriptUpdateRequest:
      type: object
      properties:
        title:
          type: string
        description:
          type: string
        author:
          type: string
        sequence:
          type: integer

    Error:
      type: object
      description: Common error structure for the API.
      properties:
        message:
          type: string
          description: Description of the error encountered.
```

### Step 1: Store Sensitive Information as GitHub Secrets

1. **Navigate to your repository**: Go to the GitHub repository where your Vapor application resides.
2. **Settings**: Click on the "Settings" tab.
3. **Secrets and variables**: In the left sidebar, click on "Secrets and variables".
4. **Actions**: Select "Actions" under "Secrets and variables".
5. **New repository secret**: Click on the "New repository secret" button.
6. **Add your secrets**: Provide names and values for your secrets, such as `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `REDIS_URL`, etc. Click "Add secret" for each one.

For example, you might add secrets like:
- `DB_HOST`: `your-database-host`
- `DB_USER`: `your-database-user`
- `DB_PASSWORD`: `your-database-password`
- `REDIS_URL`: `your-redis-url`

### Step 2: Access Secrets in GitHub Actions Workflow

Create a GitHub Actions workflow file (`.github/workflows/deploy.yml`) to build and deploy your Vapor application. Here's an example workflow that accesses the secrets:

```yaml
name: Deploy Vapor Application

on:
  push:
    branches:
      - main

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Swift
        uses: fwal/setup-swift@v1
        with:
          swift-version: '5.3'

      - name: Build the project
        run: swift build --enable-test-discovery

      - name: Run tests
        run: swift test --enable-test-discovery

      - name: Deploy to Docker
        run: |
          echo "DB_HOST=${{ secrets.DB_HOST }}" >> .env
          echo "DB_USER=${{ secrets.DB_USER }}" >> .env
          echo "DB_PASSWORD=${{ secrets.DB_PASSWORD }}" >> .env
          echo "REDIS_URL=${{ secrets.REDIS_URL }}" >> .env
          docker-compose -f docker-compose.prod.yml up --build -d
```

### Step 3: Configure Vapor Application to Use Environment Variables

In your Vapor application, configure it to read environment variables from the `.env` file or directly from the environment. Here is an example `configure.swift` file that sets up the application using environment variables:

```swift
import Vapor
import Fluent
import FluentPostgresDriver
import Redis

public func configure(_ app: Application) throws {
    // Load environment variables from .env file if available
    if let envFilePath = app.directory.workingDirectory.appending(".env"), 
       let envFile = try? String(contentsOfFile: envFilePath) {
        envFile.split(separator: "\n").forEach { line in
            let keyValue = line.split(separator: "=", maxSplits: 1)
            if keyValue.count == 2 {
                setenv(String(keyValue[0]), String(keyValue[1]), 1)
            }
        }
    }

    // Database configuration
    guard let dbHost = Environment.get("DB_HOST"),
          let dbUser = Environment.get("DB_USER"),
          let dbPassword = Environment.get("DB_PASSWORD"),
          let dbName = Environment.get("DB_NAME") else {
        fatalError("Database configuration is missing")
    }

    app.databases.use(.postgres(
        hostname: dbHost,
        username: dbUser,
        password: dbPassword,
        database: dbName
    ), as: .psql)

    // Redis configuration
    if let redisURL = Environment.get("REDIS_URL") {
        app.redis.configuration = try RedisConfiguration(url: redisURL)
    }

    // Rest of your configuration...
}
```

## Automating GitHub Secrets Management Using the GitHub API

Automating the management of GitHub Secrets using the GitHub API allows you to programmatically add, update, and remove secrets from your repositories. This can be particularly useful for integrating secret management into your CI/CD pipelines or other automation workflows.

### GitHub API for Secrets Management

The GitHub API provides endpoints for managing secrets in your repositories. Here's a brief overview of the key steps involved:

1. **Authenticate to the GitHub API**: Use a personal access token (PAT) with appropriate scopes.
2. **Get the public key**: Before adding or updating a secret, you need to get the repository’s public key.
3. **Encrypt the secret**: Use the public key to encrypt the secret value.
4. **Add or update a secret**: Use the encrypted value and the key ID to add or update the secret.

### Step-by-Step Guide

#### Step 1: Authenticate to the GitHub API

First, you need a personal access token with the `repo` scope for private repositories or `public_repo` for public repositories. Generate this token from your GitHub account settings under Developer settings.

#### Step 2: Get the Repository’s Public Key

Each repository has a unique public key used to encrypt secrets. To get this public key, make a GET request to the `/repos/{owner}/{repo}/actions/secrets/public-key` endpoint.

Example using `curl`:

```sh
REPO_OWNER="owner"
REPO_NAME="repo"
GITHUB_TOKEN="your_personal_access_token"

curl -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/secrets/public-key
```

The response will contain the `key_id` and the `key`:

```json
{
  "key_id": "012345678912345678",
  "key": "base64-encoded-public-key"
}
```

#### Step 3: Encrypt the Secret

Use the public key to encrypt your secret. You can use `libsodium` for encryption. First, you need to install `libsodium` if it's not already installed.

#### Install `libsodium` (if not already installed)


```sh
# On Ubuntu/Debian
sudo apt-get install libsodium-dev

# On macOS using Homebrew
brew install libsodium
```

#### Encrypt the Secret

```sh
PUBLIC_KEY="base64-encoded-public-key"
SECRET_VALUE="your_secret_value"
ENCRYPTED_SECRET=$(echo -n "$SECRET_VALUE" | sodium-encrypt "$PUBLIC_KEY" | base64)
```

Here, `sodium-encrypt` is a simple utility that uses `libsodium` to encrypt data with a given public key.

#### Create `sodium-encrypt` utility

You need a small script to handle encryption with `libsodium`.

1. Create a file named `sodium-encrypt` with the following content:

```sh
#!/bin/bash
# sodium-encrypt
# Usage: echo -n "secret" | ./sodium-encrypt "base64-public-key"
PUBLIC_KEY=$1
read -r SECRET_VALUE
echo -n "$SECRET_VALUE" | openssl base64 -d | openssl pkeyutl -encrypt -inkey <(echo -n "$PUBLIC_KEY" | base64 -d) -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256 | openssl base64
```

2. Make the script executable:

```sh
chmod +x sodium-encrypt
```

#### Step 4: Add or Update a Secret

Make a PUT request to the `/repos/{owner}/{repo}/actions/secrets/{secret_name}` endpoint with the encrypted value and the key ID.

```sh
SECRET_NAME="SECRET_NAME"
KEY_ID="012345678912345678"
ENCRYPTED_SECRET="encrypted_value"

curl -X PUT -H "Authorization: token $GITHUB_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/secrets/$SECRET_NAME \
     -d "{\"encrypted_value\":\"$ENCRYPTED_SECRET\",\"key_id\":\"$KEY_ID\"}"
```

### Putting It All Together

Here's a complete script to automate the process:

```sh
#!/bin/bash

# Configuration
REPO_OWNER="owner"
REPO_NAME="repo"
GITHUB_TOKEN="your_personal_access_token"
SECRET_NAME="SECRET_NAME"
SECRET_VALUE="your_secret_value"

# Get the public key for the repository
response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/secrets/public-key)

KEY_ID=$(echo "$response" | jq -r .key_id)
PUBLIC_KEY=$(echo "$response" | jq -r .key)

# Encrypt the secret
ENCRYPTED_SECRET=$(echo -n "$SECRET_VALUE" | ./sodium-encrypt "$PUBLIC_KEY" | base64)

# Add or update the secret
curl -X PUT -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/secrets/$SECRET_NAME \
    -d "{\"encrypted_value\":\"$ENCRYPTED_SECRET\",\"key_id\":\"$KEY_ID\"}"

echo "Secret $SECRET_NAME has been added/updated successfully."
```

### Explanation

1. **Configuration**: Set the `REPO_OWNER`, `REPO_NAME`, `GITHUB_TOKEN`, `SECRET_NAME`, and `SECRET_VALUE` variables.
2. **Get the Public Key**: Fetch the repository’s public key using the GitHub API.
3. **Encrypt the Secret**: Use the `sodium-encrypt` script to encrypt the secret value with the repository's public key.
4. **Add or Update the Secret**: Use the GitHub API to add or update the secret in the repository.

### Comprehensive Git Commit Message

```plaintext
feat: Automate GitHub Secrets Management with Shell Scripts

- Added shell script to automate the management of GitHub Secrets.
- Script includes steps to:
  - Fetch the repository's public key from the GitHub API.
  - Encrypt secret values using libsodium and a custom encryption utility.
  - Add or update secrets in the GitHub repository using the GitHub API.
- Created `sodium-encrypt` utility for handling encryption with libsodium.
- Updated README with instructions on configuring and using the script.
- Ensured secure handling and automation of sensitive information in CI/CD workflows.

This commit enhances security and automation by integrating seamless secrets management into the development process.
```

This documentation provides a detailed guide on how to manage GitHub Secrets for a Vapor application, including automated management using shell commands and the GitHub API.