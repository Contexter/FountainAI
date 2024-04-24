#!/bin/bash

# Save this script as '04_setup_dev_environment.sh' and make it executable:
# chmod +x 04_setup_dev_environment.sh
# Run the script using:
# ./04_setup_dev_environment.sh

# Define ANSI color code variables for better readability in terminal outputs
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"  # No Color, to reset the color after printing

# Function to check if Swift is already installed
function check_swift_installed() {
    if ! type swift >/dev/null 2>&1; then
        install_swift  # Call install_swift if Swift is not found
    else
        echo -e "${GREEN}Swift is already installed.${NC}"
    fi
}

# Function to install Swift if not already installed
function install_swift() {
    echo -e "${GREEN}Installing Swift...${NC}"
    local swift_version="5.3"
    local swift_url="https://download.swift.org/swift-${swift_version}-release/ubuntu2004/swift-${swift_version}-RELEASE/swift-${swift_version}-RELEASE-ubuntu2004.tar.gz"
    wget "$swift_url" -O swift.tar.gz  # Download Swift
    sudo tar xzf swift.tar.gz -C /usr --strip-components=1  # Extract it
    echo "export PATH=/usr/bin/swift:\$PATH" >> ~/.bash_profile  # Add Swift to PATH
    source ~/.bash_profile  # Reload bash profile
    echo "Swift installed successfully."
}

# Function to install Vapor CLI if it is not installed
function install_vapor() {
    echo -e "${GREEN}Installing Vapor CLI...${NC}"
    if ! command -v vapor > /dev/null; then
        /bin/bash -c "$(curl -fsSL https://get.vapor.sh)"  # Install Vapor CLI
        echo "Vapor CLI installed successfully."
    else
        echo "Vapor CLI is already installed."
    fi
}

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
    check_swift_installed
    install_vapor
    prompt_for_input
    find_available_port
    create_vapor_project
    setup_systemd_service
    update_nginx_for_vapor

    # Final confirmation message
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Development environment setup complete. Swift and Vapor CLI are ready for use.${NC}"
        echo -e "${GREEN}You can verify the setup by accessing https://$new_domain in your browser.${NC}"
    else
        echo -e "${RED}Failed to setup Vapor app or Nginx configuration. Check the configurations and try again.${NC}"
        exit 1
    fi
}

# Call main function to execute the script
main
