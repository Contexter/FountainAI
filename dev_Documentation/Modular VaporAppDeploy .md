# Modular VaporAppDeploy Concept

```
#VaporAppDeploy/
├── Sources/
│   ├── VaporAppDeploy/
│   │   ├── Commands/
│   │   │   ├── BuildVaporApp.swift
│   │   │   ├── CreateCertbotScript.swift
│   │   │   ├── CreateDirectories.swift
│   │   │   ├── CreateDockerComposeFile.swift
│   │   │   ├── CreateNginxConfigFile.swift
│   │   │   ├── MasterScript.swift
│   │   │   ├── RunVaporLocal.swift
│   │   │   ├── SetupCiCdPipeline.swift
│   │   │   ├── SetupProject.swift
│   │   │   └── SetupVaporProject.swift
│   │   ├── Helpers/
│   │   │   ├── Config.swift
│   │   │   ├── InputValidation.swift
│   │   │   └── Shell.swift
│   │   └── main.swift
├── config/
│   ├── config.yaml
│   ├── docker-compose-template.yml
│   ├── nginx-template.conf
│   └── init-letsencrypt-template.sh
├── Package.swift
└── README.md
```
# Create empty files ...
Here is a shell script that creates the directory structure and empty files as specified:

```bash
#!/bin/bash

# Create the directory structure
mkdir -p VaporAppDeploy/Sources/VaporAppDeploy/Commands
mkdir -p VaporAppDeploy/Sources/VaporAppDeploy/Helpers
mkdir -p VaporAppDeploy/config

# Create empty files in Commands directory
touch VaporAppDeploy/Sources/VaporAppDeploy/Commands/BuildVaporApp.swift
touch VaporAppDeploy/Sources/VaporAppDeploy/Commands/CreateCertbotScript.swift
touch VaporAppDeploy/Sources/VaporAppDeploy/Commands/CreateDirectories.swift
touch VaporAppDeploy/Sources/VaporAppDeploy/Commands/CreateDockerComposeFile.swift
touch VaporAppDeploy/Sources/VaporAppDeploy/Commands/CreateNginxConfigFile.swift
touch VaporAppDeploy/Sources/VaporAppDeploy/Commands/MasterScript.swift
touch VaporAppDeploy/Sources/VaporAppDeploy/Commands/RunVaporLocal.swift
touch VaporAppDeploy/Sources/VaporAppDeploy/Commands/SetupCiCdPipeline.swift
touch VaporAppDeploy/Sources/VaporAppDeploy/Commands/SetupProject.swift
touch VaporAppDeploy/Sources/VaporAppDeploy/Commands/SetupVaporProject.swift

# Create empty files in Helpers directory
touch VaporAppDeploy/Sources/VaporAppDeploy/Helpers/Config.swift
touch VaporAppDeploy/Sources/VaporAppDeploy/Helpers/InputValidation.swift
touch VaporAppDeploy/Sources/VaporAppDeploy/Helpers/Shell.swift

# Create the main.swift file
touch VaporAppDeploy/Sources/VaporAppDeploy/main.swift

# Create config files
touch VaporAppDeploy/config/config.yaml
touch VaporAppDeploy/config/docker-compose-template.yml
touch VaporAppDeploy/config/nginx-template.conf
touch VaporAppDeploy/config/init-letsencrypt-template.sh

# Create Package.swift and README.md
touch VaporAppDeploy/Package.swift
touch VaporAppDeploy/README.md
```

You can run this script to create the directory structure and empty files as specified.
### Directory: `Sources/VaporAppDeploy/Commands/`

#### File: `BuildVaporApp.swift`
```swift
import Foundation
import ArgumentParser

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
```

#### File: `CreateCertbotScript.swift`
```swift
import Foundation
import ArgumentParser

struct CreateCertbotScript: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Create the Certbot script."
    )

    func run() {
        createCertbotDirectoryStructure()
        downloadTlsParameters()
        createCertbotScriptFile()
    }

    private func createCertbotDirectoryStructure() {
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

    private func downloadTlsParameters() {
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

    private func createCertbotScriptFile() {
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
```

#### File: `CreateDirectories.swift`
```swift
import Foundation
import ArgumentParser

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
```

#### File: `CreateDockerComposeFile.swift`
```swift
import Foundation
import ArgumentParser

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
```

#### File: `CreateNginxConfigFile.swift`
```swift
import Foundation
import ArgumentParser

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
```

#### File: `MasterScript.swift`
```swift
import Foundation
import ArgumentParser

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

    private func runScript<T: ParsableCommand>(_ command: T.Type) {
        var command = command.init()
        do {
            try command.run()
        } catch {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
}
```

#### File: `RunVaporLocal.swift`
```swift
import Foundation
import ArgumentParser

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
```

#### File: `SetupCiCdPipeline.swift`
```swift
import Foundation
import ArgumentParser

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
```

#### File: `SetupProject.swift`
```swift
import Foundation
import ArgumentParser

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

    private func runScript<T: ParsableCommand>(_ command: T.Type) {
        var command = command.init()
        do {
            try command.run()
        } catch {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
}
```

#### File: `SetupVaporProject.swift`
```swift
import Foundation
import ArgumentParser

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

    private func createPackageSwift(_ projectDir: String) {
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

    private func createMainSwift(_ projectDir: String) {
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

    private func createConfigureSwift(_ projectDir: String) {
        let content = """
        import Vapor
        import Fluent
        import FluentPostgresDriver
        import Redis
        import RedisAI

        public func configure(_ app: Application) throws {
            app.databases.use(.postgres(
                hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                username: Environment.get("DATABASE_USERNAME") ?? "postgres",
                password: Environment.get("DATABASE_PASSWORD") ?? "password",
                database: Environment.get("DATABASE_NAME") ?? "scriptdb"
            ), as: .psql)

            let redisConfig = RedisConfiguration(
                hostname: Environment.get("REDIS_HOST") ?? "localhost",
                port: Int(Environment.get("REDIS_PORT") ?? "6379")!
            )
            app.redis.configuration = redisConfig

            app.migrations.add(CreateScript())

            try routes(app)
        }
        """

        try! content.write(toFile: "\(projectDir)/Sources/App/configure.swift", atomically: true, encoding: .utf8)
        print("configure.swift created.")
    }

    private func createRoutesSwift(_ projectDir: String) {
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

    private func createScriptModel(_ projectDir: String) {
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

    private func createScriptMigration(_ projectDir: String) {
        let content = """
        import Fluent

        struct Create

Script: Migration {
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

    private func createScriptController(_ projectDir: String) {
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
```

Let's proceed by creating the file structure for `Sources/VaporAppDeploy/Helpers/` and `Sources/VaporAppDeploy/main.swift`.

### Directory: `Sources/VaporAppDeploy/Helpers/`

#### File: `Config.swift`
```swift
import Foundation

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
```

#### File: `InputValidation.swift`
```swift
import Foundation

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
```

#### File: `Shell.swift`
```swift
import Foundation

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
```

### File: `Sources/VaporAppDeploy/main.swift`
```swift
import Foundation
import ArgumentParser

@main
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
```

Next, let's create the files in the `config/` directory.

### Directory: `config/`

#### File: `config.yaml`
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

#### File: `docker-compose-template.yml`
```yaml
version: '3'

services:
  vapor:
    image: vapor/vapor:latest
    build: .
    ports:
      - "8080:8080"
    environment:
      DATABASE_HOST: postgres
      DATABASE_USERNAME: $DATABASE_USERNAME
      DATABASE_PASSWORD: $DATABASE_PASSWORD
      DATABASE_NAME: $DATABASE_NAME
      REDIS_HOST: $REDIS_HOST
      REDIS_PORT: $REDIS_PORT

  postgres:
    image: postgres:13
    environment:
      POSTGRES_USER: $DATABASE_USERNAME
      POSTGRES_PASSWORD: $DATABASE_PASSWORD
      POSTGRES_DB: $DATABASE_NAME
    ports:
      - "5432:5432"

  redis:
    image: redis:latest
    ports:
      - "6379:6379"

  nginx:
    image: nginx:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - vapor
```

#### File: `nginx-template.conf`
```nginx
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://vapor:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
}

server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    location / {
        proxy_pass http://vapor:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### File: `init-letsencrypt-template.sh`
```bash
#!/bin/bash

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

domains=($DOMAIN)
rsa_key_size=4096
data_path="./certbot"
email=$EMAIL  # Adding a valid address is strongly recommended
staging=$STAGING # Set to 1 if you're testing your setup to avoid hitting request limits

if [ -d "$data_path" ]; then
  read -p "Existing data found for $domains. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  echo
fi

echo "### Creating dummy certificate for $domains ..."
path="/etc/letsencrypt/live/$domains"
mkdir -p "$data_path/conf/live/$domains"
docker-compose run --rm --entrypoint "
  openssl req -x509 -nodes -newkey rsa:1024 -days 1\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'" certbot
echo

echo "### Starting nginx ..."
docker-compose up --force-recreate -d nginx
echo

echo "### Deleting dummy certificate for $domains ..."
docker-compose run --rm --entrypoint "
  rm -Rf /etc/letsencrypt/live/$domains && \
  rm -Rf /etc/letsencrypt/archive/$domains && \
  rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot
echo

echo "### Requesting Let's Encrypt certificate for $domains ..."
#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker-compose run --rm --entrypoint "
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

echo "### Reloading nginx ..."
docker-compose exec nginx nginx -s reload
```
Let's add the missing `Package.swift` and `README.md` files to complete the project structure.

### File: `Package.swift`
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

---

### File: `README.md`
```markdown
# VaporAppDeploy

**VaporAppDeploy** is a Swift command-line utility designed to automate the setup, deployment, and continuous integration/continuous deployment (CI/CD) of a Vapor application using Docker, Nginx, and Let's Encrypt. This tool simplifies the process of preparing your Vapor project for production by creating necessary directories, setting up the project, building the application, generating configuration files, and deploying the project in a Dockerized environment. It also handles the generation and renewal of SSL certificates using Let's Encrypt, ensuring that your application is securely accessible over HTTPS. Additionally, VaporAppDeploy includes functionality to set up a CI/CD pipeline using GitHub Actions, enabling automated builds, tests, and deployments.

## Prerequisites

Before using the VaporAppDeploy tool, ensure you have the following installed on your system:

- Swift
- Docker
- Docker Compose
- Git

## Installation

1. Clone the repository:

   git clone <repository-url>
   cd vapor-app-deploy

2. Build the project:

   swift build -c release

## Configuration

The configuration is stored in `config/config.yaml`. Ensure this file is correctly set up before running the commands.


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


## Usage

Run the main command to see available subcommands:
```sh
swift run vaporappdeploy --help


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

## Example Usage

1. **Create Necessary Directories**:
  
   swift run vaporappdeploy create-directories


2. **Set Up the Vapor Project**:

   swift run vaporappdeploy setup-vapor-project


3. **Build the Vapor Application**:
   
   swift run vaporappdeploy build-vapor-app

4. **Run the Vapor Application Locally**:

   swift run vaporappdeploy run-vapor-local

5. **Create the Docker Compose File**:

   swift run vaporappdeploy create-docker-compose-file

6. **Create the Nginx Configuration File**:

   swift run vaporappdeploy create-nginx-config-file

7. **Create the Certbot Script**:

   swift run vaporappdeploy create-certbot-script

8. **Set Up the Entire Project**:

   swift run vaporappdeploy setup-project

9. **Run the Master Script to Set Up and Deploy the Vapor Application**:

   swift run vaporappdeploy master-script

10. **Set Up the GitHub Actions CI/CD Pipeline**:

    swift run vaporappdeploy setup-cicd-pipeline

## CI/CD Pipeline Configuration

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

## Adding Secrets to GitHub

You need to add the following secrets to your GitHub repository for the workflow to access:

1. `DOCKER_USERNAME`: Your Docker Hub username.
2. `DOCKER_PASSWORD`: Your Docker Hub password.
3. `SSH_USER`: The SSH user for your production server.
4. `SSH_HOST`: The hostname or IP address of your production server.

## Conclusion

By integrating this CI/CD pipeline with GitHub Actions, we automate the build, test, and deployment process, ensuring that the Vapor application is always in a deployable state and that new features and bug fixes are delivered quickly to the production environment. This solution improves efficiency and enhances the reliability and maintainability of the application.

```




