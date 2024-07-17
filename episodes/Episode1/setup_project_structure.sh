#!/bin/bash

# Create the .github directory if it doesn't exist
mkdir -p .github

# Create subdirectories for workflows and custom actions
mkdir -p .github/workflows
mkdir -p .github/actions/manage-secrets
mkdir -p .github/actions/setup
mkdir -p .github/actions/build
mkdir -p .github/actions/test
mkdir -p .github/actions/deploy

# Create a placeholder README.md inside the .github directory
echo "# GitHub Actions Project" > .github/README.md

echo "Project structure set up successfully!"
