Below is a **comprehensive** documentation of the **FountainAI Two-Factor Authentication (2FA) Service** as a standalone **FastAPI** microservice, reflecting **OpenAPI 3.1.0** compliance and incorporating every detailed feature discussed in this thread. This documentation is intended to serve as a single reference covering:

- Complete project structure
- Core design choices (decoupled architecture, “to whom it may concern” usage)
- Integration with other FountainAI services (e.g., Key Management Service, KMS)
- Environment variable configurations
- OTP generation and verification
- Delivery mechanisms (email, SMS)
- Logging, models, and schemas
- Dockerization
- End-to-end usage flow
- Implementation of **OpenAPI 3.1.0** overrides in FastAPI

---

# **FountainAI Two-Factor Authentication (2FA) Service**

## **1. Overview**

The **FountainAI 2FA Service** provides a secure, time-based One-Time Password (TOTP) authentication mechanism to enhance user security. It operates **on a “to whom it may concern” basis**, allowing any FountainAI service (e.g., KMS, Character Management Service, or other microservices) to request 2FA verification without tight coupling to this service’s internal logic. 

### **Key Benefits & Goals**
1. **Regulatory Compliance**: Helps satisfy GDPR and other data protection standards by adding a layer of user identity verification.
2. **Decoupled Architecture**: The 2FA Service exposes endpoints for OTP generation (`/generate`) and verification (`/verify`), enabling **independent** adoption across multiple services.
3. **Flexible Delivery**: OTPs can be sent to users via **email** or **SMS**, defined by user preference.
4. **Shared Security**: Relies on a **SECRET_KEY** (preferably managed in a secrets manager) shared across the FountainAI ecosystem to ensure JWT and OTP integrity.

---

## **2. Directory Structure**

Below is a recommended directory layout for the **2FA Service**. Adjust the structure as needed for your environment:

```
2fa_service/
├── app/
│   ├── __init__.py
│   ├── main.py               # FastAPI entry point + custom OpenAPI override (3.1.0)
│   ├── config.py             # Pydantic settings for environment vars
│   ├── database.py           # SQLAlchemy engine/session initialization
│   ├── models.py             # SQLAlchemy models for User and OTPLog
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── otp.py            # OTP-related Pydantic schemas
│   │   └── user.py           # User-related Pydantic schemas (optional)
│   ├── services/
│   │   ├── __init__.py
│   │   ├── otp_service.py    # Core OTP generation & verification logic
│   │   ├── delivery_service.py
│   │   └── user_service.py   # Optional: user registration/management logic
│   ├── dependencies.py       # Shared FastAPI dependencies (e.g., get_db)
│   ├── exceptions.py         # Custom exceptions
│   ├── logging_config.py     # Logging configuration
│   └── routes/
│       ├── __init__.py
│       └── auth.py           # Primary auth routes (/generate, /verify)
├── Dockerfile
├── requirements.txt
├── .env
└── README.md
```

---

## **3. FastAPI Application with OpenAPI 3.1.0**

**File: `app/main.py`**

```python
from fastapi import FastAPI
from fastapi.openapi.models import OpenAPI
from .routes.auth import router as auth_router

##############################################################################
# Custom OpenAPI override to use OpenAPI 3.1.0 instead of the default 3.0.2
##############################################################################
def custom_openapi():
    """
    Overriding FastAPI's default openapi() generator to produce an
    OpenAPI 3.1.0-compliant schema. This ensures up-to-date JSON Schema
    support and better alignment with modern API specifications.
    """
    if app.openapi_schema:
        return app.openapi_schema

    # Generate the base schema once
    openapi_schema = app.openapi()

    # Override the version number
    openapi_schema["openapi"] = "3.1.0"

    # Custom metadata
    openapi_schema["info"] = {
        "title": "FountainAI 2FA Service",
        "version": "1.0.0",
        "description": (
            "A standalone microservice providing two-factor authentication (2FA) "
            "to enhance security in the FountainAI ecosystem. "
            "Supports time-based OTP generation, delivery, and verification."
        ),
    }

    app.openapi_schema = openapi_schema
    return app.openapi_schema

##############################################################################
# Initialize the FastAPI app
##############################################################################
app = FastAPI()
app.openapi = custom_openapi  # Attach our custom openAPI function

# Include our authentication routes under `/auth`
app.include_router(auth_router, prefix="/auth", tags=["2FA Authentication"])

@app.get("/", tags=["Health Check"])
def health_check():
    """
    Basic health-check endpoint to confirm the 2FA Service is running.
    """
    return {"status": "2FA Service is up and running!"}
```

### **Explanation**

1. **`custom_openapi()`**: We fetch the FastAPI-generated schema, override the `"openapi"` field from **3.0.2** to **3.1.0**, and add a custom description.  
2. **`app.openapi = custom_openapi`**: Assign the function to `app.openapi`, instructing FastAPI to use our custom generator.  
3. **`@app.get("/")`**: A quick health check endpoint to confirm the service availability.

---

## **4. Configuration**

**File: `app/config.py`**

```python
import os
from pydantic import BaseSettings

class Settings(BaseSettings):
    ##################################################
    # Base Settings
    ##################################################
    DATABASE_URL: str = "sqlite:///./2fa.db"
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your_super_secret_key")
    ALGORITHM: str = "HS256"
    OTP_EXPIRATION_MINUTES: int = 5

    ##################################################
    # Email Delivery Settings
    ##################################################
    SMTP_SERVER: str = os.getenv("SMTP_SERVER", "smtp.example.com")
    SMTP_PORT: int = int(os.getenv("SMTP_PORT", 587))
    SMTP_USERNAME: str = os.getenv("SMTP_USERNAME", "your_username")
    SMTP_PASSWORD: str = os.getenv("SMTP_PASSWORD", "your_password")
    SMTP_FROM_EMAIL: str = os.getenv("SMTP_FROM_EMAIL", "no-reply@example.com")

    ##################################################
    # SMS Delivery Settings (Twilio Example)
    ##################################################
    TWILIO_ACCOUNT_SID: str = os.getenv("TWILIO_ACCOUNT_SID", "your_account_sid")
    TWILIO_AUTH_TOKEN: str = os.getenv("TWILIO_AUTH_TOKEN", "your_auth_token")
    TWILIO_PHONE_NUMBER: str = os.getenv("TWILIO_PHONE_NUMBER", "+1234567890")

    class Config:
        env_file = ".env"

settings = Settings()
```

### **How to Use**
1. **`.env` File**: Store all sensitive configuration (e.g., `SECRET_KEY`, Twilio credentials).  
2. **Secret Management**: For production, consider using a secrets manager (e.g., AWS Secrets Manager, Vault).

---

## **5. Database Initialization**

**File: `app/database.py`**

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from .config import settings

engine = create_engine(settings.DATABASE_URL, connect_args={"check_same_thread": False} if "sqlite" in settings.DATABASE_URL else {})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def init_db():
    """
    Creates all database tables if they don't exist.
    Useful in a startup script or migrations context.
    """
    Base.metadata.create_all(bind=engine)
```

### **Usage**
- **SQLite** in local development: Simple to set up.  
- **Production**: Switch `DATABASE_URL` to Postgres or MySQL for reliability.  
- **`init_db()`**: Called upon deployment or container startup.

---

## **6. Models**

**File: `app/models.py`**

```python
from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.sql import func
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, nullable=False)
    email = Column(String, unique=True, nullable=True)
    phone_number = Column(String, nullable=True)
    delivery_method = Column(String, default="email")
    otp_secret = Column(String, nullable=True)
    otp_enabled = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class OTPLog(Base):
    __tablename__ = "otp_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    otp_code = Column(String, nullable=False)
    expires_at = Column(DateTime, nullable=False)
    verified = Column(Boolean, default=False)
```

### **Explanation**
1. **`User`**: Tracks each user, including `otp_secret` (for TOTP generation), `delivery_method`, and `otp_enabled`.  
2. **`OTPLog`**: Stores generated OTPs. Fields `expires_at` and `verified` prevent OTP reuse and handle expiration.

---

## **7. Dependencies**

**File: `app/dependencies.py`**

```python
from .database import SessionLocal
from typing import Generator

def get_db() -> Generator:
    """
    Dependency that provides a SQLAlchemy session for each request.
    Ensures session cleanup after request completes.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

---

## **8. Exceptions**

**File: `app/exceptions.py`**

```python
from fastapi import HTTPException as FastAPIHTTPException

class HTTPException(FastAPIHTTPException):
    """
    Custom wrapper around FastAPI's HTTPException.
    Can add extended logging or error formatting here if needed.
    """
    pass
```

---

## **9. Logging Configuration** (Optional)

**File: `app/logging_config.py`**

```python
import logging
import sys

logging.basicConfig(
    stream=sys.stdout,
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s - %(message)s",
)

logger = logging.getLogger("2FA-Service")
```

---

## **10. Schemas**

Below are minimal schema definitions for OTP operations. Expand as needed for user management (create/update user, etc.).

**File: `app/schemas/otp.py`**
```python
from pydantic import BaseModel
from datetime import datetime

class OTPGenerateResponse(BaseModel):
    otp_code: str
    expires_at: datetime

class OTPVerifyRequest(BaseModel):
    username: str
    otp_code: str

class OTPVerifyResponse(BaseModel):
    success: bool
```

---

## **11. Services**

### **11.1 Delivery Service**

**File: `app/services/delivery_service.py`**

```python
import smtplib
from twilio.rest import Client
from ..config import settings

class DeliveryService:
    """
    Handles delivery of OTP codes via email or SMS.
    Additional methods (e.g., push notifications) can be added as needed.
    """

    def send_email(self, recipient_email: str, subject: str, message: str):
        """
        Sends an email containing the OTP code.
        SMTP server credentials are loaded from environment variables.
        """
        with smtplib.SMTP(settings.SMTP_SERVER, settings.SMTP_PORT) as server:
            server.login(settings.SMTP_USERNAME, settings.SMTP_PASSWORD)
            content = f"Subject: {subject}\n\n{message}"
            server.sendmail(settings.SMTP_FROM_EMAIL, recipient_email, content)

    def send_sms(self, phone_number: str, message: str):
        """
        Sends an SMS text containing the OTP code.
        Uses Twilio's REST API.
        """
        client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
        client.messages.create(
            to=phone_number,
            from_=settings.TWILIO_PHONE_NUMBER,
            body=message,
        )
```

### **11.2 OTP Service**

**File: `app/services/otp_service.py`**

```python
import pyotp
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from ..models import User, OTPLog
from ..config import settings
from ..exceptions import HTTPException
from .delivery_service import DeliveryService

class OTPService:
    """
    Responsible for generating and verifying OTPs, logging their usage,
    and dispatching them via the DeliveryService.
    """

    def __init__(self):
        self.delivery_service = DeliveryService()

    def generate_otp(self, username: str, db: Session):
        """
        1. Retrieves the user from DB, checks if 2FA is enabled & secret is present.
        2. Generates a time-based OTP (TOTP) using pyotp.
        3. Logs OTP in the DB (OTPLog).
        4. Sends the OTP to the user via email or SMS.
        """
        user = db.query(User).filter(User.username == username).first()
        if not user or not user.otp_enabled:
            raise HTTPException(status_code=404, detail="User not found or 2FA not enabled.")

        if not user.otp_secret:
            raise HTTPException(status_code=400, detail="OTP secret not configured.")

        totp = pyotp.TOTP(user.otp_secret)
        otp_code = totp.now()
        expires_at = datetime.utcnow() + timedelta(minutes=settings.OTP_EXPIRATION_MINUTES)

        otp_log = OTPLog(
            user_id=user.id,
            otp_code=otp_code,
            expires_at=expires_at,
            verified=False
        )
        db.add(otp_log)
        db.commit()
        db.refresh(otp_log)

        # Send the code
        message = f"Your FountainAI OTP: {otp_code}\nIt expires at: {expires_at} (UTC)."
        if user.delivery_method == "email" and user.email:
            self.delivery_service.send_email(user.email, "Your FountainAI OTP", message)
        elif user.delivery_method == "sms" and user.phone_number:
            self.delivery_service.send_sms(user.phone_number, message)
        else:
            raise HTTPException(status_code=400, detail="No valid delivery method configured.")

        return otp_log

    def verify_otp(self, username: str, otp_code: str, db: Session):
        """
        1. Validates user existence and TOTP code correctness.
        2. Ensures that the OTP has not yet been used (OTPLog.verified == False).
        3. Marks the OTP as verified to prevent reuse.
        """
        user = db.query(User).filter(User.username == username).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found.")

        totp = pyotp.TOTP(user.otp_secret)
        if not totp.verify(otp_code):
            raise HTTPException(status_code=401, detail="Invalid OTP or expired.")

        otp_log = db.query(OTPLog).filter(
            OTPLog.user_id == user.id,
            OTPLog.otp_code == otp_code
        ).first()

        if not otp_log or otp_log.verified:
            raise HTTPException(status_code=400, detail="OTP already used or no matching record.")

        otp_log.verified = True
        db.commit()

        return True
```

**Implementation Details**:
- **`pyotp.TOTP`**: Generates time-based OTP codes (commonly 6 digits).  
- **`expires_at`**: Additional guard so you can reject attempts past the configured `OTP_EXPIRATION_MINUTES`.  
- **`OTPLog.verified`**: Prevents OTP reuse (once used, it’s invalidated).

---

## **12. Routes**

### **File: `app/routes/auth.py`**

```python
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from ..dependencies import get_db
from ..services.otp_service import OTPService
from ..schemas.otp import OTPVerifyRequest, OTPVerifyResponse, OTPGenerateResponse

router = APIRouter()
otp_service = OTPService()

@router.post("/generate", response_model=OTPGenerateResponse, summary="Generate OTP for a User")
def generate_otp(username: str, db: Session = Depends(get_db)):
    """
    Generates and delivers a new OTP for the given user.
    The user must have 2FA enabled and a valid otp_secret.
    """
    try:
        otp_data = otp_service.generate_otp(username, db)
        return OTPGenerateResponse(
            otp_code=otp_data.otp_code,
            expires_at=otp_data.expires_at
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/verify", response_model=OTPVerifyResponse, summary="Verify a User's OTP")
def verify_otp(payload: OTPVerifyRequest, db: Session = Depends(get_db)):
    """
    Verifies a previously generated OTP for the given user.
    """
    try:
        success = otp_service.verify_otp(payload.username, payload.otp_code, db)
        return OTPVerifyResponse(success=success)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
```

**Usage**:
- **`POST /auth/generate`**: Provide `username`, get an OTP delivered + response including the raw code (optionally omit the code from the response in production).
- **`POST /auth/verify`**: Provide `username` and `otp_code`, check if valid.

---

## **13. Docker Configuration**

### **File: `Dockerfile`**

```dockerfile
FROM python:3.9-slim

WORKDIR /app

# Copy and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY ./app /app/app

# Expose relevant port (e.g., 8004)
EXPOSE 8004

# Run with Uvicorn
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8004"]
```

**Instructions**:
1. **Build**: `docker build -t fountainai-2fa .`
2. **Run**: `docker run -p 8004:8004 fountainai-2fa`
3. **Check**: Visit [http://localhost:8004/docs](http://localhost:8004/docs) to see **OpenAPI 3.1.0** docs.

---

## **14. Requirements**

### **File: `requirements.txt`**
```
fastapi
uvicorn
sqlalchemy
pyotp
python-dotenv
twilio
```

Adjust versions as appropriate (e.g., `fastapi==0.95.2`), ensuring your environment matches production needs.

---

## **15. README Outline**

A possible **`README.md`** might include:

- **Project Description**: Summarize the 2FA service and its purpose.
- **Prerequisites**: Docker, Python, environment variables.
- **Setup**:
  1. Clone the repo
  2. Create `.env`
  3. Build & run Docker image or run `uvicorn` directly
- **Endpoints**: Document the `/auth/generate` and `/auth/verify` usage with examples.
- **Integration Examples**:
  - **Key Management Service**: Shows how the KMS can call `/auth/verify` to validate a user’s OTP before revealing keys.
  - **Other Services**: Steps to embed 2FA checks in your service flows.

---

## **16. End-to-End Usage Flow**

Below is a typical **two-factor authentication** workflow with this service:

1. **User Registration** (handled by a different service or admin panel):
   1. Create a new `User` in the `users` table, assign a `username`.
   2. Generate a TOTP secret (`pyotp.random_base32()`) and store it in `User.otp_secret`.
   3. Mark `User.otp_enabled = True`.
   4. Set `delivery_method` (`"email"` or `"sms"`) and provide `email` or `phone_number`.

2. **2FA Generation**:
   1. A user attempts to access a protected resource.
   2. The calling service (e.g., KMS) sends an HTTP `POST /auth/generate?username={user}` to the 2FA Service.
   3. The 2FA Service:
      - Validates the user exists and 2FA is enabled.
      - Generates a TOTP using the user’s `otp_secret`.
      - Creates a record in `otp_logs`.
      - Delivers the OTP code via email or SMS.

3. **2FA Verification**:
   1. The user inputs the received OTP code.
   2. The calling service sends `POST /auth/verify` with `{"username": "theUser", "otp_code": "123456"}` to the 2FA Service.
   3. The 2FA Service checks:
      - Whether TOTP verification matches and the OTP has not expired.
      - Whether `OTPLog.verified` is still `False` (unused).
      - Marks the OTP as used (`verified = True`).
   4. On success, the 2FA Service returns `{"success": true}`, confirming a valid 2FA. The calling service may proceed with granting access.

4. **Audit & Logs**:
   - All OTP usage is logged in `otp_logs`. You can implement advanced auditing, e.g., track IPs, user agents, etc.

---

## **17. Security & Best Practices**

1. **Store `SECRET_KEY` Securely**: In production, do **not** store secrets in `.env` committed to source control. Use a secrets manager or environment variable injection.
2. **Encrypt `otp_secret`**: For compliance, consider encrypting sensitive columns (e.g., using AWS KMS or similar) to avoid plaintext TOTP secrets in the database.
3. **Use TLS/HTTPS**: Always run behind a secure HTTPS reverse proxy (e.g., Nginx) in production.
4. **Limit OTP Generation**: Implement rate limiting or throttling (e.g., one OTP request per minute) to prevent spam or brute-forcing.
5. **Enhanced Observability**: Integrate with a logging/monitoring stack (e.g., ELK, Grafana, Datadog) to track usage and detect anomalies (e.g., repeated failed verifications).

---

## **18. Conclusion**

This **FountainAI Two-Factor Authentication Service** is ready to be **deployed** and **integrated** into the FountainAI ecosystem:

- **OpenAPI 3.1.0** compliance ensures modern API standards and better JSON Schema validation.
- **Decoupled architecture** means any service in the FountainAI stack can independently use the `/generate` and `/verify` endpoints to enforce 2FA.
- **Email/SMS delivery** covers common out-of-the-box delivery mechanisms, with the possibility of adding new channels (push notifications, Slack, etc.).
- **Security considerations** address best practices for storing secrets, encryption, and limiting OTP generation.

By following the **“to whom it may concern”** design principle, this 2FA Service remains flexible, powerful, and easy to adopt across different microservices, strengthening the overall security posture of **FountainAI**.

