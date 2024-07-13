#!/bin/bash

# Load configuration from config.env
source config.env

# Check if Vapor is installed
if ! command -v vapor &> /dev/null
then
    echo "Vapor toolbox could not be found. Please install it first."
    exit
fi

# Create a new Vapor project interactively
vapor new $APP_NAME

# Indicate that the Vapor app was created
echo "Vapor application $APP_NAME created successfully."

# Return to the root directory
cd ..
