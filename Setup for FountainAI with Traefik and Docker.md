### What IS Docker?

### Docker 101

Docker is a platform that enables developers to build, run, and share applications using containers. Containers package up the code, configurations, and dependencies into a single object, providing a lightweight, standalone, and executable software environment. This ensures that the application runs quickly and reliably from one computing environment to another.

#### Key Concepts

1. **Images**: A Docker image is a read-only template used to build containers. It includes the application and all dependencies required to run it.
2. **Containers**: A container is a runnable instance of an image. You can start, stop, move, and delete a container using the Docker API or CLI.
3. **Dockerfile**: This is a text document that contains all the commands a user could call on the command line to assemble an image.
4. **Docker Hub**: It's a cloud-based registry service that allows you to share your containers with your team, maintain version control, and more.

#### Basic Docker Commands
- `docker build`: Builds Docker images from a Dockerfile and a context.
- `docker pull`: Pulls an image or a repository from a registry.
- `docker run`: Runs a command in a new container.
- `docker push`: Pushes an image or a repository to a registry.
- `docker rm`: Removes one or more containers.
- `docker rmi`: Removes one or more images.

### Vapor and Docker

[Vapor](https://vapor.codes/) is a popular web framework for Swift that provides tools and libraries to build server-side applications. Vapor has good support for Docker, which simplifies deployment processes and ensures consistency across different development and production environments.

#### Default Behavior with Docker

Vapor seamlessly integrates with Docker through the use of a predefined `Dockerfile` which is typically included in the project setup. This `Dockerfile` is designed to:

- Set up a Swift environment.
- Copy the project files into the Docker image.
- Build the application within the Docker container.

This setup provides an isolated environment where Vapor applications can be built and run, independent of the host system's configuration.

#### Suggested Workflows with Docker and Vapor

1. **Development**: 
   - Use Docker during development to ensure that your development environment matches production. You can use Docker Compose to manage services like databases or caching systems alongside your Vapor application.
   - Command to run Vapor app in development mode: `docker compose up`

2. **Testing**:
   - Run tests in a Docker container to ensure consistency across all testing environments.
   - Use commands like `docker build -t myapp-test .` and `docker run myapp-test` to build and run tests.

3. **CI/CD**:
   - Integrate Docker with your CI/CD pipeline. Build the Docker image as part of your CI process and push it to a Docker registry.
   - Use CI tools like Jenkins, GitLab CI, or GitHub Actions to automate these steps.

4. **Deployment**:
   - Deploy the Docker container to your production environment. This could be a direct deployment to a cloud service provider that supports Docker, or via an orchestration system like Kubernetes.
   - Ensure environment variables and secrets are managed securely (using Docker secrets or third-party tools).

5. **Scaling**:
   - Use Docker in combination with container orchestration tools like Kubernetes or Docker Swarm to scale your Vapor application horizontally as needed.

Using Docker with Vapor not only standardizes development environments but also streamlines deployment and scaling strategies, making it easier to manage the application lifecycle. This workflow ensures that Vapor applications are portable, scalable, and easy to update.

### Docker running multiple Vapor Apps

Using Docker for running multiple instances of Vapor apps on the same Ubuntu 20.04 machine, for both development and production environments, makes a lot of sense for several reasons. Here's a breakdown of the benefits and how Docker facilitates this setup:

### Isolation

1. **Environment Consistency**: Docker ensures that each Vapor app runs in an isolated environment with its own dependencies, configurations, and libraries. This prevents conflicts that might arise from having multiple applications on the same server, each possibly requiring different versions of dependencies.

2. **Development-Production Parity**: Docker containers provide consistency across environments. The same Docker image used in development can be used in production, ensuring that there are no discrepancies caused by differing environments.

### Scalability and Management

3. **Ease of Scaling**: With Docker, scaling your application horizontally (adding more instances of the same app) is straightforward. You can quickly spin up new instances of your containers to handle increased load, and manage them efficiently through Docker's CLI or orchestration tools like Kubernetes or Docker Swarm.

4. **Resource Control**: Docker allows you to specify CPU and memory limits per container, which is crucial when multiple applications share the same physical or virtual server. This resource allocation ensures that one application does not monopolize system resources to the detriment of others.

### Deployment and Maintenance

5. **Simplified Deployment**: Deploying updates or new apps becomes a matter of building and running a new container. This can be highly automated with continuous integration/continuous deployment (CI/CD) pipelines, reducing human error and deployment times.

6. **Version Control and Rollback**: Docker images can be versioned and stored in a registry, allowing for easy rollback to previous versions if something goes wrong with a new deployment. This is invaluable for maintaining system stability and uptime.

### Security

7. **Enhanced Security**: Running applications in separate Docker containers reduces the risk of one app being compromised affecting others. Each container can be restricted in its permissions and access to the host system and other containers.

### Practical Considerations

Given that both development and production environments are on the same machine:
- **Development**: Developers can work on their local setup using Docker containers that exactly mimic the production environment, reducing the "works on my machine" problem.
- **Production**: The same Docker configurations used in development can be applied in production, ensuring that there are no unexpected behaviors due to environment differences.

### Implementation

For implementing such a setup with Vapor apps on an Ubuntu machine, consider the following workflow:
- **Dockerfile**: Each Vapor project should have its Dockerfile specifying the Swift version, dependencies, build commands, and other environment setups.
- **Docker Compose**: Use Docker Compose to manage multiple containers, defining how they interact, their network settings, and dependencies (like databases or external services).
- **Volume Management**: Use Docker volumes to manage persistent data and logs, ensuring that important data is retained across container restarts and redeployments.
- **Monitoring and Logging**: Implement monitoring and logging solutions that work with Docker to keep track of application performance and issues.

In summary, using Docker for running multiple instances of Vapor apps on the same machine not only makes sense but also offers significant advantages in terms of scalability, management, and development workflow. It enhances security and provides a robust platform for both development and production environments.

### Install docker on an Ubuntu 20.04 machine

To install Docker and set up everything needed on an Ubuntu 20.04 machine, where Vapor and the Vapor toolbox are already installed, you'll need to install Docker Engine, Docker Compose, and configure some basic settings to ensure everything works smoothly together. Here's a step-by-step guide to get you started:

### Step 1: Update Your System
First, ensure your package list and installed packages are updated.

```bash
sudo apt update
sudo apt upgrade -y
```

### Step 2: Install Docker Engine
Ubuntu’s default repository contains Docker packages, but installing from the official Docker repository ensures you have the latest version and features. Here’s how to do it:

1. **Install required packages to allow `apt` to use a repository over HTTPS:**

```bash
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
```

2. **Add Docker’s official GPG key:**

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

3. **Set up the stable repository:**

```bash
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

4. **Update the package database with the Docker packages from the newly added repo:**

```bash
sudo apt update
```

5. **Install Docker Engine:**

```bash
sudo apt install docker-ce docker-ce-cli containerd.io -y
```

6. **Verify that Docker is installed correctly by running the hello-world image:**

```bash
sudo docker run hello-world
```

### Step 3: Execute Docker Without Sudo (Optional)
By default, the Docker command can only be run by the root user or by a user in the `docker` group, which is automatically created during Docker's installation process. To run Docker commands without `sudo`, add your user to the `docker` group:

```bash
sudo usermod -aG docker ${USER}
```

To apply the new group membership, you might need to log out of the server and back in, or you can type the following:

```bash
su - ${USER}
```

Confirm that your user is now added to the Docker group by running:

```bash
id -nG
```

### Step 4: Install Docker Compose
Docker Compose is a tool for defining and running multi-container Docker applications. To install it, follow these steps:

1. **Download the latest version of Docker Compose:**

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

2. **Apply executable permissions to the binary:**

```bash
sudo chmod +x /usr/local/bin/docker-compose
```

3. **Test the installation:**

```bash
docker-compose --version
```

### Step 5: Configure Docker to Start on Boot
Ensure Docker starts when your system boots:

```bash
sudo systemctl enable docker
```

### Step 6: Reboot Your System
After installing Docker and adding your user to the Docker group, it’s a good idea to reboot your system to ensure all changes take effect correctly.

```bash
sudo reboot
```

### Conclusion
You now have Docker and Docker Compose installed on your Ubuntu 20.04 machine alongside Vapor. You can begin containerizing your Vapor applications and managing them through Docker for both development and production environments. This setup enhances the portability, consistency, and scalability of your applications.

### DNS Reverse Proxy to the FountainAI 

Setting up DNS to run each Dockerized Vapor app under its own subdomain involves a few steps, both in terms of DNS configuration and ensuring that your Docker containers are properly set up to respond to those subdomains. Here's a detailed walkthrough:

### Step 1: DNS Configuration

1. **Register a Domain Name**: If you haven't already, register a domain name with any reputable domain registrar.

2. **Configure Subdomains**: You need to create DNS records for each subdomain. This is typically done in the DNS management panel provided by your domain registrar or DNS hosting provider. You'll create A records pointing to the IP address of your Ubuntu server. For example:

    - `app1.yourdomain.com A -> Server IP`
    - `app2.yourdomain.com A -> Server IP`

   Alternatively, if your server's IP might change or if you're using multiple servers, you might use CNAME records pointing to a stable DNS name that resolves to your server(s).

### Step 2: Docker and Reverse Proxy Setup

To handle different subdomains on the same host machine, you generally use a reverse proxy. A reverse proxy can direct traffic coming to a single IP to different containers based on the hostname (subdomain in this case). **Nginx** or **Traefik** are popular choices for this task:

#### Using Nginx as a Reverse Proxy

1. **Install Nginx** on your Ubuntu server:

    ```bash
    sudo apt update
    sudo apt install nginx
    ```

2. **Configure Nginx** to proxy requests to your Dockerized apps. You'll create server blocks (similar to virtual hosts in Apache) for each subdomain. For example, create a file for each app in `/etc/nginx/sites-available/` and link it to `/etc/nginx/sites-enabled/`.

    ```nginx
    # For app1
    server {
        listen 80;
        server_name app1.yourdomain.com;

        location / {
            proxy_pass http://localhost:8081;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    ```

    **Note:** `proxy_pass` should point to the port where the corresponding Docker container is running. If `app1` is running on port `8081`, set it to `http://localhost:8081`.

3. **Enable the configuration** by linking the site configuration files from `sites-available` to `sites-enabled` and then restart Nginx.

    ```bash
    sudo ln -s /etc/nginx/sites-available/app1 /etc/nginx/sites-enabled/
    sudo systemctl restart nginx
    ```

#### Using Traefik as a Reverse Proxy

Traefik is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy. Traefik integrates with your existing infrastructure components and configures itself automatically and dynamically. Here’s a basic setup for using Traefik with Docker:

1. **Create a `docker-compose.yml`** for Traefik and your apps:

    ```yaml
    version: '3'

    services:
      traefik:
        image: traefik:v2.5
        command:
          - "--api.insecure=true"
          - "--providers.docker=true"
          - "--entrypoints.web.address=:80"
        ports:
          - "80:80"
          - "8080:8080"
        volumes:
          - "/var/run/docker.sock:/var/run/docker.sock"
          - "./traefik.yml:/etc/traefik/traefik.yml"

      app1:
        image: your-app1-image
        labels:
          - "traefik.http.routers.app1.rule=Host(`app1.yourdomain.com`)"
          - "traefik.http.services.app1.loadbalancer.server.port=8081"

      app2:
        image: your-app2-image
        labels:
          - "traefik.http.routers.app2.rule=Host(`app2.yourdomain.com`)"
          - "traefik.http.services.app2.loadbalancer.server.port=8082"
    ```

2. **Configure `traefik.yml`** for basic settings.

3. **Run the Docker Compose**: This starts up Traefik and your apps, with Traefik handling the routing based on subdomains.

### Step 3: Test Your Configuration

Once everything is set up:
- Access `app1.yourdomain.com` and `app2.yourdomain.com` from a browser.
- Verify that the requests are routed to the correct Docker containers.

### Conclusion

By setting up a reverse proxy, you manage incoming requests and route them to the correct Docker container based on the subdomain. This setup is highly scalable, allowing

 you to add more subdomains and applications as needed without additional complexity.
 
 ### Go "traefik"
 
 Great choice! Traefik is a powerful tool that simplifies networking in containerized environments. Let’s get you started on setting up Traefik to work with Docker, creating a basic configuration that supports routing to different Dockerized Vapor apps based on subdomains.

### Step 1: Install Docker and Docker Compose

First, ensure that Docker and Docker Compose are installed on your machine. If you haven't installed them yet, you can refer to the installation instructions I provided in a previous message.

### Step 2: Setup Traefik Configuration

You’ll need to set up a configuration file for Traefik that tells it how to behave and interact with Docker.

1. **Create a directory for your Traefik configuration**:

    ```bash
    mkdir -p ~/traefik
    cd ~/traefik
    ```

2. **Create a `traefik.yml` configuration file**:

    Here’s a basic example of what the configuration file might look like:

    ```yaml
    # Traefik Configuration
    log:
      level: DEBUG

    api:
      dashboard: true

    providers:
      docker:
        endpoint: "unix:///var/run/docker.sock"
        exposedByDefault: false

    entryPoints:
      web:
        address: ":80"
    ```

    This configuration enables the Traefik dashboard and sets up Docker as the provider. It also defines an entry point (port 80) for web traffic.

3. **Create a `docker-compose.yml`** file for Traefik and your apps:

    This Docker Compose file will run Traefik and configure routing for multiple apps based on subdomains.

    ```yaml
    version: '3.7'

    services:
      traefik:
        image: traefik:v2.5
        command:
          - "--configFile=/traefik.yml"
        ports:
          - "80:80"
          - "8080:8080"
        volumes:
          - "/var/run/docker.sock:/var/run/docker.sock"
          - "./traefik.yml:/traefik.yml"

      app1:
        image: app1-image
        labels:
          - "traefik.enable=true"
          - "traefik.http.routers.app1.rule=Host(`app1.yourdomain.com`)"
          - "traefik.http.services.app1.loadbalancer.server.port=8081"

      app2:
        image: app2-image
        labels:
          - "traefik.enable=true"
          - "traefik.http.routers.app2.rule=Host(`app2.yourdomain.com`)"
          - "traefik.http.services.app2.loadbalancer.server.port=8082"
    ```

    Replace `app1-image` and `app2-image` with the actual Docker images for your applications. Also, ensure the port numbers match the ports your applications are set to run on inside their containers.

### Step 3: Running Traefik with Docker Compose

1. **Start your setup**:

    ```bash
    docker-compose up -d
    ```

    This command starts all services defined in your `docker-compose.yml`, including Traefik with the routing rules specified.

2. **Access the Traefik Dashboard**:

    Navigate to `http://localhost:8080` in your browser to view the Traefik dashboard, which will show you the current routers, services, and middlewares.

### Step 4: Verify Your Setup

1. **Test your domain routing**:

    Access `http://app1.yourdomain.com` and `http://app2.yourdomain.com` in your browser. You should be directed to the appropriate application based on the subdomain.

### Conclusion

With Traefik, you now have a dynamic, robust, and scalable proxy solution for your Dockerized applications. It handles all the complexity of routing and load balancing with ease, allowing you to focus more on development and less on infrastructure management.

### Make the "FountainAI" self contained

Let's revise the setup to make it self-contained, focusing on using Docker and Traefik directly within the structure where  Vapor applications are located whithin the FountainAI. This setup will create a cohesive environment, making it easier to manage and deploy.

### Revised Setup for FountainAI with Traefik and Docker

Given the structure, we will add Traefik configurations directly into your `VaporRoot` directory alongside your existing Docker configurations. This centralizes the Docker management for all Vapor apps within the `fountainAI` directory.

### Step 1: Add Traefik Configuration Files

We'll start by creating the necessary configuration files for Traefik within the `VaporRoot` directory:

1. **Navigate to the `VaporRoot` directory**:
   ```bash
   cd /home/benedikt/fountainAI/VaporRoot
   ```

2. **Create a directory for Traefik configurations**:
   ```bash
   mkdir traefik
   cd traefik
   ```

3. **Create the Traefik configuration file (`traefik.yml`)**:
   ```bash
   nano traefik.yml
   ```

   Add the following configuration:
   ```yaml
   # Traefik Configuration
   log:
     level: DEBUG

   api:
     insecure: true
     dashboard: true

   providers:
     docker:
       endpoint: "unix:///var/run/docker.sock"
       watch: true
       exposedByDefault: false

   entryPoints:
     web:
       address: ":80"
   ```

### Step 2: Integrate Traefik with Docker Compose in the VaporRoot

Adjust the existing `docker-compose.yml` or create one if not present in the `ServerSetupAPI` directory:

1. **Navigate back to the `ServerSetupAPI` directory**:
   ```bash
   cd ../ServerSetupAPI
   ```

2. **Edit or create the Docker Compose file**:
   ```bash
   nano docker-compose.yml
   ```

   Here's a sample setup that includes Traefik and assumes you have one Vapor app running:
   ```yaml
   version: '3.7'

   services:
     traefik:
       image: traefik:v2.5
       container_name: traefik
       command:
         - "--configFile=/etc/traefik/traefik.yml"
       ports:
         - "80:80"
         - "8080:8080"
       volumes:
         - "/var/run/docker.sock:/var/run/docker.sock"
         - "../traefik/traefik.yml:/etc/traefik/traefik.yml"
       restart: unless-stopped

     vaporapp:
       build:
         context: .
         dockerfile: Dockerfile
       image: vaporapp-image
       container_name: vaporapp
       labels:
         - "traefik.enable=true"
         - "traefik.http.routers.vaporapp.rule=Host(`vaporapp.yourdomain.com`)"
         - "traefik.http.services.vaporapp.loadbalancer.server.port=8080"
   ```

   Adjust the `vaporapp` service configuration according to your actual Vapor app Docker setup, ensuring the labels for Traefik are correctly configured to route traffic based on the desired subdomain.

### Step 3: Run Docker Compose

Once your Docker Compose file is configured, you can start your services:

```bash
docker-compose up -d
```

### Step 4: Verify Your Setup

Check that the Traefik dashboard is accessible via `http://localhost:8080` and that your Vapor application is accessible via the subdomain configured in the labels (e.g., `http://vaporapp.yourdomain.com`).

### Conclusion

This setup ensures that all configurations related to Docker and Traefik are centralized within the `VaporRoot` directory of your FountainAI project. It allows easy management of your application environment, maintaining clear boundaries within your project structure for better organization and scalability.