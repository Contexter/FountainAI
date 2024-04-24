#!/bin/bash

# This script installs the Vapor toolbox by cloning the official GitHub repository.

# Install git, make, and any necessary dependencies
install_dependencies() {
    echo "Installing git, make, and necessary build dependencies..."
    sudo apt-get update
    sudo apt-get install -y git build-essential
}

# Clone Vapor toolbox repository and install a specific version
clone_and_install_vapor() {
    echo "Cloning Vapor toolbox repository..."
    git clone https://github.com/vapor/toolbox.git
    cd toolbox

    # Checkout version 18.7.5
    echo "Checking out version 18.7.5..."
    git checkout 18.7.5

    # Install Vapor Toolbox
    echo "Installing Vapor Toolbox..."
    make install
}

# Verify the installation by checking the Vapor version
verify_installation() {
    echo "Verifying Vapor installation..."
    vapor --version
}

# Run the functions
install_dependencies
clone_and_install_vapor
verify_installation
