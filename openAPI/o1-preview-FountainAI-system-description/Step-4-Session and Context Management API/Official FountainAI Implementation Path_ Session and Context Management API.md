# Official FountainAI Implementation Path: Session and Context Management API

---

## Introduction

Following the **Official FountainAI System Description and Implementation Plan**, we will implement the **Session and Context Management API** using the same structured approach as with the previous services. This implementation includes the creation of shell scripts that:

- **Initialize the project.**
- **Generate the FastAPI application based on the OpenAPI specification.**
- **Implement the business logic.**
- **Set up testing.**
- **Dockerize the application.**
- **Configure Kong API Gateway and Amazon Route 53.**

These scripts adhere to the **FountainAI convention** for shell scripting, ensuring modularity, idempotency, and deterministic execution.

---

## Table of Contents

1. [Shell Script: `initialize_project.sh`](#shell-script-initialize_projectsh)
2. [Shell Script: `generate_fastapi_app.sh`](#shell-script-generate_fastapi_appsh)
3. [Shell Script: `implement_business_logic.sh`](#shell-script-implement_business_logicsh)
4. [Shell Script: `setup_testing.sh`](#shell-script-setup_testingsh)
5. [Shell Script: `create_dockerfile.sh`](#shell-script-create_dockerfilesh)
6. [Shell Script: `configure_kong_and_route53.sh`](#shell-script-configure_kong_and_route53sh)
7. [Instructions for Running the Scripts](#instructions-for-running-the-scripts)
8. [Explanations](#explanations)
9. [Conclusion](#conclusion)

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
requests
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
    local project_name="session_context_management_api"
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
    title="FountainAI Session and Context Management API",
    description="This API manages sessions and context, allowing for the creation, updating, and retrieval of session-specific data.",
    version="2.0.0"
)

app.include_router(router)
EOL
    echo "Created $main_file."
}

# Function to create router.py
create_router_py() {
    local router_file="$1"

    cat <<EOL > "$router_file"
from fastapi import APIRouter, HTTPException, status, Path, Depends
from typing import List

from app.models import (
    SessionRequest,
    SessionResponse,
    Session,
    SessionUpdateRequest,
    SessionContextResponse,
    ReorderRequest,
    SuccessResponse
)

router = APIRouter()

# Placeholder implementations

@router.post("/sessions", response_model=SessionResponse, status_code=status.HTTP_201_CREATED)
def create_session():
    # TODO: Implement logic to create a new session
    return SessionResponse(sessionId=1, userId=123, context="Initial context")

@router.get("/sessions", response_model=List[Session])
def list_sessions():
    # TODO: Implement logic to list all sessions
    return []

@router.put("/sessions/{sessionId}", response_model=SessionResponse)
def update_session(sessionId: int, request: SessionUpdateRequest):
    # TODO: Implement logic to update a session
    return SessionResponse(sessionId=sessionId, userId=123, context="Updated context")

@router.get("/sessions/{sessionId}/context", response_model=SessionContextResponse)
def get_session_context(sessionId: int):
    # TODO: Implement logic to get session context
    return SessionContextResponse(sessionId=sessionId, context="Current context")
EOL
    echo "Created $router_file."
}

# Main function to generate the FastAPI app
generate_fastapi_app() {
    local project_name="session_context_management_api"
    local openapi_file="../session_context_management_api_openapi.yaml"

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

## Shell Script: `implement_business_logic.sh`

```bash
#!/bin/bash

# Function to implement business logic in router.py
implement_business_logic() {
    local router_file="app/api/router.py"
    
    if [ ! -f "$router_file" ]; then
        echo "Error: $router_file does not exist. Run previous scripts first."
        exit 1
    fi

    cat <<EOL > "$router_file"
from fastapi import APIRouter, HTTPException, status, Path, Depends
from sqlalchemy.orm import Session
from typing import List

from app.models import (
    SessionRequest,
    SessionResponse,
    Session,
    SessionUpdateRequest,
    SessionContextResponse,
    ReorderRequest,
    SuccessResponse
)
from app.models_db import SessionDB
from app.database import get_db
import requests

router = APIRouter()

CENTRAL_SEQUENCE_SERVICE_URL = "http://central_sequence_service:8080"

# Sessions

@router.post("/sessions", response_model=SessionResponse, status_code=status.HTTP_201_CREATED)
def create_session(request: SessionRequest, db: Session = Depends(get_db)):
    # Obtain sequence number from Central Sequence Service
    sequence_response = requests.post(f"{CENTRAL_SEQUENCE_SERVICE_URL}/sequence", json={
        "elementType": "session",
        "elementId": None  # Will be set after creation
    })
    if sequence_response.status_code != 201:
        raise HTTPException(status_code=500, detail="Failed to obtain sequence number")
    sequence_number = sequence_response.json()["sequenceNumber"]

    # Create session
    new_session = SessionDB(
        user_id=request.userId,
        context=request.context,
        sequence_number=sequence_number
    )
    db.add(new_session)
    db.commit()
    db.refresh(new_session)

    # Update sequence with session ID
    sequence_update_response = requests.post(f"{CENTRAL_SEQUENCE_SERVICE_URL}/sequence", json={
        "elementType": "session",
        "elementId": new_session.session_id
    })
    if sequence_update_response.status_code != 201:
        raise HTTPException(status_code=500, detail="Failed to update sequence number with session ID")

    return SessionResponse(
        sessionId=new_session.session_id,
        userId=new_session.user_id,
        context=new_session.context
    )

@router.get("/sessions", response_model=List[Session])
def list_sessions(db: Session = Depends(get_db)):
    sessions = db.query(SessionDB).all()
    return sessions

@router.put("/sessions/{sessionId}", response_model=SessionResponse)
def update_session(sessionId: int, request: SessionUpdateRequest, db: Session = Depends(get_db)):
    session = db.query(SessionDB).filter_by(session_id=sessionId).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    session.context = request.context or session.context
    db.commit()
    db.refresh(session)
    return SessionResponse(
        sessionId=session.session_id,
        userId=session.user_id,
        context=session.context
    )

@router.get("/sessions/{sessionId}/context", response_model=SessionContextResponse)
def get_session_context(sessionId: int, db: Session = Depends(get_db)):
    session = db.query(SessionDB).filter_by(session_id=sessionId).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    return SessionContextResponse(
        sessionId=session.session_id,
        context=session.context
    )
EOL

    echo "Business logic implemented in $router_file."
}

# Function to create models_db.py with SQLAlchemy models
create_database_models() {
    local models_db_file="app/models_db.py"

    cat <<EOL > "$models_db_file"
from sqlalchemy import Column, Integer, String, Text
from app.database import Base

class SessionDB(Base):
    __tablename__ = 'sessions'

    session_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    context = Column(Text)
    sequence_number = Column(Integer, index=True)
EOL

    echo "Database models created in $models_db_file."
}

# Function to update database.py
update_database_py() {
    local database_file="app/database.py"

    cat <<EOL > "$database_file"
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

SQLALCHEMY_DATABASE_URL = "sqlite:///./app.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# Dependency for FastAPI
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
EOL

    echo "Database configuration updated in $database_file."
}

# Function to update main.py to create database tables
update_main_py() {
    local main_file="app/main.py"
    sed -i '/from app.api.router import router/a from app.database import engine, Base\nBase.metadata.create_all(bind=engine)' "$main_file"
    echo "Database tables will be created at startup in $main_file."
}

# Main function
implement_business_logic_main() {
    cd session_context_management_api || exit
    source venv/bin/activate

    # Install dependencies if not already installed
    pip install sqlalchemy requests

    create_database_models
    update_database_py
    implement_business_logic
    update_main_py

    echo "Business logic implementation complete."
}

# Execute the main function
implement_business_logic_main
```

---

## Shell Script: `setup_testing.sh`

```bash
#!/bin/bash

# Function to set up testing environment
setup_testing_environment() {
    cd session_context_management_api || exit
    source venv/bin/activate

    # Install testing dependencies
    pip install pytest pytest-cov requests-mock

    create_directory "tests"

    # Create __init__.py in tests directory
    touch tests/__init__.py

    echo "Testing environment set up."
}

# Function to create test file
create_test_file() {
    local test_file="tests/test_main.py"

    cat <<EOL > "$test_file"
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.database import Base, engine
from sqlalchemy.orm import sessionmaker
import requests
from unittest.mock import patch

# Set up the test database
@pytest.fixture(scope="module")
def test_client():
    Base.metadata.create_all(bind=engine)
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    client = TestClient(app)
    yield client
    Base.metadata.drop_all(bind=engine)

@patch('app.api.router.requests.post')
def test_create_session(mock_post, test_client):
    mock_post.return_value.status_code = 201
    mock_post.return_value.json.return_value = {"sequenceNumber": 1}
    response = test_client.post("/sessions", json={"userId": 123, "context": "Initial context"})
    assert response.status_code == 201
    assert response.json()["sessionId"] == 1
    assert response.json()["userId"] == 123
    assert response.json()["context"] == "Initial context"

def test_list_sessions(test_client):
    response = test_client.get("/sessions")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_update_session(test_client):
    response = test_client.put("/sessions/1", json={"context": "Updated context"})
    assert response.status_code == 200
    assert response.json()["sessionId"] == 1
    assert response.json()["context"] == "Updated context"

def test_get_session_context(test_client):
    response = test_client.get("/sessions/1/context")
    assert response.status_code == 200
    assert response.json()["sessionId"] == 1
    assert response.json()["context"] == "Updated context"

# Additional tests can be added for error cases
EOL

    echo "Test file created at $test_file."
}

# Function to create directory if not exists
create_directory() {
    local dir_path="\$1"
    if [ ! -d "\$dir_path" ]; then
        mkdir -p "\$dir_path"
        echo "Directory \$dir_path created."
    else
        echo "Directory \$dir_path already exists."
    fi
}

# Main function
setup_testing_main() {
    setup_testing_environment
    create_test_file
    echo "Testing setup complete. Run tests using 'pytest' in the virtual environment."
}

# Execute the main function
setup_testing_main
```

---

## Shell Script: `create_dockerfile.sh`

```bash
#!/bin/bash

# Function to create Dockerfile
create_dockerfile() {
    local dockerfile_path="session_context_management_api/Dockerfile"

    cat <<EOL > "$dockerfile_path"
# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt ./

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# Expose port
EXPOSE 8080

# Command to run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
EOL

    echo "Dockerfile created at $dockerfile_path."
}

# Function to update requirements.txt
update_requirements() {
    local requirements_file="session_context_management_api/requirements.txt"

    cat <<EOL > "$requirements_file"
fastapi
uvicorn
pydantic
sqlalchemy
requests
EOL

    echo "requirements.txt updated at $requirements_file."
}

# Main function
create_dockerfile_main() {
    update_requirements
    create_dockerfile
    echo "Dockerization setup complete."
}

# Execute the main function
create_dockerfile_main
```

---

## Shell Script: `configure_kong_and_route53.sh`

```bash
#!/bin/bash

# Note: This script assumes you have access to AWS CLI and have configured it with the necessary permissions.
# Additionally, configuring Kong requires access to its Admin API.

# Function to configure Kong
configure_kong() {
    echo "Configuring Kong..."

    # Define variables
    KONG_ADMIN_URL="http://localhost:8001"
    SERVICE_NAME="session-context-management-service"
    ROUTE_NAME="session-context-management-route"
    SERVICE_URL="http://session_context_management_api:8080"
    HOST_NAME="sessioncontext.fountain.coach"

    # Create Service
    curl -i -X POST $KONG_ADMIN_URL/services/ \
      --data "name=$SERVICE_NAME" \
      --data "url=$SERVICE_URL"

    # Create Route
    curl -i -X POST $KONG_ADMIN_URL/services/$SERVICE_NAME/routes \
      --data "name=$ROUTE_NAME" \
      --data "hosts[]=$HOST_NAME"

    echo "Kong configuration complete."
}

# Function to configure AWS Route 53
configure_route53() {
    echo "Configuring Route 53..."

    # Define variables
    HOSTED_ZONE_ID="YOUR_HOSTED_ZONE_ID"  # Replace with your actual hosted zone ID
    DOMAIN_NAME="sessioncontext.fountain.coach."
    KONG_PUBLIC_IP="YOUR_KONG_PUBLIC_IP"  # Replace with the public IP of your Kong gateway

    # Create JSON file for the change batch
    cat <<EOL > change-batch.json
{
  "Comment": "Create A record for Session and Context Management service",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$DOMAIN_NAME",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "$KONG_PUBLIC_IP"
          }
        ]
      }
    }
  ]
}
EOL

    # Execute the change batch
    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch file://change-batch.json

    echo "Route 53 configuration complete."
}

# Main function
configure_kong_and_route53_main() {
    # Ensure AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI not found. Please install it and configure your credentials."
        exit 1
    fi

    # Ensure Kong is accessible
    if ! curl -s http://localhost:8001/ &> /dev/null; then
        echo "Kong Admin API not accessible at http://localhost:8001/. Please ensure Kong is running."
        exit 1
    fi

    configure_kong
    configure_route53
    echo "Kong and Route 53 configuration complete."
}

# Execute the main function
configure_kong_and_route53_main
```

**Note:** Replace `YOUR_HOSTED_ZONE_ID` with your actual Route 53 hosted zone ID and `YOUR_KONG_PUBLIC_IP` with the public IP address of your Kong API Gateway.

---

## Instructions for Running the Scripts

1. **Save the OpenAPI Specification**

   Save the provided OpenAPI specification as `session_context_management_api_openapi.yaml` in the parent directory of your project.

2. **Make the Shell Scripts Executable**

   ```bash
   chmod +x initialize_project.sh
   chmod +x generate_fastapi_app.sh
   chmod +x implement_business_logic.sh
   chmod +x setup_testing.sh
   chmod +x create_dockerfile.sh
   chmod +x configure_kong_and_route53.sh
   ```

3. **Run the Project Initialization Script**

   ```bash
   ./initialize_project.sh
   ```

   This will:

   - Create the `session_context_management_api` directory.
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

5. **Implement Business Logic**

   ```bash
   ./implement_business_logic.sh
   ```

   This will:

   - Create the SQLAlchemy database models.
   - Update the database configuration.
   - Implement the actual business logic in `router.py`.
   - Update `main.py` to create database tables at startup.

6. **Set Up Testing**

   ```bash
   ./setup_testing.sh
   ```

   This will:

   - Set up the testing environment.
   - Install testing dependencies.
   - Create test cases in `tests/test_main.py`.

7. **Dockerize the Application**

   ```bash
   ./create_dockerfile.sh
   ```

   This will:

   - Update `requirements.txt` with necessary dependencies.
   - Create a `Dockerfile` for containerization.

8. **Configure Kong and Route 53**

   ```bash
   ./configure_kong_and_route53.sh
   ```

   **Important:** Before running this script:

   - Ensure you have AWS CLI installed and configured with the necessary permissions.
   - Ensure Kong is running and its Admin API is accessible.
   - Replace placeholder values in the script (`YOUR_HOSTED_ZONE_ID` and `YOUR_KONG_PUBLIC_IP`) with your actual hosted zone ID and Kong public IP.

---

## Explanations

### **1. `initialize_project.sh`**

- **Purpose:** Sets up the project directory, virtual environment, and installs dependencies.
- **Idempotency:** Checks for the existence of directories and files before creating them.
- **Key Functions:**
  - `create_directory()`: Creates directories if they do not exist.
  - `create_virtualenv()`: Creates a Python virtual environment.
  - `install_dependencies()`: Creates a `requirements.txt` file if it doesn't exist and installs the dependencies.

### **2. `generate_fastapi_app.sh`**

- **Purpose:** Generates the FastAPI application files based on the OpenAPI specification.
- **Idempotency:** Overwrites existing files to ensure they match the OpenAPI specification.
- **Key Functions:**
  - `generate_pydantic_models()`: Uses `datamodel-codegen` to generate Pydantic models from the OpenAPI spec.
  - `create_main_py()`: Creates `main.py` with the FastAPI application instance.
  - `create_router_py()`: Creates `router.py` with placeholder implementations.
  - `create_directory()`: Ensures the `app/api` directory exists.

### **3. `implement_business_logic.sh`**

- **Purpose:** Implements the actual business logic in `router.py` by replacing placeholder code with functional code.
- **Key Functions:**
  - `create_database_models()`: Creates `models_db.py` with the SQLAlchemy models.
  - `update_database_py()`: Updates `database.py` with the necessary configuration and dependency injection.
  - `implement_business_logic()`: Rewrites `router.py` with the actual implementation.
  - `update_main_py()`: Modifies `main.py` to create database tables at startup.

### **4. `setup_testing.sh`**

- **Purpose:** Sets up the testing environment and writes test cases to validate the API endpoints.
- **Key Functions:**
  - `setup_testing_environment()`: Installs testing dependencies and prepares the testing directory.
  - `create_test_file()`: Creates `test_main.py` with test cases for each endpoint.

### **5. `create_dockerfile.sh`**

- **Purpose:** Creates a `Dockerfile` to containerize the FastAPI application for deployment.
- **Key Functions:**
  - `update_requirements()`: Updates `requirements.txt` with necessary dependencies for production.
  - `create_dockerfile()`: Writes the `Dockerfile` with the instructions to build the Docker image.

### **6. `configure_kong_and_route53.sh`**

- **Purpose:** Configures Kong API Gateway and updates DNS settings in Amazon Route 53.
- **Key Functions:**
  - `configure_kong()`: Uses Kong's Admin API to create a service and route for the application.
  - `configure_route53()`: Updates DNS records in Route 53 to point the domain to the Kong API Gateway.

**Note:** This script requires AWS CLI and access to Kong's Admin API. It uses `curl` to interact with Kong and `aws` CLI commands to update Route 53.

---

## Conclusion

By following the **FountainAI Implementation Path** and adhering to shell scripting conventions, we've provided comprehensive shell scripts to implement the **Session and Context Management API**:

- **Project Initialization:** Set up the project structure and environment.
- **FastAPI App Generation:** Generated the application files based on the OpenAPI specification.
- **Business Logic Implementation:** Implemented the API endpoints with actual logic, integrating with the Central Sequence Service.
- **Testing Setup:** Created test cases to validate the API functionality.
- **Dockerization:** Prepared the application for containerized deployment.
- **Integration with Kong and Route 53:** Configured the API gateway and DNS settings.

These scripts are **idempotent**, **modular**, and **deterministic**, ensuring a reliable and maintainable deployment process in line with FountainAI's best practices.

---

**Next Steps:**

- **Run Tests:** Navigate to the `session_context_management_api` directory, activate the virtual environment, and run `pytest` to execute the tests.

  ```bash
  cd session_context_management_api
  source venv/bin/activate
  pytest
  ```

- **Build Docker Image:** Build the Docker image using the Dockerfile:

  ```bash
  cd session_context_management_api
  docker build -t session-context-management-api .
  ```

- **Run Docker Container:** Run the container locally to test:

  ```bash
  docker run -d -p 8080:8080 session-context-management-api
  ```

- **Deploy to Production Environment:** Deploy the Docker container to your production environment, ensuring it's accessible by Kong.

- **Verify Integration:** Test the API through Kong using the DNS name configured in Route 53 to ensure everything is working as expected.

---

**Feel free to reach out if you have any questions or need further assistance with any of these steps!**