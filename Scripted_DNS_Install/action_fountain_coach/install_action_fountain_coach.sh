#!/bin/bash

# Define colors for pretty output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Helper function for printing status messages
function print_status() {
    echo -e "${GREEN}$1${NC}"
}

# Ensure running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Update and install dependencies
print_status "Updating system and installing required packages..."
apt-get update && apt-get install -y curl gnupg libatomic1 libcurl4 libedit2 libsqlite3-0 libxml2 libz3-4 nginx software-properties-common certbot python3-certbot-nginx

# Install Swift
print_status "Installing Swift..."
wget https://download.swift.org/swift-5.3.3-release/ubuntu2004/swift-5.3.3-RELEASE-swift-5.3.3-RELEASE-ubuntu20.04.tar.gz
tar xzf swift-5.3.3-RELEASE-ubuntu20.04.tar.gz
mv swift-5.3.3-RELEASE-ubuntu20.04/usr /usr/share/swift
echo "export PATH=/usr/share/swift/bin:$PATH" >> ~/.bashrc
source ~/.bashrc

# Install Vapor
print_status "Installing Vapor..."
/bin/bash -c "$(curl -fsSL https://apt.vapor.sh)"
apt-get install vapor -y

# Step 2: Create a new Vapor project with Fluent and setup for SQLite
print_status "Creating new Vapor project named ActionAPI..."
vapor new ActionAPI --fluent --template=api
cd ActionAPI

# Step 3: Update Package.swift to include FluentSQLiteDriver
print_status "Adding FluentSQLiteDriver to dependencies..."
sed -i '/dependencies: \[/a \        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),' Package.swift
sed -i '/.target(name: "App", dependencies: \[/a \            .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),' Package.swift

# Step 4: Configure SQLite and create Models/Migrations
print_status "Configuring SQLite and setting up models and migrations..."
mkdir -p Sources/App/Models
mkdir -p Sources/App/Migrations

# Create Action model
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

# Create Paraphrase model
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

# Create migrations for Action and Paraphrase
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
        database.schema("paraphrases")
            .id()
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

# Step 5: Update routes and run the project
print_status "Updating routes..."
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

# Step 6: Configure Nginx and SSL
print_status "Configuring Nginx and setting up SSL..."
# Nginx configuration
cat <<EOT > /etc/nginx/sites-available/actionapi
server {
    listen 80;
    server_name action.fountain.coach;  # Change to your domain

    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name action.fountain.coach;

    ssl_certificate /etc/letsencrypt/live/action.fountain.coach/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/action.fountain.coach/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOT

ln -s /etc/nginx/sites-available/actionapi /etc/nginx/sites-enabled/
systemctl restart nginx

# Obtain SSL certificate
print_status "Obtaining SSL certificate..."
certbot --nginx -m mail@benedikt-eickhoff.de --agree-tos --no-eff-email -d action.fountain.coach --redirect

# Step 7: Build and run the Vapor project
print_status "Building the project..."
vapor build
print_status "Running the project..."
vapor run serve

