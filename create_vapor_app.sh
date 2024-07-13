#!/bin/bash

# Load configuration from config.env
source config.env

# Check if Vapor is installed
if ! command -v vapor &> /dev/null
then
    echo "Vapor toolbox could not be found. Please install it first."
    exit 1
fi

# Create a new Vapor project interactively
vapor new $APP_NAME

# Verify the directory was created
if [ ! -d "$APP_NAME" ]; then
    echo "Directory $APP_NAME was not created."
    exit 1
fi

# Remove the .git directory to prevent it from being recognized as a submodule
rm -rf $APP_NAME/.git

# Indicate that the Vapor app was created
echo "Vapor application $APP_NAME created successfully."

# Navigate back to the root directory
cd ..

# Manually add the new directory to the containing Git repository
git add $APP_NAME

# Check Git status to see the new files
git status

# Commit the changes
git commit -m "Add newly created Vapor application"

# Refresh the Git status again to ensure everything is tracked
git status

echo "Directory $APP_NAME should now be tracked by Git."
