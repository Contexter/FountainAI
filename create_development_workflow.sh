#!/bin/bash

# Create development.yml workflow
cat <<EOL > .github/workflows/development.yml
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
          github_token: \${{ secrets.GITHUB_TOKEN }}
          vps_ssh_key: \${{ secrets.VPS_SSH_KEY }}
          vps_username: \${{ secrets.VPS_USERNAME }}
          vps_ip: \${{ secrets.VPS_IP }}
          deploy_dir: \${{ secrets.DEPLOY_DIR }}
          repo_owner: \${{ secrets.REPO_OWNER }}
          app_name: \${{ secrets.APP_NAME }}
          domain: \${{ secrets.DOMAIN }}
          staging_domain: \${{ secrets.STAGING_DOMAIN }}
          db_name: \${{ secrets.DB_NAME }}
          db_user: \${{ secrets.DB_USER }}
          db_password: \${{ secrets.DB_PASSWORD }}
          email: \${{ secrets.EMAIL }}
          main_dir: \${{ secrets.MAIN_DIR }}
          nydus_port: \${{ secrets.NYDUS_PORT }}
          redisai_port: \${{ secrets.REDISAI_PORT }}
          redis_port: \${{ secrets.REDIS_PORT }}
          repo_name: \${{ secrets.REPO_NAME }}
          runner_token: \${{ secrets.RUNNER_TOKEN }}

  setup:
    needs: verify-secrets
    runs-on: ubuntu-latest
    steps:
      - name: Setup Environment
        uses: ./.github/actions/setup
        with:
          vps_ssh_key: \${{ secrets.VPS_SSH_KEY }}

  build:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - name: Build Project
        uses: ./.github/actions/build
EOL

echo "development.yml workflow created successfully!"
