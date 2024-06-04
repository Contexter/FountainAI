## Introduction to FountainAI Project Setup and Configuration

The FountainAI project involves developing multiple Vapor applications, each with its own requirements for building, testing, and deployment. Managing these applications individually can be time-consuming and error-prone. To streamline this process, we have created a setup script that automates the initial setup for all ten Vapor applications, including the Secrets Manager and Authentication Service, which are foundational to the project.

This guide provides a comprehensive overview of the necessary manual and automated configurations required to get the FountainAI project up and running. By leveraging GitHub's API, we can automate many of the repetitive tasks, ensuring a consistent and efficient setup process.

### Background

Vapor is a popular web framework for Swift, and it provides built-in support for creating RESTful services, which makes it an excellent choice for the FountainAI project. To manage the lifecycle of each application efficiently, we use Docker for containerization and GitHub Actions for CI/CD automation. The goal is to set up an environment where every code change is automatically built, tested, and deployed with minimal manual intervention.

### Overview of the Setup Process

To properly set up the FountainAI project, we need to:

1. Generate and add a GitHub Container Registry (GHCR) token.
2. Generate SSH keys for VPS access.
3. Add the public key to the VPS.
4. Add the private key to GitHub Secrets.
5. Add environment variables for each application to GitHub Secrets.
6. Configure GitHub Actions workflows for CI/CD automation.

### Manual Configurations

Some steps require manual intervention, such as generating tokens and SSH keys, and adding them to the appropriate places. Below is a detailed list of these manual steps.

#### 1. Generate and Add GitHub Container Registry (GHCR) Token

- **Generate a Personal Access Token**:
  1. Go to your GitHub account settings.
  2. Navigate to **Developer settings** -> **Personal access tokens**.
  3. Generate a new token with the following scopes:
     - `write:packages`
     - `read:packages`
     - `delete:packages`
     - `repo` (if you want to access private repositories)
  4. Copy the token.

- **Add GHCR Token to GitHub Secrets**:
  1. Go to your GitHub repository.
  2. Navigate to **Settings** -> **Secrets and variables** -> **Actions**.
  3. Add a new secret named `GHCR_TOKEN` and paste the copied token.

#### 2. Generate SSH Key for VPS Access

- **Generate an SSH Key Pair**:
  ```sh
  ssh-keygen -t ed25519 -C "your_email@example.com"
  ```
  This will generate a key pair at `~/.ssh/id_ed25519` and `~/.ssh/id_ed25519.pub`.

#### 3. Add Public Key to VPS

- **Copy the Public Key**:
  ```sh
  cat ~/.ssh/id_ed25519.pub
  ```
  - Log in to your VPS.
  - Add the public key to the `~/.ssh/authorized_keys` file on your VPS:
    ```sh
    echo "<public_key>" >> ~/.ssh/authorized_keys
    ```

### Automating Configurations via GitHub's API

To automate the addition of secrets and environment variables, we can use GitHub's API. This reduces manual effort and ensures consistency.

#### 4. Add Private Key to GitHub Secrets

- **Copy the Private Key**:
  ```sh
  cat ~/.ssh/id_ed25519
  ```

- **Add Private Key to GitHub Secrets via API**:
  - Use the GitHub API to add the private key as a secret.

#### 5. Add Environment Variables for Each Application to GitHub Secrets

- **Add Environment Variables to GitHub Secrets via API**:
  - Use the GitHub API to add the necessary environment variables for each application.

### Automate with GitHub's API

Below is a script to add secrets to GitHub using the API.

#### Script to Add Secrets via GitHub's API

1. **Prerequisites**:
   - Install `curl` if not already installed.
   - Ensure you have a GitHub personal access token with the required scopes.

2. **Script to Add Secrets**:

Create a script named `add_secrets.sh`:

```bash
#!/bin/bash

# Load configuration from config.env
source config.env

# GitHub repository details
REPO_OWNER=<your_github_username>
REPO_NAME=<your_repository_name>

# GitHub personal access token
GITHUB_TOKEN=<your_github_token>

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
create_github_secret "GHCR_TOKEN" "$GHCR_TOKEN"
create_github_secret "VPS_SSH_KEY" "$VPS_SSH_KEY"
create_github_secret "VPS_USERNAME" "$VPS_USERNAME"
create_github_secret "VPS_IP" "$VPS_IP"

# Add application-specific secrets
for app_name in "${APP_NAMES_ARRAY[@]}"; do
    upper_app_name=$(echo $app_name | tr '[:lower:]' '[:upper:]')

    create_github_secret "${upper_app_name}_DB_HOST" "<your_db_host>"
    create_github_secret "${upper_app_name}_DB_USER" "<your_db_user>"
    create_github_secret "${upper_app_name}_DB_PASSWORD" "<your_db_password>"
    create_github_secret "${upper_app_name}_API_KEY" "<your_api_key>"
    create_github_secret "${upper_app_name}_GHCR_TOKEN" "$GHCR_TOKEN"
    create_github_secret "${upper_app_name}_VPS_SSH_KEY" "$VPS_SSH_KEY"
    create_github_secret "${upper_app_name}_VPS_USERNAME" "$VPS_USERNAME"
    create_github_secret "${upper_app_name}_VPS_IP" "$VPS_IP"
    create_github_secret "${upper_app_name}_DOMAIN_NAME" "<your_domain_name>"
done

echo "Secrets have been added to GitHub repository."
```

3. **Run the Script**:

Make the script executable and run it:
```bash
chmod +x add_secrets.sh
./add_secrets.sh
```

### Summary of Manual and Automated Steps

1. **Generate and Add GHCR Token**:
   - **Manual**: Generate a personal access token and add it as the `GHCR_TOKEN` secret.

2. **Generate SSH Key for VPS Access**:
   - **Manual**: Generate an SSH key pair.

3. **Add Public Key to VPS**:
   - **Manual**: Copy the public key to the `~/.ssh/authorized_keys` file on the VPS.

4. **Add Private Key to GitHub Secrets**:
   - **Automated**: Use the provided script to add the private key as a `VPS_SSH_KEY` secret.

5. **Add Environment Variables for Each Application to GitHub Secrets**:
   - **Automated**: Use the provided script to add environment variables as secrets for each application.

6. **Configure GitHub Actions Workflows**:
   - **Automated**: Ensure workflow files are generated and placed in `.github/workflows` using the setup script.

### Comprehensive Setup Script

To automate the setup of the initial state for all ten Vapor applications, including configuring CI/CD workflows, use the following `setup.sh` script:

```bash
#!/bin/bash

# Load configuration from config.env
source config.env

# Convert comma-separated app names to an array
IFS=',' read -r -a APP_NAMES_ARRAY <<< "$APP_NAMES"

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

# Function to create a GitHub Actions workflow file for a Vapor app
create_workflow_file() {
    local app_name=$1
    local workflow_file=".github/workflows/ci-cd-${app_name}.yml"
    cat > $workflow_file <<EOL
name: CI/CD Pipeline for ${app_name}

on:
  push:
    paths:
      - '${app_name}/**'
      - '.github/workflows/ci-cd-${app_name}.yml'

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker

 Buildx
        uses: docker/setup-buildx-action@v1

      - name: Set up .env file
        run: |
          echo "DB_HOST=\${{ secrets.${app_name^^}_DB_HOST }}" >> ${app_name}/.env
          echo "DB_USER=\${{ secrets.${app_name^^}_DB_USER }}" >> ${app_name}/.env
          echo "DB_PASSWORD=\${{ secrets.${app_name^^}_DB_PASSWORD }}" >> ${app_name}/.env
          echo "API_KEY=\${{ secrets.${app_name^^}_API_KEY }}" >> ${app_name}/.env

      - name: Log in to GitHub Container Registry
        run: echo "\${{ secrets.GHCR_TOKEN }}" | docker login ghcr.io -u \${{ github.repository_owner }} --password-stdin

      - name: Build and Push Docker Image
        run: |
          cd ${app_name}
          IMAGE_NAME=ghcr.io/\${{ github.repository_owner }}/${app_name}
          docker build -t \$IMAGE_NAME .
          docker push \$IMAGE_NAME

  unit-test:
    needs: build
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Set up .env file
        run: |
          echo "DB_HOST=\${{ secrets.${app_name^^}_DB_HOST }}" >> ${app_name}/.env
          echo "DB_USER=\${{ secrets.${app_name^^}_DB_USER }}" >> ${app_name}/.env
          echo "DB_PASSWORD=\${{ secrets.${app_name^^}_DB_PASSWORD }}" >> ${app_name}/.env
          echo "API_KEY=\${{ secrets.${app_name^^}_API_KEY }}" >> ${app_name}/.env

      - name: Log in to GitHub Container Registry
        run: echo "\${{ secrets.GHCR_TOKEN }}" | docker login ghcr.io -u \${{ github.repository_owner }} --password-stdin

      - name: Run Unit Tests
        run: |
          IMAGE_NAME=ghcr.io/\${{ github.repository_owner }}/${app_name}
          docker run --env-file ${app_name}/.env \$IMAGE_NAME swift test --disable-sandbox

  integration-test:
    needs: build
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Set up .env file
        run: |
          echo "DB_HOST=\${{ secrets.${app_name^^}_DB_HOST }}" >> ${app_name}/.env
          echo "DB_USER=\${{ secrets.${app_name^^}_DB_USER }}" >> ${app_name}/.env
          echo "DB_PASSWORD=\${{ secrets.${app_name^^}_DB_PASSWORD }}" >> ${app_name}/.env
          echo "API_KEY=\${{ secrets.${app_name^^}_API_KEY }}" >> ${app_name}/.env

      - name: Log in to GitHub Container Registry
        run: echo "\${{ secrets.GHCR_TOKEN }}" | docker login ghcr.io -u \${{ github.repository_owner }} --password-stdin

      - name: Run Integration Tests
        run: |
          IMAGE_NAME=ghcr.io/\${{ github.repository_owner }}/${app_name}
          docker run --env-file ${app_name}/.env \$IMAGE_NAME swift test --filter IntegrationTests --disable-sandbox

  end-to-end-test:
    needs: integration-test
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Set up .env file
        run: |
          echo "DB_HOST=\${{ secrets.${app_name^^}_DB_HOST }}" >> ${app_name}/.env
          echo "DB_USER=\${{ secrets.${app_name^^}_DB_USER }}" >> ${app_name}/.env
          echo "DB_PASSWORD=\${{ secrets.${app_name^^}_DB_PASSWORD }}" >> ${app_name}/.env
          echo "API_KEY=\${{ secrets.${app_name^^}_API_KEY }}" >> ${app_name}/.env

      - name: Log in to GitHub Container Registry
        run: echo "\${{ secrets.GHCR_TOKEN }}" | docker login ghcr.io -u \${{ github.repository_owner }} --password-stdin

      - name: Run End-to-End Tests
        run: |
          IMAGE_NAME=ghcr.io/\${{ github.repository_owner }}/${app_name}
          docker run --env-file ${app_name}/.env \$IMAGE_NAME swift test --filter EndToEndTests --disable-sandbox

  deploy:
    needs: [unit-test, integration-test, end-to-end-test]
    runs-on: ubuntu-latest

    steps:
      - name: Set up SSH
        uses: webfactory/ssh-agent@v0.5.3
        with:
          ssh-private-key: \${{ secrets.VPS_SSH_KEY }}

      - name: Deploy to VPS
        run: |
          ssh \${{ secrets.VPS_USERNAME }}@\${{ secrets.VPS_IP }} << 'EOF'
          cd /path/to/deployment/directory
          docker pull ghcr.io/\${{ github.repository_owner }}/${app_name}
          docker stop ${app_name} || true
          docker rm ${app_name} || true
          docker run -d --env-file /path/to/env/file -p 8080:8080 --name ${app_name} ghcr.io/\${{ github.repository_owner }}/${app_name}
          EOF

      - name: Verify Nginx and SSL Configuration
        run: |
          ssh \${{ secrets.VPS_USERNAME }}@\${{ secrets.VPS_IP }} << 'EOF'
          if ! systemctl is-active --quiet nginx; then
            echo "Nginx is not running"
            exit 1
          fi

          if ! openssl s_client -connect \${{ secrets.${app_name^^}_DOMAIN_NAME }}:443 -servername \${{ secrets.${app_name^^}_DOMAIN_NAME }} </dev/null 2>/dev/null | openssl x509 -noout -dates; then
            echo "SSL certificate is not valid"
            exit 1
          fi

          if ! curl -k https://\${{ secrets.${app_name^^}_DOMAIN_NAME }} | grep -q "Expected content or response"; then
            echo "Domain is not properly configured"
            exit 1
          fi
          EOF
EOL
}

# Main function to set up the project
main() {
    create_main_directory

    # Create .github/workflows directory
    mkdir -p .github/workflows

    # Loop through app names and create each Vapor app and workflow
    for app_name in "${APP_NAMES_ARRAY[@]}"; do
        create_vapor_app $app_name
        create_workflow_file $app_name
    done

    echo "Initial setup for FountainAI project is complete."
}

# Execute main function
main
```

### How to Use the Script

1. **Save the Configuration File**: Save the configuration variables in a file named `config.env`.

2. **Save the Script**: Save the setup script as `setup.sh` in your desired directory.

3. **Make the Script Executable**: Run the following command to make the script executable:
   ```bash
   chmod +x setup.sh
   ```

4. **Run the Script**: Execute the script to set up your project:
   ```bash
   ./setup.sh
   ```

### Conclusion

By following these steps and using the provided scripts, you can automate most of the configuration required for setting up the FountainAI project. This approach ensures consistency and saves time, allowing you to focus on developing and deploying your applications effectively. The detailed guide and scripts will help you automate the setup of Vapor applications and configure a comprehensive CI/CD pipeline using GitHub Actions.

### Commit Message

```markdown
feat: Initial setup for FountainAI project

- Created main project directory and subdirectories for each application.
- Initialized new Vapor applications for each app.
- Set up GitHub Actions workflows for CI/CD automation, including build, unit test, integration test, end-to-end test, and deployment steps.
- Added a configuration file for easy setup and management.
- Provided scripts to automate the addition of secrets via GitHub's API.
```