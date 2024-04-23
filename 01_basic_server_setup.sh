#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

echo -e "${GREEN}Starting system update and essential setup...${NC}"
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y nginx curl wget gnupg software-properties-common ufw

function setup_nginx {
    echo -e "${GREEN}Configuring Nginx and SSL...${NC}"
    if ! command -v nginx > /dev/null; then
        sudo apt-get install -y nginx
        echo "Nginx installed."
    else
        echo "Nginx is already installed."
    fi

    # Setup SSL with Certbot for Nginx
    sudo apt-get install -y certbot python3-certbot-nginx
    read -p "Enter the domain name for SSL configuration: " domain
    sudo certbot --nginx -d "$domain" --non-interactive --agree-tos --email "user@example.com" --redirect
    echo "SSL configuration complete for $domain."
}

function setup_firewall {
    echo -e "${GREEN}Setting up UFW Firewall...${NC}"
    sudo ufw allow 'Nginx Full'
    sudo ufw allow OpenSSH
    sudo ufw --force enable
    echo "UFW Firewall configured: Nginx and SSH allowed."
}

setup_nginx
setup_firewall

echo -e "${GREEN}Server setup complete. Nginx, SSL, and Firewall are configured.${NC}"
