#!/bin/bash

# Load configuration from config.env
source config.env

# Convert REPO_OWNER and APP_NAME to lowercase for Docker image naming
REPO_OWNER_LOWER=$(echo "$REPO_OWNER" | tr '[:upper:]' '[:lower:]')
APP_NAME_LOWER=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]')

# Debugging: Print loaded configuration
echo "Loaded configuration:"
echo "APP_NAME=$APP_NAME"
echo "REPO_OWNER_LOWER=$REPO_OWNER_LOWER"
echo "APP_NAME_LOWER=$APP_NAME_LOWER"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Ensure we are in the correct directory
if [ ! -d "$APP_NAME" ]; then
    echo "Error: Directory $APP_NAME does not exist."
    exit 1
fi

# Check for nested directory issue
if [ -d "$APP_NAME/$APP_NAME" ]; then
    echo "Nested $APP_NAME directory found. Navigating to $APP_NAME/$APP_NAME."
    cd $APP_NAME/$APP_NAME
else
    cd $APP_NAME
fi

# Debugging: Print current directory and list files
echo "Current directory: $(pwd)"
echo "Directory contents:"
ls -l

if [ ! -f Package.swift ]; then
    echo "Error: Package.swift not found in the current directory."
    exit 1
fi

# Create necessary directories if they don't exist
mkdir -p Public Resources

# Create Package.resolved if it doesn't exist
if [ ! -f Package.resolved ]; then
    swift package resolve
fi

# Navigate back to the main project directory to create the Dockerfile
cd ..

# Create Dockerfile for Vapor application
cat <<EOF > Dockerfile
# Stage 1: Build the application
FROM swift:latest as build

WORKDIR /app

# Copy only the Package.swift and resolve dependencies to cache these steps
COPY ./$APP_NAME/Package.swift ./
COPY ./$APP_NAME/Package.resolved ./

RUN swift package resolve

# Copy the entire project and build it
COPY ./$APP_NAME ./

RUN swift build --configuration release --disable-sandbox

# Stage 2: Create the final image
FROM swift:slim

WORKDIR /app

# Copy the built binary from the build stage
COPY --from=build /app/.build/release /app

# Copy the necessary configuration files, if any
COPY ./$APP_NAME/Public /app/Public
COPY ./$APP_NAME/Resources /app/Resources

# Expose the application port
EXPOSE 8080

# Start the application
CMD ["./Run", "serve", "--env", "production"]
EOF

# Build the Docker image
docker build -t ghcr.io/$REPO_OWNER_LOWER/$APP_NAME_LOWER .

# Log in to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u $REPO_OWNER_LOWER --password-stdin

# Push the Docker image to GitHub Container Registry
docker push ghcr.io/$REPO_OWNER_LOWER/$APP_NAME_LOWER
