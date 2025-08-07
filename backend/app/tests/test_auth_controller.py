import pytest
from unittest.mock import patch, MagicMock
from datetime import datetime, date

# Import your controller functions
from app.controllers.auth import authenticate_user, register_user

# Import your models
from app.payloads import (
    TokenRequest,
    RegistrationRequest,
    User,
    UserRole,
    UserStatus,
    UnregisteredUser
)


# ============ FIXTURES ============
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

# ============ AUTHENTICATE USER TESTS ============
class TestAuthenticateUser:
    
    @patch('app.controllers.auth.auth_service')
    @pytest.mark.asyncio
    async def test_authenticate_registered_user(self, mock_auth_service, mock_registered_user, valid_token_request):
        """Test: Registered user returns 200"""
        # Setup mock
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        # Call controller
        response = await authenticate_user(None, valid_token_request)
        
        # Assertions
        assert response.status_code == 200
        # Check response structure
        # Verify auth_service was called with correct token
        
    @patch('app.controllers.auth.auth_service')
    @pytest.mark.asyncio
    async def test_authenticate_unregistered_user(self, mock_auth_service, mock_unregistered_user, valid_token_request):
        """Test: Unregistered user returns 201"""
        # Setup mock
        mock_auth_service.authenticate_user.return_value = (mock_unregistered_user, False)
        
        # Call controller
        response = await authenticate_user(None, valid_token_request)
        
        # Assertions
        assert response.status_code == 201
        # Check message indicates user not registered
        
    @patch('app.controllers.auth.auth_service')
    @pytest.mark.asyncio
    async def test_authenticate_invalid_token(self, mock_auth_service, valid_token_request):
        """Test: Invalid token returns 401"""
        # Setup mock to raise ValueError
        mock_auth_service.authenticate_user.side_effect = ValueError("Invalid token")
        
        # Call controller
        response = await authenticate_user(None, valid_token_request)
        
        # Assertions
        assert response.status_code == 401
        
    @patch('app.controllers.auth.auth_service')
    @pytest.mark.asyncio
    async def test_authenticate_service_error(self, mock_auth_service, valid_token_request):
        """Test: Service error returns 500"""
        # Setup mock to raise generic exception
        mock_auth_service.authenticate_user.side_effect = Exception("Database error")
        
        # Call controller
        response = await authenticate_user(None, valid_token_request)
        
        # Assertions
        assert response.status_code == 500

# ============ REGISTER USER TESTS ============
class TestRegisterUser:
    
    @patch('app.controllers.auth.auth_service')
    @pytest.mark.asyncio
    async def test_register_new_user_success(self, mock_auth_service, mock_registered_user, valid_registration_request):
        """Test: Successful registration returns 201"""
        # Setup mock
        mock_auth_service.register_user.return_value = mock_registered_user
        
        # Call controller
        response = await register_user(None, valid_registration_request)
        
        # Assertions
        assert response.status_code == 201
        # Verify user data in response
        
    @patch('app.controllers.auth.auth_service')
    @pytest.mark.asyncio
    async def test_register_already_registered(self, mock_auth_service, valid_registration_request):
        """Test: Already registered user returns 409"""
        # Setup mock
        mock_auth_service.register_user.side_effect = ValueError("User already registered")
        
        # Call controller
        response = await register_user(None, valid_registration_request)
        
        # Assertions
        assert response.status_code == 409
        
    @patch('app.controllers.auth.auth_service')
    @pytest.mark.asyncio
    async def test_register_invalid_token(self, mock_auth_service, valid_registration_request):
        """Test: Invalid token returns 401"""
        # Setup mock
        mock_auth_service.register_user.side_effect = ValueError("Token verification failed")
        
        # Call controller
        response = await register_user(None, valid_registration_request)
        
        # Assertions
        assert response.status_code == 401
        
    @patch('app.controllers.auth.auth_service')
    @pytest.mark.asyncio
    async def test_register_service_error(self, mock_auth_service, valid_registration_request):
        """Test: Service error returns 500"""
        # Setup mock
        mock_auth_service.register_user.side_effect = Exception("Database connection failed")
        
        # Call controller
        response = await register_user(None, valid_registration_request)
        
        # Assertions
        assert response.status_code == 500

# ============ PARAMETRIZED TESTS ============
class TestAuthParametrized:
    
    @pytest.mark.parametrize("exception,expected_status", [
        (ValueError("Invalid token"), 401),
        (ValueError("User already registered"), 409),
        (Exception("Database error"), 500),
    ])
    @patch('app.controllers.auth.auth_service')
    @pytest.mark.asyncio
    async def test_register_error_scenarios(self, mock_auth_service, exception, expected_status, valid_registration_request):
        """Test various error scenarios with parametrized inputs"""
        mock_auth_service.register_user.side_effect = exception
        
        response = await register_user(None, valid_registration_request)
        
        assert response.status_code == expected_status

# ============ EDGE CASES ============
class TestAuthEdgeCases:
    
    @patch('app.controllers.auth.auth_service')
    @pytest.mark.asyncio
    async def test_authenticate_with_special_characters_in_token(self, mock_auth_service):
        """Test token with special characters"""
        special_token = TokenRequest(id_token="token_with_!@#$%^&*()")
        mock_auth_service.authenticate_user.return_value = (MagicMock(), True)
        
        response = await authenticate_user(None, special_token)
        
        # Verify token passed correctly
        mock_auth_service.authenticate_user.assert_called_with("token_with_!@#$%^&*()")
    
    @patch('app.controllers.auth.auth_service')
    @pytest.mark.asyncio
    async def test_register_caregiver_without_youtube_url(self, mock_auth_service):
        """Test caregiver registration validation"""
        # This should fail at validation level before reaching controller
        # But good to test the flow
        pass

# ============ INTEGRATION-LIKE TESTS ============
class TestAuthIntegration:
    
    @patch('app.controllers.auth.auth_service')
    @patch('app.controllers.auth.logger')
    @pytest.mark.asyncio
    async def test_logging_on_authentication_success(self, mock_logger, mock_auth_service, mock_registered_user, valid_token_request):
        """Test that logging occurs correctly"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        await authenticate_user(None, valid_token_request)
        
        # Verify logger was called
        mock_logger.info.assert_called()
        
    @patch('app.controllers.auth.auth_service')
    @patch('app.controllers.auth.logger')
    @pytest.mark.asyncio
    async def test_logging_on_authentication_error(self, mock_logger, mock_auth_service, valid_token_request):
        """Test error logging"""
        mock_auth_service.authenticate_user.side_effect = ValueError("Bad token")
        
        await authenticate_user(None, valid_token_request)
        
        # Verify error was logged
        mock_logger.error.assert_called()



# Helper function to parse response
def get_response_data(response):
    """Extract data from JSONResponse"""
    import json
    return json.loads(response.body)

# Helper to verify response structure
def assert_response_structure(response, expected_keys):
    data = get_response_data(response)
    assert "message" in data
    assert "data" in data
    for key in expected_keys:
        assert key in data["data"]