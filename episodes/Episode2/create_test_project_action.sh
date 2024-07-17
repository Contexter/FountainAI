#!/bin/bash

# Create the action.yml file for the Test Project action
cat <<EOL > .github/actions/test/action.yml
name: 'Test Project'
description: 'Action to test the project'
runs:
  using: 'node20'
  main: 'index.js'
EOL

# Create the index.js file for the Test Project action
cat <<EOL > .github/actions/test/index.js
const core = require('@actions/core');

try {
  // Add test commands here
  core.info('Project test process started');
} catch (error) {
  core.setFailed(error.message);
}
EOL

echo "Test Project action created successfully!"
