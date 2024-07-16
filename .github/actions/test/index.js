const core = require('@actions/core');

try {
  // Add test commands here
  core.info('Project test process started');
} catch (error) {
  core.setFailed(error.message);
}
