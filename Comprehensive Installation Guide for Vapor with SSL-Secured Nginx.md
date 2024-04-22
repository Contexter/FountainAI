# Comprehensive Installation Guide for Vapor with SSL-Secured Nginx

Welcome to the comprehensive installation guide for setting up a Vapor environment with SSL-secured Nginx on Ubuntu. This guide will walk you through the entire process, divided into four distinct phases. Each phase is designed to set up different components of the server and application environment, ensuring that each step builds upon the last and is easily manageable.

## Overview of Installation Phases

**Phase 1: Essential Server Setup**  
In this initial phase, we'll update the server, install Nginx, set up a firewall with UFW, and configure SSL using Certbot. This sets the foundation for a secure and functional server environment.

**Phase 2: Development Environment Setup**  
This phase focuses on installing the necessary development tools, including Swift and the Vapor CLI. These tools are essential for Vapor application development.

**Phase 3: Basic Application Setup and Initial Deployment**  
Here, we will create and configure a basic Vapor project and set up Nginx to serve this application over HTTPS.

**Phase 4: Advanced Application Configuration**  
The final phase involves setting up the Vapor application with detailed configurations such as database schemas, models, and migrations.

---

## Phase 1: Essential Server Setup
### Script Name: `01_basic_server_setup.sh`

```bash
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
```

**Making the script executable:**
```bash
chmod +x 01_basic_server_setup.sh
./01_basic_server_setup.sh
```

## Phase 2: Development Environment Setup
### Script Name: `02_development_setup.sh`

```bash
#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

echo -e "${GREEN}Installing development tools...${NC}"

function install_swift {
    echo -e "${GREEN}Installing Swift...${NC}"
    local swift_version="5.3"
    local swift_url="https://download.swift.org/swift-${swift_version}-release/ubuntu2004/swift-${swift_version}-RELEASE/swift-${swift_version}-RELEASE-ubuntu2004.tar.gz"
    wget "$swift_url" -O swift.tar.gz
    sudo tar xzf swift.tar.gz -C /usr --strip-components=1
    echo "export PATH=/usr/bin/swift:\$PATH" >> ~/.bash_profile
    source ~/.bash_profile
    echo "Swift installed successfully."
}

function install_vapor {
    echo -e "${GREEN}Installing Vapor CLI...${NC}"
    if ! command -v vapor > /dev/null; then
        /bin/bash -c "$(curl -fsSL https://get.vapor.sh)"
        echo "Vapor CLI installed successfully."
    else
        echo "Vapor CLI is already installed."
    fi
}

install_swift
install_vapor

echo -e "${GREEN}Development environment setup complete. Swift and Vapor CLI are ready for use.${NC}"
```

**Making the script executable:**
```bash
chmod +x 02_development_setup.sh
./02_development_setup.sh
```

## Phase 3: Basic Application Setup and Initial Deployment
### Script Name: `03_application_setup.sh`

```bash
#!/bin/bash

# Define project details
read -p "Enter your Vapor project name

: " project_name
read -p "Enter the Fully Qualified Domain Name (FQDN) for your project (e.g., example.com): " domain_name
project_dir="/var/www/$project_name"

# Setup project directory
if [ ! -d "$project_dir" ]; then
    mkdir -p "$project_dir"
    echo "Directory created at $project_dir"
fi

cd "$project_dir"

# Create and build Vapor project if not already created
if [ ! -f "Package.swift" ]; then
    vapor new . --template=api --fluent
    echo "New Vapor project initialized."
    vapor build
    echo "Vapor project built successfully."
else
    echo "Vapor project already initialized."
fi

# Configure Nginx to proxy requests to Vapor
config_path="/etc/nginx/sites-available/$domain_name"
if [ ! -f "$config_path" ]; then
    cat > "$config_path" <<EOF
server {
    listen 443 ssl;
    server_name $domain_name;

    ssl_certificate /etc/letsencrypt/live/$domain_name/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain_name/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
    ln -s "$config_path" /etc/nginx/sites-enabled/
    sudo nginx -t && sudo systemctl restart nginx
    echo "Nginx configured for $project_name at $domain_name."
else
    echo "Nginx configuration already exists for $domain_name."
fi

echo "Phase 3 complete: Vapor application setup and basic Nginx configuration done."
```

**Making the script executable:**
```bash
chmod +x 03_application_setup.sh
./03_application_setup.sh
```

## Phase 4: Advanced Application Configuration
### Script Name: `04_advanced_configuration.sh`

```bash
#!/bin/bash

# Define project details
read -p "Enter your Vapor project name: " project_name
project_dir="/var/www/$project_name"

cd "$project_dir"

# Check and install necessary Vapor dependencies for database and migrations
if [ ! -d "Sources/App/Models" ]; then
    mkdir -p Sources/App/Models
    mkdir -p Sources/App/Migrations
    echo "Model and Migration directories created."
fi

# Create Model file
cat > Sources/App/Models/Action.swift <<EOF
import Fluent
import Vapor

final class Action: Model, Content {
    static let schema = "actions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "description")
    var description: String

    @Field(key: "sequence")
    var sequence: Int

    @Children(for: \.$action)
    var paraphrases: [Paraphrase]

    init() {}

    init(id: UUID? = nil, description: String, sequence: Int) {
        this.id = id
        this.description = description
        this.sequence = sequence
    }
}
EOF

echo "Action model created."

# Create Migration file
cat > Sources/App/Migrations/CreateAction.swift <<EOF
import Fluent

struct CreateAction: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("actions")
            .id()
            .field("description", .string, .required)
            .field("sequence", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("actions").delete()
    }
}
EOF

echo "CreateAction migration created."

# Compile and migrate database
vapor build && vapor run migrate

echo "Phase 4 complete: Vapor application fully configured with models and migrations."
```

**Making the script executable:**
```bash
chmod +x 04_advanced_configuration.sh
./04_advanced_configuration.sh
```

This comprehensive guide provides step-by-step instructions to set up a robust Vapor environment, ensuring that each phase is clear, functional, and rewarding. Feel free to adjust the scripts according to your specific needs or environment configurations.