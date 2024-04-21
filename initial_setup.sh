#!/bin/bash

# This script, initial_setup.sh, prepares a fresh Ubuntu installation by updating all system packages
# to their latest versions, installing Git, and setting up UFW (Uncomplicated Firewall) to secure the system.
# It ensures that the system is up-to-date, that Git is available for version control tasks,
# and that basic firewall protection is configured.
#
# Git manual can be accessed via 'man git', and UFW manual can be accessed via 'man ufw'.
# The 'man' command (manual) is used to display the user manual of any command that can run on the terminal.
# It provides a detailed view of the command, including usage, options, and examples. To use 'man':
# - Type 'man <command>' to open the manual page for '<command>'.
# - Navigate using arrow keys, search with '/', and exit with 'q'.

# Define colors for pretty output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Helper function for printing status messages
function print_status() {
    echo -e "${GREEN}$1${NC}"
}

# Ensure running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Update system to the latest package versions
print_status "Updating system packages..."
apt-get update && apt-get upgrade -y

# Install Git
print_status "Installing Git..."
apt-get install git -y

# Install and configure UFW (Uncomplicated Firewall)
print_status "Installing UFW and setting up basic firewall rules..."
apt-get install ufw -y
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw enable

print_status "System update, Git installation, and UFW setup complete."

