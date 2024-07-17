#!/bin/bash

# Function to run a script if it hasn't been run before
run_once() {
  script_name=$1
  log_file=".setup_log"

  # Check if the script has been run before
  if grep -q "$script_name" "$log_file"; then
    echo "$script_name has already been run. Skipping..."
  else
    echo "Running $script_name..."
    bash "$script_name"
    echo "$script_name" >> "$log_file"
  fi
}

# Create .setup_log if it doesn't exist
touch .setup_log

# Run all setup scripts
run_once "setup_project_structure.sh"
run_once "create_manage_secrets_action.sh"
run_once "create_setup_environment_action.sh"
run_once "create_build_project_action.sh"
run_once "create_test_project_action.sh"
run_once "create_deploy_project_action.sh"
run_once "create_development_workflow.sh"
run_once "create_testing_workflow.sh"
run_once "create_staging_workflow.sh"
run_once "create_production_workflow.sh"

echo "All setup scripts have been executed."
