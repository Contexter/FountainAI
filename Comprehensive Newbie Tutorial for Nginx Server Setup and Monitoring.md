### Comprehensive Newbie Tutorial for Nginx Server Setup and Monitoring

This tutorial covers the complete process of setting up a basic web server using Nginx, securing it with SSL certificates using Certbot, configuring the Uncomplicated Firewall (UFW), and monitoring the setup to ensure its operational status. This guide is designed for administrators new to server management or those who need a refresher on best practices.

---

### Script 1: Server Setup

This script will automate the process of setting up Nginx, configuring SSL with Let's Encrypt, and securing the server with UFW. Below are detailed explanations of each function and the steps to save and execute the script.

#### Server Setup Script: `setup_server.sh`

**Functions Explained:**

1. **`setup_nginx()`**:
   - **Purpose**: Installs and configures Nginx if it is not already installed. Also, creates a simple HTML file to verify that Nginx is serving content correctly.
   - **Operations**:
     - Checks if Nginx is installed, installs if necessary.
     - Creates and writes a verification HTML page to the default web directory.

2. **`setup_ssl()`**:
   - **Purpose**: Installs Certbot, requests an SSL certificate for the domain, and configures Nginx to use this SSL certificate.
   - **Operations**:
     - Installs Certbot and its Nginx plugin.
     - Prompts the user for the domain and email address to use for SSL certification.
     - Validates domain resolution via ping check.
     - Requests an SSL certificate and configures Nginx to use it.

3. **`setup_firewall()`**:
   - **Purpose**: Configures the UFW firewall to enhance server security by allowing only specific traffic.
   - **Operations**:
     - Sets the default policy to deny incoming connections.
     - Allows SSH and Nginx full profiles (HTTP and HTTPS traffic).
     - Enables UFW with these settings.

**Script Code**:

```bash
#!/bin/bash

# Save as 'setup_server.sh' and make executable using 'chmod +x setup_server.sh'
# Execute with './setup_server.sh'

# Define color codes for output
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"  # No Color

echo -e "${GREEN}Starting system update and essential setup...${NC}"
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y nginx curl wget gnupg software-properties-common ufw

function setup_nginx {
    echo -e "${GREEN}Configuring Nginx...${NC}"
    if ! command -v nginx > /dev/null; then
        sudo apt-get install -y nginx
        echo "Nginx installed."
    else
        echo "Nginx is already installed."
    fi

    echo "<html>
          <head><title>Nginx Setup Verification</title></head>
          <body><h1>If you see this page, Nginx is working correctly.</h1></body>
          </html>" | sudo tee /var/www/html/index.html
}

function setup_ssl {
    echo -e "${GREEN}Configuring SSL with Certbot for Nginx...${NC}"
    sudo apt-get install -y certbot python3-certbot-nginx
    read -p "Enter the domain name for SSL configuration: " domain
    read -p "Enter your email address for urgent renewal and security notices: " email

    if ! ping -c 1 "$domain" &> /dev/null; then
        echo -e "${RED}Error: Domain does not resolve to the correct IP. Please check your DNS settings.${NC}"
        return 1
    fi

    sudo certbot --nginx -d "$domain" --non-interactive --agree-tos --email "$email" --redirect --hsts
    echo -e "${GREEN}SSL configuration complete for $domain.${NC}"
}

function setup_firewall {
    echo -e "${GREEN}Setting up UFW Firewall...${NC}"
    sudo ufw default deny incoming
    sudo ufw allow ssh
    sudo ufw allow 'Nginx Full'
    sudo ufw enable --force
    echo "UFW Firewall configured: Nginx and SSH allowed."
}

setup_nginx
setup_ssl
setup_firewall

echo -e "${GREEN}Please verify Nginx setup by accessing your server's IP or domain in your browser.${NC}"
echo -e "${GREEN}Server setup complete. Nginx, SSL, and Firewall are configured.${NC}"
```

---

### Script 2: Server Monitoring

This script will check the operational status of the server, ensuring Nginx is running, serving the correct content, and that the SSL certificate is valid.

#### Server Monitoring Script: `monitor_server.sh`

**Functions Explained:

**

1. **`check_nginx()`**:
   - **Purpose**: Checks if the Nginx service is active and running.
   - **Operations**: Uses `systemctl` to verify Nginx's service status.

2. **`check_web_server()`**:
   - **Purpose**: Verifies that the Nginx server is serving the expected HTML content.
   - **Operations**: Uses `curl` to fetch the homepage and checks its content.

3. **`verify_ssl_certificate()`**:
   - **Purpose**: Confirms the SSL certificate's validity and prints its expiration date.
   - **Operations**: Uses `openssl` to connect to the server, retrieves the SSL certificate, and checks its expiration date.

**Script Code**:

```bash
#!/bin/bash

# Save as 'monitor_server.sh' and make executable using 'chmod +x monitor_server.sh'
# Execute with './monitor_server.sh'

# Define color codes
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"  # No Color

# Ask the user for the domain name
read -p "Please enter the domain you want to monitor: " domain

echo -e "${GREEN}Starting server monitoring checks for $domain...${NC}"

function check_nginx {
    echo "Checking Nginx service status..."
    if systemctl is-active --quiet nginx; then
        echo -e "${GREEN}Nginx is running.${NC}"
    else
        echo -e "${RED}Nginx is not running.${NC}"
        return 1
    fi
}

function check_web_server {
    echo "Checking web server response..."
    response=$(curl -s http://$domain)
    if [[ "$response" == *'Nginx is working correctly'* ]]; then
        echo -e "${GREEN}Web server is serving the expected content.${NC}"
    else
        echo -e "${RED}Web server content does not match expected.${NC}"
        return 1
    fi
}

function verify_ssl_certificate {
    echo "Verifying SSL certificate..."
    expiration_date=$(echo | openssl s_client -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
    if [ -z "$expiration_date" ]; then
        echo -e "${RED}SSL certificate is not found or an error occurred.${NC}"
        return 1
    else
        echo -e "${GREEN}SSL certificate is valid until $expiration_date.${NC}"
    fi
}

check_nginx
check_web_server
verify_ssl_certificate

if [ $? -eq 0 ]; then
    echo -e "${GREEN}All systems functional.${NC}"
else
    echo -e "${RED}One or more checks failed. Please investigate.${NC}"
    exit 1
fi
```

### Conclusion

These scripts are designed to be user-friendly and provide clear feedback on their operations. They are invaluable tools for new server administrators looking to automate essential tasks and ensure their server's operational integrity. Save these scripts on your server, make them executable as described, and run them according to the provided instructions to maintain a secure and efficient server environment.