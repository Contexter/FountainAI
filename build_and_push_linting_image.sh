#!/bin/bash

# Load configuration from config.env
source config.env

# Verify the variable is set within the script
if [ -z "$G_TOKEN" ]; then
  echo "Error: G_TOKEN is not set."
  exit 1
fi

# Convert repository owner and name to lowercase
REPO_OWNER_LOWER=$(echo "$REPO_OWNER" | tr '[:upper:]' '[:lower:]')
REPO_NAME_LOWER=$(echo "$REPO_NAME" | tr '[:upper:]' '[:lower:]')

# Navigate to the linting directory
if [ -d "linting" ]; then
  cd linting
else
  echo "Error: linting directory does not exist."
  exit 1
fi

# Check if Dockerfile exists
if [ -f "Dockerfile" ]; then
  echo "Dockerfile found. Proceeding with the build."
else
  echo "Error: Dockerfile not found in the linting directory."
  exit 1
fi

# Build the Docker image
docker build -t ghcr.io/$REPO_OWNER_LOWER/linting .

# Log in to GitHub Container Registry non-interactively
if echo "$G_TOKEN" | docker login ghcr.io -u "$REPO_OWNER_LOWER" --password-stdin; then
  echo "Successfully logged in to GitHub Container Registry."
else
  echo "Error: Failed to log in to GitHub Container Registry."
  exit 1
fi

# Push the Docker image to GitHub Container Registry
if docker push ghcr.io/$REPO_OWNER_LOWER/linting; then
  echo "Successfully pushed the Docker image to GitHub Container Registry."
else
  echo "Error: Failed to push the Docker image to GitHub Container Registry."
  exit 1
fi

# Navigate back to the root directory
cd ..
