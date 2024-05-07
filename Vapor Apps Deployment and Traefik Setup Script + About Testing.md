
# Vapor Apps Deployment and Traefik Setup Script

```bash
#!/bin/bash

# Name: Vapor Apps Deployment and Traefik Setup Script
# Purpose: Automates the deployment of Vapor applications and sets up Traefik for routing.
# The script does the following:
# 1. Configures Traefik's static and dynamic configuration files.
# 2. Creates a Docker Compose file to run Traefik.
# 3. Compiles each Vapor app and sets up Traefik routing labels.
# 4. Switches the apps to production mode.
# 5. Starts the Traefik service using Docker Compose.
# 6. Tests DNS resolution for each application's domain.
# Requirements: Ensure Docker, Docker Compose, and Swift are installed.

# Global variables and paths
VAPOR_APPS_ROOT="/home/benedikt/fountainAI/VaporRoot"
DOMAIN="fountain.coach"

TRAFFIC_CONFIG_DIR="$VAPOR_APPS_ROOT/traefik"
TRAFFIC_COMPOSE_FILE="$TRAFFIC_CONFIG_DIR/docker-compose.yml"
TRAFFIC_DYNAMIC_CONFIG="$TRAFFIC_CONFIG_DIR/dynamic_config.yml"
TRAFFIC_STATIC_CONFIG="$TRAFFIC_CONFIG_DIR/traefik.toml"

# Define a mapping between each Vapor app and its subdomain
declare -A APP_DOMAINS
APP_DOMAINS=(
  ["ActionVaporApp"]="action.fountain.coach"
  ["CharacterVaporApp"]="character.fountain.coach"
  ["MusicSoundVaporApp"]="musicsound.fountain.coach"
  ["NoteVaporApp"]="note.fountain.coach"
  ["ScriptVaporApp"]="script.fountain.coach"
  ["SectionHeadingVaporApp"]="sectionheading.fountain.coach"
  ["SpokenWordVaporApp"]="spokenword.fountain.coach"
  ["TransitionVaporApp"]="transition.fountain.coach"
)

# Create Traefik configuration directory if it doesn't exist
create_traffic_config_dir() {
  if [ ! -d "$TRAFFIC_CONFIG_DIR" ]; then
    mkdir -p "$TRAFFIC_CONFIG_DIR"
    echo "Created Traefik configuration directory: $TRAFFIC_CONFIG_DIR"
  else
    echo "Traefik configuration directory already exists: $TRAFFIC_CONFIG_DIR"
  fi
}

# Write the static Traefik configuration file
write_static_traffic_config() {
  if [ ! -f "$TRAFFIC_STATIC_CONFIG" ]; then
    cat <<EOF > "$TRAFFIC_STATIC_CONFIG"
# Static configuration for Traefik, defining entry points and the ACME (Let's Encrypt) resolver

[entryPoints]
  [entryPoints.web]
  address = ":80"  # HTTP traffic entry point

  [entryPoints.websecure]
  address = ":443"  # HTTPS traffic entry point

[certificatesResolvers.default.acme]
  email = "mail@benedikt-eickhoff.de"  # Email for Let's Encrypt (ACME) certificates
  storage = "acme.json"  # File to store ACME certificate data
  [certificatesResolvers.default.acme.httpChallenge]
    entryPoint = "web"  # Use the HTTP challenge on the web entry point

[log]
  level = "INFO"  # Set logging level to INFO for better diagnostics
EOF
    echo "Created Traefik static configuration: $TRAFFIC_STATIC_CONFIG"
  else
    echo "Traefik static configuration already exists: $TRAFFIC_STATIC_CONFIG"
  fi
}

# Write the dynamic Traefik configuration file
write_dynamic_traffic_config() {
  if [ ! -f "$TRAFFIC_DYNAMIC_CONFIG" ]; then
    cat <<EOF > "$TRAFFIC_DYNAMIC_CONFIG"
# Dynamic configuration for Traefik routers

http:
  routers:
    traefik-router:
      rule: "Host(\`traefik.local.$DOMAIN\`)"
      entryPoints:
        - web  # Use the web (HTTP) entry point
      service: api@internal  # Traefik internal API router for dashboard access
EOF
    echo "Created Traefik dynamic configuration: $TRAFFIC_DYNAMIC_CONFIG"
  else
    echo "Traefik dynamic configuration already exists: $TRAFFIC_DYNAMIC_CONFIG"
  fi
}

# Create the Docker Compose file for Traefik
create_traffic_docker_compose() {
  if [ ! -f "$TRAFFIC_COMPOSE_FILE" ]; then
    cat <<EOF > "$TRAFFIC_COMPOSE_FILE"
version: '3.7'

services:
  traefik:
    image: "traefik:v2.5"  # Use Traefik version 2.5
    command:
      - "--api.insecure=true"  # Enable insecure access to the Traefik dashboard (for local use)
      - "--providers.docker"  # Use Docker provider to automatically detect containers
      - "--providers.file.directory=/dynamic_config"  # Load dynamic configuration from the mounted directory
      - "--entrypoints.web.address=:80"  # Entry point for HTTP traffic
      - "--entrypoints.websecure.address=:443"  # Entry point for HTTPS traffic
    ports:
      - "80:80"  # Map HTTP port 80 on the host
      - "443:443"  # Map HTTPS port 443 on the host
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"  # Mount the Docker socket for access to containers
      - "./dynamic_config.yml:/dynamic_config/dynamic_config.yml"  # Mount the dynamic config file
      - "./traefik.toml:/etc/traefik/traefik.toml"  # Mount the static configuration file
      - "./acme.json:/acme.json"  # Mount the ACME file for certificate data

    # Add labels for routing to the Traefik dashboard
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik-router.entrypoints=web"
EOF
    echo "Created Traefik Docker Compose file: $TRAFFIC_COMPOSE_FILE"
  else
    echo "Traefik Docker Compose file already exists: $TRAFFIC_COMPOSE_FILE"
  fi
}

# Compile the Vapor apps and add Traefik routing labels to their Docker Compose files
compile_and_configure_vapor_apps() {
  for APP in "${!APP_DOMAINS[@]}"; do
    APP_DOMAIN=${APP_DOMAINS[$APP]}
    APP_DIR="$VAPOR_APPS_ROOT/$APP"
    APP_COMPOSE_FILE="$APP_DIR/docker-compose.yml"

    # Build (compile) the Vapor app using the `swift build` command
    echo "Building $APP..."
    cd "$APP_DIR" || exit
    if swift build -c release; then
      echo "Successfully built $APP."
    else
      echo "Failed to build $APP. Please check the build output for errors."
      continue
    fi

    # Add Traefik routing labels to the Docker Compose file if not already present
    if ! grep -q "traefik.http.routers.${APP,,}-router.rule=Host(\\\`$APP_DOMAIN\\\`)" "$APP_COMPOSE_FILE"; then
      sed -i.bak "/services:/a \\
  labels: \\
    - \"traefik.enable=true\" \\
    - \"traefik.http.routers.${APP,,}-router.rule=Host(\\\`$APP_DOMAIN\\\`)\" \\
    - \"traefik.http.routers.${APP,,}-router.entrypoints=web\" \\
" "$APP_COMPOSE_FILE"
      echo "Updated Docker Compose file for $APP to include Traefik routing labels."
    else
      echo "Docker Compose file for $APP already has Traefik routing labels."
    fi

    # Switch the Vapor app's environment to production mode by modifying the `configure.swift` file
    CONFIGURE_FILE="$APP_DIR/Sources/App/configure.swift"
    if [ -f "$CONFIGURE_FILE" ]; then
      if grep -q ".development" "$CONFIGURE_FILE"; then
        sed -i.bak "s/.development/.production/g" "$CONFIGURE_FILE"
        echo "Switched $APP to production mode."
      else
        echo "$APP is already in production mode."
      fi
    else
      echo "Configuration file not found for $APP."
    fi
  done
}

# Start the Traefik service using the Docker Compose file
start_traffic_service() {
  cd "$TRAFFIC_CONFIG_DIR" || exit
  docker-compose up -d
}

# Function to test DNS resolution for a specific domain using the `dig` command
test_dns_resolution() {
  local domain="$1"
  echo "Testing DNS resolution for domain: $domain"
  # Check if the domain resolves to an IP address and output the result
  if dig +short "$domain" | grep -q '^[0-9]'; then
    echo "DNS resolution successful for $domain"
  else
    echo "DNS resolution failed for $domain"
  fi
}

# Test DNS settings for all Vapor app domains
test_all_dns_resolutions() {
  echo "Testing DNS settings for all domains:"
  for DOMAIN_NAME in "${APP_DOMAINS[@]}"; do
    test_dns_resolution "$DOMAIN_NAME"
  done
}

# Execute the functions in proper order
create_traffic_config_dir
write_static_traffic_config
write_dynamic_traffic_config
create_traffic_docker_compose
compile_and_configure_vapor_apps
start_traffic_service
test_all_dns_resolutions

# End of the script
```

## About Testing the Deployment

After ensuring everything is compiled and configured correctly, here are a few ways to check if the Vapor apps and Traefik are up and running:

1. **Docker Status**:
   - Check the status of all running Docker containers by using:
   ```bash
   docker ps
   ```
   - This will list all running containers, including the Traefik service and each Vapor app. Confirm that all containers are up and healthy.

2. **Traefik Dashboard**:
   - Access the Traefik dashboard to see if it's routing requests correctly:
     - Visit the URL of the Traefik dashboard (e.g., `http://traefik.local.fountain.coach` if configured like in the script).
     - This dashboard provides visibility into the routers and services being managed by Traefik.

3. **Application URLs**:
   - Test each application's URL to ensure it's accessible and responding properly.
   - You can use `curl` to request the application's root endpoint or a specific route:
   ```bash
   curl -I http://action.fountain.coach
   curl -I http://character.fountain.coach
   # And so forth for other apps...
   ```
   - A successful response (200 OK or other appropriate status codes) indicates that the app is functioning.

4. **Logs**:
   - Check the logs for both Traefik and the individual Vapor apps:
   ```bash
   docker-compose logs traefik  # Logs for Traefik
   docker-compose logs <service_name>  # Logs for a specific Vapor app
   ```
   - You can also tail the logs in real-time to observe incoming traffic and application behavior:
   ```bash
   docker-compose logs -f traefik
   docker-compose logs -f <service_name>
   ```

5. **Direct API Requests**:
   - If the Vapor apps have specific API endpoints, perform GET or POST requests directly against those endpoints using `curl`, Postman, or any HTTP client.
   - This will allow you to validate the API behavior and confirm its connectivity.

6. **System Monitoring**:
   - Use system monitoring tools like `htop` or `top` to observe CPU/memory utilization.
   - Docker Desktop (or Docker Daemon) also provides container statistics for more detailed insights.

7. **DNS Testing**:
   - Ensure that DNS resolution is functioning correctly and domains are mapped to your application server(s).

By combining these steps, you can be confident that both Traefik and your Vapor apps are running smoothly and correctly routing traffic.