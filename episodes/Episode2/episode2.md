### `episodes/episode2.md`
# Episode 2: Creating and Managing the CI/CD Pipeline with GitHub Actions

## Table of Contents

1. [Introduction](#introduction)
2. [Folder Structure Before Running the Script](#folder-structure-before-running-the-script)
3. [Pipeline Setup Script](#pipeline-setup-script)
4. [Folder Structure After Running the Script](#folder-structure-after-running-the-script)
5. [Discussion](#discussion)
   - [Branch Management](#branch-management)
   - [Triggering Workflows](#triggering-workflows)
   - [CI/CD Pipeline](#cicd-pipeline)
6. [Conclusion](#conclusion)
7. [Foreshadowing the Next Episode](#foreshadowing-the-next-episode)

## Introduction

In this episode, we will create and manage a CI/CD pipeline using GitHub Actions. This pipeline will automate the process of building, testing, and deploying the FountainAI application, ensuring continuous integration and continuous deployment.

We will guide you through a single script that sets up the folder structure for the CI/CD pipeline, creates GitHub branches, and generates the necessary actions and workflows. We'll then discuss how committing to a branch triggers workflows and the overall reasoning behind the CI/CD pipeline.

## Folder Structure Before Running the Script

Before running the setup script, the folder structure is as follows:

```
fountainAI/
├── README.md
├── config.env
├── episodes
│   ├── Episode1
│   │   ├── episode1.md
│   │   ├── setup_all.sh
│   │   ├── setup_episodes.sh
│   │   └── setup_project_structure.sh
│   ├── Episode10
│   │   └── episode10.md
│   ├── Episode2
│   │   └── episode2.md
│   ├── Episode3
│   │   └── episode3.md
│   ├── Episode4
│   │   └── episode4.md
│   ├── Episode5
│   │   └── episode5.md
│   ├── Episode6
│   │   └── episode6.md
│   ├── Episode7
│   │   └── episode7.md
│   ├── Episode8
│   │   └── episode8.md
│   └── Episode9
│       └── episode9.md
└── openAPI
    ├── Class openAPI
    │   ├── Action.yaml
    │   ├── Character.yaml
    │   ├── MusicSound.yaml
    │   ├── Note.yaml
    │   ├── Script.yaml
    │   ├── SectionHeading.yaml
    │   ├── SpokenWord.yaml
    │   └── Transition.yaml
    ├── FountainAI-Admin-openAPI.yaml
    ├── GPT-constructive-openAPI.yaml
    ├── README.md
    └── Tools openAPI
        └── trainoptimizeseed.yaml
```

## Pipeline Setup Script

### The Setup Script

Create the following script to set up the folder structure, create GitHub branches, and generate actions and workflows for the CI/CD pipeline.

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
  using: 'node20'
  main: 'index.js'
EOL

  cat <<EOL > .github/actions/manage-secrets/index.js
const core = require('@actions/core');
try {
  const secrets = ['github_token'];
  secrets.forEach(secret => {
    const value = core.getInput(secret);
    if (!value) {
      core.setFailed(\`\${secret.toUpperCase()} is not set\`);
    } else {
      core.info(\`\${secret.toUpperCase()} is set\`);
    }
  });
} catch (error) {
  core.setFailed(error.message);
}
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
  using: 'node20'
  main: 'index.js'
EOL

  cat <<EOL > .github/actions/setup/index.js
const core = require('@actions/core');
try {
  const vpsSshKey = core.getInput('vps_ssh_key');
  if (!vpsSshKey) core.setFailed('VPS_SSH_KEY is not set');
  // Here is where you will provide the commands to setup the environment
  core.info('VPS setup with SSH key');
} catch (error) {
  core.setFailed(error.message);
}
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
  using: 'node20'
  main: 'index.js'
EOL

  cat <<EOL > .github/actions/build/index.js
const core = require('@actions/core');
try {
  // Here is where you will provide the commands to build the project
  core.info('Project build process started');
} catch (error) {
  core.setFailed(error.message);
}
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
  using: 'node20'
  main: 'index.js'
EOL

  cat <<EOL > .github/actions/test/index.js
const core = require('@actions/core');
try {
  // Here is where you will provide the commands to test the project
  core.info('Project test process started');
} catch (error) {
  core.setFailed(error.message);
}
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
  using: 'node20'
  main: 'index.js'
EOL

  cat <<EOL > .github/actions/deploy/index.js
const core = require('@actions/core');
try {
  // Here is where you will provide the commands to deploy the project
  core.info('Project deploy process started');
} catch (error) {
  core.setFailed(error.message);
}
EOL
  echo "Deploy Project action created successfully!"
}

# Step 8: Create the Development Workflow
create_development_workflow() {
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

## Folder Structure After Running the Script

After running the setup script, the folder structure should look like this:

```
fountainAI/
├── .github
│   ├── actions
│   │   ├── build
│   │   │   ├── action.yml
│   │   │   └── index.js
│   │   ├── deploy
│   │   │   ├── action.yml
│   │   │   └── index.js
│   │   ├── manage-secrets
│   │   │   ├── action.yml
│   │   │   └── index.js
│   │   ├── setup
│   │   │   ├── action.yml
│   │   │   └── index.js
│   │   ├── test
│   │   │   ├── action.yml
│   │   │   └── index.js
│   ├── workflows
│   │   ├── development.yml
│   │   ├── production.yml
│   │   ├── staging.yml
│   │   └── testing.yml
├── README.md
├── config.env
├── episodes
│   ├── Episode1
│   │   ├── episode1.md
│   │   ├── setup_all.sh
│   │   ├── setup_episodes.sh
│   │   └── setup_project_structure.sh
│   ├── Episode10
│   │   └── episode10.md
│   ├── Episode2
│   │   ├── episode2.md
│   │   ├── pipeline_setup.sh
│   ├── Episode3
│   │   └── episode3.md
│   ├── Episode4
│   │   └── episode4.md
│   ├── Episode5
│   │   └── episode5.md
│   ├── Episode6
│   │   └── episode6.md
│   ├── Episode7
│   │   └── episode7.md
│   ├── Episode8
│   │   └── episode8.md
│   └── Episode9
│       └── episode9.md
└── openAPI
    ├── Class openAPI
    │   ├── Action.yaml
    │   ├── Character.yaml
    │   ├── MusicSound.yaml
    │   ├── Note.yaml
    │   ├── Script.yaml
    │   ├── SectionHeading.yaml
    │   ├── SpokenWord.yaml
    │   └── Transition.yaml
    ├── FountainAI-Admin-openAPI.yaml
    ├── GPT-constructive-openAPI.yaml
    ├── README.md
    └── Tools openAPI
        └── trainoptimizeseed.yaml
```

## Discussion

### Branch Management

GitHub branches are essential for managing and developing different aspects of your project concurrently. They allow you to work on new features, fixes, or experiments in isolation from your main codebase. Once the work on a branch is complete, it can be merged back into the main branch.

### Triggering Workflows

Each branch is associated with specific workflows that are triggered upon events like pushes and pull requests. For instance, a push to the development branch can trigger a build and test workflow, while a push to the staging branch can trigger a deployment workflow.

### CI/CD Pipeline

The CI/CD pipeline automates the process of building, testing, and deploying the FountainAI application. Here's how it works:

1. **Setup Folder Structure**: The first step of the script creates the necessary directory structure for GitHub Actions workflows and custom actions.
2. **Custom Actions Creation**: Each custom action script sets up specific actions used in the workflows, such as managing secrets, setting up the environment, building the project, testing, and deploying.
3. **Workflows Definition**: Workflow scripts define the sequences of actions that run on specific events (e.g., push to a branch).

### Code Comments

In the action scripts, you'll find comments indicating where to add commands in the future:

- **Setup Environment Action**:
  ```js
  // Here is where you will provide the commands to setup the environment
  ```

- **Build Project Action**:
  ```js
  // Here is where you will provide the commands to build the project
  ```

- **Test Project Action**:
  ```js
  // Here is where you will provide the commands to test the project
  ```

- **Deploy Project Action**:
  ```js
  // Here is where you will provide the commands to deploy the project
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