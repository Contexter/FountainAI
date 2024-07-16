#!/bin/bash

# Create the action.yml file for the Manage Secrets action
cat <<EOL > .github/actions/manage-secrets/action.yml
name: 'Manage Secrets'
description: 'Action to manage and validate secrets'
inputs:
  github_token:
    description: 'GitHub Token'
    required: true
    type: string
  vps_ssh_key:
    description: 'VPS SSH Key'
    required: true
    type: string
  vps_username:
    description: 'VPS Username'
    required: true
    type: string
  vps_ip:
    description: 'VPS IP Address'
    required: true
    type: string
  deploy_dir:
    description: 'Deployment Directory'
    required: true
    type: string
  repo_owner:
    description: 'Repository Owner'
    required: true
    type: string
  app_name:
    description: 'Application Name'
    required: true
    type: string
  domain:
    description: 'Production Domain'
    required: true
    type: string
  staging_domain:
    description: 'Staging Domain'
    required: true
    type: string
  db_name:
    description: 'Database Name'
    required: true
    type: string
  db_user:
    description: 'Database User'
    required: true
    type: string
  db_password:
    description: 'Database Password'
    required: true
    type: string
  email:
    description: 'Email'
    required: true
    type: string
  main_dir:
    description: 'Main Directory'
    required: true
    type: string
  nydus_port:
    description: 'Nydus Port'
    required: true
    type: string
  redisai_port:
    description: 'RedisAI Port'
    required: true
    type: string
  redis_port:
    description: 'Redis Port'
    required: true
    type: string
  repo_name:
    description: 'Repository Name'
    required: true
    type: string
  runner_token:
    description: 'Runner Token'
    required: true
    type: string
runs:
  using: 'node20'
  main: 'index.js'
EOL

# Create the index.js file for the Manage Secrets action
cat <<EOL > .github/actions/manage-secrets/index.js
const core = require('@actions/core');

try {
  const secrets = [
    'github_token',
    'vps_ssh_key',
    'vps_username',
    'vps_ip',
    'deploy_dir',
    'repo_owner',
    'app_name',
    'domain',
    'staging_domain',
    'db_name',
    'db_user',
    'db_password',
    'email',
    'main_dir',
    'nydus_port',
    'redisai_port',
    'redis_port',
    'repo_name',
    'runner_token'
  ];

  secrets.forEach(secret => {
    const value = core.getInput(secret);
    if (!value) {
      core.setFailed(\`\${secret.toUpperCase()} is not set\`);
    } else {
      core.info(\`\${secret.toUpperCase()} is set\`);
    }
  });
} catch (error) {
  core.setFailed(error.message);
}
EOL

echo "Manage Secrets action created successfully!"
