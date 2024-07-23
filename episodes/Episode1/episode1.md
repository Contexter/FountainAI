### `episodes/episode1.md`

# Episode 1: Initial Setup and Manual GitHub Secrets Creation
> also read: 
> [The Ultimate Guide to GitHub Tokens](https://github.com/Contexter/fountainAI/blob/editorial/episodes/Episode1/The%20Ultimate%20Guide%20to%20GitHub%20Tokens.md)
> [The Ultimate Guide to GitHub Runners](https://github.com/Contexter/fountainAI/blob/editorial/episodes/Episode1/The%20Ultimate%20Guide%20to%20GitHub%20Runners.md)
> [The Ultimate Guide to CI/CD and GitHub Workflows](https://github.com/Contexter/fountainAI/blob/editorial/episodes/Episode1/The%20Ultimate%20Guide%20to%20CI_CD%20and%20GitHub%20Workflows.md)

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

In this episode, we will set up the foundational components required for developing and deploying your application. This includes creating a GitHub repository, configuring environment variables, and establishing secure communication with a VPS.

## Prerequisites

Ensure you have:
- A GitHub Account
- VPS (Virtual Private Server)
- Docker installed locally

## Step-by-Step Setup Guide

### Create GitHub Repository and Configuration File

1. **Create a new GitHub Repository**:
   - Go to your GitHub account and create a new repository named `<your-repo-name>`.
   - Initialize the repository with a `README.md` file.

2. **Clone the Repository Locally**:
   - Clone the repository to your local machine:
     ```sh
     git clone https://github.com/<your-username>/<your-repo-name>.git
     cd <your-repo-name>
     ```

3. **Create Configuration File**:
   - Create a file named `config.env` in your project directory. This file will act as a temporary storage for the sensitive data generated during this setup process.
   - Add the following content to `config.env`:

```env
# Placeholder for sensitive data

# GitHub personal access token (generated in Step 2)
G_TOKEN=

# Private SSH key for accessing the VPS (generated in Step 3)
VPS_SSH_KEY='-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----'

# Runner registration token (generated in Step 5)
RUNNER_TOKEN=
```

This `config.env` file acts as a temporary paste board to keep track of the sensitive data that you generate during this setup process. It also serves as a backup for these secrets, allowing you to easily reference them when adding them to GitHub.

**Security Implications:**
- Ensure that `config.env` is added to `.gitignore` to prevent it from being tracked by git. This is crucial to avoid exposing sensitive information.
- Handle this file with care. Do not share it or commit it to any public repository. 

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
   - Give your token a descriptive name, such as `<your-project-name> Project Token`.
   - Set the expiration date as needed (e.g., 90 days).
   - Select the scopes/permissions for the token.

5. **Generate and Copy the Token**:
   - Click on `Generate token`.
   - Copy the generated token and store it **immediately & securely** in your `config.env` file under `G_TOKEN`.

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

3. **Add the generated private key to the `config.env` file**:
   - Use the following command to get the private key and store it in the `config.env` file:
     ```sh
     cat ~/.ssh/id_ed25519
     ```
   - Copy the output and paste it into `config.env` under `VPS_SSH_KEY`.

```env
VPS_SSH_KEY='-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----'
```

### Add SSH Keys to Your VPS and GitHub

#### Part A: Add the Public Key to Your VPS

1. **Copy the Public Key**:
   - Run the following command to display the public key:
     ```sh
     cat ~/.ssh/id_ed25519.pub
     ```
   - Copy the output to your clipboard.

2. **Connect to Your VPS**:
   - Use an SSH client to connect to your VPS:
     ```sh
     ssh <your_vps_username>@<your_vps_ip>
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

#### Part B: Add the Private Key to GitHub Secrets

1. **Copy the Private Key**:
   - On your local machine, run the following command to display the private key:
     ```sh
     cat ~/.ssh/id_ed25519
     ```
   - Copy the output to your clipboard.

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
   - Follow the instructions to download and configure the runner. Note the `RUNNER_TOKEN` generated in the process. 

2. **Store the Runner Token**:
   - Add this token to the `config.env` file under the `RUNNER_TOKEN` variable to keep track of it.

```env
RUNNER_TOKEN=your_generated_runner_token
```

3. **Set Up the Runner as a Systemd Service**:
   - Follow the instructions provided by GitHub to configure and run the self-hosted runner.
   - Create a systemd service file on your VPS to ensure the runner runs as a service:
     ```sh
     sudo nano /etc/systemd/system/github-runner.service
     ```
   - Add the relevant content to the service file.
   - Reload the systemd daemon, enable the service to start on boot, and start the service:
     ```sh
     sudo systemctl daemon-reload
     sudo systemctl enable github-runner
     sudo systemctl start github-runner
     sudo systemctl status github-runner
     ```

### Manually Add Secrets to GitHub

For security reasons, sensitive information such as tokens, keys, and passwords should not be stored directly in the source code. Instead, GitHub allows you to store these secrets securely. These secrets can then be used in GitHub Actions workflows to inject dependencies and other sensitive information.

1. **Navigate to Your Repository Settings**:
   - Go to your GitHub repository in your web browser.
   - Click on **Settings**.

2. **Access Secrets and Variables**:
   - In the left sidebar, click on **Secrets and variables**.
   - Click on **Actions**.

3. **Add a New Repository Secret**:
   - Click on **New repository secret**.
   - For each variable in your `config.env` file, add a new secret with the same name and value.

This ensures that your GitHub Actions workflows can access these sensitive values securely.

## Conclusion

In this episode, we have set up the foundational components required for developing and deploying your application. We created a GitHub repository, configured environment variables, generated necessary tokens, and established secure communication with a VPS. 