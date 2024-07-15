# Road to FountainAI

## Introduction

Welcome to "FountainAI's Vapor," the road story of setting up and deploying FountainAI, an AI-driven model designed to analyze and process theatrical and screenplay scripts. Leveraging the power of Vapor, Docker, and modern CI/CD practices, this guide will take you through every step, from initial setup to deploying a Dockerized Vapor application managed by a CI/CD pipeline.

### FountainAI Network Graph

The FountainAI Network Graph provides a visual overview of the conceptual model of FountainAI, highlighting the core components and their interactions. This graph helps visualize the structural and thematic composition of storytelling, providing a foundational understanding of how FountainAI will process and analyze scripts.

---

![The Fountain Network Graph](https://coach.benedikt-eickhoff.de/koken/storage/cache/images/000/723/Bild-2,xlarge.1713545956.jpeg)

---

### OpenAPI Specification

The OpenAPI specification serves as the detailed blueprint for FountainAI, transitioning from the high-level conceptual model to a precise API definition. It outlines all the endpoints, request/response formats, and data models, ensuring that developers have a clear and consistent reference for implementing the AI. The OpenAPI specification for this project can be found [here](https://github.com/Contexter/fountainAI/blob/main/openAPI/FountainAI-Admin-openAPI.yaml).

---

By following this guide, you will:

1. **Set up the development environment**: Create a GitHub repository, configure environment variables, generate necessary tokens, and establish secure communication between your local machine and a Virtual Private Server (VPS).
2. **Implement a CI/CD pipeline**: Use GitHub Actions to automate the process of building, testing, and deploying the application, ensuring continuous integration and continuous deployment.
3. **Create and manage the Vapor application**: Develop the Vapor application based on the FountainAI OpenAPI specification, Dockerize the application, and integrate it into the CI/CD pipeline for seamless deployment.

By the end of this guide, you will have a fully functional, automated deployment process for FountainAI, leveraging the power of Docker, Vapor, and GitHub Actions.

---

## Table of Contents
1. [Episode 1: Initial Setup and Manual GitHub Secrets Creation](#episode-1-initial-setup-and-manual-github-secrets-creation)
2. [Episode 2: Creating and Managing the CI/CD Pipeline with GitHub Actions](#episode-2-creating-and-managing-the-cicd-pipeline-with-github-actions)
3. [Episode 3: Creating and Managing the Vapor App for FountainAI with CI/CD Pipeline](#episode-3-creating-and-managing-the-vapor-app-for-fountainai-with-cicd-pipeline)

---

## Episode 1: Initial Setup and Manual GitHub Secrets Creation

### Table of Contents
1. [Introduction](#introduction-1)
2. [Prerequisites](#prerequisites)
3. [Step-by-Step Setup Guide](#step-by-step-setup-guide)
    1. [Create GitHub Repository and Configuration File](#create-github-repository-and-configuration-file)
    2. [Generate a GitHub Personal Access Token](#generate-a-github-personal-access-token)
    3. [Create SSH Keys for VPS Access](#create-ssh-keys-for-vps-access)
    4. [Add SSH Keys to Your VPS and GitHub](#add-ssh-keys-to-your-vps-and-github)
    5. [Generate a Runner Registration Token](#generate-a-runner-registration-token)
    6. [Manually Add Secrets to GitHub](#manually-add-secrets-to-github)
4. [Conclusion](#conclusion-1)

### Introduction

In this episode, we will set up the foundational components required for developing and deploying FountainAI. This includes creating a GitHub repository, configuring environment variables, and establishing secure communication with a VPS.

### Prerequisites

Ensure you have:
- A GitHub Account
- VPS (Virtual Private Server)
- Docker installed locally

### Step-by-Step Setup Guide

#### Create GitHub Repository and Configuration File
1. **Create a new GitHub Repository**:
   - Go to your GitHub account and create a new repository named `fountainAI`.
   - Initialize the repository with a `README.md` file.

2. **Clone the Repository Locally**:
   - Clone the repository to your local machine:
     ```sh
     git clone https://github.com/Contexter/fountainAI.git
     cd fountainAI
     ```

3. **Create Configuration File**:
   - Create a file named `config.env` in your project directory. This file will store all the necessary configuration variables.
   - Add the following content to `config.env`:

```env
# Name of your application
APP_NAME=fountainAI

# GitHub repository owner (your GitHub username or organization name)
REPO_OWNER=Contexter

# Name of your GitHub repository
REPO_NAME=fountainAI

# GitHub personal access token (generated in Step 2)
G_TOKEN=your_generated_token

# Private SSH key for accessing the VPS (will be generated in Step 3)
VPS_SSH_KEY='-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----'  # Placeholder, will update in Step 4

# Username for accessing your VPS
VPS_USERNAME=your_vps_username

# IP address of your VPS
VPS_IP=your_vps_ip

# Domain name for your production environment
DOMAIN=example.com

# Domain name for your staging environment
STAGING_DOMAIN=staging.example.com

# Directory on VPS where the app will be deployed
DEPLOY_DIR=/home/your_vps_username/deployment_directory

# Email address for Let's Encrypt SSL certificate registration
EMAIL=mail@benedikt-eickhoff.de

# Name of your PostgreSQL database
DB_NAME=fountainai_db

# Username for your PostgreSQL database
DB_USER=fountainai_user

# Password for your PostgreSQL database
DB_PASSWORD=your_db_password

# Port for your Redis service
REDIS_PORT=6379

# Port for your RedisAI service
REDISAI_PORT=6378

# Runner registration token (generated in Step 5)
RUNNER_TOKEN=your_runner_registration_token  # Placeholder, will update in Step 5

# Port for the NYDUS service
NYDUS_PORT=2224
```

4. **Add `config.env` to `.gitignore`**:
   - Add the `config.env` file to `.gitignore` to ensure it is not tracked by git, preventing sensitive information from being exposed.
     ```sh
     echo "config.env" >> .gitignore
     ```

5. **Commit and Push the Changes**:
   - Commit the changes and push them to GitHub:
     ```sh
     git add .
     git commit -m "Initial setup with config.env and .gitignore"
     git push origin main
     ```

#### Generate a GitHub Personal Access Token

1. **Navigate to GitHub Settings**:
   - Go to [GitHub](https://github.com/) and log in to your account.
   - Click on your profile picture in the top right corner and select `Settings`.

2. **Access Developer Settings**:
   - In the left sidebar, click on `Developer settings`.

3. **Generate a Personal Access Token**:
   - Click on `Personal access tokens`.
   - Click on `Tokens (classic)`.
   - Click on `Generate new token`.

4. **Configure the Token**:
   - Give your token a descriptive name, such as `FountainAI Project Token`.
   - Set the expiration date as needed (e.g., 90 days).
   - Select the scopes/permissions for the token. For a super powerful access token, select the following scopes:

     #### Repository Permissions
     - `repo` (Full control of private repositories)
     - `workflow` (Update GitHub Action workflows)
     - `write:packages` (Upload packages to GitHub Package Registry)
     - `read:packages` (Download packages from GitHub Package Registry)
     - `admin:repo_hook` (Full control of repository hooks)
     - `admin:org` (Read and write org and team membership, read and write org projects)

     #### Account Permissions
     - `read:user` (Read all user profile data)
     - `user:email` (Read user email addresses)
     - `write:discussion` (Manage discussions)
     - `admin:org_hook` (Full control of organization webhooks)

     #### GPG Key Permissions
     - `admin:gpg_key` (Full control of user GPG keys)

     #### SSH Key Permissions
     - `admin:ssh_key` (Full control of user public SSH keys)

     #### Personal Access Token Permissions
     - `admin:public_key` (Full control of user public keys)
     - `admin:org` (Full control of orgs and teams)

     #### Other Permissions
     - `delete_repo` (Delete repositories)
     - `admin:enterprise` (Manage enterprise accounts)
     - `admin:org_project` (Manage org projects)
     - `admin:repo` (Manage repositories)
     - `admin:repo_hook` (Manage repository webhooks)

5. **Generate and Copy the Token**:
   - Click on `Generate token`.
   - Copy the generated token and store it **immediately & securely** in your `config.env` file.

```env
G_TOKEN=your_generated_token
```

#### Create SSH Keys for VPS Access

1. **Open your terminal**.
2. **Generate an SSH Key Pair**:
   - Run the following command, replacing `your

_email@example.com` with your email:
     ```sh
     ssh-keygen -t ed25519 -C "your_email@example.com"
     ```
   - Follow the prompts to save the key pair in the default location (`~/.ssh/id_ed25519` and `~/.ssh/id_ed25519.pub`).
     - When asked to "Enter a file in which to save the key," press Enter to accept the default location.
     - You can choose to set a passphrase or leave it empty by pressing Enter.

3. **Add the generated keys to the `config.env` file**:
   - Add the following lines to your `config.env` file:

```env
VPS_SSH_KEY=$(cat ~/.ssh/id_ed25519)
```

#### Add SSH Keys to Your VPS and GitHub

##### Part A: Add the Public Key to Your VPS

1. **Copy the Public Key**:
   - Run the following command to display the public key:
     ```sh
     cat ~/.ssh/id_ed25519.pub
     ```
   - Copy the output (your public key) to your clipboard.

2. **Connect to Your VPS**:
   - Use an SSH client to connect to your VPS. Replace `your_vps_username` and `your_vps_ip` with your actual VPS username and IP address:
     ```sh
     ssh your_vps_username@your_vps_ip
     ```

3. **Add the Public Key to the VPS**:
   - On your VPS, create the `.ssh` directory if it doesn't exist:
     ```sh
     mkdir -p ~/.ssh
     ```
   - Add the copied public key to the `authorized_keys` file:
     ```sh
     echo "<public_key>" >> ~/.ssh/authorized_keys
     ```
   - Replace `<public_key>` with the public key you copied earlier.

##### Part B: Add the Private Key to GitHub Secrets

1. **Copy the Private Key**:
   - On your local machine, run the following command to display the private key:
     ```sh
     cat ~/.ssh/id_ed25519
     ```
   - Copy the output (your private key) to your clipboard.

2. **Add the Private Key to GitHub Secrets**:
   - Go to your GitHub repository in your web browser.
   - Navigate to **Settings** -> **Secrets and variables** -> **Actions**.
   - Click on **New repository secret**.
   - Add a new secret with the following details:
     - **Name**: `VPS_SSH_KEY`
     - **Value**: Paste the private key you copied earlier.
   - Click **Add secret** to save.

#### Generate a Runner Registration Token

1. **Generate the Runner Token**:
   - Go to your GitHub repository.
   - Navigate to **Settings** -> **Actions** -> **Runners**.
   - Click on **New self-hosted runner**.
   - Select the appropriate operating system for your VPS.
   - Follow the instructions to download and configure the runner. Note the `RUNNER_TOKEN` generated in the process. You will use this token to register the runner.
   - **Immediately add this token to the `config.env` file** under the `RUNNER_TOKEN` variable to keep track of it.

```env
RUNNER_TOKEN=your_generated_runner_token
```

2. **Set Up the Runner as a Systemd Service**:
   - Follow the instructions provided by GitHub to configure and run the self-hosted runner.
   - Then, create a systemd service file on your VPS to ensure the runner runs as a service:
     ```sh
     sudo nano /etc/systemd/system/github-runner.service
     ```
   - Add the following content to the service file:
     ```ini
     [Unit]
     Description=GitHub Actions Runner
     After=network.target

     [Service]
     ExecStart=/home/your_vps_username/actions-runner/run.sh
     User=your_vps_username
     WorkingDirectory=/home/your_vps_username/actions-runner
     Restart=always

     [Install]
     WantedBy=multi-user.target
     ```
   - Replace `your_vps_username` with your actual VPS username.

3. **Reload the systemd daemon to recognize the new service**:
   ```sh
   sudo systemctl daemon-reload
   ```

4. **Enable the service to start on boot**:
   ```sh
   sudo systemctl enable github-runner
   ```

5. **Start the service**:
   ```sh
   sudo systemctl start github-runner
   ```

6. **Check the status of the service**:
   ```sh
   sudo systemctl status github-runner
   ```

#### Manually Add Secrets to GitHub

For security reasons, sensitive information such as tokens, keys, and passwords should not be stored directly in the source code. Instead, GitHub Actions allows you to store these secrets securely. You need to replicate the contents of your `config.env` file as secrets in your GitHub repository.

1. **Navigate to Your Repository Settings**:
   - Go to your GitHub repository in your web browser.
   - Click on **Settings**.

2. **Access Secrets and Variables**:
   - In the left sidebar, click on **Secrets and variables**.
   - Click on **Actions**.

3. **Add a New Repository Secret**:
   - Click on **New repository secret**.
   - For each variable in your `config.env` file, add a new secret with the same name and value. For example:
     - **Name**: `APP_NAME`
     - **Value**: `fountainAI`
   - Repeat this for all variables in the `config.env` file.

This ensures that your GitHub Actions workflows can access these sensitive values securely.

### Conclusion

Summarize the steps covered and provide a brief outlook on the next episode.

---

## Episode 2: Creating and Managing the CI/CD Pipeline with GitHub Actions

### Table of Contents
1. [Introduction](#introduction-2)
2. [Project Structure Setup](#project-structure-setup)
3. [Understanding and Managing GitHub Branches](#understanding-and-managing-github-branches)
4. [Creating GitHub Branches](#creating-github-branches)
5. [Creating Custom Actions](#creating-custom-actions)
    1. [Manage Secrets Action](#manage-secrets-action)
    2. [Setup Environment Action](#setup-environment-action)
    3. [Build Project Action](#build-project-action)
    4. [Test Project Action](#test-project-action)
    5. [Deploy Project Action](#deploy-project-action)
6. [Defining Workflows](#defining-workflows)
    1. [Development Workflow](#development-workflow)
    2. [Testing Workflow](#testing-workflow)
    3. [Staging Workflow](#staging-workflow)
    4. [Production Workflow](#production-workflow)
7. [Conclusion](#conclusion-2)
8. [Idempotent Shell Script to Automate Setup](#idempotent-shell-script-to-automate-setup)

### Introduction

In this episode, we will create and manage a CI/CD pipeline using GitHub Actions. This pipeline will automate the process of building, testing, and deploying the FountainAI application, ensuring continuous integration and continuous deployment.

### Project Structure Setup

**Setting Up the Environment**

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

After running the script, your project directory should look like this:

```
fountainAI/
├── .github
│   ├── actions
│   │   ├── build
│   │   ├── deploy
│   │   ├── manage-secrets
│   │   ├── setup
│   │   └── test
│   ├── workflows
│   └── README.md
├── .gitignore
├── config.env
└── README.md
```

### Understanding and Managing GitHub Branches

Branches in GitHub are an essential feature for managing and developing different aspects of your project concurrently. They allow you to work on new features, fixes, or experiments in isolation from your main codebase. Once the work on a branch is complete, it can be merged back into the main branch.

#### Why Use Branches?

Using branches helps you:
1. **Organize Work**: Separate different tasks or features into their respective branches.
2. **Enable Collaboration**: Multiple team members can work on different branches without interfering with each other’s work.
3. **

Ensure Stability**: Keep the main branch stable and deployable by merging changes only after they have been tested and reviewed.

#### Project-Specific Branching Strategy

For the FountainAI project, the following branching strategy will be used:

1. **Main Branch (main)**: This is the production-ready code. It should always be in a deployable state.
2. **Development Branch (development)**: This branch is used for integration and testing of new features and bug fixes before they are merged into the main branch.
3. **Testing Branch (testing)**: This branch is used for running automated tests and ensuring that the new code is stable and passes all tests.
4. **Staging Branch (staging)**: This branch is used for staging deployments, where the application can be tested in an environment similar to production.
5. **Feature Branches (feature/xyz)**: These branches are used to develop new features. They are created off the development branch and merged back into it once the feature is complete.
6. **Bugfix Branches (bugfix/xyz)**: These branches are used to fix bugs. They are also created off the development branch and merged back into it once the bug is fixed.

### Creating GitHub Branches

Before creating the workflow files, let's set up the necessary GitHub branches:

#### Create the Development Branch

1. **Create and switch to the development branch**:
   ```sh
   git checkout -b development
   ```

2. **Push the development branch to GitHub**:
   ```sh
   git push origin development
   ```

#### Create the Testing Branch

1. **Create and switch to the testing branch**:
   ```sh
   git checkout -b testing
   ```

2. **Push the testing branch to GitHub**:
   ```sh
   git push origin testing
   ```

#### Create the Staging Branch

1. **Create and switch to the staging branch**:
   ```sh
   git checkout -b staging
   ```

2. **Push the staging branch to GitHub**:
   ```sh
   git push origin staging
   ```

#### Switch Back to Main Branch

1. **Switch back to the main branch**:
   ```sh
   git checkout main
   ```

Now, we have set up the necessary branches for our workflows. Next, we will create custom actions.

### Creating Custom Actions

Now that we have our project structure in place, we will create custom actions. Custom actions help in modularizing the workflows and reusing code. We’ll start by creating an action to manage secrets.

#### Manage Secrets Action

The “Manage Secrets” action is responsible for validating that all required secrets are set. It will read the secrets from the workflow and ensure they are not empty.

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

This will create the Manage Secrets action in the `.github/actions/manage-secrets` directory.

#### Setup Environment Action

The “Setup Environment” action is responsible for preparing the VPS environment using the provided SSH key. It will use the vps_ssh_key to authenticate and perform setup tasks.

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

This will create the Setup Environment action in the `.github/actions/setup` directory.

#### Build Project Action

The “Build Project” action is responsible for building the project. It will contain the necessary commands to compile and prepare the project for deployment.

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

This will create the Build Project action

 in the `.github/actions/build` directory.

#### Test Project Action

The “Test Project” action is responsible for testing the project. It will contain the necessary commands to run tests and validate the project.

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

This will create the Test Project action in the `.github/actions/test` directory.

#### Deploy Project Action

The “Deploy Project” action is responsible for deploying the project. It will contain the necessary commands to deploy the project to the specified environment.

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

This will create the Deploy Project action in the `.github/actions/deploy` directory.

### Defining Workflows

Now that we have our custom actions in place, we need to define the workflows that will use these actions. We will create separate workflows for development, testing, staging, and production environments.

#### Development Workflow

The development workflow will run on every push to the development branch. It will use the Manage Secrets action to validate secrets, the Setup Environment action to prepare the environment, and the Build Project action to build the project.

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

This will create the development.yml workflow file in the `.github/workflows` directory.

#### Testing Workflow

The testing workflow will run on every push to the testing branch. It will use the Manage Secrets action to validate secrets, the Setup Environment action to prepare the environment, the Build Project action to build the project, and the Test Project action to test the project.

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

This will create the testing.yml workflow file in the `.github/workflows` directory.

#### Staging Workflow

The staging workflow will run on every push to the staging branch. It will use the Manage Secrets action to validate secrets, the Setup Environment action to prepare the environment, the Build Project action to build the project, the Test Project action to test the project, and the Deploy Project action to deploy the project to the staging environment.

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
          vps_ip: \${{ secrets

.VPS_IP }}
          deploy_dir: \${{ secrets.DEPLOY_DIR }}
          repo_owner: \${

{ secrets.REPO_OWNER }}
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

This will create the staging.yml workflow file in the `.github/workflows` directory.

#### Production Workflow

The production workflow will run on every push to the main branch. It will use the Manage Secrets action to validate secrets, the Setup Environment action to prepare the environment, the Build Project action to build the project, the Test Project action to test the project, and the Deploy Project action to deploy the project to the production environment.

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

This will create the production.yml workflow file in the `.github/workflows` directory.

### Conclusion

By following this guide, you have set up a comprehensive CI/CD pipeline using GitHub Actions with robust secrets management. The custom actions created are modular, maintainable, and reusable across different workflows. You can further extend this setup to include additional workflows and actions as per your project’s requirements.

### Idempotent Shell Script to Automate Setup

To streamline the process of setting up the entire project structure and creating custom actions, this section provides an idempotent shell script. This script will call all the individual creation shell scripts in one go, ensuring each script runs only once.

#### Overview

This script will automate the creation of the project structure, custom actions, and workflows.

#### Idempotent Setup Script

Save the following script as `setup_all.sh` and run it to automate the setup process:

```bash
#!/bin/bash

# Function to run a script if it hasn't been run before
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

#### Usage

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

---

## Episode 3: Creating and Managing the Vapor App for FountainAI with CI/CD Pipeline

### Table of Contents
1. [Introduction](#introduction-3)
2. [Setting Up the Vapor Application](#setting-up-the-vapor-application)
    1. [Create Vapor Application](#create-vapor-application)
    2. [Dockerizing the Vapor Application](#dockerizing-the-vapor-application)
3. [Integrating with CI/CD Pipeline](#integrating-with-cicd-pipeline)
    1. [Building and Pushing Docker Image](#building-and-pushing-docker-image)
    2. [Deployment and Monitoring](#deployment-and-monitoring)
    3. [Updating CI/CD Workflows](#updating-cicd-workflows)
4. [Conclusion](#conclusion-3)

### Introduction

In this episode, we will focus on creating a bare-bones Vapor application for FountainAI, Dockerizing it, and integrating it into the CI/CD pipeline established in Episode 2. This will help us ensure that the pipeline is functioning correctly by deploying a simple "Hello, World!" application.

### Setting Up the Vapor Application

#### Create Vapor Application

1. **Install Vapor Toolbox**:
   Ensure you have the Vapor toolbox installed on your local machine.
   ```sh
   brew install vapor
   ```

2. **Create a New Vapor Project**:
   Navigate to your project directory and create a new Vapor project.
   ```sh
   vapor new FountainAI --template=api
   cd FountainAI
   ```

3. **Initialize Git Repository**:
   Initialize a git repository in the new Vapor project directory.
   ```sh
   git init
   ```

4. **Add Project Files to Git**:
   Add the newly created Vapor project files to git.
   ```sh
   git add .
   git commit -m "Initial commit - Created Vapor project"
   ```

5. **Push to GitHub**:
   Push the initial commit to the development branch on GitHub.
   ```sh
   git remote add origin https://github.com/Contexter/fountainAI.git
   git push -u origin development
   ```

#### Dockerizing the Vapor Application

1. **Verify Dockerfile**:
   The `vapor new` command generates a Dockerfile by default. Verify its content and make necessary adjustments.

2. **Build Docker Image Locally**:
   Build the Docker image to ensure the Dockerfile is correctly set up.
   ```sh
   docker build -t fountainai:latest .
   ```

3. **Run Docker Container Locally**:
   Run the Docker container locally to verify that the application is working.
   ```sh
   docker run --rm -p 8080:8080 fountainai:latest
   ```

4. **Commit Dockerfile**:
   Commit the Dockerfile to your GitHub repository.
   ```sh
   git add Dockerfile
   git commit -m "Added Dockerfile for Vapor application"
   git push origin development
   ```

### Integrating with CI/CD Pipeline

#### Building and Pushing Docker Image

1. **Update Build Action**:
   Update the `Build Project Action` to include commands for building and pushing the Docker image to GitHub Container Registry.

   ```js
   const core = require('@actions/core');
   const exec = require('@actions/exec');

   async function run() {
       try {
           await exec.exec('docker build -t ghcr.io/Contexter/fountainai:latest .');
           await exec.exec('echo ${{ secrets.GITHUB_TOKEN }} | docker login ghcr.io -u Contexter --password-stdin');
           await exec.exec('docker push ghcr.io/Contexter/fountainai:latest');
           core.info('Docker image built and pushed successfully');
       } catch (error) {
           core.setFailed(`Action failed with error ${error}`);
       }
   }

   run();
   ```

2. **Commit Changes**:
   Commit the changes to the `Build Project Action`.
   ```sh
   git add .github/actions/build/index.js
   git commit -m "Updated Build Project Action to build and push Docker image"
   git push origin development
   ```

#### Deployment and Monitoring

1. **Update Deploy Action**:
   Update the `Deploy Project Action` to deploy the Dockerized Vapor application.

   ```js
   const core = require('@actions/core');
   const exec = require('@actions/exec');

   async function run() {
       try {
           const environment = core.getInput('environment');
           await exec.exec(`ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no ${process.env.VPS_USERNAME}@${process.env.VPS_IP} 'docker pull ghcr.io/Contexter/fountainai:latest && docker run -d -p 80:8080 --name fountainai ghcr.io/Contexter/fountainai:latest'`);
           core.info(`Deployed to ${environment} environment successfully`);
       } catch (error) {
           core.setFailed(`Action failed with error ${error}`);
       }
   }

   run();
   ```

2. **Commit Changes**:
   Commit the changes to the `Deploy Project Action`.
   ```sh
   git add .github/actions/deploy/index.js
   git commit -m "Updated Deploy Project Action to deploy Dockerized Vapor application"
   git push origin development
   ```

#### Updating CI/CD Workflows

1. **Update Development Workflow**:
   Update the development workflow to include steps for building and pushing the Docker image, and deploying it to the staging environment.

   ```yaml
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
             github_token: ${{ secrets.GITHUB_TOKEN }}
             vps_ssh_key: ${{ secrets.VPS_SSH_KEY }}
             vps_username: ${{ secrets.VPS_USERNAME }}
             vps_ip: ${{ secrets.VPS_IP }}
             deploy_dir: ${{ secrets.DEPLOY_DIR }}
             repo_owner: ${{ secrets.REPO_OWNER }}
             app_name: ${{ secrets.APP_NAME }}
             domain: ${{ secrets.DOMAIN }}
             staging_domain: ${{ secrets.STAGING_DOMAIN }}
             db_name: ${{ secrets.DB_NAME }}
             db_user: ${{ secrets.DB_USER }}
             db_password: ${{ secrets.DB_PASSWORD }}
             email: ${{ secrets.EMAIL }}
             main_dir: ${{ secrets.MAIN_DIR }}
             nydus_port: ${{ secrets.NYDUS_PORT }}
             redisai_port: ${{ secrets.REDISAI_PORT }}
             redis_port: ${{ secrets.REDIS_PORT }}
             repo_name: ${{ secrets.REPO_NAME }}
             runner_token: ${{ secrets.RUNNER_TOKEN }}

     setup:
       needs: verify-secrets
       runs-on: ubuntu-latest
       steps:
         - name: Setup Environment
           uses: ./.github/actions/setup
           with:
             vps_ssh_key: ${{ secrets.VPS_SSH_KEY }}

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
   ```

2. **Commit Workflow Changes**:
   Commit the workflow updates.
   ```sh
   git add .github/workflows/development.yml
   git commit -m "Updated development workflow to include Docker build, push, and deployment steps"
   git push origin development
   ```

#### Testing and Monitoring the Deployment

1. **Push a Change to the Development Branch**:
   Make a small change to the Vapor application, such as updating the welcome message, and push it to the development branch.
   ```sh
   echo 'print("Hello, Vapor!")' > Sources/App/Controllers/HelloController.swift
   git add .
   git commit -m "Updated welcome message"
   git push origin development
   ```

2. **Monitor the Workflow**:
   Go to the GitHub Actions tab in your repository to monitor the workflow triggered by the push to the development branch. Ensure that all steps, including building, pushing the Docker image, and deploying to the staging environment, are completed successfully.

3. **Verify Deployment**:
   Once the deployment is successful, open a web browser and navigate to your staging domain to verify that the Vapor application is running and displaying the updated welcome message.

### Conclusion

In this episode, we created a bare-bones Vapor application, Dockerized it, and integrated it into the CI/CD pipeline established in Episode 2. By following these steps, we ensured that our CI/CD pipeline is functioning correctly, capable of building, testing, and deploying a simple "Hello, World!" application. This foundation will allow us to build upon it and develop the full-featured FountainAI application in future episodes.