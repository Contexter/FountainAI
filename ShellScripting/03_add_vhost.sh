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

# Function to configure Nginx without SSL initially
function setup_nginx_basic() {
    echo -e "${GREEN}Setting up basic Nginx config for $new_domain...${NC}"
    local vhost_file="/etc/nginx/sites-available/$new_domain"
    sudo touch $vhost_file
    sudo cat > $vhost_file <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $new_domain www.$new_domain;

    root /var/www/$new_domain/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    return 301 https://\$server_name\$request_uri;
}
EOF

    # Create root directory for the new domain and assign ownership
    sudo mkdir -p /var/www/$new_domain/html
    sudo chown -R www-data:www-data /var/www/$new_domain/html

    # Create a simple HTML file to confirm Nginx is serving pages correctly
    sudo cat > /var/www/$new_domain/html/index.html <<EOF
<html>
    <head><title>Welcome to $new_domain!</title></head>
    <body>
        <h1>Success! The basic $new_domain server block is working!</h1>
        <p>This page will soon be secured with SSL.</p>
    </body>
</html>
EOF

    # Enable the new vhost by creating a symbolic link
    sudo ln -s /etc/nginx/sites-available/$new_domain /etc/nginx/sites-enabled/

    # Test Nginx configuration without SSL
    sudo nginx -t && sudo systemctl reload nginx
}

# Function to configure SSL with Certbot
function setup_ssl() {
    echo -e "${GREEN}Configuring SSL with Certbot for $new_domain using email $user_email...${NC}"
    sudo certbot --nginx -d $new_domain -d www.$new_domain --non-interactive --redirect --agree-tos --email $user_email --hsts

    # Update Nginx config to include SSL details after Certbot has installed certificates
    local vhost_file="/etc/nginx/sites-available/$new_domain"
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

    # Reload Nginx to apply SSL configuration
    sudo nginx -t && sudo systemctl reload nginx
}

# Main execution function
function main() {
    prompt_for_input
    check_dns
    setup_nginx_basic
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
