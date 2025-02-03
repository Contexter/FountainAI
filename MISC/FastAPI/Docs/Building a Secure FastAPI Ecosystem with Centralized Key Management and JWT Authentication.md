
# Building a Secure FastAPI Ecosystem with Centralized Key Management and JWT Authentication

---

# Table of Contents
1. [Introduction](#1-introduction)  
2. [Architecture Overview](#2-architecture-overview)  
3. [Project Structure](#3-project-structure)  
4. [Implementation Steps](#4-implementation-steps)  
   - [a. Key Management Service (KMS)](#a-key-management-service-kms)  
   - [b. API Gateway with JWT Authentication](#b-api-gateway-with-jwt-authentication)  
   - [c. Typesense Client Microservice](#c-typesense-client-microservice)  
   - [d. Service A](#d-service-a)  
   - [e. Caddy Configuration](#e-caddy-configuration)  
   - [f. Docker Compose Setup](#f-docker-compose-setup)  
5. [Security Best Practices](#5-security-best-practices)  
6. [Logging and Monitoring](#6-logging-and-monitoring)  
7. [Testing the Ecosystem](#7-testing-the-ecosystem)  
8. [Conclusion](#8-conclusion)  

---

## 1. Introduction

Managing multiple API keys across various services can quickly become complex and error-prone. Centralizing API key management enhances security, simplifies maintenance, and ensures consistent handling of credentials.  

This guide presents a comprehensive approach to building a secure, scalable FastAPI ecosystem with:  
- **Centralized Key Management Service (KMS)**  
- **JWT-based Authentication**  
- **API Gateway**  
- **Caddy for reverse proxy and DNS management**  
- **Typesense for search capabilities**  
- **Example backend service (Service A)**  
- **Docker Compose for streamlined deployment**  

---

### 2. Architecture Overview

---

#### Components:

1. **Key Management Service (KMS)**:  
   - Centralizes API key creation, storage, rotation, and revocation.  
   - Issues and validates JWTs for authenticated access.  

2. **API Gateway**:  
   - Central entry point for client requests.  
   - Validates JWTs for authentication and authorization.  
   - Routes requests to appropriate backend services.  

3. **Typesense Client Microservice**:  
   - Synchronizes backend services with Typesense.  
   - Utilizes API keys from KMS for secure communication.  

4. **Service A**:  
   - Example backend service managing domain-specific data.  
   - Interacts with Typesense via the Typesense Client Microservice.  

5. **Caddy**:  
   - Reverse proxy and DNS manager.  
   - Handles TLS termination and routes traffic to the API Gateway.  

6. **Docker Compose**:  
   - Orchestrates all services, ensuring they communicate over a shared network.  

---
### 3. Project Structure

---

A modular project structure ensures clarity and maintainability. Below is the recommended layout:

```
project-root/
├── api_gateway/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py
│   │   ├── config.py
│   │   ├── schemas/
│   │   │   ├── __init__.py
│   │   │   ├── auth.py
│   │   │   └── proxy.py
│   │   ├── services/
│   │   │   ├── __init__.py
│   │   │   └── auth_service.py
│   │   ├── dependencies.py
│   │   ├── middleware.py
│   │   ├── exceptions.py
│   │   └── logging_config.py
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── .env
│   └── README.md
├── key_management_service/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py
│   │   ├── config.py
│   │   ├── database.py
│   │   ├── models.py
│   │   ├── schemas/
│   │   │   ├── __init__.py
│   │   │   ├── key.py
│   │   │   └── user.py
│   │   ├── services/
│   │   │   ├── __init__.py
│   │   │   ├── auth_service.py
│   │   │   └── key_service.py
│   │   ├── dependencies.py
│   │   ├── middleware.py
│   │   ├── exceptions.py
│   │   ├── utils.py
│   │   └── logging_config.py
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── .env
│   └── README.md
├── typesense_client_service/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py
│   │   ├── config.py
│   │   ├── schemas/
│   │   │   ├── __init__.py
│   │   │   ├── document.py
│   │   │   └── search.py
│   │   ├── services/
│   │   │   ├── __init__.py
│   │   │   └── typesense_service.py
│   │   ├── dependencies.py
│   │   ├── exceptions.py
│   │   └── logging_config.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── README.md
├── service_a/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py
│   │   ├── config.py
│   │   ├── database.py
│   │   ├── models.py
│   │   ├── schemas.py
│   │   ├── services/
│   │   │   ├── __init__.py
│   │   │   └── sync_service.py
│   │   ├── dependencies.py
│   │   ├── exceptions.py
│   │   └── logging_config.py
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── .env
│   └── README.md
├── docker-compose.yml
├── Caddyfile
└── README.md
```

---
### 4. Implementation Steps

#### a. Key Management Service (KMS)

The Key Management Service centralizes the creation, storage, distribution, rotation, and revocation of API keys. It also handles JWT-based authentication for secure access to its endpoints.

---

#### i. Project Setup

1. Create Project Directory:

```bash
mkdir key_management_service
cd key_management_service
mkdir app
mkdir app/schemas
mkdir app/services
touch app/__init__.py app/main.py app/config.py
touch app/database.py app/models.py
touch app/schemas/__init__.py app/schemas/key.py app/schemas/user.py
touch app/services/__init__.py app/services/auth_service.py app/services/key_service.py
touch app/dependencies.py app/middleware.py app/exceptions.py app/utils.py app/logging_config.py
touch Dockerfile requirements.txt .env README.md
```

2. `requirements.txt`:

```
fastapi
uvicorn
pydantic
sqlalchemy
httpx
python-dotenv
passlib[bcrypt]
jose
cryptography
prometheus-fastapi-instrumentator
```

---

#### ii. Configuration & Environment Variables

**File: `app/config.py`**

```python
# app/config.py

import os
from pydantic import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str = "sqlite:///./keys.db"
    SECRET_KEY: str = "your_super_secret_key"  # Replace with a secure key
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    class Config:
        env_file = ".env"

settings = Settings()
```

**File: `.env` (Place in `key_management_service/` directory)**

```
DATABASE_URL=sqlite:///./keys.db
SECRET_KEY=your_super_secret_key  # Replace with a secure key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60
```

**Security Note**: Ensure `.env` is added to `.gitignore` to prevent accidental commits.

---

#### iii. Database Setup

**File: `app/database.py`**

```python
# app/database.py

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

from .config import settings

engine = create_engine(
    settings.DATABASE_URL,
    connect_args={"check_same_thread": False} if settings.DATABASE_URL.startswith("sqlite") else {}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()
```

---

#### iv. Models

**File: `app/models.py`**

```python
# app/models.py

from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from .database import Base

class Service(Base):
    __tablename__ = "services"

    id = Column(Integer, primary_key=True, index=True)
    service_name = Column(String, unique=True, index=True, nullable=False)
    api_key = Column(String, unique=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    roles = Column(String, nullable=False)  # Comma-separated roles
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
```

---

#### v. Schemas

**File: `app/schemas/key.py`**

```python
# app/schemas/key.py

from pydantic import BaseModel, Field

class KeyCreate(BaseModel):
    service_name: str = Field(..., description="Unique name of the service.")
    api_key: str = Field(..., description="API key for the service.")

class KeyResponse(BaseModel):
    service_name: str
    api_key: str

    class Config:
        orm_mode = True

class ErrorResponse(BaseModel):
    errorCode: str
    message: str
    details: str | None = None
```

**File: `app/schemas/user.py`**

```python
# app/schemas/user.py

from pydantic import BaseModel, Field

class UserCreate(BaseModel):
    username: str = Field(..., description="Username for the user.")
    password: str = Field(..., description="Password for the user.")
    roles: str = Field(..., description="Comma-separated roles assigned to the user.")

class UserLogin(BaseModel):
    username: str = Field(..., description="Username for the user.")
    password: str = Field(..., description="Password for the user.")

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: str | None = None
    roles: str | None = None
```

---

#### vi. Services

**File: `app/services/auth_service.py`**

```python
# app/services/auth_service.py

from jose import JWTError, jwt
from datetime import datetime, timedelta
from typing import Optional

from ..config import settings
from ..models import User
from ..schemas.user import TokenData
from ..utils import verify_password

from fastapi import HTTPException, status

SECRET_KEY = settings.SECRET_KEY
ALGORITHM = settings.ALGORITHM
ACCESS_TOKEN_EXPIRE_MINUTES = settings.ACCESS_TOKEN_EXPIRE_MINUTES

class AuthService:
    def create_access_token(self, data: dict, expires_delta: Optional[timedelta] = None):
        to_encode = data.copy()
        expire = datetime.utcnow() + (expires_delta if expires_delta else timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
        to_encode.update({"exp": expire})
        encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
        return encoded_jwt

    def authenticate_user(self, db, username: str, password: str):
        user = db.query(User).filter(User.username == username).first()
        if not user:
            return False
        if not verify_password(password, user.hashed_password):
            return False
        return user

    def verify_token(self, token: str):
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            username: str = payload.get("sub")
            roles: str = payload.get("roles")
            if username is None:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid token.",
                )
            token_data = TokenData(username=username, roles=roles)
            return token_data
        except JWTError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token.",
            )
```

---

**File: `app/services/key_service.py`**

```python
# app/services/key_service.py

import secrets
import string
from sqlalchemy.orm import Session
from ..models import Service
from ..schemas.key import KeyCreate
import logging

logger = logging.getLogger("key-management-service")

class KeyService:
    def __init__(self):
        pass

    def generate_api_key(self, length: int = 40) -> str:
        alphabet = string.ascii_letters + string.digits
        return ''.join(secrets.choice(alphabet) for _ in range(length))

    def create_service_key(self, db: Session, key_create: KeyCreate) -> Service:
        # Check if service already exists
        existing_service = db.query(Service).filter(Service.service_name == key_create.service_name).first()
        if existing_service:
            logger.error(f"Service '{key_create.service_name}' already exists.")
            raise Exception(f"Service '{key_create.service_name}' already exists.")

        # Create new service key
        service = Service(
            service_name=key_create.service_name,
            api_key=key_create.api_key
        )
        db.add(service)
        db.commit()
        db.refresh(service)
        logger.info(f"Created API key for service '{service.service_name}'.")
        return service

    def get_service_key(self, db: Session, service_name: str) -> Service:
        service = db.query(Service).filter(Service.service_name == service_name).first()
        if not service:
            logger.error(f"Service '{service_name}' not found.")
            raise Exception(f"Service '{service_name}' not found.")
        return service

    def revoke_service_key(self, db: Session, service_name: str) -> None:
        service = db.query(Service).filter(Service.service_name == service_name).first()
        if not service:
            logger.error(f"Service '{service_name}' not found.")
            raise Exception(f"Service '{service_name}' not found.")
        db.delete(service)
        db.commit()
        logger.info(f"Revoked API key for service '{service_name}'.")
```

---

#### vii. Utilities

**File: `app/utils.py`**

```python
# app/utils.py

from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)
```

---

#### viii. Dependencies

**File: `app/dependencies.py`**

```python
# app/dependencies.py

from fastapi import Depends, HTTPException, status, Header
from sqlalchemy.orm import Session
from jose import JWTError, jwt
from .database import SessionLocal
from .models import Service, User
from .services.key_service import KeyService
from .schemas.user import TokenData
from .config import settings
from .services.auth_service import AuthService

import logging

logger = logging.getLogger("key-management-service")

# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Initialize KeyService and AuthService
key_service = KeyService()
auth_service = AuthService()

# Dependency to extract token from Authorization header
def get_token_header(authorization: str = Header(...)):
    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials.",
        )
    token = authorization.split(" ")[1]
    return token

# Dependency to authenticate using JWT tokens
def get_current_user(token: str = Depends(get_token_header)):
    try:
        token_data = auth_service.verify_token(token)
        return token_data
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token.",
        )
```

---

#### ix. Exception Handlers

**File: `app/exceptions.py`**

```python
# app/exceptions.py

from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
from .schemas.key import ErrorResponse
import logging

logger = logging.getLogger("key-management-service")

async def http_exception_handler(request: Request, exc: HTTPException):
    logger.error(f"HTTPException: {exc.detail}")
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "errorCode": "HTTP_EXCEPTION",
            "message": exc.detail,
            "details": None
        }
    )

async def generic_exception_handler(request: Request, exc: Exception):
    logger.exception(f"Unhandled exception: {exc}")
    return JSONResponse(
        status_code=500,
        content={
            "errorCode": "INTERNAL_SERVER_ERROR",
            "message": "An unexpected error occurred.",
            "details": str(exc),
        }
    )
```

---

#### x. Logging Configuration

**File: `app/logging_config.py`**

```python
# app/logging_config.py

import logging
import sys
import json

class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "time": self.formatTime(record, self.datefmt),
            "level": record.levelname,
            "name": record.name,
            "message": record.getMessage(),
            "function": record.funcName,
            "line": record.lineno,
        }
        return json.dumps(log_record)

def setup_logging():
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JsonFormatter())
    logger.addHandler(handler)
```

---

#### xi. Main Application

**File: `app/main.py`**

```python
# app/main.py

from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from .config import settings
from .dependencies import get_db, key_service, auth_service, get_current_user
from .schemas.key import KeyCreate, KeyResponse
from .schemas.user import UserCreate, UserLogin, Token
from .services.key_service import KeyService
from .exceptions import http_exception_handler, generic_exception_handler
from .utils import hash_password
from .logging_config import setup_logging

from prometheus_fastapi_instrumentator import Instrumentator

# Setup logging
setup_logging()

# Initialize FastAPI app
app = FastAPI(
    title="Key Management Service API",
    description="Centralized service for managing API keys.",
    version="1.0.0",
)

# Register exception handlers
app.add_exception_handler(HTTPException, http_exception_handler)
app.add_exception_handler(Exception, generic_exception_handler)

# Initialize Prometheus Instrumentator
instrumentator = Instrumentator()
instrumentator.instrument(app).expose(app)

# Initialize KeyService and AuthService
key_service = KeyService()
auth_service = AuthService()

# ------------------------------------------------------------------
# 1. Health Check Endpoint
# ------------------------------------------------------------------

@app.get("/health", status_code=200)
def health_check():
    return {"status": "healthy"}

# ------------------------------------------------------------------
# 2. User Authentication Endpoints
# ------------------------------------------------------------------

@app.post("/register", summary="Register User", tags=["Authentication"], status_code=201)
def register_user(user: UserCreate, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.username == user.username).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already registered.")
    hashed_pwd = hash_password(user.password)
    new_user = User(
        username=user.username,
        hashed_password=hashed_pwd,
        roles=user.roles
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return {"message": "User registered successfully."}

@app.post("/login", response_model=Token, summary="Login User", tags=["Authentication"])
def login(user: UserLogin, db: Session = Depends(get_db)):
    authenticated_user = auth_service.authenticate_user(db, user.username, user.password)
    if not authenticated_user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password.",
        )
    access_token = auth_service.create_access_token(
        data={"sub": authenticated_user.username, "roles": authenticated_user.roles}
    )
    return {"access_token": access_token, "token_type": "bearer"}

# ------------------------------------------------------------------
# 3. Key Management Endpoints
# ------------------------------------------------------------------

@app.post(
    "/keys",
    summary="Create API Key",
    description="Creates a new API key for a specified service.",
    tags=["Key Management"],
    response_model=KeyResponse,
    status_code=201,
    dependencies=[Depends(get_current_user)]
)
def create_api_key(key_create: KeyCreate, db: Session = Depends(get_db)):
    try:
        service = key_service.create_service_key(db, key_create)
        return KeyResponse(service_name=service.service_name, api_key=service.api_key)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get(
    "/keys/{service_name}",
    summary="Retrieve API Key",
    description="Retrieves the API key for a specified service.",
    tags=["Key Management"],
    response_model=KeyResponse,
    dependencies=[Depends(get_current_user)]
)
def get_api_key(service_name: str, db: Session = Depends(get_db)):
    try:
        service = key_service.get_service_key(db, service_name)
        return KeyResponse(service_name=service.service_name, api_key=service.api_key)
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))

@app.delete(
    "/keys/{service_name}",
    summary="Revoke API Key",
    description="Revokes (deletes) the API key for a specified service.",
    tags=["Key Management"],
    status_code=204,
    dependencies=[Depends(get_current_user)]
)
def revoke_api_key(service_name: str, db: Session = Depends(get_db)):
    try:
        key_service.revoke_service_key(db, service_name)
        return
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))

@app.post(
    "/keys/{service_name}/rotate",
    summary="Rotate API Key",
    description="Rotates the API key for a specified service.",
    tags=["Key Management"],
    response_model=KeyResponse,
    dependencies=[Depends(get_current_user)]
)
def rotate_api_key(service_name: str, db: Session = Depends(get_db)):
    try:
        # Generate a new API key
        new_api_key = key_service.generate_api_key()
        # Update the service with the new API key
        service = key_service.get_service_key(db, service_name)
        service.api_key = new_api_key
        db.commit()
        db.refresh(service)
        logger.info(f"Rotated API key for service '{service_name}'.")
        return KeyResponse(service_name=service.service_name, api_key=service.api_key)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
```

---

#### xii. Dockerfile

**File: `Dockerfile`**

```dockerfile
# Dockerfile

FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY ./app /app/app

# Expose port
EXPOSE 8003

# Run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8003"]
```

---

#### b. API Gateway with JWT Authentication

---

**i. Project Setup**

1. **Create Project Directory**:

```bash
mkdir api_gateway
cd api_gateway
mkdir app
mkdir app/schemas
mkdir app/services
touch app/__init__.py app/main.py app/config.py
touch app/schemas/__init__.py app/schemas/auth.py app/schemas/proxy.py
touch app/services/__init__.py app/services/auth_service.py
touch app/dependencies.py app/middleware.py app/exceptions.py app/logging_config.py
touch Dockerfile requirements.txt .env README.md
```

2. **`requirements.txt`**:

```plaintext
fastapi
uvicorn
pydantic
httpx
python-dotenv
passlib[bcrypt]
jose
cryptography
prometheus-fastapi-instrumentator
```

---

**ii. Configuration & Environment Variables**

**File: `app/config.py`**

```python
# app/config.py

import os
from pydantic import BaseSettings

class Settings(BaseSettings):
    API_GATEWAY_HOST: str = "0.0.0.0"
    API_GATEWAY_PORT: int = 8002
    CADDY_URL: str = "http://caddy:2019"
    TYPESENSE_CLIENT_URL: str = "http://typesense_client_service:8001"
    KEY_MANAGEMENT_URL: str = "http://key_management_service:8003"
    SERVICE_NAME: str = "api_gateway"
    ADMIN_TOKEN: str  # JWT token with admin privileges to fetch API keys

    class Config:
        env_file = ".env"

settings = Settings()
```

**File: `.env`** *(Place in `api_gateway/` directory)*

```plaintext
API_GATEWAY_HOST=0.0.0.0
API_GATEWAY_PORT=8002
CADDY_URL=http://caddy:2019
TYPESENSE_CLIENT_URL=http://typesense_client_service:8001
KEY_MANAGEMENT_URL=http://key_management_service:8003
SERVICE_NAME=api_gateway
ADMIN_TOKEN=your_admin_jwt_token  # Replace with a secure JWT
```

> **Security Note:** Ensure `.env` is added to `.gitignore` to prevent accidental commits.

---

#### iii. Schemas

**File: `app/schemas/auth.py`**

```python
# app/schemas/auth.py

from pydantic import BaseModel

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: str | None = None
    roles: str | None = None
```

---

**File: `app/schemas/proxy.py`**

```python
# app/schemas/proxy.py

from pydantic import BaseModel

class ProxyRequest(BaseModel):
    path: str
    method: str
    headers: dict
    body: dict = {}
```

---

#### iv. Services

**File: `app/services/auth_service.py`**

```python
# app/services/auth_service.py

from jose import JWTError, jwt
from datetime import datetime, timedelta
from typing import Optional

from ..config import settings
from ..schemas.auth import TokenData
from fastapi import HTTPException, status

SECRET_KEY = settings.ADMIN_TOKEN  # Use admin JWT token for KMS interaction
ALGORITHM = "HS256"

class AuthService:
    def verify_token(self, token: str):
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            username: str = payload.get("sub")
            roles: str = payload.get("roles")
            if username is None:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid token.",
                )
            token_data = TokenData(username=username, roles=roles)
            return token_data
        except JWTError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token.",
            )
```

---

**File: `app/services/key_service.py`**

```python
# app/services/key_service.py

import httpx
from typing import Dict, Any
from ..config import settings
import logging

logger = logging.getLogger("api-gateway")

class KeyService:
    def __init__(self):
        self.client = httpx.Client(base_url=settings.KEY_MANAGEMENT_URL, timeout=5.0)
        self.service_name = settings.SERVICE_NAME
        self.admin_token = settings.ADMIN_TOKEN  # JWT token with admin privileges

    def get_api_key(self) -> str:
        try:
            response = self.client.get(
                f"/keys/{self.service_name}",
                headers={"Authorization": f"Bearer {self.admin_token}"}
            )
            response.raise_for_status()
            key_data = response.json()
            logger.info(f"Retrieved API key for service '{self.service_name}'.")
            return key_data['api_key']
        except httpx.HTTPError as e:
            logger.error(f"Failed to retrieve API key: {e}")
            raise Exception("Unable to fetch API key from Key Management Service.")
```

---

#### v. Dependencies

**File: `app/dependencies.py`**

```python
# app/dependencies.py

from fastapi import Header, HTTPException, status, Depends
from jose import JWTError, jwt
from .config import settings
from .services.auth_service import AuthService
from typing import List

auth_service = AuthService()

def get_token_header(authorization: str = Header(...)):
    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials.",
        )
    token = authorization.split(" ")[1]
    return token

def get_current_user(token: str = Depends(get_token_header)):
    try:
        token_data = auth_service.verify_token(token)
        return token_data
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token.",
        )

def get_current_user_roles(user: auth_service.verify_token = Depends(get_current_user)) -> List[str]:
    return user.roles.split(",") if user.roles else []

def require_admin(user_roles: List[str] = Depends(get_current_user_roles)):
    if "admin" not in user_roles:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions",
        )
    return user_roles
```

---

#### vi. Exception Handlers

**File: `app/exceptions.py`**

```python
# app/exceptions.py

from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
from .schemas.auth import TokenData
import logging

logger = logging.getLogger("api-gateway")

async def http_exception_handler(request: Request, exc: HTTPException):
    logger.error(f"HTTPException: {exc.detail}")
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "errorCode": "HTTP_EXCEPTION",
            "message": exc.detail,
            "details": None
        }
    )

async def generic_exception_handler(request: Request, exc: Exception):
    logger.exception(f"Unhandled exception: {exc}")
    return JSONResponse(
        status_code=500,
        content={
            "errorCode": "INTERNAL_SERVER_ERROR",
            "message": "An unexpected error occurred.",
            "details": str(exc),
        }
    )
```

---
#### vii. Logging Configuration

**File: `app/logging_config.py`**

```python
# app/logging_config.py

import logging
import sys
import json

class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "time": self.formatTime(record, self.datefmt),
            "level": record.levelname,
            "name": record.name,
            "message": record.getMessage(),
            "function": record.funcName,
            "line": record.lineno,
        }
        return json.dumps(log_record)

def setup_logging():
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JsonFormatter())
    logger.addHandler(handler)
```

---

#### viii. Main Application

**File: `app/main.py`**

```python
# app/main.py

from fastapi import FastAPI, Depends, HTTPException, Request
import httpx
from typing import Optional
from starlette.responses import Response

from .config import settings
from .dependencies import get_token_header, get_current_user, require_admin
from .schemas.auth import Token, TokenData
from .schemas.proxy import ProxyRequest
from .services.auth_service import AuthService
from .services.key_service import KeyService
from .exceptions import http_exception_handler, generic_exception_handler
from .logging_config import setup_logging

from prometheus_fastapi_instrumentator import Instrumentator

# Setup logging
setup_logging()

# Initialize FastAPI app
app = FastAPI(
    title="API Gateway",
    description="Centralized API Gateway for routing and managing API keys.",
    version="1.0.0",
)

# Register exception handlers
app.add_exception_handler(HTTPException, http_exception_handler)
app.add_exception_handler(Exception, generic_exception_handler)

# Initialize Prometheus Instrumentator
instrumentator = Instrumentator()
instrumentator.instrument(app).expose(app)

# Initialize KeyService
key_service = KeyService()
try:
    settings.API_KEY = key_service.get_api_key()
except Exception as e:
    # Handle the exception appropriately, possibly shutting down the service
    import sys
    sys.exit(f"Failed to retrieve API key: {e}")

# Initialize HTTPX client
client = httpx.AsyncClient()

# ------------------------------------------------------------------
# 1. Health Check Endpoint
# ------------------------------------------------------------------

@app.get("/health", status_code=200)
async def health_check():
    return {"status": "healthy"}

# ------------------------------------------------------------------
# 2. Proxy Endpoint
# ------------------------------------------------------------------

@app.api_route("/{full_path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH"])
async def proxy(full_path: str, request: Request, token: str = Depends(get_token_header)):
    """
    Proxy all requests to the appropriate backend service based on the URL path.
    Example: /service_a/sequence -> Service A
    """
    # Validate JWT
    user = Depends(get_current_user)
    roles = Depends(get_current_user_roles)
    # Further authorization can be implemented based on roles

    # Extract the target service from the path
    path_parts = full_path.split("/")
    if not path_parts:
        raise HTTPException(status_code=400, detail="Invalid path")

    service_name = path_parts[0]
    service_path = "/".join(path_parts[1:])

    # Map service names to internal URLs
    service_map = {
        "service_a": "http://service_a:8000",
        # Add other services as needed
    }

    if service_name not in service_map:
        raise HTTPException(status_code=404, detail="Service not found")

    target_url = f"{service_map[service_name]}/{service_path}"

    # Forward the request to the target service
    try:
        headers = dict(request.headers)
        # Remove host header to prevent forwarding to the gateway
        headers.pop("host", None)
        # Optionally add or modify headers, e.g., include service API key
        headers["X-API-KEY"] = settings.API_KEY
        # Forward the request
        response = await client.request(
            method=request.method,
            url=target_url,
            headers=headers,
            data=await request.body(),
            params=request.query_params
        )
        return Response(content=response.content, status_code=response.status_code, headers=dict(response.headers))
    except httpx.HTTPError as e:
        raise HTTPException(status_code=502, detail=str(e))
```

---

#### ix. Dockerfile

**File: `Dockerfile`**

```dockerfile
# Dockerfile

FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY ./app /app/app

# Expose port
EXPOSE 8002

# Run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8002"]
```

---

 #### c. Typesense Client Microservice

---

**i. Project Setup**

1. **Create Project Directory**:

```bash
mkdir typesense_client_service
cd typesense_client_service
mkdir app
mkdir app/schemas
mkdir app/services
touch app/__init__.py app/main.py app/config.py
touch app/schemas/__init__.py app/schemas/document.py app/schemas/search.py
touch app/services/__init__.py app/services/typesense_service.py
touch app/dependencies.py app/exceptions.py app/logging_config.py
touch Dockerfile requirements.txt README.md
```

2. **`requirements.txt`**:

```plaintext
fastapi
uvicorn
pydantic
httpx
python-dotenv
typesense
prometheus-fastapi-instrumentator
```

---

**ii. Configuration & Environment Variables**

**File: `app/config.py`**

```python
# app/config.py

import os
from pydantic import BaseSettings

class Settings(BaseSettings):
    TYPESENSE_HOST: str = "typesense"
    TYPESENSE_PORT: int = 8108
    TYPESENSE_PROTOCOL: str = "http"
    TYPESENSE_API_KEY: str
    TYPESENSE_COLLECTION_NAME: str = "elements"
    TYPESENSE_SERVICE_API_KEY: str  # From KMS
    KEY_MANAGEMENT_URL: str = "http://key_management_service:8003"
    SERVICE_NAME: str = "typesense_client_service"
    ADMIN_TOKEN: str  # JWT token with admin privileges

    class Config:
        env_file = ".env"

settings = Settings()
```

**File: `.env`** *(Place in `typesense_client_service/` directory)*

```plaintext
TYPESENSE_HOST=typesense
TYPESENSE_PORT=8108
TYPESENSE_PROTOCOL=http
TYPESENSE_API_KEY=z9y8x7w6v5u4t3s2r1q0p9o8n7m6l5k4j3i2h1g0f9e8d7c6b5a4z3y2x1w0v9u8
TYPESENSE_COLLECTION_NAME=elements
TYPESENSE_SERVICE_API_KEY=your_secure_typesense_service_api_key
KEY_MANAGEMENT_URL=http://key_management_service:8003
SERVICE_NAME=typesense_client_service
ADMIN_TOKEN=your_admin_jwt_token  # Replace with a secure JWT
```

> **Security Note:** Ensure `.env` is added to `.gitignore` to prevent accidental commits.

---

#### iii. Schemas

**File: `app/schemas/document.py`**

```python
# app/schemas/document.py

from pydantic import BaseModel, Field

class Document(BaseModel):
    id: str
    element_type: str
    element_id: int
    sequence_number: int
    version_number: int
    comment: str
    service_name: str

    class Config:
        orm_mode = True

class SyncPayload(BaseModel):
    operation: str
    document: Document

class SuccessResponse(BaseModel):
    message: str

class ErrorResponse(BaseModel):
    errorCode: str
    message: str
    details: str | None = None
```

---

**File: `app/schemas/search.py`**

```python
# app/schemas/search.py

from pydantic import BaseModel, Field
from typing import List, Optional

class SearchRequest(BaseModel):
    q: str
    query_by: str
    filter_by: Optional[str] = None
    sort_by: Optional[str] = None
    max_hits: int = 10

class SearchHit(BaseModel):
    id: str
    element_type: str
    element_id: int
    sequence_number: int
    version_number: int
    comment: str
    service_name: str

class SearchResponse(BaseModel):
    hits: List[SearchHit]
    found: int
```

---

#### iv. Services

**File: `app/services/typesense_service.py`**

```python
# app/services/typesense_service.py

import typesense
from .config import settings
import logging

logger = logging.getLogger("typesense-client-service")

class TypesenseService:
    def __init__(self):
        self.client = typesense.Client({
            'nodes': [{
                'host': settings.TYPESENSE_HOST,
                'port': settings.TYPESENSE_PORT,
                'protocol': settings.TYPESENSE_PROTOCOL
            }],
            'api_key': settings.TYPESENSE_API_KEY,
            'connection_timeout_seconds': 2
        })
        self.collection_name = settings.TYPESENSE_COLLECTION_NAME
        self.ensure_collection()

    def ensure_collection(self):
        try:
            self.client.collections[self.collection_name].retrieve()
            logger.info(f"Typesense collection '{self.collection_name}' exists.")
        except typesense.exceptions.ObjectNotFound:
            logger.info(f"Creating Typesense collection '{self.collection_name}'.")
            self.client.collections.create({
                'name': self.collection_name,
                'fields': [
                    {'name': 'id', 'type': 'string'},
                    {'name': 'element_type', 'type': 'string'},
                    {'name': 'element_id', 'type': 'int32'},
                    {'name': 'sequence_number', 'type': 'int32'},
                    {'name': 'version_number', 'type': 'int32'},
                    {'name': 'comment', 'type': 'string'},
                    {'name': 'service_name', 'type': 'string'},
                ],
                'default_sorting_field': 'sequence_number'
            })

    def upsert_document(self, document: dict):
        try:
            self.client.collections[self.collection_name].documents.upsert(document)
            logger.info(f"Upserted document ID: {document['id']}")
        except Exception as e:
            logger.error(f"Failed to upsert document ID: {document['id']}, Error: {e}")
            raise

    def delete_document(self, document_id: str):
        try:
            self.client.collections[self.collection_name].documents[document_id].delete()
            logger.info(f"Deleted document ID: {document_id}")
        except typesense.exceptions.ObjectNotFound:
            logger.warning(f"Document ID: {document_id} not found for deletion.")
        except Exception as e:
            logger.error(f"Failed to delete document ID: {document_id}, Error: {e}")
            raise

    def search_documents(self, search_request: dict) -> dict:
        try:
            results = self.client.collections[self.collection_name].documents.search(search_request)
            return results
        except Exception as e:
            logger.error(f"Search failed: {e}")
            raise
```

---
#### v. Dependencies

**File: `app/dependencies.py`**

```python
# app/dependencies.py

from fastapi import Depends, HTTPException, Header, status
from jose import JWTError, jwt
from .services.auth_service import AuthService
from .config import settings
from .schemas.auth import TokenData
from fastapi.security import OAuth2PasswordBearer

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

auth_service = AuthService()

def get_token_header(authorization: str = Header(...)):
    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials.",
        )
    token = authorization.split(" ")[1]
    return token

def get_current_user(token: str = Depends(get_token_header)):
    try:
        token_data = auth_service.verify_token(token)
        return token_data
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token.",
        )
```

---

#### vi. Exception Handlers

**File: `app/exceptions.py`**

```python
# app/exceptions.py

from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
from .schemas.document import ErrorResponse
import logging

logger = logging.getLogger("typesense-client-service")

async def http_exception_handler(request: Request, exc: HTTPException):
    logger.error(f"HTTPException: {exc.detail}")
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "errorCode": "HTTP_EXCEPTION",
            "message": exc.detail,
            "details": None
        }
    )

async def generic_exception_handler(request: Request, exc: Exception):
    logger.exception(f"Unhandled exception: {exc}")
    return JSONResponse(
        status_code=500,
        content={
            "errorCode": "INTERNAL_SERVER_ERROR",
            "message": "An unexpected error occurred.",
            "details": str(exc),
        }
    )
```

---
#### vii. Logging Configuration

**File: `app/logging_config.py`**

```python
# app/logging_config.py

import logging
import sys
import json

class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "time": self.formatTime(record, self.datefmt),
            "level": record.levelname,
            "name": record.name,
            "message": record.getMessage(),
            "function": record.funcName,
            "line": record.lineno,
        }
        return json.dumps(log_record)

def setup_logging():
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JsonFormatter())
    logger.addHandler(handler)
```

---

#### viii. Main Application

**File: `app/main.py`**

```python
# app/main.py

from fastapi import FastAPI, Depends, HTTPException, status
from typing import List

from .config import settings
from .dependencies import get_current_user
from .schemas.document import (
    Document, SyncPayload, SuccessResponse, ErrorResponse
)
from .schemas.search import SearchRequest, SearchResponse, SearchHit
from .services.typesense_service import TypesenseService
from .services.key_service import KeyService
from .exceptions import http_exception_handler, generic_exception_handler
from .logging_config import setup_logging

from prometheus_fastapi_instrumentator import Instrumentator

# Setup logging
setup_logging()

# Initialize FastAPI app
app = FastAPI(
    title="Typesense Client Microservice API",
    description="Handles synchronization and management of Typesense collections and documents.",
    version="1.0.0",
)

# Register exception handlers
app.add_exception_handler(HTTPException, http_exception_handler)
app.add_exception_handler(Exception, generic_exception_handler)

# Initialize Prometheus Instrumentator
instrumentator = Instrumentator()
instrumentator.instrument(app).expose(app)

# Initialize Typesense service
typesense_service = TypesenseService()

# Initialize KeyService
key_service = KeyService()
try:
    settings.API_KEY = key_service.get_api_key()
except Exception as e:
    import sys
    sys.exit(f"Failed to retrieve API key: {e}")

# ------------------------------------------------------------------
# 1. Health Check Endpoint
# ------------------------------------------------------------------

@app.get("/health", status_code=200)
def health_check():
    return {"status": "healthy"}

# ------------------------------------------------------------------
# 2. Document Synchronization Endpoint
# ------------------------------------------------------------------

@app.post(
    "/documents/sync",
    summary="Synchronize Document",
    description="Synchronizes a document with Typesense based on the operation.",
    tags=["Synchronization"],
    response_model=SuccessResponse,
    status_code=200
)
def sync_document(payload: SyncPayload, current_user: TokenData = Depends(get_current_user)):
    """
    Endpoint to synchronize documents with Typesense.
    """
    try:
        if payload.operation.lower() == "create" or payload.operation.lower() == "update":
            typesense_service.upsert_document(payload.document.dict())
            return SuccessResponse(message="Document synchronized successfully.")
        elif payload.operation.lower() == "delete":
            typesense_service.delete_document(payload.document.id)
            return SuccessResponse(message="Document deleted successfully.")
        else:
            raise HTTPException(status_code=400, detail="Invalid operation type.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ------------------------------------------------------------------
# 3. Search Endpoint
# ------------------------------------------------------------------

@app.post(
    "/search",
    summary="Search Documents",
    description="Searches documents in Typesense based on the query parameters.",
    tags=["Search"],
    response_model=SearchResponse,
    status_code=200
)
def search_documents(search_request: SearchRequest, current_user: TokenData = Depends(get_current_user)):
    try:
        results = typesense_service.search_documents(search_request.dict())
        hits = [SearchHit(**hit['document']) for hit in results['hits']]
        return SearchResponse(hits=hits, found=results['found'])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

---
#### ix. Dockerfile

**File: `Dockerfile`**

```dockerfile
# Dockerfile

FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY ./app /app/app

# Expose port
EXPOSE 8001

# Run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001"]
```

---

#### d. Service A

---

**i. Project Setup**

1. **Create Project Directory**:

```bash
mkdir service_a
cd service_a
mkdir app
mkdir app/services
touch app/__init__.py app/main.py app/config.py
touch app/database.py app/models.py app/schemas.py
touch app/services/__init__.py app/services/sync_service.py
touch app/dependencies.py app/exceptions.py app/logging_config.py
touch Dockerfile requirements.txt .env README.md
```

2. **`requirements.txt`**:

```plaintext
fastapi
uvicorn
pydantic
sqlalchemy
httpx
python-dotenv
prometheus-fastapi-instrumentator
```

---

**ii. Configuration & Environment Variables**

**File: `app/config.py`**

```python
# app/config.py

import os
from pydantic import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str = "sqlite:///./database.db"
    TYPESENSE_CLIENT_URL: str = "http://typesense_client_service:8001"
    TYPESENSE_SERVICE_API_KEY: str
    KEY_MANAGEMENT_URL: str = "http://key_management_service:8003"
    SERVICE_NAME: str = "service_a"
    ADMIN_TOKEN: str  # JWT token with admin privileges

    class Config:
        env_file = ".env"

settings = Settings()
```

**File: `.env`** *(Place in `service_a/` directory)*

```plaintext
DATABASE_URL=sqlite:///./database.db
TYPESENSE_CLIENT_URL=http://typesense_client_service:8001
TYPESENSE_SERVICE_API_KEY=your_secure_typesense_service_api_key
KEY_MANAGEMENT_URL=http://key_management_service:8003
SERVICE_NAME=service_a
ADMIN_TOKEN=your_admin_jwt_token  # Replace with a secure JWT
```

> **Security Note:** Ensure `.env` is added to `.gitignore` to prevent accidental commits.

---

**iii. Database Setup**

**File: `app/database.py`**

```python
# app/database.py

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

from .config import settings

engine = create_engine(
    settings.DATABASE_URL,
    connect_args={"check_same_thread": False} if settings.DATABASE_URL.startswith("sqlite") else {}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()
```

---

#### iv. Models

**File: `app/models.py`**

```python
# app/models.py

from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from .database import Base

class Element(Base):
    __tablename__ = "elements"

    id = Column(Integer, primary_key=True, index=True)
    element_type = Column(String, nullable=False)
    element_id = Column(Integer, nullable=False)
    sequence_number = Column(Integer, nullable=False)
    version_number = Column(Integer, nullable=False)
    comment = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
```

---

#### v. Schemas

**File: `app/schemas.py`**

```python
# app/schemas.py

from pydantic import BaseModel, Field
from typing import List, Optional
from enum import Enum

class ElementTypeEnum(str, Enum):
    script = "script"
    section = "section"
    character = "character"
    action = "action"
    spokenWord = "spokenWord"

class SequenceRequest(BaseModel):
    elementType: ElementTypeEnum = Field(..., alias="elementType", description="Type of the element.")
    elementId: int = Field(..., alias="elementId", ge=1, description="Unique identifier of the element.")
    comment: str = Field(..., description="Contextual explanation for generating the sequence number.")

    class Config:
        allow_population_by_field_name = True

class SequenceResponse(BaseModel):
    sequenceNumber: int
    comment: str

class ReorderRequest(BaseModel):
    elementIds: List[int] = Field(..., description="List of element IDs to reorder.")
    newOrder: List[int] = Field(..., description="New sequence order.")

class ReorderResponseElement(BaseModel):
    elementId: int
    oldSequenceNumber: int
    newSequenceNumber: int

class ReorderResponse(BaseModel):
    reorderedElements: List[ReorderResponseElement]
    comment: str

class VersionRequest(BaseModel):
    elementType: ElementTypeEnum = Field(..., alias="elementType", description="Type of the element.")
    elementId: int = Field(..., alias="elementId", ge=1, description="Unique identifier of the element.")
    newVersionData: dict = Field(..., alias="newVersionData", description="Data for the new version.")
    comment: str = Field(..., description="Contextual explanation for creating a new version.")

    class Config:
        allow_population_by_field_name = True

class VersionResponse(BaseModel):
    versionNumber: int
    comment: str

class ErrorResponse(BaseModel):
    errorCode: str
    message: str
    details: str | None = None

class TypesenseErrorResponse(BaseModel):
    errorCode: str
    retryAttempt: int
    message: str
    details: str
```

---

#### vi. Services

**File: `app/services/sync_service.py`**

```python
# app/services/sync_service.py

import httpx
from typing import Dict, Any
from ..config import settings
import logging

logger = logging.getLogger("service_a")

class SyncService:
    def __init__(self):
        self.client = httpx.Client(base_url=settings.TYPESENSE_CLIENT_URL, timeout=5.0)
        self.api_key = settings.TYPESENSE_SERVICE_API_KEY

    def sync_document(self, payload: Dict[str, Any]):
        try:
            response = self.client.post(
                "/documents/sync",
                json=payload,
                headers={"Authorization": f"Bearer {self.api_key}"}
            )
            response.raise_for_status()
            logger.info(f"Successfully synchronized document ID: {payload['document']['id']}")
        except httpx.HTTPError as e:
            logger.error(f"Failed to synchronize document ID: {payload['document']['id']}, Error: {e}")
            raise Exception("Typesense synchronization failed.")
```

---

#### vii. Dependencies

**File: `app/dependencies.py`**

```python
# app/dependencies.py

from fastapi import Depends, HTTPException, Header, status
from jose import JWTError, jwt
from .services.auth_service import AuthService
from .config import settings
from .schemas.user import TokenData

auth_service = AuthService()

def get_token_header(x_api_key: str = Header(...)):
    if x_api_key != settings.TYPESENSE_SERVICE_API_KEY:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing API Key",
        )
    return x_api_key

def get_current_user(token: str = Depends(get_token_header)):
    try:
        token_data = auth_service.verify_token(token)
        return token_data
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token.",
        )
```

---

#### viii. Exception Handlers

**File: `app/exceptions.py`**

```python
# app/exceptions.py

from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
from .schemas.document import ErrorResponse
import logging

logger = logging.getLogger("service_a")

async def http_exception_handler(request: Request, exc: HTTPException):
    logger.error(f"HTTPException: {exc.detail}")
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "errorCode": "HTTP_EXCEPTION",
            "message": exc.detail,
            "details": None
        }
    )

async def generic_exception_handler(request: Request, exc: Exception):
    logger.exception(f"Unhandled exception: {exc}")
    return JSONResponse(
        status_code=500,
        content={
            "errorCode": "INTERNAL_SERVER_ERROR",
            "message": "An unexpected error occurred.",
            "details": str(exc),
        }
    )
```

---

#### ix. Logging Configuration

**File: `app/logging_config.py`**

```python
# app/logging_config.py

import logging
import sys
import json

class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "time": self.formatTime(record, self.datefmt),
            "level": record.levelname,
            "name": record.name,
            "message": record.getMessage(),
            "function": record.funcName,
            "line": record.lineno,
        }
        return json.dumps(log_record)

def setup_logging():
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JsonFormatter())
    logger.addHandler(handler)
```

---
#### x. Main Application

**File: `app/main.py`**

```python
# app/main.py

from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session

from .config import settings
from .dependencies import get_current_user
from .database import engine, Base, SessionLocal
from .models import Element
from .schemas import (
    SequenceRequest, SequenceResponse,
    ReorderRequest, ReorderResponse, ReorderResponseElement,
    VersionRequest, VersionResponse
)
from .services.sync_service import SyncService
from .exceptions import http_exception_handler, generic_exception_handler
from .logging_config import setup_logging

from prometheus_fastapi_instrumentator import Instrumentator

# Setup logging
setup_logging()

# Initialize FastAPI app
app = FastAPI(
    title="Service A API",
    description="Manages elements with sequence and versioning, synchronizing with Typesense.",
    version="1.0.0",
)

# Create database tables
Base.metadata.create_all(bind=engine)

# Initialize SyncService
sync_service = SyncService()

# Dependency for DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Register exception handlers
app.add_exception_handler(HTTPException, http_exception_handler)
app.add_exception_handler(Exception, generic_exception_handler)

# Initialize Prometheus Instrumentator
instrumentator = Instrumentator()
instrumentator.instrument(app).expose(app)

# ------------------------------------------------------------------
# 1. Health Check Endpoint
# ------------------------------------------------------------------

@app.get("/health", status_code=200)
def health_check():
    return {"status": "healthy"}

# ------------------------------------------------------------------
# 2. Sequence Number Generation Endpoint
# ------------------------------------------------------------------

@app.post(
    "/sequence",
    summary="Generate Sequence Number",
    description="Generates the next sequence number for a specified element type and ID.",
    tags=["Sequence Management"],
    response_model=SequenceResponse,
    status_code=201
)
def generate_sequence_number(
    request: SequenceRequest,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    try:
        max_seq = (
            db.query(Element)
            .filter(Element.element_type == request.elementType)
            .order_by(Element.sequence_number.desc())
            .first()
        )
        next_seq = max_seq.sequence_number + 1 if max_seq else 1

        new_element = Element(
            element_type=request.elementType.value,
            element_id=request.elementId,
            sequence_number=next_seq,
            version_number=1,
            comment=request.comment,
        )
        db.add(new_element)
        db.commit()
        db.refresh(new_element)

        sync_payload = {
            "operation": "create",
            "document": {
                "id": f"{new_element.element_id}_{new_element.version_number}",
                "element_type": new_element.element_type,
                "element_id": new_element.element_id,
                "sequence_number": new_element.sequence_number,
                "version_number": new_element.version_number,
                "comment": new_element.comment or "",
                "service_name": settings.SERVICE_NAME,
            },
        }

        sync_service.sync_document(sync_payload)

        return SequenceResponse(
            sequenceNumber=new_element.sequence_number,
            comment=request.comment,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ------------------------------------------------------------------
# 3. Reorder Elements Endpoint
# ------------------------------------------------------------------

@app.post(
    "/sequence/reorder",
    summary="Reorder Elements",
    description="Reorders elements based on the provided new order.",
    tags=["Sequence Management"],
    response_model=ReorderResponse,
    status_code=200
)
def reorder_elements(
    request: ReorderRequest,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    try:
        elements = db.query(Element).filter(Element.element_id.in_(request.elementIds)).all()
        if len(elements) != len(request.elementIds):
            raise HTTPException(status_code=404, detail="Some elements not found.")

        element_map = {element.element_id: element for element in elements}
        reordered_elements = []

        for new_seq, element_id in enumerate(request.newOrder, start=1):
            element = element_map.get(element_id)
            if element.sequence_number != new_seq:
                old_seq = element.sequence_number
                element.sequence_number = new_seq
                db.commit()
                db.refresh(element)

                sync_payload = {
                    "operation": "update",
                    "document": {
                        "id": f"{element.element_id}_{element.version_number}",
                        "element_type": element.element_type,
                        "element_id": element.element_id,
                        "sequence_number": element.sequence_number,
                        "version_number": element.version_number,
                        "comment": element.comment or "",
                        "service_name": settings.SERVICE_NAME,
                    },
                }

                sync_service.sync_document(sync_payload)

                reordered_elements.append(
                    ReorderResponseElement(
                        elementId=element.element_id,
                        oldSequenceNumber=old_seq,
                        newSequenceNumber=new_seq,
                    )
                )

        return ReorderResponse(
            reorderedElements=reordered_elements,
            comment="Elements reordered successfully.",
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ------------------------------------------------------------------
# 4. Create New Version Endpoint
# ------------------------------------------------------------------

@app.post(
    "/sequence/version",
    summary="Create New Version",
    description="Creates a new version of an element.",
    tags=["Version Management"],
    response_model=VersionResponse,
    status_code=201
)
def create_new_version(
    request: VersionRequest,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    try:
        max_ver = db.query(Element).filter(
            Element.element_type == request.elementType,
            Element.element_id == request.elementId,
        ).order_by(Element.version_number.desc()).first()

        new_ver_num = max_ver.version_number + 1 if max_ver else 1

        new_element = Element(
            element_type=request.elementType.value,
            element_id=request.elementId,
            sequence_number=max_ver.sequence_number if max_ver else 1,
            version_number=new_ver_num,
            comment=request.comment,
        )
        db.add(new_element)
        db.commit()
        db.refresh(new_element)

        sync_payload = {
            "operation": "create",
            "document": {
                "id": f"{new_element.element_id}_{new_element.version_number}",
                "element_type": new_element.element_type,
                "element_id": new_element.element_id,
                "sequence_number": new_element.sequence_number,
                "version_number": new_element.version_number,
                "comment": new_element.comment or "",
                "service_name": settings.SERVICE_NAME,
            },
        }

        sync_service.sync_document(sync_payload)

        return VersionResponse(
            versionNumber=new_element.version_number,
            comment=request.comment,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

---
#### xi. Dockerfile

**File: `Dockerfile`**

```dockerfile
# Dockerfile

FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY ./app /app/app

# Expose port
EXPOSE 8000

# Run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

The next section in this context would be **e. Caddy Configuration**.

#### e. Caddy Configuration

**File: `Caddyfile`**

```caddy
yourdomain.com {
    reverse_proxy api_gateway:8002
    tls /path/to/fullchain.pem /path/to/privkey.pem
}

key_management_service.yourdomain.com {
    reverse_proxy key_management_service:8003
    tls /path/to/fullchain.pem /path/to/privkey.pem
}

typesense_client_service.yourdomain.com {
    reverse_proxy typesense_client_service:8001
    tls /path/to/fullchain.pem /path/to/privkey.pem
}

service_a.yourdomain.com {
    reverse_proxy service_a:8000
    tls /path/to/fullchain.pem /path/to/privkey.pem
}

# Add other subdomains as needed
```

---

**Explanation**:  
- **Subdomains**: Routes different subdomains to their respective services.
- **TLS**: Configures TLS certificates for secure HTTPS connections. Replace `/path/to/fullchain.pem` and `/path/to/privkey.pem` with actual certificate paths or configure Caddy for automatic certificate management.

**Security Note**: Ensure Caddy is configured to handle TLS securely, possibly leveraging Caddy’s automatic HTTPS features.

---

#### f. Docker Compose Setup

**File: `docker-compose.yml`**

```yaml
version: '3.8'

services:
  caddy:
    image: caddy:latest
    container_name: caddy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
      - ./certs:/path/to/certs  # Update with actual paths if using manual TLS
    networks:
      - app-network
    depends_on:
      - api_gateway
      - key_management_service
      - typesense_client_service
      - service_a
    secrets:
      - caddy_api_key

  key_management_service:
    build:
      context: ./key_management_service
    container_name: key_management_service
    ports:
      - "8003:8003"
    environment:
      - DATABASE_URL=sqlite:///./keys.db
      - SECRET_KEY=your_super_secret_key  # Should be managed via secrets
      - ALGORITHM=HS256
      - ACCESS_TOKEN_EXPIRE_MINUTES=60
    depends_on:
      - typesense_client_service
    networks:
      - app-network
    secrets:
      - key_management_secret_key
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8003/health"]
      interval: 30s
      timeout: 10s
      retries: 5

  api_gateway:
    build:
      context: ./api_gateway
    container_name: api_gateway
    ports:
      - "8002:8002"
    environment:
      - TYPESENSE_CLIENT_URL=http://typesense_client_service:8001
      - KEY_MANAGEMENT_URL=http://key_management_service:8003
      - SERVICE_NAME=api_gateway
      - ADMIN_TOKEN=your_admin_jwt_token  # Should be managed via secrets
    depends_on:
      - typesense_client_service
      - key_management_service
      - service_a
    networks:
      - app-network
    secrets:
      - key_management_secret_key
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8002/health"]
      interval: 30s
      timeout: 10s
      retries: 5

  typesense:
    image: typesense/typesense:latest
    container_name: typesense
    ports:
      - "8108:8108"
    environment:
      - TYPESENSE_API_KEY=z9y8x7w6v5u4t3s2r1q0p9o8n7m6l5k4j3i2h1g0f9e8d7c6b5a4z3y2x1w0v9u8
      - TYPESENSE_ENABLE_CORS=true
    volumes:
      - typesense_data:/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8108/health"]
      interval: 30s
      timeout: 10s
      retries: 5

  typesense_client_service:
    build:
      context: ./typesense_client_service
    container_name: typesense_client_service
    ports:
      - "8001:8001"
    environment:
      - TYPESENSE_HOST=typesense
      - TYPESENSE_PORT=8108
      - TYPESENSE_PROTOCOL=http
      - TYPESENSE_API_KEY=z9y8x7w6v5u4t3s2r1q0p9o8n7m6l5k4j3i2h1g0f9e8d7c6b5a4z3y2x1w0v9u8
      - TYPESENSE_COLLECTION_NAME=elements
      - TYPESENSE_SERVICE_API_KEY=your_secure_typesense_service_api_key  # From KMS
      - KEY_MANAGEMENT_URL=http://key_management_service:8003
      - SERVICE_NAME=typesense_client_service
      - ADMIN_TOKEN=your_admin_jwt_token  # Should be managed via secrets
    depends_on:
      typesense:
        condition: service_healthy
      key_management_service:
        condition: service_healthy
    networks:
      - app-network
    secrets:
      - key_management_secret_key
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8001/health"]
      interval: 30s
      timeout: 10s
      retries: 5

  service_a:
    build:
      context: ./service_a
    container_name: service_a
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=sqlite:///./database.db
      - TYPESENSE_CLIENT_URL=http://typesense_client_service:8001
      - TYPESENSE_SERVICE_API_KEY=your_secure_typesense_service_api_key  # From KMS
      - KEY_MANAGEMENT_URL=http://key_management_service:8003
      - SERVICE_NAME=service_a
      - ADMIN_TOKEN=your_admin_jwt_token  # Should be managed via secrets
    depends_on:
      - typesense_client_service
      - key_management_service
    networks:
      - app-network
    volumes:
      - service_a_data:/app/database.db
    secrets:
      - key_management_secret_key
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 5

secrets:
  caddy_api_key:
    external: true
  key_management_secret_key:
    external: true  # Secret for KMS's SECRET_KEY and ADMIN_TOKEN

volumes:
  caddy_data:
  caddy_config:
  typesense_data:
  service_a_data:

networks:
  app-network:
    driver: bridge
```

---

**Explanation**:
- **Services**:
  - `caddy`: Reverse proxy handling TLS termination and routing.
  - `key_management_service`: Centralized Key Management Service.
  - `api_gateway`: Central API entry point with JWT authentication.
  - `typesense`: Typesense search engine.
  - `typesense_client_service`: Handles synchronization with Typesense.
  - `service_a`: Example backend service managing elements.
- **Secrets**:
  - `key_management_secret_key`: Stores sensitive data like `SECRET_KEY` and `ADMIN_TOKEN`.
- **Volumes**: Persist data for Caddy, Typesense, and Service A.
- **Networks**: All services communicate over the `app-network`.
- **Healthchecks**: Ensure services are healthy before dependent services start.

### 5. Security Best Practices

Ensuring the security of your FastAPI ecosystem is paramount. Adhere to the following best practices:

---

#### a. **Centralized Key Management**
- **KMS Centralization**: Manage all API keys and secrets through the Key Management Service (KMS) to reduce the risk of key leakage.
- **Least Privilege**: Assign minimal permissions to each API key, ensuring services can only perform necessary operations.
- **Automated Rotation**: Implement automated API key rotation policies to enhance security.

---

#### b. **JWT Security**
- **Strong Secret Keys**: Use long, random, and complex secret keys for signing JWTs.
- **Token Expiration**: Set reasonable expiration times (`exp`) to limit the window of token misuse.
- **Audience and Issuer Claims**: Define and validate `aud` (audience) and `iss` (issuer) claims to prevent token misuse.
- **HTTPS Enforcement**: Always transmit JWTs over HTTPS to protect against interception.
- **Token Revocation**: Implement strategies like token blacklisting or short-lived tokens with refresh tokens to handle token revocation.

---

#### c. **Secure Communication**
- **TLS Everywhere**: Encrypt all inter-service communications using TLS, managed by Caddy.
- **Firewall Rules**: Restrict access to services only from trusted sources and networks.
- **Network Isolation**: Use Docker networks to isolate services and prevent unauthorized access.

---

#### d. **Secret Management**
- **Avoid Hardcoding**: Never hardcode API keys or secrets in code repositories.
- **Secure Storage**: Use Docker Secrets or dedicated secret management tools like HashiCorp Vault or AWS Secrets Manager.

---

#### e. **Audit and Monitoring**
- **Logging**: Maintain detailed logs of all key management operations, including creation, rotation, and revocation.
- **Monitoring**: Continuously monitor the ecosystem for suspicious activities or unauthorized access attempts.
- **Alerts**: Set up alerts for critical events, such as multiple failed authentication attempts or unauthorized access.

---

#### f. **Regular Audits and Reviews**
- **Periodic Reviews**: Regularly audit API keys and their usage to ensure compliance with security policies.
- **Vulnerability Assessments**: Conduct regular security assessments to identify and mitigate potential vulnerabilities.

---
### 6. Logging and Monitoring

Effective logging and monitoring are critical for maintaining the health, performance, and security of your services.

---

#### a. **Centralized Logging**
- **Aggregate Logs**: Use tools like ELK Stack (Elasticsearch, Logstash, Kibana), Grafana Loki, or Graylog to centralize and manage logs.
- **Structured Logging**: Ensure logs are in a consistent, structured format (e.g., JSON) to facilitate parsing and analysis.
- **Log Aggregation**: Centralize logs from all services to enable comprehensive analysis and troubleshooting.

---

#### b. **Metrics Collection**
- **Prometheus for Metrics**: Collect metrics using Prometheus, and visualize them in Grafana for system insights.

**Implementation Steps**:
1. **Integrate Prometheus with FastAPI**:
   - Install Prometheus instrumentation in FastAPI applications:
     ```bash
     pip install prometheus-fastapi-instrumentator
     ```
   - Add the following to your FastAPI apps:
     ```python
     from prometheus_fastapi_instrumentator import Instrumentator

     # Initialize Prometheus Instrumentator
     instrumentator = Instrumentator()
     instrumentator.instrument(app).expose(app)
     ```

2. **Add Prometheus and Grafana to `docker-compose.yml`**:
   Update your `docker-compose.yml` file:
   ```yaml
   prometheus:
     image: prom/prometheus:latest
     container_name: prometheus
     volumes:
       - ./prometheus.yml:/etc/prometheus/prometheus.yml
     ports:
       - "9090:9090"
     networks:
       - app-network

   grafana:
     image: grafana/grafana:latest
     container_name: grafana
     ports:
       - "3000:3000"
     networks:
       - app-network
     depends_on:
       - prometheus
   ```

3. **Prometheus Configuration**:
   Create `prometheus.yml`:
   ```yaml
   global:
     scrape_interval: 15s

   scrape_configs:
     - job_name: 'api_gateway'
       static_configs:
         - targets: ['api_gateway:8002']
     - job_name: 'service_a'
       static_configs:
         - targets: ['service_a:8000']
     - job_name: 'typesense_client_service'
       static_configs:
         - targets: ['typesense_client_service:8001']
     - job_name: 'key_management_service'
       static_configs:
         - targets: ['key_management_service:8003']
     - job_name: 'typesense'
       static_configs:
         - targets: ['typesense:8108']
   ```

---

#### c. **Alerting**
Set up alerts in Prometheus or Grafana for critical system issues.

**Example Alert in Prometheus**:
```yaml
groups:
- name: api_gateway_alerts
  rules:
  - alert: HighErrorRate
    expr: rate(http_requests_total{status_code=~"5.."}[5m]) > 0.05
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High error rate detected in API Gateway"
      description: "More than 5% of requests to API Gateway are failing."
```

**Key Alerts**:
- **High Error Rates**: Monitor for a sudden spike in `5xx` errors.
- **Latency Spikes**: Detect increased response times.
- **Service Downtimes**: Monitor failed health checks or unresponsive services.

---

### 7. Testing the Ecosystem

Ensuring that all components interact correctly and securely is vital. Implement **Unit Tests**, **Integration Tests**, and perform **Manual Testing** as needed.

---

#### a. **Unit Tests**
Test individual components to ensure they function as expected in isolation.

**Example with `pytest`**:

```python
# service_a/tests/test_sync.py

from fastapi.testclient import TestClient
from service_a.app.main import app
import pytest
from unittest.mock import patch

client = TestClient(app)

def test_generate_sequence_number_success():
    with patch('service_a.app.services.sync_service.SyncService.sync_document') as mock_sync:
        mock_sync.return_value = None

        response = client.post(
            "/sequence",
            headers={"Authorization": "Bearer valid_jwt_token"},
            json={
                "elementType": "script",
                "elementId": 1,
                "comment": "Test sequence generation."
            }
        )
        assert response.status_code == 201
        assert response.json()["sequenceNumber"] == 1
        assert "Test sequence generation." in response.json()["comment"]
```

**Explanation**:
- **Mocking**: Uses `unittest.mock.patch` to mock the synchronization with the Typesense Client Microservice.
- **Assertions**: Validates that the sequence number is generated correctly and the response contains the expected data.

---

#### b. **Integration Tests**
Test interactions between multiple services to ensure seamless communication and functionality.

**Steps**:
1. **Start All Services**:
   ```bash
   docker-compose up -d
   ```

2. **Register a User and Obtain JWT**:
   ```bash
   curl -X POST "https://key_management_service.yourdomain.com/register" \
       -H "Content-Type: application/json" \
       -d '{
             "username": "admin",
             "password": "securepassword",
             "roles": "admin"
           }'

   curl -X POST "https://key_management_service.yourdomain.com/login" \
       -H "Content-Type: application/json" \
       -d '{
             "username": "admin",
             "password": "securepassword"
           }'
   ```

3. **Create API Key for Service A via KMS**:
   ```bash
   curl -X POST "https://key_management_service.yourdomain.com/keys" \
       -H "Authorization: Bearer your_admin_jwt_token" \
       -H "Content-Type: application/json" \
       -d '{
             "service_name": "service_a",
             "api_key": "new_service_api_key_456"
           }'
   ```

4. **Perform Operations via API Gateway**:
   - **Generate Sequence Number**:
     ```bash
     curl -X POST "https://api_gateway.yourdomain.com/service_a/sequence" \
         -H "Content-Type: application/json" \
         -H "Authorization: Bearer client_jwt_token" \
         -d '{
               "elementType": "script",
               "elementId": 1,
               "comment": "Test sequence generation."
             }'
     ```
   - **Perform a Search**:
     ```bash
     curl -X POST "https://api_gateway.yourdomain.com/search" \
         -H "Content-Type: application/json" \
         -H "Authorization: Bearer client_jwt_token" \
         -d '{
               "q": "script",
               "query_by": "element_type",
               "filter_by": null,
               "sort_by": "sequence_number:asc",
               "max_hits": 10
             }'
     ```

**Explanation**:
- **End-to-End Workflow**: Ensures authentication, API key management, request routing, and synchronization with Typesense work as expected.
- **Response Verification**: Check responses to confirm accurate reflection of operations across services.

---

#### c. **Manual Testing**
Use tools like **Postman** or **cURL** for exploratory testing of API endpoints.

**Example**:
- **Create a New API Key via KMS**:
  ```bash
  curl -X POST "https://key_management_service.yourdomain.com/keys" \
       -H "Authorization: Bearer your_admin_jwt_token" \
       -H "Content-Type: application/json" \
       -d '{
             "service_name": "api_gateway",
             "api_key": "api_gateway_api_key_789"
           }'
  ```

- **Use the API Key in API Gateway**:
  ```bash
  curl -X POST "https://api_gateway.yourdomain.com/service_a/sequence" \
       -H "Content-Type: application/json" \
       -H "X-API-KEY: api_gateway_api_key_789" \
       -H "Authorization: Bearer client_jwt_token" \
       -d '{
             "elementType": "script",
             "elementId": 2,
             "comment": "Another test sequence generation."
           }'
  ```

**Explanation**:
- **API Key Usage**: Demonstrates utilizing API keys managed by the KMS.
- **JWT Authentication**: Ensures requests include valid JWTs for authentication and authorization.

---
### 8. Conclusion

By following this **Unified Comprehensive Guide**, you’ve established a secure, scalable, and maintainable FastAPI ecosystem with centralized key management and JWT-based authentication. This architecture ensures:

---

#### Key Outcomes:
1. **Enhanced Security**: 
   - Centralized control over API keys minimizes the risk of leakage and misuse.
   - Robust JWT-based authentication and authorization secure inter-service communication.

2. **Simplified Maintenance**:
   - A Key Management Service (KMS) centralizes API key lifecycle management.
   - Automated service orchestration using Docker Compose reduces manual setup and deployment complexity.

3. **Scalability**:
   - Easily onboard new services following the established patterns with minimal configuration changes.

4. **Improved Auditability**:
   - Detailed logging and monitoring enable better tracking of system operations and quick issue resolution.

---

#### Key Takeaways:
- **Centralization**: A dedicated KMS improves security by centralizing API key management.
- **JWT Authentication**: Implements robust mechanisms to authenticate and authorize requests.
- **Secure Communication**: TLS encryption ensures secure communication across all services.
- **Monitoring & Logging**: Centralized logging and monitoring provide valuable insights into system health and performance.
- **Efficient Deployment**: Docker Compose simplifies the deployment and networking of multi-container services.

---

#### Next Steps:
1. **Implement Additional Services**:
   - Add more backend services following the patterns outlined in this guide.
   - Ensure secure interaction with the API Gateway and KMS.

2. **Enhance Security Measures**:
   - Introduce Multi-Factor Authentication (MFA) for administrative users.
   - Implement token blacklisting or short-lived tokens with refresh tokens for better JWT security.

3. **Optimize Typesense Configuration**:
   - Refine indexing strategies and search configurations in Typesense to suit your specific application requirements.

4. **Automate Key Rotation**:
   - Integrate policies to automate API key rotation to enhance security while minimizing manual interventions.

5. **Expand Monitoring and Alerting**:
   - Create detailed Grafana dashboards.
   - Set up comprehensive alerting rules to monitor system health and security.

6. **Integrate CI/CD Pipelines**:
   - Automate testing, building, and deploying services to ensure consistent and reliable releases.

7. **Documentation and Training**:
   - Maintain detailed documentation for team onboarding.
   - Train your team to manage and interact with the FastAPI ecosystem effectively.

---

By adhering to these practices and continuously refining your architecture to meet evolving requirements, you are poised to build a robust and high-performance system, capable of handling complex, scalable applications.


---
---
# Appendix 

> Here’s the structure recap of this Markdown document:

---

### **Unified Comprehensive Guide: Building a Secure FastAPI Ecosystem with Centralized Key Management and JWT Authentication**

---

#### **Table of Contents**
1. [Introduction](#1-introduction)  
2. [Architecture Overview](#2-architecture-overview)  
3. [Project Structure](#3-project-structure)  
4. [Implementation Steps](#4-implementation-steps)  
   - [a. Key Management Service (KMS)](#a-key-management-service-kms)  
   - [b. API Gateway with JWT Authentication](#b-api-gateway-with-jwt-authentication)  
   - [c. Typesense Client Microservice](#c-typesense-client-microservice)  
   - [d. Service A](#d-service-a)  
   - [e. Caddy Configuration](#e-caddy-configuration)  
   - [f. Docker Compose Setup](#f-docker-compose-setup)  
5. [Security Best Practices](#5-security-best-practices)  
6. [Logging and Monitoring](#6-logging-and-monitoring)  
7. [Testing the Ecosystem](#7-testing-the-ecosystem)  
8. [Conclusion](#8-conclusion)  

---

### **1. Introduction**
- Overview of managing API keys and JWT-based authentication.

---

### **2. Architecture Overview**
- Description of key components:
  - Key Management Service (KMS)
  - API Gateway
  - Typesense Client Microservice
  - Example backend service (Service A)
  - Caddy for reverse proxy
  - Docker Compose for orchestration.

---

### **3. Project Structure**
- A modular structure for organizing services:
  - **api_gateway/**
  - **key_management_service/**
  - **typesense_client_service/**
  - **service_a/**
  - Docker Compose and Caddy configurations.

---

### **4. Implementation Steps**
- Detailed steps for each component:
  - **a. Key Management Service (KMS)**:
    - Setup, configuration, and JWT implementation.
  - **b. API Gateway**:
    - JWT-based routing and proxying.
  - **c. Typesense Client Microservice**:
    - Synchronization and search capabilities.
  - **d. Service A**:
    - Example backend service with sequence/version management.
  - **e. Caddy Configuration**:
    - Reverse proxy and TLS setup.
  - **f. Docker Compose Setup**:
    - Orchestration of all services.

---

### **5. Security Best Practices**
- Key security practices:
  - Centralized API key management.
  - JWT token security.
  - TLS encryption and network isolation.
  - Secret management and regular audits.

---

### **6. Logging and Monitoring**
- Centralized logging setup.
- Prometheus and Grafana for metrics collection and visualization.
- Example alert rules for system monitoring.

---

### **7. Testing the Ecosystem**
- Types of testing:
  - **Unit Testing** with `pytest`.
  - **Integration Testing** with cURL and service interactions.
  - **Manual Testing** with Postman or cURL.

---

### **8. Conclusion**
- Summary of outcomes:
  - Enhanced security, scalability, and auditability.
  - Simplified maintenance with centralized key management.
- Next steps for improvement:
  - Add more services.
  - Enhance security measures.
  - Integrate CI/CD and expand monitoring.

---



