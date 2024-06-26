
## Table of Contents

- [Introduction](#introduction)
- [OpenAPI Specification](#openapi-specification)
- [Prerequisites](#prerequisites)
- [Step-by-Step Setup Guide](#step-by-step-setup-guide)
  - [Step 1: Generate a GitHub Personal Access Token](#step-1-generate-a-github-personal-access-token)
  - [Step 2: Create SSH Keys for VPS Access](#step-2-create-ssh-keys-for-vps-access)
  - [Step 3: Add SSH Keys to Your VPS and GitHub](#step-3-add-ssh-keys-to-your-vps-and-github)
  - [Step 4: Create Configuration File](#step-4-create-configuration-file)
  - [Step 5: Create Script to Add Secrets via GitHub's API](#step-5-create-script-to-add-secrets-via-githubs-api)
  - [Step 6: Create GitHub Actions Workflow Templates](#step-6-create-github-actions-workflow-templates)
  - [Step 7: Final Setup Script](#step-7-final-setup-script)
- [How to Deploy](#how-to-deploy)
  - [Deploy to Staging](#deploy-to-staging)
  - [Deploy to Production](#deploy-to-production)
  - [Monitoring and Manual Trigger](#monitoring-and-manual-trigger)
- [Commit Message](#commit-message)
- [Development Perspective](#development-perspective)
  - [TDD and CI/CD](#tdd-and-cicd)
  - [Conclusion](#conclusion)

## Introduction

This guide provides a comprehensive step-by-step approach to automate the initial setup for a Vapor application, including setting up a Dockerized environment with Nginx, PostgreSQL, Redis, and SSL via Let's Encrypt managed by Certbot. It also covers creating separate environments for staging and production, managed through GitHub Actions.

## OpenAPI Specification

The OpenAPI specification for this project can be found [here](https://github.com/Contexter/fountainAI/blob/main/openAPI/FountainAI-Admin-openAPI.yaml).

## Prerequisites

Before starting the setup, ensure you have the following:

1. **GitHub Account**: You need a GitHub account to host your repositories and manage secrets.
2. **GitHub Personal Access Token**: Required for accessing the GitHub API.
3. **VPS (Virtual Private Server)**: To deploy your applications.
4. **SSH Key Pair**: For secure communication between your local machine and the VPS.
5. **Docker**: Installed on your local machine for containerization.
6. **curl and jq**: Installed on your local machine for making API calls and processing JSON.

## Step-by-Step Setup Guide

### Step 1: Generate a GitHub Personal Access Token

1. **Generate the Token**:
   - Go to your GitHub account settings.
   - Navigate to **Developer settings** -> **Personal access tokens**.
   - Generate a new token with the following scopes:
     - `write:packages`
     - `read:packages`
     - `delete:packages`
     - `repo` (for accessing private repositories).
   - Copy the token. This token will be used to authenticate Docker with GitHub's container registry.

### Step 2: Create SSH Keys for VPS Access

1. **Generate an SSH Key Pair**:
   - Open your terminal.
   - Run the following command, replacing `your_email@example.com` with your email:
     ```sh
     ssh-keygen -t ed25519 -C "your_email@example.com"
     ```
   - Follow the prompts to save the key pair in the default location (`~/.ssh/id_ed25519` and `~/.ssh/id_ed25519.pub`).

### Step 3: Add SSH Keys to Your VPS and GitHub

1. **Copy the Public Key**:
   - Run the following command to display the public key:
     ```sh
     cat ~/.ssh/id_ed25519.pub
     ```
   - Copy the output (your public key).

2. **Add the Public Key to Your VPS**:
   - Use an SSH client to connect to your VPS.
   - Example command:
     ```sh
     ssh $VPS_USERNAME@$VPS_IP
     ```
   - On your VPS, run the following command to add your public key to the `authorized_keys` file:
     ```sh
     echo "<public_key>" >> ~/.ssh/authorized_keys
     ```
   - Replace `<public_key>` with the public key you copied earlier.

3. **Copy the Private Key**:
   - Run the following command to display the private key:
     ```sh
     cat ~/.ssh/id_ed25519
     ```
   - Copy the output (your private key).

4. **Add the Private Key to GitHub Secrets**:
   - Go to your GitHub repository.
   - Navigate to **Settings** -> **Secrets and variables** -> **Actions**.
   - Add a new secret named `VPS_SSH_KEY` and paste the copied private key.

### Step 4: Create Configuration File

Create a file named `config.env` in your project directory. This file will store all the necessary configuration variables:

```env
MAIN_DIR=fountainai-project
REPO_OWNER=your_github_username
REPO_NAME=your_repository_name
GITHUB_TOKEN=your_github_token
VPS_SSH_KEY=your_vps_private_key
VPS_USERNAME=your_vps_username
VPS_IP=your_vps_ip
APP_NAME=fountainai
DOMAIN=example.com
STAGING_DOMAIN=staging.example.com
DEPLOY_DIR=/home/your_vps_username/deployment_directory  # Directory on VPS where the app will be deployed
EMAIL=mail@benedikt-eickhoff.de
```

### Step 5: Create Script to Add Secrets via GitHub's API

Create a script named `add_secrets.sh`:

```bash
#!/bin/bash

# Load configuration from config.env
source config.env

# Function to create a secret in GitHub repository
create_github_secret() {
    local secret_name=$1
    local secret_value=$2

    # Get the public key
    PUB_KEY_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
                            "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/secrets/public-key")
    PUB_KEY=$(echo "$PUB_KEY_RESPONSE" | jq -r '.key')
    KEY_ID=$(echo "$PUB_KEY_RESPONSE" | jq -r '.key_id')

    # Encrypt the secret value
    ENCRYPTED_VALUE=$(echo -n "$secret_value" | openssl rsautl -encrypt -pubin -inkey <(echo "$PUB_KEY" | base64 -d) | base64)

    # Create the secret
    curl -s -X PUT -H "Authorization: token $GITHUB_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"encrypted_value\":\"$ENCRYPTED_VALUE\",\"key_id\":\"$KEY_ID\"}" \
        "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/secrets/$secret_name"
}

# Add secrets
create_github_secret "MAIN_DIR" "$MAIN_DIR"
create_github_secret "REPO_OWNER" "$REPO_OWNER"
create_github_secret "REPO_NAME" "$REPO_NAME"
create_github_secret "GITHUB_TOKEN" "$GITHUB_TOKEN"
create_github_secret "VPS_SSH_KEY" "$VPS_SSH_KEY"
create_github_secret "VPS_USERNAME" "$VPS_USERNAME"
create_github_secret "VPS_IP" "$VPS_IP"
create_github_secret "APP_NAME" "$APP_NAME"
create_github_secret "DOMAIN" "$DOMAIN"
create_github_secret "STAGING_DOMAIN" "$STAGING_DOMAIN"
create_github_secret "DEPLOY_DIR" "$DEPLOY_DIR"
create_github_secret "EMAIL" "$EMAIL"

echo "Secrets have been added to GitHub repository."
```

Make the script executable and run it:

```sh
chmod +x add_secrets.sh
./add_secrets.sh
```

### Step 6: Create GitHub Actions Workflow Templates

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
    runs-on: ubuntu-latest
    steps:
      - name: Set up SSH
        uses: webfactory/ssh-agent@v0.5.3
        with:
          ssh-private-key: ${{ secrets.VPS_SSH_KEY }}

      - name: Set up Nginx and SSL for Staging
        run: |
          ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
          sudo apt update
          sudo apt install -y nginx certbot python3-certbot-nginx
          sudo tee /etc/nginx/sites-available/${{ secrets.STAGING_DOMAIN }} > /dev/null <<EOL
server {
    listen 80;
    listen 443 ssl;
    server_name ${{ secrets.STAGING_DOMAIN }};
    ssl_certificate /etc/letsencrypt/live/${{ secrets.STAGING_DOMAIN }}/fullchain.pem;
    ssl_certificate_key /etc

/letsencrypt/live/${{ secrets.STAGING_DOMAIN }}/privkey.pem;
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

  build:
    needs: setup-vps
    runs-on: ubuntu-latest
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

  deploy:
    needs: build
    runs-on: ubuntu-latest
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
  workflow_dispatch: # Add this line to allow manual dispatch

jobs:
  setup-vps:
    runs-on: ubuntu-latest
    steps:
      - name: Set up SSH
        uses: webfactory/ssh-agent@v0.5.3
        with:
          ssh-private-key: ${{ secrets.VPS_SSH_KEY }}

      - name: Set up Nginx and SSL for Production
        run: |
          ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
          sudo apt update
          sudo apt install -y nginx certbot python3-certbot-nginx
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

  build:
    needs: setup-vps
    runs-on: ubuntu-latest
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
    runs-on: ubuntu-latest
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

### Step 7: Final Setup Script

**Final Setup Script (`setup.sh`)**:
```bash
#!/bin/bash

# Load configuration from config.env
source config.env

# Function to create main project directory
create_main_directory() {
    mkdir -p $MAIN_DIR
    cd $MAIN_DIR
}

# Function to create and initialize a new Vapor app in its starter state
create_vapor_app() {
    local app_name=$1
    mkdir -p $app_name
    cd $app_name
    vapor new $app_name --branch=main --non-interactive

    # Comment indicating the starter nature of the app
    echo "// This is a starter Vapor application. Further customization and implementation required." >> README.md

    # Return to main directory
    cd ..
}

# Function to install Docker on the VPS
install_docker_on_vps() {
    ssh $VPS_USERNAME@$VPS_IP << EOF
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common


    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl enable docker
    sudo systemctl start docker
EOF
}

# Main function to set up the project
main() {
    create_main_directory

    create_vapor_app $APP_NAME

    ./add_secrets.sh

    ./generate_workflows.sh

    install_docker_on_vps

    ./setup_nginx.sh

    echo "Initial setup for FountainAI project is complete."
}

# Execute main function
main
```

**Execute Final Setup Script**:
```sh
chmod +x setup.sh
./setup.sh
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
   - The GitHub Actions workflow will automatically build, push the Docker image, and deploy the application to the staging environment.
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
feat: Automated setup for FountainAI project

- Added comprehensive step-by-step guide to automate the initial setup for a Vapor application.
- Included security best practices and explanations for managing SSH keys and .env files.
- Created configuration file `config.env` to store necessary configuration variables.
- Added `add_secrets.sh` script to automate adding secrets to GitHub.
- Provided `ci-cd-template.yml` for GitHub Actions workflow templates.
- Added `setup.sh` script to automate the creation of Vapor application and generating workflows.
- Integrated Nginx and SSL setup directly into GitHub Actions workflows.
- Ensured Docker installation on VPS as part of the setup process.
- Detailed deployment steps for staging and production environments.
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

### Conclusion

Following this guide will set up a robust environment for developing and deploying the FountainAI project using Vapor. The combination of Docker, Nginx, PostgreSQL, Redis, and GitHub Actions ensures a seamless workflow from development to production. Implementing the OpenAPI specification in a TDD fashion will lead to a reliable and maintainable codebase, leveraging the benefits of automated testing and continuous deployment.

---

By following this guide, you will have a well-structured and automated setup for developing and deploying your Vapor application with environment-specific configurations for both staging and production.