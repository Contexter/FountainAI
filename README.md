## FountainAI's Vapor

This comprehensive guide details a step-by-step approach to creating, handling, and deploying a Vapor application using modern DevOps practices. The process is divided into three main parts for clarity and focus: Initial Setup, Creating and Handling the Vapor App, and Deployment and Monitoring. The guide ensures a robust, efficient, and scalable environment leveraging Docker, Nginx, PostgreSQL, Redis, RedisAI, and GitHub Actions.

### Part 1: Initial Setup

The first part of the guide begins with creating a new GitHub repository named `fountainAI` and cloning it locally. A configuration file (`config.env`) is set up to store all necessary configuration variables, ensuring security by adding `config.env` to `.gitignore`. Next, you generate a fine-grained personal access token from GitHub with the necessary permissions and store it in the `config.env` file.

SSH keys for VPS access are created to establish secure communication between your local machine and the VPS, with the private key stored in the `config.env` file. The public key is added to your VPS, and the private key is stored as a GitHub secret. A runner registration token is generated to set up a self-hosted runner on GitHub Actions, and the runner is configured as a systemd service to ensure it runs consistently.

Sensitive information such as tokens, keys, and passwords are securely stored in GitHub Secrets. A linting environment is then set up using Docker and yamllint to ensure proper formatting of YAML and other configuration files. The linting process is automated via GitHub Actions using a linting Docker image.

### Part 2: Creating and Handling the Vapor App

In the second part, the guide details the creation of modular GitHub Actions workflow templates. Separate modular workflows for linting, setup, build, test, and deployment are created and integrated into main workflows for staging and production to ensure a streamlined CI/CD process.

A script is created to interactively set up a new Vapor application using the Vapor toolbox. This ensures the Vapor application structure is properly created and organized, preparing the project for further development and deployment.

### Part 3: Deployment and Monitoring

The third part of the guide covers building and pushing the Docker image of the Vapor application to the GitHub Container Registry. A script is created to build and push the Docker image, ensuring it is properly built and stored for deployment.

Firewall settings on the VPS are managed using an automated UFW management workflow. This workflow allows necessary ports for the application, database, and other services, including the NYDUS service port. This enhances security and ensures proper connectivity between the VPS instance and the host system's service dashboard.

### How to Deploy

Deployment to staging is triggered by pushing to the `main` branch, with the GitHub Actions workflow automatically building, pushing the Docker image, running tests, deploying the application to the staging environment, and configuring the UFW settings. Deployment to production involves creating or merging changes into the `production` branch to trigger the production deployment, with optional configuration for manual workflow dispatch from the GitHub Actions interface.

### Monitoring and Manual Trigger

Workflow runs and logs can be monitored in the GitHub Actions interface. Manual deployments can be triggered if configured, providing greater control over the deployment process.

### Development Perspective

The guide emphasizes implementing Test-Driven Development (TDD) alongside Continuous Integration/Continuous Deployment (CI/CD). This ensures that each feature of the OpenAPI specification is thoroughly tested and automatically deployed. Unit tests are designed to test individual units of code in isolation, while integration tests verify the interaction between different components or systems. The output of the compiler and other build steps can be accessed through the GitHub Actions interface for further analysis.

### Conclusion

Following this guide sets up a robust environment for developing and deploying the FountainAI project using Vapor. The combination of Docker, Nginx, PostgreSQL, Redis, RedisAI, and GitHub Actions ensures a seamless workflow from development to production. Implementing the OpenAPI specification in a TDD fashion leads to a reliable and maintainable codebase, while managing VPS UFW settings enhances security and reliability. This comprehensive approach ensures an efficient, scalable, and secure deployment process for your Vapor application.

## Table of Contents

- [Introduction](#introduction)
- [The FountainAI Project](#the-fountainai-project)
  - [The Fountain Network Graph](#the-fountain-network-graph)
  - [OpenAPI Specification](#openapi-specification)
  - [Implementation](#implementation)
- [Prerequisites](#prerequisites)
- [Step-by-Step Setup Guide](#step-by-step-setup-guide)
  - [Part 1: Initial Setup](#part-1-initial-setup)
    - [Step 1: Create GitHub Repository and Configuration File](#step-1-create-github-repository-and-configuration-file)
    - [Step 2: Generate a GitHub Personal Access Token](#step-2-generate-a-github-personal-access-token)
    - [Step 3: Create SSH Keys for VPS Access](#step-3-create-ssh-keys-for-vps-access)
    - [Step 4: Add SSH Keys to Your VPS and GitHub](#step-4-add-ssh-keys-to-your-vps-and-github)
    - [Step 5: Generate a Runner Registration Token](#step-5-generate-a-runner-registration-token)
    - [Step 6: Manually Add Secrets to GitHub](#step-6-manually-add-secrets-to-github)
    - [Step 7: Create Linting Environment](#step-7-create-linting-environment)
  - [Part 2: Creating and Handling the Vapor App](#part-2-creating-and-handling-the-vapor-app)
    - [Step 8: Create Modular GitHub Actions Workflow Templates](#step-8-create-modular-github-actions-workflow-templates)
    - [Step 9: Create Vapor Application Manually](#step-9-create-vapor-application-manually)
    - [Step 10: Build and Push Docker Image to GitHub Container Registry](#step-10-build-and-push-docker-image-to-github-container-registry)
  - [Part 3: Deployment and Monitoring](#part-3-deployment-and-monitoring)
- [How to Deploy](#how-to-deploy)
  - [Deploy to Staging](#deploy-to-staging)
  - [Deploy to Production](#deploy-to-production)
  - [Monitoring and Manual Trigger](#monitoring-and-manual-trigger)
- [Development Perspective](#development-perspective)
  - [TDD and CI/CD](#tdd-and-cicd)
  - [Unit Tests](#unit-tests)
  - [Integration Tests](#integration-tests)
  - [Accessing Compiler Output in GitHub Actions](#accessing-compiler-output-in-github-actions)
- [Conclusion](#conclusion)

## The FountainAI Project

In this guide, we will focus on implementing a specific project, FountainAI. FountainAI is a conceptual AI model designed to analyze and process scripts. The project involves creating a network graph, defining an OpenAPI specification, and implementing the application using Vapor.

The following sections provide detailed steps on how to conceptualize the FountainAI network graph, specify the OpenAPI, and implement the application using Vapor, a popular server-side Swift framework.

## The Fountain Network Graph

---

![The Fountain Network Graph](https://coach.benedikt-eickhoff.de/koken/storage/cache/images/000/723/Bild-2,xlarge.1713545956.jpeg)

---

The Fountain Network Graph illustrates the conceptual model of FountainAI, with the "Paraphrase" node at the center symbolizing the core idea or theme. Connected nodes like "Character," "Action," "Spoken Word," and "Transition" are placed at cardinal points to signify their fundamental influence on the narrative. Other elements such as "Script," "Section Heading," "Music Sound," and "Note" are distributed evenly, indicating their supplementary role. This layout helps visualize the structural and thematic composition of storytelling, providing a foundational understanding of how FountainAI will process and analyze scripts.

## OpenAPI Specification

The OpenAPI specification serves as the detailed blueprint for FountainAI, transitioning from the high-level conceptual model to a precise API definition. It outlines all the endpoints, request/response formats, and data models, ensuring that developers have a clear and consistent reference for implementing the AI. This standardization helps automate the generation of API documentation, client libraries, and server stubs, streamlining the development process and ensuring alignment with the conceptual model. The OpenAPI specification for this project can be found [here](https://github.com/Contexter/fountainAI/blob/main/openAPI/FountainAI-Admin-openAPI.yaml).

## Implementation

The implementation phase involves creating the actual codebase for FountainAI using Vapor. By adhering to the OpenAPI specification, we ensure that the implementation is consistent with the defined API standards. The focus is on writing scalable, maintainable, and efficient code, leveraging Vapor's features and best practices. This phase translates the conceptual and API models into a working application, ready for deployment and real-world use.

## Prerequisites

Before starting the setup, ensure you have the following:

1. **GitHub Account**: You need a GitHub account to host your repositories and manage secrets.
2. **GitHub Personal Access Token**: Required for accessing the GitHub API.
3. **VPS (Virtual Private Server)**: To deploy your applications.
4. **SSH Key Pair**: For secure communication between your local machine and the VPS.
5. **Docker**: Installed on your local machine for containerization.

   **Containerization** is a lightweight form of virtualization that allows you to run applications in isolated environments called containers. Containers include the application code along with all its dependencies, libraries, and configuration files, enabling the application to run consistently across different computing environments. In this setup, Docker is used to build the Vapor application locally, package it into a container, and push the container image to the GitHub Container Registry for deployment on the VPS.

6. **curl and jq**: Installed on your local machine for making API calls and processing JSON.
7. **YAML Linter**: Installed on your local machine to ensure error-free YAML configuration files.

Install yamllint via Homebrew:
```sh
brew install yamllint
```

## Step-by-Step Setup Guide

### Part 1: Initial Setup

#### Step 1: Create GitHub Repository and Configuration File

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
GITHUB_TOKEN=ghp_yourgithubtoken1234567890  # Placeholder, will update in Step 2

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

#### Step 2: Generate a GitHub Personal Access Token

1. **Generate the Token**:
   - Go to your GitHub account settings.
   - Navigate to **Developer settings** -> **Personal access tokens** -> **Fine-grained tokens**.
   - Click on **Generate new token**.
   - Fill in the token description (e.g., "FountainAI Project Token").
   - Set the expiration date as needed.
   - Under **Repository access**, select **All repositories** (or **Only select repositories** if you want to limit access to specific repositories).
   - In the **Permissions** section, select the following permissions:
     - **Repository permissions**:
       - Actions: Read and write
       - Administration: Read and write
       - Codespaces: Read and write
       - Contents: Read and write
       - Deployments: Read and write
       - Environments: Read and write
       - Issues: Read and write
       - Metadata: Read and write
       - Packages: Read and write
       - Pages: Read and write
       - Pull requests: Read and write
       - Secrets: Read and write
       - Variables: Read and write
       - Webhooks: Read and write
     - **Account permissions**:
       - Codespaces user secrets: Read and write
       - Gists: Read and write
       - Git SSH keys: Read and write
       - Email addresses: Read and write
       - Followers: Read
       - GPG keys: Read and write
       - Private repository invitations: Read and write
       - Profile: Read and write
       - SSH signing keys: Read and write
       - Starring: Read and write
       - Watching: Read and write
   - Click **Generate token** and copy the generated token. **Immediately add this token to the `config.env` file** under the `GITHUB_TOKEN` variable to keep track of it.

```env
GITHUB_TOKEN=your_generated_token
```

#### Step 3: Create SSH Keys for VPS Access

1. **Open your terminal**.
2. **Generate an SSH Key Pair**:
   - Run the following command, replacing `your_email@example.com` with your email:
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

#### Step 4: Add SSH Keys to Your VPS and GitHub

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

#### Step 5: Generate a Runner Registration Token

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

#### Step 6: Manually Add Secrets to GitHub

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

#### Step 7: Create Linting Environment

Create a linting environment to ensure your YAML files and other configuration files are properly formatted.

1. **Create a Dockerfile for Linting**:
   - In your project directory, create a folder named `linting`.
   - Inside the `linting` folder, create a file named `Dockerfile`.

**linting/Dockerfile**:
```Dockerfile
FROM python:3.9-slim

RUN pip install yamllint

WORKDIR /linting

ENTRYPOINT ["yamllint", "."]
```

2. **Create yamllint Configuration File**:
   - In the `linting` folder, create a `.yamllint` file to specify the linting rules.

**linting/.yamllint**:
```yaml
extends: default

rules:
  line-length:
    max: 120
    level: warning
  indentation:
    indent-sequences: false
  truthy:
    allowed-values: ['true', 'false']
    level: error
```

3. **Build and Push the Linting Docker Image**:
   - Create a script named `build_and_push_linting_image.sh` in the root directory of your project.

**build_and_push_linting_image.sh**:
```bash
#!/bin/bash

# Load configuration from config.env
source config.env

# Navigate to the linting directory
cd linting

# Build the Docker image
docker build -t ghcr.io/$REPO_OWNER/linting .

# Log in to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u $REPO_OWNER --password-stdin

# Push the Docker image to GitHub Container Registry
docker push ghcr.io/$REPO_OWNER/linting

# Navigate back to the root directory
cd ..
```

4. **Make the Script Executable**:
   ```sh
   chmod +x build_and_push_linting_image.sh
   ```

5. **Run the Script**:
   ```sh
   ./build_and_push_linting_image.sh
   ```

### Part 2: Creating and Handling the Vapor App

#### Step 8: Create Modular GitHub Actions Workflow Templates

1. **Create Linting Workflow**:
   - Create a linting workflow to validate your YAML files and configuration files.

**.github/workflows/linting.yml**:
```yaml
name: Linting

on:
  push:
    branches:
      - '**'
  pull_request:
    branches:
      - '**'

jobs:
  lint:
    runs-on: self-hosted

    steps:
      - name: Set up SSH
        uses: webfactory/ssh-agent@v0.5.3
        with:
          ssh-private-key: ${{ secrets.VPS_SSH_KEY }}

      - name: Clone Repository
        uses: actions/checkout@v2

      - name: Run Linters
        run: |
          ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
          docker pull ghcr.io/${{ secrets.REPO_OWNER }}/linting
          docker run --rm -v $(pwd):/linting ghcr.io/${{ secrets.REPO_OWNER }}/linting
EOF
```

2. **Create Setup Workflow**:
   - Create a setup workflow to prepare the VPS for deployment.

**.github/workflows/setup.yml**:
```yaml
name: Setup VPS

on: [workflow_call]

jobs:
  setup-vps:
    runs-on: self-hosted

    steps:
      - name: Set up SSH
        uses: webfactory/ssh-agent@v0.5.3
        with:
          ssh-private-key: ${{ secrets.VPS_SSH_KEY }}

      - name: Install Docker and Dependencies
        run: |
          ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
          sudo apt update
          sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
          curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
          sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
          sudo apt update
          sudo apt install -y docker-ce docker-ce-cli containerd.io
          sudo systemctl enable docker
          sudo systemctl start docker
          sudo apt install -y nginx certbot python3-certbot-nginx
EOF
```

3. **Create UFW Configuration Workflow**:
   - Create a UFW configuration workflow to automate the firewall settings on the VPS.

**.github/workflows/ufw-config.yml**:
```yaml
name: UFW Configuration

on: [workflow_call]

jobs:
  configure-ufw:
    runs-on: self-hosted

    steps:
      # Set up SSH agent to allow connecting to the VPS
      - name: Set up SSH
        uses: webfactory/ssh-agent@v0.5.3
        with:
          ssh-private-key: ${{ secrets.VPS_SSH_KEY }}

      # Configure UFW on the VPS
      - name: Configure UFW
        run: |
          ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
          sudo ufw allow 22/tcp   # Ensure SSH remains allowed
          sudo ufw allow 80/tcp   # Allow HTTP
          sudo ufw allow 443/tcp  # Allow HTTPS
          sudo ufw allow 5432/tcp # Allow PostgreSQL
          sudo ufw allow 6379/tcp # Allow Redis
          sudo ufw allow 6378/tcp # Allow RedisAI
          sudo ufw allow 8080/tcp # Allow Application (Production)
          sudo ufw allow 8081/tcp # Allow Application (Staging)
          sudo ufw allow 2224/tcp # Allow NYDUS Service
          sudo ufw default deny incoming  # Deny all other incoming connections
          sudo ufw enable
EOF
```

4. **Create Build Workflow**:
   - Create a build workflow to build the Docker image for the Vapor app.

**.github/workflows/build.yml**:
```yaml
name: Build Docker Image

on: [workflow_call]

jobs:
  build:
    runs-on: self-hosted

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name:

 Log in to GitHub Container Registry
        run: echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin

      - name: Build and Push Docker Image
        run: |
          IMAGE_NAME=ghcr.io/${{ secrets.REPO_OWNER }}/$(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')
          docker build -t $IMAGE_NAME .
          docker push $IMAGE_NAME
```

5. **Create Test Workflow**:
   - Create a test workflow to run unit and integration tests.

**.github/workflows/test.yml**:
```yaml
name: Test

on: [workflow_call]

jobs:
  test:
    runs-on: self-hosted

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Log in to GitHub Container Registry
        run: echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin

      - name: Run Unit Tests
        run: |
          IMAGE_NAME=ghcr.io/${{ secrets.REPO_OWNER }}/$(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')
          docker run $IMAGE_NAME swift test --filter UnitTests

      - name: Run Integration Tests
        run: |
          IMAGE_NAME=ghcr.io/${{ secrets.REPO_OWNER }}/$(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')
          docker run $IMAGE_NAME swift test --filter IntegrationTests
```

6. **Create Deployment Workflows**:
   - Create deployment workflows for both staging and production environments.

**.github/workflows/deploy-staging.yml**:
```yaml
name: Deploy to Staging

on: [workflow_call]

jobs:
  deploy:
    runs-on: self-hosted

    steps:
      - name: Set up SSH
        uses: webfactory/ssh-agent@v0.5.3
        with:
          ssh-private-key: ${{ secrets.VPS_SSH_KEY }}

      - name: Deploy to VPS (Staging)
        run: |
          ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
          cd ${{ secrets.DEPLOY_DIR }}
          docker pull ghcr.io/${{ secrets.REPO_OWNER }}/$(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')
          docker stop $(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')-staging || true
          docker rm $(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')-staging || true
          docker run -d --env-file ${{ secrets.DEPLOY_DIR }}/.env -p 8081:8080 --name $(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')-staging ghcr.io/${{ secrets.REPO_OWNER }}/$(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')
EOF

      - name: Verify Nginx and SSL Configuration (Staging)
        run: |
          ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
          if ! systemctl is-active --quiet nginx; then
            echo "Nginx is not running"
            exit 1
          fi

          if ! openssl s_client -connect ${{ secrets.STAGING_DOMAIN }}:443 -servername ${{ secrets.STAGING_DOMAIN }} </dev/null 2>/dev/null | openssl x509 -noout -dates; then
            echo "SSL certificate is not valid"
            exit 1
          fi

          if ! curl -k https://${{ secrets.STAGING_DOMAIN }} | grep -q "Expected content or response"; then
            echo "Domain is not properly configured"
            exit 1
          fi
EOF
```

**.github/workflows/deploy-production.yml**:
```yaml
name: Deploy to Production

on: [workflow_call]

jobs:
  deploy:
    runs-on: self-hosted

    steps:
      - name: Set up SSH
        uses: webfactory/ssh-agent@v0.5.3
        with:
          ssh-private-key: ${{ secrets.VPS_SSH_KEY }}

      - name: Deploy to VPS (Production)
        run: |
          ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
          cd ${{ secrets.DEPLOY_DIR }}
          docker pull ghcr.io/${{ secrets.REPO_OWNER }}/$(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')
          docker stop $(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]') || true
          docker rm $(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]') || true
          docker run -d --env-file ${{ secrets.DEPLOY_DIR }}/.env -p 8080:8080 --name $(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]') ghcr.io/${{ secrets.REPO_OWNER }}/$(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')
EOF

      - name: Verify Nginx and SSL Configuration (Production)
        run: |
          ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
          if ! systemctl is-active --quiet nginx; then
            echo "Nginx is not running"
            exit 1
          fi

          if ! openssl s_client -connect ${{ secrets.DOMAIN }}:443 -servername ${{ secrets.DOMAIN }} </dev/null 2>/dev/null | openssl x509 -noout -dates; then
            echo "SSL certificate is not valid"
            exit 1
          fi

          if ! curl -k https://${{ secrets.DOMAIN }} | grep -q "Expected content or response"; then
            echo "Domain is not properly configured"
            exit 1
          fi
EOF
```

7. **Create Main Workflows**:
   - Create main workflows to call the modular workflows for staging and production.

**.github/workflows/main-staging.yml**:
```yaml
name: Main Workflow for Staging

on:
  push:
    branches:
      - main
    paths:
      - '**'
  workflow_dispatch:

jobs:
  linting:
    uses: ./.github/workflows/linting.yml

  setup:
    needs: linting
    uses: ./.github/workflows/setup.yml

  ufw-config:
    needs: setup
    uses: ./.github/workflows/ufw-config.yml

  build:
    needs: ufw-config
    uses: ./.github/workflows/build.yml

  test:
    needs: build
    uses: ./.github/workflows/test.yml

  deploy:
    needs: test
    uses: ./.github/workflows/deploy-staging.yml
```

**.github/workflows/main-production.yml**:
```yaml
name: Main Workflow for Production

on:
  push:
    branches:
      - production
    paths:
      - '**'
  workflow_dispatch:

jobs:
  linting:
    uses: ./.github/workflows/linting.yml

  setup:
    needs: linting
    uses: ./.github/workflows/setup.yml

  ufw-config:
    needs: setup
    uses: ./.github/workflows/ufw-config.yml

  build:
    needs: ufw-config
    uses: ./.github/workflows/build.yml

  test:
    needs: build
    uses: ./.github/workflows/test.yml

  deploy:
    needs: test
    uses: ./.github/workflows/deploy-production.yml
```

#### Step 9: Create Vapor Application Manually

Create a script named `create_vapor_app.sh` in the root directory of your project. This script will create the Vapor application interactively using the Vapor toolbox.

**create_vapor_app.sh**:
```bash
#!/bin/bash

# Load configuration from config.env
source config.env

# Check if Vapor is installed
if ! command -v vapor &> /dev/null
then
    echo "Vapor toolbox could not be found. Please install it first."
    exit
fi

# Create a new Vapor project interactively
vapor new $APP_NAME

# Indicate that the Vapor app was created
echo "Vapor application $APP_NAME created successfully."

# Return to the root directory
cd ..
```

Make the script executable:
```sh
chmod +x create_vapor_app.sh
```

Run the script:


```sh
./create_vapor_app.sh
```

#### Step 10: Build and Push Docker Image to GitHub Container Registry

Create a script named `build_and_push_docker_image.sh` in the root directory of your project.

**build_and_push_docker_image.sh**:
```bash
#!/bin/bash

# Load configuration from config.env
source config.env

# Navigate to the directory containing the Vapor app
cd "$APP_NAME"

# Build the Docker image
docker build -t ghcr.io/$REPO_OWNER/$APP_NAME .

# Log in to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u $REPO_OWNER --password-stdin

# Push the Docker image to GitHub Container Registry
docker push ghcr.io/$

REPO_OWNER/$APP_NAME

# Navigate back to the root directory
cd ..
```

Make the script executable:
```sh
chmod +x build_and_push_docker_image.sh
```

Run the script:
```sh
./build_and_push_docker_image.sh
```

### Part 3: Deployment and Monitoring

## How to Deploy

### Deploy to Staging

1. **Push to the `main` Branch**:
   - Any push to the `main` branch will trigger the staging workflow (`main-staging.yml`).
   - To deploy to staging, commit your changes and push them to the `main` branch:
     ```sh
     git add .
     git commit -m "Your commit message"
     git push origin main
     ```

2. **Verify Deployment**:
   - The GitHub Actions workflow will automatically build, push the Docker image, run tests, and deploy the application to the staging environment.
   - You can monitor the progress in the Actions tab of your GitHub repository.

### Deploy to Production

1. **Create or Merge into a `production` Branch**:
   - Typically, you will create a separate branch named `production` for deploying to the production environment.
   - Merge changes from `main` (or another branch) into the `production` branch to trigger the production deployment.

   To create a `production` branch and push it:
   ```sh
   git checkout -b production
   git push origin production
   ```

   To merge changes into the `production` branch:
   ```sh
   git checkout production
   git merge main
   git push origin production
   ```

2. **Manual Workflow Dispatch**:
   - Optionally, you can configure the workflows to allow manual dispatch from the GitHub Actions interface.

### Monitoring and Manual Trigger

- **Monitoring**:
  - Go to the Actions tab in your GitHub repository to monitor the workflow runs and logs.

- **Manual Trigger** (Optional):
  - You can configure your GitHub Actions workflows to allow manual triggering from the GitHub interface. Add the `workflow_dispatch` event to your workflows.

**Example**:

**Staging Workflow (`.github/workflows/main-staging.yml`)**:
```yaml
name: Main Workflow for Staging

on:
  push:
    branches:
      - main
    paths:
      - '**'
  workflow_dispatch:

jobs:
  linting:
    uses: ./.github/workflows/linting.yml

  setup:
    needs: linting
    uses: ./.github/workflows/setup.yml

  ufw-config:
    needs: setup
    uses: ./.github/workflows/ufw-config.yml

  build:
    needs: ufw-config
    uses: ./.github/workflows/build.yml

  test:
    needs: build
    uses: ./.github/workflows/test.yml

  deploy:
    needs: test
    uses: ./.github/workflows/deploy-staging.yml
```

**Production Workflow (`.github/workflows/main-production.yml`)**:
```yaml
name: Main Workflow for Production

on:
  push:
    branches:
      - production
    paths:
      - '**'
  workflow_dispatch:

jobs:
  linting:
    uses: ./.github/workflows/linting.yml

  setup:
    needs: linting
    uses: ./.github/workflows/setup.yml

  ufw-config:
    needs: setup
    uses: ./.github/workflows/ufw-config.yml

  build:
    needs: ufw-config
    uses: ./.github/workflows/build.yml

  test:
    needs: build
    uses: ./.github/workflows/test.yml

  deploy:
    needs: test
    uses: ./.github/workflows/deploy-production.yml
```

With these configurations, you can manually trigger deployments from the Actions tab in your GitHub repository.

## Development Perspective

### TDD and CI/CD

Implementing Test-Driven Development (TDD) alongside Continuous Integration/Continuous Deployment (CI/CD) ensures that each feature of the OpenAPI specification is thoroughly tested and automatically deployed. The steps include:

1. **Write Tests First**:
   - For each API endpoint defined in the OpenAPI, write unit tests and integration tests before implementing the functionality.

2. **Develop the Feature**:
   - Implement the required functionality to pass the written tests.

3. **Run Tests Locally**:
   - Ensure that all tests pass locally.

4. **Commit and Push**:
   - Commit the code and push it to GitHub. The CI/CD pipeline will automatically build, test, and deploy the application.

5. **Review CI/CD Pipeline Results**:
   - Monitor the GitHub Actions pipeline to ensure the build passes and the application is deployed successfully.

6. **Deploy to Production**:
   - Once tests pass in the staging environment, merge the changes into the main branch to deploy to the production environment.

### Unit Tests

**Unit Tests** are designed to test individual units of code in isolation. They help ensure that each function, method, or class behaves as expected. Unit tests are typically fast and should cover edge cases, invalid inputs, and typical use cases.

**Example**:
For a function that adds two numbers, a unit test might look like this:

```swift
func testAddition() {
    XCTAssertEqual(add(2, 3), 5)
    XCTAssertEqual(add(-1, 1), 0)
    XCTAssertEqual(add(0, 0), 0)
}
```

### Integration Tests

**Integration Tests** are designed to test the interaction between different components or systems. They help ensure that various parts of the application work together as expected. Integration tests can involve testing multiple functions, database interactions, and API calls.

**Example**:
For an API endpoint that retrieves user data from a database, an integration test might look like this:

```swift
func testGetUser() throws {
    // Setup test data
    let user = User(name: "Test User", email: "test@example.com")
    try user.save()

    // Make API call
    let response = try app.getResponse(to: "/users/\(user.id!)", method: .GET)

    // Verify response
    XCTAssertEqual(response.status, .ok)
    let receivedUser = try response.content.decode(User.self).wait()
    XCTAssertEqual(receivedUser.name, "Test User")
    XCTAssertEqual(receivedUser.email, "test@example.com")
}
```

### Accessing Compiler Output in GitHub Actions

The output of the compiler and other build steps can be accessed through the GitHub Actions interface. Here's how you can access and utilize the compiler output:

1. **Navigate to Actions**:
   - Go to your GitHub repository.
   - Click on the **Actions** tab to view the list of workflow runs.

2. **Select a Workflow Run**:
   - Click on a specific workflow run to see the details.

3. **View Logs**:
   - In the workflow run details, you can see logs for each job and step.
   - Click on a job to expand it and view the logs for individual steps.

4. **Download Logs**:
   - You can download the logs for further analysis by clicking on the **Download logs** button.

5. **Retention Period**:
   - By default, GitHub retains logs for 90 days. You can configure this period in the repository settings under **Settings** -> **Actions** -> **Workflow runs** -> **Retention period**.

### Conclusion

Following this guide will set up a robust environment for developing and deploying the FountainAI project using Vapor. The combination of Docker, Nginx, PostgreSQL, Redis, RedisAI, and GitHub Actions ensures a seamless workflow from development to production. Implementing the OpenAPI specification in a TDD fashion will lead to a reliable and maintainable codebase, leveraging the benefits of automated testing and continuous deployment. Managing the VPS UFW settings enhances security, ensuring only necessary ports are open, including the NYDUS service port, for a secure and well-functioning application environment.


## Addendum 1: Generating a Super Powerful GitHub Personal Access Token

### Steps to Generate the Token

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
   - Copy the generated token and store it securely. This token will be used in your `config.env` file.

### Storing the Token in `config.env`

Add the generated token to your `config.env` file as follows:

```env
G_TOKEN=your_generated_token
```

### Important Note

Handle this token with care as it has extensive permissions and can make critical changes to your GitHub account and repositories. Do not share this token or expose it in public repositories.


## Addendum 2: Script for Building and Pushing Linting Docker Image

This addendum provides the detailed steps and script for building and pushing the linting Docker image to the GitHub Container Registry.

### Script: `build_and_push_linting_image.sh`

```bash
#!/bin/bash

# Load configuration from config.env
source config.env

# Verify the variable is set within the script
if [ -z "$G_TOKEN" ]; then
  echo "Error: G_TOKEN is not set."
  exit 1
fi

# Convert repository owner and name to lowercase
REPO_OWNER_LOWER=$(echo "$REPO_OWNER" | tr '[:upper:]' '[:lower:]')
REPO_NAME_LOWER=$(echo "$REPO_NAME" | tr '[:upper:]' '[:lower:]')

# Navigate to the linting directory
if [ -d "linting" ]; then
  cd linting
else
  echo "Error: linting directory does not exist."
  exit 1
fi

# Check if Dockerfile exists
if [ -f "Dockerfile" ]; then
  echo "Dockerfile found. Proceeding with the build."
else
  echo "Error: Dockerfile not found in the linting directory."
  exit 1
fi

# Build the Docker image
docker build -t ghcr.io/$REPO_OWNER_LOWER/linting .

# Log in to GitHub Container Registry non-interactively
if echo "$G_TOKEN" | docker login ghcr.io -u "$REPO_OWNER_LOWER" --password-stdin; then
  echo "Successfully logged in to GitHub Container Registry."
else
  echo "Error: Failed to log in to GitHub Container Registry."
  exit 1
fi

# Push the Docker image to GitHub Container Registry
if docker push ghcr.io/$REPO_OWNER_LOWER/linting; then
  echo "Successfully pushed the Docker image to GitHub Container Registry."
else
  echo "Error: Failed to push the Docker image to GitHub Container Registry."
  exit 1
fi

# Navigate back to the root directory
cd ..
```

### Description

This script performs the following actions:

1. **Load Configuration**: It loads the configuration variables from the `config.env` file.
2. **Verify Token**: It checks if the `G_TOKEN` variable is set. If not, it exits with an error message.
3. **Lowercase Conversion**: Converts the `REPO_OWNER` and `REPO_NAME` to lowercase to comply with Docker naming conventions.
4. **Navigate to Linting Directory**: Checks if the `linting` directory exists and navigates into it. If the directory does not exist, it exits with an error message.
5. **Dockerfile Check**: Verifies if the `Dockerfile` exists in the `linting` directory. If not, it exits with an error message.
6. **Build Docker Image**: Builds the Docker image with the tag `ghcr.io/$REPO_OWNER_LOWER/linting`.
7. **Login to GitHub Container Registry**: Logs in to the GitHub Container Registry non-interactively using the provided token.
8. **Push Docker Image**: Pushes the built Docker image to the GitHub Container Registry.
9. **Navigate Back**: Returns to the root directory after the operations are completed.

This script ensures that the linting Docker image is properly built and pushed to the GitHub Container Registry with error handling and verification steps to ensure successful execution.

trigger a github action workflow
again trigger
another trigger

