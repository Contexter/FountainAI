# Continuous Integration and Continuous Deployment (CI/CD)

**Continuous Integration (CI)** and **Continuous Deployment (CD)** are key practices in modern software development that aim to improve the quality, efficiency, and reliability of software releases. 

- **Continuous Integration (CI)**: This practice involves automatically building and testing the application whenever new code is committed to the version control system. This ensures that the code is always in a deployable state and helps catch bugs early in the development cycle.
  
- **Continuous Deployment (CD)**: This extends CI by automatically deploying the application to a production environment whenever the application passes all tests. This ensures that new features and bug fixes are delivered to users as quickly as possible.

### Laying the Groundwork for CI/CD Integration

The scripts provided in the initial setup automate the process of setting up, building, and deploying a Vapor application. They are designed to be modular and idempotent, meaning they can be run multiple times without causing adverse effects. This modularity and idempotency are essential qualities for CI/CD pipelines.

### Building a CI/CD Pipeline with GitHub Actions

Let's implement a CI/CD pipeline using GitHub Actions, a popular CI/CD tool that integrates seamlessly with GitHub repositories. We'll create a workflow that:

1. **Builds and tests the Vapor application** whenever code is pushed to the repository.
2. **Deploys the application** to a production environment if the tests pass successfully.

### GitHub Actions Workflow Configuration

1. **Create a `.github/workflows` directory** in the root of your project.
2. **Create a `ci-cd-pipeline.yml` file** inside the `.github/workflows` directory with the following content:

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

### Explanation of the CI/CD Workflow

1. **Trigger**: The workflow is triggered on any push to the `main` branch.
2. **Build Job**:
   - Runs on an Ubuntu machine.
   - Sets up PostgreSQL and Redis services using Docker.
   - Checks out the code from the repository.
   - Sets up Swift.
   - Installs dependencies, builds the project, and runs tests.
3. **Deploy Job**:
   - Runs on an Ubuntu machine.
   - Depends on the successful completion of the build job.
   - Checks out the code from the repository.
   - Sets up Docker Buildx for building multi-platform Docker images.
   - Logs into Docker Hub using credentials stored in GitHub Secrets.
   - Builds and pushes the Docker image to Docker Hub.
   - SSH into the production server and deploys the latest Docker image using Docker Compose.

### Adding Secrets to GitHub

You need to add the following secrets to your GitHub repository for the workflow to access:

1. `DOCKER_USERNAME`: Your Docker Hub username.
2. `DOCKER_PASSWORD`: Your Docker Hub password.
3. `SSH_USER`: The SSH user for your production server.
4. `SSH_HOST`: The hostname or IP address of your production server.

### Conclusion

By integrating this CI/CD pipeline with GitHub Actions, we automate the build, test, and deployment process, ensuring that the Vapor application is always in a deployable state and that new features and bug fixes are delivered quickly to the production environment. This solution not only improves efficiency but also enhances the reliability and maintainability of the application.
