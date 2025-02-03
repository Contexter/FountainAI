# FastAPI Implementation Path for the Official FountainAI System

---

## Introduction

This document provides an exact description of the FastAPI implementation path for the Official FountainAI System, as outlined in the system description and implementation plan. The goal is to develop FastAPI applications that precisely match the OpenAPI specifications, ensuring that each microservice operates as intended, with exact input/output conformity.

---

## Overview

The implementation path involves the following key steps:

1. **Define OpenAPI Specifications**
2. **Generate Pydantic Models and API Stubs**
3. **Implement FastAPI Applications**
4. **Set Up Database Models and Persistence**
5. **Implement Endpoint Logic**
6. **Testing and Validation**
7. **Containerization with Docker**
8. **Integration with Kong API Gateway**
9. **Deployment and DNS Configuration**

---

## Detailed Implementation Path

### **1. Define OpenAPI Specifications**

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

### **2. Generate Pydantic Models and API Stubs**

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

### **3. Implement FastAPI Applications**

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

  - In `app/api/endpoints.py`, use the generated Pydantic models to define request and response schemas.

  ```python
  # app/api/endpoints.py
  from fastapi import APIRouter, Depends, HTTPException
  from sqlalchemy.orm import Session
  from app import schemas, models
  from app.database import get_db

  router = APIRouter()

  @router.post("/characters", response_model=schemas.Character)
  def create_character(character: schemas.CharacterCreateRequest, db: Session = Depends(get_db)):
      # Implement logic to create a new character
      db_character = models.Character(**character.dict())
      db.add(db_character)
      db.commit()
      db.refresh(db_character)
      return db_character
  ```

- **Ensure Exact Input/Output:**

  - Validate all inputs using the Pydantic models.
  - Return responses using the Pydantic models to ensure the outputs match the OpenAPI specs.

### **4. Set Up Database Models and Persistence**

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
  ```

- **Define SQLAlchemy Models:**

  ```python
  # app/models.py
  from sqlalchemy import Column, Integer, String, Text
  from app.database import Base

  class Character(Base):
      __tablename__ = 'characters'

      characterId = Column(Integer, primary_key=True, index=True)
      name = Column(String, index=True)
      description = Column(Text)
  ```

- **Initialize Database:**

  ```python
  # app/main.py
  from app.database import engine
  from app import models

  models.Base.metadata.create_all(bind=engine)
  ```

### **5. Implement Endpoint Logic**

**Objective:** Implement the business logic for each endpoint, ensuring that all operations conform to the OpenAPI specifications.

**Actions:**

- **CRUD Operations:**

  - Implement Create, Read, Update, Delete operations as defined.
  - Use the database session (`db: Session = Depends(get_db)`) for database interactions.

- **Error Handling:**

  - Raise appropriate HTTP exceptions (`HTTPException`) with correct status codes and detail messages.

  ```python
  @router.get("/characters/{characterId}", response_model=schemas.Character)
  def get_character(characterId: int, db: Session = Depends(get_db)):
      character = db.query(models.Character).filter(models.Character.characterId == characterId).first()
      if character is None:
          raise HTTPException(status_code=404, detail="Character not found")
      return character
  ```

- **Authentication (If Required):**

  - Implement authentication mechanisms as per the OpenAPI specs.
  - Use dependencies to enforce authentication.

### **6. Testing and Validation**

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

  client = TestClient(app)

  def test_create_character():
      response = client.post("/characters", json={"name": "John Doe", "description": "Protagonist"})
      assert response.status_code == 200
      assert response.json()["name"] == "John Doe"
  ```

- **Validation Against OpenAPI Specs:**

  - Use tools to validate that the API responses conform to the OpenAPI definitions.
  - Ensure that input validation works as expected.

### **7. Containerization with Docker**

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

  CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
  ```

- **Build Docker Image:**

  ```bash
  docker build -t character-management-api .
  ```

- **Ensure SQLite Persistence:**

  - Use Docker volumes to persist the SQLite database file (`app.db`).

### **8. Integration with Kong API Gateway**

**Objective:** Configure Kong to route requests to the FastAPI applications based on the DNS names specified in the OpenAPI specs.

**Actions:**

- **Update `kong.yml`:**

  ```yaml
  _format_version: '2.1'
  services:
    - name: character-management-service
      url: http://character_management_api:8000
      routes:
        - name: character-management-route
          hosts:
            - character.fountain.coach
          paths:
            - /
  ```

- **Mount SSL Certificates:**

  - Ensure SSL certificates are correctly configured for each hostname.

- **Configure Plugins (If Needed):**

  - Add authentication or rate limiting plugins as required.

### **9. Deployment and DNS Configuration**

**Objective:** Deploy the services and ensure they are accessible via the specified DNS names.

**Actions:**

- **Docker Compose Configuration:**

  - Define services in `docker-compose.yml`, including networks and volumes.

- **DNS Configuration in Route 53:**

  - Create DNS records mapping the subdomains (e.g., `character.fountain.coach`) to the public IP or load balancer of the Kong proxy.

- **Run Docker Compose:**

  ```bash
  docker-compose up -d
  ```

- **Verify Deployment:**

  - Test accessing the APIs via the DNS names to ensure that Kong is routing requests properly.

---

## Conclusion

By following this FastAPI implementation path, you will develop microservices that exactly match your OpenAPI specifications, ensuring consistency and correctness across your system. Each microservice will be self-contained, with its own FastAPI application and SQLite database, and will integrate seamlessly with Kong API Gateway and your DNS configuration.

This approach aligns with the Official FountainAI System Description and Implementation Plan, providing a scalable, maintainable, and robust architecture for your system.

---

**Next Steps:**

- Proceed to implement each microservice following the steps outlined above.
- Ensure thorough testing at each stage to validate conformity with the OpenAPI specs.
- Deploy the services incrementally, verifying functionality and integration with Kong and Route 53.
- Update documentation and OpenAPI specs as needed based on implementation details.

---

**Feel free to ask if you need further clarification on any of these steps or assistance with specific implementation details!**