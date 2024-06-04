## Introduction to FountainAI Project Setup Script

The FountainAI project involves developing multiple Vapor applications, each with its own requirements for building, testing, and deployment. Managing these applications individually can be time-consuming and error-prone. To streamline this process, we have created a setup script that automates the initial setup for all ten Vapor applications, including the Secrets Manager and Authentication Service, which are foundational to the project.

This script not only initializes each application but also configures a comprehensive CI/CD pipeline using GitHub Actions. This pipeline ensures that each application is built, tested, and deployed consistently and reliably.

### Background

Vapor is a popular web framework for Swift, and it provides built-in support for creating RESTful services, which makes it an excellent choice for the FountainAI project. To manage the lifecycle of each application efficiently, we use Docker for containerization and GitHub Actions for CI/CD automation. The goal is to set up an environment where every code change is automatically built, tested, and deployed with minimal manual intervention.

### Script Overview

The setup script performs the following tasks:

1. **Creates the Main Project Directory**: Initializes a directory to house all the applications.
2. **Creates Subdirectories and Initializes Vapor Applications**: Uses the `vapor new` command to create new Vapor applications in their respective directories.
3. **Creates GitHub Actions Workflows**: Configures a comprehensive CI/CD pipeline for each application, including steps for building Docker images, running unit, integration, and end-to-end tests, and deploying to a Virtual Private Server (VPS).

### Configuration File

The script reads necessary configuration variables from a file named `config.env`. This file should contain environment variables required for the setup, such as application names, GitHub Container Registry token, and VPS credentials.

### Configuration File: `config.env`

Create a file named `config.env` with the following content:

```ini
MAIN_DIR=fountainAI
APP_NAMES="secrets-manager,auth-service,app1,app2,app3,app4,app5,app6,app7,app8"
GHCR_TOKEN=<your-ghcr-token>
VPS_SSH_KEY=<your-vps-ssh-key>
VPS_USERNAME=<your-vps-username>
VPS_IP=<your-vps-ip>
```

### Setup Script: `setup.sh`

Save the following script as `setup.sh` in your desired directory.

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

### Detailed Explanation of the Script

1. **Loading Configuration**: The script starts by loading configuration variables from the `config.env` file. This includes the main project directory name, application names, and credentials for the GitHub Container Registry and VPS.

2. **Creating the Main Project Directory**: The `create_main_directory` function creates the main directory for the project and navigates into it.

3. **Creating and Initializing Vapor Applications**: The `create_vapor_app` function creates a subdirectory for each application and initializes a new Vapor application within it using the `vapor new` command. This ensures each application has a standard structure and necessary files, including the default Dockerfile provided by Vapor.

4. **Creating GitHub Actions Workflows**: The `create_workflow_file` function generates a comprehensive GitHub Actions workflow for each application. This workflow includes:
   - **Building the Docker Image**: The `build` job checks out the code, sets up Docker Buildx, creates an `.env` file with necessary environment variables, logs into the GitHub Container Registry, and builds and pushes the Docker image.
   - **Running Unit Tests**: The `unit-test` job runs unit tests inside the Docker container.
   - **Running Integration Tests**: The `integration-test` job runs integration tests inside the Docker container.
   - **Running End-to-End Tests**: The `end-to-end-test` job runs end-to-end tests inside the Docker container.
   - **Deploying to VPS**: The `deploy` job pulls the latest Docker image, stops and removes the old container, runs the new container, and verifies the Nginx and SSL configuration on the VPS.

5. **Executing the Main Function**: The `main` function orchestrates the entire setup process, creating the main directory, initializing each Vapor application, and generating the corresponding GitHub Actions workflows.

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

This setup script automates the initial configuration for all ten Vapor applications in the FountainAI project, including comprehensive CI/CD pipelines. By leveraging Docker and GitHub Actions, it ensures that each application is built, tested, and deployed consistently and reliably. This approach saves time, reduces manual errors, and enhances the overall efficiency of the development and deployment process.

### Commit Message

```markdown
feat: Initial setup for FountainAI project

- Created main project directory and subdirectories for each application.
- Initialized new Vapor applications for each app.
- Set up GitHub Actions workflows for CI/CD automation, including build, unit test, integration test, end-to-end test, and deployment steps.
- Added a configuration file for easy setup and management.
```