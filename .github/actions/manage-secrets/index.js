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
      core.setFailed(`${secret.toUpperCase()} is not set`);
    } else {
      core.info(`${secret.toUpperCase()} is set`);
    }
  });
} catch (error) {
  core.setFailed(error.message);
}
