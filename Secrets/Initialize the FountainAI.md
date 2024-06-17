## Introduction to FountainAI Project Setup and Configuration

The FountainAI project involves developing multiple Vapor applications, each with specific requirements for building, testing, and deployment. Managing these applications individually can be time-consuming and error-prone. This guide provides a detailed, step-by-step approach to automate the initial setup for all ten Vapor applications, including the foundational Secrets Manager and Authentication Service.

### Background

Vapor is a popular web framework for Swift, ideal for creating RESTful services. We use Docker for containerization and GitHub Actions for CI/CD automation to manage the lifecycle of each application efficiently. Our goal is to set up an environment where every code change is automatically built, tested, and deployed with minimal manual intervention.

### Prerequisites

Before starting the setup, ensure you have the following:

1. **GitHub Account**: You need a GitHub account to host your repositories and manage secrets.
2. **GitHub Personal Access Token**: Required for accessing the GitHub API.
3. **VPS (Virtual Private Server)**: To deploy your applications.
4. **SSH Key Pair**: For secure communication between your local machine and the VPS.
5. **Docker**: Installed on your local machine for containerization.
6. **curl and jq**: Installed on your local machine for making API calls and processing JSON.

### Step-by-Step Setup Guide

We will follow these steps to set up the FountainAI project:

1. Generate a GitHub Personal Access Token.
2. Create SSH keys for VPS access.
3. Add SSH keys to your VPS and GitHub.
4. Create a configuration file.
5. Create a script to add secrets via GitHub's API.
6. Create GitHub Actions workflow templates.
7. Create a script to generate workflows.
8. Set up Nginx and SSL on the VPS for each Vapor app.
9. Run a comprehensive setup script to finalize the project setup.

### How Docker Ensures Correct Ports for Nginx Proxy to Vapor Apps

Docker and Nginx work together to route traffic to the appropriate Vapor app running in Docker containers. Here’s how it happens step-by-step:

1. **Docker Container Configuration**:
    - Each Vapor app is built into a Docker image and run as a Docker container.
    - During the container run command, a specific port on the host is mapped to the port inside the Docker container where the Vapor app is listening. This is done using the `-p` option in the Docker run command.
    - The specific ports for each app are assigned and stored as secrets in GitHub, and they are referenced when running the Docker containers.

2. **Nginx Configuration**:
    - Nginx is set up on the VPS to act as a reverse proxy.
    - Nginx configuration files for each subdomain are created to route incoming requests to the appropriate Docker containers based on the subdomain and port mapping.
    - SSL certificates are obtained and configured for each subdomain using Certbot.

Here’s how this process is implemented in the provided setup scripts and workflows:

#### Step 1: Generate a GitHub Personal Access Token

1. **Generate the Token**:
   - Go to your GitHub account settings.
   - Navigate to **Developer settings** -> **Personal access tokens**.
   - Generate a new token with the following scopes:
     - `write:packages`
     - `read:packages`
     - `delete:packages`
     - `repo` (for accessing private repositories).
   - Copy the token. This token will be used to authenticate Docker with GitHub's container registry.

#### Step 2: Create SSH Keys for VPS Access

1. **Generate an SSH Key Pair**:
   - Open your terminal.
   - Run the following command, replacing `your_email@example.com` with your email:
     ```sh
     ssh-keygen -t ed25519 -C "your_email@example.com"
     ```
   - Follow the prompts to save the key pair in the default location (`~/.ssh/id_ed25519` and `~/.ssh/id_ed25519.pub`).

   **Security Note**: SSH keys are used to securely connect to your VPS without exposing your password. Keep your private key (`id_ed25519`) safe and never share it. The public key (`id_ed25519.pub`) is safe to share with the VPS.

#### Step 3: Add SSH Keys to Your VPS and GitHub

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
     ssh your_vps_username@your_vps_ip
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

   **Security Note**: GitHub Secrets allow you to store sensitive information securely. Adding your private key here ensures that it is encrypted and only accessible to GitHub Actions workflows.

#### Visualization of Key Management

**Step 1: Generate SSH Key Pair on Local Machine**

```plaintext
Local Machine:
+-----------------------------------------+
| Command:                                |
| ssh-keygen -t ed25519 -C "your_email@example.com" |
+-----------------------------------------+
| Files Generated:                        |
| - Private Key: ~/.ssh/id_ed25519        |
| - Public Key:  ~/.ssh/id_ed25519.pub    |
+-----------------------------------------+
```

**Step 2: Copy Public Key to VPS**

```plaintext
Local Machine:
+-----------------------------------------+
| Command:                                |
| cat ~/.ssh/id_ed25519.pub               |
| (Copy the output)                       |
+-----------------------------------------+

               |
               v

VPS:
+-----------------------------------------+
| Command:                                |
| ssh your_vps_username@your_vps_ip       |
| echo "<public_key>" >> ~/.ssh/authorized_keys |
| (Replace <public_key> with the copied   |
| public key output)                      |
+-----------------------------------------+
```

**Step 3: Add Private Key to GitHub Secrets**

```plaintext
Local Machine:
+-----------------------------------------+
| Command:                                |
| cat ~/.ssh/id_ed25519                   |
| (Copy the output)                       |
+-----------------------------------------+

               |
               v

GitHub:
+-----------------------------------------+
| Steps:                                  |
| 1. Go to GitHub Repository Settings     |
| 2. Navigate to "Secrets and variables"  |
|    -> "Actions"                         |
| 3. Add a new secret named `VPS_SSH_KEY` |
| 4. Paste the copied private key         |
+-----------------------------------------+
```

### Summary of Actions and Locations

1. **Local Machine**:
   - **Generate SSH Key Pair**:
     ```sh
     ssh-keygen -t ed25519 -C "your_email@example.com"
     ```
     - Private Key: `~/.ssh/id_ed25519`
     - Public Key: `~/.ssh/id_ed25519.pub`
   - **Copy Public Key**:
     ```sh
     cat ~/.ssh/id_ed25519.pub
     ```
   - **Copy Private Key**:
     ```sh
     cat ~/.ssh/id_ed25519
     ```

2. **VPS**:
   - **Add Public Key** to `authorized_keys`:
     ```sh
     echo "<public_key>" >> ~/.ssh/authorized_keys
     ```

3. **GitHub**:
   - **Add Private Key** to GitHub Secrets:
     - Navigate to **Settings** -> **Secrets and variables** -> **Actions**.
     - Add a new secret named `VPS_SSH_KEY` and paste the copied private key.

### Visualization Diagram

```plaintext
+---------------------------+         +---------------------------+
| Local Machine             |         | VPS                       |
|                           |         |                           |
| ssh-keygen -t ed25519     |         |                           |
| - Generates SSH Key Pair  |         |                           |
|   - Private Key           |         |                           |
|     ~/.ssh/id_ed25519     +-------->| ssh your_vps_username@    |
|   - Public Key            |         | your_vps_ip               |
|     ~/.ssh/id_ed25519.pub |         | echo "<public_key>" >>    |
|                           |         | ~/.ssh/authorized_keys    |
| cat ~/.ssh/id_ed25519.pub |         | (Add Public Key)          |
| - Copy Public Key         |         |                           |
+-------------+-------------+         +-------------+-------------+
              |                                     |
              v                                     v
+-------------+-------------+                       |
| Local Machine             |                       |
|                           |                       |
| cat ~/.ssh/id_ed25519     |                       |
| - Copy Private Key        |                       |
+-------------+-------------+                       |
              |                                     |
              v                                     v
+-------------+-------------+         +---------------------------+
| GitHub Repository         |         | GitHub Secrets            |
|                           |         |                           |
| Go to

 Settings            |         | Add Secret:               |
| - "Secrets and variables" |         | - Name: VPS_SSH_KEY       |
| - "Actions"               |         | - Value: <private_key>    |
| Add New Secret            |         |   (Paste copied key)      |
| - Name: VPS_SSH_KEY       |         |                           |
| - Value: <private_key>    |         +---------------------------+
|   (Paste copied key)      |
+---------------------------+
```

#### Step 4: Create Configuration File

Create a file named `config.env` in your project directory. This file will store all the necessary configuration variables:

```env
MAIN_DIR=fountainai-project
REPO_OWNER=your_github_username
REPO_NAME=your_repository_name
GITHUB_TOKEN=your_github_token
VPS_SSH_KEY=your_vps_private_key
VPS_USERNAME=your_vps_username
VPS_IP=your_vps_ip
APP_NAMES=app1,app2,app3,app4,app5,app6,app7,app8,app9,app10
DOMAIN=example.com
```

**Security Note**: The `config.env` file contains sensitive information such as your GitHub token and private key. Ensure this file is not tracked by Git and is stored securely. You can add it to your `.gitignore` file to prevent it from being committed to your repository.

#### Directory Structure After Step 4

```plaintext
fountainai-project/
├── config.env
```

#### Step 5: Create Script to Add Secrets via GitHub's API

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

# Add common secrets
create_github_secret "GHCR_TOKEN" "$GITHUB_TOKEN"
create_github_secret "VPS_SSH_KEY" "$VPS_SSH_KEY"
create_github_secret "VPS_USERNAME" "$VPS_USERNAME"
create_github_secret "VPS_IP" "$VPS_IP"

# Add application-specific secrets
for i in "${!APP_NAMES_ARRAY[@]}"; do
    app_name=${APP_NAMES_ARRAY[$i]}
    port=$((8080 + $i))
    upper_app_name=$(echo $app_name | tr '[:lower:]' '[:upper:]')

    create_github_secret "${upper_app_name}_DB_HOST" "<your_db_host>"
    create_github_secret "${upper_app_name}_DB_USER" "<your_db_user>"
    create_github_secret "${upper_app_name}_DB_PASSWORD" "<your_db_password>"
    create_github_secret "${upper_app_name}_API_KEY" "<your_api_key>"
    create_github_secret "${upper_app_name}_GHCR_TOKEN" "$GITHUB_TOKEN"
    create_github_secret "${upper_app_name}_VPS_SSH_KEY" "$VPS_SSH_KEY"
    create_github_secret "${upper_app_name}_VPS_USERNAME" "$VPS_USERNAME"
    create_github_secret "${upper_app_name}_VPS_IP" "$VPS_IP"
    create_github_secret "${upper_app_name}_DOMAIN_NAME" "${app_name}.${DOMAIN}"


    create_github_secret "${upper_app_name}_PORT" "$port"
done

echo "Secrets have been added to GitHub repository."
```

Make the script executable and run it:

```bash
chmod +x add_secrets.sh
./add_secrets.sh
```

#### Directory Structure After Step 5

```plaintext
fountainai-project/
├── config.env
├── add_secrets.sh
```

#### Step 6: Create GitHub Actions Workflow Templates

Create a file named `ci-cd-template.yml` under `.github/workflows/`:

```yaml
name: CI/CD Pipeline for {{app_name}}

on:
  push:
    paths:
      - '{{app_name}}/**'
      - '.github/workflows/ci-cd-{{app_name}}.yml'

jobs:
  setup-vps:
    runs-on: ubuntu-latest
    steps:
      # Set up SSH
      - name: Set up SSH
        uses: webfactory/ssh-agent@v0.5.3
        with:
          ssh-private-key: ${{ secrets.VPS_SSH_KEY }}

      # Install Nginx and Certbot, and configure Nginx for the app
      - name: Set up Nginx and SSL
        run: |
          ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
          # Update and install necessary packages
          sudo apt update
          sudo apt install nginx certbot python3-certbot-nginx -y

          # Configure Nginx
          sudo tee /etc/nginx/sites-available/{{app_name}}.${{ secrets.DOMAIN }} > /dev/null <<EOL
server {
    listen 80;
    listen 443 ssl;
    server_name {{app_name}}.${{ secrets.DOMAIN }};

    ssl_certificate /etc/letsencrypt/live/{{app_name}}.${{ secrets.DOMAIN }}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/{{app_name}}.${{ secrets.DOMAIN }}/privkey.pem;

    location / {
        proxy_pass http://localhost:${{ secrets.{{APP_NAME}}_PORT }};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

          # Enable the site and reload Nginx
          sudo ln -s /etc/nginx/sites-available/{{app_name}}.${{ secrets.DOMAIN }} /etc/nginx/sites-enabled/
          sudo systemctl reload nginx

          # Obtain SSL certificate
          sudo certbot --nginx -d {{app_name}}.${{ secrets.DOMAIN }} --non-interactive --agree-tos -m your-email@example.com
          sudo systemctl reload nginx
EOF

  build:
    needs: setup-vps
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      # Set up Docker Buildx
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      # Set up environment variables for the app
      - name: Set up .env file
        run: |
          echo "DB_HOST=${{ secrets.{{APP_NAME}}_DB_HOST }}" >> {{app_name}}/.env
          echo "DB_USER=${{ secrets.{{APP_NAME}}_DB_USER }}" >> {{app_name}}/.env
          echo "DB_PASSWORD=${{ secrets.{{APP_NAME}}_DB_PASSWORD }}" >> {{app_name}}/.env
          echo "API_KEY=${{ secrets.{{APP_NAME}}_API_KEY }}" >> {{app_name}}/.env

      # Log in to GitHub Container Registry
      - name: Log in to GitHub Container Registry
        run: echo "${{ secrets.GHCR_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin

      # Build and Push Docker Image
      - name: Build and Push Docker Image
        run: |
          cd {{app_name}}
          IMAGE_NAME=ghcr.io/${{ github.repository_owner }}/{{app_name}}
          docker build -t $IMAGE_NAME .
          docker push $IMAGE_NAME

  unit-test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      # Set up Docker Buildx
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      # Set up environment variables for the app
      - name: Set up .env file
        run: |
          echo "DB_HOST=${{ secrets.{{APP_NAME}}_DB_HOST }}" >> {{app_name}}/.env
          echo "DB_USER=${{ secrets.{{APP_NAME}}_DB_USER }}" >> {{app_name}}/.env
          echo "DB_PASSWORD=${{ secrets.{{APP_NAME}}_DB_PASSWORD }}" >> {{app_name}}/.env
          echo "API_KEY=${{ secrets.{{APP_NAME}}_API_KEY }}" >> {{app_name}}/.env

      # Log in to GitHub Container Registry
      - name: Log in to GitHub Container Registry
        run: echo "${{ secrets.GHCR_TOKEN }}" | docker login ghcr.io -u ${{ github.repository

_owner }} --password-stdin

      # Run Unit Tests
      - name: Run Unit Tests
        run: |
          IMAGE_NAME=ghcr.io/${{ github.repository_owner }}/{{app_name}}
          docker run --env-file {{app_name}}/.env $IMAGE_NAME swift test --disable-sandbox

  integration-test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      # Set up Docker Buildx
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      # Set up environment variables for the app
      - name: Set up .env file
        run: |
          echo "DB_HOST=${{ secrets.{{APPNAME}}_DB_HOST }}" >> {{app_name}}/.env
          echo "DB_USER=${{ secrets.{{APPNAME}}_DB_USER }}" >> {{app_name}}/.env
          echo "DB_PASSWORD=${{ secrets.{{APPNAME}}_DB_PASSWORD }}" >> {{app_name}}/.env
          echo "API_KEY=${{ secrets.{{APPNAME}}_API_KEY }}" >> {{app_name}}/.env

      # Log in to GitHub Container Registry
      - name: Log in to GitHub Container Registry
        run: echo "${{ secrets.GHCR_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin

      # Run Integration Tests
      - name: Run Integration Tests
        run: |
          IMAGE_NAME=ghcr.io/${{ github.repository_owner }}/{{app_name}}
          docker run --env-file {{app_name}}/.env $IMAGE_NAME swift test --filter IntegrationTests --disable-sandbox

  end-to-end-test:
    needs: integration-test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      # Set up Docker Buildx
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      # Set up environment variables for the app
      - name: Set up .env file
        run: |
          echo "DB_HOST=${{ secrets.{{APPNAME}}_DB_HOST }}" >> {{app_name}}/.env
          echo "DB_USER=${{ secrets.{{APPNAME}}_DB_USER }}" >> {{app_name}}/.env
          echo "DB_PASSWORD=${{ secrets.{{APPNAME}}_DB_PASSWORD }}" >> {{app_name}}/.env
          echo "API_KEY=${{ secrets.{{APPNAME}}_API_KEY }}" >> {{app_name}}/.env

      # Log in to GitHub Container Registry
      - name: Log in to GitHub Container Registry
        run: echo "${{ secrets.GHCR_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin

      # Run End-to-End Tests
      - name: Run End-to-End Tests
        run: |
          IMAGE_NAME=ghcr.io/${{ github.repository_owner }}/{{app_name}}
          docker run --env-file {{app_name}}/.env $IMAGE_NAME swift test --filter EndToEndTests --disable-sandbox

  deploy:
    needs: [unit-test, integration-test, end-to-end-test]
    runs-on: ubuntu-latest
    steps:
      - name: Set up SSH
        uses: webfactory/ssh-agent@v0.5.3
        with:
          ssh-private-key: ${{ secrets.VPS_SSH_KEY }}

      - name: Deploy to VPS
        run: |
          ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
          cd /path/to/deployment/directory
          docker pull ghcr.io/${{ github.repository_owner }}/{{app_name}}
          docker stop {{app_name}} || true
          docker rm {{app_name}} || true
          docker run -d --env-file /path/to/env/file -p ${app_port}:${app_port} --name {{app_name}} ghcr.io/${{ github.repository_owner }}/{{app_name}}
          EOF

      - name: Verify Nginx and SSL Configuration
        run: |
          ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
          if ! systemctl is-active --quiet nginx; then
            echo

 "Nginx is not running"
            exit 1
          fi

          if ! openssl s_client -connect ${{ secrets.{{APPNAME}}_DOMAIN_NAME }}:443 -servername ${{ secrets.{{APPNAME}}_DOMAIN_NAME }} </dev/null 2>/dev/null | openssl x509 -noout -dates; then
            echo "SSL certificate is not valid"
            exit 1
          fi

          if ! curl -k https://${{ secrets.{{APPNAME}}_DOMAIN_NAME }} | grep -q "Expected content or response"; then
            echo "Domain is not properly configured"
            exit 1
          fi
          EOF
```

#### Directory Structure After Step 6

```plaintext
fountainai-project/
├── config.env
├── add_secrets.sh
├── .github/
│   └── workflows/
│       └── ci-cd-template.yml
```

#### Step 7: Create Script to Generate Workflows

Create a script named `generate_workflows.sh`:

```bash
#!/bin/bash

# Load configuration from config.env
source config.env

# Convert comma-separated app names to an array
IFS=',' read -r -a APP_NAMES_ARRAY <<< "$APP_NAMES"

# Create .github/workflows directory if it doesn't exist
mkdir -p .github/workflows

# Loop through app names and create each GitHub Actions workflow
for i in "${!APP_NAMES_ARRAY[@]}"; do
    app_name=${APP_NAMES_ARRAY[$i]}
    app_port=$((8080 + $i))

    # Replace placeholders in the template and create the workflow file
    sed -e "s/{{app_name}}/$app_name/g" \
        -e "s/{{APPNAME}}/$(echo $app_name | tr '[:lower:]' '[:upper:]')/g" \
        -e "s/{{app_port}}/$app_port/g" \
        ci-cd-template.yml > .github/workflows/ci-cd-$app_name.yml
done

echo "GitHub Actions workflows have been generated."
```

Make the script executable and run it:

```bash
chmod +x generate_workflows.sh
./generate_workflows.sh
```

#### Directory Structure After Step 7

```plaintext
fountainai-project/
├── config.env
├── add_secrets.sh
├── generate_workflows.sh
├── .github/
│   └── workflows/
│       ├── ci-cd-template.yml
│       ├── ci-cd-app1.yml
│       ├── ci-cd-app2.yml
│       ├── ci-cd-app3.yml
│       ├── ci-cd-app4.yml
│       ├── ci-cd-app5.yml
│       ├── ci-cd-app6.yml
│       ├── ci-cd-app7.yml
│       ├── ci-cd-app8.yml
│       ├── ci-cd-app9.yml
│       └── ci-cd-app10.yml
```

#### Step 8: Set up Nginx and SSL on the VPS for Each Vapor App

Create a script named `setup_nginx.sh` to automate the Nginx and SSL setup for each subdomain:

```bash
#!/bin/bash

# Load configuration from config.env
source config.env

# Install Nginx and Certbot on the VPS
ssh $VPS_USERNAME@$VPS_IP << EOF
sudo apt update
sudo apt install nginx certbot python3-certbot-nginx -y
EOF

# Configure Nginx and obtain SSL certificates for each subdomain
for i in "${!APP_NAMES_ARRAY[@]}"
do
    app_name=${APP_NAMES_ARRAY[$i]}
    port=$((8080 + $i))
    full_domain="${app_name}.${DOMAIN}"

    ssh $VPS_USERNAME@$VPS_IP << EOF
    sudo tee /etc/nginx/sites-available/${full_domain} > /dev/null <<EOL
server {
    listen 80;
    listen 443 ssl;
    server_name ${full_domain};

    ssl_certificate /etc/letsencrypt/live/${full_domain}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${full_domain}/privkey.pem;

    location / {
        proxy_pass http://localhost:${port};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

    sudo ln -s /etc/nginx/sites-available/${full_domain} /etc/nginx/sites-enabled/
    sudo systemctl reload nginx
    sudo certbot --nginx -d ${full_domain} --non-interactive --agree-tos -m your-email@example.com
    sudo systemctl reload nginx
EOF
done
```

Make the script executable and run it:

```bash
chmod +x setup_nginx.sh
./setup_nginx.sh
```

#### Directory Structure After Step 8

```plaintext
fountainai-project/
├── config.env
├── add_secrets.sh
├── generate_workflows.sh
├── setup_nginx.sh
├── .github/
│   └── workflows/
│       ├── ci-cd

-template.yml
│       ├── ci-cd-app1.yml
│       ├── ci-cd-app2.yml
│       ├── ci-cd-app3.yml
│       ├── ci-cd-app4.yml
│       ├── ci-cd-app5.yml
│       ├── ci-cd-app6.yml
│       ├── ci-cd-app7.yml
│       ├── ci-cd-app8.yml
│       ├── ci-cd-app9.yml
│       └── ci-cd-app10.yml
├── app1/
│   ├── .gitignore
│   ├── Package.swift
│   ├── README.md
│   ├── Sources/
│   └── Tests/
├── app2/
│   ├── .gitignore
│   ├── Package.swift
│   ├── README.md
│   ├── Sources/
│   └── Tests/
...
└── app10/
    ├── .gitignore
    ├── Package.swift
    ├── README.md
    ├── Sources/
    └── Tests/
```

### Final Setup Script

The final setup script will consolidate all the previous steps and ensure a seamless setup of the FountainAI project. This includes creating the Vapor applications, adding secrets, generating workflows, and setting up Nginx and SSL.

Create the `setup.sh` script:

```bash
#!/bin/bash

# Load configuration from config.env
source config.env

# Function to create main project directory
create_main_directory() {
    mkdir -p $MAIN_DIR
    cd $MAIN_DIR
}

# Function to create and initialize a new Vapor app
create_vapor_app() {
    local app_name=$1
    mkdir -p $app_name
    cd $app_name
    vapor new $app_name --branch=main --non-interactive
    cd ..
}

# Main function to set up the project
main() {
    create_main_directory

    # Create and initialize Vapor applications
    for app_name in $(echo $APP_NAMES | tr "," "\n"); do
        create_vapor_app $app_name
    done

    # Add secrets to GitHub
    ../add_secrets.sh

    # Generate GitHub Actions workflows
    ../generate_workflows.sh

    # Set up Nginx and SSL on the VPS
    ../setup_nginx.sh

    echo "Initial setup for FountainAI project is complete."
}

# Execute main function
main
```

Make the script executable and run it:

```bash
chmod +x setup.sh
./setup.sh
```

### Conclusion

By following these steps and using the provided scripts, you can automate the setup of the FountainAI project, including creating Vapor applications, configuring the VPS, setting up Nginx and SSL, and integrating everything into a CI/CD pipeline with GitHub Actions. This ensures that Docker manages the correct proxy by Nginx to Vapor apps running on distinct ports.

### Commit Message

```
feat: Automated setup for FountainAI project

- Added comprehensive step-by-step guide to automate the initial setup for all ten Vapor applications.
- Included security best practices and explanations for managing SSH keys and .env files.
- Created configuration file `config.env` to store necessary configuration variables.
- Added `add_secrets.sh` script to automate adding secrets to GitHub.
- Provided `ci-cd-template.yml` for GitHub Actions workflow templates.
- Added `generate_workflows.sh` script to generate GitHub Actions workflows for each application.
- Created `setup.sh` script to automate the creation of Vapor applications and generating workflows.
- Integrated Nginx and SSL setup directly into GitHub Actions workflows.
- Included directory structures at each step to help users visualize their progress.
- Explained how Docker and Nginx work together to ensure correct port mapping for Vapor apps.
```