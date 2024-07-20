# The Ultimate Guide to GitHub Workflows, Custom Actions, and Secrets

GitHub Actions provide a powerful, flexible way to automate your software development workflows directly in your GitHub repository. This guide covers everything you need to know about creating custom actions, building comprehensive workflows, and securely managing secrets using GitHub Secrets.

## Table of Contents

1. [Introduction to GitHub Actions and Workflows](#introduction-to-github-actions-and-workflows)
2. [Setting Up Your Development Environment on macOS](#setting-up-your-development-environment-on-macos)
3. [Understanding GitHub Workflows](#understanding-github-workflows)
4. [Creating Custom GitHub Actions](#creating-custom-github-actions)
    - [JavaScript Actions](#creating-a-javascript-action)
    - [Docker Container Actions](#creating-a-docker-container-action)
    - [Composite Actions](#creating-a-composite-action)
5. [Using GitHub Secrets](#using-github-secrets)
6. [Building Comprehensive Workflows](#building-comprehensive-workflows)
7. [Using Marketplace Actions](#using-marketplace-actions)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)
10. [Conclusion](#conclusion)

## Introduction to GitHub Actions and Workflows

GitHub Actions allow you to automate, customize, and execute software development workflows directly in your GitHub repository. Workflows are defined as YAML files in the `.github/workflows` directory of your repository.

### Key Concepts

- **Workflow**: A process that runs one or more jobs.
- **Job**: A set of steps that execute on the same runner.
- **Step**: An individual task that can run commands or actions.
- **Runner**: A server that runs your workflows when triggered.
- **Secret**: Encrypted environment variables that store sensitive information securely.

## Setting Up Your Development Environment on macOS

To develop GitHub Actions and workflows, you'll need a basic development environment on macOS. This section outlines the setup process using Homebrew, a package manager for macOS.

### 1. Install Homebrew

If Homebrew is not already installed, you can install it by running the following command in your terminal:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

To verify that Homebrew is installed, run:

```sh
brew --version
```

### 2. Install Node.js

Node.js is required for creating JavaScript GitHub Actions. You can install Node.js using Homebrew:

```sh
brew install node
```

To verify the installation, run:

```sh
node --version
npm --version
```

### 3. Install Docker

Docker is required for creating Docker container actions. You can install Docker using Homebrew:

```sh
brew install --cask docker
```

After installing Docker, you need to start Docker. You can do this by opening the Docker application from your Applications folder or by running:

```sh
open /Applications/Docker.app
```

### 4. Install GitHub CLI

The GitHub CLI is a powerful tool for managing GitHub from the command line. You can install it using Homebrew:

```sh
brew install gh
```

To verify the installation, run:

```sh
gh --version
```

### Summary of Installation Commands

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install node
brew install --cask docker
brew install gh
```

## Understanding GitHub Workflows

### Workflow Structure

A workflow is defined by a YAML file in the `.github/workflows` directory. It consists of:

- **Triggers**: Events that trigger the workflow, such as `push`, `pull_request`, or a schedule.
- **Jobs**: Individual units of work, each with its own set of steps.
- **Steps**: Commands or actions that make up a job.

### Example Workflow

```yaml
name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '14'

      - name: Install dependencies
        run: npm install

      - name: Run tests
        run: npm test
```

## Creating Custom GitHub Actions

### JavaScript Actions

JavaScript actions run directly on the runner and are written in JavaScript or TypeScript.

#### Step-by-Step Guide

1. **Create the Repository**

```sh
mkdir my-js-action
cd my-js-action
git init
```

2. **Setup Action Metadata**

Create `action.yml`:

```yaml
# action.yml
name: 'My JavaScript Action'
description: 'A simple hello world action'
inputs:
  who-to-greet:
    description: 'The name of the person to greet'
    required: true
    default: 'World'
outputs:
  time:
    description: 'The time we greeted you'
runs:
  using: 'node12'
  main: 'index.js'
```

3. **Write the Action Code**

Create `index.js`:

```javascript
// index.js
const core = require('@actions/core');
const github = require('@actions/github');

try {
  const nameToGreet = core.getInput('who-to-greet');
  console.log(`Hello ${nameToGreet}!`);
  const time = (new Date()).toTimeString();
  core.setOutput('time', time);
} catch (error) {
  core.setFailed(error.message);
}
```

4. **Create the `package.json`**

Create `package.json`:

```json
{
  "name": "my-js-action",
  "version": "1.0.0",
  "description": "A simple hello world action",
  "main": "index.js",
  "dependencies": {
    "@actions/core": "^1.2.6",
    "@actions/github": "^2.2.0"
  }
}
```

5. **Publish the Action**

```sh
git add .
git commit -m "Initial commit"
git remote add origin <your-repository-url>
git push -u origin main
```

### Docker Container Actions

Docker container actions run in a Docker container, allowing you to use any environment and dependencies you need.

#### Step-by-Step Guide

1. **Create the Repository**

```sh
mkdir my-docker-action
cd my-docker-action
git init
```

2. **Setup Action Metadata**

Create `action.yml`:

```yaml
# action.yml
name: 'My Docker Action'
description: 'A simple hello world action in Docker'
inputs:
  who-to-greet:
    description: 'The name of the person to greet'
    required: true
    default: 'World'
runs:
  using: 'docker'
  image: 'Dockerfile'
  args:
    - ${{ inputs.who-to-greet }}
```

3. **Create the Dockerfile**

Create `Dockerfile`:

```Dockerfile
# Dockerfile
FROM debian:9.5-slim

RUN apt-get update && apt-get install -y \
  curl \
  && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
```

4. **Write the Entrypoint Script**

Create `entrypoint.sh`:

```sh
#!/bin/sh -l

echo "Hello $1"
```

5. **Build and Test Locally**

```sh
docker build -t my-docker-action .
docker run -e INPUT_WHO-TO-GREET=World my-docker-action
```

6. **Publish the Action**

```sh
git add .
git commit -m "Initial commit"
git remote add origin <your-repository-url>
git push -u origin main
```

### Composite Actions

Composite actions allow you to combine multiple steps and existing actions into a single action using YAML.

#### Step-by-Step Guide

1. **Create the Repository**

```sh
mkdir my-composite-action
cd my-composite-action
git init
```

2. **Setup Action Metadata**

Create `action.yml`:

```yaml
# action.yml
name: 'My Composite Action'
description: 'A composite action example'
runs:
  using: 'composite'
  steps:
    - name: Check out repository
      uses: actions/checkout@v2
    - name: Run a script
      run: echo "Hello, world!"
    - name: Use an existing action
      uses: actions/setup-node@v2
      with:
        node-version: '14'
```

3. **Publish the Action**

```sh
git add .
git commit -m "Initial commit"
git remote add origin <your-repository-url>
git push -u origin main
```

## Using GitHub Secrets

GitHub Secrets are the recommended way to handle sensitive environment variables securely in your GitHub Actions workflows. They provide a secure way to manage sensitive information like API keys, passwords, and tokens.

### Key Features of GitHub Secrets

- **Encryption**: Secrets are encrypted to ensure they are stored securely.
- **Masked in Logs**: Secrets are masked in logs to prevent accidental exposure.
- **Scoped Access**: Secrets can be scoped to a repository, organization, or environment level.
- **Environment Variables**: Secrets are accessible as environment variables within your workflows.

### Setting Up GitHub Secrets



1. **Navigate to Your Repository on GitHub**:
   - Go to your repository on GitHub.
   - Click on `Settings` in the repository menu.

2. **Access Secrets**:
   - In the left sidebar, click on `Secrets and variables` and then `Actions`.

3. **Add a New Secret**:
   - Click on `New repository secret`.
   - Provide a name for your secret (e.g., `API_KEY`) and enter the secret value.
   - Click `Add secret`.

### Using GitHub Secrets in Workflows

To use GitHub Secrets in your workflows, reference them in your YAML file using the `${{ secrets.SECRET_NAME }}` syntax.

### Example

```yaml
name: Deploy

on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Deploy to server
        env:
          API_KEY: ${{ secrets.API_KEY }}
        run: |
          echo "Deploying with API key: $API_KEY"
```

## Building Comprehensive Workflows

To build comprehensive workflows, you need to understand how to structure your jobs and steps effectively. Here are some advanced concepts:

### Job Dependencies

You can define dependencies between jobs to ensure they run in a specific order.

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Build project
        run: npm run build

  test:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Run tests
        run: npm test
```

### Matrix Builds

Matrix builds allow you to run jobs with different configurations, such as testing against multiple versions of a programming language.

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node: [10, 12, 14]
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: ${{ matrix.node }}
      - name: Install dependencies
        run: npm install
      - name: Run tests
        run: npm test
```

### Environment Variables

You can define environment variables at different levels in your workflow.

```yaml
env:
  GLOBAL_ENV: production

jobs:
  build:
    runs-on: ubuntu-latest
    env:
      BUILD_ENV: debug
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Print environment
        run: echo "Global: $GLOBAL_ENV, Build: $BUILD_ENV"
```

## Using Marketplace Actions

GitHub Marketplace offers a wide range of pre-built actions that you can use in your workflows. These actions can save you time and effort.

### Finding and Using Actions

1. **Search for Actions**: Browse the [GitHub Marketplace](https://github.com/marketplace?type=actions) to find actions that fit your needs.
2. **Add Actions to Your Workflow**: Use the `uses` keyword to include marketplace actions in your workflow.

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '14'
      - name: Run tests
        run: npm test
```

## Best Practices

- **Versioning**: Use semantic versioning and create tags for releases.
- **Testing**: Thoroughly test your actions locally and with example workflows.
- **Documentation**: Provide clear documentation in the `README.md` of your repository.
- **Security**: Ensure that your actions do not expose secrets or sensitive data.
- **Reusability**: Write actions that are reusable and configurable through inputs.
- **Limit Secret Exposure**: Only provide access to secrets where necessary. Minimize the scope to reduce potential exposure.
- **Rotate Secrets Regularly**: Periodically update and rotate secrets to reduce the risk of unauthorized access.
- **Use Descriptive Names**: Use clear, descriptive names for secrets to make their purpose obvious.
- **Monitor and Audit**: Regularly review and audit the use of secrets in your workflows.
- **Avoid Hardcoding Secrets**: Never hardcode sensitive information in your workflows or codebase. Always use secrets to manage sensitive data.

## Troubleshooting

- **Action Fails to Run**: Check for syntax errors and ensure all files are correctly named and located.
- **Permissions Issues**: Ensure your runner has the necessary permissions to execute the tasks.
- **Secrets Not Working**: Verify that secrets are correctly set up in your repository and referenced properly in the workflow.

## Example Workflow Using GitHub Secrets

Here is a comprehensive example of a workflow that uses GitHub Secrets to manage sensitive information securely:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest

    env:
      NODE_ENV: production

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '14'

      - name: Install dependencies
        run: npm install

      - name: Run tests
        run: npm test

  deploy:
    runs-on: ubuntu-latest
    needs: build

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Deploy to server
        env:
          API_KEY: ${{ secrets.API_KEY }}
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
        run: |
          echo "Deploying with API key: $API_KEY"
          echo "Connecting to database at: $DATABASE_URL"
          # Add deployment commands here
```

In this workflow:
- Secrets `API_KEY` and `DATABASE_URL` are securely accessed in the deployment step.
- The secrets are referenced as environment variables using the `${{ secrets.SECRET_NAME }}` syntax.

## Conclusion

Creating and using GitHub Actions and workflows allows you to automate and streamline your development processes, making your development pipeline more efficient. GitHub Secrets provide a secure and recommended way to manage sensitive information in your workflows. By following best practices and leveraging the full range of capabilities offered by GitHub Actions, you can build powerful, flexible, and secure workflows tailored to your needs.

With this ultimate guide, you should have a comprehensive understanding of how to implement custom GitHub actions, build advanced workflows, and securely manage secrets. Happy coding!