# Official CI/CD Pipeline of the FountainAI Project

This document describes the CI/CD (Continuous Integration/Continuous Deployment) pipeline for the FountainAI project, which ensures that our application is built, tested, and deployed consistently and reliably. The pipeline uses GitHub Actions for automation and Docker for containerization, with images stored in GitHub Container Registry (GHCR). Additionally, the pipeline includes checks to verify that the production environment meets the expected requirements, such as having an SSL-secured Nginx proxy.

## Introduction

The FountainAI project consists of multiple Vapor applications described by 9 OpenAPI documents. This guide details the setup of a CI/CD pipeline using GitHub Actions and Docker, managing environment variables through GitHub Secrets, and automating the deployment process to a VPS (Virtual Private Server).

### Overview of the Steps:

1. **Create a GitHub Repository**: If you haven't already, create a new GitHub repository for your Vapor applications.
2. **Generate Necessary Tokens and Keys**: Generate personal access tokens and SSH keys for secure access and deployments.
3. **Add Secrets to GitHub Repository**: Store environment variables and other sensitive information as GitHub Secrets.
4. **Set Up GitHub Actions Workflow**: Define the CI/CD workflow in a YAML configuration file.
5. **Automate Configuration Creation**: Use scripts to automate the setup and configuration.

## Step-by-Step Guide

### 1. Create a GitHub Repository

Create a new repository on GitHub to store your Vapor applications.

### 2. Generate Necessary Tokens and Keys

#### a. Personal Access Token for GHCR

1. Go to your GitHub account settings.
2. Navigate to **Developer settings** -> **Personal access tokens**.
3. Generate a new token with the following scopes:
   - `write:packages`
   - `read:packages`
   - `delete:packages`
   - `repo` (if you want to access private repositories)
4. Copy the token and save it securely.

#### b. SSH Key for VPS Access

1. Generate an SSH key pair on your local machine:
   ```sh
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```
2. Add the public key (`~/.ssh/id_ed25519.pub`) to the `~/.ssh/authorized_keys` file on your VPS.

### 3. Add Secrets to GitHub Repository

1. Go to your GitHub repository.
2. Navigate to **Settings** -> **Secrets and variables** -> **Actions**.
3. Add the necessary environment variables for each Vapor application as secrets. For example, for `app1`, add:
   - **`APP1_DB_HOST`**
   - **`APP1_DB_USER`**
   - **`APP1_DB_PASSWORD`**
   - **`APP1_API_KEY`**
   - **`APP1_GHCR_TOKEN`**
   - **`APP1_VPS_SSH_KEY`**
   - **`APP1_VPS_USERNAME`**
   - **`APP1_VPS_IP`**
   - **`APP1_DOMAIN_NAME`**

   Repeat these steps for each application (e.g., `APP2_DB_HOST`, `APP2_DB_USER`, etc.).

### 4. Set Up GitHub Actions Workflow

Add the following workflow configuration to your repository at `.github/workflows/ci-cd.yml`. This example covers two applications; you can expand it to all nine:

```yaml
name: CI/CD Pipeline for FountainAI

on:
  push:
    branches:
      - main

jobs:
  build-app1:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Create .env file for App1
        run: |
          echo "DB_HOST=${{ secrets.APP1_DB_HOST }}" >> .env
          echo "DB_USER=${{ secrets.APP1_DB_USER }}" >> .env
          echo "DB_PASSWORD=${{ secrets.APP1_DB_PASSWORD }}" >> .env
          echo "API_KEY=${{ secrets.APP1_API_KEY }}" >> .env

      - name: Log in to GitHub Container Registry for App1
        run: echo "${{ secrets.APP1_GHCR_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin

      - name: Build and Push Docker Image for App1
        run: |
          IMAGE_NAME=ghcr.io/${{ github.repository_owner }}/app1
          docker build -f Dockerfile.app1 -t $IMAGE_NAME .
          docker push $IMAGE_NAME

  unit-test-app1:
    needs: build-app1
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Create .env file for App1
        run: |
          echo "DB_HOST=${{ secrets.APP1_DB_HOST }}" >> .env
          echo "DB_USER=${{ secrets.APP1_DB_USER }}" >> .env
          echo "DB_PASSWORD=${{ secrets.APP1_DB_PASSWORD }}" >> .env
          echo "API_KEY=${{ secrets.APP1_API_KEY }}" >> .env

      - name: Log in to GitHub Container Registry for App1
        run: echo "${{ secrets.APP1_GHCR_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin

      - name: Run Unit Tests for App1
        run: |
          IMAGE_NAME=ghcr.io/${{ github.repository_owner }}/app1
          docker run --env-file .env $IMAGE_NAME swift test --disable-sandbox

  integration-test-app1:
    needs: build-app1
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Create .env file for App1
        run: |
          echo "DB_HOST=${{ secrets.APP1_DB_HOST }}" >> .env
          echo "DB_USER=${{ secrets.APP1_DB_USER }}" >> .env
          echo "DB_PASSWORD=${{ secrets.APP1_DB_PASSWORD }}" >> .env
          echo "API_KEY=${{ secrets.APP1_API_KEY }}" >> .env

      - name: Log in to GitHub Container Registry for App1
        run: echo "${{ secrets.APP1_GHCR_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin

      - name: Run Integration Tests for App1
        run: |
          IMAGE_NAME=ghcr.io/${{ github.repository_owner }}/app1
          docker run --env-file .env $IMAGE_NAME swift test --filter IntegrationTests --disable-sandbox

  end-to-end-test-app1:
    needs: integration-test-app1
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Create .env file for App1
        run: |
          echo "DB_HOST=${{ secrets.APP1_DB_HOST }}" >> .env
          echo "DB_USER=${{ secrets.APP1_DB_USER }}" >> .env
          echo "DB_PASSWORD=${{ secrets.APP1_DB_PASSWORD }}" >> .env
          echo "API_KEY=${{ secrets.APP1_API_KEY }}" >> .env

      - name: Log in to GitHub Container Registry for App1
        run: echo "${{ secrets.APP1_GHCR_TOKEN }}" | docker login ghcr.io -u ${{ github.repository_owner }} --password-stdin

      - name: Run End-to-End Tests for App1
        run: |
          IMAGE_NAME=ghcr.io/${{ github.repository_owner }}/app1
          docker run --env-file .env $IMAGE_NAME swift test --filter EndToEndTests --disable-sandbox

  deploy-app1:
    needs: [unit-test-app1, integration-test-app1, end-to-end-test-app1]
    runs-on: ubuntu-latest

    steps:
      - name: Set up SSH for App1
        uses: webfactory/ssh-agent@v0.5.3
        with:
          ssh-private-key: ${{ secrets.APP1_VPS_SSH_KEY }}

      - name: Deploy Docker Image to VPS for App1
        run: |
          ssh ${{ secrets.APP1_VPS_USERNAME }}@${{ secrets.APP1_VPS_IP }} << 'EOF'
          IMAGE_NAME=ghcr.io/${{ github.repository_owner }}/app1
          docker pull $IMAGE_NAME
          docker stop app1 || true
          docker rm app1 || true
          docker run -d --env-file .env -p 8081:8080 --name app1 $IMAGE_NAME
          EOF

      - name: Verify Nginx and SSL Configuration for App1
        run: |
          ssh ${{ secrets.APP1_VPS_USERNAME }}@${{ secrets.APP1_VPS_IP }} << 'EOF'
          # Check if Nginx is running
          if ! systemctl is-active --quiet nginx; then
            echo "Nginx is not running"
            exit 1
          fi

          # Check if the SSL certificate is valid
          if ! openssl s_client -connect ${{ secrets.APP1_DOMAIN_NAME }}:443 -servername ${{ secrets.APP1_DOMAIN_NAME }} </dev/null 2>/dev/null | openssl x509 -noout -dates; then
            echo "SSL certificate is

 not valid"
            exit 1
          fi

          # Check if the domain is properly configured
          if ! curl -k https://${{ secrets.APP1_DOMAIN_NAME }} | grep -q "Expected content or response"; then
            echo "Domain is not properly configured"
            exit 1
          fi
          EOF

  # Repeat the above jobs for app2, app3, ... app9
```

### Explanation of the Workflow Configuration

### Triggers

- **`on: push`:** This specifies that the workflow should be triggered on push events to the `main` branch.

### Jobs

#### Build Job for App1

- **`runs-on: ubuntu-latest`:** This specifies that the job should run on the latest version of Ubuntu.
- **Steps:**
  - **Checkout Code:** Uses the `actions/checkout@v2` action to get the code from the repository.
  - **Set up Docker Buildx:** Uses the `docker/setup-buildx-action@v1` action to set up Docker Buildx for multi-platform builds.
  - **Create .env file for App1:** Uses secrets to create a `.env` file with the necessary environment variables.
  - **Log in to GHCR:** Logs in to GitHub Container Registry using a token stored in GitHub Secrets.
  - **Build and Push Docker Image:** Builds the Docker image and pushes it to GitHub Container Registry.

#### Unit Test Job for App1

- **`needs: build-app1`:** Specifies that this job depends on the `build-app1` job.
- **Steps:**
  - Similar setup steps as the build job.
  - **Create .env file for App1:** Uses secrets to create a `.env` file with the necessary environment variables.
  - **Run Unit Tests:** Runs unit tests inside the Docker container using the `.env` file.

#### Integration Test Job for App1

- **`needs: build-app1`:** Specifies that this job depends on the `build-app1` job.
- **Steps:**
  - Similar setup steps as the build job.
  - **Create .env file for App1:** Uses secrets to create a `.env` file with the necessary environment variables.
  - **Run Integration Tests:** Runs integration tests inside the Docker container using the `.env` file.

#### End-to-End Test Job for App1

- **`needs: integration-test-app1`:** Specifies that this job depends on the `integration-test-app1` job.
- **Steps:**
  - Similar setup steps as the build job.
  - **Create .env file for App1:** Uses secrets to create a `.env` file with the necessary environment variables.
  - **Run End-to-End Tests:** Runs end-to-end tests inside the Docker container using the `.env` file.

#### Deploy Job for App1

- **`needs: [unit-test-app1, integration-test-app1, end-to-end-test-app1]`:** Specifies that this job depends on the successful completion of the `unit-test-app1`, `integration-test-app1`, and `end-to-end-test-app1` jobs.
- **Steps:**
  - **Set up SSH:** Uses the `webfactory/ssh-agent@v0.5.3` action to set up SSH access to the VPS using a private key stored in GitHub Secrets.
  - **Deploy Docker Image to VPS:** SSH into the VPS, pull the Docker image, stop and remove the old container, and start a new container using the `.env` file for environment variables.
  - **Verify Nginx and SSL Configuration:** SSH into the VPS and verify the Nginx server and SSL configuration.

### Extending to More Applications

To handle all 9 applications, repeat the jobs for each application (app2, app3, ..., app9) by following the same pattern as above. Ensure each application's secrets and configurations are properly managed in GitHub Secrets.

### Automating the Configuration Creation

To automate the creation of the described configuration, we can use a script that generates the necessary secrets and the workflow file. Here's a sample script in Python to demonstrate the automation process:

```python
import os

# Define the applications and their secrets
apps = [
    {"name": "app1", "domain": "auth1.fountain.coach"},
    {"name": "app2", "domain": "auth2.fountain.coach"},
    # Add all other apps here...
]

# Generate the .env file content
def generate_env_content(app_name):
    return f"""DB_HOST=${{{app_name}_DB_HOST}}
DB_USER=${{{app_name}_DB_USER}}
DB_PASSWORD=${{{app_name}_DB_PASSWORD}}
API_KEY=${{{app_name}_API_KEY}}
"""

# Generate the job section for each app
def generate_job_section(app):
    app_name = app["name"]
    return f"""
  build-{app_name}:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Create .env file for {app_name}
        run: |
          echo "{generate_env_content(app_name)}" > .env

      - name: Log in to GitHub Container Registry for {app_name}
        run: echo "${{{app_name}_GHCR_TOKEN}}" | docker login ghcr.io -u ${{{{ github.repository_owner }}}} --password-stdin

      - name: Build and Push Docker Image for {app_name}
        run: |
          IMAGE_NAME=ghcr.io/${{{{ github.repository_owner }}}}/{app_name}
          docker build -f Dockerfile.{app_name} -t $IMAGE_NAME .
          docker push $IMAGE_NAME

  unit-test-{app_name}:
    needs: build-{app_name}
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Create .env file for {app_name}
        run: |
          echo "{generate_env_content(app_name)}" > .env

      - name: Log in to GitHub Container Registry for {app_name}
        run: echo "${{{app_name}_GHCR_TOKEN}}" | docker login ghcr.io -u ${{{{ github.repository_owner }}}} --password-stdin

      - name: Run Unit Tests for {app_name}
        run: |
          IMAGE_NAME=ghcr.io/${{{{ github.repository_owner }}}}/{app_name}
          docker run --env-file .env $IMAGE_NAME swift test --disable-sandbox

  integration-test-{app_name}:
    needs: build-{app_name}
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Create .env file for {app_name}
        run: |
          echo "{generate_env_content(app_name)}" > .env

      - name: Log in to GitHub Container Registry for {app_name}
        run: echo "${{{app_name}_GHCR_TOKEN}}" | docker login ghcr.io -u ${{{{ github.repository_owner }}}} --password-stdin

      - name: Run Integration Tests for {app_name}
        run: |
          IMAGE_NAME=ghcr.io/${{{{ github.repository_owner }}}}/{app_name}
          docker run --env-file .env $IMAGE_NAME swift test --filter IntegrationTests --disable-sandbox

  end-to-end-test-{app_name}:
    needs: integration-test-{app_name}
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Create .env file for {app_name}
        run: |
          echo "{generate_env_content(app_name)}" > .env

      - name: Log in to GitHub Container Registry for {app_name}
        run: echo "${{{app_name}_GHCR_TOKEN}}" | docker login ghcr.io -u ${{{{ github.repository_owner }}}} --password-stdin

      - name: Run End-to-End Tests for {app_name}
        run: |
          IMAGE_NAME=ghcr.io/${{{{ github.repository_owner }}}}/{app_name}
          docker run --env-file .env $IMAGE_NAME swift test --filter EndToEndTests --disable-sandbox

  deploy-{app_name}:
    needs: [unit-test-{app_name}, integration-test-{app_name}, end-to-end-test-{app_name}]
    runs-on: ubuntu-latest

    steps:
      - name: Set up SSH for {app_name}
        uses: webfactory/ssh-agent@v0.5.3
        with:
          ssh-private-key: "${{{app_name}_VPS_SSH_KEY}}"

      - name: Deploy Docker Image to VPS for {app_name}
        run: |
          ssh ${{{{app_name}_VPS_USERNAME}}}@${{{{app_name}_VPS_IP}}} << 'EOF'
          IMAGE_NAME=ghcr.io/${{{{ github.repository_owner }}}}/{app_name}
          docker pull $IMAGE_NAME
          docker stop {app_name} || true
          docker rm {app_name} || true
          docker run -d --env-file .env -p 8080:8080 --name {app_name} $IMAGE_NAME
          EOF

      - name: Verify Nginx and SSL Configuration for {app_name}
        run: |
          ssh ${{{{app_name}_V

PS_USERNAME}}}@${{{{app_name}_VPS_IP}}} << 'EOF'
          if ! systemctl is-active --quiet nginx; then
            echo "Nginx is not running"
            exit 1
          fi

          if ! openssl s_client -connect ${{{{app_name}_DOMAIN_NAME}}}:443 -servername ${{{{app_name}_DOMAIN_NAME}}} </dev/null 2>/dev/null | openssl x509 -noout -dates; then
            echo "SSL certificate is not valid"
            exit 1
          fi

          if ! curl -k https://${{{{app_name}_DOMAIN_NAME}}} | grep -q "Expected content or response"; then
            echo "Domain is not properly configured"
            exit 1
          fi
          EOF
"""

# Generate the entire workflow file
workflow_content = """
name: CI/CD Pipeline for FountainAI

on:
  push:
    branches:
      - main

jobs:
"""
for app in apps:
    workflow_content += generate_job_section(app)

# Write the workflow file
os.makedirs(".github/workflows", exist_ok=True)
with open(".github/workflows/ci-cd.yml", "w") as workflow_file:
    workflow_file.write(workflow_content)

print("CI/CD workflow configuration generated successfully.")
```

### Summary

By following this guide, you can set up a robust CI/CD pipeline for the entire FountainAI project, ensuring high-quality, secure, and reliable software delivery for all your Vapor applications. The automation script provided helps streamline the configuration process, making it easier to manage multiple applications and their respective environments.