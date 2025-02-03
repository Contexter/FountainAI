"""
API Gateway Service for FountainAI
====================================

This self-contained FastAPI application serves as the central entry point for client
requests in the FountainAI ecosystem. It performs JWT validation and dynamically routes
requests to backend services based on the first URL segment.

Features:
- Validates JWT tokens using a simple AuthService.
- Uses a service map to forward requests to the correct backend service.
- Proxies requests asynchronously using httpx.
- Exposes Prometheus metrics.
- Provides a health-check endpoint.
- Overrides the OpenAPI schema to 3.0.3 (Swagger-compatible).
"""

import os
import logging
import httpx
from fastapi import FastAPI, Request, Depends, HTTPException, status
from fastapi.openapi.utils import get_openapi
from fastapi.responses import Response
from jose import JWTError, jwt
from dotenv import load_dotenv

# Load environment variables.
load_dotenv()
SECRET_KEY = os.getenv("SECRET_KEY", "your_api_gateway_secret_key")
API_GATEWAY_HOST = os.getenv("API_GATEWAY_HOST", "0.0.0.0")
API_GATEWAY_PORT = int(os.getenv("API_GATEWAY_PORT", "8002"))

# -----------------------------------------------------------------------------
# Logging configuration
# -----------------------------------------------------------------------------
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("api-gateway")

# -----------------------------------------------------------------------------
# Simple Auth Service & Dependency for JWT Validation
# -----------------------------------------------------------------------------
class AuthService:
    def verify_token(self, token: str, secret_key: str, algorithm: str = "HS256") -> dict:
        try:
            payload = jwt.decode(token, secret_key, algorithms=[algorithm])
            username = payload.get("sub")
            roles = payload.get("roles")
            if username is None:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid token payload."
                )
            return {"username": username, "roles": roles}
        except JWTError as e:
            logger.error("JWT error: %s", e)
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token signature or expired."
            )

auth_service = AuthService()

def get_token_header(authorization: str = None):
    if authorization is None or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing authorization header."
        )
    return authorization.split(" ")[1]

def get_current_user(token: str = Depends(get_token_header)):
    return auth_service.verify_token(token, SECRET_KEY)

# -----------------------------------------------------------------------------
# Service Map: Mapping first URL segment to backend service URL.
# -----------------------------------------------------------------------------
service_map = {
    "service_a": "http://service_a:8000",
    "typesense_client": "http://typesense_client_service:8001",
    # Add additional microservices here.
}

# -----------------------------------------------------------------------------
# FastAPI Application Initialization
# -----------------------------------------------------------------------------
app = FastAPI(
    title="API Gateway",
    description="Central entry point for FountainAI ecosystem requests; validates JWTs and routes requests to backend services.",
    version="1.0.0",
)

# -----------------------------------------------------------------------------
# Custom OpenAPI Schema Generation (Swagger-Compatible)
# -----------------------------------------------------------------------------
def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    schema = get_openapi(
        title=app.title,
        version=app.version,
        description=app.description,
        routes=app.routes,
    )
    schema["openapi"] = "3.0.3"
    app.openapi_schema = schema
    return app.openapi_schema

app.openapi = custom_openapi

# -----------------------------------------------------------------------------
# Prometheus Instrumentation
# -----------------------------------------------------------------------------
from prometheus_fastapi_instrumentator import Instrumentator
Instrumentator().instrument(app).expose(app)

# -----------------------------------------------------------------------------
# Health Check Endpoint
# -----------------------------------------------------------------------------
@app.get("/health", tags=["Health"])
async def health_check():
    return {"status": "healthy"}

# -----------------------------------------------------------------------------
# Proxy Endpoint: Catch-all route to forward requests.
# -----------------------------------------------------------------------------
@app.api_route("/{full_path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH"])
async def proxy(
    full_path: str,
    request: Request,
    current_user: dict = Depends(get_current_user)
):
    """
    Catches all requests and forwards them to the appropriate backend service.
    
    The first segment of the path determines the target service.
    Example: /service_a/endpoint will be forwarded to http://service_a:8000/endpoint.
    """
    path_parts = full_path.split("/")
    if not path_parts or path_parts[0] == "":
        raise HTTPException(status_code=400, detail="Invalid path.")

    target_key = path_parts[0]
    service_url = service_map.get(target_key)
    if not service_url:
        raise HTTPException(status_code=404, detail="Service not recognized.")

    sub_path = "/".join(path_parts[1:])  # This may be empty.
    target_url = f"{service_url}/{sub_path}" if sub_path else service_url
    logger.info("Routing request to %s", target_url)

    # Forward headers (remove the host header).
    headers = dict(request.headers)
    headers.pop("host", None)

    async with httpx.AsyncClient() as client:
        try:
            response = await client.request(
                method=request.method,
                url=target_url,
                headers=headers,
                params=request.query_params,
                content=await request.body()
            )
        except httpx.HTTPError as exc:
            logger.error("Error forwarding request: %s", exc)
            raise HTTPException(status_code=502, detail="Bad Gateway")
    return Response(
        content=response.content,
        status_code=response.status_code,
        headers=dict(response.headers)
    )

# -----------------------------------------------------------------------------
# Run the Application
# -----------------------------------------------------------------------------
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=API_GATEWAY_HOST, port=API_GATEWAY_PORT)
