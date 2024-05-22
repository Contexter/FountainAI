### Introduction

**VaporAppDeploy** is a Swift command-line utility designed to automate the setup, deployment, and continuous integration/continuous deployment (CI/CD) of a Vapor application using Docker, Nginx, and Let's Encrypt. This tool simplifies the process of preparing your Vapor project for production by creating necessary directories, setting up the project, building the application, generating configuration files, and deploying the project in a Dockerized environment. It also handles the generation and renewal of SSL certificates using Let's Encrypt, ensuring that your application is securely accessible over HTTPS. Additionally, VaporAppDeploy includes functionality to set up a CI/CD pipeline using GitHub Actions, enabling automated builds, tests, and deployments.

### Flow Description

The `VaporAppDeploy` tool consists of multiple commands, each serving a specific purpose in the setup and deployment process. Here is an overview of the flow and functionality:

1. **Create Necessary Directories**:
   - Command: `create-directories`
   - This command creates the directory structure required for the Vapor project, including directories for controllers, models, and migrations.

2. **Set Up the Vapor Project**:
   - Command: `setup-vapor-project`
   - This command sets up the Vapor project by generating essential files such as `Package.swift`, `main.swift`, `configure.swift`, `routes.swift`, and model, migration, and controller files for a basic Script entity.

3. **Build the Vapor Application**:
   - Command: `build-vapor-app`
   - This command builds the Vapor application in release mode using Swift's build system.

4. **Run the Vapor Application Locally**:
   - Command: `run-vapor-local`
   - This command runs the Vapor application locally in development mode for testing purposes.

5. **Create the Docker Compose File**:
   - Command: `create-docker-compose-file`
   - This command generates a Docker Compose file from a template, substituting necessary environment variables from the configuration file to set up services such as Vapor, PostgreSQL, Redis, and Nginx.

6. **Create the Nginx Configuration File**:
   - Command: `create-nginx-config-file`
   - This command creates an Nginx configuration file from a template, setting up Nginx to act as a reverse proxy for the Vapor application and handle HTTPS traffic.

7. **Create the Certbot Script**:
   - Command: `create-certbot-script`
   - This command creates the directory structure for Certbot, downloads TLS parameters, and generates a script to obtain and renew SSL certificates from Let's Encrypt.

8. **Set Up the Entire Project**:
   - Command: `setup-project`
   - This command orchestrates the setup of the entire project by running the necessary commands to create directories, generate configuration files, and start the Docker containers. It also runs the Certbot script to obtain SSL certificates.

9. **Run the Master Script to Set Up and Deploy the Vapor Application**:
   - Command: `master-script`
   - This command combines the setup and deployment process into a single workflow. It performs all the steps from creating directories to running the project in production, ensuring that the Vapor application is fully set up and deployed.

10. **Set Up the GitHub Actions CI/CD Pipeline**:
    - Command: `setup-cicd-pipeline`
    - This command sets up the CI/CD pipeline by creating the necessary `.github/workflows/ci-cd-pipeline.yml` file. The GitHub Actions workflow builds and tests the Vapor application whenever code is pushed to the repository and deploys the application to a production environment if the tests pass.

By following this flow, VaporAppDeploy ensures a comprehensive and automated setup and deployment process, making it easier to manage and maintain Vapor applications in a production environment.

### Comprehensive Documentation and Usage Description

### Introduction

**VaporAppDeploy** is a Swift command-line utility designed to automate the setup and deployment of a Vapor application using Docker, Nginx, and Let's Encrypt. This tool simplifies the process of preparing your Vapor project for production by creating necessary directories, setting up the project, building the application, generating configuration files, and deploying the project in a Dockerized environment. It also handles the generation and renewal of SSL certificates using Let's Encrypt, ensuring that your application is securely accessible over HTTPS.

### Prerequisites

Before using the VaporAppDeploy tool, ensure you have the following installed on your system:

- Swift
- Docker
- Docker Compose
- Git

### Installation

1. Clone the repository:
   ```sh
   git clone <repository-url>
   cd vapor-app-deploy
   ```

2. Build the project:
   ```sh
   swift build -c release
   ```

### Configuration

The configuration is stored in `config/config.yaml`. Ensure this file is correctly set up before running the commands.

```yaml
# Example config.yaml
projectDirectory: "/path/to/your/project"
domain: "yourdomain.com"
email: "youremail@example.com"
database:
  host: "localhost"
  username: "postgres"
  password: "password"
  name: "scriptdb"
redis:
  host: "localhost"
  port: 6379
staging: 0
```

### Usage

Run the main command to see available subcommands:
```sh
swift run vaporappdeploy --help
```

### Available Commands

- `create-directories`: Create necessary directories for the project.
- `setup-vapor-project`: Set up the Vapor project.
- `build-vapor-app`: Build the Vapor application.
- `run-vapor-local`: Run the Vapor application locally.
- `create-docker-compose-file`: Create the Docker Compose file.
- `create-nginx-config-file`: Create the Nginx configuration file.
- `create-certbot-script`: Create the Certbot script.
- `setup-project`: Set up the entire project.
- `master-script`: Run the master script to set up and deploy the Vapor application.
- `setup-cicd-pipeline`: Set up the GitHub Actions CI/CD pipeline.

### Example Usage

1. **Create Necessary Directories**:
   ```sh
   swift run vaporappdeploy create-directories
   ```
   This command creates the necessary directory structure for the Vapor project, including directories for controllers, models, and migrations.

2. **Set Up the Vapor Project**:
   ```sh
   swift run vaporappdeploy setup-vapor-project
   ```
   This command sets up the Vapor project by generating essential files such as `Package.swift`, `main.swift`, `configure.swift`, `routes.swift`, and model, migration, and controller files for a basic Script entity.

3. **Build the Vapor Application**:
   ```sh
   swift run vaporappdeploy build-vapor-app
   ```
   This command builds the Vapor application in release mode using Swift's build system.

4. **Run the Vapor Application Locally**:
   ```sh
   swift run vaporappdeploy run-vapor-local
   ```
   This command runs the Vapor application locally in development mode for testing purposes.

5. **Create the Docker Compose File**:
   ```sh
   swift run vaporappdeploy create-docker-compose-file
   ```
   This command generates a Docker Compose file from a template, substituting necessary environment variables from the configuration file to set up services such as Vapor, PostgreSQL, Redis, and Nginx.

6. **Create the Nginx Configuration File**:
   ```sh
   swift run vaporappdeploy create-nginx-config-file
   ```
   This command creates an Nginx configuration file from a template, setting up Nginx to act as a reverse proxy for the Vapor application and handle HTTPS traffic.

7. **Create the Certbot Script**:
   ```sh
   swift run vaporappdeploy create-certbot-script
   ```
   This command creates the directory structure for Certbot, downloads TLS parameters, and generates a script to obtain and renew SSL certificates from Let's Encrypt.

8. **Set Up the Entire Project**:
   ```sh
   swift run vaporappdeploy setup-project
   ```
   This command orchestrates the setup of the entire project by running the necessary commands to create directories, generate configuration files, and start the Docker containers. It also runs the Certbot script to obtain SSL certificates.

9. **Run the Master Script to Set Up and Deploy the Vapor Application**:
   ```sh
   swift run vaporappdeploy master-script
   ```
   This command combines the setup and deployment process into a single workflow. It performs all the steps from creating directories to running the project in production, ensuring that the Vapor application is fully set up and deployed.

10. **Set Up the GitHub Actions CI/CD Pipeline**:
    ```sh
    swift run vaporappdeploy setup-cicd-pipeline
    ```
    This command sets up the CI/CD pipeline by creating the necessary `.github/workflows/ci-cd-pipeline.yml` file. The GitHub Actions workflow builds and tests the Vapor application whenever code is pushed to the repository and deploys the application to a production environment if the tests pass.

### CI/CD Pipeline Configuration

1. **Create a `.github/workflows` Directory** in the root of your project.
2. **Create a `ci-cd-pipeline.yml` File** inside the `.github/workflows` directory with the following content:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: password
          POSTGRES_DB: scriptdb
        ports:
          - 5432:5432
        options: >-
          --health-cmd="pg_isready -U postgres"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5

      redis:
        image: redis:latest
        ports:
          - 6379:6379
        options: >-
          --health-cmd="redis-cli ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Swift
        uses: fwal/setup-swift@v1

      - name: Install dependencies
        run: swift package resolve

      - name: Build project
        run: swift build -c release

      - name: Run tests
        run: swift test

  deploy:
    runs-on: ubuntu-latest
    needs: build

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Log in to Docker Hub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push Docker image
        run: |
          docker build -t ${{ secrets.DOCKER_USERNAME }}/vapor-app:latest .
          docker push ${{ secrets.DOCKER_USERNAME }}/vapor-app:latest

      - name: Deploy to production
        run: |
          ssh -o StrictHostKeyChecking=no ${{ secrets.SSH_USER }}@${{ secrets.SSH_HOST }} << 'EOF'
            docker pull ${{ secrets.DOCKER_USERNAME }}/vapor-app:latest
            docker-compose -f /path/to/your/project/docker-compose.yml up -d
          EOF
```

### Adding Secrets to GitHub

You need to add the following secrets to your GitHub repository for the workflow to access:

1. `DOCKER_USERNAME`: Your Docker Hub username.
2. `DOCKER_PASSWORD`: Your Docker Hub password.
3. `SSH_USER`: The SSH user for your production server.
4. `SSH_HOST`: The hostname or IP address of your production server.

### Conclusion

By integrating this CI/CD pipeline with GitHub Actions, we automate the build, test, and deployment process, ensuring that the Vapor application is always in a deployable state and that new features and bug fixes are delivered quickly to the production environment. This solution improves efficiency and enhances the reliability and maintainability of the application.

### Comprehensive Documentation with Code Comments

Here's the complete code for the `VaporAppDeploy` command-line utility with detailed comments suitable for documentation generation.

**Step 1: Update `Package.swift`**

Ensure that the `Package.swift` file includes the necessary dependencies and targets.

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "VaporAppDeploy",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/behrang/YamlSwift.git", from: "3.4.3")
    ],
    targets: [
        .executableTarget(
            name: "VaporAppDeploy",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yaml", package: "YamlSwift")
            ]
        )
    ]
)
```

**Step 2: Implement the Command-Line Application**

**Sources/VaporAppDeploy/main.swift**

```swift
import Foundation
import ArgumentParser
import Yaml

// MARK: - Configuration Structures

/// The main configuration structure for the application.
struct Config: Decodable {
    var projectDirectory: String
    var domain: String
    var email: String
    var database: DatabaseConfig
    var redis: RedisConfig
    var staging: Int
}

/// The configuration structure for the database settings.
struct DatabaseConfig: Decodable {
    var host: String
    var username: String
    var password: String
    var name: String
}

/// The configuration structure for the Redis settings.
struct RedisConfig: Decodable {
    var host: String
    var port: Int
}

// MARK: - Helper Functions

/// Reads and decodes the configuration file.
func readConfig() -> Config {
    let fileURL = URL(fileURLWithPath: "./config/config.yaml")
    guard let data = try? Data(contentsOf: fileURL) else {
        fatalError("Configuration file not found: ./config/config.yaml")
    }

    let decoder = YAMLDecoder()
    guard let config = try? decoder.decode(Config.self, from: data) else {
        fatalError("Failed to decode configuration file")
    }

    return config
}

/// Validates the project directory path.
func validateProjectDirectory(_ projectDir: String) {
    if projectDir.isEmpty {
        fatalError("Error: Project directory cannot be empty")
    }
}

/// Validates the domain name format.
func validateDomainName(_ domain: String) {
    let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
    if regex.firstMatch(in: domain, options: [], range: NSRange(location: 0, length: domain.count)) == nil {
        fatalError("Error: Invalid domain name")
    }
}

/// Validates the email address format.
func validateEmail(_ email: String) {
    let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
    if regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) == nil {
        fatalError("Error: Invalid email address")
    }
}

/// Runs a shell command with the specified arguments.
func runShellCommand(_ command: String, arguments: [String], workingDirectory: String? = nil) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: command)
    process.arguments = arguments
    if let workingDirectory = workingDirectory {
        process.currentDirectoryURL = URL(fileURLWithPath: workingDirectory)
    }

    do {
        try process.run()
        process.waitUntilExit()
    } catch {
        fatalError("Error: \(error.localizedDescription)")
    }
}

// MARK: - Command Line Application

/// The main command structure for the VaporAppDeploy utility.
struct VaporAppDeploy: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "vaporappdeploy",
        abstract: "A utility for deploying a Vapor application.",
        subcommands: [
            CreateDirectories.self,
            SetupVaporProject.self,
            BuildVaporApp.self,
            RunVaporLocal.self,
            CreateDockerComposeFile.self,
            CreateNginxConfigFile.self,
            CreateCertbotScript.self,
            SetupProject.self,
            MasterScript.self,
            SetupCiCdPipeline.self
        ]
    )
}

extension VaporAppDeploy {
    /// Command to create necessary directories for the project.
    struct CreateDirectories: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Create necessary directories for the project."
        )

        func run() {
            let config = readConfig()
            let projectDir = config.projectDirectory
            validateProjectDirectory(projectDir)

            let fileManager = FileManager.default
            let directories = [
                "\(projectDir)/Sources/App/Controllers",
                "\(projectDir)/Sources/App/Models",
                "\(projectDir)/Sources/App/Migrations"
            ]

            for dir in directories {
                if !fileManager.fileExists(atPath: dir) {
                    try! fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
                    print("Directory created at \(dir)")
                } else {
                    print("Directory already exists at \(dir)")
                }
            }
        }
    }

    /// Command to set up the Vapor project.
    struct SetupVaporProject: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Set up the Vapor project."
        )

        func run() {
            let config = readConfig()
            let projectDir = config.projectDirectory
            validateProjectDirectory(projectDir)

            createPackageSwift(projectDir)
            createMainSwift(projectDir)
            createConfigureSwift(projectDir)
            createRoutesSwift(projectDir)
            createScriptModel(projectDir)
            createScriptMigration(projectDir)
            createScriptController(projectDir)
        }

        /// Creates the Package.swift file.
        func createPackageSwift(_ projectDir: String) {
            let content = """
            // swift-tools-version:5.3
            import PackageDescription

            let package = Package(
                name: "VaporApp",
                platforms: [
                   .macOS(.v10_15)
                ],
                dependencies: [
                    .package(name: "vapor", url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
                    .package(name: "fluent", url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
                    .package(name: "fluent-postgres-driver", url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
                    .package(url: "https://github.com/vapor/redis.git", from: "4.0.0"),
                    .package(url: "https://github.com/RedisAI/redisai-vapor", from: "1.0.0")
                ],
                targets: [
                    .target(
                        name: "App",
                        dependencies: [
                            .product(name: "Vapor", package: "vapor"),
                            .product(name: "Fluent", package: "fluent"),
                            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                            .product(name: "Redis", package: "redis"),
                            .product(name: "RedisAI", package: "redisai-vapor")
                        ],
                        path: "Sources/App"
                    )
                ]
            )
            """

            try! content.write(toFile: "\(projectDir)/Package.swift", atomically: true, encoding: .utf8)
            print("Package.swift created.")
        }

        /// Creates the main.swift file.
        func createMainSwift(_ projectDir: String) {
            let content = """
            import Vapor

            var env = try Environment.detect()
            let app = Application(env)
            defer { app.shutdown() }
            try configure(app)
            try app.run()
            """

            try! content.write(toFile: "\(projectDir)/Sources/App/main.swift", atomically: true, encoding: .utf8)
            print("main.swift created.")
        }

        /// Creates the configure.swift file.
        func createConfigureSwift(_ projectDir: String) {
            let content = """
            import Vapor
            import Fluent
            import FluentPostgresDriver
            import Redis
            import RedisAI

            public func configure(_ app: Application) throws {
                // Database configuration
                app.databases.use(.postgres(
                    hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                    username: Environment.get("DATABASE_USERNAME") ?? "postgres",
                    password: Environment.get("DATABASE_PASSWORD") ?? "password",
                    database: Environment.get("DATABASE_NAME") ?? "scriptdb"
                ), as: .psql)

                // Redis configuration
                let redisConfig = RedisConfiguration(
                    hostname: Environment.get("REDIS_HOST") ?? "localhost",
                    port: Int(Environment.get("REDIS_PORT") ?? "6379")!
                )
                app.redis.configuration = redisConfig

                // Migrations
                app.migrations.add(CreateScript())

                // Register routes
                try routes(app)
            }
            """

            try! content.write(toFile: "\(projectDir)/Sources/App/configure.swift", atomically: true, encoding: .utf8)
            print("configure.swift created.")
        }

       

 /// Creates the routes.swift file.
        func createRoutesSwift(_ projectDir: String) {
            let content = """
            import Vapor

            func routes(_ app: Application) throws {
                let scriptController = ScriptController()

                app.get("scripts", use: scriptController.index)
                app.post("scripts", use: scriptController.create)
                app.get("scripts", ":scriptId", use: scriptController.show)
                app.put("scripts", ":scriptId", use: scriptController.update)
                app.delete("scripts", ":scriptId", use: scriptController.delete)

                app.get("health") { req -> String in
                    return "OK"
                }
            }
            """

            try! content.write(toFile: "\(projectDir)/Sources/App/routes.swift", atomically: true, encoding: .utf8)
            print("routes.swift created.")
        }

        /// Creates the Script model file.
        func createScriptModel(_ projectDir: String) {
            let content = """
            import Vapor
            import Fluent

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

                @Field(key: "sequence")
                var sequence: Int

                init() {}

                init(id: UUID? = nil, title: String, description: String, author: String, sequence: Int) {
                    self.id = id
                    self.title = title
                    self.description = description
                    self.author = author
                    self.sequence = sequence
                }
            }
            """

            try! content.write(toFile: "\(projectDir)/Sources/App/Models/Script.swift", atomically: true, encoding: .utf8)
            print("Script.swift created.")
        }

        /// Creates the migration file for the Script model.
        func createScriptMigration(_ projectDir: String) {
            let content = """
            import Fluent

            struct CreateScript: Migration {
                func prepare(on database: Database) -> EventLoopFuture<Void> {
                    return database.schema("scripts")
                        .id()
                        .field("title", .string, .required)
                        .field("description", .string, .required)
                        .field("author", .string, .required)
                        .field("sequence", .int, .required)
                        .create()
                }

                func revert(on database: Database) -> EventLoopFuture<Void> {
                    return database.schema("scripts").delete()
                }
            }
            """

            try! content.write(toFile: "\(projectDir)/Sources/App/Migrations/CreateScript.swift", atomically: true, encoding: .utf8)
            print("CreateScript.swift created.")
        }

        /// Creates the controller file for the Script model.
        func createScriptController(_ projectDir: String) {
            let content = """
            import Vapor
            import Fluent
            import Redis
            import RedisAI

            final class ScriptController {
                func index(req: Request) throws -> EventLoopFuture<[Script]> {
                    if let cachedScripts: [Script] = try? req.redis.get("all_scripts", as: [Script].self).wait() {
                        return req.eventLoop.future(cachedScripts)
                    } else {
                        return Script.query(on: req.db).all().map { scripts in
                            try? req.redis.set("all_scripts", toJSON: scripts).wait()
                            return scripts
                        }
                    }
                }

                func create(req: Request) throws -> EventLoopFuture<Script> {
                    let script = try req.content.decode(Script.self)
                    return script.save(on: req.db).map { script }
                }

                func show(req: Request) throws -> EventLoopFuture<Script> {
                    Script.find(req.parameters.get("scriptId"), on: req.db)
                        .unwrap(or: Abort(.notFound))
                }

                func update(req: Request) throws -> EventLoopFuture<Script> {
                    let updatedScript = try req.content.decode(Script.self)
                    return Script.find(req.parameters.get("scriptId"), on: req.db)
                        .unwrap(or: Abort(.notFound)).flatMap { script in
                            script.title = updatedScript.title
                            script.description = updatedScript.description
                            script.author = updatedScript.author
                            script.sequence = updatedScript.sequence
                            return script.save(on: req.db).map { script }
                        }
                }

                func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
                    Script.find(req.parameters.get("scriptId"), on: req.db)
                        .unwrap(or: Abort(.notFound)).flatMap { script in
                            script.delete(on: req.db).transform(to: .noContent)
                        }
                }
            }
            """

            try! content.write(toFile: "\(projectDir)/Sources/App/Controllers/ScriptController.swift", atomically: true, encoding: .utf8)
            print("ScriptController.swift created.")
        }
    }

    /// Command to build the Vapor application.
    struct BuildVaporApp: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Build the Vapor application."
        )

        func run() {
            let config = readConfig()
            let projectDir = config.projectDirectory
            validateProjectDirectory(projectDir)

            runShellCommand("/usr/bin/env", arguments: ["swift", "build", "-c", "release"], workingDirectory: projectDir)
            print("Vapor app built in release mode.")
        }
    }

    /// Command to run the Vapor application locally.
    struct RunVaporLocal: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Run the Vapor application locally."
        )

        func run() {
            let config = readConfig()
            let projectDir = config.projectDirectory
            validateProjectDirectory(projectDir)

            runShellCommand("\(projectDir)/.build/release/App", arguments: ["--env", "development"], workingDirectory: projectDir)
        }
    }

    /// Command to create the Docker Compose file.
    struct CreateDockerComposeFile: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Create the Docker Compose file."
        )

        func run() {
            let config = readConfig()
            let projectDir = config.projectDirectory
            validateProjectDirectory(projectDir)

            let templatePath = "./config/docker-compose-template.yml"
            let outputPath = "\(projectDir)/docker-compose.yml"

            let templateContent = try! String(contentsOfFile: templatePath)
            let substitutedContent = templateContent
                .replacingOccurrences(of: "$DATABASE_USERNAME", with: config.database.username)
                .replacingOccurrences(of: "$DATABASE_PASSWORD", with: config.database.password)
                .replacingOccurrences(of: "$DATABASE_NAME", with: config.database.name)
                .replacingOccurrences(of: "$REDIS_HOST", with: config.redis.host)
                .replacingOccurrences(of: "$REDIS_PORT", with: String(config.redis.port))

            try! substitutedContent.write(toFile: outputPath, atomically: true, encoding: .utf8)
            print("Docker Compose file created in \(projectDir).")
        }
    }

    /// Command to create the Nginx configuration file.
    struct CreateNginxConfigFile: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Create the Nginx configuration file."
        )

        func run() {
            let config = readConfig()
            let projectDir = config.projectDirectory
            let domain = config.domain
            validateProjectDirectory(projectDir)
            validateDomainName(domain)

            let templatePath = "./config/nginx-template.conf"
            let outputPath = "\(projectDir)/nginx/nginx.conf"

            let templateContent = try! String(contentsOfFile: templatePath)
            let substitutedContent = templateContent
                .replacingOccurrences(of: "$DOMAIN", with: domain)

            try! substitutedContent.write(toFile: outputPath, atomically: true, encoding: .utf8)
            print("Nginx configuration file created for \(domain) in \(projectDir).")
        }
    }

    /// Command to create the Certbot script.
    struct CreateCertbotScript: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Create the Certbot script."
        )

        func run() {
            createCertbotDirectoryStructure()
            downloadTlsParameters()
            createCertbotScriptFile()
        }

        /// Creates the directory structure for Certbot.
        func createCertbotDirectoryStructure() {
            let config = readConfig()
            let projectDir = config.projectDirectory
            validateProjectDirectory(projectDir)

            let fileManager = FileManager.default
            let directories = [
                "\(projectDir)/certbot/conf",
                "\(projectDir)/certbot/www"
            ]

            for dir in directories {
                if !fileManager.fileExists(atPath: dir) {
                    try! fileManager.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
                    print("Directory created at \(dir)")
                } else {
                    print("Directory already exists at \(dir)")
                }
            }
        }

        /// Downloads the recommended TLS parameters for Certbot.
        func downloadTlsParameters() {
            let config = readConfig()
            let projectDir = config.projectDirectory
            validateProjectDirectory(projectDir)

            let optionsSslNginxPath = "\(projectDir)/certbot/conf/options-ssl-nginx.conf"
            let sslDhparamsPath = "\(projectDir)/certbot/conf/ssl-dhparams.pem"

            if !FileManager.default.fileExists(atPath: optionsSslNginxPath) || !FileManager.default.fileExists(atPath: sslDhparamsPath) {
               

 print("### Downloading recommended TLS parameters ...")
                let optionsSslNginxURL = URL(string: "https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/options-ssl-nginx.conf")!
                let sslDhparamsURL = URL(string: "https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem")!

                try! Data(contentsOf: optionsSslNginxURL).write(to: URL(fileURLWithPath: optionsSslNginxPath))
                try! Data(contentsOf: sslDhparamsURL).write(to: URL(fileURLWithPath: sslDhparamsPath))

                print("TLS parameters downloaded.")
            } else {
                print("TLS parameters already exist.")
            }
        }

        /// Creates the Certbot script file.
        func createCertbotScriptFile() {
            let config = readConfig()
            let projectDir = config.projectDirectory
            let domain = config.domain
            validateProjectDirectory(projectDir)
            validateDomainName(domain)

            let templatePath = "./config/init-letsencrypt-template.sh"
            let outputPath = "\(projectDir)/certbot/init-letsencrypt.sh"

            let templateContent = try! String(contentsOfFile: templatePath)
            let substitutedContent = templateContent
                .replacingOccurrences(of: "$DOMAIN", with: domain)
                .replacingOccurrences(of: "$EMAIL", with: config.email)
                .replacingOccurrences(of: "$STAGING", with: String(config.staging))

            try! substitutedContent.write(toFile: outputPath, atomically: true, encoding: .utf8)
            try! FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: outputPath)

            print("Let's Encrypt certificate generation script created for \(domain) in \(projectDir).")
        }
    }

    /// Command to set up the entire project.
    struct SetupProject: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Set up the entire project."
        )

        func run() {
            let config = readConfig()
            let projectDir = config.projectDirectory
            let domain = config.domain
            validateProjectDirectory(projectDir)
            validateDomainName(domain)

            runScript(CreateDirectories.self)
            runScript(CreateDockerComposeFile.self)
            runScript(CreateNginxConfigFile.self)
            runScript(CreateCertbotScript.self)

            print("Project setup complete in \(projectDir).")

            runShellCommand("/usr/bin/env", arguments: ["docker-compose", "up", "-d"], workingDirectory: projectDir)
            runShellCommand("/bin/bash", arguments: ["./certbot/init-letsencrypt.sh"], workingDirectory: projectDir)

            print("Production server setup complete and running in \(projectDir).")
        }

        /// Runs a specified command script.
        func runScript<T: ParsableCommand>(_ command: T.Type) {
            var command = command.init()
            do {
                try command.run()
            } catch {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }

    /// Command to run the master script to set up and deploy the Vapor application.
    struct MasterScript: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Run the master script to set up and deploy the Vapor application."
        )

        func run() {
            print("Starting Phase 1: Vapor App Creation...")
            runScript(CreateDirectories.self)
            runScript(SetupVaporProject.self)
            runScript(BuildVaporApp.self)
            print("Phase 1: Vapor App Creation completed.")

            print("Starting Phase 2: Production Deployment...")
            runScript(CreateDirectories.self)
            runScript(CreateDockerComposeFile.self)
            runScript(CreateNginxConfigFile.self)
            runScript(CreateCertbotScript.self)
            print("Project setup for production deployment...")

            runScript(SetupProject.self)
            print("Phase 2: Production Deployment completed.")

            print("Master script completed successfully. The Vapor app is now set up and running in the production environment.")
        }

        /// Runs a specified command script.
        func runScript<T: ParsableCommand>(_ command: T.Type) {
            var command = command.init()
            do {
                try command.run()
            } catch {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }

    /// Command to set up the GitHub Actions CI/CD pipeline.
    struct SetupCiCdPipeline: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Set up the GitHub Actions CI/CD pipeline."
        )

        func run() {
            let workflowPath = ".github/workflows/ci-cd-pipeline.yml"
            let workflowContent = """
            name: CI/CD Pipeline

            on:
              push:
                branches:
                  - main

            jobs:
              build:
                runs-on: ubuntu-latest

                services:
                  postgres:
                    image: postgres:13
                    env:
                      POSTGRES_USER: postgres
                      POSTGRES_PASSWORD: password
                      POSTGRES_DB: scriptdb
                    ports:
                      - 5432:5432
                    options: >-
                      --health-cmd="pg_isready -U postgres"
                      --health-interval=10s
                      --health-timeout=5s
                      --health-retries=5

                  redis:
                    image: redis:latest
                    ports:
                      - 6379:6379
                    options: >-
                      --health-cmd="redis-cli ping"
                      --health-interval=10s
                      --health-timeout=5s
                      --health-retries=5

                steps:
                  - name: Checkout code
                    uses: actions/checkout@v2

                  - name: Set up Swift
                    uses: fwal/setup-swift@v1

                  - name: Install dependencies
                    run: swift package resolve

                  - name: Build project
                    run: swift build -c release

                  - name: Run tests
                    run: swift test

              deploy:
                runs-on: ubuntu-latest
                needs: build

                steps:
                  - name: Checkout code
                    uses: actions/checkout@v2

                  - name: Set up Docker Buildx
                    uses: docker/setup-buildx-action@v1

                  - name: Log in to Docker Hub
                    uses: docker/login-action@v1
                    with:
                      username: ${{ secrets.DOCKER_USERNAME }}
                      password: ${{ secrets.DOCKER_PASSWORD }}

                  - name: Build and push Docker image
                    run: |
                      docker build -t ${{ secrets.DOCKER_USERNAME }}/vapor-app:latest .
                      docker push ${{ secrets.DOCKER_USERNAME }}/vapor-app:latest

                  - name: Deploy to production
                    run: |
                      ssh -o StrictHostKeyChecking=no ${{ secrets.SSH_USER }}@${{ secrets.SSH_HOST }} << 'EOF'
                        docker pull ${{ secrets.DOCKER_USERNAME }}/vapor-app:latest
                        docker-compose -f /path/to/your/project/docker-compose.yml up -d
                      EOF
            """

            let fileManager = FileManager.default
            let workflowDirectory = ".github/workflows"
            if !fileManager.fileExists(atPath: workflowDirectory) {
                try! fileManager.createDirectory(atPath: workflowDirectory, withIntermediateDirectories: true, attributes: nil)
            }

            try! workflowContent.write(toFile: workflowPath, atomically: true, encoding: .utf8)
            print("GitHub Actions CI/CD pipeline configuration created at \(workflowPath).")
        }
    }
}

// MARK: - Main

VaporAppDeploy.main()
```

### Tutorial for Creating and Using the VaporAppDeploy CLI

**Step 1: Clone the Repository**

First, clone the repository where the `VaporAppDeploy` tool is hosted.

```sh
git clone <repository-url>
cd vapor-app-deploy
```

**Step 2: Build the Project**

Build the project using Swift's build system.

```sh
swift build -c release
```

**Step 3: Configure the Project**

Ensure the `config/config.yaml` file is properly set up with the necessary configuration values.

```yaml
# Example config.yaml
projectDirectory: "/path/to/your/project"
domain: "yourdomain.com"
email: "youremail@example.com"
database:
  host: "localhost"
  username: "postgres"
  password: "password"
  name: "scriptdb"
redis:
  host: "localhost"
  port: 6379
staging: 0
```

**Step 4: Run the Commands**

The `VaporAppDeploy` tool provides various commands to set up and deploy your Vapor project. Below are examples of how to use each command.

1. **Create Necessary Directories**

   ```sh
   swift run vaporappdeploy create-directories
   ```

   This command creates the necessary directory structure for the Vapor project, including directories for controllers, models, and migrations.

2. **Set Up the Vapor Project**

   ```sh
   swift run vaporappdeploy setup-vapor-project
   ```

   This command sets up the Vapor project by generating essential files such as `Package.swift`, `main.swift`, `configure.swift`, `routes.swift`, and model, migration, and controller files for a basic Script entity.

3. **Build the Vapor Application**

   ```sh
   swift run vaporappdeploy build-vapor-app
   ```

   This command builds the Vapor application in release mode using Swift's build system.

4. **Run the Vapor Application Locally**

   ```sh
   swift run vaporappdeploy run-vapor-local
   ```

   This command runs the Vapor application locally in development mode for testing purposes.

5. **Create the Docker Compose File**

   ```sh
   swift run vaporappdeploy create-docker-compose-file
   ```

   This command generates a Docker Compose file from a template, substituting necessary environment variables from the configuration file to set up services such as Vapor, PostgreSQL, Redis, and Nginx.

6. **Create the Nginx Configuration File**

   ```sh
   swift run vaporappdeploy create-nginx-config-file
   ```

   This command creates an Nginx configuration file from a template, setting up Nginx to act as a reverse proxy for the Vapor application and handle HTTPS traffic.

7. **Create the Certbot Script**

   ```sh
   swift run vaporappdeploy create-certbot-script
   ```

   This command creates the directory structure for Certbot, downloads TLS parameters, and generates a script to obtain and renew SSL certificates from Let's Encrypt.

8. **Set Up the Entire Project**

   ```sh
   swift run vaporappdeploy setup-project
   ```

   This command orchestrates the setup of the entire project by running the necessary commands to create directories, generate configuration files, and start the Docker containers. It also runs the Certbot script to obtain SSL certificates.

9. **Run the Master Script to Set Up and Deploy the Vapor Application**

   ```sh
   swift run vaporappdeploy master-script
   ```

   This command combines the setup and deployment process into a single workflow. It performs all the steps from creating directories to running the project in production, ensuring that the Vapor application is fully set up and deployed.

10. **Set Up the GitHub Actions CI/CD Pipeline**

    ```sh
    swift run vaporappdeploy setup-cicd-pipeline
    ```

    This command sets up the CI/CD pipeline by creating the necessary `.github/workflows/ci-cd-pipeline.yml` file. The GitHub Actions workflow builds and tests the Vapor application whenever code is pushed to the repository and deploys the application to a production environment if the tests pass.

### Detailed Command Descriptions

**Create Directories**

This command creates the necessary directory structure for the Vapor project, ensuring that the project has a well-organized layout.

```sh
swift run vaporappdeploy create-directories
```

**Setup Vapor Project**

This command sets up the Vapor project by generating essential files such as `Package.swift`, `main.swift`, `configure.swift`, `routes.swift`, and model, migration, and controller files for a basic Script entity.

```sh
swift run vaporappdeploy setup-vapor-project
```

**Build Vapor App**

This command builds the Vapor application in release mode using Swift's build system.

```sh
swift run vaporappdeploy build-vapor-app
```

**Run Vapor Locally**

This command runs the Vapor application locally in development mode for testing purposes.

```sh
swift run vaporappdeploy run-vapor-local
```

**Create Docker Compose File**

This command generates a Docker Compose file from a template, substituting necessary environment variables from the configuration file to set up services such as Vapor, PostgreSQL, Redis, and Nginx.

```sh
swift run vaporappdeploy create-docker-compose-file
```

**Create Nginx Config File**

This command creates an Nginx configuration file from a template, setting up Nginx to act as a reverse proxy for the Vapor application and handle HTTPS traffic.

```sh
swift run vaporappdeploy create-nginx-config-file
```

**Create Certbot Script**

This command creates the directory structure for Certbot, downloads TLS parameters, and generates a script to obtain and renew SSL certificates from Let's Encrypt.

```sh
swift run vaporappdeploy create-certbot-script
```

**Setup Project**

This command orchestrates the setup of the entire project by running the necessary commands to create directories, generate configuration files, and start the Docker containers. It also runs the Certbot script to obtain SSL certificates.

```sh
swift run vaporappdeploy setup-project
```

**Master Script**

This command combines the setup and deployment process into a single workflow. It performs all the steps from creating directories to running the project in production, ensuring that the Vapor application is fully set up and deployed.

```sh
swift run vaporappdeploy master-script
```

**Setup CI/CD Pipeline**

This command sets up the CI/CD pipeline by creating the necessary `.github/workflows/ci-cd-pipeline.yml` file. The GitHub Actions workflow builds and tests the Vapor application whenever code is pushed to the repository and deploys the application to a production environment if the tests pass.

```sh
swift run vaporappdeploy setup-cicd-pipeline
```

### Conclusion

The `VaporAppDeploy` CLI tool provides a comprehensive solution for automating the setup, deployment, and CI/CD integration of a Vapor application. By following the steps outlined in this tutorial, you can streamline your development workflow and ensure that your Vapor application is properly configured and deployed in a production environment.