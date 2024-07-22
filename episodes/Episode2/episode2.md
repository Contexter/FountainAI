### `episodes/episode2.md`
# Episode 2: Creating and Managing the CI/CD Pipeline for The FountainAI with GitHub Actions

## Table of Contents

1. [Introduction](#introduction)
2. [Pipeline Setup Script](#pipeline-setup-script)
3. [Discussion](#discussion)
   - [Branch Management](#branch-management)
   - [Triggering Workflows](#triggering-workflows)
   - [CI/CD Pipeline](#cicd-pipeline)
4. [Conclusion](#conclusion)
5. [Foreshadowing the Next Episode](#foreshadowing-the-next-episode)

## Introduction

In this episode, we will create and manage a CI/CD pipeline for The FountainAI with GitHub Actions. This pipeline will automate the process of building, testing, and deploying The FountainAI application, ensuring continuous integration and continuous deployment.

For more details on CI/CD and GitHub workflows, please refer to the [Ultimate Guide to CI/CD and GitHub Workflows](https://github.com/Contexter/fountainAI/blob/editorial/episodes/Episode2/The%20Ultimate%20Guide%20to%20CI_CD%20and%20GitHub%20Workflows.md).

We will guide you through a single script that sets up the folder structure for the CI/CD pipeline, creates GitHub branches, and generates the necessary actions and workflows using Docker-based custom actions. We'll then discuss how committing to a branch triggers workflows and the overall reasoning behind the CI/CD pipeline.

For more details on the API endpoints and the Dockerized environment, you can refer to the [FountainAI API OpenAPI specification](https://github.com/Contexter/fountainAI/blob/editorial/openAPI/FountainAI-Admin-openAPI.yaml). This API integrates functionalities for managing scripts, including section headings, transitions, spoken words, orchestration, complete script management, characters, and actions, along with their paraphrases. The Dockerized environment includes Nginx for SSL termination, a Swift-based Vapor app, PostgreSQL for data persistence, Redis for caching, and RedisAI for recommendations and validations.

### Putting Things into Perspective

The FountainAI API operates within a highly integrated Dockerized environment, leveraging several containerized services to ensure performance, security, and scalability. Here’s why this CI/CD pipeline is particularly well-suited to this environment:

1. **Dockerized Custom Actions**: By using Docker-based custom actions in the CI/CD pipeline, we can ensure that each step in the workflow is executed in a consistent environment. This eliminates the "works on my machine" problem and ensures that the same versions of dependencies and tools are used in development, testing, and production environments.

2. **Service Integration**: The FountainAI API relies on multiple services running in Docker containers, including Nginx for SSL termination, a Vapor application server, PostgreSQL for data persistence, Redis for caching, and RedisAI for advanced recommendations and validations. The CI/CD pipeline can be configured to start and test these services as part of the workflow, ensuring that any changes to the codebase are compatible with the entire system architecture.

3. **Automated Testing and Deployment**: Automated workflows ensure that every code change is tested in an environment that mirrors production as closely as possible. This includes running unit tests, integration tests, and end-to-end tests that interact with the Dockerized services. This rigorous testing helps catch issues early in the development process.

4. **Scalability and Consistency**: With Docker, scaling services is straightforward. The CI/CD pipeline can be extended to deploy multiple instances of the Vapor app or other components as needed, ensuring that the system can handle increased load while maintaining consistent performance.

5. **Secrets Management**: Managing secrets such as API keys, SSH keys, and database credentials is critical in a Dockerized environment. The pipeline includes a custom action for managing secrets, ensuring that sensitive information is handled securely and is only accessible to authorized parts of the workflow.

## Pipeline Setup Script

### The Setup Script

Create the following script to set up the folder structure, create GitHub branches, and generate actions and workflows for the CI/CD pipeline using Docker-based custom actions.

```bash
#!/bin/bash

# Function to run a step if it hasn't been run before
run_once() {
  step_name=$1
  log_file=".pipeline_setup_log"

  # Check if the step has been run before
  if grep -q "$step_name" "$log_file"; then
    echo "$step_name has already been run. Skipping..."
  else
    echo "Running $step_name..."
    $step_name
    echo "$step_name" >> "$log_file"
  fi
}

# Create .pipeline_setup_log if it doesn't exist
touch .pipeline_setup_log

# Step 1: Create the folder structure for the CI/CD pipeline
create_folder_structure() {
  echo "Creating folder structure..."
  mkdir -p .github
  mkdir -p .github/workflows
  mkdir -p .github/actions/manage-secrets
  mkdir -p .github/actions/setup
  mkdir -p .github/actions/build
  mkdir -p .github/actions/test
  mkdir -p .github/actions/deploy
  echo "Folder structure created successfully!"
}

# Step 2: Create the GitHub branches for CI/CD
create_github_branches() {
  echo "Creating GitHub branches..."
  git checkout -b development
  git push origin development
  git checkout -b testing
  git push origin testing
  git checkout -b staging
  git push origin staging
  git checkout main
  echo "GitHub branches created and pushed successfully!"
}

# Step 3: Create the Manage Secrets action
create_manage_secrets_action() {
  echo "Creating Manage Secrets action..."
  mkdir -p .github/actions/manage-secrets
  cat <<EOL > .github/actions/manage-secrets/action.yml
name: 'Manage Secrets'
description: 'Action to manage and validate secrets'
inputs:
  github_token:
    description: 'GitHub Token'
    required: true
    type: string
runs:
  using: 'docker'
  image: 'alpine:3.12'
  args:
    - /bin/sh
    - -c
    - |
      # Check if the github_token is set
      # Placeholder for actual action content
      if [ -z "\${{ inputs.github_token }}" ]; then
        echo "GITHUB_TOKEN is not set"
        exit 1
      else
        echo "GITHUB_TOKEN is set"
        # Add actual management and validation commands here
      fi
EOL
  echo "Manage Secrets action created successfully!"
}

# Step 4: Create the Setup Environment action
create_setup_environment_action() {
  echo "Creating Setup Environment action..."
  mkdir -p .github/actions/setup
  cat <<EOL > .github/actions/setup/action.yml
name: 'Setup Environment'
description: 'Action to setup the environment'
inputs:
  vps_ssh_key:
    description: 'VPS SSH Key'
    required: true
    type: string
runs:
  using: 'docker'
  image: 'alpine:3.12'
  args:
    - /bin/sh
    - -c
    - |
      # Check if the vps_ssh_key is set
      # Placeholder for actual action content
      if [ -z "\${{ inputs.vps_ssh_key }}" ]; then
        echo "VPS_SSH_KEY is not set"
        exit 1
      else
        echo "VPS_SSH_KEY is set"
        # Add actual environment setup commands here
      fi
EOL
  echo "Setup Environment action created successfully!"
}

# Step 5: Create the Build Project action
create_build_project_action() {
  echo "Creating Build Project action..."
  mkdir -p .github/actions/build
  cat <<EOL > .github/actions/build/action.yml
name: 'Build Project'
description: 'Action to build the project'
runs:
  using: 'docker'
  image: 'node:14'
  args:
    - /bin/sh
    - -c
    - |
      # Placeholder for actual action content
      echo "Building project..."
      # Add actual build commands here
EOL
  echo "Build Project action created successfully!"
}

# Step 6: Create the Test Project action
create_test_project_action() {
  echo "Creating Test Project action..."
  mkdir -p .github/actions/test
  cat <<EOL > .github/actions/test/action.yml
name: 'Test Project'
description: 'Action to test the project'
runs:
  using: 'docker'
  image: 'node:14'
  args:
    - /bin/sh
    - -c
    - |
      # Placeholder for actual action content
      echo "Running tests..."
      # Add actual test commands here
EOL
  echo "Test Project action created successfully!"
}

# Step 7: Create the Deploy Project action
create_deploy_project_action() {
  echo "Creating Deploy Project action..."
  mkdir -p .github/actions/deploy
  cat <<EOL > .github/actions/deploy/action.yml
name: 'Deploy Project'
description: 'Action to deploy the project'
runs:
  using: 'docker'
  image: 'alpine:3.12'
  args:
    - /bin/sh
    - -c
    - |
      # Placeholder for actual action content
      echo "Deploying to environment..."
      # Add actual deployment commands here
EOL
  echo "Deploy Project action created successfully!"
}

# Step 8: Create the Development Workflow
create_development

_workflow() {
  echo "Creating Development Workflow..."
  cat <<EOL > .github/workflows/development.yml
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
          github_token: \${{ secrets.GITHUB_TOKEN }}
  setup:
    needs: verify-secrets
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
EOL
  echo "Development Workflow created successfully!"
}

# Step 9: Create the Testing Workflow
create_testing_workflow() {
  echo "Creating Testing Workflow..."
  cat <<EOL > .github/workflows/testing.yml
name: Testing Workflow
on:
  push:
    branches:
      - testing
jobs:
  verify-secrets:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Manage Secrets
        uses: ./.github/actions/manage-secrets
        with:
          github_token: \${{ secrets.GITHUB_TOKEN }}
  setup:
    needs: verify-secrets
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
  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Test Project
        uses: ./.github/actions/test
EOL
  echo "Testing Workflow created successfully!"
}

# Step 10: Create the Staging Workflow
create_staging_workflow() {
  echo "Creating Staging Workflow..."
  cat <<EOL > .github/workflows/staging.yml
name: Staging Workflow
on:
  push:
    branches:
      - staging
jobs:
  verify-secrets:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Manage Secrets
        uses: ./.github/actions/manage-secrets
        with:
          github_token: \${{ secrets.GITHUB_TOKEN }}
  setup:
    needs: verify-secrets
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
  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Test Project
        uses: ./.github/actions/test
  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Project
        uses: ./.github/actions/deploy
EOL
  echo "Staging Workflow created successfully!"
}

# Step 11: Create the Production Workflow
create_production_workflow() {
  echo "Creating Production Workflow..."
  cat <<EOL > .github/workflows/production.yml
name: Production Workflow
on:
  push:
    branches:
      - main
jobs:
  verify-secrets:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Manage Secrets
        uses: ./.github/actions/manage-secrets
        with:
          github_token: \${{ secrets.GITHUB_TOKEN }}
  setup:
    needs: verify-secrets
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
  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Test Project
        uses: ./.github/actions/test
  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Project
        uses: ./.github/actions/deploy
EOL
  echo "Production Workflow created successfully!"
}

# Execute the pipeline setup steps
run_once "create_folder_structure"
run_once "create_github_branches"
run_once "create_manage_secrets_action"
run_once "create_setup_environment_action"
run_once "create_build_project_action"
run_once "create_test_project_action"
run_once "create_deploy_project_action"
run_once "create_development_workflow"
run_once "create_testing_workflow"
run_once "create_staging_workflow"
run_once "create_production_workflow"

echo "CI/CD pipeline setup script has been executed successfully."
```

Save this script as `pipeline_setup.sh` in the `episodes/Episode2` directory:

```sh
touch episodes/Episode2/pipeline_setup.sh
```

Open the file with your preferred text editor and paste the above script content into it. Then make the script executable and run it:

```sh
chmod +x episodes/Episode2/pipeline_setup.sh
./episodes/Episode2/pipeline_setup.sh
```

## Discussion

### Branch Management

GitHub branches are essential for managing and developing different aspects of your project concurrently. They allow you to work on new features, fixes, or experiments in isolation from your main codebase. Once the work on a branch is complete, it can be merged back into the main branch.

### Triggering Workflows

Each branch is associated with specific workflows that are triggered upon events like pushes and pull requests. For instance, a push to the development branch can trigger a build and test workflow, while a push to the staging branch can trigger a deployment workflow.

### CI/CD Pipeline

The CI/CD pipeline automates the process of building, testing, and deploying The FountainAI application. Here's how it works:

1. **Setup Folder Structure**: The first step of the script creates the necessary directory structure for GitHub Actions workflows and custom actions.
2. **Custom Actions Creation**: Each custom action script sets up specific actions used in the workflows, such as managing secrets, setting up the environment, building the project, testing, and deploying.
3. **Workflows Definition**: Workflow scripts define the sequences of actions that run on specific events (e.g., push to a branch).

### Action Placeholders

The scripts include placeholders for actual commands that need to be executed for managing secrets, setting up the environment, building, testing, and deploying the project. These placeholders need to be replaced with actual commands specific to The FountainAI application. For example:

- **Manage Secrets Action**:
  ```yaml
  runs:
    using: 'docker'
    image: 'alpine:3.12'
    args:
      - /bin/sh
      - -c
      - |
        # Check if the github_token is set
        if [ -z "${{ inputs.github_token }}" ]; then
          echo "GITHUB_TOKEN is not set"
          exit 1
        else
          echo "GITHUB_TOKEN is set"
          # Add actual management and validation commands here
        fi
  ```

- **Setup Environment Action**:
  ```yaml
  runs:
    using: 'docker'
    image: 'alpine:3.12'
    args:
      - /bin/sh
      - -c
      - |
        # Check if the vps_ssh_key is set
        if [ -z "${{ inputs.vps_ssh_key }}" ]; then
          echo "VPS_SSH_KEY is not set"
          exit 1
        else
          echo "VPS_SSH_KEY is set"
          # Add actual environment setup commands here
        fi
  ```

- **Build Project Action**:
  ```yaml
  runs:
    using: 'docker'
    image: 'node:14'
    args:
      - /bin/sh
      - -c
      - |
        # Placeholder for actual action content
        echo "Building project..."
        # Add actual build commands here
  ```

- **Test Project Action**:
  ```yaml
  runs:
    using: 'docker'
    image: 'node:14'
    args:
      - /bin/sh
      - -c
      - |
        # Placeholder for actual action content
        echo "Running tests..."
        # Add actual test commands here
  ```

- **Deploy Project Action**:
  ```yaml
  runs:
    using: 'docker'
    image: 'alpine:3.12'
    args:
      - /bin/sh
      - -c
      - |
        # Placeholder for actual action content
        echo "Deploying to environment..."
        # Add actual deployment commands here
  ```

### Benefits Realized

By implementing this CI/CD pipeline, we've achieved several benefits:
- **Automated Setup**: The single script ensures that all setup steps are completed correctly and only once, reducing the risk of errors.
- **Modular Actions**: Custom actions are reusable and maintainable, allowing for easier updates and extensions.
- **Branch Management**: Structured branching strategy ensures stable and deployable code in the main branch while enabling concurrent development and testing.

### Future Outlook

In future episodes, we will build upon this foundation to further enhance the CI/CD pipeline. This will include:
- **Advanced Testing**: Implementing more comprehensive testing strategies.
- **Continuous Deployment**: Automating deployments to production environments with zero downtime.
- **Monitoring and Alerts**: Adding monitoring and alerting capabilities to ensure the health of deployments.

## Conclusion

By following this guide, you have set up a comprehensive CI/CD pipeline using GitHub Actions with robust secrets management. The custom actions created are modular, maintainable, and reusable across different workflows. You can further extend this setup to include additional workflows and actions as per your project’s requirements.

## Foreshadowing the Next Episode

In the next episode, we will focus on creating a basic "Hello, World!" Vapor application, Dockerizing it, and integrating it into the CI/CD pipeline established in this episode. We will also introduce Docker Compose to manage multiple containers and ensure a smooth deployment process. This integration will utilize the secrets management scheme already set up to handle sensitive information securely.

Stay tuned for Episode 3: "Creating and Managing the Vapor App for FountainAI with CI/CD Pipeline."

---