# Server Configuration Script Guide

## Overview

This guide explains how to use a Bash script for configuring an Nginx virtual host with SSL support on a Linux server. The script automates the process, setting up a new domain with HTTPS enabled, ensuring a secure and effective web hosting setup.

## Script Details

### Script Name
- **Filename**: `03_add_vhost.sh`

### Execution Permissions
Before running the script, you must make it executable with the following command:
```bash
chmod +x 03_add_vhost.sh
```

### Running the Script
Execute the script by entering:
```bash
./03_add_vhost.sh
```

## Function Descriptions

### `prompt_for_input`
**Purpose**: Gathers user input for the domain name and email address. These details are used to configure the domain and for SSL certificate notifications.

### `check_dns`
**Purpose**: Ensures the provided domain name resolves correctly. This step is crucial for the domain to point to the correct server IP address, affecting SSL configuration and site accessibility.

### `setup_nginx`
**Purpose**: Configures the Nginx server block for the specified domain. It includes setting up HTTP to HTTPS redirection, establishing the document root, and creating a basic HTML page to confirm that Nginx is serving pages correctly.

### `setup_ssl`
**Purpose**: Uses Certbot to secure the domain with an SSL certificate, enabling HTTPS for secure communications.

### `main`
**Purpose**: Orchestrates the execution of all functions in the appropriate sequence. It ensures each step is performed sequentially and checks the final status to confirm the setup's success.

## Usage Instructions

1. **Server Preparation**: Make sure that Nginx and Certbot are installed on your server.
2. **Script Preparation**: Download and prepare the script by setting the executable permission.
3. **Execute and Input**: Run the script and provide the required inputs when prompted.
4. **Monitor Outputs**: Watch the outputs carefully during execution. Errors will appear in red and successful operations in green.
5. **Verification**: After completion, verify the setup by accessing your domain with HTTPS in a web browser to ensure everything is configured correctly.

## Script Reprint

Here is the script to be used:

```bash
#!/bin/bash

# Save this script as '03_add_vhost.sh' and make it executable:
# chmod +x 03_add_vhost.sh
# Run the script using:
# ./03_add_vhost.sh

# Define color codes for output
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"  # No Color

# Function to prompt for user input
function prompt_for_input() {
    read -p "Please enter the new domain to configure: " new_domain
    read -p "Please enter your email for SSL notifications: " user_email
}

# Function to check DNS resolution
function check_dns() {
    if ! host $new_domain &> /dev/null; then
        echo -e "${RED}Error: Domain $new_domain does not resolve. Please check your DNS settings or domain name.${NC}"
        exit 1
    fi
}

# Function to configure Nginx
function setup_nginx() {
    echo -e "${GREEN}Configuring new Nginx vhost for $new_domain...${NC}"

    # Create Nginx server block file
    local vhost_file="/etc/nginx/sites-available/$new_domain"
    sudo touch $vhost_file
    sudo cat > $vhost_file <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $new_domain www.$new_domain;

    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name $new_domain www.$new_domain;

    ssl_certificate /etc/letsencrypt/live/$new_domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$new_domain/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    root /var/www/$new_domain/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

    # Create root directory for the new domain and assign ownership
    sudo mkdir -p /var/www/$new_domain/html
    sudo chown -R \$USER:\$USER /var/www/$new_domain/html

    # Create a simple HTML file to confirm Nginx is serving pages correctly
    sudo cat > /var/www/$new_domain/html/index.html <<EOF
<html>
    <head><title>Welcome to $new_domain!</title></head>
    <body>
        <h1>Success! The $new_domain server block is working!</h1>
        <

p>Hosted on $(hostname) with IP address $(hostname -I | cut -d' ' -f1)</p>
    </body>
</html>
EOF

    # Enable the new vhost by creating a symbolic link
    sudo ln -s /etc/nginx/sites-available/$new_domain /etc/nginx/sites-enabled/

    # Test Nginx configuration and restart service
    sudo nginx -t && sudo systemctl restart nginx
}

# Function to configure SSL
function setup_ssl() {
    echo -e "${GREEN}Configuring SSL with Certbot for $new_domain using email $user_email...${NC}"
    sudo certbot --nginx -d $new_domain -d www.$new_domain --non-interactive --redirect --agree-tos --email $user_email --hsts
}

# Main execution function
function main() {
    prompt_for_input
    check_dns
    setup_nginx
    setup_ssl

    # Final confirmation message
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}New vhost configuration and SSL setup completed successfully for $new_domain.${NC}"
        echo -e "${GREEN}You can verify the setup by accessing https://$new_domain in your browser.${NC}"
    else
        echo -e "${RED}Failed to configure new vhost or SSL. Check the configurations and try again.${NC}"
        exit 1
    fi
}

# Call main function to execute the script
main
```

This guide aims to provide a comprehensive, step-by-step understanding suitable for users new to server management.