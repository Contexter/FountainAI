### `episodes/Episode1/episode1.md`

# Episode 1: Initial Setup and Manual GitHub Secrets Creation

## Introduction

In this episode, we will set up the foundational components required for developing and deploying FountainAI. This includes creating a GitHub repository, configuring environment variables, and establishing secure communication with a VPS.

*Editor's Aside:*

Hello, dear reader!

Welcome to the FountainAI project! As your editor, my goal is to ensure that your journey through these episodes is as smooth and organized as possible. To achieve this, I have structured the project files to match the episodes linked in the README. Each shell script will start with its correct placement path and will close with a commit message for clarity and version control. This approach not only keeps everything tidy but also helps you track your progress and changes effectively.

For each script provided, you will need to make it executable and actually execute it. This means running the following command in your terminal:

```sh
chmod +x path/to/script.sh
./path/to/script.sh
```

When the project is shipped, all scripts will already be in place. You will simply need to run them in the correct order as described in each episode. This ensures that you can easily set up and configure everything as needed, even if you start the project midway. Now, let's dive into the first episode!

## Prerequisites

Ensure you have:
- A GitHub Account
- VPS (Virtual Private Server)
- Docker installed locally
- GitHub CLI (gh) installed

### Installing GitHub CLI

1. **macOS**:
   ```sh
   brew install gh
   ```

2. **Windows**:
   Download and run the [Windows installer](https://github.com/cli/cli/releases/latest).

3. **Linux**:
   Follow the instructions for your specific distribution from the [GitHub CLI installation page](https://github.com/cli/cli/blob/trunk/docs/install_linux.md).

### Authenticating GitHub CLI

After installing GitHub CLI, you need to authenticate it with your GitHub account:

```sh
gh auth login
```

Follow the prompts to authenticate.

## Step-by-Step Setup Guide

### Create GitHub Repository and Configuration File

First, let’s establish the foundational setup for our project. To start, we'll create a GitHub repository and configure our environment. This repository will be the central place for all our code, configuration, and documentation. Our configuration will be closely aligned with the OpenAPI specification, which will serve as the source of truth for our API.

**Why Use a VPS?**

Using a Virtual Private Server (VPS) offers several advantages, such as greater control over your environment, better performance, and enhanced security compared to shared hosting. It’s an excellent choice for running our self-hosted GitHub Actions runner, which will automate our CI/CD pipeline. Although it involves some costs, the benefits and flexibility it provides are significant.

### `episodes/Episode1/setup.sh`

```sh
#!/bin/bash

# Editor's Voice: This script sets up the initial components required for FountainAI.
# It creates a GitHub repository, configures environment variables, and establishes secure communication with a VPS.

# Step 1: Create a new GitHub Repository
echo "Creating GitHub repository..."
gh repo create Contexter/fountainAI --public --description "FountainAI Project Repository" --confirm

# Step 2: Clone the Repository Locally
echo "Cloning the repository locally..."
git clone https://github.com/Contexter/fountainAI.git
cd fountainAI

# Step 3: Create the folder structure for all episodes
echo "Creating folder structure for all episodes..."
mkdir -p episodes/Episode1
mkdir -p episodes/Episode2
mkdir -p episodes/Episode3
mkdir -p episodes/Episode4
mkdir -p episodes/Episode5
mkdir -p episodes/Episode6
mkdir -p episodes/Episode7
mkdir -p episodes/Episode8
mkdir -p episodes/Episode9
mkdir -p episodes/Episode10

# Step 4: Create Configuration File at the Root
echo "Creating configuration file..."
cat <<EOT >> config.env
# Name of your application
APP_NAME=fountainAI

# GitHub repository owner (your GitHub username or organization name)
REPO_OWNER=Contexter

# Name of your GitHub repository
REPO_NAME=fountainAI

# GitHub personal access token (generated in Step 2)
G_TOKEN=your_generated_token

# Private SSH key for accessing the VPS (will be generated in Step 3)
VPS_SSH_KEY='-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----'  # Placeholder, will update in Step 4

# Username for accessing your VPS
VPS_USERNAME=your_vps_username

# IP address of your VPS
VPS_IP=your_vps_ip

# Domain name for your production environment
DOMAIN=example.com

# Domain name for your staging environment
STAGING_DOMAIN=staging.example.com

# Directory on VPS where the app will be deployed
DEPLOY_DIR=/home/your_vps_username/deployment_directory

# Email address for Let's Encrypt SSL certificate registration
EMAIL=mail@benedikt-eickhoff.de

# Name of your PostgreSQL database
DB_NAME=fountainai_db

# Username for your PostgreSQL database
DB_USER=fountainai_user

# Password for your PostgreSQL database
DB_PASSWORD=your_db_password

# Port for your Redis service
REDIS_PORT=6379

# Port for your RedisAI service
REDISAI_PORT=6378

# Runner registration token (generated in Step 5)
RUNNER_TOKEN=your_runner_registration_token  # Placeholder, will update in Step 5

# Port for the NYDUS service
NYDUS_PORT=2224
EOT

# Step 5: Add config.env to .gitignore
echo "Adding config.env to .gitignore..."
echo "config.env" >> .gitignore

# Step 6: Commit and Push the Changes
echo "Committing and pushing changes..."
git add .
git commit -m "Initial setup with config.env and .gitignore"
git push origin main
```

**Tree After Running Setup Script:**
```
FountainAI/
├── config.env
├── README.md
└── episodes/
    ├── Episode1/
    │   ├── setup.sh
    │   └── episode1.md
    ├── Episode2/
    │   └── episode2.md
    ├── Episode3/
    │   └── episode3.md
    ├── Episode4/
    │   └── episode4.md
    ├── Episode5/
    │   └── episode5.md
    ├── Episode6/
    │   └── episode6.md
    ├── Episode7/
    │   └── episode7.md
    ├── Episode8/
    │   └── episode8.md
    ├── Episode9/
    │   └── episode9.md
    └── Episode10/
        └── episode10.md
```

### Generate a GitHub Personal Access Token

1. **Navigate to GitHub Settings**:
   - Go to [GitHub](https://github.com/) and log in to your account.
   - Click on your profile picture in the top right corner and select `Settings`.

2. **Access Developer Settings**:
   - In the left sidebar, click on `Developer settings`.

3. **Generate a Personal Access Token**:
   - Click on `Personal access tokens`.
   - Click on `Tokens (classic)`.
   - Click on `Generate new token`.

4. **Configure the Token**:
   - Give your token a descriptive name, such as `FountainAI Project Token`.
   - Set the expiration date as needed (e.g., 90 days).
   - Select the scopes/permissions for the token. For a super powerful access token, select the following scopes:

     #### Repository Permissions
     - `repo` (Full control of private repositories)
     - `workflow` (Update GitHub Action workflows)
     - `write:packages` (Upload packages to GitHub Package Registry)
     - `read:packages` (Download packages from GitHub Package Registry)
     - `admin:repo_hook` (Full control of repository hooks)
     - `admin:org` (Read and write org and team membership, read and write org projects)

     #### Account Permissions
     - `read:user` (Read all user profile data)
     - `user:email` (Read user email addresses)
     - `write:discussion` (Manage discussions)
     - `admin:org_hook` (Full control of organization webhooks)

     #### GPG Key Permissions
     - `admin:gpg_key` (Full control of user GPG keys)

     #### SSH Key Permissions
     - `admin:ssh_key` (Full control of user public SSH keys)

     #### Personal Access Token Permissions
     - `admin:public_key` (Full control of user public keys)
     - `admin:org` (Full control of orgs and teams)

     #### Other Permissions
     - `delete_repo` (Delete repositories)
     - `admin:enterprise` (Manage enterprise accounts)
     - `admin:org_project` (Manage org projects)
     - `admin:repo` (Manage repositories)
     - `admin:repo_hook` (Manage repository webhooks)

5. **Generate and Copy the Token**:
   - Click on `Generate token`.
   - Copy the generated token and store it **immediately & securely** in your

 `config.env` file.

```env
G_TOKEN=your_generated_token
```

### Create SSH Keys for VPS Access

1. **Open your terminal**.
2. **Generate an SSH Key Pair**:
   - Run the following command, replacing `your_email@example.com` with your email:
     ```sh
     ssh-keygen -t ed25519 -C "your_email@example.com"
     ```
   - Follow the prompts to save the key pair in the default location (`~/.ssh/id_ed25519` and `~/.ssh/id_ed25519.pub`).
     - When asked to "Enter a file in which to save the key," press Enter to accept the default location.
     - You can choose to set a passphrase or leave it empty by pressing Enter.

3. **Add the generated keys to the `config.env` file**:
   - Add the following lines to your `config.env` file:

```env
VPS_SSH_KEY=$(cat ~/.ssh/id_ed25519)
```

### Add SSH Keys to Your VPS and GitHub

#### Part A: Add the Public Key to Your VPS

1. **Copy the Public Key**:
   - Run the following command to display the public key:
     ```sh
     cat ~/.ssh/id_ed25519.pub
     ```
   - Copy the output (your public key) to your clipboard.

2. **Connect to Your VPS**:
   - Use an SSH client to connect to your VPS. Replace `your_vps_username` and `your_vps_ip` with your actual VPS username and IP address:
     ```sh
     ssh your_vps_username@your_vps_ip
     ```

3. **Add the Public Key to the VPS**:
   - On your VPS, create the `.ssh` directory if it doesn't exist:
     ```sh
     mkdir -p ~/.ssh
     ```
   - Add the copied public key to the `authorized_keys` file:
     ```sh
     echo "<public_key>" >> ~/.ssh/authorized_keys
     ```
   - Replace `<public_key>` with the public key you copied earlier.

#### Part B: Add the Private Key to GitHub Secrets

1. **Copy the Private Key**:
   - On your local machine, run the following command to display the private key:
     ```sh
     cat ~/.ssh/id_ed25519
     ```
   - Copy the output (your private key) to your clipboard.

2. **Add the Private Key to GitHub Secrets**:
   - Go to your GitHub repository in your web browser.
   - Navigate to **Settings** -> **Secrets and variables** -> **Actions**.
   - Click on **New repository secret**.
   - Add a new secret with the following details:
     - **Name**: `VPS_SSH_KEY`
     - **Value**: Paste the private key you copied earlier.
   - Click **Add secret** to save.

### Generate a Runner Registration Token

**Milestone: Setting Up Your Self-Hosted Runner**

Congratulations on reaching this milestone! Setting up a self-hosted runner on your VPS will bring the power of GitHub Actions directly to your server, giving you full control over your CI/CD pipeline. This is a significant step that leverages the flexibility and resources of your VPS, making it a rewarding and essential part of your project.

1. **Generate the Runner Token**:
   - Go to your GitHub repository.
   - Navigate to **Settings** -> **Actions** -> **Runners**.
   - Click on **New self-hosted runner**.
   - Select the appropriate operating system for your VPS.
   - Follow the instructions to download and configure the runner. Note the `RUNNER_TOKEN` generated in the process. You will use this token to register the runner.
   - **Immediately add this token to the `config.env` file** under the `RUNNER_TOKEN` variable to keep track of it.

```env
RUNNER_TOKEN=your_generated_runner_token
```

2. **Set Up the Runner as a Systemd Service**:
   - Follow the instructions provided by GitHub to configure and run the self-hosted runner.
   - Then, create a systemd service file on your VPS to ensure the runner runs as a service:
     ```sh
     sudo nano /etc/systemd/system/github-runner.service
     ```
   - Add the following content to the service file:
     ```ini
     [Unit]
     Description=GitHub Actions Runner
     After=network.target

     [Service]
     ExecStart=/home/your_vps_username/actions-runner/run.sh
     User=your_vps_username
     WorkingDirectory=/home/your_vps_username/actions-runner
     Restart=always

     [Install]
     WantedBy=multi-user.target
     ```
   - Replace `your_vps_username` with your actual VPS username.

3. **Reload the systemd daemon to recognize the new service**:
   ```sh
   sudo systemctl daemon-reload
   ```

4. **Enable the service to start on boot**:
   ```sh
   sudo systemctl enable github-runner
   ```

5. **Start the service**:
   ```sh
   sudo systemctl start github-runner
   ```

6. **Check the status of the service**:
   ```sh
   sudo systemctl status github-runner
   ```

### Manually Add Secrets to GitHub

For security reasons, sensitive information such as tokens, keys, and passwords should not be stored directly in the source code. Instead, GitHub Actions allows you to store these secrets securely. You need to replicate the contents of your `config.env` file as secrets in your GitHub repository.

1. **Navigate to Your Repository Settings**:
   - Go to your GitHub repository in your web browser.
   - Click on **Settings**.

2. **Access Secrets and Variables**:
   - In the left sidebar, click on **Secrets and variables**.
   - Click on **Actions**.

3. **Add a New Repository Secret**:
   - Click on **New repository secret**.
   - For each variable in your `config.env` file, add a new secret with the same name and value. For example:
     - **Name**: `APP_NAME`
     - **Value**: `fountainAI`
   - Repeat this for all variables in the `config.env` file.

This ensures that your GitHub Actions workflows can access these sensitive values securely.

## Conclusion

In this episode, we have set up the foundational components required for developing and deploying FountainAI. We created a GitHub repository, configured environment variables, generated necessary tokens, and established secure communication with a VPS. In the next episode, we will create and manage a CI/CD pipeline using GitHub Actions to automate the process of building, testing, and deploying the FountainAI application.

---

Would you like to proceed to Episode 2?