#!/bin/bash

# This script fetches the Contexter/fountainAI repository from GitHub and makes all shell scripts (.sh) executable.

# Define the repository URL
REPO_URL="https://github.com/Contexter/fountainAI"

# Clone the repository
echo "Cloning the fountainAI repository from GitHub..."
git clone $REPO_URL

# Navigate to the cloned directory (assuming the repo name is the directory name)
cd fountainAI

# Find all .sh files and make them executable
echo "Making all .sh scripts executable..."
find . -type f -name "*.sh" -exec chmod +x {} \;

echo "All .sh scripts in the repository have been made executable."

