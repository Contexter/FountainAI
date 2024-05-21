Automated Deployment of a Secure Vapor App with Docker, Nginx, and Let's Encrypt

### Project Directory Structure

```
vapor-app/
├── Scripts/                       # Contains all the bash scripts used for setup and deployment
│   ├── create_directories.sh      # Script to create necessary directories for the project
│   ├── setup_vapor_project.sh     # Script to set up the Vapor project
│   ├── build_vapor_app.sh         # Script to build the Vapor application
│   ├── run_vapor_local.sh         # Script to run the Vapor application locally
│   ├── create_docker_compose.sh   # Script to create Docker Compose file
│   ├── create_nginx_config.sh     # Script to create Nginx configuration file
│   ├── create_certbot_script.sh   # Script to create Certbot initialization script
│   ├── setup_project.sh           # Script to set up the entire project for production
│   ├── master_script.sh           # Master script to orchestrate the entire setup process
│   └── input_validation.sh        # Common functions for validating user inputs
│   └── read_config.sh             # Function to read configuration variables from config.yaml
├── .github/                       # Contains GitHub Actions workflows
│   └── workflows/
│       └── ci-cd-pipeline.yml     # CI/CD pipeline configuration
├── config/                        # Contains configuration templates and the main config file
│   ├── config.yaml                # Centralized configuration file for all variables used in the setup
│   ├── docker-compose-template.yml# Template for the Docker Compose file
│   ├── nginx-template.conf        # Template for the Nginx configuration file
│   └── init-letsencrypt-template.sh # Template for the Certbot initialization script
├── Sources/                       # Source code for the Vapor application
│   └── App/
│       ├── Controllers/           # Contains the controller files
│       │   ├── ScriptController.swift # Controller for the Script model
│       ├── Models/                # Contains the model files
│       │   ├── Script.swift       # Script model definition
│       ├── Migrations/            # Contains migration files
│       │   ├── CreateScript.swift # Migration file for creating the Script table
│       ├── configure.swift        # Configuration file for the Vapor application
│       ├── routes.swift           # File defining the application routes
│       └── main.swift             # Main entry point for the Vapor application
├── certbot/                       # Contains directories and files for Certbot
│   ├── conf/                      # Configuration files for Certbot
│   ├── www/                       # Webroot for Certbot validation
├── nginx/                         # Contains the Nginx configuration file
│   └── nginx.conf                 # Nginx configuration file (generated from template)
├── vapor/                         # Directory for Docker build context of the Vapor application
│   ├── Dockerfile                 # Dockerfile for building the Vapor application container
│   ├── Sources/                   # Source code for the Vapor application inside Docker context
│   │   └── App/
│   │       ├── Controllers/       # Same as above
│   │       │   ├── ScriptController.swift
│   │       ├── Models/            # Same as above
│   │       │   ├── Script.swift
│   │       ├── Migrations/        # Same as above
│   │       │   ├── CreateScript.swift
│   │       ├── configure.swift    # Same as above
│   │       ├── routes.swift       # Same as above
│   │       └── main.swift         # Same as above
│   └── Package.swift              # Package.swift for the Vapor application
└── docker-compose.yml             # Docker Compose file (generated from template)
```

### CI/CD Pipeline Configuration (`.github/workflows/ci-cd-pipeline.yml`)

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: password
          POSTGRES_DB: scriptdb
        ports:
          - 5432:5432
        options: >-
          --health-cmd="pg_isready -U postgres"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5

      redis:
        image: redis:latest
        ports:
          - 6379:6379
        options: >-
          --health-cmd="redis-cli ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Swift
        uses: fwal/setup-swift@v1

      - name: Install dependencies
        run: swift package resolve

      - name: Build project
        run: swift build -c release

      - name: Run tests
        run: swift test

  deploy:
    runs-on: ubuntu-latest
    needs: build

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Log in to Docker Hub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push Docker image
        run: |
          docker build -t ${{ secrets.DOCKER_USERNAME }}/vapor-app:latest .
          docker push ${{ secrets.DOCKER_USERNAME }}/vapor-app:latest

      - name: Deploy to production
        run: |
          ssh -o StrictHostKeyChecking=no ${{ secrets.SSH_USER }}@${{ secrets.SSH_HOST }} << 'EOF'
            docker pull ${{ secrets.DOCKER_USERNAME }}/vapor-app:latest
            docker-compose -f /path/to/your/project/docker-compose.yml up -d
          EOF
```

### Configuration File (`config/config.yaml`)

```yaml
# Centralized configuration file for all variables used in the setup
project_directory: "/path/to/your/project"
domain: "yourdomain.com"
email: "youremail@example.com"
database:
  host: "localhost"
  username: "postgres"
  password: "password"
  name: "scriptdb"
redis:
  host: "localhost"
  port: 6379
staging: 0
```

### Input Validation Script (`Scripts/input_validation.sh`)

```sh
#!/bin/bash

# Function to validate the project directory
validate_project_directory() {
    local project_dir=$1
    if [ -z "$project_dir" ]; then
        echo "Error: Project directory cannot be empty"
        exit 1
    fi
}

# Function to validate the domain name
validate_domain_name() {
    local domain=$1
    if [[ ! "$domain" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo "Error: Invalid domain name"
        exit 1
    fi
}

# Function to validate the email address
validate_email() {
    local email=$1
    if [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo "Error: Invalid email address"
        exit 1
    fi
}
```

### Configuration Reading Script (`Scripts/read_config.sh`)

```sh
#!/bin/bash

# Ensure yq is installed
if ! command -v yq &> /dev/null
then
    echo "yq could not be found. Please install yq to continue."
    exit 1
fi

# Function to read the configuration file and export environment variables
read_config() {
    local config_file=$1
    if [ ! -f "$config_file" ]; then
        echo "Configuration file not found: $config_file"
        exit 1
    fi

    export PROJECT_DIRECTORY=$(yq e '.project_directory' $config_file)
    export DOMAIN=$(yq e '.domain' $config_file)
    export EMAIL=$(yq e '.email' $config_file)
    export DATABASE_HOST=$(yq e '.database.host' $config_file)
    export DATABASE_USERNAME=$(yq e '.database.username' $config_file)
    export DATABASE_PASSWORD=$(yq e '.database.password' $config_file)
    export DATABASE_NAME=$(yq e '.database.name' $config_file)
    export REDIS_HOST=$(yq e '.redis.host' $config_file)
    export REDIS_PORT=$(yq e '.redis.port' $config_file)
    export STAGING=$(yq e '.staging' $config_file)
}
```

### Create Directories Script (`Scripts/create_directories.sh`)

```sh
#!/bin/bash

# Source the input validation functions
source ./Scripts/input_validation.sh

# Source the configuration variables
source ./Scripts/read_config.sh
read_config ./config/config.yaml



# Function to create necessary directories for the project
create_directories() {
    local project_dir=$1
    validate_project_directory "$project_dir"

    if [ ! -d "$project_dir" ]; then
        mkdir -p "$project_dir/Sources/App/Controllers"
        mkdir -p "$project_dir/Sources/App/Models"
        mkdir -p "$project_dir/Sources/App/Migrations"
        echo "Directories created in $project_dir."
    else
        echo "Project directory already exists."
    fi
}

# Main function to execute the script
main() {
    project_dir=$PROJECT_DIRECTORY
    create_directories "$project_dir"
}

main
```

### Setup Vapor Project Script (`Scripts/setup_vapor_project.sh`)

```sh
#!/bin/bash

# Source the input validation functions
source ./Scripts/input_validation.sh

# Source the configuration variables
source ./Scripts/read_config.sh
read_config ./config/config.yaml

# Function to create the Package.swift file for the Vapor project
create_package_swift() {
    local project_dir=$1

    cat <<EOF > "$project_dir/Package.swift"
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "VaporApp",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        .package(name: "vapor", url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(name: "fluent", url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(name: "fluent-postgres-driver", url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "4.0.0"),
        .package(url: "https://github.com/RedisAI/redisai-vapor", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Redis", package: "redis"),
                .product(name: "RedisAI", package: "redisai-vapor")
            ],
            path: "Sources/App"
        )
    ]
)
EOF

    echo "Package.swift created."
}

# Function to create the main.swift file for the Vapor project
create_main_swift() {
    local project_dir=$1

    cat <<EOF > "$project_dir/Sources/App/main.swift"
import Vapor

var env = try Environment.detect()
let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.run()
EOF

    echo "main.swift created."
}

# Function to create the configure.swift file for the Vapor project
create_configure_swift() {
    local project_dir=$1

    cat <<EOF > "$project_dir/Sources/App/configure.swift"
import Vapor
import Fluent
import FluentPostgresDriver
import Redis
import RedisAI

public func configure(_ app: Application) throws {
    // Database configuration
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        username: Environment.get("DATABASE_USERNAME") ?? "postgres",
        password: Environment.get("DATABASE_PASSWORD") ?? "password",
        database: Environment.get("DATABASE_NAME") ?? "scriptdb"
    ), as: .psql)

    // Redis configuration
    let redisConfig = RedisConfiguration(
        hostname: Environment.get("REDIS_HOST") ?? "localhost",
        port: Int(Environment.get("REDIS_PORT") ?? "6379")!
    )
    app.redis.configuration = redisConfig

    // Migrations
    app.migrations.add(CreateScript())

    // Register routes
    try routes(app)
}
EOF

    echo "configure.swift created."
}

# Function to create the routes.swift file for the Vapor project
create_routes_swift() {
    local project_dir=$1

    cat <<EOF > "$project_dir/Sources/App/routes.swift"
import Vapor

func routes(_ app: Application) throws {
    let scriptController = ScriptController()

    app.get("scripts", use: scriptController.index)
    app.post("scripts", use: scriptController.create)
    app.get("scripts", ":scriptId", use: scriptController.show)
    app.put("scripts", ":scriptId", use: scriptController.update)
    app.delete("scripts", ":scriptId", use: scriptController.delete)

    app.get("health") { req -> String in
        return "OK"
    }
}
EOF

    echo "routes.swift created."
}

# Function to create the Script model file for the Vapor project
create_script_model() {
    local project_dir=$1

    cat <<EOF > "$project_dir/Sources/App/Models/Script.swift"
import Vapor
import Fluent

final class Script: Model, Content {
    static let schema = "scripts"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "description")
    var description: String

    @Field(key: "author")
    var author: String

    @Field(key: "sequence")
    var sequence: Int

    init() {}

    init(id: UUID? = nil, title: String, description: String, author: String, sequence: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.author = author
        self.sequence = sequence
    }
}
EOF

    echo "Script.swift created."
}

# Function to create the CreateScript migration file for the Vapor project
create_script_migration() {
    local project_dir=$1

    cat <<EOF > "$project_dir/Sources/App/Migrations/CreateScript.swift"
import Fluent

struct CreateScript: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("scripts")
            .id()
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("author", .string, .required)
            .field("sequence", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("scripts").delete()
    }
}
EOF

    echo "CreateScript.swift created."
}

# Function to create the ScriptController file for the Vapor project
create_script_controller() {
    local project_dir=$1

    cat <<EOF > "$project_dir/Sources/App/Controllers/ScriptController.swift"
import Vapor
import Fluent
import Redis
import RedisAI

final class ScriptController {
    func index(req: Request) throws -> EventLoopFuture<[Script]> {
        if let cachedScripts: [Script] = try? req.redis.get("all_scripts", as: [Script].self).wait() {
            return req.eventLoop.future(cachedScripts)
        } else {
            return Script.query(on: req.db).all().map { scripts in
                try? req.redis.set("all_scripts", toJSON: scripts).wait()
                return scripts
            }
        }
    }

    func create(req: Request) throws -> EventLoopFuture<Script> {
        let script = try req.content.decode(Script.self)
        return script.save(on: req.db).map { script }
    }

    func show(req: Request) throws -> EventLoopFuture<Script> {
        Script.find(req.parameters.get("scriptId"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func update(req: Request) throws -> EventLoopFuture<Script> {
        let updatedScript = try req.content.decode(Script.self)
        return Script.find(req.parameters.get("scriptId"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { script in
                script.title = updatedScript.title
                script.description = updatedScript.description
                script.author = updatedScript.author
                script.sequence = updatedScript.sequence
                return script.save(on: req.db).map { script }
            }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        Script.find(req.parameters.get("scriptId"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { script in
                script.delete(on: req.db).transform(to: .noContent)
            }
    }
}
EOF

    echo "ScriptController.swift created."
}

# Function to set up the Vapor project
setup_vapor_project() {
    local project_dir=$1
    validate_project_directory "$project_dir"

    create_package_swift "$project_dir"
    create_main_swift "$project_dir"
    create_configure_swift "$project_dir"
    create_routes_swift "$project_dir"
    create_script_model "$project_dir"
    create_script_migration "$project_dir"
    create_script_controller "$project_dir"
}

# Main function to execute the script
main() {
    project_dir=$PROJECT_DIRECTORY
    setup_vapor_project "$project_dir"
}

main
```

### Build Vapor App Script (`Scripts/build_vapor_app.sh`)

```sh
#!/bin/bash

# Source the input validation functions
source ./Scripts/input_validation.sh

# Source the configuration variables
source ./Scripts/read_config.sh
read_config ./config/config.yaml

# Function to build the Vapor application
build_vapor_app() {
    local project_dir=$1
    validate

_project_directory "$project_dir"

    cd "$project_dir"
    swift build -c release
    echo "Vapor app built in release mode."
}

# Main function to execute the script
main() {
    project_dir=$PROJECT_DIRECTORY
    build_vapor_app "$project_dir"
}

main
```

### Run Vapor Locally Script (`Scripts/run_vapor_local.sh`)

```sh
#!/bin/bash

# Source the input validation functions
source ./Scripts/input_validation.sh

# Source the configuration variables
source ./Scripts/read_config.sh
read_config ./config/config.yaml

# Function to run the Vapor application locally
run_vapor_local() {
    local project_dir=$1
    validate_project_directory "$project_dir"

    cd "$project_dir"
    ./.build/release/App --env development
}

# Main function to execute the script
main() {
    project_dir=$PROJECT_DIRECTORY
    run_vapor_local "$project_dir"
}

main
```

### Create Docker Compose Script (`Scripts/create_docker_compose.sh`)

```sh
#!/bin/bash

# Source the input validation functions
source ./Scripts/input_validation.sh

# Source the configuration variables
source ./Scripts/read_config.sh
read_config ./config/config.yaml

# Function to create the Docker Compose file from a template
create_docker_compose_file() {
    local project_dir=$1
    validate_project_directory "$project_dir"

    # Substitute environment variables in the template and save to the project directory
    cat ./config/docker-compose-template.yml | envsubst > "$project_dir/docker-compose.yml"

    echo "Docker Compose file created in $project_dir."
}

# Main function to execute the script
main() {
    project_dir=$PROJECT_DIRECTORY
    create_docker_compose_file "$project_dir"
}

main
```

### Docker Compose Template (`config/docker-compose-template.yml`)

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:latest
    container_name: nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    networks:
      - web
    depends_on:
      - vapor
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 1m30s
      timeout: 10s
      retries: 3

  vapor:
    build:
      context: ./vapor
    container_name: vapor
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgres://$DATABASE_USERNAME:$DATABASE_PASSWORD@postgres:5432/$DATABASE_NAME
      - REDIS_URL=redis://$REDIS_HOST:$REDIS_PORT
    depends_on:
      - postgres
      - redis
    networks:
      - web
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
      interval: 1m
      timeout: 10s
      retries: 5

  postgres:
    image: postgres:13
    environment:
      POSTGRES_USER: $DATABASE_USERNAME
      POSTGRES_PASSWORD: $DATABASE_PASSWORD
      POSTGRES_DB: $DATABASE_NAME
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - web
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $DATABASE_USERNAME"]
      interval: 1m
      timeout: 10s
      retries: 5

  redis:
    image: redis:latest
    networks:
      - web
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 1m
      timeout: 10s
      retries: 5

  redisai:
    image: redislabs/redisai:latest
    ports:
      - "6378:6378"
    networks:
      - web

  certbot:
    image: certbot/certbot
    volumes:
      - ./certbot/conf:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do sleep 6h & wait $${!}; certbot renew; done;'"
    networks:
      - web

networks:
  web:
    driver: bridge

volumes:
  postgres_data:
```

### Create Nginx Config Script (`Scripts/create_nginx_config.sh`)

```sh
#!/bin/bash

# Source the input validation functions
source ./Scripts/input_validation.sh

# Source the configuration variables
source ./Scripts/read_config.sh
read_config ./config/config.yaml

# Function to create the Nginx configuration file from a template
create_nginx_config_file() {
    local project_dir=$1
    local domain=$2
    validate_project_directory "$project_dir"
    validate_domain_name "$domain"

    # Substitute environment variables in the template and save to the project directory
    cat ./config/nginx-template.conf | envsubst > "$project_dir/nginx/nginx.conf"

    echo "Nginx configuration file created for $domain in $project_dir."
}

# Main function to execute the script
main() {
    project_dir=$PROJECT_DIRECTORY
    domain=$DOMAIN
    create_nginx_config_file "$project_dir" "$domain"
}

main
```

### Nginx Config Template (`config/nginx-template.conf`)

```nginx
server {
    listen 80;
    server_name $DOMAIN;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    location / {
        proxy_pass http://vapor:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Create Certbot Script (`Scripts/create_certbot_script.sh`)

```sh
#!/bin/bash

# Source the input validation functions
source ./Scripts/input_validation.sh

# Source the configuration variables
source ./Scripts/read_config.sh
read_config ./config/config.yaml

# Function to create the directory structure for Certbot
create_certbot_directory_structure() {
    local project_dir=$1
    validate_project_directory "$project_dir"

    mkdir -p "$project_dir/certbot/conf"
    mkdir -p "$project_dir/certbot/www"
    echo "Certbot directory structure created in $project_dir."
}

# Function to download TLS parameters for Certbot
download_tls_parameters() {
    local project_dir=$1
    validate_project_directory "$project_dir"

    if [ ! -e "$project_dir/certbot/conf/options-ssl-nginx.conf" ] || [ ! -e "$project_dir/certbot/conf/ssl-dhparams.pem" ]; then
        echo "### Downloading recommended TLS parameters ..."
        curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$project_dir/certbot/conf/ssl-dhparams.pem"
        curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/options-ssl-nginx.conf > "$project_dir/certbot/conf/options-ssl-nginx.conf"
        echo "TLS parameters downloaded."
    else
        echo "TLS parameters already exist."
    fi
}

# Function to create a dummy certificate for the domain
create_dummy_certificate() {
    local project_dir=$1
    local domain=$2
    validate_project_directory "$project_dir"
    validate_domain_name "$domain"

    echo "### Creating dummy certificate for $domain ..."
    path="/etc/letsencrypt/live/$domain"
    mkdir -p "$project_dir/certbot/conf/live/$domain"
    docker-compose run --rm --entrypoint "\
      openssl req -x509 -nodes -newkey rsa:4096 -days 1\
        -keyout '$path/privkey.pem' \
        -out '$path/fullchain.pem' \
        -subj '/CN=localhost'" certbot
    echo "Dummy certificate created."
}

# Function to delete the dummy certificate
delete_dummy_certificate() {
    local domain=$1
    validate_domain_name "$domain"

    echo "### Deleting dummy certificate for $domain ..."
    docker-compose run --rm --entrypoint "\
      rm -Rf /etc/letsencrypt/live/$domain && \
      rm -Rf /etc/letsencrypt/archive/$domain && \
      rm -Rf /etc/letsencrypt/renewal/$domain.conf" certbot
    echo "Dummy certificate deleted."
}

# Function to request a Let's Encrypt certificate for the domain
request_lets_encrypt_certificate() {
    local project_dir=$1
    local domain=$2
    local email=$3
    local staging=$4
    validate_project_directory "$project_dir"
    validate_domain_name "$domain"
    validate_email "$email"

    echo "### Requesting Let's Encrypt certificate for $domain ..."
    domain_args="-d $domain"
    email_arg="--email $email"
    staging_arg=""
    if [ "$staging" != "0

" ]; then staging_arg="--staging"; fi

    docker-compose run --rm --entrypoint "\
      certbot certonly --webroot -w /var/www/certbot \
        $staging_arg \
        $email_arg \
        $domain_args \
        --rsa-key-size 4096 \
        --agree-tos \
        --force-renewal" certbot
    echo "Let's Encrypt certificate requested."
}

# Function to reload Nginx
reload_nginx() {
    echo "### Reloading nginx ..."
    docker-compose exec nginx nginx -s reload
    echo "Nginx reloaded."
}

# Function to create the Certbot script from a template
create_certbot_script() {
    local project_dir=$1
    local domain=$2
    validate_project_directory "$project_dir"
    validate_domain_name "$domain"

    # Substitute environment variables in the template and save to the project directory
    cat ./config/init-letsencrypt-template.sh | envsubst > "$project_dir/certbot/init-letsencrypt.sh"
    chmod +x "$project_dir/certbot/init-letsencrypt.sh"
    echo "Let's Encrypt certificate generation script created for $domain in $project_dir."
}

# Main function to execute the script
main() {
    project_dir=$PROJECT_DIRECTORY
    domain=$DOMAIN
    create_certbot_directory_structure "$project_dir"
    download_tls_parameters "$project_dir"
    create_certbot_script "$project_dir" "$domain"
}

main
```

### Certbot Initialization Template (`config/init-letsencrypt-template.sh`)

```sh
#!/bin/bash

domains=($DOMAIN)
rsa_key_size=4096
data_path="./certbot"
email=$EMAIL
staging=$STAGING

if [ -d "$data_path" ]; then
  read -p "Existing data found for $domains. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  echo
fi

echo "### Creating dummy certificate for $domains ..."
path="/etc/letsencrypt/live/$domains"
mkdir -p "$data_path/conf/live/$domains"
docker-compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:4096 -days 1\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'" certbot
echo

echo "### Starting nginx ..."
docker-compose up --force-recreate -d nginx
echo

echo "### Deleting dummy certificate for $domains ..."
docker-compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$domains && \
  rm -Rf /etc/letsencrypt/archive/$domains && \
  rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot
echo

echo "### Requesting Let's Encrypt certificate for $domains ..."
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

echo "### Reloading nginx ..."
docker-compose exec nginx nginx -s reload
```

### Setup Project Script (`Scripts/setup_project.sh`)

```sh
#!/bin/bash

# Source the input validation functions
source ./Scripts/input_validation.sh

# Source the configuration variables
source ./Scripts/read_config.sh
read_config ./config/config.yaml

# Function to set up the entire project
setup_project() {
    local project_dir=$1
    local domain=$2
    validate_project_directory "$project_dir"
    validate_domain_name "$domain"

    ./Scripts/create_directories.sh "$project_dir"
    ./Scripts/create_docker_compose.sh "$project_dir"
    ./Scripts/create_nginx_config.sh "$project_dir" "$domain"
    ./Scripts/create_certbot_script.sh "$project_dir" "$domain"

    echo "Project setup complete in $project_dir."

    cd "$project_dir"
    docker-compose up -d
    ./certbot/init-letsencrypt.sh

    echo "Production server setup complete and running in $project_dir."
}

# Main function to execute the script
main() {
    project_dir=$PROJECT_DIRECTORY
    domain=$DOMAIN
    setup_project "$project_dir" "$domain"
}

main
```

### Master Script (`Scripts/master_script.sh`)

```sh
#!/bin/bash

set -e

# Source the input validation functions
source ./Scripts/input_validation.sh

# Source the configuration variables
source ./Scripts/read_config.sh
read_config ./config/config.yaml

# Function to run a script and handle errors
run_script() {
    local script_path=$1
    local description=$2

    if [ ! -f "$script_path" ]; then
        echo "Error: $description script not found at $script_path."
        exit 1
    fi

    echo "Running $description..."
    bash "$script_path"
    if [ $? -ne 0 ]; then
        echo "Error: $description script failed."
        exit 1
    fi
    echo "$description completed successfully."
}

# Phase 1: Vapor App Creation
echo "Starting Phase 1: Vapor App Creation..."

run_script "./Scripts/create_directories.sh" "Create Directories"
run_script "./Scripts/setup_vapor_project.sh" "Setup Vapor Project"
run_script "./Scripts/build_vapor_app.sh" "Build Vapor App"

echo "Phase 1: Vapor App Creation completed."

# Phase 2: Production Deployment
echo "Starting Phase 2: Production Deployment..."

run_script "./Scripts/create_directories.sh" "Create Directories for Production"
run_script "./Scripts/create_docker_compose.sh" "Create Docker Compose File"
run_script "./Scripts/create_nginx_config.sh" "Create Nginx Configuration"
run_script "./Scripts/create_certbot_script.sh" "Create Certbot Script"

echo "Project setup for production deployment..."

cd "$PROJECT_DIRECTORY"
docker-compose up -d || { echo "Error: Docker Compose failed to start."; exit 1; }
bash "./certbot/init-letsencrypt.sh" || { echo "Error: Certbot initialization failed."; exit 1; }

echo "Phase 2: Production Deployment completed."

echo "Master script completed successfully. The Vapor app is now set up and running in the production environment."
```

### Conclusion

This refactored implementation centralizes configuration variables in a `config.yaml` file and uses a modular and automated approach for setting up and deploying the Vapor application. It incorporates CI/CD practices with GitHub Actions and enhances security measures for managing sensitive information throughout the application lifecycle. This setup ensures a robust, efficient, and secure deployment process for your Vapor application.
