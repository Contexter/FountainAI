### Comprehensive Documentation: Vapor Application Setup with Nginx and systemd

This documentation provides detailed guidance on setting up a Vapor application on a server configured with Nginx and managed by systemd. Below, we outline the script used for setting up the application, followed by a discussion on the elements of the setup that can be modified and those that are hardcoded.

#### **Setup Script: `04_setup_vapor_vhost.sh`**

Here is the script renamed to `04_setup_vapor_vhost.sh`. This script automates the setup of a Vapor application, configuring it to run as a system service and setting up Nginx as a reverse proxy.

```bash
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
```

#### **Modifiable and Hardcoded Elements Discussion**

In the setup described, there are elements that can be modified easily and others that are more static:

### **Modifiable Elements:**

- **Vapor Application Code**: You can freely update and redeploy the Vapor application code. This includes changes to routes, controllers, middleware, etc.
- **Nginx Configuration**: The server's reverse proxy settings, including the SSL configuration, server names, and proxy headers, can be adjusted to meet new requirements or optimize performance.
- **Systemd Service File**: Adjustments can be made to how the Vapor application is run, such as changing the user, tweaking environment variables, or modifying the restart policy.

### **Hardcoded Elements:**

- **Port Number**: Once set, changing the port number requires updates in both the Nginx configuration and the systemd service file. This might involve some manual steps unless automated through scripts.
- **Service and Directory Names**: Changes to service names or directory paths require updates across various configuration files and possibly scripts, affecting how easily these elements can be managed.

By understanding these modifiable and hardcoded elements, you can better manage and maintain your Vapor application's deployment, ensuring it remains responsive to the needs of your projects and environment.


### A list of system administration commands 

Here's a list of system administration commands organized according to the modifiable and hardcoded elements in the setup of a Vapor application, as discussed. These commands help in updating configurations and managing the service.

### **Modifiable Elements:**

1. **Vapor Application Code:**
   - **Rebuild the Application:**
     ```bash
     swift build -c release
     ```
   - **Restart the Systemd Service after Rebuilding:**
     ```bash
     sudo systemctl restart your_service_name.service
     ```

2. **Nginx Configuration:**
   - **Edit the Nginx Configuration File:**
     ```bash
     sudo nano /etc/nginx/sites-available/your_domain
     ```
   - **Test Nginx Configuration for Errors:**
     ```bash
     sudo nginx -t
     ```
   - **Reload Nginx to Apply Configuration Changes:**
     ```bash
     sudo systemctl reload nginx
     ```

3. **Systemd Service File:**
   - **Edit the Systemd Service File:**
     ```bash
     sudo nano /etc/systemd/system/your_service_name.service
     ```
   - **Reload Systemd to Apply Changes:**
     ```bash
     sudo systemctl daemon-reload
     ```
   - **Restart the Service:**
     ```bash
     sudo systemctl restart your_service_name.service
     ```
   - **Enable the Service to Start on Boot:**
     ```bash
     sudo systemctl enable your_service_name.service
     ```
   - **Disable the Service:**
     ```bash
     sudo systemctl disable your_service_name.service
     ```

### **Hardcoded Elements:**

1. **Port Number:**
   - **Change in Nginx Configuration File:**
     ```bash
     sudo nano /etc/nginx/sites-available/your_domain
     ```
   - **Change in Systemd Service File:**
     ```bash
     sudo nano /etc/systemd/system/your_service_name.service
     ```
   - **Reload Both Nginx and Systemd After Changes:**
     ```bash
     sudo nginx -t && sudo systemctl reload nginx
     sudo systemctl daemon-reload && sudo systemctl restart your_service_name.service
     ```

2. **Service and Directory Names:**
   - **Update the Directory Path in the Systemd Service File:**
     ```bash
     sudo nano /etc/systemd/system/your_service_name.service
     ```
   - **Update the Directory Path in Scripts or Application Code:**
     ```bash
     sudo nano path_to_your_script_or_code
     ```
   - **Reload or Restart Services After Changes:**
     ```bash
     sudo systemctl daemon-reload
     sudo systemctl restart your_service_name.service
     ```

### **General System Commands:**

- **Check the Status of a Systemd Service:**
  ```bash
  sudo systemctl status your_service_name.service
  ```
- **View Logs for a Systemd Service:**
  ```bash
  journalctl -u your_service_name.service
  ```

These commands allow system administrators to effectively manage and update the server and application configurations, ensuring that the Vapor application runs smoothly and remains secure and efficient. Adjust paths and service names as needed to fit your specific setup.