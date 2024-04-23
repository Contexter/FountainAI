#!/bin/bash

# Save this script as '04_setup_vapor_vhost.sh' and make it executable:
# chmod +x 04_setup_vapor_vhost.sh
# Run the script using:
# ./04_setup_vapor_vhost.sh

# Define color codes for output
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"  # No Color

# Function to prompt for user input
function prompt_for_input() {
    read -p "Please enter the domain to configure for Vapor: " new_domain
    read -p "Please enter the directory to create the Vapor app in (default /var/www/$new_domain): " app_directory
    app_directory=${app_directory:-/var/www/$new_domain}
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

# Function to create and setup the Vapor project
function create_vapor_project() {
    echo -e "${GREEN}Creating Vapor project in $app_directory...${NC}"
    mkdir -p $app_directory
    cd $app_directory
    vapor new --type=web --name=$new_domain
    cd $new_domain
    swift build -c release
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

    # Enable and start the service
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

   

 # Test and reload Nginx configuration
    sudo nginx -t && sudo systemctl reload nginx
}

# Main execution function
function main() {
    prompt_for_input
    find_available_port
    create_vapor_project
    setup_systemd_service
    update_nginx_for_vapor

    # Final confirmation message
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Vapor app and Nginx configuration completed successfully for $new_domain.${NC}"
        echo -e "${GREEN}You can verify the setup by accessing https://$new_domain in your browser.${NC}"
    else
        echo -e "${RED}Failed to setup Vapor app or Nginx configuration. Check the configurations and try again.${NC}"
        exit 1
    fi
}

# Call main function to execute the script
main
