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
8. Run a comprehensive setup script to finalize the project setup.

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
for app_name in $(echo $APP_NAMES | tr "," "\n"); do
    upper_app_name=$(echo $app_name | tr '[:lower:]' '[:upper:]')

    create_github_secret "${upper_app_name}_DB_HOST" "<your_db_host>"
    create_github_secret "${upper_app_name}_DB_USER" "<your_db_user>"
    create_github_secret "${upper_app_name}_DB_PASSWORD" "<your_db_password>"
    create_github_secret "${upper_app_name}_API_KEY" "<your_api_key>"
    create_github_secret "${upper_app_name}_GHCR_TOKEN" "$GITHUB_TOKEN"
    create_github_secret "${upper_app_name}_VPS_SSH_KEY" "$VPS_SSH_KEY"
    create_github_secret "${upper_app_name}_VPS_USERNAME" "$VPS_USERNAME"
    create_github_secret "${upper_app_name}_VPS_IP" "$VPS_IP"
    create_github_secret "${upper_app_name}_DOMAIN_NAME" "<your_domain_name>"
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

Create a template for GitHub Actions workflow files. This will automate the CI/CD pipeline for each application.

1. **Example Workflow File**:

Create a file named `ci-cd-template.yml` under `.github/workflows/`:

```yaml
name: CI/CD Pipeline for {{app_name}}

on:
  push:
    paths:
      - '{{app_name}}/**'
      - '.github/workflows/ci-cd-{{app_name}}.yml'

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Set up .env file
        run: |
          echo "DB_HOST=${{ secrets.{{APP_NAME}}_DB_HOST }}" >> {{app_name}}

/.env
          echo "DB_USER=${{ secrets.{{APP_NAME}}_DB_USER }}" >> {{app_name}}/.env
          echo "DB_PASSWORD=${{ secrets.{{APP_NAME}}_DB_PASSWORD }}" >> {{app_name}}/.env
          echo "API_KEY=${{ secrets.{{APP_NAME}}_API_KEY }}" >> {{app_name}}/.env

      - name: Log in to GitHub Container Registry
        run: echo "${{ secrets.GHCR_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin

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

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Set up .env file
        run: |
          echo "DB_HOST=${{ secrets.{{APP_NAME}}_DB_HOST }}" >> {{app_name}}/.env
          echo "DB_USER=${{ secrets.{{APP_NAME}}_DB_USER }}" >> {{app_name}}/.env
          echo "DB_PASSWORD=${{ secrets.{{APP_NAME}}_DB_PASSWORD }}" >> {{app_name}}/.env
          echo "API_KEY=${{ secrets.{{APP_NAME}}_API_KEY }}" >> {{app_name}}/.env

      - name: Log in to GitHub Container Registry
        run: echo "${{ secrets.GHCR_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin

      - name: Run Unit Tests
        run: |
          IMAGE_NAME=ghcr.io/${{ github.repository_owner }}/{{app_name}}
          docker run --env-file {{app_name}}/.env $IMAGE_NAME swift test --disable-sandbox

  integration-test:
    needs: build
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Set up .env file
        run: |
          echo "DB_HOST=${{ secrets.{{APP_NAME}}_DB_HOST }}" >> {{app_name}}/.env
          echo "DB_USER=${{ secrets.{{APP_NAME}}_DB_USER }}" >> {{app_name}}/.env
          echo "DB_PASSWORD=${{ secrets.{{APP_NAME}}_DB_PASSWORD }}" >> {{app_name}}/.env
          echo "API_KEY=${{ secrets.{{APP_NAME}}_API_KEY }}" >> {{app_name}}/.env

      - name: Log in to GitHub Container Registry
        run: echo "${{ secrets.GHCR_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin

      - name: Run Integration Tests
        run: |
          IMAGE_NAME=ghcr.io/${{ github.repository_owner }}/{{app_name}}
          docker run --env-file {{app_name}}/.env $IMAGE_NAME swift test --filter IntegrationTests --disable-sandbox

  end-to-end-test:
    needs: integration-test
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Set up .env file
        run: |
          echo "DB_HOST=${{ secrets.{{APP_NAME}}_DB_HOST }}" >> {{app_name}}/.env
          echo "DB_USER=${{ secrets.{{APP_NAME}}_DB_USER }}" >> {{app_name}}/.env
          echo "DB_PASSWORD=${{ secrets.{{APP_NAME}}_DB_PASSWORD }}" >> {{app_name}}/.env
          echo "API_KEY=${{ secrets.{{APP_NAME}}_API_KEY }}" >> {{app_name}}/.env

      - name: Log in to GitHub Container Registry
        run: echo "${{ secrets.GHCR_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin

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
          docker run -d --env-file /path/to/env/file -p 8080:8080 --name {{app_name}} ghcr.io/${{ github.repository_owner }}/{{app_name}}
          EOF

      - name: Verify Nginx and SSL Configuration
        run: |
          ssh ${{ secrets.VPS_USERNAME }}@${{ secrets.VPS_IP }} << 'EOF'
          if ! systemctl is-active --quiet nginx; then
            echo "Nginx is not running"
            exit 1
          fi

          if ! openssl s_client -connect ${{ secrets.{{APP_NAME}}_DOMAIN_NAME }}:443 -servername ${{ secrets.{{APP_NAME}}_DOMAIN_NAME }} </dev/null 2>/dev/null | openssl x509 -noout -dates; then
            echo "SSL certificate is not valid"
            exit 1
          fi

          if ! curl -k https://${{ secrets.{{APP_NAME}}_DOMAIN_NAME }} | grep -q "Expected content or response"; then
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

Create a script named `generate_workflows.sh` that will generate a workflow file for each application by replacing placeholders in the template:

```bash
#!/bin/bash

# Load configuration from config.env
source config.env

# Convert comma-separated app names to an array
IFS=',' read -r -a APP_NAMES_ARRAY <<< "$APP_NAMES"

# Create .github/workflows directory if it doesn't exist
mkdir -p .github/workflows

# Loop through app names and create each GitHub Actions workflow
for app_name in "${APP_NAMES_ARRAY[@]}"; do
    # Replace placeholders in the template and create the workflow file
    sed "s/{{app_name}}/$app_name/g; s/{{APP_NAME}}/$(echo $app_name | tr '[:lower:]' '[:upper:]')/g" ci-cd-template.yml > .github/workflows/ci-cd-$app_name.yml
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

### Step 8: Comprehensive Setup Script

This step involves running a final script that consolidates all previous steps and finalizes the project setup. This includes creating the Vapor applications, adding secrets, and generating workflows.

1. **Create the `setup.sh` Script**:

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

    #

 Add secrets to GitHub
    ../add_secrets.sh

    # Generate GitHub Actions workflows
    ../generate_workflows.sh

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

#### Directory Structure After Step 8

```plaintext
fountainai-project/
├── config.env
├── add_secrets.sh
├── generate_workflows.sh
├── setup.sh
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

### Conclusion

By following these detailed steps and using the provided scripts, you can automate the setup of the FountainAI project. This ensures a consistent and efficient setup process, allowing you to focus on developing and deploying your applications effectively. Always remember to manage your sensitive information responsibly and secure your environment variables properly.

### Commit Message
```
feat: Automated setup for FountainAI project

- Added comprehensive step-by-step guide to automate the initial setup for all ten Vapor applications.
- Included security best practices and explanations for managing SSH keys and .env files.
- Created configuration file `config.env` to store necessary configuration variables.
- Added `add_secrets.sh` script to automate adding secrets to GitHub.
- Provided `ci-cd-template.yml` for GitHub Actions workflow templates.
- Added `generate_workflows.sh` script to generate GitHub Actions workflows for each application.
- Created `setup.sh` script to automate the creation of Vapor applications, adding secrets, and generating workflows.
- Included directory structures at each step to help users visualize their progress.
```