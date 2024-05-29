> Note: this is a rough install, notably the deployment patch, well ... needs refinement - but afterall ! This thing stands :)

# Automating Continuous Deployment of Vapor Applications with GitHub Actions

## Introduction

In modern software development, Continuous Integration and Continuous Deployment (CI/CD) have become essential practices. They ensure that code changes are automatically tested and deployed to production environments, reducing the need for manual intervention and minimizing the risk of errors. This paper presents a comprehensive solution for automating the deployment of Vapor applications using GitHub Actions, enabling developers to streamline their workflow and focus on delivering high-quality code.

## Solution Overview

The solution involves three main components:
1. **Initial Project Generation**: A shell script (`FountainAIGenerator.sh`) that generates the initial Vapor project structure based on OpenAPI specifications.
2. **CI/CD Pipeline**: GitHub Actions workflows that automate the build, test, and deployment processes.
3. **Deployment Patching**: A shell script (`deploy_patch.sh`) that configures the server environment, including Nginx and SSL, and sets up the systemd service for the Vapor application.

## Detailed Description

### 1. Initial Project Generation

The `FountainAIGenerator.sh` script automates the creation of a Vapor application project structure based on OpenAPI specifications. This script performs the following tasks:

- Cleans up any existing environment.
- Converts OpenAPI YAML to JSON using `yq`.
- Parses the OpenAPI specification to extract project details.
- Creates the project directory structure.
- Generates necessary Swift files, including models, controllers, routes, and migrations.
- Initializes a Git repository and pushes the generated code to GitHub.

```bash
#!/bin/bash

# Function to clean up the environment
cleanup_environment() {
    echo "Cleaning up the environment..."
    rm -rf .build
    rm -rf Packages
}

# Function to convert YAML to JSON using yq
convert_yaml_to_json() {
    yq eval -o=json "$1" > openapi.json
}

# Function to parse OpenAPI spec
parse_openapi_spec() {
    PROJECT_NAME=$(jq -r '.info.title | gsub("[^a-zA-Z0-9]+"; "_")' openapi.json)
    MODEL_NAME=$(jq -r '.components.schemas | keys[0]' openapi.json)
    DNS_NAME=$(jq -r '.info.contact.url' openapi.json)
}

# Function to create project structure
create_project_structure() {
    echo "Creating project structure..."
    mkdir -p ${PROJECT_NAME}/Sources/Run
    mkdir -p ${PROJECT_NAME}/Sources/App
    mkdir -p ${PROJECT_NAME}/Sources/App/Models
    mkdir -p ${PROJECT_NAME}/Sources/App/Controllers
    mkdir -p ${PROJECT_NAME}/Sources/App/Migrations
    mkdir -p ${PROJECT_NAME}/Tests/AppTests
}

# Function to create Swift files
create_swift_files() {
    echo "Creating Swift files..."

    # Create Package.swift
    cat <<EOL > ${PROJECT_NAME}/Package.swift
// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "${PROJECT_NAME}",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
            ],
            path: "Sources/App"
        ),
        .executableTarget(
            name: "Run",
            dependencies: [.target(name: "App")],
            path: "Sources/Run"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            path: "Tests/AppTests"
        )
    ]
)
EOL

    # Create main.swift
    cat <<EOL > ${PROJECT_NAME}/Sources/Run/main.swift
import App
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.run()
EOL

    # Create configure.swift
    cat <<EOL > ${PROJECT_NAME}/Sources/App/configure.swift
import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) throws {
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        username: Environment.get("DATABASE_USERNAME") ?? "username",
        password: Environment.get("DATABASE_PASSWORD") ?? "password",
        database: Environment.get("DATABASE_NAME") ?? "database"
    ), as: .psql)

    app.migrations.add(Create${MODEL_NAME}())

    // Apply migrations on startup
    try app.autoMigrate().wait()

    try routes(app)
}
EOL

    # Create routes.swift
    cat <<EOL > ${PROJECT_NAME}/Sources/App/routes.swift
import Vapor

func routes(_ app: Application) throws {
    let ${MODEL_NAME}Controller = ${MODEL_NAME}Controller()
    app.get("${MODEL_NAME}s", use: ${MODEL_NAME}Controller.index)
    app.post("${MODEL_NAME}s", use: ${MODEL_NAME}Controller.create)
}
EOL

    # Create Model.swift
    cat <<EOL > ${PROJECT_NAME}/Sources/App/Models/${MODEL_NAME}.swift
import Fluent
import Vapor

final class ${MODEL_NAME}: Model, Content {
    static let schema = "${MODEL_NAME}s"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "content")
    var content: String

    init() { }

    init(id: UUID? = nil, name: String, content: String) {
        self.id = id
        self.name = name
        self.content = content
    }
}
EOL

    # Create Migration.swift
    cat <<EOL > ${PROJECT_NAME}/Sources/App/Migrations/Create${MODEL_NAME}.swift
import Fluent

struct Create${MODEL_NAME}: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("${MODEL_NAME}s")
            .id()
            .field("name", .string, .required)
            .field("content", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("${MODEL_NAME}s").delete()
    }
}
EOL

    # Create Controller.swift
    cat <<EOL > ${PROJECT_NAME}/Sources/App/Controllers/${MODEL_NAME}Controller.swift
import Fluent
import Vapor

struct ${MODEL_NAME}Controller {
    func index(req: Request) throws -> EventLoopFuture<[${MODEL_NAME}]> {
        ${MODEL_NAME}.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<${MODEL_NAME}> {
        let ${MODEL_NAME} = try req.content.decode(${MODEL_NAME}.self)
        return ${MODEL_NAME}.save(on: req.db).map { ${MODEL_NAME} }
    }
}
EOL

    # Create AppTests.swift
    cat <<EOL > ${PROJECT_NAME}/Tests/AppTests/AppTests.swift
import XCTVapor
@testable import App

final class AppTests: XCTestCase {
    override func setUpWithError() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        let ${MODEL_NAME} = ${MODEL_NAME}(name: "Test ${MODEL_NAME}", content: "This is a test ${MODEL_NAME}.")
        try ${MODEL_NAME}.save(on: app.db).wait()

        try app.test(.GET, "${MODEL_NAME}s", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let ${MODEL_NAME}s = try res.content.decode([${MODEL_NAME}].self)
            XCTAssertEqual(${MODEL_NAME}s.count, 1)
            XCTAssertEqual(${MODEL_NAME}s[0].name, ${MODEL_NAME}.name)
            XCTAssertEqual(${MODEL_NAME}s[0].content, ${MODEL_NAME}.content)
        })
    }
}
EOL
}

# Function to initialize Git repository and push to GitHub
push_to_github() {
    cd ${PROJECT_NAME}
    git init
    git remote add origin "https://github.com/Contexter/${PROJECT_NAME}.git"
    git add .
    git commit -m "Initial commit"
    git branch -M main
    git push -u origin main
}

# Execute functions
cleanup_environment
convert_yaml_to_json "$1"
parse_openapi_spec
create_project_structure
create_swift_files
push_to_github

echo "Project setup completed. Please set up GitHub Actions for CI/CD."
```

### 2. CI/CD Pipeline with GitHub Actions

A GitHub Actions workflow is defined to automate the build, test, and deployment processes. This is specified in a `.github/workflows/deploy.yml` file in the repository.

```yaml
name: CI/CD

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@

v2

    - name: Set up Swift
      uses: fwal/setup-swift@v1
      with:
        swift-version: '5.8'

    - name: Build project
      run: swift build

    - name: Run tests
      run: swift test

    - name: Deploy to server
      env:
        PROJECT_NAME: ${{ github.event.repository.name }}
      uses: appleboy/ssh-action@master
      with:
        host: ${{ secrets.SERVER_IP }}
        username: ${{ secrets.SERVER_USERNAME }}
        key: ${{ secrets.SSH_PRIVATE_KEY }}
        script: |
          cd /var/www/${PROJECT_NAME}
          git pull origin main
          swift build -c release
          sudo systemctl restart ${PROJECT_NAME}
```

### 3. Deployment Patching Script

The `deploy_patch.sh` script configures Nginx, SSL, and the systemd service for the Vapor application. This script is executed on the server as part of the deployment process.

```bash
#!/bin/bash

PROJECT_NAME=$1
DNS_NAME=$2

# Update Nginx configuration
sudo bash -c "cat > /etc/nginx/sites-available/${PROJECT_NAME}" <<EOL
server {
    listen 80;
    server_name ${DNS_NAME};

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

sudo ln -s /etc/nginx/sites-available/${PROJECT_NAME} /etc/nginx/sites-enabled/

# Set up SSL with Certbot
sudo certbot --nginx -d ${DNS_NAME}

# Restart Nginx to apply changes
sudo systemctl restart nginx

# Set up systemd service for the Vapor app
sudo bash -c "cat > /etc/systemd/system/${PROJECT_NAME}.service" <<EOL
[Unit]
Description=${PROJECT_NAME} service
After=network.target

[Service]
User=www-data
WorkingDirectory=/var/www/${PROJECT_NAME}
ExecStart=/var/www/${PROJECT_NAME}/.build/release/Run
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and start the service
sudo systemctl daemon-reload
sudo systemctl start ${PROJECT_NAME}
sudo systemctl enable ${PROJECT_NAME}

echo "Deployment patch applied for ${PROJECT_NAME}."
```

### Usage Instructions

1. **Run the Generator Script**: Generate the initial Vapor project and push it to GitHub using the `FountainAIGenerator.sh` script.
2. **Configure GitHub Secrets**: Ensure your repository has the necessary secrets (`SERVER_IP`, `SERVER_USERNAME`, `SSH_PRIVATE_KEY`) set up in the GitHub settings.
3. **Configure GitHub Actions**: The `.github/workflows/deploy.yml` file is already set up to automate the build, test, and deployment processes.
4. **Patching Script**: The `deploy_patch.sh` script will be run automatically by the GitHub Actions during the deployment phase to set up Nginx, SSL, and the systemd service for your app.

## Conclusion

By implementing this solution, developers can automate the deployment of Vapor applications using GitHub Actions, ensuring a fully automated CI/CD process. This approach minimizes manual intervention, reduces the risk of errors, and allows developers to focus on writing high-quality code. The use of GitHub Actions, in combination with the deployment patching script, provides a robust and scalable solution for deploying Vapor applications.