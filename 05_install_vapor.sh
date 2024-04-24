#!/bin/bash

# This script installs Vapor and the Vapor CLI on Ubuntu 20.04.

# Update system packages and install dependencies
update_and_install_dependencies() {
    echo "Updating system packages and installing necessary dependencies..."
    sudo apt-get update
    sudo apt-get install -y clang libicu-dev libatomic1 libcurl4 libxml2 zlib1g-dev libssl-dev pkg-config
}

# Install Vapor Toolbox using the official script
install_vapor_toolbox() {
    echo "Installing Vapor Toolbox..."
    eval "$(curl -sL https://apt.vapor.sh)"
    sudo apt-get install -y vapor
}

# Verify the installation by checking the Vapor version
verify_installation() {
    echo "Verifying Vapor installation..."
    vapor --version
}

# Run the functions
update_and_install_dependencies
install_vapor_toolbox
verify_installation
