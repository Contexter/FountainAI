const core = require('@actions/core');

try {
  const vpsSshKey = core.getInput('vps_ssh_key');
  if (!vpsSshKey) core.setFailed('VPS_SSH_KEY is not set');
  
  // Setup commands can be added here
  core.info('VPS setup with SSH key');
} catch (error) {
  core.setFailed(error.message);
}
