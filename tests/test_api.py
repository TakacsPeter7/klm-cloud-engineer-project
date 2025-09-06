import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.main import app, get_db
from app.models import Base
import tempfile
import os

SQLALCHEMY_DATABASE_URL = "sqlite:///./test_notes.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

@pytest.fixture(scope="function")
def test_client():
    Base.metadata.create_all(bind=engine)
    with TestClient(app) as client:
        yield client
    Base.metadata.drop_all(bind=engine)

def test_read_root(test_client):
    response = test_client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Welcome to the Note-Taking API"}

def test_create_note(test_client):
    note_data = {"title": "Test Note", "content": "This is a test note"}
    response = test_client.post("/notes", json=note_data)
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == "Test Note"
    assert data["content"] == "This is a test note"
    assert "id" in data

def test_get_notes(test_client):
    note_data = {"title": "Test Note", "content": "This is a test note"}
    test_client.post("/notes", json=note_data)
    
    response = test_client.get("/notes")
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 1

def test_get_note_by_id(test_client):
    note_data = {"title": "Test Note", "content": "This is a test note"}
    create_response = test_client.post("/notes", json=note_data)
    note_id = create_response.json()["id"]
    
    response = test_client.get(f"/notes/{note_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == "Test Note"

def test_update_note(test_client):
    note_data = {"title": "Test Note", "content": "This is a test note"}
    create_response = test_client.post("/notes", json=note_data)
    note_id = create_response.json()["id"]
    
    update_data = {"title": "Updated Note"}
    response = test_client.put(f"/notes/{note_id}", json=update_data)
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == "Updated Note"

def test_delete_note(test_client):
    note_data = {"title": "Test Note", "content": "This is a test note"}
    create_response = test_client.post("/notes", json=note_data)
    note_id = create_response.json()["id"]
    
    response = test_client.delete(f"/notes/{note_id}")
    assert response.status_code == 200
    assert response.json() == {"message": "Note deleted successfully"}
    
    get_response = test_client.get(f"/notes/{note_id}")
    assert get_response.status_code == 404
