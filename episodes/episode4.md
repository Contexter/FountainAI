### `episodes/episode4.md`

# Episode 4: Decoupling Secrets Management from the CI/CD Pipeline

## Table of Contents

1. [Introduction](#introduction)
2. [Rationale for Decoupling](#rationale-for-decoupling)
3. [What is GPG?](#what-is-gpg)
4. [Creating the Central Secrets Repository](#creating-the-central-secrets-repository)
5. [Encrypting and Storing Secrets](#encrypting-and-storing-secrets)
6. [Updating the Manage Secrets Action](#updating-the-manage-secrets-action)
7. [Modifying CI/CD Workflows](#modifying-cicd-workflows)
   1. [Development Workflow](#development-workflow)
   2. [Testing Workflow](#testing-workflow)
   3. [Staging Workflow](#staging-workflow)
   4. [Production Workflow](#production-workflow)
8. [Conclusion](#conclusion)

---

## Introduction

In the previous episode, we focused on creating a basic "Hello, World!" Vapor application, Dockerizing it, and integrating it into our CI/CD pipeline. We introduced Docker Compose to manage multiple containers and ensured a smooth deployment process. This integration utilized secrets management to handle sensitive information securely.

In this episode, we will enhance our CI/CD pipeline by decoupling secrets management from the main repository. This will make our pipeline more flexible and reusable across multiple projects. We will create a centralized secrets repository and update our workflows to fetch and decrypt secrets dynamically. This approach ensures better security and maintainability of sensitive information.

## Rationale for Decoupling

Managing secrets directly within each repository's CI/CD pipeline can lead to several issues:
1. **Duplication of Secrets**: Each repository needs to manage its own set of secrets, leading to duplication and potential inconsistencies.
2. **Security Risks**: Storing secrets directly in each repository increases the risk of accidental exposure.
3. **Maintenance Overhead**: Updating secrets across multiple repositories can be tedious and error-prone.

By centralizing secrets management, we can:
1. **Reduce Duplication**: Store secrets in a single repository, ensuring consistency across multiple projects.
2. **Enhance Security**: Use encryption to secure secrets and control access to the central repository.
3. **Simplify Maintenance**: Update secrets in one place and propagate changes to all dependent repositories.

## What is GPG?

GPG (GNU Privacy Guard) is a tool for secure communication and data storage. It uses cryptographic techniques to provide data encryption, ensuring that sensitive information can be securely stored and transferred. GPG allows users to encrypt and decrypt data, create digital signatures, and manage keys.

### Key Features of GPG

- **Encryption**: GPG can encrypt data to ensure that only intended recipients can read it.
- **Decryption**: GPG can decrypt data that has been encrypted with the recipient's public key.
- **Digital Signatures**: GPG can create digital signatures to verify the authenticity of data.
- **Key Management**: GPG allows users to generate, store, and manage cryptographic keys.

### How GPG Works

GPG uses a system of public and private keys for encryption and decryption. Here’s a brief overview:

1. **Public Key**: Used to encrypt data. It can be shared openly.
2. **Private Key**: Used to decrypt data. It must be kept secret.

To encrypt data, you need the recipient's public key. The encrypted data can only be decrypted using the corresponding private key, ensuring that only the intended recipient can access the information.

## Creating the Central Secrets Repository

### Step 1: Create the Repository

1. **Create a new GitHub repository named `central-secrets`**:
   - Go to GitHub and create a new repository named `central-secrets`.
   - Initialize the repository with a `README.md` file.

2. **Clone the Repository Locally**:
   ```sh
   git clone https://github.com/YourUsername/central-secrets.git
   cd central-secrets
   ```

## Encrypting and Storing Secrets

### Step 2: Encrypt Secrets Using GPG

1. **Generate GPG Keys**:
   - If you don't have a GPG key pair, generate one:
     ```sh
     gpg --full-generate-key
     ```
   - Follow the prompts to create your GPG key pair.

2. **Export Your Public Key**:
   - Export your public key to share with others who need to encrypt secrets for you:
     ```sh
     gpg --export -a "Your Name" > public-key.asc
     ```

3. **Encrypt Secrets**:
   - Create a `secrets` directory in your `central-secrets` repository:
     ```sh
     mkdir secrets
     ```

   - Encrypt each secret using your public key and store it in the `secrets` directory. Below are the commands for encrypting the secrets from your `config.env` file:
     ```sh
     gpg --encrypt --armor --recipient "Your Name" <<< "fountainAI" > secrets/APP_NAME.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "Contexter" > secrets/REPO_OWNER.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "fountainAI" > secrets/REPO_NAME.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "your_generated_token" > secrets/G_TOKEN.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "-----BEGIN OPENSSH PRIVATE KEY-----\n...\n-----END OPENSSH PRIVATE KEY-----" > secrets/VPS_SSH_KEY.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "your_vps_username" > secrets/VPS_USERNAME.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "your_vps_ip" > secrets/VPS_IP.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "example.com" > secrets/DOMAIN.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "staging.example.com" > secrets/STAGING_DOMAIN.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "/home/your_vps_username/deployment_directory" > secrets/DEPLOY_DIR.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "mail@benedikt-eickhoff.de" > secrets/EMAIL.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "fountainai_db" > secrets/DB_NAME.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "fountainai_user" > secrets/DB_USER.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "your_db_password" > secrets/DB_PASSWORD.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "6379" > secrets/REDIS_PORT.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "6378" > secrets/REDISAI_PORT.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "your_generated_runner_token" > secrets/RUNNER_TOKEN.asc
     gpg --encrypt --armor --recipient "Your Name" <<< "2224" > secrets/NYDUS_PORT.asc
     ```

4. **Store Encrypted Secrets in the Repository**:
   - Add the encrypted secrets to the `central-secrets` repository:
     ```sh
     git add secrets
     git commit -m "Add encrypted secrets"
     git push origin main
     ```

## Updating the Manage Secrets Action

### Step 3: Modify the Manage Secrets Action

Update the `index.js` of the Manage Secrets action to fetch and decrypt secrets from the `central-secrets` repository.

```js
const core = require('@actions/core');
const exec = require('@actions/exec');
const fs = require('fs');

async function run() {
    try {
        const secretsRepo = core.getInput('central_repo');
        const gpgPrivateKey = core.getInput('gpg_private_key');
        const gpgPassphrase = core.getInput('gpg_passphrase');

        // Clone the central-secrets repository
        await exec.exec(`git clone https://github.com/${secretsRepo}.git`);

        // Import the GPG private key
        await exec.exec(`echo "${gpgPrivateKey}" | gpg --batch --import`);

        // Decrypt secrets
        const secrets = [
            'APP_NAME',
            'REPO_OWNER',
            'REPO_NAME',
            'G_TOKEN',
            'VPS_SSH_KEY',
            'VPS_USERNAME',
            'VPS_IP',
            'DOMAIN',
            'STAGING_DOMAIN',
            'DEPLOY_DIR',
            'EMAIL',
            'DB_NAME',
            'DB_USER',
            'DB_PASSWORD',
            'REDIS_PORT',
            'REDISAI_PORT',
            'RUNNER_TOKEN',
            'NYDUS_PORT'
        ];

        for (const secret of secrets) {
            await exec.exec(`gpg --batch --yes --decrypt --passphrase "${gpgPassphrase}" --output ${secret} central-secrets/secrets/${secret}.asc`);
            const value = fs.readFileSync(secret, 'utf8').trim();
            core.exportVariable(secret, value);
        }
    } catch (error) {
        core.setFailed(`Action failed with error ${error}`);
    }
}

run();
```

**Comments and Changes in the Code:**
1. **Clone the Repository**:
   - Clones the `central-secrets` repository to access the encrypted secrets.
   ```js


   await exec.exec(`git clone https://github.com/${secretsRepo}.git`);
   ```

2. **Import the GPG Private Key**:
   - Imports the GPG private key to decrypt the secrets.
   ```js
   await exec.exec(`echo "${gpgPrivateKey}" | gpg --batch --import`);
   ```

3. **Decrypt Secrets**:
   - Iterates over the list of secrets, decrypts each one, and exports it as an environment variable.
   ```js
   for (const secret of secrets) {
       await exec.exec(`gpg --batch --yes --decrypt --passphrase "${gpgPassphrase}" --output ${secret} central-secrets/secrets/${secret}.asc`);
       const value = fs.readFileSync(secret, 'utf8').trim();
       core.exportVariable(secret, value);
   }
   ```

## Modifying CI/CD Workflows

### Development Workflow

Update the `development.yml` workflow to use the centralized secrets.

```yaml
name: Development Workflow

on:
  push:
    branches:
      - development

jobs:
  verify-secrets:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Manage Secrets
        uses: ./.github/actions/manage-secrets
        with:
          central_repo: YourUsername/central-secrets
          gpg_private_key: ${{ secrets.GPG_PRIVATE_KEY }}
          gpg_passphrase: ${{ secrets.GPG_PASSPHRASE }}

  setup:
    needs: verify-secrets
    runs-on: ubuntu-latest
    steps:
      - name: Setup Environment
        uses: ./.github/actions/setup
        with:
          vps_ssh_key: ${{ env.VPS_SSH_KEY }}

  build:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - name: Build Project
        uses: ./.github/actions/build

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Test Project
        uses: ./.github/actions/test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Project
        uses: ./.github/actions/deploy
        with:
          environment: staging
          vps_username: ${{ env.VPS_USERNAME }}
          vps_ip: ${{ env.VPS_IP }}
          deploy_dir: ${{ env.DEPLOY_DIR }}
```

### Testing Workflow

Update the `testing.yml` workflow similarly to the development workflow.

```yaml
name: Testing Workflow

on:
  push:
    branches:
      - testing

jobs:
  verify-secrets:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Manage Secrets
        uses: ./.github/actions/manage-secrets
        with:
          central_repo: YourUsername/central-secrets
          gpg_private_key: ${{ secrets.GPG_PRIVATE_KEY }}
          gpg_passphrase: ${{ secrets.GPG_PASSPHRASE }}

  setup:
    needs: verify-secrets
    runs-on: ubuntu-latest
    steps:
      - name: Setup Environment
        uses: ./.github/actions/setup
        with:
          vps_ssh_key: ${{ env.VPS_SSH_KEY }}

  build:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - name: Build Project
        uses: ./.github/actions/build

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Test Project
        uses: ./.github/actions/test
```

### Staging Workflow

Update the `staging.yml` workflow similarly.

```yaml
name: Staging Workflow

on:
  push:
    branches:
      - staging

jobs:
  verify-secrets:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Manage Secrets
        uses: ./.github/actions/manage-secrets
        with:
          central_repo: YourUsername/central-secrets
          gpg_private_key: ${{ secrets.GPG_PRIVATE_KEY }}
          gpg_passphrase: ${{ secrets.GPG_PASSPHRASE }}

  setup:
    needs: verify-secrets
    runs-on: ubuntu-latest
    steps:
      - name: Setup Environment
        uses: ./.github/actions/setup
        with:
          vps_ssh_key: ${{ env.VPS_SSH_KEY }}

  build:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - name: Build Project
        uses: ./.github/actions/build

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Test Project
        uses: ./.github/actions/test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Project
        uses: ./.github/actions/deploy
        with:
          environment: staging
          vps_username: ${{ env.VPS_USERNAME }}
          vps_ip: ${{ env.VPS_IP }}
          deploy_dir: ${{ env.DEPLOY_DIR }}
```

### Production Workflow

Update the `production.yml` workflow similarly.

```yaml
name: Production Workflow

on:
  push:
    branches:
      - main

jobs:
  verify-secrets:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Manage Secrets
        uses: ./.github/actions/manage-secrets
        with:
          central_repo: YourUsername/central-secrets
          gpg_private_key: ${{ secrets.GPG_PRIVATE_KEY }}
          gpg_passphrase: ${{ secrets.GPG_PASSPHRASE }}

  setup:
    needs: verify-secrets
    runs-on: ubuntu-latest
    steps:
      - name: Setup Environment
        uses: ./.github/actions/setup
        with:
          vps_ssh_key: ${{ env.VPS_SSH_KEY }}

  build:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - name: Build Project
        uses: ./.github/actions/build

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Test Project
        uses: ./.github/actions/test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Project
        uses: ./.github/actions/deploy
        with:
          environment: production
          vps_username: ${{ env.VPS_USERNAME }}
          vps_ip: ${{ env.VPS_IP }}
          deploy_dir: ${{ env.DEPLOY_DIR }}
```

## Conclusion

In this episode, we enhanced our CI/CD pipeline by decoupling secrets management using a centralized secrets repository and GPG encryption. We created a new repository to store encrypted secrets and updated our workflows to dynamically fetch and decrypt these secrets. This approach ensures better security, reduces duplication, and simplifies the maintenance of sensitive information across multiple projects.

By following these steps, we have created a more flexible and reusable CI/CD pipeline that can be easily adapted for future projects.