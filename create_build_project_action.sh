#!/bin/bash

# Create the action.yml file for the Build Project action
cat <<EOL > .github/actions/build/action.yml
name: 'Build Project'
description: 'Action to build the project'
runs:
  using: 'node20'
  main: 'index.js'
EOL

# Create the index.js file for the Build Project action
cat <<EOL > .github/actions/build/index.js
const core = require('@actions/core');

try {
  // Add build commands here
  core.info('Project build process started');
} catch (error) {
  core.setFailed(error.message);
}
EOL

echo "Build Project action created successfully!"
