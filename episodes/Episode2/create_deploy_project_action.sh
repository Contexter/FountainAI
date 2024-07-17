#!/bin/bash

# Create the action.yml file for the Deploy Project action
cat <<EOL > .github/actions/deploy/action.yml
name: 'Deploy Project'
description: 'Action to deploy the project'
runs:
  using: 'node20'
  main: 'index.js'
EOL

# Create the index.js file for the Deploy Project action
cat <<EOL > .github/actions/deploy/index.js
const core = require('@actions/core');

try {
  // Add deploy commands here
  core.info('Project deploy process started');
} catch (error) {
  core.setFailed(error.message);
}
EOL

echo "Deploy Project action created successfully!"
