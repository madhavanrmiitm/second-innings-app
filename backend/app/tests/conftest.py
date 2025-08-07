import pytest
from unittest.mock import MagicMock, AsyncMock
from datetime import datetime, date
from fastapi.testclient import TestClient
from fastapi import Request

# Import your models
from app.payloads import (
    User,
    UserRole,
    UserStatus,
    UnregisteredUser,
    TokenRequest,
    RegistrationRequest
)

# ============ SHARED FIXTURES ============

@pytest.fixture
def mock_request():
    """Mock FastAPI Request object"""
    request = MagicMock(spec=Request)
    request.headers = {"Authorization": "Bearer test_token"}
    return request

@pytest.fixture
def mock_db():
    """Mock database connection"""
    db = AsyncMock()
    return db

@pytest.fixture
def sample_user_dict():
    """Sample user data as dictionary"""
    return {
        "id": 1,
        "gmail_id": "test@gmail.com",
        "firebase_uid": "firebase_123",
        "full_name": "Test User",
        "role": "senior_citizen",
        "status": "active",
        "created_at": datetime.now(),
        "updated_at": datetime.now()
    }

@pytest.fixture
def mock_registered_user():
    """Returns a fully registered User object"""
    return User(
        id=1,
        gmail_id="test@gmail.com",
        firebase_uid="firebase_123",
        full_name="Test User",
        role=UserRole.SENIOR_CITIZEN,
        status=UserStatus.ACTIVE,
        created_at=datetime.now(),
        updated_at=datetime.now()
    )

@pytest.fixture
def mock_admin_user():
    """Returns an admin User object"""
    return User(
        id=2,
        gmail_id="admin@gmail.com",
        firebase_uid="firebase_admin",
        full_name="Admin User",
        role=UserRole.ADMIN,
        status=UserStatus.ACTIVE,
        created_at=datetime.now(),
        updated_at=datetime.now()
    )

@pytest.fixture
def mock_caregiver_user():
    """Returns a caregiver User object"""
    return User(
        id=3,
        gmail_id="caregiver@gmail.com",
        firebase_uid="firebase_caregiver",
        full_name="Caregiver User",
        role=UserRole.CAREGIVER,
        status=UserStatus.PENDING_APPROVAL,
        created_at=datetime.now(),
        updated_at=datetime.now(),
        youtube_url="https://youtube.com/@caregiver"
    )

@pytest.fixture
def mock_unregistered_user():
    """Returns Firebase user info for unregistered user"""
    return UnregisteredUser(
        firebase_uid="firebase_456",
        gmail_id="newuser@gmail.com",
        full_name="New User"
    )

@pytest.fixture
def valid_token_request():
    """Valid token request payload"""
    return TokenRequest(id_token="valid_token_123")

@pytest.fixture
def valid_registration_request():
    """Valid registration request payload"""
    return RegistrationRequest(
        id_token="valid_token_123",
        full_name="Test User",
        role=UserRole.FAMILY_MEMBER,
        date_of_birth=date(1990, 1, 1)
    )

@pytest.fixture
def caregiver_registration_request():
    """Caregiver registration request payload"""
    return RegistrationRequest(
        id_token="valid_token_123",
        full_name="Caregiver User",
        role=UserRole.CAREGIVER,
        date_of_birth=date(1985, 1, 1),
        youtube_url="https://youtube.com/@caregiver"
    )

# ============ MOCK SERVICES ============

@pytest.fixture
def mock_auth_service():
    """Mock auth service"""
    return MagicMock()

@pytest.fixture
def mock_admin_service():
    """Mock admin service"""
    return MagicMock()

@pytest.fixture
def mock_user_service():
    """Mock user service"""
    return MagicMock()

# ============ HELPER FUNCTIONS ============

def create_mock_response(status_code: int, data: dict = None, message: str = ""):
    """Create mock JSON response"""
    from fastapi.responses import JSONResponse
    content = {
        "message": message,
        "data": data or {}
    }
    return JSONResponse(content=content, status_code=status_code)

def extract_response_data(response):
    """Extract data from JSONResponse for testing"""
    import json
    if hasattr(response, 'body'):
        return json.loads(response.body)
    return response
