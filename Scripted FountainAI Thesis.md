
# Summary:
- **Phase 1:** Creates, builds, and runs the Vapor app locally, implementing Redis for caching and RedisAI for enhanced script analysis.
- **Phase 2:** Sets up the production environment, including Docker Compose, Nginx, and Certbot configurations, and deploys the Vapor app in a Docker container.

# Main Script 
- **Main Script to call**


## Phase 1: Vapor App Creation
### Directory Structure for Phase 1
```
vapor-app/
├── Scripts/
│   ├── create_directories.sh
│   ├── setup_vapor_project.sh
│   ├── build_vapor_app.sh
│   ├── run_vapor_local.sh
├── Sources/
│   └── App/
│       ├── Controllers/
│       │   ├── ScriptController.swift
│       ├── Models/
│       │   ├── Script.swift
│       ├── Migrations/
│       │   ├── CreateScript.swift
│       ├── configure.swift
│       ├── routes.swift
│       └── main.swift
├── Package.swift
└── .build/
```

### Scripts for Creating the Vapor App

#### 1. `create_directories.sh`
```sh
#!/bin/bash

create_directories() {
    local project_dir=$1
    if [ -z "$project_dir" ]; then
        echo "Project directory cannot be empty"
        exit 1
    fi

    if [ ! -d "$project_dir" ]; then
        mkdir -p "$project_dir/Sources/App/Controllers"
        mkdir -p "$project_dir/Sources/App/Models"
        mkdir -p "$project_dir/Sources/App/Migrations"
        echo "Directories created in $project_dir."
    else
        echo "Project directory already exists."
    fi
}

main() {
    read -p "Enter the project directory: " project_dir
    create_directories "$project_dir"
}

main
```

#### 2. `setup_vapor_project.sh`
```sh
#!/bin/bash

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

setup_vapor_project() {
    local project_dir=$1

    create_package_swift "$project_dir"
    create_main_swift "$project_dir"
    create_configure_swift "$project_dir"
    create_routes_swift "$project_dir"
    create_script_model "$project_dir"
    create_script_migration "$project_dir"
    create_script_controller "$project_dir"
}

main() {
    read -p "Enter the project directory: " project_dir
    setup_vapor_project "$

project_dir"
}

main
```

#### 3. `build_vapor_app.sh`
```sh
#!/bin/bash

build_vapor_app() {
    local project_dir=$1

    if [ -z "$project_dir" ]; then
        echo "Project directory cannot be empty"
        exit 1
    fi

    cd "$project_dir"
    swift build -c release
    echo "Vapor app built in release mode."
}

main() {
    read -p "Enter the project directory: " project_dir
    build_vapor_app "$project_dir"
}

main
```

#### 4. `run_vapor_local.sh`
```sh
#!/bin/bash

run_vapor_local() {
    local project_dir=$1

    if [ -z "$project_dir" ]; then
        echo "Project directory cannot be empty"
        exit 1
    fi

    cd "$project_dir"
    ./.build/release/App --env development
}

main() {
    read -p "Enter the project directory: " project_dir
    run_vapor_local "$project_dir"
}

main
```

## Phase 2: Production Deployment

### Directory Structure for Phase 2
```
vapor-app/
├── Scripts/
│   ├── create_directories.sh
│   ├── create_docker_compose.sh
│   ├── create_nginx_config.sh
│   ├── create_certbot_script.sh
│   ├── setup_project.sh
├── certbot/
│   ├── conf/
│   ├── www/
│   └── init-letsencrypt.sh
├── nginx/
│   └── nginx.conf
├── vapor/
│   ├── Dockerfile
│   ├── Sources/
│   │   └── App/
│   │       ├── Controllers/
│   │       │   ├── ScriptController.swift
│   │       ├── Models/
│   │       │   ├── Script.swift
│   │       ├── Migrations/
│   │       │   ├── CreateScript.swift
│   │       ├── configure.swift
│   │       ├── routes.swift
│   │       └── main.swift
│   └── Package.swift
└── docker-compose.yml
```

### Scripts for Production Deployment

#### 1. `create_directories.sh`
```sh
#!/bin/bash

create_directories() {
    local project_dir=$1
    if [ -z "$project_dir" ]; then
        echo "Project directory cannot be empty"
        exit 1
    fi

    if [ ! -d "$project_dir" ]; then
        mkdir -p "$project_dir"/{vapor,nginx,certbot}
        echo "Directories created in $project_dir."
    else
        echo "Project directory already exists."
    fi
}

main() {
    read -p "Enter the project directory: " project_dir
    create_directories "$project_dir"
}

main
```

#### 2. `create_docker_compose.sh`
```sh
#!/bin/bash

create_docker_compose() {
    local project_dir=$1
    if [ -z "$project_dir" ]; then
        echo "Project directory cannot be empty"
        exit 1
    fi

    cat <<EOF > "$project_dir/docker-compose.yml"
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
      - DATABASE_URL=postgres://postgres:password@postgres:5432/scriptdb
      - REDIS_URL=redis://redis:6379
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
    container_name: postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: scriptdb
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - web
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 1m
      timeout: 10s
      retries: 5

  redis:
    image: redis:latest
    container_name: redis
    networks:
      - web
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 1m
      timeout: 10s
      retries: 5

  redisai:
    image: redislabs/redisai:latest
    container_name: redisai
    ports:
      - "6378:6378"
    networks:
      - web

  certbot:
    image: certbot/certbot
    container_name: certbot
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
EOF

    echo "Docker Compose file created in $project_dir."
}

main() {
    read -p "Enter the project directory: " project_dir
    create_docker_compose "$project_dir"
}

main
```

#### 3. `create_nginx_config.sh`
```sh
#!/bin/bash

create_nginx_config() {
    local project_dir=$1
    local domain=$2

    if [ -z "$project_dir" ] || [ -z "$domain" ]; then
        echo "Project directory and domain cannot be empty"
        exit 1
    fi

    cat <<EOF > "$project_dir/nginx/nginx.conf"
server {
    listen 80;
    server_name $domain;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name $domain;

    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;

    location / {
        proxy_pass http://vapor:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

    echo "Nginx configuration file created for $domain in $project_dir."
}

main() {
    read -p "Enter the project directory: " project_dir
    read -p "Enter the domain: " domain
    create_nginx_config "$project_dir" "$domain"
}

main
```

#### 4. `create_certbot_script.sh`
```sh
#!/bin/bash

create_certbot_directory_structure() {
    local project_dir=$1

    if [ -z "$project_dir" ]; then
        echo "Project directory cannot be empty"
        exit 1
    fi

    mkdir -p "$project_dir/certbot/conf"
    mkdir -p "$project_dir/certbot/www"
    echo "Certbot directory structure created in $project_dir."
}

download_tls_parameters() {
    local project_dir=$1

    if [ -z "$project_dir" ]; then
        echo "Project directory cannot be empty"
        exit 1
    fi

    if [ ! -e "$project_dir/certbot/conf/options-ssl-nginx.conf" ] || [ ! -e "$project_dir/certbot/conf/ssl-dhparams.pem" ]; then
        echo "### Downloading recommended TLS parameters ..."
        curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$project_dir/certbot/conf/ssl-dhparams.pem"
        curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/options-ssl-nginx.conf > "$project_dir/certbot/conf/options-ssl-nginx.conf"
        echo "TLS parameters downloaded."
    else
        echo "TLS parameters already exist."
    fi
}

create_dummy_certificate() {
    local project_dir=$1
    local domain=$2

    if [ -z "$project_dir" ] || [ -z "$domain" ]; then
        echo "Project directory and domain cannot be empty"
        exit 1
    fi

    echo "### Creating dummy

 certificate for $domain ..."
    path="/etc/letsencrypt/live/$domain"
    mkdir -p "$project_dir/certbot/conf/live/$domain"
    docker-compose run --rm --entrypoint "\
      openssl req -x509 -nodes -newkey rsa:1024 -days 1\
        -keyout '$path/privkey.pem' \
        -out '$path/fullchain.pem' \
        -subj '/CN=localhost'" certbot
    echo "Dummy certificate created."
}

delete_dummy_certificate() {
    local domain=$1

    if [ -z "$domain" ]; then
        echo "Domain cannot be empty"
        exit 1
    fi

    echo "### Deleting dummy certificate for $domain ..."
    docker-compose run --rm --entrypoint "\
      rm -Rf /etc/letsencrypt/live/$domain && \
      rm -Rf /etc/letsencrypt/archive/$domain && \
      rm -Rf /etc/letsencrypt/renewal/$domain.conf" certbot
    echo "Dummy certificate deleted."
}

request_lets_encrypt_certificate() {
    local project_dir=$1
    local domain=$2
    local email=$3
    local staging=$4

    if [ -z "$project_dir" ] || [ -z "$domain" ] || [ -z "$email" ]; then
        echo "Project directory, domain, and email cannot be empty"
        exit 1
    fi

    echo "### Requesting Let's Encrypt certificate for $domain ..."
    # Join $domains to -d args
    domain_args="-d $domain"

    # Select appropriate email arg
    email_arg="--email $email"

    # Enable staging mode if needed
    staging_arg=""
    if [ "$staging" != "0" ]; then staging_arg="--staging"; fi

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

reload_nginx() {
    echo "### Reloading nginx ..."
    docker-compose exec nginx nginx -s reload
    echo "Nginx reloaded."
}

create_certbot_script() {
    local project_dir=$1
    local domain=$2

    if [ -z "$project_dir" ] || [ -z "$domain" ]; then
        echo "Project directory and domain cannot be empty"
        exit 1
    fi

    cat <<EOF > "$project_dir/certbot/init-letsencrypt.sh"
#!/bin/bash

domains=($domain)
rsa_key_size=4096
data_path="./certbot"
email="mail@benedikt-eickhoff.de" # Adding a valid address is strongly recommended
staging=0 # Set to 1 if you're testing your setup to avoid hitting request limits

if [ -d "\$data_path" ]; then
  read -p "Existing data found for \$domains. Continue and replace existing certificate? (y/N) " decision
  if [ "\$decision" != "Y" ] && [ "\$decision" != "y" ]; then
    exit
  fi
fi

if [ ! -e "\$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "\$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "\$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "\$data_path/conf/ssl-dhparams.pem"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/options-ssl-nginx.conf > "\$data_path/conf/options-ssl-nginx.conf"
  echo
fi

echo "### Creating dummy certificate for \$domains ..."
path="/etc/letsencrypt/live/\$domains"
mkdir -p "\$data_path/conf/live/\$domains"
docker-compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:1024 -days 1\
    -keyout '\$path/privkey.pem' \
    -out '\$path/fullchain.pem' \
    -subj '/CN=localhost'" certbot
echo

echo "### Starting nginx ..."
docker-compose up --force-recreate -d nginx
echo

echo "### Deleting dummy certificate for \$domains ..."
docker-compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/\$domains && \
  rm -Rf /etc/letsencrypt/archive/\$domains && \
  rm -Rf /etc/letsencrypt/renewal/\$domains.conf" certbot
echo

echo "### Requesting Let's Encrypt certificate for \$domains ..."
# Join \$domains to -d args
domain_args=""
for domain in "\${domains[@]}"; do
  domain_args="\$domain_args -d \$domain"
done

# Select appropriate email arg
case "\$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email \$email" ;;
esac

# Enable staging mode if needed
if [ \$staging != "0" ]; then staging_arg="--staging"; fi

docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    \$staging_arg \
    \$email_arg \
    \$domain_args \
    --rsa-key-size \$rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

echo "### Reloading nginx ..."
docker-compose exec nginx nginx -s reload
EOF

    chmod +x "$project_dir/certbot/init-letsencrypt.sh"
    echo "Let's Encrypt certificate generation script created for $domain in $project_dir."
}

main() {
    read -p "Enter the project directory: " project_dir
    read -p "Enter the domain: " domain

    create_certbot_directory_structure "$project_dir"
    download_tls_parameters "$project_dir"
    create_certbot_script "$project_dir" "$domain"
}

main
```

### Final Setup Script

#### 5. `setup_project.sh`
```sh
#!/bin/bash

main() {
    read -p "Enter the project directory: " project_dir
    read -p "Enter the domain: " domain

    if [ -z "$project_dir" ] || [ -z "$domain" ]; then
        echo "Project directory and domain cannot be empty"
        exit 1
    fi

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

main
```

## Directory Structure for Main Script
```
vapor-app/
├── Scripts/
│   ├── create_directories.sh
│   ├── setup_vapor_project.sh
│   ├── build_vapor_app.sh
│   ├── run_vapor_local.sh
│   ├── create_docker_compose.sh
│   ├── create_nginx_config.sh
│   ├── create_certbot_script.sh
│   ├── setup_project.sh
│   └── master_script.sh
├── Sources/
│   └── App/
│       ├── Controllers/
│       │   ├── ScriptController.swift
│       ├── Models/
│       │   ├── Script.swift
│       ├── Migrations/
│       │   ├── CreateScript.swift
│       ├── configure.swift
│       ├── routes.swift
│       └── main.swift
├── certbot/
│   ├── conf/
│   ├── www/
│   └── init-letsencrypt.sh
├── nginx/
│   └── nginx.conf
├── vapor/
│   ├── Dockerfile
│   ├── Sources/
│   │   └── App/
│   │       ├── Controllers/
│   │       │   ├── ScriptController.swift
│   │       ├── Models/
│   │       │   ├── Script.swift
│   │       ├── Migrations/
│   │       │   ├── CreateScript.swift
│   │       ├── configure.swift
│   │       ├── routes.swift
│   │       └── main.swift
│   └── Package.swift
└── docker-compose.yml
```

### Main Script (`main_script.sh`)

```sh
#!/bin/bash

set -e

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

cd "./vapor-app"
docker-compose up -d || { echo "Error: Docker Compose failed to start."; exit 1; }
bash "./certbot/init-letsencrypt.sh" || { echo "Error: Certbot initialization failed."; exit 1; }

echo "Phase 2: Production Deployment completed."

echo "Master script completed successfully. The Vapor app is now set up and running in the production environment."
```

### Explanation:
- **`set -e`**: This ensures that the script exits immediately if a command exits with a non-zero status.
- **`run_script` Function**: This function checks if the script file exists, runs it, and checks for errors.
- **Phase 1**: Runs the scripts for creating directories, setting up the Vapor project, and building the Vapor app.
- **Phase 2**: Runs the scripts for creating directories for production, creating the Docker Compose file, creating the Nginx configuration, and creating the Certbot script.
- **Docker Compose and Certbot**: Starts the Docker Compose services and runs the Certbot script to initialize SSL certificates.

This master script ensures that each step is executed in order, checks for errors, and provides appropriate error messages.