#!/bin/bash

# Define colors for pretty output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper function for printing status messages
function print_status() {
    echo -e "${GREEN}$1${NC}"
}

function print_error() {
    echo -e "${RED}$1${NC}"
}

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
print_status "Installing Swift..."
if [ ! -d "/usr/share/swift" ]; then
    SWIFT_URL="https://download.swift.org/swift-5.10-release/ubuntu2004/swift-5.10-RELEASE/swift-5.10-RELEASE-ubuntu20.04.tar.gz"
    wget $SWIFT_URL -O swift.tar.gz
    tar xzf swift.tar.gz
    mv swift-5.10-RELEASE-ubuntu20.04/usr /usr/share/swift
    echo "export PATH=/usr/share/swift/usr/bin:$PATH" >> ~/.bashrc
    source ~/.bashrc
else
    print_status "Swift is already installed."
fi

# Install Vapor CLI
print_status "Installing Vapor CLI..."
if ! command -v vapor &> /dev/null; then
    curl -sL toolbox.vapor.sh | bash
else
    print_status "Vapor CLI is already installed."
fi

# Create a new Vapor project
PROJECT_DIR="ActionAPI"
print_status "Creating new Vapor project named $PROJECT_DIR..."
if [ ! -d "$PROJECT_DIR" ]; then
    vapor new $PROJECT_DIR --fluent --template=api
    cd $PROJECT_DIR
else
    print_status "$PROJECT_DIR project already exists."
    cd $PROJECT_DIR
fi

# Configure SQLite and models
print_status "Configuring SQLite and setting up models and migrations..."
mkdir -p Sources/App/Models
mkdir -p Sources/App/Migrations

# Model definitions
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
        self.sequence = sequence
    }
}
EOT

cat <<EOT > Sources/App/Models/Paraphrase.swift
import Fluent
import Vapor

final class Paraphrase: Model, Content {
    static let schema = "paraphrases"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "action_id")
    var action: Action

    @Field(key: "text")
    var text: String

    @Field(key: "commentary")
    var commentary: String

    init() {}

    init(id: UUID? = nil, actionId: UUID, text: String, commentary: String) {
        self.id = id
        self.\$action.id = actionId
        self.text = text
        self.commentary = commentary
    }
}
EOT

# Migration definitions
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

cat <<EOT > Sources/App/Migrations/CreateParaphrase.swift
import Fluent

struct CreateParaphrase: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("paraphrases            .id()
            .field("action_id", .uuid, .required, .references("actions", "id"))
            .field("text", .string, .required)
            .field("commentary", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("paraphrases").delete()
    }
}
EOT

# Configure routes
print_status "Configuring routes..."
cat <<EOT > Sources/App/routes.swift
import Vapor

func routes(_ app: Application) throws {
    let actionController = ActionController()
    app.get("actions", use: actionController.index)
    app.post("actions", use: actionController.create)
    app.get("actions", ":actionId", "paraphrases", use: actionController.getParaphrases)
    app.post("actions", ":actionId", "paraphrases", use: actionController.addParaphrase)
}
EOT

# Configure Nginx and SSL
print_status "Configuring Nginx and setting up SSL..."
nginx -t && systemctl reload nginx || {
    print_error "Failed to reload Nginx"
    exit 1
}
if ! certbot certificates | grep -q your_domain.com; then
    certbot --nginx -m your_email@example.com --agree-tos --no-eff-email -d your_domain.com --redirect || {
        print_error "Failed to setup SSL with Let's Encrypt"
        exit 1
    }
else
    print_status "SSL certificate for your_domain.com is already set up."
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

echo "Setup complete. Your system is now configured to use SSH with GitHub."
