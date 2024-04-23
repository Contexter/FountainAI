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
