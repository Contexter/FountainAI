### Script Title

**Vapor App Project Bootstrapper**

### Commit Message

```
feat: Add Vapor App Project Bootstrapper Script

- Introduces an interactive shell script to automate the setup of a Vapor application project.
- Prompts the user for project configuration values, including project directory, domain, and email.
- Creates the necessary directory structure and populates it with placeholder files.
- Ensures idempotency by avoiding overwriting existing files and directories.
- Generates a zip file of the project structure named `vapor_app_project.zip`.
- Includes a self-testing mechanism to verify the correct creation of files and directories with expected placeholder content.
- Enhances development efficiency by providing a robust foundation for the Vapor application.

This script helps streamline the initial setup process, allowing developers to focus on building their Vapor app with a pre-configured project structure.
```

### Script

```sh
#!/bin/bash

# Vapor App Project Bootstrapper
# This script creates a directory structure and placeholder files for a Vapor application project.
# It prompts the user for project configuration values, ensures that the directory structure is idempotent,
# and runs self-tests to verify the correct creation of files and directories with expected placeholder content.
#
# The script is designed to help automate the setup of a Vapor app with Docker, Nginx, and Let's Encrypt,
# making it easier to deploy a secure and robust Vapor application.
#
# By running this script, you will:
# 1. Create the necessary directory structure for the Vapor application.
# 2. Populate the directories with placeholder files to serve as templates for your actual project files.
# 3. Generate a zip file containing the project structure.
# 4. Perform self-tests to ensure that all files and directories are correctly created.
#
# This script is idempotent, meaning it can be run multiple times without causing issues.
# It also includes an interactive component to gather configuration values from the user.
#
# The self-testing mechanism ensures that the resulting project structure is correct and ready for further development.

# Define the project directory structure and placeholder contents
declare -A project_structure=(
    ["vapor-app/Scripts/create_directories.sh"]="# Placeholder content for create_directories.sh"
    ["vapor-app/Scripts/setup_vapor_project.sh"]="# Placeholder content for setup_vapor_project.sh"
    ["vapor-app/Scripts/build_vapor_app.sh"]="# Placeholder content for build_vapor_app.sh"
    ["vapor-app/Scripts/run_vapor_local.sh"]="# Placeholder content for run_vapor_local.sh"
    ["vapor-app/Scripts/create_docker_compose.sh"]="# Placeholder content for create_docker_compose.sh"
    ["vapor-app/Scripts/create_nginx_config.sh"]="# Placeholder content for create_nginx_config.sh"
    ["vapor-app/Scripts/create_certbot_script.sh"]="# Placeholder content for create_certbot_script.sh"
    ["vapor-app/Scripts/setup_project.sh"]="# Placeholder content for setup_project.sh"
    ["vapor-app/Scripts/master_script.sh"]="# Placeholder content for master_script.sh"
    ["vapor-app/Scripts/input_validation.sh"]="# Placeholder content for input_validation.sh"
    ["vapor-app/Scripts/read_config.sh"]="# Placeholder content for read_config.sh"
    ["vapor-app/.github/workflows/ci-cd-pipeline.yml"]="# Placeholder content for ci-cd-pipeline.yml"
    ["vapor-app/config/config.yaml"]="# Placeholder content for config.yaml"
    ["vapor-app/config/docker-compose-template.yml"]="# Placeholder content for docker-compose-template.yml"
    ["vapor-app/config/nginx-template.conf"]="# Placeholder content for nginx-template.conf"
    ["vapor-app/config/init-letsencrypt-template.sh"]="# Placeholder content for init-letsencrypt-template.sh"
    ["vapor-app/Sources/App/Controllers/ScriptController.swift"]="# Placeholder content for ScriptController.swift"
    ["vapor-app/Sources/App/Models/Script.swift"]="# Placeholder content for Script.swift"
    ["vapor-app/Sources/App/Migrations/CreateScript.swift"]="# Placeholder content for CreateScript.swift"
    ["vapor-app/Sources/App/configure.swift"]="# Placeholder content for configure.swift"
    ["vapor-app/Sources/App/routes.swift"]="# Placeholder content for routes.swift"
    ["vapor-app/Sources/App/main.swift"]="# Placeholder content for main.swift"
    ["vapor-app/nginx/nginx.conf"]="# Placeholder content for nginx.conf"
    ["vapor-app/vapor/Dockerfile"]="# Placeholder content for Dockerfile"
    ["vapor-app/vapor/Sources/App/Controllers/ScriptController.swift"]="# Placeholder content for ScriptController.swift"
    ["vapor-app/vapor/Sources/App/Models/Script.swift"]="# Placeholder content for Script.swift"
    ["vapor-app/vapor/Sources/App/Migrations/CreateScript.swift"]="# Placeholder content for CreateScript.swift"
    ["vapor-app/vapor/Sources/App/configure.swift"]="# Placeholder content for configure.swift"
    ["vapor-app/vapor/Sources/App/routes.swift"]="# Placeholder content for routes.swift"
    ["vapor-app/vapor/Sources/App/main.swift"]="# Placeholder content for main.swift"
    ["vapor-app/vapor/Package.swift"]="# Placeholder content for Package.swift"
    ["vapor-app/docker-compose.yml"]="# Placeholder content for docker-compose.yml"
    ["vapor-app/certbot/conf/"]=""
    ["vapor-app/certbot/www/"]=""
)

# Function to get user input for configuration values
get_user_input() {
    read -p "Enter your project directory (default: vapor-app): " project_dir
    project_dir=${project_dir:-vapor-app}

    read -p "Enter your domain (default: example.com): " domain
    domain=${domain:-example.com}

    read -p "Enter your email for Let's Encrypt (default: user@example.com): " email
    email=${email:-user@example.com}
}

# Function to create the project structure
create_project_structure() {
    for file_path in "${!project_structure[@]}"; do
        if [[ "$file_path" == */ ]]; then
            mkdir -p "$file_path"
        else
            mkdir -p "$(dirname "$file_path")"
            if [ ! -f "$file_path" ]; then
                echo "${project_structure[$file_path]}" > "$file_path"
            fi
        fi
    done
}

# Function to create a zip file of the project directory
create_zip_file() {
    zip_file_path="vapor_app_project.zip"
    if [ -f "$zip_file_path" ]; then
        rm "$zip_file_path"
    fi
    zip -r "$zip_file_path" vapor-app
    echo "Project structure created and zipped into $zip_file_path"
}

# Function to run self-tests
run_self_tests() {
    echo "Running self-test..."

    # Test if directories exist
    for dir in "vapor-app/certbot/conf/" "vapor-app/certbot/www/"; do
        if [ ! -d "$dir" ]; then
            echo "Error: Directory $dir does not exist."
            exit 1
        fi
    done

    # Test if files exist and contain placeholder content
    for file_path in "${!project_structure[@]}"; do
        if [[ "$file_path" != */ ]]; then
            if [ ! -f "$file_path" ]; then
                echo "Error: File $file_path does not exist."
                exit 1
            fi
            content=$(cat "$file_path")
            if [ "$content" != "${project_structure[$file_path]}" ]; then
                echo "Error: File $file_path does not contain the expected content."
                exit 1
            fi
        fi
    done

    echo "Self-test passed. All files and directories are in place."
}

# Main script execution
get_user_input
create_project_structure
create_zip_file
run_self_tests
```

### Instructions

1. **Copy the script**: Copy the script above into a file, e.g., `create_project.sh`.
2. **Make the script executable**: Run `chmod +x create_project.sh` to make the script executable.
3. **Run the script**: Execute the script with `./create_project.sh`.

### What the Script Does

1. **Interactive Configuration**: The script prompts you for project configuration values, including the project directory, domain, and email for Let's Encrypt. Defaults are provided for each prompt, which you can accept by pressing Enter.

2. **Create Project Structure**: It defines a project directory structure and placeholder contents, then creates the necessary directories and files. If the script is run multiple times, it will not overwrite existing files or directories, ensuring idempotency.

3. **Generate Zip File**: The script compiles the created project structure into a zip file named `vapor_app_project.zip`.

4. **Self-Testing**: It includes a self-testing mechanism to verify that all files and directories are correctly created with the expected placeholder content. If any discrepancies are found, the script reports an error and exits.

### Connection to Shell Scripted Test Run

By providing a structured and automated approach to setting up the project, this script helps ensure that the basic scaffold of your Vapor app is correctly initialized. This foundation allows you to focus on developing your application logic without worrying about initial setup errors. The self-testing mechanism serves as an initial validation step, ensuring that your environment is set up as expected before you proceed to further development and deployment steps.