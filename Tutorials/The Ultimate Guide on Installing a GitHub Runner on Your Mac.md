# The Ultimate Guide on Installing a GitHub Runner on Your Mac

This guide will take you through the steps to install Homebrew, Docker, and configure a GitHub Runner on your Mac. This setup is essential for integrating GitHub Actions with a self-hosted runner on your macOS.

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Step-by-Step Installation Guide](#step-by-step-installation-guide)
   1. [Install Homebrew](#install-homebrew)
   2. [Install Docker](#install-docker)
   3. [Configure a GitHub Runner on macOS](#configure-a-github-runner-on-macos)
4. [Optional: Configure the Runner as a Service](#optional-configure-the-runner-as-a-service)
5. [Conclusion](#conclusion)

## Introduction

This guide provides a comprehensive walkthrough to set up a GitHub Runner on your Mac. Starting from scratch, you will install Homebrew, Docker, and then configure the runner to work with your GitHub repository.

## Prerequisites

Ensure you have:
- A GitHub Account

## Step-by-Step Installation Guide

### Install Homebrew

Homebrew is a package manager for macOS. Follow these steps to install it:

1. Open Terminal.
2. Install Homebrew by running the following command:
   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. Follow the on-screen instructions to complete the installation.
4. Add Homebrew to your PATH by following the instructions provided at the end of the installation process. Typically, you need to add something like this to your shell profile (`~/.zshrc` or `~/.bash_profile`):
   ```sh
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```

### Install Docker

Next, install Docker using Homebrew:

1. Install Docker:
   ```sh
   brew install --cask docker
   ```

2. Start Docker:
   - Open Docker from the Applications folder.
   - Follow the on-screen instructions to complete the setup.

### Configure a GitHub Runner on macOS

After setting up Homebrew and Docker, you can now configure the GitHub runner:

1. **Navigate to Your GitHub Repository**:
   - Go to your GitHub repository in your web browser.
   - Click on **Settings**.

2. **Access Actions Runners**:
   - In the left sidebar, click on **Actions**.
   - Then, click on **Runners**.
   - Click on **New self-hosted runner**.

3. **Select macOS**:
   - Under **Choose your runner's operating system**, select **macOS**.

4. **Download the Runner**:
   - Follow the instructions to download the runner application. For macOS, it typically provides a URL to download a `.tar.gz` file. Use the following command to download it:
     ```sh
     curl -o actions-runner-osx-x64-2.296.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.296.1/actions-runner-osx-x64-2.296.1.tar.gz
     ```

5. **Create a Directory for the Runner**:
   - Create a directory for the runner application and navigate into it:
     ```sh
     mkdir actions-runner && cd actions-runner
     ```

6. **Extract the Runner**:
   - Extract the downloaded `.tar.gz` file:
     ```sh
     tar xzf ../actions-runner-osx-x64-2.296.1.tar.gz
     ```

7. **Configure the Runner**:
   - Configure the runner using the registration token provided by GitHub. This token can be found in the instructions on the GitHub repository settings page:
     ```sh
     ./config.sh --url https://github.com/your-repo-owner/your-repo-name --token YOUR_REGISTRATION_TOKEN
     ```

8. **Run the Runner**:
   - Start the runner application:
     ```sh
     ./run.sh
     ```

   - The runner will connect to GitHub and be ready to accept jobs.

## Optional: Configure the Runner as a Service

To ensure the runner starts automatically and runs in the background, you can configure it to run as a service using `launchd` on macOS.

1. **Create a `launchd` Service File**:
   - Create a `launchd` service file in `/Library/LaunchDaemons/` directory. For example:
     ```sh
     sudo nano /Library/LaunchDaemons/github.runner.plist
     ```

2. **Add the Service Configuration**:
   - Add the following content to the `plist` file, replacing `your_user` and `your_runner_directory` with your actual username and the path to your runner directory:
     ```xml
     <?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">
       <dict>
         <key>Label</key>
         <string>github.runner</string>
         <key>ProgramArguments</key>
         <array>
           <string>/Users/your_user/actions-runner/run.sh</string>
         </array>
         <key>RunAtLoad</key>
         <true/>
         <key>KeepAlive</key>
         <true/>
         <key>UserName</key>
         <string>your_user</string>
         <key>WorkingDirectory</key>
         <string>/Users/your_user/actions-runner</string>
         <key>StandardOutPath</key>
         <string>/Users/your_user/actions-runner/runner.log</string>
         <key>StandardErrorPath</key>
         <string>/Users/your_user/actions-runner/runner.err</string>
       </dict>
     </plist>
     ```

3. **Load the Service**:
   - Load the service with `launchd`:
     ```sh
     sudo launchctl load /Library/LaunchDaemons/github.runner.plist
     ```

4. **Start the Service**:
   - Start the service:
     ```sh
     sudo launchctl start github.runner
     ```

5. **Check the Service Status**:
   - Check the status to ensure it is running:
     ```sh
     sudo launchctl list | grep github.runner
     ```

## Conclusion

In this guide, you have successfully installed Homebrew, Docker, and configured a GitHub Runner on your macOS. Additionally, you have learned how to set up the runner as a service to ensure it starts automatically and runs in the background. This setup allows you to integrate GitHub Actions with a self-hosted runner on your Mac, facilitating seamless automation for your projects.