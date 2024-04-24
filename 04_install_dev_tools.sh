#!/bin/bash

# Define ANSI color code variables for better readability in terminal outputs
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"  # No Color

# Check and install net-tools if not installed for netstat
if ! type netstat >/dev/null 2>&1; then
    echo -e "${GREEN}Installing net-tools...${NC}"
    sudo apt-get install -y net-tools
fi

# Function to install Swift using the specified version and URL
function install_swift() {
    echo -e "${GREEN}Installing Swift...${NC}"
    local swift_version="5.10"
    local swift_url="https://download.swift.org/swift-5.10-release/ubuntu2004/swift-5.10-RELEASE/swift-5.10-RELEASE-ubuntu20.04.tar.gz"
    wget "$swift_url" -O swift.tar.gz
    sudo tar xzf swift.tar.gz -C /usr --strip-components=1
    echo "export PATH=/usr/bin/swift:\$PATH" >> ~/.bash_profile
    source ~/.bash_profile
    if type swift >/dev/null 2>&1; then
        echo "Swift installed successfully."
    else
        echo -e "${RED}Swift installation failed.${NC}"
        exit 1
    fi
}

# Function to install Vapor CLI
function install_vapor() {
    echo -e "${GREEN}Installing Vapor CLI...${NC}"
    /bin/bash -c "$(curl -fsSL https://apt.vapor.sh)"
    if type vapor >/dev/null 2>&1; then
        echo "Vapor CLI installed successfully."
    else
        echo -e "${RED}Vapor CLI installation failed.${NC}"
        exit 1
    fi
}

# Main function to orchestrate the setup
function main() {
    install_swift
    install_vapor
    echo -e "${GREEN}All installations are complete.${NC}"
}

# Execute the main function to start the setup
main

