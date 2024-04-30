# Tooling Composition and Management of FountainAI, a cluster of Vapor Apps

### Part 1: Creation

1. **Navigate to VaporRoot:**
   - Go to the directory `/fountainAI/VaporRoot`.

2. **Create individual Vapor apps:**
   - For each OpenAPI specification (excluding `serverSetup.yaml`), create a new Vapor app:
     - `ActionService`
     - `CharacterService`
     - `MusicSoundService`
     - `NoteService`
     - `ScriptService`
     - `SectionHeadingService`
     - `SpokenWordService`
     - `TransitionService`

3. **Explore each app's directory structure:**
   - Examine the generated directories and files:
      - **Dockerfile:** Defines how to build the app's Docker image.
      - **Package.swift:** Specifies the project's dependencies and configurations.
      - **Sources/App/routes.swift:** Sets up the app's routing logic.
      - **Tests Directory:** Contains unit tests for the app.

4. **Avoid overwriting existing configurations:**
   - Ensure that existing configurations from `serverSetup.yaml` or other relevant setups are not overwritten.

5. **Docker Compose configuration:**
   - At `VaporRoot`, create a `docker-compose.yml` to orchestrate the cluster:
      - **Define services:** Include all apps, mapping them to specific ports.
      - **Proxy Setup:** Traefik will act as a reverse proxy to manage routing across all services.
      - **Network:** Set up a shared network to connect all services.

### Part 2: Management

1. **Build and start:**
   - Navigate to the `VaporRoot` directory and use `docker-compose` to build and run all services:

   ```bash
   docker-compose up --build
   ```

2. **Monitoring the cluster:**
   - **Check logs:** Monitor logs of each service to ensure they're running smoothly.

3. **Scaling services:**
   - Adjust the number of instances for specific services:

   ```bash
   docker-compose scale action-service=2
   ```

4. **Restarting services:**
   - Stop and restart services as needed:

   ```bash
   docker-compose stop/start action-service
   ```

5. **Documentation:**
   - Provide detailed documentation or instructions for managing the cluster effectively:
      - How to scale services.
      - How to restart services.
      - How to monitor logs and ensure smooth operation.

