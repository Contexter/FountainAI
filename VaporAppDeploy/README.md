# VaporAppDeploy

**VaporAppDeploy** is a Swift command-line utility designed to automate the setup, deployment, and continuous integration/continuous deployment (CI/CD) of a Vapor application using Docker, Nginx, and Let's Encrypt. This tool simplifies the process of preparing your Vapor project for production by creating necessary directories, setting up the project, building the application, generating configuration files, and deploying the project in a Dockerized environment. It also handles the generation and renewal of SSL certificates using Let's Encrypt, ensuring that your application is securely accessible over HTTPS. Additionally, VaporAppDeploy includes functionality to set up a CI/CD pipeline using GitHub Actions, enabling automated builds, tests, and deployments.

## Prerequisites

Before using the VaporAppDeploy tool, ensure you have the following installed on your system:

- Swift
- Docker
- Docker Compose
- Git

## Installation

1. Clone the repository:

    ```sh
    git clone <repository-url>
    cd vapor-app-deploy
    ```

2. Build the project:

    ```sh
    swift build -c release
    ```

## Configuration

The configuration is stored in `config/config.yaml`. Ensure this file is correctly set up before running the commands.

```yaml
# Example config.yaml
projectDirectory: "/path/to/your/project"
domain: "yourdomain.com"
email: "youremail@example.com"
database:
  host: "localhost"
  username: "postgres"
  password: "password"
  name: "scriptdb"
redis:
  host: "localhost"
  port: 6379
staging: 0
```


## Usage

Run the main command to see available subcommands:

```sh
swift run vaporappdeploy --help
```

### Available Commands

- `create-directories`: Create necessary directories for the project.
- `setup-vapor-project`: Set up the Vapor project using an OpenAPI specification.
- `build-vapor-app`: Build the Vapor application.
- `run-vapor-local`: Run the Vapor application locally.
- `create-docker-compose-file`: Create the Docker Compose file.
- `create-nginx-config-file`: Create the Nginx configuration file.
- `create-certbot-script`: Create the Certbot script.
- `setup-project`: Set up the entire project.
- `master-script`: Run the master script to set up and deploy the Vapor application.
- `setup-cicd-pipeline`: Set up the GitHub Actions CI/CD pipeline.

## Example Usage

1. **Create Necessary Directories**:
  
    ```sh
    swift run vaporappdeploy create-directories
    ```

2. **Set Up the Vapor Project Using OpenAPI**:

    ```sh
    swift run vaporappdeploy setup-vapor-project --project-directory /path/to/your/project --openapi-file /path/to/openapi.yaml
    ```

3. **Build the Vapor Application**:
   
    ```sh
    swift run vaporappdeploy build-vapor-app
    ```

4. **Run the Vapor Application Locally**:

    ```sh
    swift run vaporappdeploy run-vapor-local
    ```

5. **Create the Docker Compose File**:

    ```sh
    swift run vaporappdeploy create-docker-compose-file
    ```

6. **Create the Nginx Configuration File**:

    ```sh
    swift run vaporappdeploy create-nginx-config-file
    ```

7. **Create the Certbot Script**:

    ```sh
    swift run vaporappdeploy create-certbot-script
    ```

8. **Set Up the Entire Project**:

    ```sh
    swift run vaporappdeploy setup-project
    ```

9. **Run the Master Script to Set Up and Deploy the Vapor Application**:

    ```sh
    swift run vaporappdeploy master-script
    ```

10. **Set Up the GitHub Actions CI/CD Pipeline**:

    ```sh
    swift run vaporappdeploy setup-cicd-pipeline
    ```

## CI/CD Pipeline Configuration

1. **Create a `.github/workflows` Directory** in the root of your project.
2. **Create a `ci-cd-pipeline.yml` File** inside the `.github/workflows` directory with the following content:

    ```yaml
    name: CI/CD Pipeline

    on:
      push:
        branches:
          - main

    jobs:
      build:
        runs-on: ubuntu-latest

        services:
          postgres:
            image: postgres:13
            env:
              POSTGRES_USER: postgres
              POSTGRES_PASSWORD: password
              POSTGRES_DB: scriptdb
            ports:
              - 5432:5432
            options: >-
              --health-cmd="pg_isready -U postgres"
              --health-interval=10s
              --health-timeout=5s
              --health-retries=5

          redis:
            image: redis:latest
            ports:
              - 6379:6379
            options: >-
              --health-cmd="redis-cli ping"
              --health-interval=10s
              --health-timeout=5s
              --health-retries=5

        steps:
          - name: Checkout code
            uses: actions/checkout@v2

          - name: Set up Swift
            uses: fwal/setup-swift@v1

          - name: Install dependencies
            run: swift package resolve

          - name: Build project
            run: swift build -c release

          - name: Run tests
            run: swift test

      deploy:
        runs-on: ubuntu-latest
        needs: build

        steps:
          - name: Checkout code
            uses: actions/checkout@v2

          - name: Set up Docker Buildx
            uses: docker/setup-buildx-action@v1

          - name: Log in to Docker Hub
            uses: docker/login-action@v1
            with:
              username: ${{ secrets.DOCKER_USERNAME }}
              password: ${{ secrets.DOCKER_PASSWORD }}

          - name: Build and push Docker image
            run: |
              docker build -t ${{ secrets.DOCKER_USERNAME }}/vapor-app:latest .
              docker push ${{ secrets.DOCKER_USERNAME }}/vapor-app:latest

          - name: Deploy to production
            run: |
              ssh -o StrictHostKeyChecking=no ${{ secrets.SSH_USER }}@${{ secrets.SSH_HOST }} << 'EOF'
                docker pull ${{ secrets.DOCKER_USERNAME }}/vapor-app:latest
                docker-compose -f /path/to/your/project/docker-compose.yml up -d
              EOF
    ```

## Adding Secrets to GitHub

You need to add the following secrets to your GitHub repository for the workflow to access:

1. `DOCKER_USERNAME`: Your Docker Hub username.
2. `DOCKER_PASSWORD`:

 Your Docker Hub password.
3. `SSH_USER`: The SSH user for your production server.
4. `SSH_HOST`: The hostname or IP address of your production server.

## Conclusion

By integrating this CI/CD pipeline with GitHub Actions, we automate the build, test, and deployment process, ensuring that the Vapor application is always in a deployable state and that new features and bug fixes are delivered quickly to the production environment. This solution improves efficiency and enhances the reliability and maintainability of the application.

