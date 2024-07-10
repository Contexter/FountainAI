## Table of Contents

- [Introduction](#introduction)
- [The FountainAI Project](#the-fountainai-project)
- [The Fountain Network Graph](#the-fountain-network-graph)
- [OpenAPI Specification](#openapi-specification)
- [Implementation](#implementation)
- [Prerequisites](#prerequisites)
- [Step-by-Step Setup Guide](#step-by-step-setup-guide)
  - [Step 1: Create GitHub Repository and Configuration File](#step-1-create-github-repository-and-configuration-file)
  - [Step 2: Generate a GitHub Personal Access Token](#step-2-generate-a-github-personal-access-token)
  - [Step 3: Create SSH Keys for VPS Access](#step-3-create-ssh-keys-for-vps-access)
  - [Step 4: Add SSH Keys to Your VPS and GitHub](#step-4-add-ssh-keys-to-your-vps-and-github)
  - [Step 5: Generate a Runner Registration Token](#step-5-generate-a-runner-registration-token)
  - [Step 6: Manually Add Secrets to GitHub](#step-6-manually-add-secrets-to-github)
  - [Step 7: Create GitHub Actions Workflow Templates](#step-7-create-github-actions-workflow-templates)
  - [Step 8: Create Vapor Application Manually](#step-8-create-vapor-application-manually)
  - [Step 9: Build and Push Docker Image to GitHub Container Registry](#step-9-build-and-push-docker-image-to-github-container-registry)
  - [Step 10: Configure UFW on VPS](#step-10-configure-ufw-on-vps)
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

## Introduction

This guide provides a comprehensive approach to creating and deploying a Vapor application using modern DevOps practices. You'll start by manually setting up a basic Vapor application and then configure a scalable environment leveraging Docker for services like Nginx, PostgreSQL, Redis, and RedisAI. Through detailed steps, you will establish automated testing and deployment using GitHub Actions, ensuring a streamlined workflow from development to production with CI/CD (Continuous Integration/Continuous Deployment). This setup is designed to enhance efficiency, reliability, and scalability for your application.

### Vision and Goals

**The Vision**: Establish an automated, efficient, and reliable pipeline for developing and deploying Vapor applications.

**Goals**:
1. **Automate Setup**: Simplify the initial setup with automated scripts and workflows.
2. **Leverage Containerization**: Create isolated, consistent environments for development, staging, and production using Docker.
3. **Implement CI/CD**: Integrate GitHub Actions for automated building, testing, and deployment.
4. **Enhance Security and Reliability**: Securely manage secrets and configurations to ensure reliable deployment processes.
5. **Ensure Scalability**: Design the setup to scale easily as the application grows.

## The FountainAI Project

In this guide, we will focus on implementing a specific project, FountainAI. FountainAI is a conceptual AI model designed to analyze and process scripts. The project involves creating a network graph, defining an OpenAPI specification, and implementing the application using Vapor. 

The following sections provide detailed steps on how to conceptualize the FountainAI network graph, specify the OpenAPI, and implement the application using Vapor, a popular server-side Swift framework.

## The Fountain Network Graph

### Vision and Goals

**The Vision**: To conceptualize and visualize the functioning of FountainAI, highlighting how different elements interact within the AI to analyze and process scripts. This network graph serves as an initial high-level idea of how FountainAI operates, providing a foundation for further detailed specifications and implementations.

**Goals**:
1. **Visualize Functionality**: Show the core idea and functioning of FountainAI, with "Paraphrase" at the center and other nodes representing key elements like "Character," "Action," "Spoken Word," and "Transition."
2. **Establish Relationships**: Illustrate the relationships and hierarchies between different script elements and their role in the AI's analysis.
3. **Conceptual Foundation**: Provide a visual and conceptual foundation for understanding and developing the AI.

### Explanation

---

![The Fountain Network Graph](https://coach.benedikt-eickhoff.de/koken/storage/cache/images/000/723/Bild-2,xlarge.1713545956.jpeg)

---

The Fountain Network Graph illustrates the conceptual model of FountainAI, with the "Paraphrase" node at the center symbolizing the core idea or theme. Connected nodes like "Character," "Action," "Spoken Word," and "Transition" are placed at cardinal points to signify their fundamental influence on the narrative. Other elements such as "Script," "Section Heading," "Music Sound," and "Note" are distributed evenly, indicating their supplementary role. This layout helps visualize the structural and thematic composition of storytelling, providing a foundational understanding of how FountainAI will process and analyze scripts.

## OpenAPI Specification

### Vision and Goals

**The Vision**: To transition from the conceptual model of FountainAI to a detailed and standardized API specification. This OpenAPI specification will define the endpoints, request/response formats, and data models required for implementing FountainAI, ensuring a consistent and reliable interface for communication.

**Goals**:
1. **Standardization**: Use OpenAPI to create a standardized format for API definitions, ensuring consistency and clarity.
2. **Detailed Specification**: Provide a comprehensive and detailed specification for all API endpoints and interactions within FountainAI.
3. **Foundation for Implementation**: Serve as the blueprint for implementing FountainAI, guiding developers through the necessary endpoints and data models.

### Explanation

The OpenAPI specification serves as the detailed blueprint for FountainAI, transitioning from the high-level conceptual model to a precise API definition. It outlines all the endpoints, request/response formats, and data models, ensuring that developers have a clear and consistent reference for implementing the AI. This standardization helps automate the generation of API documentation, client libraries, and server stubs, streamlining the development process and ensuring alignment with the conceptual model. The OpenAPI specification for this project can be found [here](https://github.com/Contexter/fountainAI/blob/main/openAPI/FountainAI-Admin-openAPI.yaml).

## Implementation

### Vision and Goals

**The Vision**: To bring the conceptual model and API specification of FountainAI into a functional and scalable application using Vapor. This phase involves translating the detailed OpenAPI specification into actual code, ensuring that the implementation is efficient, maintainable, and adheres to best practices.

**Goals**:
1. **Adherence to Specification**: Ensure the implementation strictly follows the OpenAPI specification, maintaining consistency and reliability.
2. **Scalability**: Design the application to handle growth and increased load efficiently.
3. **Maintainability**: Write clean, modular code that is easy to maintain and extend.
4. **Efficiency**: Optimize the application for performance and resource usage.

### Explanation

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

## Step-by-Step Setup Guide

### Step 1: Create GitHub Repository and Configuration File

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
   - Create a file named `config.env` in

 your project directory. This file will store all the necessary configuration variables.
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

### Project Directory Tree at Step 1

```
fountainAI/
├── .git/
├── .gitignore
├── config.env
└── README.md
```

### Step 2: Generate a GitHub Personal Access Token

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

### Step 3: Create SSH Keys for VPS Access

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

### Step 4: Add SSH Keys to Your VPS and GitHub

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

### Step 5: Generate a Runner Registration Token

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

### Step 6: Manually Add Secrets to GitHub

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

### Step 7: Create GitHub Actions Workflow Templates

Create separate workflows for staging and production. Start with `ci-cd-staging.yml`:

**.github/workflows/ci-cd-staging.yml**

```yaml
name: CI/CD Pipeline for ${{ secrets.APP_NAME }} (Staging)

on:
  push:
    branches:
      - main
    paths:
      - '**'
  workflow_dispatch: # Add this line to allow manual dispatch

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
        # This adds Docker's GPG key and the Docker APT repository if they aren't already added
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io
        sudo systemctl enable docker
        sudo systemctl start docker
        sudo apt install -y nginx certbot python3-certbot-nginx
EOF

    - name: Set up Nginx and SSL for Staging
      run: |
        ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
        sudo tee /etc/nginx/sites-available/${{ secrets.STAGING_DOMAIN }} > /dev/null <<EOL
server {
    listen 80;
    listen 443 ssl;
    server_name ${{ secrets.STAGING_DOMAIN }};
    ssl_certificate /etc/letsencrypt/live/${{ secrets.STAGING_DOMAIN }}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${{ secrets.STAGING_DOMAIN }}/privkey.pem;
    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL
        sudo ln -s /etc/nginx/sites-available/${{ secrets.STAGING_DOMAIN }} /etc/nginx/sites-enabled/
        sudo systemctl reload nginx
        sudo certbot --nginx -d ${{ secrets.STAGING_DOMAIN }} --non-interactive --agree-tos -m ${{ secrets.EMAIL }}
        sudo systemctl reload nginx
EOF

    - name: Set up PostgreSQL, Redis, and RedisAI
      run: |
        ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
        sudo docker stop postgres || true
        sudo docker rm postgres || true
        sudo docker run --name postgres -e POSTGRES_DB=${{ secrets.DB_NAME }} -e POSTGRES_USER=${{ secrets.DB_USER }} -e POSTGRES_PASSWORD=${{ secrets.DB_PASSWORD }} -p 5432:5432 -d postgres
        
        sudo docker stop redis || true
        sudo docker rm redis || true
        sudo docker run --name redis -p ${{ secrets.REDIS_PORT }}:6379 -d redis
        
        sudo docker stop redisai || true
        sudo docker rm redisai || true
        sudo docker run --name redisai -p ${{ secrets.REDISAI_PORT }}:6378 -d redislabs/redisai
        
        sleep 10
        
        PGPASSWORD=${{ secrets.DB_PASSWORD }} psql -h localhost -U postgres -c "DO \$\$ BEGIN
            IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${{ secrets.DB_USER }}') THEN
                CREATE ROLE ${{ secrets.DB_USER }} WITH LOGIN PASSWORD '${{ secrets.DB_PASSWORD }}';
            END IF;
        END \$\$;"
        
        PGPASSWORD=${{ secrets.DB_PASSWORD }} psql -h localhost -U postgres -c "CREATE DATABASE ${{ secrets.DB_NAME }} OWNER ${{ secrets.DB_USER }};"
EOF

  build:
    needs: setup-vps
    runs-on: self-hosted

    steps:
    - uses: actions/checkout@v2

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v1

    - name: Log in to GitHub Container Registry
      run: echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin

    - name: Build and Push Docker Image for Staging
      run: |
        IMAGE_NAME=ghcr.io/${{ secrets.REPO_OWNER }}/$(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')-staging
        docker build -t $IMAGE_NAME .
        docker push $IMAGE_NAME

  test:
    needs: build
    runs-on: self-hosted

    steps:
    - uses: actions/checkout@v2

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v1

    - name: Log in to GitHub Container Registry
      run: echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin

    - name: Run Unit Tests
      run: |
        IMAGE_NAME=ghcr.io/${{ secrets.REPO_OWNER }}/$(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')-staging
        docker run $IMAGE_NAME swift test --filter UnitTests

    - name: Run Integration Tests
      run: |
        IMAGE_NAME=ghcr.io/${{ secrets.REPO_OWNER }}/$(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')-staging
        docker run $IMAGE_NAME swift test --filter IntegrationTests

  deploy:
    needs: test
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
        docker pull ghcr.io/${{ secrets.REPO_OWNER }}/$(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')-staging
        docker stop $(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')-staging || true
        docker rm $(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')-staging || true
        docker run -d --env-file ${{ secrets.DEPLOY_DIR }}/.env -p 8081:8080 --name $(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')-staging ghcr.io/${{ secrets.REPO_OWNER }}/$(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')-staging
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

Then, create the production workflow:

**.github/workflows/ci-cd-production.yml**

```yaml
name: CI/CD Pipeline for ${{ secrets.APP_NAME }} (Production)

on:
  push:
    branches:
      - production
    paths:
      - '**'
  workflow_dispatch: # Add this

 line to allow manual dispatch

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
        # This adds Docker's GPG key and the Docker APT repository if they aren't already added
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io
        sudo systemctl enable docker
        sudo systemctl start docker
        sudo apt install -y nginx certbot python3-certbot-nginx
EOF

    - name: Set up Nginx and SSL for Production
      run: |
        ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
        sudo tee /etc/nginx/sites-available/${{ secrets.DOMAIN }} > /dev/null <<EOL
server {
    listen 80;
    listen 443 ssl;
    server_name ${{ secrets.DOMAIN }};
    ssl_certificate /etc/letsencrypt/live/${{ secrets.DOMAIN }}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${{ secrets.DOMAIN }}/privkey.pem;
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL
        sudo ln -s /etc/nginx/sites-available/${{ secrets.DOMAIN }} /etc/nginx/sites-enabled/
        sudo systemctl reload nginx
        sudo certbot --nginx -d ${{ secrets.DOMAIN }} --non-interactive --agree-tos -m ${{ secrets.EMAIL }}
        sudo systemctl reload nginx
EOF

    - name: Set up PostgreSQL, Redis, and RedisAI
      run: |
        ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
        sudo docker stop postgres || true
        sudo docker rm postgres || true
        sudo docker run --name postgres -e POSTGRES_DB=${{ secrets.DB_NAME }} -e POSTGRES_USER=${{ secrets.DB_USER }} -e POSTGRES_PASSWORD=${{ secrets.DB_PASSWORD }} -p 5432:5432 -d postgres
        
        sudo docker stop redis || true
        sudo docker rm redis || true
        sudo docker run --name redis -p ${{ secrets.REDIS_PORT }}:6379 -d redis
        
        sudo docker stop redisai || true
        sudo docker rm redisai || true
        sudo docker run --name redisai -p ${{ secrets.REDISAI_PORT }}:6378 -d redislabs/redisai
        
        sleep 10
        
        PGPASSWORD=${{ secrets.DB_PASSWORD }} psql -h localhost -U postgres -c "DO \$\$ BEGIN
            IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${{ secrets.DB_USER }}') THEN
                CREATE ROLE ${{ secrets.DB_USER }} WITH LOGIN PASSWORD '${{ secrets.DB_PASSWORD }}';
            END IF;
        END \$\$;"
        
        PGPASSWORD=${{ secrets.DB_PASSWORD }} psql -h localhost -U postgres -c "CREATE DATABASE ${{ secrets.DB_NAME }} OWNER ${{ secrets.DB_USER }};"
EOF

  build:
    needs: setup-vps
    runs-on: self-hosted

    steps:
    - uses: actions/checkout@v2

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v1

    - name: Log in to GitHub Container Registry
      run: echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin

    - name: Build and Push Docker Image for Production
      run: |
        IMAGE_NAME=ghcr.io/${{ secrets.REPO_OWNER }}/$(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')
        docker build -t $IMAGE_NAME .
        docker push $IMAGE_NAME

  deploy:
    needs: build
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

### Step 8: Create Vapor Application Manually

Create a script named `create_vapor_app.sh` in the root directory of your project. This script will create the Vapor application interactively using the Vapor toolbox.

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

### Project Directory Tree at Step 8

```
fountainAI/
├── .github/
│   └── workflows/
│       ├── ci-cd-production.yml
│       └── ci-cd-staging.yml
├── .git/
├── .gitignore
├── config.env
├── create_vapor_app.sh
└── README.md
└── fountainAI/
    ├── Package.swift
    ├── README.md
    ├── Sources/
    │   └── App/
    │       ├── configure.swift
    │       └── ...
    ├── Tests/
    │   ├── ...
    ├── Public/
    │   ├── ...
    ├── Resources/
    │   ├── ...
    └── Dockerfile
```

### Step 9: Build and Push Docker Image to GitHub Container Registry

Create a script named `build_and_push_docker_image.sh` in the root directory of your project.

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
docker push ghcr.io/$REPO_OWNER/$APP_NAME

# Navigate back to the root directory
cd ..
```

Make the script executable:

```sh
chmod +x build_and_push_docker_image.sh
```

### Project Directory Tree at Step 9

```
fountainAI/
├── .github/
│   └── workflows/
│       ├── ci-cd-production.yml
│       └── ci-cd-staging.yml
├── .git/
├── .gitignore
├── build_and_push_docker_image.sh
├── config.env
├── create_vapor_app.sh
└── README.md
└── fountainAI/
    ├── Package.swift
    ├── README.md
    ├── Sources/
    │   └── App/
    │       ├── configure.swift
    │       └── ...
    ├── Tests/
    │   ├── ...
    ├── Public/
    │   ├── ...
    ├── Resources/
    │   ├── ...
    └── Dockerfile
```

### Step 10: Configure UFW on VPS

To ensure that your VPS is secure and properly configured, it's essential to manage the firewall settings using UFW (Uncomplicated Firewall). This step will guide you on how to configure UFW to allow necessary ports for your services, including the special port for the NYDUS service, which connects your VPS instance to the host system's service dashboard.

#### NYDUS Port Configuration

**NYDUS_PORT**: The NYDUS service requires access through a specific port, which in this case is **2224**. This port must remain accessible to ensure proper connectivity between the VPS instance and the NYDUS service dashboard.

#### UFW Configuration Steps

1. **Install UFW**:
   - Ensure UFW is installed on your VPS. If it's not installed, you can install it using the following command:
     ```sh
     sudo apt install ufw
     ```

2. **Enable UFW**:
   - Enable UFW to start managing your firewall settings:
     ```sh
     sudo ufw enable
     ```

3. **Allow Necessary Ports**:
   - Configure UFW to allow traffic on the necessary ports for your application, database, and other services:
     ```sh
     sudo ufw allow 22/tcp   # SSH
     sudo ufw allow 80/tcp   # HTTP
     sudo ufw allow 443/tcp  # HTTPS
     sudo ufw allow 5432/tcp # PostgreSQL
     sudo ufw allow 6379/tcp # Redis
     sudo ufw allow 6378/tcp # RedisAI
     sudo ufw allow 8080/tcp # Application (Production)
     sudo ufw allow 8081/tcp # Application (Staging)
     sudo ufw allow 2224/tcp # NYDUS Service
     ```

4. **Check UFW Status**:
   - Verify the UFW status and ensure the rules are correctly applied:
     ```sh
     sudo ufw status
     ```

## How to Deploy

### Deploy to Staging

1. **Push to the `main` Branch**:
   - Any push to the `main` branch will trigger the staging workflow (`ci-cd-staging.yml`).
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

Example:

#### Staging Workflow (`.github/workflows/ci-cd-staging.yml`)

```yaml
name: CI/CD Pipeline for ${{ secrets.APP_NAME }} (Staging)

on:
  push:
    branches:
      - main
    paths:
      - '**'
  workflow_dispatch: # Add this line to allow manual dispatch
```

#### Production Workflow (`.github/workflows/ci-cd-production.yml`)

```yaml
name: CI/CD Pipeline for ${{ secrets.APP_NAME }} (Production)

on:
  push:
    branches:
      - production
    paths:
      - '**'
  workflow_dispatch: # Add this line to allow manual dispatch
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

#### Example:
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

#### Example:
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