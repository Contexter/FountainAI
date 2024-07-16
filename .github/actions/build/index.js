const core = require('@actions/core');

try {
  // Add build commands here
  core.info('Project build process started');
} catch (error) {
  core.setFailed(error.message);
}
