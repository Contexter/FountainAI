#!/bin/bash

# Define ANSI color code variables for better readability in terminal outputs
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"  # No Color

# Function to prompt for user input
function prompt_for_input() {
    read -p "Please enter the domain to configure for Vapor: " new_domain
    read -p "Please enter the directory to create the Vapor app in (default /var/www/$new_domain): " app_directory
    app_directory=${app_directory:-/var/www/$new_domain}  # Default to /var/www/domain if no input
}

# Function to find an available port starting from 8080
function find_available_port() {
    local port=8080
    while true; do
        if ! netstat -tuln | grep -q ":$port "; then
            echo "Found available port: $port"
            vapor_port=$port
            break
        else
            ((port++))
        fi
    done
}

# Function to configure UFW to allow traffic on the Vapor port
function configure_ufw_firewall() {
    echo -e "${GREEN}Configuring UFW firewall to allow traffic on port $vapor_port...${NC}"
    sudo ufw allow $vapor_port/tcp
    echo -e "${GREEN}Firewall configured to allow traffic on port $vapor_port.${NC}"
}

# Function to create and setup the Vapor project
function create_vapor_project() {
    echo -e "${GREEN}Creating Vapor project in $app_directory...${NC}"
    mkdir -p $app_directory
    cd $app_directory
    vapor new --type=web --name=$new_domain  # Create new Vapor project
    cd $new_domain
    swift build -c release  # Build the project in release configuration
    echo -e "${GREEN}Vapor project created and built successfully.${NC}"
}

# Function to setup Vapor app as a systemd service
function setup_systemd_service() {
    local service_name="${new_domain//./_}"
    echo -e "${GREEN}Setting up systemd service for $new_domain...${NC}"
    sudo cat > /etc/systemd/system/$service_name.service <<EOF
[Unit]
Description=Vapor Application
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=$app_directory/$new_domain
ExecStart=/usr/bin/swift run -c release --hostname 0.0.0.0 --port $vapor_port
Restart=always
Environment="VAPOR_ENV=production"

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable $service_name
    sudo systemctl start $service_name
    echo -e "${GREEN}Systemd service configured and started.${NC}"
}

# Function to update Nginx configuration for Vapor
function update_nginx_for_vapor() {
    echo -e "${GREEN}Updating Nginx configuration for the Vapor app on $new_domain...${NC}"
    local vhost_file="/etc/nginx/sites-available/$new_domain"
    sudo cat > $vhost_file <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $new_domain www.$new_domain;

    location / {
        proxy_pass http://localhost:$vapor_port;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $new_domain www.$new_domain;

    ssl_certificate /etc/letsencrypt/live/$new_domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$new_domain/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://localhost:$vapor_port;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

    sudo nginx -t && sudo systemctl reload nginx
    echo -e "${GREEN}Nginx configuration updated successfully.${NC}"
}

# Main function to orchestrate setup
function main() {
    prompt_for_input
    find_available_port
    configure_ufw_firewall
    create_vapor_project
    setup_systemd_service
    update_nginx_for_vapor
    echo -e "${GREEN}Vapor project setup is complete.${NC}"
}

# Call main function to execute the script
main

