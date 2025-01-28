# FountainAI Ecosystem Security Manual

## Table of Contents

1. **Introduction**
   - Overview of Security in FountainAI
   - Core Components of FountainAI Security
2. **Key Security Concepts**
   - Role of JWT Authentication
   - Role of the `SECRET_KEY`
3. **`SECRET_KEY` Management**
   - Purpose and Functionality
   - Generation and Best Practices
   - Deployment and Storage
4. **JWT Authentication**
   - Token Creation
   - Token Validation
   - Token Lifecycle Management
5. **Service Security Model**
   - Key Management Service (KMS)
   - API Gateway
   - Backend Microservices
   - Typesense Client Service
6. **End-to-End Security Flow**
   - User Authentication Workflow
   - API Request Workflow
   - Data Synchronization Workflow
7. **Best Practices for Securing FountainAI**
   - Secure Key Storage
   - Token Expiration and Rotation
   - Logging and Monitoring
   - Network Isolation and TLS
8. **Advanced Security Features**
   - Multi-Factor Authentication (MFA)
   - Automated Key Rotation
   - Real-Time Alerting
9. **Implementation Examples**
   - Code Examples for Key Features
   - Docker Secrets and Cloud Key Management
10. **Appendix**
    - Common Security Pitfalls
    - Troubleshooting Authentication Issues

---

## 1. Introduction

### Overview of Security in FountainAI
The FountainAI Ecosystem is a secure, modular framework designed for managing APIs and services in an AI-driven application. Its security is built on two pillars:

1. **Centralized Key Management** via the Key Management Service (KMS).
2. **JWT Authentication** for user and service authorization.

By leveraging robust encryption and industry-standard practices, FountainAI ensures confidentiality, integrity, and availability of data and services.

### Core Components of FountainAI Security
1. **Key Management Service (KMS)**: Central hub for managing API keys and issuing JWT tokens.
2. **API Gateway**: Authenticates incoming requests and routes them to the appropriate backend services.
3. **Backend Microservices**: Perform domain-specific tasks and validate JWT tokens.
4. **Typesense Client Service**: Synchronizes data with the search engine securely.

---

## 2. Key Security Concepts

### Role of JWT Authentication
- **What is JWT?**: JSON Web Tokens (JWT) are compact, URL-safe tokens used for securely transmitting information between services.
- **Why JWT?**: Provides a stateless authentication mechanism, reducing server overhead and enabling scalability.
- **Use in FountainAI**:
  - Issued by the KMS after authentication.
  - Used by the API Gateway and microservices to validate access.

### Role of the `SECRET_KEY`
- **What is `SECRET_KEY`?**: A cryptographic secret used to sign and validate JWT tokens.
- **Why is it important?**: Ensures that JWT tokens cannot be tampered with or forged.

---

## 3. `SECRET_KEY` Management

### Purpose and Functionality
The `SECRET_KEY` is critical for:
1. **Signing JWT Tokens**: Adds a secure signature to ensure token authenticity.
2. **Validating JWT Tokens**: Verifies the integrity and source of the token.

### Generation and Best Practices
1. **Generation**:
   ```python
   import secrets
   SECRET_KEY = secrets.token_hex(32)  # Generates a secure 256-bit key
   ```
2. **Best Practices**:
   - Use a long, random value (minimum 32 characters).
   - Never hardcode in source code.
   - Rotate periodically.

### Deployment and Storage
1. **Environment Variables**:
   - Store in a `.env` file.
   - Example:
     ```
     SECRET_KEY=f82432a0b0f5461f8235a7b9e7d1c84b1e9eb1cbb3272d45fbdfeeb1c2e87f77
     ```
2. **Docker Secrets**:
   - Add to `docker-compose.yml`:
     ```yaml
     secrets:
       secret_key:
         file: ./secret_key.txt
     ```
3. **Cloud Secret Management**:
   - Use services like AWS Secrets Manager or HashiCorp Vault.

---

## 4. JWT Authentication

### Token Creation
1. **KMS Signs Tokens**:
   - Payload:
     ```python
     payload = {
         "sub": user_id,
         "roles": "admin",
         "exp": datetime.utcnow() + timedelta(minutes=60)
     }
     ```
   - Signed Token:
     ```python
     token = jwt.encode(payload, SECRET_KEY, algorithm="HS256")
     ```

### Token Validation
1. **Decoding and Verifying**:
   ```python
   jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
   ```
2. **Validation Steps**:
   - Check signature.
   - Ensure `exp` (expiration) is valid.
   - Validate claims (`sub`, `roles`, etc.).

### Token Lifecycle Management
1. **Short-Lived Tokens**:
   - Use tokens with a short expiration (e.g., 15-60 minutes).
   - Example:
     ```python
     "exp": datetime.utcnow() + timedelta(minutes=15)
     ```
2. **Token Rotation**:
   - Issue a new token upon expiration using refresh tokens.

---

## 5. Service Security Model

### Key Management Service (KMS)
- Central authority for issuing and validating tokens.
- Handles API key creation, rotation, and revocation.

### API Gateway
- Validates incoming tokens.
- Ensures only authenticated requests are routed to services.

### Backend Microservices
- Revalidate tokens received from the API Gateway.
- Secure communication with other services using JWT tokens.

### Typesense Client Service
- Synchronizes data securely with the Typesense engine.
- Validates tokens for requests from backend services.

---

## 6. End-to-End Security Flow

### User Authentication Workflow
1. User logs in to the KMS with a username and password.
2. KMS validates credentials and issues a signed JWT.
3. The user includes the JWT in the `Authorization` header for subsequent requests.

### API Request Workflow
1. User sends a request to the API Gateway with a JWT.
2. API Gateway:
   - Verifies the token using the `SECRET_KEY`.
   - Routes the request to the appropriate microservice.
3. Microservice:
   - Revalidates the token.
   - Processes the request securely.

### Data Synchronization Workflow
1. Backend services send data to the Typesense Client Service.
2. The Typesense Client Service validates the token and synchronizes data with the Typesense engine.

---

## 7. Best Practices for Securing FountainAI

### Secure Key Storage
- Store `SECRET_KEY` in environment variables or secret managers.
- Never expose it in logs or code repositories.

### Token Expiration and Rotation
- Use short-lived tokens.
- Implement refresh tokens for extended sessions.

### Logging and Monitoring
- Log all authentication and token validation events.
- Use tools like Prometheus and Grafana for monitoring.

### Network Isolation and TLS
- Use Docker networks to isolate services.
- Encrypt all communication using TLS.

---

## 8. Advanced Security Features

### Multi-Factor Authentication (MFA)
- Add an extra layer of security for administrative access.

### Automated Key Rotation
- Periodically rotate the `SECRET_KEY` and invalidate old tokens.

### Real-Time Alerting
- Set up alerts for suspicious activities (e.g., failed login attempts).

---

## 9. Implementation Examples

### Example: Using Docker Secrets
1. Create a secret file (`secret_key.txt`).
2. Reference it in `docker-compose.yml`:
   ```yaml
   secrets:
     secret_key:
       file: ./secret_key.txt
   ```

### Example: Validating JWT in FastAPI
```python
from jose import jwt, JWTError
from fastapi import HTTPException, Depends

SECRET_KEY = "your_secret_key"

def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        return payload
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
```

---

## 10. Appendix

### Common Security Pitfalls
- Hardcoding secrets in code.
- Using long-lived tokens without expiration.
- Failing to rotate keys periodically.

### Troubleshooting Authentication Issues
- **Invalid Token**: Ensure the token is signed with the correct `SECRET_KEY`.
- **Token Expired**: Check the `exp` claim and issue a new token.
- **Service Rejection**: Verify that all services share the same `SECRET_KEY`.

---

By following this comprehensive manual, the FountainAI Ecosystem can maintain a robust and secure environment, ensuring data integrity and seamless service orchestration.

