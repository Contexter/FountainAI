### Introduction

**VaporAppDeploy** is a Swift command-line utility designed to automate the setup and deployment of a Vapor application using Docker, Nginx, and Let's Encrypt. This tool simplifies the process of preparing your Vapor project for production by creating necessary directories, setting up the project, building the application, generating configuration files, and deploying the project in a Dockerized environment. It also handles the generation and renewal of SSL certificates using Let's Encrypt, ensuring that your application is securely accessible over HTTPS.

### Flow Description

The **VaporAppDeploy** utility provides a series of commands, each responsible for a specific part of the deployment process. Below is a detailed flow of the functionalities implemented:

1. **Create Directories**
   - Command: `create-directories`
   - Functionality: This command creates the necessary directory structure for the Vapor project, including directories for controllers, models, and migrations.

2. **Setup Vapor Project**
   - Command: `setup-vapor-project`
   - Functionality: This command sets up the Vapor project by generating essential files such as `Package.swift`, `main.swift`, `configure.swift`, `routes.swift`, and model, migration, and controller files for a basic Script entity.

3. **Build Vapor App**
   - Command: `build-vapor-app`
   - Functionality: This command builds the Vapor application in release mode using Swift's build system.

4. **Run Vapor Locally**
   - Command: `run-vapor-local`
   - Functionality: This command runs the Vapor application locally in development mode for testing purposes.

5. **Create Docker Compose File**
   - Command: `create-docker-compose-file`
   - Functionality: This command generates a Docker Compose file from a template, substituting necessary environment variables from the configuration file to set up services such as Vapor, PostgreSQL, Redis, and Nginx.

6. **Create Nginx Config File**
   - Command: `create-nginx-config-file`
   - Functionality: This command creates an Nginx configuration file from a template, setting up Nginx to act as a reverse proxy for the Vapor application and handle HTTPS traffic.

7. **Create Certbot Script**
   - Command: `create-certbot-script`
   - Functionality: This command creates the directory structure for Certbot, downloads TLS parameters, and generates a script to obtain and renew SSL certificates from Let's Encrypt.

8. **Setup Project**
   - Command: `setup-project`
   - Functionality: This command orchestrates the setup of the entire project by running the necessary commands to create directories, generate configuration files, and start the Docker containers. It also runs the Certbot script to obtain SSL certificates.

9. **Master Script**
   - Command: `master-script`
   - Functionality: This command combines the setup and deployment process into a single workflow. It performs all the steps from creating directories to running the project in production, ensuring that the Vapor application is fully set up and deployed.


# Swift VaporAppDeploy Implementation 
### Step 1: Create a Swift Package

First, create a new Swift package:

```sh
$ mkdir vapor-app-deploy
$ cd vapor-app-deploy
$ swift package init --type executable
```

### Step 2: Implement Functionalities

Replace the contents of `main.swift` with the refactored code, organizing the functionalities into commands using the `ArgumentParser` library.

**Package.swift**

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

**Sources/VaporAppDeploy/main.swift**

```swift
import Foundation
import ArgumentParser
import Yaml

// MARK: - Configuration Structures

struct Config: Decodable {
    var projectDirectory: String
    var domain: String
    var email: String
    var database: DatabaseConfig
    var redis: RedisConfig
    var staging: Int
}

struct DatabaseConfig: Decodable {
    var host: String
    var username: String
    var password: String
    var name: String
}

struct RedisConfig: Decodable {
    var host: String
    var port: Int
}

// MARK: - Helper Functions

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

func validateProjectDirectory(_ projectDir: String) {
    if projectDir.isEmpty {
        fatalError("Error: Project directory cannot be empty")
    }
}

func validateDomainName(_ domain: String) {
    let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
    if regex.firstMatch(in: domain, options: [], range: NSRange(location: 0, length: domain.count)) == nil {
        fatalError("Error: Invalid domain name")
    }
}

func validateEmail(_ email: String) {
    let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
    if regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) == nil {
        fatalError("Error: Invalid email address")
    }
}

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
            MasterScript.self
        ]
    )
}

extension VaporAppDeploy {
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

    struct CreateCertbotScript: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Create the Certbot script."
        )

        func run() {
            createCertbotDirectoryStructure()
            downloadTlsParameters()
            createCertbotScriptFile()
        }

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

        func createCertbotScriptFile() {
            let config = readConfig()
            let projectDir = config.project

Directory
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

        func runScript<T: ParsableCommand>(_ command: T.Type) {
            var command = command.init()
            do {
                try command.run()
            } catch {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }

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

        func runScript<T: ParsableCommand>(_ command: T.Type) {
            var command = command.init()
            do {
                try command.run()
            } catch {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Main

VaporAppDeploy.main()
```

### Step 3: Provide Documentation

Create a `README.md` file to provide documentation on how to use the command-line application.

**README.md**

```markdown
# VaporAppDeploy

A utility for deploying a Vapor application with Docker, Nginx, and Let's Encrypt.

## Installation

1. Clone the repository:
 
   git clone <repository-url>
   cd vapor-app-deploy

2. Build the project:

   swift build -c release
   ```

## Usage

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

### Example Usage

1. Create necessary directories:
   ```sh
   swift run vaporappdeploy create-directories
   ```

2. Set up the Vapor project:
   ```sh
   swift run vaporappdeploy setup-vapor-project
   ```

3. Build the Vapor application:
   ```sh
   swift run vaporappdeploy build-vapor-app
   ```

4. Run the Vapor application locally:
   ```sh
   swift run vaporappdeploy run-vapor-local
   ```

5. Create the Docker Compose file:
   ```sh
   swift run vaporappdeploy create-docker-compose-file
   ```

6. Create the Nginx configuration file:
   ```sh
   swift run vaporappdeploy create-nginx-config-file
   ```

7. Create the Certbot script:
   ```sh
   swift run vaporappdeploy create-certbot-script
   ```

8. Set up the entire project:
   ```sh
   swift run vaporappdeploy setup-project
   ```

9. Run the master script to set up and deploy the Vapor application:
   ```sh
   swift run vaporappdeploy master-script
   ```

## Configuration

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

### Commit Message

```
feat: Implement VaporAppDeploy CLI for automated deployment of Vapor apps

- Created `VaporAppDeploy` Swift command-line application
- Added commands to:
  - Create necessary directories (`create-directories`)
  - Set up the Vapor project (`setup-vapor-project`)
  - Build the Vapor application (`build-vapor-app`)
  - Run the Vapor application locally (`run-vapor-local`)
  - Generate Docker Compose file (`create-docker-compose-file`)
  - Generate Nginx configuration file (`create-nginx-config-file`)
  - Create Certbot directory structure and script (`create-certbot-script`)
  - Orchestrate full project setup (`setup-project`)
  - Run master script for complete deployment (`master-script`)
- Provided detailed documentation on usage in `README.md`

This implementation automates the setup and deployment of Vapor applications using Docker, Nginx, and Let's Encrypt, streamlining the process and enhancing security.
```