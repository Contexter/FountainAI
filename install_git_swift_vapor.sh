#!/bin/bash

# This script ensures that Git, Swift, and the Vapor Toolbox are installed.
# It installs them only if they are not already installed or if the installed version needs to be updated.

# Function to check if a command exists.
# Usage: command_exists <command_name>
command_exists() {
  type "$1" &> /dev/null
}

# Function to install Git.
# It checks if Git is installed before attempting installation.
install_git() {
  if ! command_exists git; then
    echo "Installing Git..."
    apt-get update && apt-get install -y git
    if [ $? -eq 0 ]; then
      echo "Git installed successfully."
    else
      echo "Failed to install Git."
      exit 1
    fi
  else
    echo "Git is already installed."
  fi
}

# Function to install Swift using a curl command.
# It checks if Swift is installed before attempting installation.
install_swift() {
  if ! command_exists swift; then
    echo "Installing Swift..."
    curl -L https://swift-server.github.io/swiftly/swiftly-install.sh | bash
    if [ $? -eq 0 ]; then
      echo "Swift installed successfully."
    else
      echo "Failed to install Swift."
      exit 1
    fi
  else
    echo "Swift is already installed."
  fi
}

# Function to install the Vapor Toolbox.
# It clones the Vapor toolbox from GitHub, checks out a specific version, and installs it.
# It first checks if the desired version is already installed.
install_vapor_toolbox() {
  local vapor_toolbox_version="18.7.5"
  if ! command_exists vapor || [[ $(vapor --version) != *"$vapor_toolbox_version"* ]]; then
    echo "Installing or updating Vapor Toolbox to version $vapor_toolbox_version..."
    # Cleanup any previous toolbox directory
    [ -d "toolbox" ] && rm -rf toolbox

    # Clone, checkout the specific version, and install
    git clone https://github.com/vapor/toolbox.git
    cd toolbox
    git checkout $vapor_toolbox_version
    make install
    cd ..
    rm -rf toolbox
    echo "Vapor Toolbox installed or updated successfully."
  else
    echo "Vapor Toolbox version $vapor_toolbox_version is already installed."
  fi
}

# Main function to orchestrate the installation process.
main() {
  install_git
  install_swift
  install_vapor_toolbox
  echo "Installation process completed successfully."
}

# Entry point of the script.
main

