### `episodes/episode3.md`

# Episode 3: Creating and Managing the Vapor App for FountainAI with CI/CD Pipeline

## Table of Contents

1. [Introduction](#introduction)
2. [Setting Up the Vapor Application](#setting-up-the-vapor-application)
3. [Dockerizing the Vapor Application](#dockerizing-the-vapor-application)
4. [Introduction to Docker Compose](#introduction-to-docker-compose)
5. [Configuring Docker Compose](#configuring-docker-compose)
6. [Integrating with CI/CD Pipeline](#integrating-with-cicd-pipeline)
7. [Testing and Monitoring the Deployment](#testing-and-monitoring-the-deployment)
8. [Conclusion](#conclusion)

---

## Introduction

In this episode, we will focus on creating a basic "Hello, World!" Vapor application, Dockerizing it, and integrating it into the CI/CD pipeline established in Episode 2. We will also introduce Docker Compose to manage multiple containers and ensure a smooth deployment process. This integration will utilize the secrets management scheme already set up to handle sensitive information securely.

## Setting Up the Vapor Application

First, we need to set up a new Vapor project within the existing `fountainAI` repository. This will serve as the foundation for our application. To streamline this process, we'll use a shell script to automate the setup.

### Create a Script to Set Up the Vapor Application

Create a file named `setup_vapor_project.sh` with the following content:

```sh
#!/bin/bash

# Ensure we're in the root directory of the existing repository
cd path/to/your/fountainAI

# Initialize a new Vapor project (without git initialization)
vapor new . --template=api --no-git

# Ensure the generated files are correctly integrated
# Commit the new files to the existing Git repository
git add .
git commit -m "Integrated Vapor project into existing repository"
git push origin development

echo "Vapor project setup complete and pushed to development branch."
```

This script navigates to the root directory of your existing repository, initializes a new Vapor project using the API template without creating a new Git repository, adds the generated files to the existing Git repository, and pushes the changes to the development branch.

Make this script executable and run it:

```sh
chmod +x setup_vapor_project.sh
./setup_vapor_project.sh
```

## Dockerizing the Vapor Application

Next, we need to ensure that the Vapor application can be containerized using Docker. The Vapor toolbox generates a default Dockerfile, which we will review and update if necessary.

### Verify and Update the Dockerfile

Create a file named `update_dockerfile.sh` with the following content:

```sh
#!/bin/bash

# Create or update the Dockerfile with the following content
cat << 'EOF' > Dockerfile
# Use the official Swift image for building the application
FROM swift:5.7 as builder

# Set the working directory
WORKDIR /app

# Copy the package files and resolve dependencies
COPY Package.swift .
COPY Package.resolved .

# Resolve dependencies
RUN swift package resolve

# Copy the entire repository into the container
COPY . .

# Build the application in release mode
RUN swift build --configuration release --enable-test-discovery

# Create a slimmer runtime image
FROM swift:5.7-slim

# Set the working directory in the runtime image
WORKDIR /app

# Copy the build artifacts from the builder image
COPY --from=builder /app/.build/release /app
COPY --from=builder /app/Public /app/Public
COPY --from=builder /app/Resources /app/Resources

# Expose the port that the application will run on
EXPOSE 8080

# Run the application
CMD ["./Run"]
EOF

# Commit the Dockerfile to the repository
git add Dockerfile
git commit -m "Updated Dockerfile for Vapor application"
git push origin development

echo "Dockerfile updated and pushed to development branch."
```

This script ensures that the Dockerfile is set up correctly by copying the necessary files, building the Vapor application in release mode, and creating a slimmer runtime image. It then commits and pushes the Dockerfile to the development branch.

Make this script executable and run it:

```sh
chmod +x update_dockerfile.sh
./update_dockerfile.sh
```

## Introduction to Docker Compose

Docker Compose is a tool for defining and running multi-container Docker applications. With Compose, you can manage different services such as your web server, database, and cache with a single configuration file.

#### Benefits of Docker Compose:
- **Multi-Container Management**: Easily manage multiple containers for different services (e.g., web server, database, cache).
- **Declarative Configuration**: Define all your services in a single `docker-compose.yml` file.
- **Simplified Deployment**: One command to start and stop all services, simplifying the deployment process.

## Configuring Docker Compose

Given the [OpenAPI specification](https://github.com/Contexter/fountainAI/blob/main/openAPI/FountainAI-Admin-openAPI.yaml), we need to set up an environment with multiple services: Nginx, Vapor, PostgreSQL, Redis, and RedisAI.

### Create a Script to Set Up Docker Compose

Create a file named `setup_docker_compose.sh` with the following content:

```sh
#!/bin/bash

# Create the docker-compose.yml file with the following content
cat << 'EOF' > docker-compose.yml
version: '3.8'

services:
  nginx:
    image: nginx:latest
    container_name: nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./nginx/certbot/conf:/etc/letsencrypt
      - ./nginx/certbot/www:/var/www/certbot
    depends_on:
      - vapor
    networks:
      - fountainai_network

  vapor:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: vapor
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - REDISAI_URL=${REDISAI_URL}
    depends_on:
      - postgres
      - redis
      - redisai
    networks:
      - fountainai_network

  postgres:
    image: postgres:13
    container_name: postgres
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - fountainai_network

  redis:
    image: redis:6
    container_name: redis
    ports:
      - "6379:6379"
    networks:
      - fountainai_network

  redisai:
    image: redislabs/redisai:latest
    container_name: redisai
    ports:
      - "6378:6378"
    networks:
      - fountainai_network

networks:
  fountainai_network:
    driver: bridge

volumes:
  postgres_data:
EOF

# Commit the docker-compose.yml file to the repository
git add docker-compose.yml
git commit -m "Added Docker Compose configuration"
git push origin development

echo "Docker Compose configuration added and pushed to development branch."
```

This script creates the `docker-compose.yml` file, defining the services and their dependencies, networks, and volumes. The environment variables are placeholders that will be replaced with secrets managed by the CI/CD pipeline. It then commits and pushes the configuration to the development branch.

Make this script executable and run it:

```sh
chmod +x setup_docker_compose.sh
./setup_docker_compose.sh
```

## Integrating with CI/CD Pipeline

We need to ensure that our CI/CD pipeline can build, push, and deploy the Docker Compose stack. We'll update our CI/CD pipeline scripts to include these steps, leveraging the secrets management from Episode 2.

### How the CI/CD Pipeline Manages Secrets Injection into the Docker Compose File

The CI/CD pipeline leverages the `Manage Secrets` action to securely inject secrets into the Docker Compose file. Here's how it works:

1. **Define Secrets in CI/CD Environment**:
   - Secrets such as `DATABASE_URL`, `REDIS_URL`, `REDISAI_URL`, `DB_NAME`, `DB_USER`, and `DB_PASSWORD` are securely stored in the CI/CD environment (e.g., GitHub Secrets).

2. **Manage Secrets Action**:
   - The `Manage Secrets` action retrieves these secrets from the CI/CD environment and sets them as environment variables for subsequent steps in the workflow.

3. **Docker Compose File Configuration**:
   - The `docker-compose.yml` file is configured to use environment variables for sensitive information. Placeholders like `${DATABASE_URL}` are used in the `docker-compose.yml` file.
   - When the pipeline runs, the environment variables set by the `Manage Secrets` action replace these placeholders with actual values.

4. **Pipeline Workflow**:
   - The workflow uses the `Manage Secrets` action to validate and export secrets.
   - The `Setup Environment` action prepares the VPS environment.
   - The `Build Project` action builds the Docker image, ensuring that the environment variables are available during the build process.
   - The `Deploy Project` action deploys the Docker Compose stack, injecting the secrets into the running containers.

### Update the Environment Setup Action

To securely manage SSH keys, we will use `ssh-agent` to handle the SSH key in-memory, avoiding writing it to disk. Here is the revised `update_setup_environment_action.sh`:

```sh
#!/bin/bash

# Create or update the setup environment action index.js file
cat << 'EOF' > .github/actions/setup/index.js
const core = require('@actions/core');
const exec = require('@actions/exec');

async function run() {
    try {
        const vpsUsername = core.getInput('vps_username');
        const vpsIp = core.getInput('vps_ip');
        const vpsSshKey = core.getInput('vps_ssh_key');

        // Start the SSH agent
        await exec.exec('ssh-agent', ['-a', '/tmp/ssh-agent.sock']);
        core.exportVariable('SSH_AUTH_SOCK', '/tmp/ssh-agent.sock');

        // Add the SSH key to the agent
        await exec.exec('ssh-add', ['-'], { input: vpsSshKey });

        // Commands to install Docker and Docker Compose
        const installDockerCmd = `
            sudo apt-get update &&
            sudo apt-get install -y \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg \
                lsb-release &&
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg &&
            echo "deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null &&
            sudo apt-get update &&
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io &&
            sudo usermod -aG docker ${vpsUsername} &&
            sudo systemctl enable docker &&
            sudo systemctl start docker &&
            sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose &&
            sudo chmod +x /usr/local/bin/docker-compose &&
            sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose &&
            docker-compose --version
        `;

        // SSH command to execute the installation on the VPS
        await exec.exec(`ssh -o StrictHostKeyChecking=no ${vpsUsername}@${vpsIp} '${installDockerCmd}'`);
        
        core.info('Docker and Docker Compose installed successfully on the VPS');
    } catch (error) {
        core.setFailed(`Action failed with error ${error}`);
    }
}

run();
EOF

# Commit the setup environment action changes
git add .github/actions/setup/index.js
git commit -m "Updated setup environment action to use ssh-agent for SSH key management"
git push origin development

echo "Setup environment action updated and pushed to development branch."
```

This script updates the environment setup action to use `ssh-agent` for managing the SSH key securely in memory. It starts the SSH agent, adds the SSH key to the agent from the provided input, and uses the SSH agent to authenticate and run the installation commands on the VPS. It then commits and pushes the changes to the development branch.

Make this script executable and run it:

```sh
chmod +x update_setup_environment_action.sh
./update_setup_environment_action.sh
```

### Update the Build Action

Create a file named `update_build_action.sh` with the following content:

```sh
#!/bin/bash

# Create or update the build action index.js file
cat << 'EOF' > .github/actions/build/index.js
const core = require('@actions/core');
const exec = require('@actions/exec');

async function run() {
    try {
        // Build Docker image
        await exec.exec('docker build -t ghcr.io/Contexter/fountainai:latest .');
        
        // Log in to GitHub Container Registry
        await exec.exec(`echo ${{ secrets.GITHUB_TOKEN }} | docker login ghcr.io -u Contexter --password-stdin`);
        
        // Push Docker image to GitHub Container Registry
        await exec.exec('docker push ghcr.io/Contexter/fountainai:latest');
        
        core.info('Docker image built and pushed successfully');
    } catch (error) {
        core.setFailed(`Action failed with error ${error}`);
    }
}

run();
EOF

# Commit the build action changes
git add .github/actions/build/index.js
git commit -m "Updated build action to build and push Docker image"
git push origin development

echo "Build action updated and pushed to development branch."
```

This script updates the build action to build the Docker image and push it to the GitHub Container Registry. It then commits and pushes the changes to the development branch.

Make this script executable and run it:

```sh
chmod +x update_build_action.sh
./update_build_action.sh
```

### Update the Deploy Action

Create a file named `update_deploy_action.sh` with the following content:

```sh
#!/bin/bash

# Create or update the deploy action index.js file
cat << 'EOF' > .github/actions/deploy/index.js
const core = require('@actions/core');
const exec = require('@actions/exec');

async function run() {
    try {
        const environment = core.getInput('environment');
        const vpsUsername = core.getInput('vps_username');
        const vpsIp = core.getInput('vps_ip');
        const deployDir = core.getInput('deploy_dir');

        // SSH into VPS and pull the latest Docker images, then run the Docker Compose stack
        await exec.exec(`ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no ${vpsUsername}@${vpsIp} `
            + `'cd ${deployDir} && docker-compose pull && docker-compose up -d --remove-orphans'`);
        
        core.info(`Deployed to ${environment} environment successfully`);
    } catch (error) {
        core.setFailed(`Action failed with error ${error}`);
    }
}

run();
EOF

# Commit the deploy action changes
git add .github/actions/deploy/index.js
git commit -m "Updated deploy action to deploy Docker Compose stack"
git push origin development

echo "Deploy action updated and pushed to development branch."
```

This script updates the deploy action to SSH into the VPS, pull the latest Docker images, and run the Docker Compose stack. It then commits and pushes the changes to the development branch.

Make this script executable and run it:

```sh
chmod +x update_deploy_action.sh
./update_deploy_action.sh
```

### Update Development Workflow

Create a file named `update_development_workflow.sh` with the following content:

```sh
#!/bin/bash

# Create or update the development workflow file
cat << 'EOF' > .github/workflows/development.yml
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
          vps_username: ${{ secrets.VPS_USERNAME }}
          vps_ip: ${{ secrets.VPS_IP }}
          deploy_dir: ${{ secrets.DEPLOY_DIR }}
EOF

# Commit the development workflow changes
git add .github/workflows/development.yml
git commit -m "Updated development workflow to include Docker build, push, and deployment steps"
git push origin development

echo "Development workflow updated and pushed to development branch."
```

This script updates the development workflow to include steps for building, pushing, and deploying the Docker Compose stack. It then commits and pushes the changes to the development branch.

Make this script executable and run it:

```sh
chmod +x update_development_workflow.sh
./update_development_workflow.sh
```

## Testing and Monitoring the Deployment

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

## Conclusion

In this episode, we created a basic "Hello, World!" Vapor application, Dockerized it, and integrated it into the CI/CD pipeline established in Episode 2. By introducing Docker Compose, we set up a multi-container environment to manage different services, ensuring a robust and scalable infrastructure for the FountainAI project. 

We also detailed how the CI/CD pipeline manages secrets injection into the Docker Compose file using the `Manage Secrets` action, ensuring that sensitive information is securely handled. Additionally, we improved the security of SSH key management by using `ssh-agent` to keep the key in memory, avoiding the risk associated with writing keys to disk.

By following these steps and using shell scripts to automate file creation and updates, we ensured that our CI/CD pipeline is functioning correctly and efficiently. This setup will support the seamless integration and deployment of new features and services as we continue to develop FountainAI.

Stay tuned for the next episodes, where we will delve deeper into the implementation of FountainAI, building upon the solid groundwork established in this episode. We will expand the functionality of the Vapor application, integrate additional services, and continue refining our deployment process to ensure a seamless and reliable development experience.