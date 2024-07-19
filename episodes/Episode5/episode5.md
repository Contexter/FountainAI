### Episode 5: Try or Die - Forcing the Monolith
> Generating a Full-Stack Vapor Application and CI/CD Pipeline with GPT-4o

#### Table of Contents
1. [Introduction](#introduction)
2. [Recap of Episode 4](#recap-of-episode-4)
3. [Leveraging GPT-4o for Code Generation](#leveraging-gpt-4-for-code-generation)
4. [Prompt Engineering for Vapor Application](#prompt-engineering-for-vapor-application)
5. [Prompt Engineering for CI/CD Pipeline](#prompt-engineering-for-cicd-pipeline)
6. [The Comprehensive Prompt](#the-comprehensive-prompt)
7. [Result of Prompting the Monolith](#result-of-prompting-the-monolith)
8. [Conclusion](#conclusion)
9. [Foreshadowing Problem Solution Strategy - Episode 6](#foreshadowing-problem-solution-strategy---episode-6)

---

### Introduction

In the previous episode, we decoupled our CI/CD pipeline and centralized the management of secrets using a custom Swift-based command-line tool. This ensured that sensitive information is securely stored and seamlessly integrated into our deployment process. 

In this episode, we will take a significant leap forward by leveraging GPT-4o to generate a full-stack Vapor application and an accompanying CI/CD pipeline. The GPT-4o model will use the provided OpenAPI specification to produce all necessary code components, streamlining our development workflow and enhancing productivity.

### Recap of Episode 4

In Episode 4, we:
- Created a Swift-based command-line tool for managing GitHub secrets.
- Dockerized the tool and integrated it into our CI/CD pipeline using GitHub Actions.
- Streamlined the deployment process by automating the management of sensitive information.

### Leveraging GPT-4o for Code Generation

GPT-4o is a powerful language model capable of generating high-quality code based on provided specifications and instructions. By utilizing GPT-4o, we can automate the creation of a comprehensive Vapor application and its CI/CD pipeline, ensuring that all necessary components are correctly implemented and integrated.

### Prompt Engineering for Vapor Application

To generate a full-stack Vapor application, we need to provide GPT-4 with a detailed prompt that includes:
- A placeholder for the OpenAPI specification.
- Instructions to create models, controllers, and migrations based on the OpenAPI schema.
- Guidance on implementing routes, validation, and error handling.
- Details on using Redis for caching where applicable.

### Prompt Engineering for CI/CD Pipeline

For the CI/CD pipeline, the prompt should include:
- Instructions to set up GitHub Actions workflows for building, testing, and deploying the application.
- Steps for environment setup, including PostgreSQL and Redis.
- Integration of the previously created secrets manager command-line tool.
- Details on running database migrations as part of the deployment process.

### The Comprehensive Prompt

Here is the comprehensive prompt for GPT-4o:

---

**START OF PROMPT**

You are a highly capable AI trained to assist with software development. Given the following OpenAPI specification, generate a fully functional Vapor application in Swift. The code must be fully commented. Also, integrate a CI/CD pipeline using GitHub Actions, leveraging the secrets manager command-line tool previously created. The code must be provided in executable shell scripts that again produce the code correctly integrated into the FountainAI repository.

**OpenAPI Specification Placeholder:**
 (Include here the full OpenAPI specification from [FountainAI-Admin-openAPI.yaml](https://github.com/Contexter/fountainAI/blob/staging/openAPI/FountainAI-Admin-openAPI.yaml))

**Task:**

1. **Vapor Application:**
   - Create models, controllers, and migrations based on the OpenAPI specification.
   - Ensure all routes and endpoints are implemented as specified.
   - Use Redis for caching where applicable.
   - Implement validation and error handling as per the specification.
   - Ensure all models such as `Script`, `SectionHeading`, `Action`, `Character`, `SpokenWord`, `Transition`, `Paraphrase` are defined according to the schema provided in the OpenAPI.
   - Implement controllers for handling CRUD operations on these models.
   - Create migrations for setting up the database schema.

2. **CI/CD Pipeline:**
   - Set up GitHub Actions workflows for building, testing, and deploying the application.
   - Use the secrets manager command-line tool to manage secrets securely.
   - Ensure the pipeline includes steps for environment setup, running tests, building Docker images, and deploying to a specified environment.
   - The environment setup should include PostgreSQL, Redis, and any other services mentioned in the OpenAPI.
   - Include steps for running database migrations as part of the deployment process.

3. **Executable Shell Scripts:**
   - Provide the code in executable shell scripts that will produce the code correctly integrated into the FountainAI repository.
   - Ensure the scripts set up the project structure, create necessary files, and commit changes to the repository.
   - Scripts should include setup for directories, environment configuration, and integration with Docker Compose.

4. **Comments and Documentation:**
   - Provide comprehensive comments and documentation within the code to explain the implementation details.

### Example Shell Scripts:

**setup_project_structure.sh**
```sh
#!/bin/bash

# Ensure we're in the root directory of the existing repository
cd /path/to/your/fountainAI

# Create necessary directories for controllers, models, migrations, and tests
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

**create_models.sh**
```sh
#!/bin/bash

# Navigate to the Models directory
cd Sources/App/Models

# Create models based on the OpenAPI specification
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
EOF

echo "Models created."

# Commit the changes to the repository
git add Script.swift
git commit -m "Create models based on OpenAPI specification"
git push origin development
```

**create_controllers.sh**
```sh
#!/bin/bash

# Navigate to the Controllers directory
cd Sources/App/Controllers

# Create controllers based on the OpenAPI specification
cat << 'EOF' > ScriptController.swift
import Vapor

struct ScriptController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let scripts = routes.grouped("scripts")
        scripts.get(use: index)
        scripts.post(use: create)
        scripts.group(":scriptID") { script in
            script.get(use: show)
            script.put(use: update)
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

    func show(req: Request) throws -> EventLoopFuture<Script> {
        return Script.find(req.parameters.get("scriptID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func update(req: Request) throws -> EventLoopFuture<Script> {
        let updatedScript = try req.content.decode(Script.self)
        return Script.find(req.parameters.get("scriptID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { script in
                script.title = updatedScript.title
                script.description = updatedScript.description
                script.author = updatedScript.author
                script.sequence = updatedScript.sequence
                return script.save(on: req.db).map { script }
            }
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

echo "Controllers created."

# Commit the changes to the repository
git add ScriptController.swift
git commit -m "Create controllers based on OpenAPI specification"
git push origin development
```

**create_migrations.sh**
```sh
#!/bin/bash

# Navigate to the Migrations directory
cd Sources/App/Migrations

# Create migrations based on the OpenAPI specification
cat << 'EOF' > CreateScript.swift
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

    func revert(on database: Database

) -> EventLoopFuture<Void> {
        return database.schema("scripts").delete()
    }
}
EOF

echo "Migrations created."

# Commit the changes to the repository
git add CreateScript.swift
git commit -m "Create migrations based on OpenAPI specification"
git push origin development
```

**create_cicd_pipeline.sh**
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

  setup:
    needs: manage-secrets
    runs-on: ubuntu-latest
    steps:
      - name: Setup Environment
        uses: ./.github/actions/setup
        with:
          vps_ssh_key: \${{ secrets.VPS_SSH_KEY }}

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
          vps_username: \${{ secrets.VPS_USERNAME }}
          vps_ip: \${{ secrets.VPS_IP }}
          deploy_dir: \${{ secrets.DEPLOY_DIR }}
EOF
)

# Update each workflow file
for WORKFLOW_PATH in "${WORKFLOW_PATHS[@]}"; do
  echo "${WORKFLOW_CONTENT}" > "${WORKFLOW_PATH}"
done

echo "CI/CD workflows updated successfully."
```

**END OF PROMPT**
___

### Result of Prompting the Monolith 

**Outcome and Resume**

**Outcome:** After thorough testing and analysis, it has been determined that the GPT model is currently unable to directly meet the level of complexity required by detailed OpenAPI specifications. This conclusion is based on several identified limitations in the model’s scope, context management, precision in code generation, and ability to handle integrations and middleware.

**Resume:** The test focused on evaluating the GPT model's capability to generate a fully functional Vapor application in Swift based on a comprehensive OpenAPI specification. The evaluation encompassed multiple dimensions, including understanding of detailed specifications, state management, precision in code generation, and handling complex integrations. Despite its advanced capabilities, the GPT model fell short in meeting the intricate requirements of the task.

**Prompts Used for Testing:**
- [Prompt Version 1](https://github.com/Contexter/fountainAI/blob/editorial/episodes/Episode5/FountainAI%20Prompt%20Engineering%20-%20Prompt%20Version%201.md)
- [Prompt Version 2](https://github.com/Contexter/fountainAI/blob/editorial/episodes/Episode5/FountainAI%20Prompt%20Engineering%20-%20Prompt%20Version%202.md)

## Table of Contents
1. [Scope and Depth of Understanding](#1-scope-and-depth-of-understanding)
2. [Context and State Management](#2-context-and-state-management)
3. [Precision and Accuracy in Code Generation](#3-precision-and-accuracy-in-code-generation)
4. [Integration and Middleware](#4-integration-and-middleware)
5. [Why Writing More Descriptive Prompts Doesn't Change the Situation](#why-writing-more-descriptive-prompts-doesnt-change-the-situation)
6. [Conclusion](#conclusion)
7. [Foreshadowing Problem Solution Strategy - Episode 6](#foreshadowing-problem-solution-strategy---episode-6)

### 1. Scope and Depth of Understanding

- **Complexity of OpenAPI Specifications:** OpenAPI specifications can be highly complex, involving detailed schema definitions, relationships, error handling, middleware, and integration with various services like databases, caches, and third-party APIs.
- **Model Limitations:** GPT models are trained on a wide array of text data but are not specifically optimized to understand and execute detailed technical specifications like those found in an OpenAPI document. The model might miss nuanced details or fail to fully grasp the intricate relationships and validation rules that are critical for a robust implementation.

### 2. Context and State Management

- **Limited Context Window:** GPT models have a limited context window (for example, 2048 tokens for GPT-3), which means they can only consider a portion of the input at a time. Detailed specifications often exceed this limit, causing the model to lose track of essential details as it processes the text.
- **Lack of State Awareness:** The model does not retain state between interactions, making it difficult to build upon previous outputs in a coherent manner. This is crucial for managing complex, multi-step processes like setting up a comprehensive CI/CD pipeline or implementing interdependent models and controllers.

### 3. Precision and Accuracy in Code Generation

- **Nuanced Requirements:** Specifications often include nuanced requirements and edge cases that need precise implementation. GPT-generated code may lack the accuracy and detail required to handle these effectively.
- **Error Handling and Validation:** Implementing robust error handling and validation requires a deep understanding of the domain logic and user expectations, which the model might not fully capture from the input prompt.

### 4. Integration and Middleware

- **Complex Integrations:** Integrating Redis, RedisAI, Docker, and other services involves not only code but also configuration files, environment setup, and operational knowledge that goes beyond what a static text model can generate accurately.
- **Middleware and Caching:** Detailed configurations and middleware setups require a specific order of operations and precise parameters that the model might not fully detail or understand, leading to incomplete or incorrect implementations.

### Why Writing More Descriptive Prompts Doesn't Change the Situation

1. **Descriptive Prompts vs. Practical Execution:**
   - **Information Overload:** Providing more descriptive prompts might overload the model with too much information at once, leading to confusion and errors. The model can struggle to prioritize and organize the information effectively.
   - **Lack of Practical Execution Context:** Descriptive prompts can outline what needs to be done, but the model lacks the practical execution context to implement these steps correctly. It doesn't interact with real-world systems or tools to validate and refine its output.

2. **Ambiguity and Interpretation:**
   - **Ambiguous Instructions:** More descriptive prompts can still be interpreted in multiple ways. The model may generate code that appears correct but does not function as intended in the real-world context.
   - **Misinterpretation of Specifications:** The model might misinterpret complex relationships and dependencies outlined in the specifications, leading to incomplete or incorrect code.

3. **Iterative Development and Feedback Loops:**
   - **Need for Iterative Refinement:** Complex software development often requires iterative refinement and feedback loops, something that a static model output cannot provide. Developers usually test, debug, and refine their code in cycles, adapting to unexpected issues and edge cases.
   - **Real-Time Adjustments:** Descriptive prompts cannot account for real-time adjustments and problem-solving that occur during development. The model cannot dynamically adjust its approach based on testing and feedback.

### Conclusion

While GPT models can assist in generating code snippets and providing a starting point, they are currently limited in their ability to fully implement complex specifications like those found in an OpenAPI document. The depth of understanding, context management, precision, and real-world execution required for such tasks exceed the capabilities of the model. Forcing the model to become aware of the complexity through descriptive prompts does not bridge these fundamental gaps, as the model lacks practical execution capabilities, iterative refinement, and precise handling of nuanced requirements.

### Foreshadowing Problem Solution Strategy - Episode 6

#### Recomposition Strategy for Implementing Complex OpenAPI Specification

In the next episode, we will explore a recomposition strategy to manage the complexity of the given OpenAPI specification. This approach involves breaking down the specification into smaller, manageable components, implementing single model CRUD APIs, and utilizing CI/CD pipelines, custom GitHub Actions, and Docker Compose for incremental development and integration. By structuring the implementation into well-defined steps, we can effectively build and integrate the components required for the full specification, ensuring a robust and maintainable solution.

#### Optimistic Use of GPT Models

Despite the challenges, GPT models can generate instantly valid code with managed complexity. By providing well-structured prompts and breaking down tasks into simpler components, GPT can produce code beyond mere snippets, facilitating faster development cycles and offering substantial assistance in the software development process.