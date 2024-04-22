#!/bin/bash

# Define colors for pretty output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper functions for printing status messages
function print_status() {
    echo -e "${GREEN}$1${NC}"
}

function print_error() {
    echo -e "${RED}$1${NC}"
}

# Introduction
echo "This script will guide you through installing Swift, setting up a Vapor project, and configuring Nginx with SSL on Ubuntu 20.04."
echo "Please ensure you are connected to the internet and have sudo privileges."

# Confirm start
read -p "Press ENTER to begin or ctrl+c to abort..."

# Ensure running as root
if [ "$(id -u)" != "0" ]; then
    print_error "This script must be run as root"
    exit 1
fi

# Update and install dependencies
print_status "Updating system and installing required packages..."
apt-get update
apt-get install -y curl wget gnupg libatomic1 libcurl4 libedit2 libsqlite3-0 libxml2 libz3-4 nginx software-properties-common certbot python3-certbot-nginx openssl libssl-dev uuid-dev

# Install Swift
print_status "Preparing to install Swift..."
read -p "Please confirm the version of Swift to install (e.g., 5.10): " SWIFT_VERSION
read -p "Please confirm the Ubuntu version (e.g., ubuntu2004): " UBUNTU_VERSION
SWIFT_URL="https://download.swift.org/swift-${SWIFT_VERSION}-release/${UBUNTU_VERSION}/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-${UBUNTU_VERSION}.tar.gz"
print_status "Downloading Swift from $SWIFT_URL..."
if [ ! -d "/usr/share/swift" ]; then
    wget $SWIFT_URL -O swift.tar.gz && tar xzf swift.tar.gz
    mv swift-${SWIFT_VERSION}-RELEASE-${UBUNTU_VERSION}/usr /usr/share/swift
    echo "export PATH=/usr/share/swift/usr/bin:$PATH" >> ~/.bashrc
    source ~/.bashrc
    print_status "Swift installed successfully."
else
    print_status "Swift is already installed."
fi

# Install Vapor CLI
print_status "Installing Vapor CLI..."
if ! command -v vapor &> /dev/null; then
    curl -sL toolbox.vapor.sh | bash
    print_status "Vapor CLI installed successfully."
else
    print_status "Vapor CLI is already installed."
fi

# Create a new Vapor project
print_status "Setting up a new Vapor project..."
read -p "Enter your project directory name (e.g., MyVaporApp): " PROJECT_DIR
if [ ! -d "$PROJECT_DIR" ]; then
    vapor new $PROJECT_DIR --fluent --template=api
    cd $PROJECT_DIR
    print_status "Created the project in $PROJECT_DIR."
else
    print_status "$PROJECT_DIR project already exists."
    cd $PROJECT_DIR
fi

# Configure SQLite and models
print_status "Configuring database and models..."
mkdir -p Sources/App/Models
mkdir -p Sources/App/Migrations

# Model and Migration definitions
cat <<EOT > Sources/App/Models/Action.swift
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
        self.id = id
        self.description = description
        this.sequence = sequence
    }
}
EOT

cat <<EOT > Sources/App/Migrations/CreateAction.swift
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
EOT

# Configure Nginx and SSL
read -p "Enter the domain name for your project (e.g., example.com): " DOMAIN_NAME
read -p "Enter your email for SSL certificateregistration (e.g., user@example.com): " EMAIL
print_status "Configuring Nginx and setting up SSL..."
nginx -t && systemctl reload nginx || {
    print_error "Failed to reload Nginx"
    exit 1
}
if ! certbot certificates | grep -q $DOMAIN_NAME; then
    certbot --nginx -m $EMAIL --agree-tos --no-eff-email -d $DOMAIN_NAME --redirect || {
        print_error "Failed to setup SSL with Let's Encrypt"
        exit 1
    }
else
    print_status "SSL certificate for $DOMAIN_NAME is already set up."
fi

# Build and run the project
print_status "Building and running the Vapor project..."
vapor build || {
    print_error "Failed to build the project"
    exit 1
}
vapor run serve || {
    print_error "Failed to run the project"
    exit 1
}

echo "Setup complete. Your Vapor environment is ready to use."
echo "Visit http://$DOMAIN_NAME to see your running application."
