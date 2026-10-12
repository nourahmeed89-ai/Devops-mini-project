import pytest

from app import app

@pytest.fixture
def client():
    app.config["TESTING"] = True

    with app.test_client() as client:
        yield client

def test_home_endpoint(client):
    response = client.get("/")

    assert response.status_code == 200
    assert response.json == {
        "message": "Welcome to the DevOps Mini Project!"
    }

def test_health_endpoint(client):
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json == {"status": "healthy"}
    