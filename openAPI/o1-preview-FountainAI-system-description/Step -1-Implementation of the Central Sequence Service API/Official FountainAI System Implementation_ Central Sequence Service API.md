# Official FountainAI System Implementation: Central Sequence Service API

---

## Introduction

This document provides the implementation of the **Central Sequence Service API** as per the **Official FountainAI System Description and Implementation Plan**. We will use shell scripts to generate a FastAPI application that exactly matches the provided OpenAPI specification. The shell scripts follow the **FountainAI convention** for shell scripting, ensuring modularity, idempotency, and deterministic execution.

---

## Table of Contents

1. [Shell Scripts Overview](#shell-scripts-overview)
2. [Shell Script: `initialize_project.sh`](#shell-script-initialize_projectsh)
3. [Shell Script: `generate_fastapi_app.sh`](#shell-script-generate_fastapi_appsh)
4. [Instructions for Running the Scripts](#instructions-for-running-the-scripts)
5. [Explanations](#explanations)
6. [Conclusion](#conclusion)

---

## Shell Scripts Overview

We will use the following shell scripts:

1. **`initialize_project.sh`**: Initializes the project directory, virtual environment, and installs dependencies.
2. **`generate_fastapi_app.sh`**: Generates the FastAPI application based on the OpenAPI specification.

All scripts are idempotent and can be run multiple times without causing unintended side effects.

---

## Shell Script: `initialize_project.sh`

```bash
#!/bin/bash

# Function to create a directory if it does not exist
create_directory() {
    local dir_path="$1"
    if [ ! -d "$dir_path" ]; then
        mkdir -p "$dir_path"
        echo "Directory $dir_path created."
    else
        echo "Directory $dir_path already exists."
    fi
}

# Function to create a virtual environment if it does not exist
create_virtualenv() {
    local venv_path="$1"
    if [ ! -d "$venv_path" ]; then
        python3 -m venv "$venv_path"
        echo "Virtual environment created at $venv_path."
    else
        echo "Virtual environment at $venv_path already exists."
    fi
}

# Function to install Python dependencies
install_dependencies() {
    local requirements_file="$1"
    if [ ! -f "$requirements_file" ]; then
        cat <<EOL > "$requirements_file"
fastapi
uvicorn
pydantic
sqlalchemy
EOL
        echo "Created requirements.txt with default dependencies."
    else
        echo "requirements.txt already exists."
    fi
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r "$requirements_file"
}

# Main function to initialize the project
initialize_project() {
    local project_name="central_sequence_service"
    create_directory "$project_name"
    cd "$project_name" || exit

    create_virtualenv "venv"
    install_dependencies "requirements.txt"

    create_directory "app"
    touch app/__init__.py
    echo "Project initialization complete."
}

# Execute the main function
initialize_project
```

---

## Shell Script: `generate_fastapi_app.sh`

```bash
#!/bin/bash

# Function to generate Pydantic models from OpenAPI spec
generate_pydantic_models() {
    local openapi_file="$1"
    local output_file="$2"

    if [ ! -f "$openapi_file" ]; then
        echo "OpenAPI specification file $openapi_file not found."
        exit 1
    fi

    echo "Generating Pydantic models from $openapi_file..."
    datamodel-codegen --input "$openapi_file" --output "$output_file"
}

# Function to create main.py
create_main_py() {
    local main_file="$1"

    cat <<EOL > "$main_file"
from fastapi import FastAPI
from app.api.router import router

app = FastAPI(
    title="Central Sequence Service API",
    description="This API manages the assignment and updating of sequence numbers for various elements within a story, ensuring logical order and consistency.",
    version="1.0.0"
)

app.include_router(router)
EOL
    echo "Created $main_file."
}

# Function to create router.py
create_router_py() {
    local router_file="$1"

    cat <<EOL > "$router_file"
from fastapi import APIRouter, HTTPException, status
from app.models import (
    SequenceRequest,
    SequenceResponse,
    ReorderRequest,
    SuccessResponse,
    VersionRequest,
    VersionResponse,
)

router = APIRouter()

@router.post("/sequence", response_model=SequenceResponse, status_code=status.HTTP_201_CREATED)
def generate_sequence_number(request: SequenceRequest):
    # Placeholder implementation
    sequence_number = 1  # TODO: Implement actual logic
    return SequenceResponse(sequenceNumber=sequence_number)

@router.post("/sequence/reorder", response_model=SuccessResponse)
def reorder_elements(request: ReorderRequest):
    # Placeholder implementation
    return SuccessResponse(message="Reorder successful.")

@router.post("/sequence/version", response_model=VersionResponse, status_code=status.HTTP_201_CREATED)
def create_version(request: VersionRequest):
    # Placeholder implementation
    version_number = 2  # TODO: Implement actual logic
    return VersionResponse(versionNumber=version_number)
EOL
    echo "Created $router_file."
}

# Main function to generate the FastAPI app
generate_fastapi_app() {
    local project_name="central_sequence_service"
    local openapi_file="../central_sequence_service_openapi.yaml"

    cd "$project_name" || exit
    source venv/bin/activate

    pip install datamodel-code-generator

    generate_pydantic_models "$openapi_file" "app/models.py"
    create_main_py "app/main.py"
    create_directory "app/api"
    touch app/api/__init__.py
    create_router_py "app/api/router.py"

    echo "FastAPI application generated."
}

# Function to create a directory if it does not exist
create_directory() {
    local dir_path="$1"
    if [ ! -d "$dir_path" ]; then
        mkdir -p "$dir_path"
        echo "Directory $dir_path created."
    else
        echo "Directory $dir_path already exists."
    fi
}

# Execute the main function
generate_fastapi_app
```

---

## Instructions for Running the Scripts

1. **Save the OpenAPI Specification**

   Save the provided OpenAPI specification as `central_sequence_service_openapi.yaml` in the parent directory of your project.

2. **Make the Shell Scripts Executable**

   ```bash
   chmod +x initialize_project.sh
   chmod +x generate_fastapi_app.sh
   ```

3. **Run the Project Initialization Script**

   ```bash
   ./initialize_project.sh
   ```

   This will:

   - Create the `central_sequence_service` directory.
   - Set up a Python virtual environment.
   - Install necessary dependencies.
   - Create the basic project structure.

4. **Run the FastAPI App Generation Script**

   ```bash
   ./generate_fastapi_app.sh
   ```

   This will:

   - Generate Pydantic models from the OpenAPI specification.
   - Create `main.py` and `router.py` with placeholder implementations.
   - Ensure all files are placed correctly within the project structure.

5. **Run the FastAPI Application**

   Activate the virtual environment and run the application using Uvicorn:

   ```bash
   cd central_sequence_service
   source venv/bin/activate
   uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload
   ```

   The API will be accessible at `http://localhost:8080`.

---

## Explanations

### **1. `initialize_project.sh`**

- **Purpose**: Sets up the project directory, virtual environment, and installs dependencies.
- **Idempotency**: Checks for the existence of directories and files before creating them.
- **Key Functions**:
  - `create_directory()`: Creates directories if they do not exist.
  - `create_virtualenv()`: Creates a Python virtual environment.
  - `install_dependencies()`: Creates a `requirements.txt` file if it doesn't exist and installs the dependencies.

### **2. `generate_fastapi_app.sh`**

- **Purpose**: Generates the FastAPI application files based on the OpenAPI specification.
- **Idempotency**: Overwrites existing files to ensure they match the OpenAPI specification.
- **Key Functions**:
  - `generate_pydantic_models()`: Uses `datamodel-codegen` to generate Pydantic models from the OpenAPI spec.
  - `create_main_py()`: Creates `main.py` with the FastAPI application instance.
  - `create_router_py()`: Creates `router.py` with the API endpoint implementations.
  - `create_directory()`: Ensures the `app/api` directory exists.

### **Notes**:

- **Placeholder Implementations**: The endpoint functions contain placeholder logic that should be replaced with actual implementations as per your business requirements.
- **Dependencies**: The script installs `datamodel-code-generator` within the virtual environment to generate models.

---

## Conclusion

By following the **Official FountainAI System Description and Implementation Plan** and adhering to the shell scripting conventions, we've provided shell scripts that generate a FastAPI application matching the provided OpenAPI specification. The scripts are modular, idempotent, and well-documented, ensuring a deterministic and reliable deployment process.

---

**Next Steps**:

- **Implement Business Logic**: Replace the placeholder logic in `router.py` with actual implementations.
- **Testing**: Write unit and integration tests to ensure the API functions as expected.
- **Dockerization**: Create a `Dockerfile` to containerize the application for deployment.
- **Integration with Kong and Route 53**: Configure the API gateway and DNS settings as per the implementation plan.

---

**Feel free to reach out if you have any questions or need further assistance with the implementation.**