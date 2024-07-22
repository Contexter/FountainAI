### `episodes/episode1.md`

# Episode 1: Initial Setup and Manual GitHub Secrets Creation
> also read: 
> [The Ultimate Guide to GitHub Tokens](https://github.com/Contexter/fountainAI/blob/editorial/episodes/Episode1/The%20Ultimate%20Guide%20to%20GitHub%20Tokens.md)
> [The Ultimate Guide to GitHub Runners](https://github.com/Contexter/fountainAI/blob/editorial/episodes/Episode1/The%20Ultimate%20Guide%20to%20GitHub%20Runners.md)

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Step-by-Step Setup Guide](#step-by-step-setup-guide)
   1. [Create GitHub Repository and Configuration File](#create-github-repository-and-configuration-file)
   2. [Generate a GitHub Personal Access Token](#generate-a-github-personal-access-token)
   3. [Create SSH Keys for VPS Access](#create-ssh-keys-for-vps-access)
   4. [Add SSH Keys to Your VPS and GitHub](#add-ssh-keys-to-your-vps-and-github)
   5. [Generate a Runner Registration Token](#generate-a-runner-registration-token)
   6. [Manually Add Secrets to GitHub](#manually-add-secrets-to-github)
4. [Conclusion](#conclusion)

## Introduction

In this episode, we will set up the foundational components required for developing and deploying FountainAI. This includes creating a GitHub repository, configuring environment variables, and establishing secure communication with a VPS.

## Prerequisites

Ensure you have:
- A GitHub Account
- VPS (Virtual Private Server)
- Docker installed locally

## Step-by-Step Setup Guide

### Create GitHub Repository and Configuration File

1. **Create a new GitHub Repository**:
   - Go to your GitHub account and create a new repository named `fountainAI`.
   - Initialize the repository with a `README.md` file.

2. **Clone the Repository Locally**:
   - Clone the repository to your local machine:
     ```sh
     git clone https://github.com/Contexter/fountainAI.git
     cd fountainAI
     ```

3. **Create Configuration File**:
   - Create a file named `config.env` in your project directory. This file will store all the necessary configuration variables.
   - Add the following content to `config.env`:

```env
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
```

4. **Add `config.env` to `.gitignore`**:
   - Add the `config.env` file to `.gitignore` to ensure it is not tracked by git, preventing sensitive information from being exposed.
     ```sh
     echo "config.env" >> .gitignore
     ```

5. **Commit and Push the Changes**:
   - Commit the changes and push them to GitHub:
     ```sh
     git add .
     git commit -m "Initial setup with config.env and .gitignore"
     git push origin main
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
   - Copy the generated token and store it **immediately & securely** in your `config.env` file.

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