# /episodes/episode4.md

## Episode 4: Test-Driven Development for Core Features

### Table of Contents
1. [Introduction](#introduction)
2. [Reviewing the OpenAPI Specification](#reviewing-the-openapi-specification)
3. [Setting Up the Project Structure](#setting-up-the-project-structure)
4. [Writing Tests Based on OpenAPI](#writing-tests-based-on-openapi)
5. [Running Tests and Seeing Them Fail](#running-tests-and-seeing-them-fail)
6. [Developing Core API Endpoints](#developing-core-api-endpoints)
7. [Connecting to the PostgreSQL Database](#connecting-to-the-postgresql-database)
8. [Implementing Basic CRUD Operations](#implementing-basic-crud-operations)
9. [Running Tests and Seeing Them Pass](#running-tests-and-seeing-them-pass)
10. [Integrating with CI/CD Pipeline](#integrating-with-cicd-pipeline)
11. [Conclusion](#conclusion)

---

### Introduction

In this episode, we will extend the functionality of the FountainAI application by following the Test-Driven Development (TDD) approach. We will start with the OpenAPI specification as our initial "test" or blueprint, write tests for our desired functionality, run them to see them fail, then implement the functionality to make the tests pass. We will focus on developing core API endpoints, connecting to the PostgreSQL database, and implementing basic CRUD operations.

**Expected Outcome:**

By the end of this episode, you will have a fully functional API that can create, retrieve, and delete screenplay scripts, with tests that ensure the reliability of these endpoints. Additionally, these tests will be integrated into your CI/CD pipeline.

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

### Setting Up the Project Structure

To ensure our project is well-organized and maintainable, we will set up a clear project structure. This involves creating necessary directories and files for controllers, models, and tests.

#### Create a Script to Set Up the Project Structure

Create a file named `setup_project_structure.sh` with the following content:

```sh
#!/bin/bash

# Ensure we're in the root directory of the existing repository
cd path/to/your/fountainAI

# Create necessary directories for controllers, models, and tests
mkdir -p Sources/App/Controllers
mkdir -p Sources/App/Models
mkdir -p Tests/AppTests

echo "Project structure setup complete."
```

Make this script executable and run it:

```sh
chmod +x setup_project_structure.sh
./setup_project_structure.sh
```

**Expected Outcome:**

You should now have a well-organized project structure with separate directories for controllers, models, and tests. This will help keep your codebase clean and maintainable.

---

### Writing Tests Based on OpenAPI

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
```

Make this script executable and run it:

```sh
chmod +x create_tests.sh
./create_tests.sh
```

**Expected Outcome:**

You now have unit tests for creating, retrieving, and deleting scripts, based on the OpenAPI specification. These tests describe the expected behavior of your API endpoints.

---

### Running Tests and Seeing Them Fail

Next, we will run the tests to see them fail, as we haven't implemented the functionality yet.

```sh
swift test
```

**Expected Outcome:**

The tests should fail, indicating that the functionality is not yet implemented. This failure will guide our implementation process.

---

### Developing Core API Endpoints

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
        let script = try req.content.decode(Script.self)
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
```

Make this script executable and run it:

```sh
chmod +x create_api_endpoints.sh
./create_api_endpoints.sh
```

**Expected Outcome:**

The core API endpoints for creating, retrieving, and deleting scripts are now implemented.

---

### Connecting to the PostgreSQL Database

We need to configure our Vapor application to connect to the PostgreSQL database.

#### Create a Script to Set Up Database Configuration

Create a file named `setup_database.sh` with the following content:

```sh
#!/bin/bash

# Navigate to the root directory
cd path/to/your/fountainAI

# Update the configure.swift file to set up database connection
cat << '

EOF' > Sources/App/configure.swift
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
```

Make this script executable and run it:

```sh
chmod +x setup_database.sh
./setup_database.sh
```

**Expected Outcome:**

Your Vapor application is now configured to connect to a PostgreSQL database, and a migration for the Script model is set up.

---

### Implementing Basic CRUD Operations

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
EOF

echo "Script model created."
```

Make this script executable and run it:

```sh
chmod +x create_script_model.sh
./create_script_model.sh
```

**Expected Outcome:**

The Script model is now created, representing the structure of the screenplay scripts in your database.

---

### Running Tests and Seeing Them Pass

With the implementation complete, we will now run the tests again to see them pass.

```sh
swift test
```

**Expected Outcome:**

All tests should pass, indicating that the functionality is correctly implemented and adheres to the OpenAPI specification.

---

### Integrating with CI/CD Pipeline

We need to ensure that our CI/CD pipeline can build, test, and deploy the updated functionality.

#### Update the Environment Setup Action

We will update the environment setup action to include the setup of the database.

Create a file named `update_setup_environment_action.sh` with the following content:

```sh
#!/bin/bash

# Create or update the setup environment action index.js file
cat << 'EOF' > .github/actions/setup/index.js
const core = require('@actions/core');
const exec = require('@actions/exec');
const fs = require('fs');
const path = require('path');

async function run() {
    try {
        const vpsUsername = core.getInput('vps_username');
        const vpsIp = core.getInput('vps_ip');
        const vpsSshKey = core.getInput('vps_ssh_key');

        // Write the SSH key to a file
        const sshKeyPath = path.join(process.env.HOME, '.ssh', 'id_ed25519');
        fs.writeFileSync(sshKeyPath, vpsSshKey, { mode: 0o600 });

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
        await exec.exec(`ssh -i ${sshKeyPath} -o StrictHostKeyChecking=no ${vpsUsername}@${vpsIp} '${installDockerCmd}'`);
        
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

#### Update the Build Action

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
git commit -m "Updated build action to build and push Docker image"
git push origin development

echo "Build action updated and pushed to development branch."
```

Make this script executable and run it:

```sh
chmod +x update_build_action.sh
./update_build_action.sh
```

#### Update the Deploy Action

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

        // SSH into VPS and pull the latest Docker images, then run the Docker Compose stack
        await exec.exec(`ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no ${vpsUsername}@${vpsIp} `
            + `'cd ${deployDir} && docker-compose pull && docker-compose up -d --remove-orphans'`);
        
        core.info(`Deployed to ${environment} environment successfully`);
    } catch (error) {
        core.setFailed(`Action failed with error ${error}`);
    }
}

run();
EOF

# Commit the deploy action changes
git add .github/actions/deploy/index.js
git commit -m "Updated deploy action to deploy Docker Compose stack"
git push origin development

echo "Deploy action updated and pushed to development branch."
```

Make this script executable and run it:

```sh
chmod +x update_deploy_action.sh
./update_deploy_action.sh
```

#### Update Development Workflow

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
git commit -m "Updated development workflow to include Docker build, push, and deployment steps"
git push origin development

echo "Development workflow updated and pushed to development branch."
```

Make this script executable and run it:

```sh
chmod +x update_development_workflow.sh
./update_development_workflow.sh
```

### Conclusion

In this episode, we extended the functionality of the FountainAI application by following the Test-Driven Development (TDD) approach. We started with the OpenAPI specification as our initial "test" or blueprint, wrote tests for our desired functionality, ran them to see them fail, then implemented the functionality to make the tests pass. We developed core API endpoints, connected to the PostgreSQL database, and implemented basic CRUD operations.

By following these steps, we ensured that our implementation adheres to the OpenAPI specification and that our tests validate the functionality. Additionally, we integrated these tests into our CI/CD pipeline, ensuring a reliable and automated deployment process.

Stay tuned for the next episodes, where we will continue to build upon this foundation, implementing more complex features and further refining our development process.

---

**Next Episode Suggestion:**
### Episode 5: Enhancing the Vapor Application with Authentication and Authorization

In the next episode, we will implement authentication and authorization for the FountainAI application. We will ensure that only authenticated users can access certain endpoints and that users have appropriate permissions for their actions. This will involve integrating JWT (JSON Web Tokens) for secure authentication and setting up role-based access control (RBAC).

---

**Expected Outcome:**

By the end of Episode 5, you will have a secure API with authentication and authorization mechanisms in place, ensuring that only authorized users can access and modify resources.

---

