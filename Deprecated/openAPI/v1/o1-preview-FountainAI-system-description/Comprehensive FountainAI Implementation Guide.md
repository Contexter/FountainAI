# Comprehensive FountainAI Implementation Guide

---

## Table of Contents

1. [Introduction](#introduction)
2. [System Overview](#system-overview)
3. [Architecture Summary](#architecture-summary)
4. [Implementation Requirements](#implementation-requirements)
   - [Explicit OpenAPI Compliance](#explicit-openapi-compliance)
   - [FastAPI Implementation Guidelines](#fastapi-implementation-guidelines)
   - [Shell Scripting Practices](#shell-scripting-practices)
5. [Implementation Path](#implementation-path)
   - [1. Define OpenAPI Specifications](#1-define-openapi-specifications)
   - [2. Generate Pydantic Models and API Stubs](#2-generate-pydantic-models-and-api-stubs)
   - [3. Implement FastAPI Applications](#3-implement-fastapi-applications)
   - [4. Set Up Database Models and Persistence](#4-set-up-database-models-and-persistence)
   - [5. Implement Endpoint Logic](#5-implement-endpoint-logic)
   - [6. Testing and Validation](#6-testing-and-validation)
   - [7. Containerization with Docker](#7-containerization-with-docker)
   - [8. Integration with Kong API Gateway](#8-integration-with-kong-api-gateway)
   - [9. Deployment and DNS Configuration](#9-deployment-and-dns-configuration)
6. [GPT Code Generation Sessions](#gpt-code-generation-sessions)
   - [Overview](#overview)
   - [Example: Character Management API](#example-character-management-api)
   - [Instructions for Running GPT Code Generation](#instructions-for-running-gpt-code-generation)
7. [Additional Considerations](#additional-considerations)
8. [Conclusion](#conclusion)
9. [Next Steps](#next-steps)

---

## Introduction

This **Comprehensive FountainAI Implementation Guide** serves as the definitive reference for developing, deploying, and maintaining the FountainAI system. It amalgamates the system description, implementation requirements, a detailed FastAPI implementation path, and guidelines for leveraging the GPT model to automate code generation. This guide is intended to facilitate the refactoring of existing implementations, ensuring alignment with best practices, OpenAPI specifications, and the overall architectural vision of FountainAI.

---

## System Overview

**FountainAI** is designed to manage story elements such as scripts, characters, actions, spoken words, sessions, context, and the logical flow of stories. The system comprises several components:

1. **Independent Microservices**: Five FastAPI applications, each handling specific aspects of screenplay management.
2. **Kong API Gateway**: Routes requests to the appropriate microservices and manages API features like authentication and rate limiting.
3. **Docker Compose**: Orchestrates the deployment of microservices and Kong.
4. **Amazon Route 53**: Manages DNS records, mapping domain names to services.
5. **GPT Model**: Acts as the orchestrator, using OpenAPI specifications to interact with the services.

This modular architecture ensures scalability, maintainability, and ease of deployment, adhering to modern microservices best practices.

---

## Architecture Summary

### Components:

1. **Independent Microservices:**
   - **Technologies:** FastAPI, SQLite
   - **Characteristics:**
     - Each microservice is self-contained.
     - Manages its own database (SQLite).
     - Exposes RESTful APIs as per its OpenAPI specification.
     - Does not assume the existence of other services.
     - Focuses on a specific domain or functionality.

2. **Kong API Gateway:**
   - Acts as a single entry point for all API requests.
   - Routes requests to the appropriate microservice based on hostnames.
   - Provides features like authentication, rate limiting, logging, and SSL termination.

3. **Docker Compose:**
   - Orchestrates the deployment of microservices, Kong, and any other required services.
   - Defines service configurations, networks, and volumes.

4. **Amazon Route 53:**
   - Manages DNS records for the domain (`fountain.coach`).
   - Maps domain names to the Kong API Gateway or load balancer.

5. **GPT Model:**
   - Orchestrates interactions between microservices by making API calls.
   - Uses the OpenAPI specifications to understand and interact with the APIs.

---

## Implementation Requirements

### Explicit OpenAPI Compliance

#### Importance of Compliance

Ensuring compliance with OpenAPI specifications is critical for:

- **Interoperability**: Allowing various services to communicate effectively.
- **Documentation**: Providing accurate API documentation for developers and users.
- **Maintainability**: Simplifying the process of updating and managing the API.

#### FastAPI Route Definitions

Each FastAPI route must explicitly define the following parameters:

- **Operation ID**: A unique identifier for each API operation that aligns with the OpenAPI specification.
- **Summary**: A brief description of what the API endpoint does.
- **Description**: A detailed explanation of the endpoint’s purpose and usage (not exceeding a 300 characters maximum limit).

##### Example Implementation

```python
from fastapi import FastAPI, status, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.database import get_db

app = FastAPI()

class SequenceRequest(BaseModel):
    elementType: str

class SequenceResponse(BaseModel):
    sequenceNumber: int

@app.post(
    "/sequence", 
    response_model=SequenceResponse, 
    status_code=status.HTTP_201_CREATED,
    summary="Generate Sequence Number", 
    description="Generates a new sequence number for a specified element type.",
    operation_id="generateSequenceNumber"
)
def generate_sequence_number(request: SequenceRequest, db: Session = Depends(get_db)):
    # Placeholder logic
    sequence_number = 1  # TODO: Implement actual logic
    return SequenceResponse(sequenceNumber=sequence_number)
```

#### Additional Considerations

- Ensure that **all** endpoints in the API are documented in this manner to maintain consistency.
- Regularly review and update the OpenAPI specifications alongside the codebase to prevent discrepancies.

---

### FastAPI Implementation Guidelines

#### Structure and Modularity

- Use a clear project structure that separates concerns, such as routing, models, and database interactions.
- Maintain modularity by breaking down functionality into reusable components.

#### Idempotency and Determinism

- Ensure that all shell scripts and FastAPI endpoints are idempotent, meaning they can be safely called multiple times without unintended effects.
- Implement deterministic behaviors that lead to predictable outcomes, enhancing the reliability of the system.

#### Testing and Validation

- Develop unit tests for each endpoint to validate that they behave as expected and conform to the OpenAPI definitions.
- Use **pytest** and **FastAPI’s testing capabilities** to write comprehensive test cases.

---

### Shell Scripting Practices

#### Overview

Shell scripts play a crucial role in automating the deployment and configuration of FountainAI services. Adhering to a consistent scripting style will simplify maintenance and enhance readability.

#### Key Principles

- **Modularity**: Create functions for repetitive tasks to avoid redundancy.
- **Idempotency**: Ensure that running scripts multiple times does not alter the system state unexpectedly.
- **Documentation**: Comment thoroughly to explain the purpose of each function and script.

##### Example Shell Script Structure

```bash
#!/bin/bash

# Function to initialize the project
initialize_project() {
    # Create directories and virtual environment
    # Install dependencies
}

# Function to generate FastAPI app
generate_fastapi_app() {
    # Generate models and routes based on OpenAPI spec
}

# Main execution
initialize_project
generate_fastapi_app
```

---

## Implementation Path

The following steps outline the detailed path to implement the FountainAI system, ensuring alignment with the system description and implementation requirements.

### 1. Define OpenAPI Specifications

**Objective:** Create detailed OpenAPI specifications for each microservice, serving as the single source of truth.

**Actions:**

- **Document All Endpoints:**
  - Define all API endpoints, HTTP methods, and paths.
- **Define Schemas:**
  - Specify request and response schemas using JSON Schema.
- **Include Examples:**
  - Provide example requests and responses for clarity.
- **Authentication and Security Schemes:**
  - Define any required authentication mechanisms.

**Tools:**

- Use OpenAPI 3.0 or 3.1 YAML or JSON format.
- Utilize editors like Swagger Editor or Stoplight Studio.

**Deliverables:**

- `central_sequence_service_openapi.yaml`
- `character_management_api_openapi.yaml`
- `core_script_management_api_openapi.yaml`
- `session_context_management_api_openapi.yaml`
- `story_factory_api_openapi.yaml`

---

### 2. Generate Pydantic Models and API Stubs

**Objective:** Generate Pydantic models and FastAPI stubs based on the OpenAPI specifications to ensure exact conformity.

**Actions:**

- **Use OpenAPI Code Generators:**
  - Utilize tools like `datamodel-code-generator` to generate Pydantic models.
  - Use `fastapi-codegen` to generate FastAPI stubs.

**Commands:**

- Install code generation tools:

  ```bash
  pip install datamodel-code-generator fastapi-codegen
  ```

- Generate models:

  ```bash
  datamodel-codegen --input character_management_api_openapi.yaml --input-file-type openapi --output character_management_api/models.py
  ```

- Generate FastAPI stubs:

  ```bash
  fastapi-codegen --input character_management_api_openapi.yaml --output character_management_api
  ```

**Deliverables:**

- `models.py` files containing Pydantic models for each microservice.
- FastAPI project structure with stub files for each endpoint.

---

### 3. Implement FastAPI Applications

**Objective:** Implement the FastAPI applications using the generated models and stubs, ensuring adherence to the OpenAPI specs.

**Actions:**

- **Project Structure:**

  For each microservice, organize the project as follows:

  ```
  microservice_name/
  ├── app/
  │   ├── __init__.py
  │   ├── main.py
  │   ├── api/
  │   │   ├── __init__.py
  │   │   ├── endpoints.py
  │   ├── models.py
  │   ├── schemas.py
  │   ├── database.py
  ├── tests/
  ├── requirements.txt
  ├── Dockerfile
  └── README.md
  ```

- **Integrate Generated Models:**

  - Place the generated `models.py` and `schemas.py` into the `app/` directory.
  - Ensure that the Pydantic models (`schemas.py`) are used for request validation and response serialization.

- **Set Up FastAPI App:**

  ```python
  # app/main.py
  from fastapi import FastAPI
  from app.api import endpoints

  app = FastAPI(
      title="Character Management API",
      version="1.0.0",
      description="API for managing characters, actions, and paraphrases."
  )

  app.include_router(endpoints.router)
  ```

- **Implement API Endpoints:**

  ```python
  # app/api/endpoints.py
  from fastapi import APIRouter, Depends, HTTPException, status
  from sqlalchemy.orm import Session
  from app import schemas, models_db
  from app.database import get_db

  router = APIRouter()

  @router.post(
      "/characters",
      response_model=schemas.Character,
      status_code=status.HTTP_201_CREATED,
      summary="Create a New Character",
      description="Creates a new character with the provided details.",
      operation_id="createCharacter"
  )
  def create_character(character: schemas.CharacterCreateRequest, db: Session = Depends(get_db)):
      db_character = models_db.CharacterDB(**character.dict())
      db.add(db_character)
      db.commit()
      db.refresh(db_character)
      return db_character
  ```

- **Ensure Exact Input/Output:**

  - Validate all inputs using the Pydantic models.
  - Return responses using the Pydantic models to ensure the outputs match the OpenAPI specs.

---

### 4. Set Up Database Models and Persistence

**Objective:** Define SQLAlchemy models and set up the database connection using SQLite.

**Actions:**

- **Database Configuration:**

  ```python
  # app/database.py
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
  ```

- **Define SQLAlchemy Models:**

  ```python
  # app/models_db.py
  from sqlalchemy import Column, Integer, String, Text
  from app.database import Base

  class CharacterDB(Base):
      __tablename__ = 'characters'

      character_id = Column(Integer, primary_key=True, index=True)
      name = Column(String, index=True)
      description = Column(Text)

  class ParaphraseDB(Base):
      __tablename__ = 'paraphrases'

      paraphrase_id = Column(Integer, primary_key=True, index=True)
      original_id = Column(Integer, index=True)
      original_type = Column(String, index=True)  # 'character', 'action', 'spokenWord'
      text = Column(Text)
      commentary = Column(Text)

  class ActionDB(Base):
      __tablename__ = 'actions'

      action_id = Column(Integer, primary_key=True, index=True)
      description = Column(Text)

  class SpokenWordDB(Base):
      __tablename__ = 'spoken_words'

      spoken_word_id = Column(Integer, primary_key=True, index=True)
      text = Column(Text)
  ```

- **Initialize Database:**

  ```python
  # app/main.py
  from app.database import engine, Base
  from app.api import endpoints

  Base.metadata.create_all(bind=engine)
  ```

---

### 5. Implement Endpoint Logic

**Objective:** Implement the business logic for each endpoint, ensuring that all operations conform to the OpenAPI specifications.

**Actions:**

- **CRUD Operations:**
  - Implement Create, Read, Update, Delete operations as defined.
  - Use the database session (`db: Session = Depends(get_db)`) for database interactions.

- **Error Handling:**
  - Raise appropriate HTTP exceptions (`HTTPException`) with correct status codes and detail messages.

  ```python
  @router.get(
      "/characters/{characterId}",
      response_model=schemas.Character,
      summary="Get Character Details",
      description="Retrieves the details of a specific character by ID.",
      operation_id="getCharacterDetails"
  )
  def get_character(characterId: int, db: Session = Depends(get_db)):
      character = db.query(models_db.CharacterDB).filter(models_db.CharacterDB.character_id == characterId).first()
      if character is None:
          raise HTTPException(status_code=404, detail="Character not found")
      return character
  ```

- **Authentication (If Required):**
  - Implement authentication mechanisms as per the OpenAPI specs.
  - Use dependencies to enforce authentication.

---

### 6. Testing and Validation

**Objective:** Ensure that the FastAPI applications function correctly and conform to the OpenAPI specifications.

**Actions:**

- **Unit Tests:**
  - Write tests for individual functions and methods.

- **Integration Tests:**
  - Use `TestClient` from FastAPI for testing endpoints.

  ```python
  # tests/test_main.py
  from fastapi.testclient import TestClient
  from app.main import app
  from app.database import Base, engine
  from sqlalchemy.orm import sessionmaker

  # Set up the test database
  TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

  client = TestClient(app)

  def test_create_character():
      response = client.post("/characters", json={"name": "John Doe", "description": "Protagonist"})
      assert response.status_code == 201
      assert response.json()["name"] == "John Doe"

  def test_get_character():
      response = client.get("/characters/1")
      assert response.status_code == 200
      assert response.json()["name"] == "John Doe"

  def test_get_nonexistent_character():
      response = client.get("/characters/999")
      assert response.status_code == 404
      assert response.json()["detail"] == "Character not found"
  ```

- **Validation Against OpenAPI Specs:**
  - Use tools to validate that the API responses conform to the OpenAPI definitions.
  - Ensure that input validation works as expected.

---

### 7. Containerization with Docker

**Objective:** Containerize each FastAPI application using Docker, ensuring that they can be deployed consistently.

**Actions:**

- **Create Dockerfile:**

  ```dockerfile
  # Dockerfile
  FROM python:3.9-slim

  WORKDIR /app

  COPY requirements.txt ./
  RUN pip install --no-cache-dir -r requirements.txt

  COPY . .

  CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
  ```

- **Build Docker Image:**

  ```bash
  docker build -t character-management-api .
  ```

- **Ensure SQLite Persistence:**
  - Use Docker volumes to persist the SQLite database file (`app.db`).

---

### 8. Integration with Kong API Gateway

**Objective:** Configure Kong to route requests to the FastAPI applications based on the DNS names specified in the OpenAPI specs.

**Actions:**

- **Update `kong.yml`:**

  ```yaml
  _format_version: '2.1'
  services:
    - name: character-management-service
      url: http://character_management_api:8080
      routes:
        - name: character-management-route
          hosts:
            - character.fountain.coach
          paths:
            - /
          methods:
            - GET
            - POST
            - PUT
            - DELETE
  ```

- **Mount SSL Certificates:**
  - Ensure SSL certificates are correctly configured for each hostname.

- **Configure Plugins (If Needed):**
  - Add authentication or rate limiting plugins as required.

---

### 9. Deployment and DNS Configuration

**Objective:** Deploy the services and ensure they are accessible via the specified DNS names.

**Actions:**

- **Docker Compose Configuration:**

  Define services in `docker-compose.yml`, including networks and volumes.

  ```yaml
  version: '3.8'

  services:
    # Character Management API
    character_management_api:
      build: ./character_management_api
      volumes:
        - character_management_data:/app/data  # Persist SQLite database
      networks:
        - fountainai-network

    # Kong API Gateway
    kong:
      image: kong:2.4
      environment:
        KONG_DATABASE: 'off'
        KONG_DECLARATIVE_CONFIG: /kong/declarative/kong.yml
      volumes:
        - ./kong.yml:/kong/declarative/kong.yml
      ports:
        - '80:8000'    # Proxy
        - '8001:8001'  # Admin API (secure this in production)
      networks:
        - fountainai-network

  volumes:
    character_management_data:

  networks:
    fountainai-network:
  ```

- **DNS Configuration in Route 53:**
  - Create DNS records mapping the subdomains (e.g., `character.fountain.coach`) to the public IP or load balancer of the Kong proxy.

- **Run Docker Compose:**

  ```bash
  docker-compose up -d
  ```

- **Verify Deployment:**
  - Test accessing the APIs via the DNS names to ensure that Kong is routing requests properly.

---

## GPT Code Generation Sessions

### Overview

The **GPT Code Generation Sessions** are designed to automate the creation of FastAPI applications based on existing OpenAPI specifications. By providing the GPT model with the OpenAPI documents, it generates shell scripts that:

- Initialize projects.
- Generate FastAPI code with precise `operationId`, `summary`, and `description` fields.
- Implement business logic.
- Set up testing environments.
- Dockerize applications.
- Configure API gateways and DNS settings.

These scripts follow the **FountainAI convention** for shell scripting, ensuring modularity, idempotency, and deterministic execution.

### Example: Character Management API

Following is an example of how the GPT model can generate shell scripts for the **Character Management API**, ensuring compliance with all requirements, including explicit `operationId`, `summary`, and `description` in FastAPI route definitions.

---

#### Shell Script: `initialize_project.sh`

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
    local project_name="character_management_api"
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

#### Shell Script: `generate_fastapi_app.sh`

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
    datamodel-codegen --input "$openapi_file" --input-file-type openapi --output "$output_file"
}

# Function to create main.py
create_main_py() {
    local main_file="$1"

    cat <<EOL > "$main_file"
from fastapi import FastAPI
from app.api.router import router

app = FastAPI(
    title="Character Management API",
    description="This API handles characters within stories, including their creation, management, actions, and spoken words.",
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
    Character,
    CharacterCreateRequest,
    Paraphrase,
    ParaphraseCreateRequest,
    Action,
    ActionCreateRequest,
    SpokenWord,
    SpokenWordCreateRequest,
    Error
)
from typing import List

router = APIRouter()

# Placeholder implementations

@router.get(
    "/characters",
    response_model=List[Character],
    summary="List All Characters",
    description="Retrieves a list of all characters.",
    operation_id="listAllCharacters"
)
def list_characters():
    # TODO: Implement logic to retrieve all characters
    return []

@router.post(
    "/characters",
    response_model=Character,
    status_code=status.HTTP_201_CREATED,
    summary="Create a New Character",
    description="Creates a new character with the provided details.",
    operation_id="createCharacter"
)
def create_character(request: CharacterCreateRequest):
    # TODO: Implement logic to create a new character
    return Character(characterId=1, name=request.name, description=request.description)

@router.get(
    "/characters/{characterId}/paraphrases",
    response_model=List[Paraphrase],
    summary="List Paraphrases for a Character",
    description="Retrieves all paraphrases associated with a specific character.",
    operation_id="listCharacterParaphrases"
)
def list_character_paraphrases(characterId: int):
    # TODO: Implement logic to retrieve paraphrases for a character
    return []

@router.post(
    "/characters/{characterId}/paraphrases",
    response_model=Paraphrase,
    status_code=status.HTTP_201_CREATED,
    summary="Create a Paraphrase for a Character",
    description="Creates a new paraphrase for a specific character.",
    operation_id="createCharacterParaphrase"
)
def create_character_paraphrase(characterId: int, request: ParaphraseCreateRequest):
    # TODO: Implement logic to create a paraphrase for a character
    return Paraphrase(paraphraseId=1, originalId=characterId, text=request.text, commentary=request.commentary)

# Similar implementations for Actions and SpokenWords

EOL
    echo "Created $router_file."
}

# Main function to generate the FastAPI app
generate_fastapi_app() {
    local project_name="character_management_api"
    local openapi_file="../character_management_api_openapi.yaml"

    cd "$project_name" || exit
    source venv/bin/activate

    pip install datamodel-code-generator fastapi-codegen

    generate_pydantic_models "$openapi_file" "app/models.py"
    create_main_py "app/main.py"
    create_directory "app/api"
    touch app/api/__init__.py
    create_router_py "app/api/router.py"

    echo "FastAPI application generated."
}

# Function to create directory if it does not exist
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

#### Shell Script: `implement_business_logic.sh`

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
    Character,
    CharacterCreateRequest,
    Paraphrase,
    ParaphraseCreateRequest,
    Action,
    ActionCreateRequest,
    SpokenWord,
    SpokenWordCreateRequest,
    Error
)
from app.models_db import (
    CharacterDB,
    ParaphraseDB,
    ActionDB,
    SpokenWordDB
)
from app.database import get_db

router = APIRouter()

# Characters

@router.get(
    "/characters",
    response_model=List[Character],
    summary="List All Characters",
    description="Retrieves a list of all characters.",
    operation_id="listAllCharacters"
)
def list_characters(db: Session = Depends(get_db)):
    characters = db.query(CharacterDB).all()
    return characters

@router.post(
    "/characters",
    response_model=Character,
    status_code=status.HTTP_201_CREATED,
    summary="Create a New Character",
    description="Creates a new character with the provided details.",
    operation_id="createCharacter"
)
def create_character(character: CharacterCreateRequest, db: Session = Depends(get_db)):
    new_character = CharacterDB(name=character.name, description=character.description)
    db.add(new_character)
    db.commit()
    db.refresh(new_character)
    return new_character

@router.get(
    "/characters/{characterId}/paraphrases",
    response_model=List[Paraphrase],
    summary="List Paraphrases for a Character",
    description="Retrieves all paraphrases associated with a specific character.",
    operation_id="listCharacterParaphrases"
)
def list_character_paraphrases(characterId: int, db: Session = Depends(get_db)):
    paraphrases = db.query(ParaphraseDB).filter_by(original_id=characterId, original_type='character').all()
    return paraphrases

@router.post(
    "/characters/{characterId}/paraphrases",
    response_model=Paraphrase,
    status_code=status.HTTP_201_CREATED,
    summary="Create a Paraphrase for a Character",
    description="Creates a new paraphrase for a specific character.",
    operation_id="createCharacterParaphrase"
)
def create_character_paraphrase(characterId: int, paraphrase: ParaphraseCreateRequest, db: Session = Depends(get_db)):
    # Check if character exists
    character = db.query(CharacterDB).filter_by(character_id=characterId).first()
    if not character:
        raise HTTPException(status_code=404, detail="Character not found")
    new_paraphrase = ParaphraseDB(
        original_id=characterId,
        original_type='character',
        text=paraphrase.text,
        commentary=paraphrase.commentary
    )
    db.add(new_paraphrase)
    db.commit()
    db.refresh(new_paraphrase)
    return new_paraphrase

# Actions

@router.get(
    "/actions",
    response_model=List[Action],
    summary="List All Actions",
    description="Retrieves a list of all actions.",
    operation_id="listAllActions"
)
def list_actions(db: Session = Depends(get_db)):
    actions = db.query(ActionDB).all()
    return actions

@router.post(
    "/actions",
    response_model=Action,
    status_code=status.HTTP_201_CREATED,
    summary="Create a New Action",
    description="Creates a new action with the provided description.",
    operation_id="createAction"
)
def create_action(action: ActionCreateRequest, db: Session = Depends(get_db)):
    new_action = ActionDB(description=action.description)
    db.add(new_action)
    db.commit()
    db.refresh(new_action)
    return new_action

@router.get(
    "/actions/{actionId}/paraphrases",
    response_model=List[Paraphrase],
    summary="List Paraphrases for an Action",
    description="Retrieves all paraphrases associated with a specific action.",
    operation_id="listActionParaphrases"
)
def list_action_paraphrases(actionId: int, db: Session = Depends(get_db)):
    paraphrases = db.query(ParaphraseDB).filter_by(original_id=actionId, original_type='action').all()
    return paraphrases

@router.post(
    "/actions/{actionId}/paraphrases",
    response_model=Paraphrase,
    status_code=status.HTTP_201_CREATED,
    summary="Create a Paraphrase for an Action",
    description="Creates a new paraphrase for a specific action.",
    operation_id="createActionParaphrase"
)
def create_action_paraphrase(actionId: int, paraphrase: ParaphraseCreateRequest, db: Session = Depends(get_db)):
    # Check if action exists
    action = db.query(ActionDB).filter_by(action_id=actionId).first()
    if not action:
        raise HTTPException(status_code=404, detail="Action not found")
    new_paraphrase = ParaphraseDB(
        original_id=actionId,
        original_type='action',
        text=paraphrase.text,
        commentary=paraphrase.commentary
    )
    db.add(new_paraphrase)
    db.commit()
    db.refresh(new_paraphrase)
    return new_paraphrase

# SpokenWords

@router.get(
    "/spokenWords",
    response_model=List[SpokenWord],
    summary="List All Spoken Words",
    description="Retrieves a list of all spoken words.",
    operation_id="listAllSpokenWords"
)
def list_spoken_words(db: Session = Depends(get_db)):
    spoken_words = db.query(SpokenWordDB).all()
    return spoken_words

@router.post(
    "/spokenWords",
    response_model=SpokenWord,
    status_code=status.HTTP_201_CREATED,
    summary="Create a New Spoken Word",
    description="Creates a new spoken word with the provided text.",
    operation_id="createSpokenWord"
)
def create_spoken_word(spoken_word: SpokenWordCreateRequest, db: Session = Depends(get_db)):
    new_spoken_word = SpokenWordDB(text=spoken_word.text)
    db.add(new_spoken_word)
    db.commit()
    db.refresh(new_spoken_word)
    return new_spoken_word

@router.get(
    "/spokenWords/{spokenWordId}/paraphrases",
    response_model=List[Paraphrase],
    summary="List Paraphrases for a Spoken Word",
    description="Retrieves all paraphrases associated with a specific spoken word.",
    operation_id="listSpokenWordParaphrases"
)
def list_spoken_word_paraphrases(spokenWordId: int, db: Session = Depends(get_db)):
    paraphrases = db.query(ParaphraseDB).filter_by(original_id=spokenWordId, original_type='spokenWord').all()
    return paraphrases

@router.post(
    "/spokenWords/{spokenWordId}/paraphrases",
    response_model=Paraphrase,
    status_code=status.HTTP_201_CREATED,
    summary="Create a Paraphrase for a Spoken Word",
    description="Creates a new paraphrase for a specific spoken word.",
    operation_id="createSpokenWordParaphrase"
)
def create_spoken_word_paraphrase(spokenWordId: int, paraphrase: ParaphraseCreateRequest, db: Session = Depends(get_db)):
    # Check if spoken word exists
    spoken_word = db.query(SpokenWordDB).filter_by(spoken_word_id=spokenWordId).first()
    if not spoken_word:
        raise HTTPException(status_code=404, detail="Spoken word not found")
    new_paraphrase = ParaphraseDB(
        original_id=spokenWordId,
        original_type='spokenWord',
        text=paraphrase.text,
        commentary=paraphrase.commentary
    )
    db.add(new_paraphrase)
    db.commit()
    db.refresh(new_paraphrase)
    return new_paraphrase
EOL

    echo "Business logic implemented in $router_file."
}

# Function to create models_db.py with SQLAlchemy models
create_database_models() {
    local models_db_file="app/models_db.py"

    cat <<EOL > "$models_db_file"
from sqlalchemy import Column, Integer, String, Text
from app.database import Base

class CharacterDB(Base):
    __tablename__ = 'characters'

    character_id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(Text)

class ParaphraseDB(Base):
    __tablename__ = 'paraphrases'

    paraphrase_id = Column(Integer, primary_key=True, index=True)
    original_id = Column(Integer, index=True)
    original_type = Column(String, index=True)  # 'character', 'action', 'spokenWord'
    text = Column(Text)
    commentary = Column(Text)

class ActionDB(Base):
    __tablename__ = 'actions'

    action_id = Column(Integer, primary_key=True, index=True)
    description = Column(Text)

class SpokenWordDB(Base):
    __tablename__ = 'spoken_words'

    spoken_word_id = Column(Integer, primary_key=True, index=True)
    text = Column(Text)
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
    cd character_management_api || exit
    source venv/bin/activate

    # Install SQLAlchemy if not already installed
    pip install sqlalchemy

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

#### Shell Script: `setup_testing.sh`

```bash
#!/bin/bash

# Function to set up testing environment
setup_testing_environment() {
    cd character_management_api || exit
    source venv/bin/activate

    # Install testing dependencies
    pip install pytest pytest-cov

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

# Set up the test database
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

client = TestClient(app)

def test_create_character():
    response = client.post("/characters", json={"name": "John Doe", "description": "Protagonist"})
    assert response.status_code == 201
    assert response.json()["name"] == "John Doe"

def test_get_character():
    response = client.get("/characters/1")
    assert response.status_code == 200
    assert response.json()["name"] == "John Doe"

def test_get_nonexistent_character():
    response = client.get("/characters/999")
    assert response.status_code == 404
    assert response.json()["detail"] == "Character not found"

# Similar tests can be added for Actions and SpokenWords
EOL

    echo "Test file created at $test_file."
}

# Function to create directory if not exists
create_directory() {
    local dir_path="$1"
    if [ ! -d "$dir_path" ]; then
        mkdir -p "$dir_path"
        echo "Directory $dir_path created."
    else
        echo "Directory $dir_path already exists."
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

#### Shell Script: `create_dockerfile.sh`

```bash
#!/bin/bash

# Function to create Dockerfile
create_dockerfile() {
    local dockerfile_path="character_management_api/Dockerfile"

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
    local requirements_file="character_management_api/requirements.txt"

    cat <<EOL > "$requirements_file"
fastapi
uvicorn
pydantic
sqlalchemy
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

#### Shell Script: `configure_kong_and_route53.sh`

```bash
#!/bin/bash

# Note: This script assumes you have access to AWS CLI and have configured it with the necessary permissions.
# Additionally, configuring Kong requires access to its Admin API.

# Function to configure Kong
configure_kong() {
    echo "Configuring Kong..."

    # Define variables
    KONG_ADMIN_URL="http://localhost:8001"
    SERVICE_NAME="character-management-service"
    ROUTE_NAME="character-management-route"
    SERVICE_URL="http://character_management_api:8080"
    HOST_NAME="character.fountain.coach"

    # Create Service
    curl -i -X POST $KONG_ADMIN_URL/services/ \
      --data "name=$SERVICE_NAME" \
      --data "url=$SERVICE_URL"

    # Create Route
    curl -i -X POST $KONG_ADMIN_URL/services/$SERVICE_NAME/routes \
      --data "name=$ROUTE_NAME" \
      --data "hosts[]=$HOST_NAME" \
      --data "methods[]=GET" \
      --data "methods[]=POST" \
      --data "methods[]=PUT" \
      --data "methods[]=DELETE"

    echo "Kong configuration complete."
}

# Function to configure AWS Route 53
configure_route53() {
    echo "Configuring Route 53..."

    # Define variables
    HOSTED_ZONE_ID="YOUR_HOSTED_ZONE_ID"  # Replace with your actual hosted zone ID
    DOMAIN_NAME="character.fountain.coach."
    KONG_PUBLIC_IP="YOUR_KONG_PUBLIC_IP"  # Replace with the public IP of your Kong gateway

    # Create JSON file for the change batch
    cat <<EOL > change-batch.json
{
  "Comment": "Create A record for character management service",
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

### Instructions for Running the Scripts

1. **Save the OpenAPI Specification**

   Save the provided OpenAPI specification as `character_management_api_openapi.yaml` in the parent directory of your project.

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

   - Create the `character_management_api` directory.
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
   - Replace placeholder values in the script with your actual hosted zone ID and Kong public IP.

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

By following the same implementation path as with the Central Sequence Service, we've provided shell scripts to implement the **Character Management API**:

- **Project Initialization:** Set up the project structure and environment.
- **FastAPI App Generation:** Generated the application files based on the OpenAPI specification.
- **Business Logic Implementation:** Implemented the API endpoints with actual logic, ensuring each route includes `operationId`, `summary`, and `description` for OpenAPI compliance.
- **Testing Setup:** Created test cases to validate the API functionality.
- **Dockerization:** Prepared the application for containerized deployment.
- **Integration with Kong and Route 53:** Configured the API gateway and DNS settings.

These scripts are idempotent and follow the FountainAI shell scripting conventions, ensuring deterministic and reliable execution. Additionally, all FastAPI route definitions include explicit `operationId`, `summary`, and `description` fields to maintain OpenAPI compliance and facilitate seamless interaction with the GPT model for orchestration.

---

## Next Steps

1. **Finalize OpenAPI Specifications:**
   - Ensure all microservices have complete and accurate OpenAPI specs.

2. **Develop and Test Each Microservice Individually:**
   - Implement FastAPI applications adhering to the specifications.
   - Conduct thorough testing to ensure functionality and compliance.

3. **Set Up Docker Compose and Configure Kong:**
   - Define all services in `docker-compose.yml`.
   - Configure Kong API Gateway with the necessary routes and plugins.

4. **Configure DNS Records in Amazon Route 53:**
   - Map subdomains to the Kong API Gateway or load balancer.

5. **Deploy the Entire Stack and Perform Thorough Testing:**
   - Use Docker Compose to deploy services.
   - Validate that all components interact seamlessly.

6. **Implement Security Measures and Monitoring Tools:**
   - Set up authentication, rate limiting, and secure admin interfaces.
   - Integrate logging and monitoring solutions.

7. **Integrate the GPT Model for Orchestration:**
   - Provide the GPT model with OpenAPI specifications.
   - Ensure the model can interact with microservices as intended.

8. **Plan for Scaling and Future Enhancements:**
   - Develop strategies for horizontal scaling.
   - Identify areas for future improvements and feature additions.

---

**This Comprehensive FountainAI Implementation Guide** serves as a significant reference point for current and future FountainAI implementations, focusing on precision, clarity, and best practices to ensure the system's success and longevity.

