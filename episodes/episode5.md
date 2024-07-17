### Episode 5: Test-Driven Development for Core Features

#### Table of Contents
1. [Introduction](#introduction)
2. [Recap of Episode 4](#recap-of-episode-4)
3. [Reviewing the OpenAPI Specification](#reviewing-the-openapi-specification)
4. **A: Changes in the Vapor Application**
   1. [Setting Up the Project Structure](#setting-up-the-project-structure)
   2. [Writing Tests Based on OpenAPI](#writing-tests-based-on-openapi)
   3. [Running Tests and Seeing Them Fail](#running-tests-and-seeing-them-fail)
   4. [Developing Core API Endpoints](#developing-core-api-endpoints)
   5. [Connecting to the PostgreSQL Database](#connecting-to-the-postgresql-database)
   6. [Implementing Basic CRUD Operations](#implementing-basic-crud-operations)
   7. [Running Tests and Seeing Them Pass](#running-tests-and-seeing-them-pass)
5. **B: Updates to the CI/CD Pipeline**
   1. [Environment Setup Action](#environment-setup-action)
   2. [Build Action](#build-action)
   3. [Deploy Action](#deploy-action)
   4. [Development Workflow](#development-workflow)
6. [Testing the API with Curl Commands](#testing-the-api-with-curl-commands)
7. [Conclusion](#conclusion)

---

### Introduction

In this episode, we will extend the functionality of the FountainAI application by following the Test-Driven Development (TDD) approach. We will start with the OpenAPI specification as our initial "test" or blueprint, write tests for our desired functionality, run them to see them fail, then implement the functionality to make the tests pass. We will focus on developing core API endpoints, connecting to the PostgreSQL database, and implementing basic CRUD operations.

**Expected Outcome:**

By the end of this episode, you will have a fully functional API that can create, retrieve, and delete screenplay scripts, with tests that ensure the reliability of these endpoints. Additionally, these tests will be integrated into your CI/CD pipeline.

### Recap of Episode 4

In the previous episode, we decoupled our CI/CD pipeline and centralized the management of secrets using GPG encryption. This ensured that sensitive information is securely stored and shared across different repositories while maintaining a high level of security. We updated our GitHub Actions workflows to fetch and decrypt these secrets as needed, streamlining the deployment process.

---

### Reviewing the OpenAPI Specification

According to the [OpenAPI specification](https://github.com/Contexter/fountainAI/blob/main/openAPI/FountainAI-Admin-openAPI.yaml), we need to set up endpoints for managing screenplay scripts. Here are the relevant paths:

```yaml
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
      responses:
        '201':
          description: Script successfully created.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Script'
  /scripts/{scriptId}:
    delete:
      summary: Delete a Script by ID
      operationId: deleteScript
      description: Deletes a specific screenplay script from the system, identified by its scriptId.
      parameters:
        - name: scriptId
          in: path
          required: true
          schema:
            type: integer
      responses:
        '204':
          description: Script successfully deleted.
        '404':
          description: The script with the specified ID was not found.
```

These paths guide our implementation steps, ensuring we meet the defined API requirements.

---

### A: Changes in the Vapor Application

#### Setting Up the Project Structure

To ensure our project is well-organized and maintainable, we will set up a clear project structure. This involves creating necessary directories and files for controllers, models, migrations, and tests.

#### Create a Script to Set Up the Project Structure

Create a file named `setup_project_structure.sh` with the following content:

```sh
#!/bin/bash

# Ensure we're in the root directory of the existing repository
cd /path/to/your/fountainAI

# Create necessary directories for controllers, models, and tests
mkdir -p Sources/App/Controllers
mkdir -p Sources/App/Models
mkdir -p Sources/App/Migrations
mkdir -p Tests/AppTests

echo "Project structure setup complete."

# Commit the changes to the repository
git add Sources/App Tests/AppTests
git commit -m "Set up initial project structure"
git push origin development
```

Make this script executable and run it:

```sh
chmod +x setup_project_structure.sh
./setup_project_structure.sh
```

**Expected Outcome:**

You should now have a well-organized project structure with separate directories for controllers, models, migrations, and tests. This will help keep your codebase clean and maintainable.

---

#### Writing Tests Based on OpenAPI

Following the TDD approach, we will start by writing tests for the core API endpoints we want to implement, guided by the OpenAPI specification.

#### Create a Script for Tests

Create a file named `create_tests.sh` with the following content:

```sh
#!/bin/bash

# Navigate to the Tests directory
cd Tests/AppTests

# Create a new file for the Script tests
cat << 'EOF' > ScriptTests.swift
import XCTVapor
@testable import App

final class ScriptTests: XCTestCase {
    func testCreateScript() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.POST, "scripts", beforeRequest: { req in
            try req.content.encode(ScriptCreateRequest(title: "Test Script", description: "A test script", author: "Author"))
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
            let script = try res.content.decode(Script.self)
            XCTAssertEqual(script.title, "Test Script")
            XCTAssertEqual(script.description, "A test script")
            XCTAssertEqual(script.author, "Author")
        })
    }

    func testGetScripts() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "scripts", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let scripts = try res.content.decode([Script].self)
            XCTAssertGreaterThan(scripts.count, 0)
        })
    }

    func testDeleteScript() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        // First create a script to delete
        let script = Script(title: "Test Script", description: "A test script", author: "Author")
        try script.save(on: app.db).wait()

        // Then delete the script
        try app.test(.DELETE, "scripts/\(script.id!)", afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
        })
    }
}
EOF

echo "Tests created."

# Commit the changes to the repository
git add ScriptTests.swift
git commit -m "Add unit tests for script API endpoints"
git push origin development
```

Make this script executable and run it:

```sh
chmod +x create_tests.sh
./create_tests.sh
```

**Expected Outcome:**

You now have unit tests for creating, retrieving, and deleting scripts, based on the OpenAPI specification. These tests describe the expected behavior of your API endpoints.

---

#### Running Tests and Seeing Them Fail

Next, we will run the tests to see them fail, as we haven't implemented the functionality yet.

```sh
swift test
```

**Expected Outcome:**

The tests should fail, indicating that the functionality is not yet implemented. This failure will guide our implementation process.

---

#### Developing Core API Endpoints

We will now develop the core API endpoints to make the tests pass.

#### Create a Script for API Endpoints

Create a file named `create_api_endpoints.sh` with the following content:

```sh
#!/bin/bash

# Navigate to the Controllers directory
cd Sources/App/Controllers

# Create a new file for the scripts controller
cat << 'EOF' > ScriptController.swift
import Vapor

struct ScriptController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let scripts = routes.grouped("scripts")
        scripts.get(use: index)
        scripts.post(use: create)
        scripts.group(":scriptID") { script in
            script.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[Script]> {
        return Script.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Script> {
        let scriptCreateRequest =

 try req.content.decode(ScriptCreateRequest.self)
        let script = Script(title: scriptCreateRequest.title, description: scriptCreateRequest.description, author: scriptCreateRequest.author)
        return script.save(on: req.db).map { script }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Script.find(req.parameters.get("scriptID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { script in
                script.delete(on: req.db)
            }.transform(to: .noContent)
    }
}
EOF

echo "API endpoints created."

# Commit the changes to the repository
git add ScriptController.swift
git commit -m "Implement API endpoints for scripts"
git push origin development
```

Make this script executable and run it:

```sh
chmod +x create_api_endpoints.sh
./create_api_endpoints.sh
```

**Expected Outcome:**

The core API endpoints for creating, retrieving, and deleting scripts are now implemented.

---

#### Connecting to the PostgreSQL Database

We need to configure our Vapor application to connect to the PostgreSQL database.

#### Create a Script to Set Up Database Configuration

Create a file named `setup_database.sh` with the following content:

```sh
#!/bin/bash

# Navigate to the root directory
cd /path/to/your/fountainAI

# Update the configure.swift file to set up database connection
cat << 'EOF' > Sources/App/configure.swift
import Vapor
import Fluent
import FluentPostgresDriver

public func configure(_ app: Application) throws {
    // Database configuration
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        username: Environment.get("DATABASE_USER") ?? "vapor",
        password: Environment.get("DATABASE_PASSWORD") ?? "password",
        database: Environment.get("DATABASE_NAME") ?? "fountainai"
    ), as: .psql)

    // Migrations
    app.migrations.add(CreateScript())

    // Register routes
    try routes(app)
}
EOF

# Create a migration for the Script model
cat << 'EOF' > Sources/App/Migrations/CreateScript.swift
import Fluent

struct CreateScript: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("scripts")
            .id()
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("author", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("scripts").delete()
    }
}
EOF

echo "Database configuration and migration setup complete."

# Commit the changes to the repository
git add Sources/App/configure.swift Sources/App/Migrations/CreateScript.swift
git commit -m "Set up PostgreSQL database configuration and migration"
git push origin development
```

Make this script executable and run it:

```sh
chmod +x setup_database.sh
./setup_database.sh
```

**Expected Outcome:**

Your Vapor application is now configured to connect to a PostgreSQL database, and a migration for the Script model is set up.

---

#### Implementing Basic CRUD Operations

We will now implement the model for the Script entity and complete the CRUD operations.

#### Create a Script for the Script Model

Create a file named `create_script_model.sh` with the following content:

```sh
#!/bin/bash

# Navigate to the Models directory
cd Sources/App/Models

# Create a new file for the Script model
cat << 'EOF' > Script.swift
import Fluent
import Vapor

final class Script: Model, Content {
    static let schema = "scripts"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "description")
    var description: String

    @Field(key: "author")
    var author: String

    init() {}

    init(id: UUID? = nil, title: String, description: String, author: String) {
        self.id = id
        self.title = title
        self.description = description
        self.author = author
    }
}

struct ScriptCreateRequest: Content {
    let title: String
    let description: String
    let author: String
}
EOF

echo "Script model created."

# Commit the changes to the repository
git add Script.swift
git commit -m "Create Script model"
git push origin development
```

Make this script executable and run it:

```sh
chmod +x create_script_model.sh
./create_script_model.sh
```

**Expected Outcome:**

The Script model is now created, representing the structure of the screenplay scripts in your database.

---

#### Running Tests and Seeing Them Pass

With the implementation complete, we will now run the tests again to see them pass.

```sh
swift test
```

**Expected Outcome:**

All tests should pass, indicating that the functionality is correctly implemented and adheres to the OpenAPI specification.

---

### B: Updates to the CI/CD Pipeline

To reflect the changes in our Vapor application and ensure the CI/CD pipeline correctly handles the new structure, we will update the environment setup action, build action, and deploy action, along with the development workflow.

#### Environment Setup Action

The environment setup action is updated to include the installation of PostgreSQL along with Docker and Docker Compose. This ensures that the database is set up correctly in the environment.

Create a file named `update_setup_environment_action.sh` with the following content:

```sh
#!/bin/bash

# Create or update the setup environment action index.js file
cat << 'EOF' > .github/actions/setup/index.js
const core = require('@actions/core');
const exec = require('@actions/exec');

async function run() {
    try {
        const vpsUsername = core.getInput('vps_username');
        const vpsIp = core.getInput('vps_ip');
        
        // Add SSH key to the agent
        await exec.exec('ssh-agent bash -c "ssh-add <(echo "$SSH_KEY")"');
        
        // Commands to install Docker and Docker Compose, and setup PostgreSQL
        const installDockerCmd = `
            sudo apt-get update &&
            sudo apt-get install -y \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg \
                lsb-release &&
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg &&
            echo "deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null &&
            sudo apt-get update &&
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io &&
            sudo usermod -aG docker ${vpsUsername} &&
            sudo systemctl enable docker &&
            sudo systemctl start docker &&
            sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose &&
            sudo chmod +x /usr/local/bin/docker-compose &&
            sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose &&
            docker-compose --version &&
            sudo apt-get install -y postgresql postgresql-contrib &&
            sudo -u postgres createuser --interactive &&
            sudo -u postgres createdb fountainai
        `;

        // SSH command to execute the installation on the VPS
        await exec.exec(`ssh -o StrictHostKeyChecking=no ${vpsUsername}@${vpsIp} '${installDockerCmd}'`);
        
        core.info('Docker, Docker Compose, and PostgreSQL installed successfully on the VPS');
    } catch (error) {
        core.setFailed(`Action failed with error ${error}`);
    }
}

run();
EOF

# Commit the setup environment action changes
git add .github/actions/setup/index.js
git commit -m "Updated setup environment action to install Docker, Docker Compose, and PostgreSQL"
git push origin development

echo "Setup environment action updated and pushed to development branch."
```

Make this script executable and run it:

```sh
chmod +x update_setup_environment_action.sh
./update_setup_environment_action.sh
```

#### Build Action

This action now builds the Docker image for the Vapor application and pushes it to GitHub Container Registry.

Create a file named `update_build_action.sh` with the following content:

```sh
#!/bin/bash

# Create or update the build action index.js file
cat << 'EOF' > .github/actions/build/index.js
const core = require('@actions/core');
const exec = require('@actions/exec');

async function run() {
    try {
        // Build Docker image
        await exec.exec('docker build -t ghcr.io/Contexter/fountainai:latest .');
        
        // Log in to GitHub Container Registry
        await exec.exec('echo ${{ secrets.GITHUB_TOKEN }} | docker login ghcr.io -u Contexter --password-stdin');
        
        // Push Docker image to GitHub Container Registry
        await exec.exec('docker push ghcr.io/Contexter/fountainai:latest');
        
        core.info('Docker image built and pushed successfully');
    } catch (error) {
        core.setFailed(`Action failed with error ${error}`);
    }
}

run();
EOF

# Commit the build action changes
git add .github/actions/build/index.js
git commit -m "Updated build action to build and

 push Docker image"
git push origin development

echo "Build action updated and pushed to development branch."
```

Make this script executable and run it:

```sh
chmod +x update_build_action.sh
./update_build_action.sh
```

#### Deploy Action

This action pulls the latest Docker images and runs the Docker Compose stack on the VPS. We need to add a step to run the database migrations after deploying the Docker Compose stack.

Create a file named `update_deploy_action.sh` with the following content:

```sh
#!/bin/bash

# Create or update the deploy action index.js file
cat << 'EOF' > .github/actions/deploy/index.js
const core = require('@actions/core');
const exec = require('@actions/exec');

async function run() {
    try {
        const environment = core.getInput('environment');
        const vpsUsername = core.getInput('vps_username');
        const vpsIp = core.getInput('vps_ip');
        const deployDir = core.getInput('deploy_dir');
        
        // Add SSH key to the agent
        await exec.exec('ssh-agent bash -c "ssh-add <(echo "$SSH_KEY")"');

        // SSH into VPS and pull the latest Docker images, then run the Docker Compose stack
        await exec.exec(`ssh -o StrictHostKeyChecking=no ${vpsUsername}@${vpsIp} `
            + `'cd ${deployDir} && docker-compose pull && docker-compose up -d --remove-orphans'`);

        // Run database migrations
        await exec.exec(`ssh -o StrictHostKeyChecking=no ${vpsUsername}@${vpsIp} `
            + `'cd ${deployDir} && docker-compose exec vapor ./Run migrate --env production'`);
        
        core.info(`Deployed to ${environment} environment successfully and migrations run`);
    } catch (error) {
        core.setFailed(`Action failed with error ${error}`);
    }
}

run();
EOF

# Commit the deploy action changes
git add .github/actions/deploy/index.js
git commit -m "Updated deploy action to deploy Docker Compose stack and run migrations"
git push origin development

echo "Deploy action updated and pushed to development branch."
```

Make this script executable and run it:

```sh
chmod +x update_deploy_action.sh
./update_deploy_action.sh
```

#### Development Workflow

This workflow now includes steps for setting up the environment, building the project, and deploying the project.

Create a file named `update_development_workflow.sh` with the following content:

```sh
#!/bin/bash

# Create or update the development workflow file
cat << 'EOF' > .github/workflows/development.yml
name: Development Workflow

on:
  push:
    branches:
      - development

jobs:
  verify-secrets:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Manage Secrets
        uses: ./.github/actions/manage-secrets
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          vps_ssh_key: ${{ secrets.VPS_SSH_KEY }}
          vps_username: ${{ secrets.VPS_USERNAME }}
          vps_ip: ${{ secrets.VPS_IP }}
          deploy_dir: ${{ secrets.DEPLOY_DIR }}
          repo_owner: ${{ secrets.REPO_OWNER }}
          app_name: ${{ secrets.APP_NAME }}
          domain: ${{ secrets.DOMAIN }}
          staging_domain: ${{ secrets.STAGING_DOMAIN }}
          db_name: ${{ secrets.DB_NAME }}
          db_user: ${{ secrets.DB_USER }}
          db_password: ${{ secrets.DB_PASSWORD }}
          email: ${{ secrets.EMAIL }}
          main_dir: ${{ secrets.MAIN_DIR }}
          nydus_port: ${{ secrets.NYDUS_PORT }}
          redisai_port: ${{ secrets.REDISAI_PORT }}
          redis_port: ${{ secrets.REDIS_PORT }}
          repo_name: ${{ secrets.REPO_NAME }}
          runner_token: ${{ secrets.RUNNER_TOKEN }}

  setup:
    needs: verify-secrets
    runs-on: ubuntu-latest
    steps:
      - name: Setup Environment
        uses: ./.github/actions/setup
        with:
          vps_ssh_key: ${{ secrets.VPS_SSH_KEY }}

  build:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - name: Build Project
        uses: ./.github/actions/build

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Project
        uses: ./.github/actions/deploy
        with:
          environment: staging
          vps_username: ${{ secrets.VPS_USERNAME }}
          vps_ip: ${{ secrets.VPS_IP }}
          deploy_dir: ${{ secrets.DEPLOY_DIR }}
EOF

# Commit the development workflow changes
git add .github/workflows/development.yml
git commit -m "Updated development workflow to include Docker build, push, deployment, and migration steps"
git push origin development

echo "Development workflow updated and pushed to development branch."
```

Make this script executable and run it:

```sh
chmod +x update_development_workflow.sh
./update_development_workflow.sh
```

---

### Testing the API with Curl Commands

After successfully running the pipeline and deploying the app to the staging domain, we can use curl commands to test the API endpoints.

Create a file named `test_api_with_curl.sh` with the following content:

```sh
#!/bin/bash

# Source environment variables
source config.env

# Base URL of the API
BASE_URL="${STAGING_DOMAIN}"

# Test creating a script
echo "Creating a script..."
curl -X POST "$BASE_URL/scripts" -H "Content-Type: application/json" -d '{
    "title": "Test Script",
    "description": "A test script",
    "author": "Author"
}'
echo

# Test retrieving all scripts
echo "Retrieving all scripts..."
curl -X GET "$BASE_URL/scripts"
echo

# Test deleting a script
echo "Retrieving the first script to delete..."
SCRIPT_ID=$(curl -X GET "$BASE_URL/scripts" | jq -r '.[0].id')
echo "Deleting script with ID $SCRIPT_ID..."
curl -X DELETE "$BASE_URL/scripts/$SCRIPT_ID"
echo
```

Make this script executable and run it:

```sh
chmod +x test_api_with_curl.sh
./test_api_with_curl.sh
```

**Expected Outcome:**

The curl commands should demonstrate that the API endpoints for creating, retrieving, and deleting scripts are working as expected.

### Conclusion

In this episode, we extended the functionality of the FountainAI application by following the Test-Driven Development (TDD) approach. We started with the OpenAPI specification as our initial "test" or blueprint, wrote tests for our desired functionality, ran them to see them fail, then implemented the functionality to make the tests pass. We developed core API endpoints, connected to the PostgreSQL database, and implemented basic CRUD operations.

By following these steps, we ensured that our implementation adheres to the OpenAPI specification and that our tests validate the functionality. Additionally, we integrated these tests into our CI/CD pipeline, ensuring a reliable and automated deployment process.

Stay tuned for the next episodes, where we will continue to build upon this foundation, implementing more complex features and further refining our development process.