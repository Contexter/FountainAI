### Comprehensive TDD Plan for VaporAppDeploy

To ensure we cover all the essential steps of the original VaporAppDeploy project and follow a test-driven development (TDD) approach, we'll break down the entire lifecycle into manageable, testable steps. Here's the comprehensive plan:

### Stage 1: OpenAPI Parser

1. **Create Mock OpenAPI Parser**
2. **Write Tests for Simple Endpoint Parsing**
3. **Implement Simple Endpoint Parsing**
4. **Write Tests for Complex Endpoint Parsing**
5. **Implement Complex Endpoint Parsing**
6. **Expand Tests to Cover Full OpenAPI Specifications**
7. **Implement Full OpenAPI Specifications Parsing**

### Stage 2: Vapor Routes Generation

1. **Write Tests for Generating Vapor Routes from Parsed Endpoints**
2. **Implement Basic Routes Generation**
3. **Write Tests for Handling Different HTTP Methods**
4. **Implement Handling for Different HTTP Methods**
5. **Write Tests for Parameter Handling**
6. **Implement Parameter Handling in Routes**

### Stage 3: Building and Running Locally

1. **Write Tests for Building the Vapor Application**
2. **Implement Building Process**
3. **Write Tests for Running the Application Locally**
4. **Implement Local Running Process**

### Stage 4: Docker Integration

1. **Write Tests for Creating Docker Compose File**
2. **Implement Docker Compose File Creation**
3. **Write Tests for Building Docker Images**
4. **Implement Docker Image Building Process**
5. **Write Tests for Running Docker Containers Locally**
6. **Implement Docker Containers Running Process**

### Stage 5: SSL Certificate Management

1. **Write Tests for Creating Certbot Script**
2. **Implement Certbot Script Creation**

### Stage 6: CI/CD Pipeline Setup

1. **Write Tests for Setting Up GitHub Actions Workflow**
2. **Implement GitHub Actions Workflow Setup**

### Stage 7: Deployment to Production

1. **Write Tests for Production Deployment Steps**
2. **Implement Production Deployment Steps**
3. **Write Tests for Verifying Deployment**
4. **Implement Verification Process**

### Detailed Plan with Example Steps

#### Stage 1: OpenAPI Parser

1. **Create Mock OpenAPI Parser**

    **Test:**

    ```swift
    import XCTest
    @testable import VaporAppDeploy

    final class OpenAPIParserTests: XCTestCase {
        func testParseSimpleEndpoint() {
            let openAPI = """
            openapi: 3.0.0
            info:
              title: Simple API
              version: 1.0.0
            paths:
              /simple:
                get:
                  summary: Simple endpoint
                  parameters:
                    - name: param1
                      in: query
                      required: true
                      schema:
                        type: string
            """
            
            let parser = OpenAPIParser()
            let endpoints = parser.parse(openAPI)
            
            XCTAssertEqual(endpoints.count, 1)
            XCTAssertEqual(endpoints.first?.path, "/simple")
            XCTAssertEqual(endpoints.first?.method, "get")
            XCTAssertEqual(endpoints.first?.parameters.count, 1)
            XCTAssertEqual(endpoints.first?.parameters.first?.name, "param1")
            XCTAssertEqual(endpoints.first?.parameters.first?.type, "string")
            XCTAssertEqual(endpoints.first?.parameters.first?.required, true)
        }
    }
    ```

    **Implementation:**

    ```swift
    import Foundation
    import Yams

    struct OpenAPIParser {
        func parse(_ openAPI: String) -> [Endpoint] {
            guard let yaml = try? Yams.load(yaml: openAPI) as? [String: Any],
                  let paths = yaml["paths"] as? [String: Any] else {
                return []
            }
            
            var endpoints: [Endpoint] = []
            
            for (path, methods) in paths {
                if let methods = methods as? [String: Any] {
                    for (method, details) in methods {
                        if let details = details as? [String: Any],
                           let parameters = details["parameters"] as? [[String: Any]] {
                            let params = parameters.map { param in
                                Parameter(
                                    name: param["name"] as? String ?? "",
                                    type: (param["schema"] as? [String: Any])?["type"] as? String ?? "",
                                    required: param["required"] as? Bool ?? false
                                )
                            }
                            let endpoint = Endpoint(path: path, method: method, parameters: params)
                            endpoints.append(endpoint)
                        }
                    }
                }
            }
            
            return endpoints
        }
    }

    struct Endpoint {
        let path: String
        let method: String
        let parameters: [Parameter]
    }

    struct Parameter {
        let name: String
        let type: String
        let required: Bool
    }
    ```

2. **Write Tests for Complex Endpoint Parsing**

    **Test:**

    ```swift
    func testParseComplexEndpoint() {
        let openAPI = """
        openapi: 3.0.0
        info:
          title: Complex API
          version: 1.0.0
        paths:
          /complex:
            post:
              summary: Complex endpoint
              parameters:
                - name: param1
                  in: query
                  required: true
                  schema:
                    type: string
                - name: param2
                  in: header
                  required: false
                  schema:
                    type: integer
        """
        
        let parser = OpenAPIParser()
        let endpoints = parser.parse(openAPI)
        
        XCTAssertEqual(endpoints.count, 1)
        XCTAssertEqual(endpoints.first?.path, "/complex")
        XCTAssertEqual(endpoints.first?.method, "post")
        XCTAssertEqual(endpoints.first?.parameters.count, 2)
        XCTAssertEqual(endpoints.first?.parameters[0].name, "param1")
        XCTAssertEqual(endpoints.first?.parameters[0].type, "string")
        XCTAssertEqual(endpoints.first?.parameters[0].required, true)
        XCTAssertEqual(endpoints.first?.parameters[1].name, "param2")
        XCTAssertEqual(endpoints.first?.parameters[1].type, "integer")
        XCTAssertEqual(endpoints.first?.parameters[1].required, false)
    }
    ```

3. **Implement Complex Endpoint Parsing**

    - Implement parsing logic to handle different parameter types and methods.

#### Stage 2: Vapor Routes Generation

1. **Write Tests for Generating Vapor Routes from Parsed Endpoints**

    **Test:**

    ```swift
    func testGenerateVaporRoutes() {
        let endpoints = [
            Endpoint(path: "/simple", method: "get", parameters: [
                Parameter(name: "param1", type: "string", required: true)
            ])
        ]
        
        let routes = VaporRouteGenerator().generate(from: endpoints)
        
        XCTAssertEqual(routes, """
        func routes(_ app: Application) throws {
            app.get("simple") { req -> String in
                let param1 = try req.query.get(String.self, at: "param1")
                return "Hello, \\(param1)"
            }
        }
        """)
    }
    ```

    **Implementation:**

    ```swift
    struct VaporRouteGenerator {
        func generate(from endpoints: [Endpoint]) -> String {
            var routes = "func routes(_ app: Application) throws {\n"
            
            for endpoint in endpoints {
                routes += "    app.\(endpoint.method)(\"\(endpoint.path)\") { req -> String in\n"
                for param in endpoint.parameters {
                    routes += "        let \(param.name) = try req.query.get(\(param.type).self, at: \"\(param.name)\")\n"
                }
                routes += "        return \"Hello, \\(\(endpoint.parameters.map { $0.name }.joined(separator: ", ")))\"\n"
                routes += "    }\n"
            }
            
            routes += "}\n"
            return routes
        }
    }
    ```

2. **Write Tests for Handling Different HTTP Methods**

    **Test:**

    ```swift
    func testGenerateVaporRoutesForDifferentMethods() {
        let endpoints = [
            Endpoint(path: "/simple", method: "get", parameters: []),
            Endpoint(path: "/complex", method: "post", parameters: [])
        ]
        
        let routes = VaporRouteGenerator().generate(from: endpoints)
        
        XCTAssertTrue(routes.contains("app.get(\"simple\")"))
        XCTAssertTrue(routes.contains("app.post(\"complex\")"))
    }
    ```

    **Implementation:**

    ```swift
    struct VaporRouteGenerator {
        func generate(from endpoints: [Endpoint]) -> String {
            var routes = "func routes(_ app: Application) throws {\n"
            
            for endpoint in endpoints {
                routes += "    app.\(endpoint.method)(\"\(endpoint.path)\") { req -> String in\n"
                routes += "        return \"Hello, \(endpoint.path)\"\n"
                routes += "    }\n"
            }
            
            routes += "}\n"
            return routes
        }
    }
    ```

#### Stage 3: Building and Running Locally

1. **Write Tests for Building the Vapor Application**

    **Test:**

    ```swift
    func testBuildVaporApp() {
        let builder = VaporAppBuilder()
        let result = builder.build(at: "/path/to/project")
        
        XCTAssertTrue(result)
    }
    ```

    **Implementation:**

    ```swift
    struct VaporAppBuilder {
        func build(at path: String) -> Bool {
            runShellCommand("/usr/bin/env", arguments: ["swift", "build", "-c", "release"], workingDirectory: path)
            return true
        }
    }
    ```

2. **Write Tests for Running the Application Locally**

    **Test:**

    ```swift
    func testRunVaporAppLocally() {
        let runner = VaporAppRunner()
        let result = runner.run(at: "/path/to/project")
        
        XCTAssertTrue(result)
    }
    ```

    **Implementation:**

    ```swift
    struct VaporAppRunner {
        func run(at path: String) -> Bool {
            runShellCommand("\(path)/.build/release/App", arguments: ["serve"], workingDirectory: path)
            return true
        }
    }
    ```

#### Stage 4: Docker Integration

1. **Write Tests for Creating Docker Compose File**

    **Test:**

    ```swift
    func testCreateDockerComposeFile() {
        let config = Config(projectDirectory: "/path/to/project", database: DatabaseConfig(username: "postgres", password: "password", name: "scriptdb"))
        let generator = DockerComposeGenerator()
        let result = generator.createComposeFile(for: config)
        
        XCTAssertTrue(result)
    }
    ```

    **Implementation:**

    ```swift
    struct DockerComposeGenerator {
        func createComposeFile(for config: Config) -> Bool {
            let templatePath = "./config/docker-compose-template.yml"
            let outputPath = "\(config.projectDirectory)/docker-compose.yml"

            let templateContent = try! String(contentsOfFile: templatePath)
            let substitutedContent = templateContent
                .replacingOccurrences(of: "$DATABASE_USERNAME", with: config.database.username)
                .replacingOccurrences(of: "$DATABASE_PASSWORD", with: config.database.password)
                .replacingOccurrences(of: "$DATABASE_NAME", with: config.database.name)

            try! substitutedContent.write(toFile: outputPath, atomically: true, encoding: .utf8)
            return true
        }
    }
    ```

2. **Write Tests for Building Docker Images**

    **Test:**

    ```swift
    func testBuildDockerImage() {
        let builder = DockerImageBuilder()
        let result = builder.build(at: "/path/to/project")
        
        XCTAssertTrue(result)
    }
    ```

    **Implementation:**

    ```swift
    struct DockerImageBuilder {
        func build(at path: String) -> Bool {
            runShellCommand("/usr/bin/env", arguments: ["docker-compose", "build"], workingDirectory: path)
            return true
        }
    }
    ```

3. **Write Tests for Running Docker Containers Locally**

    **Test:**

    ```swift
    func testRunDockerContainersLocally() {
        let runner = DockerContainerRunner()
        let result = runner.run(at: "/path/to/project")
        
        XCTAssertTrue(result)
    }
    ```

    **Implementation:**

    ```swift
    struct DockerContainerRunner {
        func run(at path: String) -> Bool {
            runShellCommand("/usr/bin/env", arguments: ["docker-compose", "up", "-d"], workingDirectory: path)
            return true
        }
    }
    ```

#### Stage 5: SSL Certificate Management

1. **Write Tests for Creating Certbot Script**

    **Test:**

    ```swift
    func testCreateCertbotScript() {
        let config = Config(projectDirectory: "/path/to/project", domain: "example.com", email: "email@example.com", staging: 0)
        let creator = CertbotScriptCreator()
        let result = creator.create(for: config)
        
        XCTAssertTrue(result)
    }
    ```

    **Implementation:**

    ```swift
    struct CertbotScriptCreator {
        func create(for config: Config) -> Bool {
            let templatePath = "./config/init-letsencrypt-template.sh"
            let outputPath = "\(config.projectDirectory)/certbot/init-letsencrypt.sh"

            let templateContent = try! String(contentsOfFile: templatePath)
            let substitutedContent = templateContent
                .replacingOccurrences(of: "$DOMAIN", with: config.domain)
                .replacingOccurrences(of: "$EMAIL", with: config.email)
                .replacingOccurrences(of: "$STAGING", with: String(config.staging))

            try! substitutedContent.write(toFile: outputPath, atomically: true, encoding: .utf8)
            try! FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: outputPath)

            return true
        }
    }
    ```

#### Stage 6: CI/CD Pipeline Setup

1. **Write Tests for Setting Up GitHub Actions Workflow**

    **Test:**

    ```swift
    func testSetupGithubActionsWorkflow() {
        let setup = GithubActionsSetup()
        let result = setup.setup(at: "/path/to/project")
        
        XCTAssertTrue(result)
    }
    ```

    **Implementation:**

    ```swift
    struct GithubActionsSetup {
        func setup(at path: String) -> Bool {
            let workflowPath = "\(path)/.github/workflows/ci-cd-pipeline.yml"
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
            let workflowDirectory = "\(path)/.github/workflows"
            if !fileManager.fileExists(atPath: workflowDirectory) {
                try! fileManager.createDirectory(atPath: workflowDirectory, withIntermediateDirectories: true, attributes: nil)
            }

            try! workflowContent.write(toFile: workflowPath, atomically: true, encoding: .utf8)
            return true
        }
    }
    ```

#### Stage 7: Deployment to Production

1. **Write Tests for Production Deployment Steps**

    **Test:**

    ```swift
    func testDeployToProduction() {
        let deployer = ProductionDeployer()
        let result = deployer.deploy(from: "/path/to/project")
        
        XCTAssertTrue(result)
    }
    ```

    **Implementation:**

    ```swift
    struct ProductionDeployer {
        func deploy(from path: String) -> Bool {
            runShellCommand("/usr/bin/env", arguments: ["docker-compose", "up", "-d"], workingDirectory: path)
            return true
        }
    }
    ```

### Conclusion

This comprehensive TDD plan ensures we cover all essential steps of the VaporAppDeploy project while maintaining a structured and testable approach. By starting with simple tests and gradually adding complexity, we ensure each component works correctly before moving on to the next, ultimately leading to a reliable deployment tool for Vapor applications based on OpenAPI specifications.