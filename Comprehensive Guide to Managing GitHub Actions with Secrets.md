# Comprehensive Guide to Managing GitHub Actions with Secrets

## Table of Contents
- [Introduction](#introduction)
- [Requirements](#requirements)
- [Project Structure](#project-structure)
- [Setting Up the Environment](#setting-up-the-environment)
- [Creating Custom Actions](#creating-custom-actions)
  - [Manage Secrets Action](#manage-secrets-action)
  - [Setup Environment Action](#setup-environment-action)
  - [Build Project Action](#build-project-action)
  - [Test Project Action](#test-project-action)
  - [Deploy Project Action](#deploy-project-action)
- [Defining Workflows](#defining-workflows)
  - [Development Workflow](#development-workflow)
  - [Testing Workflow](#testing-workflow)
  - [Staging Workflow](#staging-workflow)
  - [Production Workflow](#production-workflow)
- [Conclusion](#conclusion)
- [Addendum: Idempotent Shell Script to Automate Setup](#addendum-idempotent-shell-script-to-automate-setup)
  - [Overview](#overview)
  - [Idempotent Setup Script](#idempotent-setup-script)
  - [Usage](#usage)
- [Development Perspective](#development-perspective)

## Introduction
In this guide, we will set up GitHub Actions with a robust secrets management system. We’ll create custom actions to manage secrets, set up the environment, build, test, and deploy the project. This guide will provide detailed steps and shell scripts to automate the setup process.

## Requirements
Before we start, ensure you have the following:

- A GitHub repository.
- Necessary secrets configured in the GitHub repository.

## Project Structure
Before diving into the implementation, it’s essential to understand the overall project structure we aim to achieve. The project will have a .github directory containing workflows and custom actions. Each custom action will have its own directory with an action.yml file and an implementation file (index.js).

Initial Project Tree:

```
.
├── .github
│   ├── workflows
│   │   ├── development.yml
│   │   ├── testing.yml
│   │   ├── staging.yml
│   │   ├── production.yml
│   └── actions
│       ├── manage-secrets
│       │   ├── action.yml
│       │   └── index.js
│       ├── setup
│       │   ├── action.yml
│       │   └── index.js
│       ├── build
│       │   ├── action.yml
│       │   └── index.js
│       ├── test
│       │   ├── action.yml
│       │   └── index.js
│       └── deploy
│           ├── action.yml
│           └── index.js
└── README.md
```

## Setting Up the Environment
To kick things off, we’ll set up the basic directory structure for our project. This step ensures that we have all the necessary folders and files in place before we start creating custom actions and workflows.

Here’s a shell script to set up the project structure:

```bash
#!/bin/bash

# Create the .github directory if it doesn't exist
mkdir -p .github

# Create subdirectories for workflows and custom actions
mkdir -p .github/workflows
mkdir -p .github/actions/manage-secrets
mkdir -p .github/actions/setup
mkdir -p .github/actions/build
mkdir -p .github/actions/test
mkdir -p .github/actions/deploy

# Create a placeholder README.md inside the .github directory
echo "# GitHub Actions Project" > .github/README.md

echo "Project structure set up successfully!"
```

Save this script as `setup_project_structure.sh` by using the following commands:

```bash
touch setup_project_structure.sh
```

Open the file with your preferred text editor and paste the above script content into it. Then make the script executable and run it:

```bash
chmod +x setup_project_structure.sh
./setup_project_structure.sh
```

After running the script, your project directory should match the initial project tree structure provided above.

## Creating Custom Actions
Now that we have our project structure in place, we will create custom actions. Custom actions help in modularizing the workflows and reusing code. We’ll start by creating an action to manage secrets.

### Manage Secrets Action
The “Manage Secrets” action is responsible for validating that all required secrets are set. It will read the secrets from the workflow and ensure they are not empty.

Here are the steps to create the Manage Secrets action:

Create action.yml and index.js for Manage Secrets:

```bash
#!/bin/bash

# Create the action.yml file for the Manage Secrets action
cat <<EOL > .github/actions/manage-secrets/action.yml
name: 'Manage Secrets'
description: 'Action to manage and validate secrets'
inputs:
  github_token:
    description: 'GitHub Token'
    required: true
    type: string
  vps_ssh_key:
    description: 'VPS SSH Key'
    required: true
    type: string
  vps_username:
    description: 'VPS Username'
    required: true
    type: string
  vps_ip:
    description: 'VPS IP Address'
    required: true
    type: string
  deploy_dir:
    description: 'Deployment Directory'
    required: true
    type: string
  repo_owner:
    description: 'Repository Owner'
    required: true
    type: string
  app_name:
    description: 'Application Name'
    required: true
    type: string
  domain:
    description: 'Production Domain'
    required: true
    type: string
  staging_domain:
    description: 'Staging Domain'
    required: true
    type: string
  db_name:
    description: 'Database Name'
    required: true
    type: string
  db_user:
    description: 'Database User'
    required: true
    type: string
  db_password:
    description: 'Database Password'
    required: true
    type: string
  email:
    description: 'Email'
    required: true
    type: string
  main_dir:
    description: 'Main Directory'
    required: true
    type: string
  nydus_port:
    description: 'Nydus Port'
    required: true
    type: string
  redisai_port:
    description: 'RedisAI Port'
    required: true
    type: string
  redis_port:
    description: 'Redis Port'
    required: true
    type: string
  repo_name:
    description: 'Repository Name'
    required: true
    type: string
  runner_token:
    description: 'Runner Token'
    required: true
    type: string
runs:
  using: 'node20'
  main: 'index.js'
EOL

# Create the index.js file for the Manage Secrets action
cat <<EOL > .github/actions/manage-secrets/index.js
const core = require('@actions/core');

try {
  const secrets = [
    'github_token',
    'vps_ssh_key',
    'vps_username',
    'vps_ip',
    'deploy_dir',
    'repo_owner',
    'app_name',
    'domain',
    'staging_domain',
    'db_name',
    'db_user',
    'db_password',
    'email',
    'main_dir',
    'nydus_port',
    'redisai_port',
    'redis_port',
    'repo_name',
    'runner_token'
  ];

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
```

Save this script as `create_manage_secrets_action.sh` by using the following commands:

```bash
touch create_manage_secrets_action.sh
```

Open the file with your preferred text editor and paste the above script content into it. Then make the script executable and run it:

```bash
chmod +x create_manage_secrets_action.sh
./create_manage_secrets_action.sh
```

This will create the Manage Secrets action in the .github/actions/manage-secrets directory.

### Setup Environment Action
The “Setup Environment” action is responsible for preparing the VPS environment using the provided SSH key. It will use the vps_ssh_key to authenticate and perform setup tasks.

Here are the steps to create the Setup Environment action:

Create action.yml and index.js for Setup Environment:

```bash
#!/bin/bash

# Create the action.yml file for the Setup Environment action
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

# Create the index.js file for the Setup Environment action
cat <<EOL > .github/actions/setup/index.js
const core = require('@actions/core');

try {
  const vpsSshKey = core.getInput('vps_ssh_key');
  if (!vpsSshKey) core.setFailed('VPS_SSH_KEY is not set');
  
  // Setup commands can be added here
 

 core.info('VPS setup with SSH key');
} catch (error) {
  core.setFailed(error.message);
}
EOL

echo "Setup Environment action created successfully!"
```

Save this script as `create_setup_environment_action.sh` by using the following commands:

```bash
touch create_setup_environment_action.sh
```

Open the file with your preferred text editor and paste the above script content into it. Then make the script executable and run it:

```bash
chmod +x create_setup_environment_action.sh
./create_setup_environment_action.sh
```

This will create the Setup Environment action in the .github/actions/setup directory.

### Build Project Action
The “Build Project” action is responsible for building the project. It will contain the necessary commands to compile and prepare the project for deployment.

Here are the steps to create the Build Project action:

Create action.yml and index.js for Build Project:

```bash
#!/bin/bash

# Create the action.yml file for the Build Project action
cat <<EOL > .github/actions/build/action.yml
name: 'Build Project'
description: 'Action to build the project'
runs:
  using: 'node20'
  main: 'index.js'
EOL

# Create the index.js file for the Build Project action
cat <<EOL > .github/actions/build/index.js
const core = require('@actions/core');

try {
  // Add build commands here
  core.info('Project build process started');
} catch (error) {
  core.setFailed(error.message);
}
EOL

echo "Build Project action created successfully!"
```

Save this script as `create_build_project_action.sh` by using the following commands:

```bash
touch create_build_project_action.sh
```

Open the file with your preferred text editor and paste the above script content into it. Then make the script executable and run it:

```bash
chmod +x create_build_project_action.sh
./create_build_project_action.sh
```

This will create the Build Project action in the .github/actions/build directory.

### Test Project Action
The “Test Project” action is responsible for testing the project. It will contain the necessary commands to run tests and validate the project.

Here are the steps to create the Test Project action:

Create action.yml and index.js for Test Project:

```bash
#!/bin/bash

# Create the action.yml file for the Test Project action
cat <<EOL > .github/actions/test/action.yml
name: 'Test Project'
description: 'Action to test the project'
runs:
  using: 'node20'
  main: 'index.js'
EOL

# Create the index.js file for the Test Project action
cat <<EOL > .github/actions/test/index.js
const core = require('@actions/core');

try {
  // Add test commands here
  core.info('Project test process started');
} catch (error) {
  core.setFailed(error.message);
}
EOL

echo "Test Project action created successfully!"
```

Save this script as `create_test_project_action.sh` by using the following commands:

```bash
touch create_test_project_action.sh
```

Open the file with your preferred text editor and paste the above script content into it. Then make the script executable and run it:

```bash
chmod +x create_test_project_action.sh
./create_test_project_action.sh
```

This will create the Test Project action in the .github/actions/test directory.

### Deploy Project Action
The “Deploy Project” action is responsible for deploying the project. It will contain the necessary commands to deploy the project to the specified environment.

Here are the steps to create the Deploy Project action:

Create action.yml and index.js for Deploy Project:

```bash
#!/bin/bash

# Create the action.yml file for the Deploy Project action
cat <<EOL > .github/actions/deploy/action.yml
name: 'Deploy Project'
description: 'Action to deploy the project'
runs:
  using: 'node20'
  main: 'index.js'
EOL

# Create the index.js file for the Deploy Project action
cat <<EOL > .github/actions/deploy/index.js
const core = require('@actions/core');

try {
  // Add deploy commands here
  core.info('Project deploy process started');
} catch (error) {
  core.setFailed(error.message);
}
EOL

echo "Deploy Project action created successfully!"
```

Save this script as `create_deploy_project_action.sh` by using the following commands:

```bash
touch create_deploy_project_action.sh
```

Open the file with your preferred text editor and paste the above script content into it. Then make the script executable and run it:

```bash
chmod +x create_deploy_project_action.sh
./create_deploy_project_action.sh
```

This will create the Deploy Project action in the .github/actions/deploy directory.

## Defining Workflows
Now that we have our custom actions in place, we need to define the workflows that will use these actions. We will create separate workflows for development, testing, staging, and production environments.

### Development Workflow
The development workflow will run on every push to the development branch. It will use the Manage Secrets action to validate secrets, the Setup Environment action to prepare the environment, and the Build Project action to build the project.

Here are the steps to create the Development Workflow:

Create development.yml Workflow:

```bash
#!/bin/bash

# Create development.yml workflow
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
          vps_ssh_key: \${{ secrets.VPS_SSH_KEY }}
          vps_username: \${{ secrets.VPS_USERNAME }}
          vps_ip: \${{ secrets.VPS_IP }}
          deploy_dir: \${{ secrets.DEPLOY_DIR }}
          repo_owner: \${{ secrets.REPO_OWNER }}
          app_name: \${{ secrets.APP_NAME }}
          domain: \${{ secrets.DOMAIN }}
          staging_domain: \${{ secrets.STAGING_DOMAIN }}
          db_name: \${{ secrets.DB_NAME }}
          db_user: \${{ secrets.DB_USER }}
          db_password: \${{ secrets.DB_PASSWORD }}
          email: \${{ secrets.EMAIL }}
          main_dir: \${{ secrets.MAIN_DIR }}
          nydus_port: \${{ secrets.NYDUS_PORT }}
          redisai_port: \${{ secrets.REDISAI_PORT }}
          redis_port: \${{ secrets.REDIS_PORT }}
          repo_name: \${{ secrets.REPO_NAME }}
          runner_token: \${{ secrets.RUNNER_TOKEN }}

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

echo "development.yml workflow created successfully!"
```

Save this script as `create_development_workflow.sh` by using the following commands:

```bash
touch create_development_workflow.sh
```

Open the file with your preferred text editor and paste the above script content into it. Then make the script executable and run it:

```bash
chmod +x create_development_workflow.sh
./create_development_workflow.sh
```

This will create the development.yml workflow file in the .github/workflows directory.

### Testing Workflow
The testing workflow will run on every push to the testing branch. It will use the Manage Secrets action to validate secrets, the Setup Environment action to prepare the environment, the Build Project action to build the project, and the Test Project action to test the project.

Here are the steps to create the Testing Workflow:

Create testing.yml Workflow:

```bash
#!/bin/bash

# Create testing.yml workflow
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
          vps_ssh_key: \${{ secrets.VPS_SSH_KEY }}
          vps_username: \${{ secrets.VPS_USERNAME }}
          vps_ip: \${{ secrets.VPS_IP }}
          deploy_dir: \${{ secrets.DEPLOY_DIR }}
          repo_owner: \${{ secrets.REPO_OWNER }}
          app_name: \${{ secrets.APP_NAME }}
          domain: \${{ secrets.DOMAIN }}
          staging_domain: \${{ secrets.STAGING_DOMAIN }}
          db_name: \${{ secrets.DB_NAME }}
          db_user: \${{ secrets.DB_USER }}
          db_password: \${{ secrets.DB_PASSWORD }}
          email: \${{ secrets.EMAIL }}
          main_dir: \${{ secrets.MAIN_DIR }}
          nydus_port: \${{ secrets.NYDUS_PORT }}
          redisai_port: \${{ secrets.REDISAI_PORT }}
          redis_port: \${{ secrets.REDIS_PORT }}
          repo_name: \${{ secrets.REPO_NAME }}
          runner_token: \${{ secrets.RUNNER_TOKEN }}

  setup:
    needs: verify-secrets
    runs-on:

 ubuntu-latest
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

echo "testing.yml workflow created successfully!"
```

Save this script as `create_testing_workflow.sh` by using the following commands:

```bash
touch create_testing_workflow.sh
```

Open the file with your preferred text editor and paste the above script content into it. Then make the script executable and run it:

```bash
chmod +x create_testing_workflow.sh
./create_testing_workflow.sh
```

This will create the testing.yml workflow file in the .github/workflows directory.

### Staging Workflow
The staging workflow will run on every push to the staging branch. It will use the Manage Secrets action to validate secrets, the Setup Environment action to prepare the environment, the Build Project action to build the project, the Test Project action to test the project, and the Deploy Project action to deploy the project to the staging environment.

Here are the steps to create the Staging Workflow:

Create staging.yml Workflow:

```bash
#!/bin/bash

# Create staging.yml workflow
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
          vps_ssh_key: \${{ secrets.VPS_SSH_KEY }}
          vps_username: \${{ secrets.VPS_USERNAME }}
          vps_ip: \${{ secrets.VPS_IP }}
          deploy_dir: \${{ secrets.DEPLOY_DIR }}
          repo_owner: \${{ secrets.REPO_OWNER }}
          app_name: \${{ secrets.APP_NAME }}
          domain: \${{ secrets.DOMAIN }}
          staging_domain: \${{ secrets.STAGING_DOMAIN }}
          db_name: \${{ secrets.DB_NAME }}
          db_user: \${{ secrets.DB_USER }}
          db_password: \${{ secrets.DB_PASSWORD }}
          email: \${{ secrets.EMAIL }}
          main_dir: \${{ secrets.MAIN_DIR }}
          nydus_port: \${{ secrets.NYDUS_PORT }}
          redisai_port: \${{ secrets.REDISAI_PORT }}
          redis_port: \${{ secrets.REDIS_PORT }}
          repo_name: \${{ secrets.REPO_NAME }}
          runner_token: \${{ secrets.RUNNER_TOKEN }}

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
        with:
          environment: staging
EOL

echo "staging.yml workflow created successfully!"
```

Save this script as `create_staging_workflow.sh` by using the following commands:

```bash
touch create_staging_workflow.sh
```

Open the file with your preferred text editor and paste the above script content into it. Then make the script executable and run it:

```bash
chmod +x create_staging_workflow.sh
./create_staging_workflow.sh
```

This will create the staging.yml workflow file in the .github/workflows directory.

### Production Workflow
The production workflow will run on every push to the main branch. It will use the Manage Secrets action to validate secrets, the Setup Environment action to prepare the environment, the Build Project action to build the project, the Test Project action to test the project, and the Deploy Project action to deploy the project to the production environment.

Here are the steps to create the Production Workflow:

Create production.yml Workflow:

```bash
#!/bin/bash

# Create production.yml workflow
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
          vps_ssh_key: \${{ secrets.VPS_SSH_KEY }}
          vps_username: \${{ secrets.VPS_USERNAME }}
          vps_ip: \${{ secrets.VPS_IP }}
          deploy_dir: \${{ secrets.DEPLOY_DIR }}
          repo_owner: \${{ secrets.REPO_OWNER }}
          app_name: \${{ secrets.APP_NAME }}
          domain: \${{ secrets.DOMAIN }}
          staging_domain: \${{ secrets.STAGING_DOMAIN }}
          db_name: \${{ secrets.DB_NAME }}
          db_user: \${{ secrets.DB_USER }}
          db_password: \${{ secrets.DB_PASSWORD }}
          email: \${{ secrets.EMAIL }}
          main_dir: \${{ secrets.MAIN_DIR }}
          nydus_port: \${{ secrets.NYDUS_PORT }}
          redisai_port: \${{ secrets.REDISAI_PORT }}
          redis_port: \${{ secrets.REDIS_PORT }}
          repo_name: \${{ secrets.REPO_NAME }}
          runner_token: \${{ secrets.RUNNER_TOKEN }}

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
        with:
          environment: production
EOL

echo "production.yml workflow created successfully!"
```

Save this script as `create_production_workflow.sh` by using the following commands:

```bash
touch create_production_workflow.sh
```

Open the file with your preferred text editor and paste the above script content into it. Then make the script executable and run it:

```bash
chmod +x create_production_workflow.sh
./create_production_workflow.sh
```

This will create the production.yml workflow file in the .github/workflows directory.

## Conclusion
By following this guide, you have set up a comprehensive CI/CD pipeline using GitHub Actions with robust secrets management. The custom actions created are modular, maintainable, and reusable across different workflows. You can further extend this setup to include additional workflows and actions as per your project’s requirements.

Final Project Tree:

```
.
├── .github
│   ├── workflows
│   │   ├── development.yml
│   │   ├── testing.yml
│   │   ├── staging.yml
│   │   ├── production.yml
│   └── actions
│       ├── manage-secrets
│       │   ├── action.yml
│       │   └── index.js
│       ├── setup
│       │   ├── action.yml
│       │   └── index.js
│       ├── build
│       │   ├── action.yml
│       │   └── index.js
│       ├── test
│       │   ├── action.yml
│       │   └── index.js
│       └── deploy
│           ├── action.yml
│           └── index.js
└── README.md
```

This setup will ensure your workflows are modular, maintainable, and compatible with the latest GitHub Actions environment.

Feel free to expand this guide further to include any additional workflows and actions following the same pattern provided above. Each workflow will use the custom actions we created and ensure a consistent CI/CD pipeline across different environments.

## Addendum: Idempotent Shell Script to Automate Setup

### Overview
To streamline the process of setting up the entire project structure and creating custom actions, this addendum provides an idempotent shell script. This script will call all the individual creation shell scripts in one go, ensuring each script runs only once.

### Idempotent Setup Script
Save the following script as `setup_all.sh` and run it to automate the setup process:

```bash
#!/bin/bash

# Function to run a script if

 it hasn't been run before
run_once() {
  script_name=$1
  log_file=".setup_log"

  # Check if the script has been run before
  if grep -q "$script_name" "$log_file"; then
    echo "$script_name has already been run. Skipping..."
  else
    echo "Running $script_name..."
    bash "$script_name"
    echo "$script_name" >> "$log_file"
  fi
}

# Create .setup_log if it doesn't exist
touch .setup_log

# Run all setup scripts
run_once "setup_project_structure.sh"
run_once "create_manage_secrets_action.sh"
run_once "create_setup_environment_action.sh"
run_once "create_build_project_action.sh"
run_once "create_test_project_action.sh"
run_once "create_deploy_project_action.sh"
run_once "create_development_workflow.sh"
run_once "create_testing_workflow.sh"
run_once "create_staging_workflow.sh"
run_once "create_production_workflow.sh"

echo "All setup scripts have been executed."
```

### Usage
Ensure all individual creation scripts are present in the same directory as `setup_all.sh`.

Make the script executable:

```bash
chmod +x setup_all.sh
```

Run the setup script:

```bash
./setup_all.sh
```

This script will execute all the individual creation scripts in sequence, ensuring that each script is run only once. If you need to rerun any of the scripts, you can remove the corresponding entry from `.setup_log` and run `setup_all.sh` again. By using this idempotent setup script, you can automate the entire process of setting up the project structure and creating custom actions and workflows in one go, making the setup process efficient and error-free.

## Development Perspective
In the provided setup, each action and workflow is created with placeholder comments indicating where the actual logic should be implemented. Here is a summary of what needs to be developed and where:

### Manage Secrets Action
- **File**: .github/actions/manage-secrets/index.js
- **Logic to Implement**: Validation logic for each secret. Ensure that each required secret is present and not empty. If any secret is missing, the action should fail and provide a meaningful error message.

### Setup Environment Action
- **File**: .github/actions/setup/index.js
- **Logic to Implement**: Commands to prepare the VPS environment using the provided SSH key. This could include setting up directories, installing necessary software, and configuring the environment for subsequent build and deployment steps.

### Build Project Action
- **File**: .github/actions/build/index.js
- **Logic to Implement**: Build commands specific to your project. This could include compiling code, running build scripts, and preparing the project artifacts for deployment.

### Test Project Action
- **File**: .github/actions/test/index.js
- **Logic to Implement**: Commands to run the project's tests. This could include running unit tests, integration tests, and any other test suites to validate the project before deployment.

### Deploy Project Action
- **File**: .github/actions/deploy/index.js
- **Logic to Implement**: Deployment commands to deploy the project to the specified environment (staging or production). This could include copying files, running deployment scripts, and any other necessary steps to make the project live.

### Workflows
- **Files**: .github/workflows/development.yml, .github/workflows/testing.yml, .github/workflows/staging.yml, .github/workflows/production.yml
- **Logic to Implement**: Ensure that each workflow correctly calls the custom actions in the appropriate order. Each workflow should reflect the correct sequence of steps for its respective environment (development, testing, staging, production).

By implementing the necessary logic in these placeholders, you can create a comprehensive and fully functional CI/CD pipeline using GitHub Actions. This setup will help you manage secrets securely and automate the build, test, and deployment processes efficiently.