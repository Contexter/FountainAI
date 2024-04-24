#!/bin/bash

# This script installs Vapor and the Vapor CLI on Ubuntu 20.04.

# Update system packages and install dependencies
update_and_install_dependencies() {
    echo "Updating system packages and installing necessary dependencies..."
    sudo apt-get update
    sudo apt-get install -y clang libicu-dev libatomic1 libcurl4 libxml2 zlib1g-dev libssl-dev pkg-config
}

# Add Vapor repository and install Vapor Toolbox
add_vapor_repository_and_install_toolbox() {
    echo "Adding Vapor repository..."
    wget -q https://repo.vapor.codes/apt/keyring.gpg -O- | sudo gpg --dearmor -o /usr/share/keyrings/vapor-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/vapor-archive-keyring.gpg] https://repo.vapor.codes/apt/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/vapor.list > /dev/null
    sudo apt-get update

    echo "Installing Vapor Toolbox..."
    sudo apt-get install -y vapor
}

# Verify the installation by checking the Vapor version
verify_installation() {
    echo "Verifying Vapor installation..."
    vapor --version
}

# Run the functions
update_and_install_dependencies
add_vapor_repository_and_install_toolbox
verify_installation
