import pytest
from fastapi.testclient import TestClient
import httpx
from jose import jwt

# Import from our application.
from main import app, service_map, SECRET_KEY, get_current_user

client = TestClient(app)

# Helper: generate a dummy token (for reference, not used now)
def generate_dummy_token():
    payload = {"sub": "testuser", "roles": "user"}
    token = jwt.encode(payload, SECRET_KEY, algorithm="HS256")
    return token

# Instead of using a decorator to override, assign the override directly.
app.dependency_overrides[get_current_user] = lambda: {"username": "testuser", "roles": "user"}

# For proxy tests, we override httpx.AsyncClient using monkeypatch.
def dummy_backend(request: httpx.Request) -> httpx.Response:
    # Simulate a backend response.
    return httpx.Response(200, json={"dummy": "ok"})

@pytest.fixture(autouse=True)
def override_async_client(monkeypatch):
    original_client = httpx.AsyncClient
    from httpx import MockTransport

    class DummyAsyncClient(httpx.AsyncClient):
        def __init__(self, *args, **kwargs):
            kwargs["transport"] = MockTransport(dummy_backend)
            super().__init__(*args, **kwargs)

    monkeypatch.setattr(httpx, "AsyncClient", DummyAsyncClient)
    yield
    monkeypatch.setattr(httpx, "AsyncClient", original_client)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert "healthy" in data["status"]

def test_proxy_dummy_get():
    # Override service_map to include a dummy service.
    service_map["dummy"] = "http://dummy_backend"
    # No Authorization header is needed because the dependency override provides a dummy user.
    response = client.get("/dummy/test")
    assert response.status_code == 200
    data = response.json()
    assert data["dummy"] == "ok"
