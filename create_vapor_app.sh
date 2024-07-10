#!/bin/bash

# Load configuration from config.env
source config.env

# Function to create and initialize a new Vapor app with required packages
create_vapor_app() {
    local app_name=$1
    
    # Clean up any existing directory
    if [ -d "$app_name" ]; then
        echo "Removing existing directory $app_name"
        rm -rf $app_name
    fi

    mkdir -p $app_name
    cd $app_name

    # Create a new Vapor project using expect to handle interactive prompts
    expect <<EOF
spawn vapor new $app_name
expect "Would you like to use Fluent (ORM)? (--fluent/--no-fluent)"
send "y\r"
expect "Which database would you like to use? (--fluent.db)"
send "1\r"
expect "Would you like to use Leaf (templating)? (--leaf/--no-leaf)"
send "y\r"
expect eof
EOF

    cd $app_name

    # Comment indicating the starter nature of the app
    echo "// This is a starter Vapor application. Further customization and implementation required." >> README.md

    # Update Package.swift to include PostgreSQL, Redis, and Leaf
    sed -i '' '/dependencies:/a\
        .package(url: "https://github.com/vapor/postgres-kit.git", from: "2.0.0"),\
        .package(url: "https://github.com/vapor/redis.git", from: "4.0.0"),\
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0")' Package.swift

    sed -i '' '/targets:/a\
        .target(name: "'$app_name'", dependencies: [.product(name: "Leaf", package: "leaf"), .product(name: "PostgresKit", package: "postgres-kit"), .product(name: "Redis", package: "redis")])' Package.swift

    # Create the necessary configurations for Leaf, PostgreSQL, and Redis in configure.swift
    cat <<EOT >> Sources/App/configure.swift
import Vapor
import Leaf
import Fluent
import FluentPostgresDriver
import Redis

public func configure(_ app: Application) throws {
    app.views.use(.leaf)

    app.databases.use(.postgres(
        hostname: Environment.get("DB_HOST") ?? "localhost",
        username: Environment.get("DB_USER") ?? "postgres",
        password: Environment.get("DB_PASSWORD") ?? "password",
        database: Environment.get("DB_NAME") ?? "database"
    ), as: .psql)

    app.redis.configuration = try RedisConfiguration(
        hostname: Environment.get("REDIS_HOST") ?? "localhost",
        port: Environment.get("REDIS_PORT").flatMap(Int.init(_:)) ?? 6379
    )

    // Register routes
    try routes(app)
}
EOT

    # Return to main directory
    cd ../..
}

# Execute the function
create_vapor_app $APP_NAME
