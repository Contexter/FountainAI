const core = require('@actions/core');

try {
  // Add deploy commands here
  core.info('Project deploy process started');
} catch (error) {
  core.setFailed(error.message);
}
