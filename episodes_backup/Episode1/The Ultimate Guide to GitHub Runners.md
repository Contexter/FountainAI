# The Ultimate Guide to GitHub Runners

GitHub Actions provide a flexible and powerful way to automate your development workflows. Central to GitHub Actions are runners, which execute the jobs in your workflows. This guide covers everything you need to know about GitHub runners, from understanding their types to setting up and managing self-hosted runners, including examples for different platforms.

## Table of Contents

1. [Introduction to GitHub Runners](#introduction-to-github-runners)
2. [Types of GitHub Runners](#types-of-github-runners)
    - [GitHub-Hosted Runners](#github-hosted-runners)
    - [Self-Hosted Runners](#self-hosted-runners)
3. [Setting Up Self-Hosted Runners](#setting-up-self-hosted-runners)
    - [On macOS](#setting-up-self-hosted-runners-on-macos)
    - [On Linux (Ubuntu 20.04 VPS Example)](#setting-up-self-hosted-runners-on-linux-ubuntu-2004-vps-example)
    - [On Windows](#setting-up-self-hosted-runners-on-windows)
4. [Managing Runners](#managing-runners)
    - [Runner Labels](#runner-labels)
    - [Runner Groups](#runner-groups)
    - [Security Best Practices](#security-best-practices)
5. [Using Runners in Workflows](#using-runners-in-workflows)
6. [Monitoring and Troubleshooting Runners](#monitoring-and-troubleshooting-runners)
7. [Conclusion](#conclusion)

## Introduction to GitHub Runners

Runners are servers that run your GitHub Actions workflows. When a workflow is triggered, a runner picks up the job and executes the steps defined in the workflow. GitHub provides both GitHub-hosted and self-hosted runners.

## Types of GitHub Runners

### GitHub-Hosted Runners

GitHub-hosted runners are provided by GitHub and run on virtual machines. They come with a pre-configured software environment that includes common languages, tools, and services.

#### Advantages:
- **No Maintenance**: GitHub manages the runners, including updates and scaling.
- **Quick Setup**: Ready to use with no additional configuration.
- **Pre-Configured**: Includes a wide range of tools and software.

#### Disadvantages:
- **Limited Customization**: You cannot customize the runner environment.
- **Usage Limits**: Subject to usage limits and quotas.

### Self-Hosted Runners

Self-hosted runners are servers that you set up and manage. They provide more control and customization over the runner environment.

#### Advantages:
- **Full Control**: Customize the runner environment to fit your needs.
- **No Usage Limits**: Not subject to GitHub-hosted runner usage limits.
- **Cost-Effective**: Can use existing infrastructure to run workflows.

#### Disadvantages:
- **Maintenance Required**: You are responsible for managing and updating the runners.
- **Security**: You need to ensure the runners are secure and isolated.

## Setting Up Self-Hosted Runners

### Setting Up Self-Hosted Runners on macOS

1. **Create a Directory for the Runner**

```sh
mkdir actions-runner && cd actions-runner
```

2. **Download the Latest Runner Package**

```sh
curl -o actions-runner-osx-x64-2.293.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.293.0/actions-runner-osx-x64-2.293.0.tar.gz
tar xzf ./actions-runner-osx-x64-2.293.0.tar.gz
```

3. **Configure the Runner**

```sh
./config.sh --url https://github.com/your-repo --token YOUR_RUNNER_TOKEN
```

4. **Install and Start the Runner**

```sh
./svc.sh install
./svc.sh start
```

### Setting Up Self-Hosted Runners on Linux (Ubuntu 20.04 VPS Example)

1. **Create a Directory for the Runner**

```sh
mkdir actions-runner && cd actions-runner
```

2. **Download the Latest Runner Package**

```sh
curl -o actions-runner-linux-x64-2.293.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.293.0/actions-runner-linux-x64-2.293.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.293.0.tar.gz
```

3. **Configure the Runner**

Replace `YOUR_REPOSITORY_URL` and `YOUR_RUNNER_TOKEN` with your actual repository URL and runner token.

```sh
./config.sh --url https://github.com/YOUR_REPOSITORY_URL --token YOUR_RUNNER_TOKEN
```

4. **Install and Start the Runner**

```sh
./svc.sh install
./svc.sh start
```

### Setting Up Self-Hosted Runners on Windows

1. **Create a Directory for the Runner**

```powershell
mkdir actions-runner && cd actions-runner
```

2. **Download the Latest Runner Package**

```powershell
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.293.0/actions-runner-win-x64-2.293.0.zip -OutFile actions-runner-win-x64-2.293.0.zip
Expand-Archive -Path actions-runner-win-x64-2.293.0.zip -DestinationPath .
```

3. **Configure the Runner**

```powershell
.\config.cmd --url https://github.com/your-repo --token YOUR_RUNNER_TOKEN
```

4. **Install and Start the Runner**

```powershell
.\svc.cmd install
.\svc.cmd start
```

## Managing Runners

### Runner Labels

Labels are used to identify and categorize runners. They help in selecting the appropriate runner for a job in your workflows.

#### Adding Labels:

During the configuration step, you can add labels:

```sh
./config.sh --url https://github.com/YOUR_REPOSITORY_URL --token YOUR_RUNNER_TOKEN --labels label1,label2
```

### Runner Groups

Runner groups allow you to organize runners and control access to them. They can be created and managed in the GitHub repository or organization settings.

### Security Best Practices

- **Isolate Runners**: Use dedicated runners for sensitive workloads.
- **Restrict Access**: Limit who can use the runners.
- **Regular Updates**: Keep the runner software and dependencies updated.
- **Monitor Logs**: Regularly check runner logs for unusual activity.

## Using Runners in Workflows

You can specify the runner type and labels in your workflow files.

### Example Workflow Using GitHub-Hosted Runner

```yaml
name: CI

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Build and test
        run: |
          echo "Building the project..."
          # Add build and test commands here
```

### Example Workflow Using Self-Hosted Runner

```yaml
name: CI

on: [push]

jobs:
  build:
    runs-on: self-hosted
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Build and test
        run: |
          echo "Building the project..."
          # Add build and test commands here
```

### Example Workflow Using Runner Labels

```yaml
name: CI

on: [push]

jobs:
  build:
    runs-on: [self-hosted, linux, high-memory]

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Build and test
        run: |
          echo "Building the project on a high-memory runner..."
          # Add build and test commands here
```

## Monitoring and Troubleshooting Runners

### Monitoring Runners

- **Runner Status**: Check the status of your runners in the GitHub repository or organization settings.
- **Logs**: Review logs to monitor runner activities and diagnose issues.
- **Metrics**: Use monitoring tools to track runner performance and resource usage.

### Troubleshooting Common Issues

- **Runner Offline**: Ensure the runner service is running and properly configured.
- **Job Failures**: Check logs for error messages and ensure dependencies are installed.
- **Resource Limits**: Monitor resource usage to ensure the runner has enough capacity.

## Conclusion

GitHub runners are essential components of GitHub Actions, enabling you to execute your workflows. By understanding the different types of runners and how to set up and manage them, you can optimize your CI/CD pipelines for performance, security, and efficiency. This ultimate guide provides you with the knowledge to effectively use both GitHub-hosted and self-hosted runners in your workflows, including detailed examples for macOS, Linux (Ubuntu 20.04 VPS), and Windows. Happy automating!