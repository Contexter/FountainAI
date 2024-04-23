#!/bin/bash

# Save this script as '01_basic_server_setup.sh' and make it executable:
# chmod +x setup_server.sh
# Run the script using:
# ./01_basic_server_setup.sh

# Define color codes for output to enhance readability
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"  # No Color

# Start by updating the system and installing necessary packages
echo -e "${GREEN}Starting system update and essential setup...${NC}"
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y nginx curl wget gnupg software-properties-common ufw

# Function to configure Nginx
function setup_nginx {
    echo -e "${GREEN}Configuring Nginx...${NC}"
    # Check if Nginx is installed and install it if it's not already installed
    if ! command -v nginx > /dev/null; then
        sudo apt-get install -y nginx
        echo "Nginx installed."
    else
        echo "Nginx is already installed."
    fi

    # Create a simple HTML file to confirm Nginx is serving pages correctly
    echo "<html>
          <head><title>Nginx Setup Verification</title></head>
          <body><h1>If you see this page, Nginx is working correctly.</h1></body>
          </html>" | sudo tee /var/www/html/index.html
}

# Function to configure SSL using Certbot
function setup_ssl {
    echo -e "${GREEN}Configuring SSL with Certbot for Nginx...${NC}"
    sudo apt-get install -y certbot python3-certbot-nginx
    read -p "Enter the domain name for SSL configuration: " domain
    read -p "Enter your email address for urgent renewal and security notices: " email

    # Verify if the domain resolves to the correct IP address
    if ! ping -c 1 "$domain" &> /dev/null; then
        echo -e "${RED}Error: Domain does not resolve to the correct IP. Please check your DNS settings.${NC}"
        return 1
    fi

    # Configure SSL, handle errors gracefully
    if ! sudo certbot --nginx -d "$domain" --non-interactive --agree-tos --email "$email" --redirect --hsts; then
        echo -e "${RED}Certbot failed to configure SSL. Check domain settings and Certbot logs.${NC}"
        return 1
    fi
    echo -e "${GREEN}SSL configuration complete for $domain.${NC}"
}

# Function to set up UFW Firewall
function setup_firewall {
    echo -e "${GREEN}Setting up UFW Firewall...${NC}"
    sudo ufw default deny incoming
    sudo ufw allow ssh
    sudo ufw allow 'Nginx Full'
    sudo ufw enable --force
    echo "UFW Firewall configured: Nginx and SSH allowed."
}

# Run setup functions
setup_nginx
setup_ssl
setup_firewall

# Final verification message
echo -e "${GREEN}Please verify Nginx setup by accessing your server's IP or domain in your browser.${NC}"
echo -e "${GREEN}Server setup complete. Nginx, SSL, and Firewall are configured.${NC}"
