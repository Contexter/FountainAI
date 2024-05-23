import Foundation
import ArgumentParser

/// Command to set up the GitHub Actions CI/CD pipeline.
struct SetupCiCdPipeline: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Set up the GitHub Actions CI/CD pipeline."
    )

    /// Execute the command to create the GitHub Actions workflow file.
    func run() {
        let workflowPath = ".github/workflows/ci-cd-pipeline.yml"
        let workflowContent = """
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
        """

        let fileManager = FileManager.default
        let workflowDirectory = ".github/workflows"
        if !fileManager.fileExists(atPath: workflowDirectory) {
            try! fileManager.createDirectory(atPath: workflowDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        try! workflowContent.write(toFile: workflowPath, atomically: true, encoding: .utf8)
        print("GitHub Actions CI/CD pipeline configuration created at \(workflowPath).")
    }
}

