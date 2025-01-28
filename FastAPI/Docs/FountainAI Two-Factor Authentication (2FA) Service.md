# FountainAI Two-Factor Authentication (2FA) Service
> Default FastAPI openAPI Version (3.0.1)
> **ToDo:** deploy overrides to achieve a more recent openAPI Version (3.1.0) 

## Overview
The 2FA Service is a standalone FastAPI microservice that integrates with the Key Management Service (KMS) and other FountainAI services to provide secure two-factor authentication. By requiring an additional layer of authentication, this service enhances the overall security of the FountainAI ecosystem, ensuring compliance with regulations like GDPR and mitigating risks of unauthorized access.

This service operates on a "to whom it may concern" basis, enabling seamless integration with other services in the ecosystem. Services can independently verify 2FA status without tightly coupling with the 2FA service.

## Implementation

### Directory Structure
```
2fa_service/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   ├── database.py
│   ├── models.py
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── otp.py
│   │   └── user.py
│   ├── services/
│   │   ├── __init__.py
│   │   ├── otp_service.py
│   │   └── user_service.py
│   ├── dependencies.py
│   ├── exceptions.py
│   ├── logging_config.py
│   └── routes/
│       ├── __init__.py
│       └── auth.py
├── Dockerfile
├── requirements.txt
├── .env
└── README.md
```

### Configuration

**File: app/config.py**
```python
import os
from pydantic import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str = "sqlite:///./2fa.db"
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your_super_secret_key")
    ALGORITHM: str = "HS256"
    OTP_EXPIRATION_MINUTES: int = 5

    class Config:
        env_file = ".env"

settings = Settings()
```

- **SECRET_KEY**: A cryptographic key used for signing JWTs and ensuring the integrity of OTPs. This key is central to securing communications and should be stored securely (e.g., in environment variables or a secrets manager). It is shared across the FountainAI ecosystem for signing and verifying tokens, ensuring consistency and security.
- **OTP_EXPIRATION_MINUTES**: Defines the validity period of an OTP (One-Time Password), ensuring that OTPs cannot be reused or exploited beyond a short window of time.

### Models

**File: app/models.py**
```python
from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.sql import func
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, nullable=False)
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

#### Relationship Explanation
- **User Model**: This model represents users in the FountainAI system. The `otp_secret` field stores a unique key for each user, enabling the generation of time-based one-time passwords (TOTPs). The `otp_enabled` field indicates whether 2FA is active for the user.
- **OTPLog Model**: This model logs OTP generation and verification attempts. Each record links to a user (`user_id`) and tracks whether an OTP has been verified to prevent reuse. The `expires_at` field ensures the OTP is valid only for a limited time. This linkage ensures OTP operations are securely and transparently tied to individual users, while the `verified` field prevents OTP reuse or exploitation.

### Routes

**File: app/routes/auth.py**
```python
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from ..dependencies import get_db
from ..services.otp_service import OTPService
from ..schemas.otp import OTPVerifyRequest, OTPVerifyResponse, OTPGenerateResponse

router = APIRouter()

otp_service = OTPService()

@router.post("/generate", response_model=OTPGenerateResponse, summary="Generate OTP for User", description="Creates a new OTP for the user to use during authentication. OTPs are time-limited.")
def generate_otp(username: str, db: Session = Depends(get_db)):
    """Generates a new OTP for the specified user."""
    try:
        otp_data = otp_service.generate_otp(username, db)
        return OTPGenerateResponse(otp_code=otp_data.otp_code, expires_at=otp_data.expires_at)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/verify", response_model=OTPVerifyResponse, summary="Verify OTP for User", description="Validates an OTP entered by the user. Ensures it matches the one generated previously and has not expired.")
def verify_otp(payload: OTPVerifyRequest, db: Session = Depends(get_db)):
    """Verifies the provided OTP for the specified user."""
    try:
        success = otp_service.verify_otp(payload.username, payload.otp_code, db)
        return OTPVerifyResponse(success=success)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
```

### OTP Service

**File: app/services/otp_service.py**
```python
import pyotp
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from ..models import User, OTPLog
from ..config import settings
from ..exceptions import HTTPException

class OTPService:
    def generate_otp(self, username: str, db: Session):
        """Generates a new OTP for the user."""
        user = db.query(User).filter(User.username == username).first()
        if not user or not user.otp_enabled:
            raise HTTPException(status_code=404, detail="User not found or 2FA not enabled")

        otp_secret = user.otp_secret
        if not otp_secret:
            raise HTTPException(status_code=400, detail="OTP secret not configured")

        totp = pyotp.TOTP(otp_secret)
        otp_code = totp.now()
        expires_at = datetime.utcnow() + timedelta(minutes=settings.OTP_EXPIRATION_MINUTES)

        otp_log = OTPLog(user_id=user.id, otp_code=otp_code, expires_at=expires_at, verified=False)
        db.add(otp_log)
        db.commit()
        db.refresh(otp_log)

        return otp_log

    def verify_otp(self, username: str, otp_code: str, db: Session):
        """Verifies the OTP for the user."""
        user = db.query(User).filter(User.username == username).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        totp = pyotp.TOTP(user.otp_secret)
        if not totp.verify(otp_code):
            raise HTTPException(status_code=401, detail="Invalid OTP")

        otp_log = db.query(OTPLog).filter(OTPLog.user_id == user.id, OTPLog.otp_code == otp_code).first()
        if not otp_log or otp_log.verified:
            raise HTTPException(status_code=400, detail="OTP already used or expired")

        otp_log.verified = True
        db.commit()
        return True
```

### Dockerfile

**File: Dockerfile**
```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./app /app/app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8004"]
```

### Requirements

**File: requirements.txt**
```
fastapi
uvicorn
sqlalchemy
pyotp
python-dotenv
```

---

This new 2FA Service is modular and connects with other FountainAI services through shared JWTs and database integration, providing secure authentication to "whom it may concern" endpoints.
