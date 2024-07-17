#!/bin/bash

# Create the action.yml file for the Setup Environment action
cat <<EOL > .github/actions/setup/action.yml
name: 'Setup Environment'
description: 'Action to setup the environment'
inputs:
  vps_ssh_key:
    description: 'VPS SSH Key'
    required: true
    type: string
runs:
  using: 'node20'
  main: 'index.js'
EOL

# Create the index.js file for the Setup Environment action
cat <<EOL > .github/actions/setup/index.js
const core = require('@actions/core');

try {
  const vpsSshKey = core.getInput('vps_ssh_key');
  if (!vpsSshKey) core.setFailed('VPS_SSH_KEY is not set');
  
  // Setup commands can be added here
  core.info('VPS setup with SSH key');
} catch (error) {
  core.setFailed(error.message);
}
EOL

echo "Setup Environment action created successfully!"
