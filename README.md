## Table of Contents

- [Introduction](#introduction)
- [The Fountain Network Graph](#the-fountain-network-graph)
- [OpenAPI Specification](#openapi-specification)
- [Prerequisites](#prerequisites)
- [Step-by-Step Setup Guide](#step-by-step-setup-guide)
  - [Step 1: Generate a GitHub Personal Access Token](#step-1-generate-a-github-personal-access-token)
  - [Step 2: Create SSH Keys for VPS Access](#step-2-create-ssh-keys-for-vps-access)
  - [Step 3: Add SSH Keys to Your VPS and GitHub](#step-3-add-ssh-keys-to-your-vps-and-github)
  - [Step 4: Generate a Runner Registration Token](#step-4-generate-a-runner-registration-token)
  - [Step 5: Create Configuration File](#step-5-create-configuration-file)
  - [Step 6: Initialize Git Repository](#step-6-initialize-git-repository)
  - [Step 7: Manually Add Secrets to GitHub](#step-7-manually-add-secrets-to-github)
  - [Step 8: Create GitHub Actions Workflow Templates](#step-8-create-github-actions-workflow-templates)
  - [Step 9: Create Vapor Application Locally](#step-9-create-vapor-application-locally)
  - [Step 10: Build and Push Docker Image to GitHub Container Registry](#step-10-build-and-push-docker-image-to-github-container-registry)
  - [Step 11: Configure UFW on VPS](#step-11-configure-ufw-on-vps)
  - [Step 12: Final Setup Script](#step-12-final-setup-script)
- [How to Deploy](#how-to-deploy)
  - [Deploy to Staging](#deploy-to-staging)
  - [Deploy to Production](#deploy-to-production)
  - [Monitoring and Manual Trigger](#monitoring-and-manual-trigger)
- [Commit Message](#commit-message)
- [Development Perspective](#development-perspective)
  - [TDD and CI/CD](#tdd-and-cicd)
  - [Unit Tests](#unit-tests)
  - [Integration Tests](#integration-tests)
  - [Conclusion](#conclusion)

## Introduction

This guide provides a comprehensive step-by-step approach to automate the initial setup and deployment of a Vapor application, using modern DevOps practices. By following these steps, you will create a robust and scalable environment for your application, leveraging Docker, Nginx, PostgreSQL, Redis, and RedisAI, all managed through GitHub Actions. This setup ensures a seamless workflow from development to production, enabling continuous integration and continuous deployment (CI/CD).

### Vision and Goals

**The Vision**: To establish an automated, efficient, and reliable pipeline for developing and deploying Vapor applications. By integrating Docker and GitHub Actions, we aim to streamline the development process, reduce deployment errors, and ensure consistent application performance across different environments.

**Goals**:
1. **Automate Setup**: Simplify the initial setup of a Vapor application with automated scripts and workflows.
2. **Leverage Containerization**: Use Docker to create isolated, consistent environments for development, staging, and production.
3. **Implement CI/CD**: Integrate GitHub Actions for automated building, testing, and deployment.
4. **Enhance Security and Reliability**: Securely manage secrets and configurations, ensuring reliable deployment processes.
5. **Ensure Scalability**: Design the setup to easily scale with the growth of the application.

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

The OpenAPI specification serves as the detailed blueprint for FountainAI, transitioning from the high-level conceptual model to a precise API definition. It outlines all the endpoints, request/response formats, and data models, ensuring that developers have a clear and consistent reference for implementing the AI. This standardization helps automate the generation of API documentation, client libraries, and server stubs, streamlining the development process and ensuring alignment with the conceptual model.

The OpenAPI specification for this project can be found [here](https://github.com/Contexter/fountainAI/blob/main/openAPI/FountainAI-Admin-openAPI.yaml).

## Implementation

### Vision and Goals

**The Vision**: To bring the conceptual model and API specification of FountainAI into a functional and scalable application using Vapor. This phase involves translating the detailed OpenAPI specification into actual code, ensuring that the implementation is efficient, maintainable, and adheres to best practices.

**Goals**:
1. **Adherence to Specification**: Ensure the implementation strictly follows the OpenAPI specification, maintaining consistency and reliability.
2. **Scalability**: Design the application to handle growth and increased load efficiently.
3. **Maintainability**: Write clean, modular code that is easy to maintain and extend.
4. **Efficiency**: Optimize the application for performance and resource usage.

### Explanation

The implementation phase involves creating the actual codebase for FountainAI using Vapor, a popular server-side Swift framework. By adhering to the OpenAPI specification, we ensure that the implementation is consistent with the defined API standards. The focus is on writing scalable, maintainable, and efficient code, leveraging Vapor's features and best practices. This phase translates the conceptual and API models into a working application, ready for deployment and real-world use.

---

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

### Step 1: Generate a GitHub Personal Access Token

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
   - Click **Generate token** and copy the generated token. This token will be used to authenticate Docker with GitHub's container registry and perform other API operations.

### Step 2: Create SSH Keys for VPS Access

1. **Open your terminal**.
2. **Generate an SSH Key Pair**:
   - Run the following command, replacing `your_email@example.com` with your email:
     ```sh
     ssh-keygen -t ed25519 -C "your_email@example.com"
     ```
   - Follow the prompts to save the key pair in the default location (`~/.ssh/id_ed25519` and `~/.ssh/id_ed25519.pub`).
     - When asked to "Enter a file in which to save the key," press Enter to accept the default location.
     - You can choose to set a passphrase or leave it empty by pressing Enter.

### Step 3: Add SSH Keys to Your VPS and GitHub

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

### Step 4: Generate a Runner Registration Token

1. **Generate the Runner Token**:
   - Go to your GitHub repository.
   - Navigate to **Settings** -> **Actions** -> **Runners**.
   - Click on **New self-hosted runner**.
   - Select the appropriate operating system for your VPS.
   - Follow the instructions to download and configure the runner. Note the `RUNNER_TOKEN` generated in the process. You will use this token to register the runner.

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

### Step 5: Create Configuration File

Create a file named `config.env` in your project directory. This file will store all the necessary configuration variables:

```env
MAIN_DIR=fountainAI-project
REPO_OWNER=Contexter
REPO_NAME=fountainAI
GITHUB_TOKEN=ghp_yourgithubtoken1234567890
VPS_SSH_KEY='-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----'
VPS_USERNAME=your_vps_username
VPS_IP=your_vps_ip
APP_NAME=fountainAI
DOMAIN=example.com
STAGING_DOMAIN=staging.example.com
DEPLOY_DIR=/home/your_vps_username/deployment_directory  # Directory on VPS where the app will be deployed
EMAIL=mail@benedikt-eickhoff.de
DB_NAME=fountainai_db
DB_USER=fountainai_user
DB_PASSWORD=your_db_password
REDIS_PORT=6379
REDISAI_PORT=6378
RUNNER_TOKEN=your_runner_registration_token
NYDUS_PORT=2224
```

### Step 6: Initialize Git Repository

1. **Add `config.env` to `.gitignore`**:
   - Add the `config.env` file to `.gitignore` to ensure it is not tracked by git, preventing sensitive information from being exposed.
     ```sh
     echo "config.env" >> .gitignore
     ```

2. **Initialize Git Repository**:
   - Open your terminal and navigate to your project directory.
   - Run the following commands to initialize a new git repository and commit the initial setup:
     ```sh
     git init
     git add .
     git commit -m "Initial project setup"
     git remote add origin https://github.com/Contexter/fountainAI.git
     git push -u origin main
     ```

**Security Note**: The `config.env` file contains sensitive information such as your GitHub token and private key. By adding it to `.gitignore` before committing, you ensure this file is not tracked by git and is stored securely. This helps prevent accidental exposure of sensitive data in your repository.

### Project Directory Tree at Step 6

```
fountainAI-project/
├── .git/
├── .gitignore
├── config.env
└── README.md
```

### Step 7: Manually Add Secrets to GitHub

Secrets are sensitive information that you don't want to expose in your source code. GitHub Actions allows you to store these secrets securely in your repository settings. For the FountainAI project, you need to add several secrets that will be used by your workflows.

#### Comprehensive Explanation of Each Secret:

1. **`MAIN_DIR`**: This is the main directory for the project on your local machine.
   - **Usage**: Organizes the project files and scripts.
   - **Example**: `fountainAI-project`

2. **`REPO_OWNER`**: Your GitHub username or organization name.
   - **Usage**: Identifies the owner of the repository.
   - **Example**: `Contexter`

3. **`REPO_NAME`**: The name of your GitHub repository.
   - **Usage**: Specifies the repository where the workflows will be executed.
   - **Example**: `fountainAI`

4. **`GITHUB_TOKEN`**: Your GitHub personal access token.
   - **Usage**: Authenticates GitHub API requests, such as pushing Docker images to GitHub Container Registry.
   - **Example**: `ghp_yourgithubtoken1234567890`

5. **`VPS_SSH_KEY`**: Your private SSH key for accessing the VPS.
   - **Usage**: Allows secure SSH connections to your VPS for deployments.
   - **Example**:
     ```env
     -----BEGIN OPENSSH PRIVATE KEY-----
     ...
     -----END OPENSSH PRIVATE KEY-----
     ```

6. **`VPS_USERNAME`**: The username for accessing your VPS.
   - **Usage**: Used in SSH commands to connect to your VPS.
   - **Example**: `your_vps_username`

7. **`VPS_IP`**: The IP address of your VPS.
   - **Usage**: Specifies the VPS to which you will connect for deployment.
   - **Example**: `your_vps_ip`

8. **`APP_NAME`**: The name of your application.


   - **Usage**: Used in naming Docker images and deployment directories.
   - **Example**: `fountainAI`

9. **`DOMAIN`**: The domain name for your production environment.
   - **Usage**: Configures Nginx and SSL certificates for the production environment.
   - **Example**: `example.com`

10. **`STAGING_DOMAIN`**: The domain name for your staging environment.
    - **Usage**: Configures Nginx and SSL certificates for the staging environment.
    - **Example**: `staging.example.com`

11. **`DEPLOY_DIR`**: The directory on your VPS where the application will be deployed.
    - **Usage**: Specifies where the application files will be stored on the VPS.
    - **Example**: `/home/your_vps_username/deployment_directory`

12. **`EMAIL`**: The email address for Let's Encrypt SSL certificate registration.
    - **Usage**: Required by Certbot for generating SSL certificates.
    - **Example**: `mail@benedikt-eickhoff.de`

13. **`DB_NAME`**: The name of your PostgreSQL database.
    - **Usage**: Configures the database connection in your application.
    - **Example**: `fountainai_db`

14. **`DB_USER`**: The username for your PostgreSQL database.
    - **Usage**: Authenticates connections to your PostgreSQL database.
    - **Example**: `fountainai_user`

15. **`DB_PASSWORD`**: The password for your PostgreSQL database.
    - **Usage**: Authenticates connections to your PostgreSQL database.
    - **Example**: `your_db_password`

16. **`REDIS_PORT`**: The port for your Redis service.
    - **Usage**: Configures the Redis connection in your application.
    - **Example**: `6379`

17. **`REDISAI_PORT`**: The port for your RedisAI service.
    - **Usage**: Configures the RedisAI connection in your application.
    - **Example**: `6378`

18. **`RUNNER_TOKEN`**: The runner registration token for setting up the self-hosted GitHub Actions runner.
    - **Usage**: Registers the self-hosted runner with GitHub Actions.
    - **Example**: `your_runner_registration_token`

19. **`NYDUS_PORT`**: The port for the NYDUS service, which connects the host system's service dashboard with the VPS instance.
    - **Usage**: Ensures the NYDUS service can connect to the VPS.
    - **Example**: `2224`

#### Adding Secrets to GitHub:

1. **Navigate to Your Repository Settings**:
   - Go to your GitHub repository in your web browser.
   - Click on **Settings**.

2. **Access Secrets and Variables**:
   - In the left sidebar, click on **Secrets and variables**.
   - Click on **Actions**.

3. **Add a New Repository Secret**:
   - Click on **New repository secret**.
   - Enter the **Name** and **Value** for each secret as described above.
   - Click **Add secret** to save.

---

### Step 8: Create GitHub Actions Workflow Templates

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
        ssh ${{ secrets.VPS_USERNAME }}@

${{ secrets.VPS_IP }} << 'EOF'
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

### Project Directory Tree at Step 8

```
fountainAI-project/
├── .github/
│   └── workflows/
│       ├── ci-cd-production.yml
│       └── ci-cd-staging.yml
├── .git/
├── .gitignore
├── config.env
└── README.md
```

### Step 9: Create Vapor Application Locally

Create a script named `create_vapor_app.sh`:

```bash
#!/bin/bash

# Load configuration from config.env


source config.env

# Function to create and initialize a new Vapor app with required packages
create_vapor_app() {
    local app_name=$1
    mkdir -p $app_name
    cd $app_name
    vapor new $app_name --branch=main --non-interactive

    # Comment indicating the starter nature of the app
    echo "// This is a starter Vapor application. Further customization and implementation required." >> README.md

    # Update Package.swift to include PostgreSQL, Redis, RedisAI, and Leaf
    sed -i ''

 '/dependencies:/a\
        .package(url: "https://github.com/vapor/postgres-kit.git", from: "2.0.0"),\
        .package(url: "https://github.com/vapor/redis.git", from: "4.0.0"),

\
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0")
    ' Package.swift

    sed -i '' '/targets:/a\
        .target(name: "'$app_name'", dependencies: [.product(name: "Leaf", package: "leaf"), .product(name: "PostgresKit", package: "postgres-kit"), .product(name: "Redis", package: "redis")])
    ' Package.swift

    # Create the necessary configurations for Leaf, PostgreSQL, and Redis in configure.swift
    cat <<EOT >> Sources/App/configure.swift
import Vapor
import Leaf
import Fluent
import FluentPostgresDriver
import Redis

public func configure(_ app: Application) throws {
    app.views.use(.leaf)

    app.databases.use(.postgres(
        hostname: Environment.get("DB_HOST") ?? "localhost",
        username: Environment.get("DB_USER") ?? "postgres",
        password: Environment.get("DB_PASSWORD") ?? "password",
        database: Environment.get("DB_NAME") ?? "database"
    ), as: .psql)

    app.redis.configuration = try RedisConfiguration(
        hostname: Environment.get("REDIS_HOST") ?? "localhost",
        port: Environment.get("REDIS_PORT").flatMap(Int.init(_:)) ?? 6379
    )

    // Register routes
    try routes(app)
}
EOT

    # Return to main directory
    cd ..
}

# Execute the function
create_vapor_app $APP_NAME
```

Make the script executable:

```sh
chmod +x create_vapor_app.sh
./create_vapor_app.sh
```

### Project Directory Tree at Step 9

```
fountainAI-project/
├── .github/
│   └── workflows/
│       ├── ci-cd-production.yml
│       └── ci-cd-staging.yml
├── .git/
├── .gitignore
├── config.env
├── create_vapor_app.sh
├── README.md
└── fountainAI/
    ├── Package.swift
    ├── README.md
    ├── Sources/
    │   └── App/
    │       ├── configure.swift
    │       └── ...
    └── ...
```

### Step 10: Build and Push Docker Image to GitHub Container Registry

Create a script named `build_and_push_docker_image.sh`:

```bash
#!/bin/bash

# Load configuration from config.env
source config.env

# Create Dockerfile for Vapor application
cat <<EOF > Dockerfile
FROM swift:5.4

WORKDIR /app

# Install Vapor
RUN git clone https://github.com/vapor/toolbox.git /tmp/toolbox \
    && cd /tmp/toolbox \
    && swift build -c release --disable-sandbox \
    && mv .build/release/vapor /usr/local/bin/vapor

# Copy the Vapor project files
COPY . .

# Build the Vapor application
RUN vapor build --release

# Expose the application port
EXPOSE 8080

# Start the Vapor application
CMD ["vapor", "run", "serve", "--env", "production"]
EOF

# Build the Docker image
docker build -t ghcr.io/$REPO_OWNER/$APP_NAME .

# Log in to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u $REPO_OWNER --password-stdin

# Push the Docker image to GitHub Container Registry
docker push ghcr.io/$REPO_OWNER/$APP_NAME
```

Make the script executable and run it:

```sh
chmod +x build_and_push_docker_image.sh
./build_and_push_docker_image.sh
```

### Project Directory Tree at Step 10

```
fountainAI-project/
├── .github/
│   └── workflows/
│       ├── ci-cd-production.yml
│       └── ci-cd-staging.yml
├── .git/
├── .gitignore
├── config.env
├── create_vapor_app.sh
├── build_and_push_docker_image.sh
├── Dockerfile
├── README.md
└── fountainAI/
    ├── Package.swift
    ├── README.md
    ├── Sources/
    │   └── App/
    │       ├── configure.swift
    │       └── ...
    └── ...
```

### Step 11: Configure UFW on VPS

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

### Step 12: Final Setup Script

**Final Setup Script (`setup.sh`)**:

```bash
#!/bin/bash

# Load configuration from config.env
source config.env

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if required environment variables are set
check_env_vars() {
    local missing=0
    for var in MAIN_DIR REPO_OWNER REPO_NAME GITHUB_TOKEN VPS_SSH_KEY VPS_USERNAME VPS_IP APP_NAME DOMAIN STAGING_DOMAIN DEPLOY_DIR EMAIL DB_NAME DB_USER DB_PASSWORD REDIS_PORT REDISAI_PORT RUNNER_TOKEN NYDUS_PORT; do
        if [ -z "${!var}" ]; then
            echo "Error: $var is not set in config.env"
            missing=1
        fi
    done
    return $missing
}

# Function to check if required commands are available
check_commands() {
    local missing=0
    for cmd in git curl jq ssh ssh-keygen docker; do
        if ! command_exists $cmd; then
            echo "Error: $cmd is not installed"
            missing=1
        fi
    done
    return $missing
}

# Function to check if Docker is installed on the VPS
check_docker_on_vps() {
    ssh $VPS_USERNAME@$VPS_IP "command -v docker >/dev/null 2>&1"
}

# Function to check if GitHub runner is running on the VPS
check_runner_on_vps() {
    ssh $VPS_USERNAME@$VPS_IP "systemctl is-active --quiet github-runner"
}

# Main function to set up the project
main() {
    # Check for required environment variables
    if ! check_env_vars; then
        echo "One or more required environment variables are missing"
        exit 1
    fi

    # Check for required commands
    if ! check_commands; then
        echo "One or more required commands are missing"
        exit 1
    fi

    # Check if Docker is installed on the VPS
    if ! check_docker_on_vps; then
        echo "Docker is not installed on the VPS. Installing Docker..."
        ssh $VPS_USERNAME@$VPS_IP << EOF
        sudo apt update
        sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux

/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io
        sudo systemctl enable docker
        sudo systemctl start docker
EOF
    fi

    # Check if GitHub runner is running on the VPS
    if ! check_runner_on_vps; then
        echo "GitHub runner is not running on the VPS. Please ensure it is set up correctly."
        exit 1
    fi

    # Configure UFW on the VPS
    ssh $VPS_USERNAME@$VPS_IP << EOF
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw allow 5432/tcp
    sudo ufw allow 6379/tcp
    sudo ufw allow 6378/tcp
    sudo ufw allow 8080/tcp
    sudo ufw allow 8081/tcp
    sudo ufw allow $NYDUS_PORT/tcp
    sudo ufw enable
EOF

    # Create main directory
    mkdir -p $MAIN_DIR
    cd $MAIN_DIR

    # Generate workflows
    ./generate_workflows.sh

    # Create and build Vapor app locally
    ./create_vapor_app.sh

    # Build and push Docker image to GitHub Container Registry
    ./build_and_push_docker_image.sh

    echo "Initial setup for FountainAI project is complete."
}

# Execute main function
main
```

Make the final setup script executable and run it:

```sh
chmod +x setup.sh
./setup.sh
```

### Project Directory Tree at Step 12

```
fountainAI-project/
├── .github/
│   └── workflows/
│       ├── ci-cd-production.yml
│       └── ci-cd-staging.yml
├── .git/
├── .gitignore
├── config.env
├── create_vapor_app.sh
├── build_and_push_docker_image.sh
├── setup.sh
├── Dockerfile
├── README.md
└── fountainAI/
    ├── Package.swift
    ├── README.md
    ├── Sources/
    │   └── App/
    │       ├── configure.swift
    │       └── ...
    └── ...
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

## Commit Message

```plaintext
feat: Add UFW management and directory tree visualization

- Integrated UFW management into the setup guide to ensure VPS security.
- Added instructions to configure UFW to allow necessary ports, including the NYDUS service port (2224).
- Updated the final setup script to automate UFW configuration.
- Ensured all required ports for SSH, HTTP, HTTPS, PostgreSQL, Redis, RedisAI, and application services are included.
- Enhanced security by providing a comprehensive guide for managing firewall settings on the VPS.
- Included project directory tree visualizations at key steps to aid in understanding the project structure.

```

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

Following this guide will set up a robust environment for developing and deploying the FountainAI project using Vapor. The combination of Docker, Nginx, PostgreSQL, Redis, RedisAI, and GitHub Actions ensures a seamless workflow from development to production. Implementing the OpenAPI specification in a TDD fashion will lead to a reliable and maintainable codebase, leveraging the benefits of automated testing and continuous deployment. Managing the VPS UFW settings enhances security, ensuring only necessary ports are open, including the NYDUS service port, for a secure

 and well-functioning application environment.