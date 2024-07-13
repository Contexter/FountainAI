#!/bin/bash

# Load configuration from config.env
source config.env

# Navigate to the directory containing the Vapor app
cd "$APP_NAME"

# Convert repository owner and app name to lowercase
REPO_OWNER_LOWER=$(echo "$REPO_OWNER" | tr '[:upper:]' '[:lower:]')
APP_NAME_LOWER=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]')

# Build the Docker image
docker build -t ghcr.io/$REPO_OWNER_LOWER/$APP_NAME_LOWER .

# Log in to GitHub Container Registry
echo $G_TOKEN | docker login ghcr.io -u $REPO_OWNER_LOWER --password-stdin

# Push the Docker image to GitHub Container Registry
docker push ghcr.io/$REPO_OWNER_LOWER/$APP_NAME_LOWER

# Navigate back to the root directory
cd ..
