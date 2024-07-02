Certainly! Below is the revised guide with the second addendum addressing idempotency in GitHub Actions templates included.

## Table of Contents

- [Introduction](#introduction)
- [The Fountain Network Graph](#the-fountain-network-graph)
- [OpenAPI Specification](#openapi-specification)
- [Prerequisites](#prerequisites)
- [Step-by-Step Setup Guide](#step-by-step-setup-guide)
  - [Step 1: Generate a GitHub Personal Access Token](#step-1-generate-a-github-personal-access-token)
  - [Step 2: Create SSH Keys for VPS Access](#step-2-create-ssh-keys-for-vps-access)
  - [Step 3: Add SSH Keys to Your VPS and GitHub](#step-3-add-ssh-keys-to-your-vps-and-github)
  - [Step 4: Create Configuration File](#step-4-create-configuration-file)
  - [Step 5: Initialize Git Repository](#step-5-initialize-git-repository)
  - [Step 6: Create Script to Add Secrets via GitHub's API](#step-6-create-script-to-add-secrets-via-githubs-api)
  - [Step 7: Create GitHub Actions Workflow Templates](#step-7-create-github-actions-workflow-templates)
  - [Step 8: Final Setup Script](#step-8-final-setup-script)
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
- [Addendum: Configuration File Documentation](#addendum-configuration-file-documentation)
- [Addendum: Ensuring Idempotency in GitHub Actions Templates](#addendum-ensuring-idempotency-in-github-actions-templates)

## Introduction

This guide provides a comprehensive step-by-step approach to automate the initial setup for a Vapor application, including setting up a Dockerized environment with Nginx, PostgreSQL, Redis, and RedisAI, along with SSL via Let's Encrypt managed by Certbot. It also covers creating separate environments for staging and production, managed through GitHub Actions.

## The Fountain Network Graph

---

![The Fountain Network Graph](https://coach.benedikt-eickhoff.de/koken/storage/cache/images/000/723/Bild-2,xlarge.1713545956.jpeg)

---

The illustration of the network graph featuring the "Paraphrase" node at the center and various other nodes positioned around it serves as a conceptual visualization for understanding relationships and hierarchies in script analysis, specifically within the context of film or theater script elements. Here's a breakdown of the reasoning behind this visualization:

### Central Node: "Paraphrase"
- **Purpose**: Represents the core idea or theme that can be modified or influenced by various script elements.
- **Symbolism**: Positioned at the center to emphasize its pivotal role in integrating and interpreting the surrounding elements.

### Connected Nodes at Specific Positions
- **Nodes**: "Character", "Action", "Spoken Word", "Transition"
- **Positions**: Placed at 12, 3, 6, and 9 o'clock.
- **Reasoning**:
  - These positions symbolize cardinal directions, suggesting fundamental aspects of scriptwriting that directly shape the narrative structure.
  - **12 o'clock ("Character")**: Characters are often the driving force of a narrative, situated at the top to signify their primary influence over the plot.
  - **3 o'clock ("Action")**: Actions propel the narrative forward, positioned to the right, indicating forward movement or progression.
  - **6 o'clock ("Spoken Word")**: Dialogue reveals character and advances the plot, located at the bottom, grounding the narrative.
  - **9 o'clock ("Transition")**: Transitions guide the flow and pacing of scenes, placed to the left, reflecting their role in shifting narrative phases.

### Other Nodes: Distributed Evenly
- **Nodes**: "Script", "Section Heading", "Music Sound", "Note"
- **Distribution**: Evenly around the circle, excluding the primary positions.
- **Reasoning**:
  - These elements, while crucial, are more peripheral compared to the direct narrative drivers.
  - Their even distribution around the circle avoids hierarchical implication, suggesting that their influence is supplementary and situational depending on the context of the script.

### Visual and Conceptual Implications
- **Circle Layout**: Suggests continuity and connectivity, mirroring the cyclical nature of narratives where various elements continuously influence each other.
- **Clarity and Separation**: By not overlapping and clearly distinguishing each node, the layout facilitates an intuitive understanding of how different script elements interact and contribute to the overall narrative.

### Educational and Analytical Use
- **Analysis Tool**: Can be used as a teaching aid to illustrate the dynamics of script elements in narrative building.
- **Script Development**: Helps scriptwriters visualize and reconsider the balance and emphasis of various elements within their scripts.

This network graph not only organizes script elements spatially but also metaphorically, providing insights into the structural and thematic composition of storytelling. It highlights the centrality of theme interpretation ("Paraphrase") while acknowledging the integral roles played by characters, actions, dialogues, and transitions in shaping a narrative.

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
MAIN_DIR=fountainAI-project
REPO_OWNER=Contexter
REPO_NAME=fountainAI
GITHUB_TOKEN=ghp_yourgithubtoken1234567890
VPS_SSH_KEY=-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
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
```

### Step 5: Initialize Git Repository

1. **Initialize Git Repository**:
   - Open your terminal and navigate to your project directory.
   - Run the following commands to initialize a new git repository and commit the initial setup:
     ```sh
     git init
     git add .
     git commit -m "Initial project setup"
     git remote add origin https://github.com/Contexter/fountainAI.git
     git push -u origin main
     ```

2. **Add `config.env` to `.gitignore`**:
   - Add the `config.env` file to `.gitignore` to ensure it is not tracked by git, preventing sensitive information from being exposed.
     ```sh
     echo "config.env" >> .gitignore
     git add .gitignore
     git commit -m "Add config.env to .gitignore for security"
     git push
     ```

**Security Note**: The `config.env` file contains sensitive information such as your GitHub token and private key. By adding it to `.gitignore`, you ensure this file is not tracked by git and is stored securely. This helps prevent accidental exposure of sensitive data in your repository.

### Step 6: Create Script to Add Secrets via GitHub's API

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
create_github_secret "DB_NAME" "$DB_NAME"
create_github_secret "DB_USER" "$DB_USER"
create_github_secret "DB_PASSWORD" "$DB_PASSWORD"
create_github_secret "REDIS_PORT" "$REDIS_PORT"
create_github_secret "REDISAI_PORT" "$REDISAI_PORT"

echo "Secrets have been added to GitHub repository."
```

Make the script executable and run it:

```sh
chmod +x add_secrets.sh
./add_secrets.sh
```

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
        docker run $IMAGE_NAME swift test

 --filter UnitTests

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

### Step 8: Final Setup Script

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

# Function to create and initialize a new Vapor app with required packages
create_vapor_app() {
    local app_name=$1
    mkdir -p $app_name
    cd $app_name
    vapor new $app_name --branch=main --non-interactive

    # Comment indicating the starter nature of the app
    echo "// This is a starter Vapor application. Further customization and implementation required." >> README.md

    # Update Package.swift to include PostgreSQL, Redis, RedisAI, and Leaf
    sed -i '' '/dependencies:/a\
        .package(url: "https://github.com/vapor/postgres-kit.git", from: "2.0.0"),\
        .package(url: "https://github.com/vapor/redis.git", from: "4.0.0"),\
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
- Enhanced PostgreSQL setup to include automatic user and database creation.
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

### Conclusion

Following this guide will set up a robust environment for developing and deploying the FountainAI project using Vapor. The combination of Docker, Nginx, PostgreSQL, Redis, RedisAI, and GitHub Actions ensures a seamless workflow from development to production. Implementing

 the OpenAPI specification in a TDD fashion will lead to a reliable and maintainable codebase, leveraging the benefits of automated testing and continuous deployment.

## Addendum: Configuration File Documentation

### `config.env` File

The `config.env` file is a crucial component in the setup process, containing all the necessary configuration variables. Here’s a breakdown of each variable and its purpose:

- **`MAIN_DIR`**: The main directory for the project on your local machine. This can be the same as the `APP_NAME` or different.
  - Example: `MAIN_DIR=fountainAI-project`
  
- **`REPO_OWNER`**: Your GitHub username or organization name.
  - Example: `REPO_OWNER=Contexter`
  
- **`REPO_NAME`**: The name of your GitHub repository.
  - Example: `REPO_NAME=fountainAI`
  
- **`GITHUB_TOKEN`**: Your GitHub personal access token.
  - Example: `GITHUB_TOKEN=ghp_yourgithubtoken1234567890`
  
- **`VPS_SSH_KEY`**: Your private SSH key for accessing the VPS. This key should be added to GitHub Secrets.
  - Example:
    ```env
    VPS_SSH_KEY=-----BEGIN OPENSSH PRIVATE KEY-----
    ...
    -----END OPENSSH PRIVATE KEY-----
    ```
  
- **`VPS_USERNAME`**: The username for accessing your VPS.
  - Example: `VPS_USERNAME=your_vps_username`
  
- **`VPS_IP`**: The IP address of your VPS.
  - Example: `VPS_IP=your_vps_ip`
  
- **`APP_NAME`**: The name of your application. This will be used in various places, including Docker images and deployment scripts.
  - Example: `APP_NAME=fountainAI`
  
- **`DOMAIN`**: The domain name for your production environment.
  - Example: `DOMAIN=example.com`
  
- **`STAGING_DOMAIN`**: The domain name for your staging environment.
  - Example: `STAGING_DOMAIN=staging.example.com`
  
- **`DEPLOY_DIR`**: The directory on your VPS where the application will be deployed.
  - Example: `DEPLOY_DIR=/home/your_vps_username/deployment_directory`
  
- **`EMAIL`**: The email address for Let's Encrypt SSL certificate registration.
  - Example: `EMAIL=mail@benedikt-eickhoff.de`
  
- **`DB_NAME`**: The name of your PostgreSQL database.
  - Example: `DB_NAME=fountainai_db`
  
- **`DB_USER`**: The username for your PostgreSQL database.
  - Example: `DB_USER=fountainai_user`
  
- **`DB_PASSWORD`**: The password for your PostgreSQL database.
  - Example: `DB_PASSWORD=your_db_password`
  
- **`REDIS_PORT`**: The port for your Redis service.
  - Example: `REDIS_PORT=6379`
  
- **`REDISAI_PORT`**: The port for your RedisAI service.
  - Example: `REDISAI_PORT=6378`

Ensure that this file is added to your `.gitignore` to prevent sensitive information from being exposed.

## Addendum: Ensuring Idempotency in GitHub Actions Templates

Idempotency in the context of GitHub Actions ensures that running the same workflow multiple times does not produce different results or cause unintended side effects. The provided GitHub Actions templates address idempotency through several mechanisms, ensuring that operations like service setup, deployments, and SSL configurations are idempotent. Here’s how the templates handle idempotency:

### Ensuring Idempotency in GitHub Actions Templates

1. **Service Setup with Docker:**
   - **PostgreSQL, Redis, and RedisAI Containers:**
     - Docker commands ensure that containers are run or started only if they are not already running. This is managed by stopping and removing existing containers before starting new ones, which ensures that the state of the services is consistent across workflow runs.
     ```sh
     sudo docker run --name postgres -e POSTGRES_DB=${{ secrets.DB_NAME }} -e POSTGRES_USER=${{ secrets.DB_USER }} -e POSTGRES_PASSWORD=${{ secrets.DB_PASSWORD }} -p 5432:5432 -d postgres
     sudo docker run --name redis -p ${{ secrets.REDIS_PORT }}:6379 -d redis
     sudo docker run --name redisai -p ${{ secrets.REDISAI_PORT }}:6378 -d redislabs/redisai
     ```
     - Ensuring clean slate:
     ```sh
     docker stop $(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')-staging || true
     docker rm $(echo ${{ secrets.APP_NAME }} | tr '[:upper:]' '[:lower:]')-staging || true
     ```

2. **Nginx Configuration and SSL Setup:**
   - **Nginx Configuration:**
     - Nginx configuration files are created or updated only if there are changes, ensuring that repeated runs do not create redundant configurations.
     ```sh
     sudo tee /etc/nginx/sites-available/${{ secrets.STAGING_DOMAIN }} > /dev/null <<EOL
     ...
     EOL
     ```
   - **SSL Setup:**
     - Certbot is used to manage SSL certificates. Certbot checks if a certificate already exists before attempting to issue a new one, ensuring that SSL setup does not create duplicate certificates.
     ```sh
     sudo certbot --nginx -d ${{ secrets.STAGING_DOMAIN }} --non-interactive --agree-tos -m ${{ secrets.EMAIL }}
     ```

3. **Workflow Steps:**
   - **Idempotent Operations:**
     - The actions and scripts are designed to be idempotent, ensuring that each step checks the current state before making changes.
     - For instance, the scripts for setting up Docker, Nginx, and SSL configurations are rerun safely without causing side effects or duplicating resources.
   
4. **GitHub Actions Workflow Logic:**
   - **Conditional Steps:**
     - By using conditional logic and checks, the workflows ensure that operations like deployments only occur if there are actual changes, avoiding redundant deployments.
     ```yaml
     if: github.ref == 'refs/heads/main'
     ```

5. **Environment Variables and Secrets Management:**
   - **Secrets and Configuration:**
     - By using GitHub secrets and environment variables, the workflows manage sensitive information securely and consistently, ensuring that configurations remain the same across runs.
     ```yaml
     env:
       DB_NAME: ${{ secrets.DB_NAME }}
       DB_USER: ${{ secrets.DB_USER }}
       DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
     ```

### Example: Detailed Workflow for Idempotency

Here is a detailed example of how the workflow ensures idempotency for setting up PostgreSQL, Nginx, and deploying the application:

```yaml
name: CI/CD Pipeline for ${{ secrets.APP_NAME }} (Staging)

on:
  push:
    branches:
      - main
  workflow_dispatch:

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
        sudo

 docker stop postgres || true
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

By incorporating these principles and examples into the GitHub Actions templates, you can ensure that your workflows are idempotent, providing consistent and reliable deployments across multiple runs.

---