"""Unit testing untuk aplikasi Flask ATS."""

import pytest
from app import app

@pytest.fixture
def client():
    """Fixture untuk test client Flask."""
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client

def test_home(client):
    """Test endpoint utama."""
    response = client.get("/")
    assert response.status_code == 200
    assert b"Selamat Datang di ATS CI/CD Secure Flask App!" in response.data

def test_health(client):
    """Test endpoint health check."""
    response = client.get("/health")
    assert response.status_code == 200
    json_data = response.get_json()
    assert json_data["status"] == "healthy"
