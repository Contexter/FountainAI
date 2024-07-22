# The Ultimate Guide to the `vapor new` Command

This guide will comprehensively cover the `vapor new` command, a powerful tool provided by the Vapor framework for quickly scaffolding new Vapor projects. By the end of this guide, you'll understand the command's options, how to use it effectively, and how to customize the generated project to suit your needs, including integrating Docker for containerization and deployment.

> For more detailed information, refer to the official [Vapor documentation on Docker](https://docs.vapor.codes/deploy/docker/).

## Table of Contents

1. [Introduction to the `vapor new` Command](#introduction-to-the-vapor-new-command)
2. [Installing Vapor](#installing-vapor)
3. [Creating a New Project](#creating-a-new-project)
4. [Understanding Project Structure](#understanding-project-structure)
5. [Using Project Templates](#using-project-templates)
6. [Customizing Your Project](#customizing-your-project)
7. [Integrating Docker](#integrating-docker)
   - [Generated Dockerfile](#generated-dockerfile)
   - [Setting Up Docker Compose](#setting-up-docker-compose)
   - [Running Your Application with Docker](#running-your-application-with-docker)
8. [Managing Multiple Vapor Apps with Docker Compose](#managing-multiple-vapor-apps-with-docker-compose)
   - [Running Migrations for Each App](#running-migrations-for-each-app)
9. [Advanced Usage](#advanced-usage)
10. [Common Issues and Troubleshooting](#common-issues-and-troubleshooting)
11. [Best Practices](#best-practices)

## Introduction to the `vapor new` Command

The `vapor new` command is used to generate a new Vapor project. It sets up the necessary directory structure, dependencies, and default configurations to get you started quickly with Vapor, a server-side Swift framework.

### Key Features:
- Scaffolds a complete Vapor project
- Supports various templates for different project types
- Configures default settings and dependencies
- Generates a Dockerfile for easy containerization

## Installing Vapor

Before you can use the `vapor new` command, you need to install the Vapor toolbox. Ensure you have Swift installed on your machine, then install the Vapor toolbox using Homebrew:

```bash
brew install vapor/tap/vapor
```

Verify the installation by checking the version of Vapor:

```bash
vapor --version
```

## Creating a New Project

To create a new Vapor project, use the `vapor new` command followed by the name of your project. For example, to create a project named `MyVaporApp`:

```bash
vapor new MyVaporApp
```

This command will generate a new directory called `MyVaporApp` with the default project structure and files, including a Dockerfile and a Docker Compose file. The specific configuration of these files depends on the options selected during project setup.

## Understanding Project Structure

The generated project structure includes several key components:

- `Sources/`: Contains the main application code.
  - `App/`: Contains application-specific code.
  - `Run/`: Contains the entry point for the application.
- `Public/`: Contains publicly accessible files like CSS, JavaScript, and images.
- `Resources/`: Contains resource files like templates and configuration files.
- `Package.swift`: The Swift Package Manager manifest file for managing dependencies.
- `Dockerfile`: The Docker configuration file for containerizing your application.
- `docker-compose.yml`: A Docker Compose configuration file for defining and running multi-container Docker applications.

### Example Project Structure:

```
MyVaporApp/
├── Public/
├── Resources/
│   └── Views/
├── Sources/
│   ├── App/
│   │   ├── Controllers/
│   │   ├── Models/
│   │   └── configure.swift
│   └── Run/
│       └── main.swift
├── Tests/
│   ├── AppTests/
│   └── XCTVapor/
├── .dockerignore
├── .gitignore
├── Dockerfile
├── docker-compose.yml
├── Package.swift
└── README.md
```

## Using Project Templates

The `vapor new` command supports different templates to generate projects tailored to specific needs. Common templates include `api`, `web`, and `auth`. You can specify a template using the `--template` flag:

```bash
vapor new MyVaporApp --template=api
```

### Available Templates:
- **api**: For creating RESTful API projects.
- **web**: For creating web applications with HTML views.
- **auth**: For projects requiring authentication.

## Customizing Your Project

After generating a new project, you can customize it to fit your specific requirements. Here are some common customizations:

### Adding Dependencies

Modify the `Package.swift` file to add dependencies. For example, to add the Fluent ORM and PostgreSQL driver:

```swift
dependencies: [
    .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
    .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
],
targets: [
    .target(name: "App", dependencies: [
        .product(name: "Fluent", package: "fluent"),
        .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
        // other dependencies...
    ]),
]
```

### Configuring Middleware

Update the `configure.swift` file to add or remove middleware. For example, to add a custom middleware:

```swift
app.middleware.use(MyCustomMiddleware())
```

### Setting Up Routes

Define your application routes in the `routes.swift` file:

```swift
func routes(_ app: Application) throws {
    app.get("hello") { req -> String in
        return "Hello, world!"
    }
}
```

## Integrating Docker

Using Docker to deploy your Vapor app has several benefits:
1. Your dockerized app can be spun up reliably using the same commands on any platform with a Docker Daemon.
2. You can use docker-compose or Kubernetes manifests to orchestrate multiple services needed for a full deployment (e.g., Redis, Postgres, nginx, etc.).
3. It is easy to test your app's ability to scale horizontally, even locally on your development machine.

For more detailed guidance on Docker deployment, refer to the [official Vapor documentation on Docker](https://docs.vapor.codes/deploy/docker/).

### Generated Dockerfile

The `vapor new` command generates a `Dockerfile` that you can use to containerize your Vapor application. The exact contents of the Dockerfile depend on the template and options you choose when running the `vapor new` command.

Here's an example of what a generated Dockerfile might look like:

```dockerfile
# Stage 1 - Build the Swift application
FROM swift:5.7 as builder

WORKDIR /app
COPY . .

RUN swift package resolve
RUN swift build --configuration release

# Stage 2 - Create a lightweight image for running the app
FROM ubuntu:20.04

WORKDIR /app
COPY --from=builder /app/.build/release /app

EXPOSE 8080
ENTRYPOINT ["./Run"]
```

### Setting Up Docker Compose

To simplify the process of managing your Docker containers, you can use Docker Compose. The `vapor new` command also generates a `docker-compose.yml` file. The specific configuration of this file depends on the options selected during project setup.

Here’s an example of a generated `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  vapor:
    build: .
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgres://user:password@db:5432/vapor
    depends_on:
      - db

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: vapor
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### Running Your Application with Docker

1. **Build and Start Services:**
   Navigate to your project directory and run:

   ```bash
   docker-compose up --build
   ```

2. **Access Your Application:**
   Open a browser and go to `http://localhost:8080`. Your Vapor application should be running.

3. **Running Migrations:**
   If your application uses a database and requires migrations, you can run them with:

   ```bash
   docker-compose run vapor migrate
   ```

## Managing Multiple Vapor Apps with Docker Compose

If you are managing a Docker Compose collection of multiple Vapor apps, you can use Docker Compose to run the migrations for each of the Vapor Docker containers. Here's how you can set it up:

### Example `docker-compose.yml`

```yaml
version: '3.8'

services:
  vapor_app1:
    build: ./app1
    ports:
      - "8081:8080"
    environment:
      - DATABASE_URL=postgres://user:password@db:5432/app1
    depends_on:
      - db

  vapor_app1_migrate:
    build: ./app1
    command: ["vapor", "migrate", "--env", "production"]
    environment:
      - DATABASE_URL=postgres://user:password@db:5432/app1
    depends_on:
      - db

  vapor_app2:
    build: ./app2
    ports:
      - "8082:8080"
    environment:
      - DATABASE_URL=postgres://user:password@db:5432/app2
    depends_on:
      - db

  vapor_app2_migrate:
    build: ./app2
    command: ["vapor", "migrate", "--env", "production"]
    environment:
      - DATABASE_URL=postgres://user:password@db:5432/app2
    depends_on:
      - db

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: postgres
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

In this setup:
- **vapor_app1** and **vapor_app2** are the main services running your Vapor applications.
- **vapor_app1_migrate** and **vapor_app2_migrate** are the services responsible for running the migrations for each application.
- The `command` directive in the migration services overrides the default entry point to run the `vapor migrate` command.

### Running Migrations for Each App

1. **Build the Docker Compose Stack:**
   Navigate to your project directory and run:

   ```bash
   docker-compose up --build
   ```

2. **Run Migrations:**
   After building the stack, you can run the migrations for each application by starting the respective migration services:

   ```bash
   docker-compose run vapor_app1_migrate
   docker-compose run vapor_app2_migrate
   ```

3. **Start the Applications:**
   Once migrations are completed, you can start the application services:

   ```bash
   docker-compose up vapor_app1 vapor_app2
   ```

## Advanced Usage

The `vapor new` command has additional options for advanced usage. Use `vapor new --help` to see all available options.

### Specifying a Directory

You can specify a custom directory for the new project:

```bash
vapor new MyVaporApp --output /path/to/directory
```

### Skipping Git Initialization

To skip Git repository initialization, use the `--no-git` flag:

```bash
vapor new MyVaporApp --no-git
```

## Common Issues and Troubleshooting

### Problem: Command Not Found

If you encounter a "command not found" error, ensure that the Vapor toolbox is correctly installed and accessible in your PATH.

### Problem: Dependency Errors

If you encounter dependency resolution errors, check your `Package.swift` for version conflicts or incorrect URLs.

## Best Practices

1. **Use Version Control:**
   Initialize a Git repository to track changes in your project:

   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```

2. **Follow Swift Guidelines:**
   Adhere to Swift's API Design Guidelines and Vapor's best practices for clean and maintainable code.

3. **Write Tests:**
   Use XCTVapor to write and run tests for your application:

   ```swift
   import XCTVapor

   final class AppTests: XCTestCase {
       func testHelloWorld() throws {
           let app = Application(.testing)
           defer { app.shutdown() }
           try configure(app)

           try app.test(.GET, "hello", afterResponse: { response in
               XCTAssertEqual(response.status, .ok)
               XCTAssertEqual(response.body.string, "Hello, world!")
           })
       }
   }
   ```

4. **Use Environment Variables:**
   Manage configuration using environment variables for flexibility and security.

   ```swift
   let databaseURL = Environment.get("DATABASE_URL") ?? "postgres://localhost:5432/mydb"
   ```

5. **Keep Dependencies Updated:**
   Regularly update your dependencies to benefit from the latest features and security fixes:

   ```bash
   swift package update
   ```

By following this guide, you should be well-equipped to use the `vapor new` command to create and customize Vapor projects effectively, including leveraging Docker for containerization and deployment. For detailed Docker deployment steps, refer to the official [Vapor documentation on Docker](https://docs.vapor.codes/deploy/docker/). Happy coding!