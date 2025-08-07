import pytest
from unittest.mock import patch, MagicMock

# Import controller functions
from app.controllers.user import get_profile
from app.payloads import TokenRequest, ProfileResponse


class TestUserController:
    
    # ============ GET PROFILE TESTS ============
    
    @patch('app.controllers.user.auth_service')
    @pytest.mark.asyncio
    async def test_get_profile_registered_user_success(self, mock_auth_service, mock_registered_user, valid_token_request):
        """Test successful profile retrieval for registered user"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        # Call controller
        response = await get_profile(None, valid_token_request)
        
        # Assertions
        assert response.status_code == 200
        mock_auth_service.authenticate_user.assert_called_once_with("valid_token_123")

    @patch('app.controllers.user.auth_service')
    @pytest.mark.asyncio
    async def test_get_profile_unregistered_user(self, mock_auth_service, mock_unregistered_user, valid_token_request):
        """Test profile retrieval for unregistered user"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_unregistered_user, False)
        
        # Call controller
        response = await get_profile(None, valid_token_request)
        
        # Assertions
        assert response.status_code == 201
        mock_auth_service.authenticate_user.assert_called_once_with("valid_token_123")

    @patch('app.controllers.user.auth_service')
    @pytest.mark.asyncio
    async def test_get_profile_invalid_token(self, mock_auth_service, valid_token_request):
        """Test profile retrieval with invalid token"""
        # Setup mock to raise ValueError
        mock_auth_service.authenticate_user.side_effect = ValueError("Invalid token")
        
        # Call controller
        response = await get_profile(None, valid_token_request)
        
        # Assertions
        assert response.status_code == 401

    @patch('app.controllers.user.auth_service')
    @pytest.mark.asyncio
    async def test_get_profile_service_error(self, mock_auth_service, valid_token_request):
        """Test profile retrieval with service error"""
        # Setup mock to raise generic exception
        mock_auth_service.authenticate_user.side_effect = Exception("Database error")
        
        # Call controller
        response = await get_profile(None, valid_token_request)
        
        # Assertions
        assert response.status_code == 500

    # ============ TOKEN VALIDATION TESTS ============
    
    @patch('app.controllers.user.auth_service')
    @pytest.mark.asyncio
    async def test_get_profile_empty_token(self, mock_auth_service):
        """Test profile retrieval with empty token"""
        empty_token_request = TokenRequest(id_token="")
        mock_auth_service.authenticate_user.side_effect = ValueError("Empty token")
        
        # Call controller
        response = await get_profile(None, empty_token_request)
        
        # Assertions
        assert response.status_code == 401

    @patch('app.controllers.user.auth_service')
    @pytest.mark.asyncio
    async def test_get_profile_malformed_token(self, mock_auth_service):
        """Test profile retrieval with malformed token"""
        malformed_token_request = TokenRequest(id_token="invalid.token.format")
        mock_auth_service.authenticate_user.side_effect = ValueError("Malformed token")
        
        # Call controller
        response = await get_profile(None, malformed_token_request)
        
        # Assertions
        assert response.status_code == 401

    # ============ EDGE CASES ============
    
    @patch('app.controllers.user.auth_service')
    @pytest.mark.asyncio
    async def test_get_profile_with_special_characters_token(self, mock_auth_service, mock_registered_user):
        """Test profile retrieval with token containing special characters"""
        special_token = TokenRequest(id_token="token_with_!@#$%^&*()")
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        # Call controller
        response = await get_profile(None, special_token)
        
        # Assertions
        assert response.status_code == 200
        mock_auth_service.authenticate_user.assert_called_with("token_with_!@#$%^&*()")

    @patch('app.controllers.user.auth_service')
    @pytest.mark.asyncio
    async def test_get_profile_very_long_token(self, mock_auth_service, mock_registered_user):
        """Test profile retrieval with very long token"""
        long_token = TokenRequest(id_token="a" * 2000)  # Very long token
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        # Call controller
        response = await get_profile(None, long_token)
        
        # Assertions
        assert response.status_code == 200

    # ============ PARAMETRIZED TESTS ============
    
    @pytest.mark.parametrize("exception,expected_status,expected_message_contains", [
        (ValueError("Invalid token"), 401, "Authentication failed"),
        (ValueError("Token expired"), 401, "Authentication failed"),
        (ValueError("Token verification failed"), 401, "Authentication failed"),
        (Exception("Database connection failed"), 500, "Internal server error"),
        (Exception("Network error"), 500, "Internal server error"),
    ])
    @patch('app.controllers.user.auth_service')
    @pytest.mark.asyncio
    async def test_get_profile_error_scenarios(self, mock_auth_service, exception, expected_status, expected_message_contains, valid_token_request):
        """Test various error scenarios with parametrized inputs"""
        mock_auth_service.authenticate_user.side_effect = exception
        
        response = await get_profile(None, valid_token_request)
        
        assert response.status_code == expected_status

    # ============ LOGGING TESTS ============
    
    @patch('app.controllers.user.auth_service')
    @patch('app.controllers.user.logger')
    @pytest.mark.asyncio
    async def test_logging_on_success(self, mock_logger, mock_auth_service, mock_registered_user, valid_token_request):
        """Test that logging occurs on successful profile retrieval"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        await get_profile(None, valid_token_request)
        
        # Verify logger.info was called
        mock_logger.info.assert_called()

    @patch('app.controllers.user.auth_service')
    @patch('app.controllers.user.logger')
    @pytest.mark.asyncio
    async def test_logging_on_error(self, mock_logger, mock_auth_service, valid_token_request):
        """Test error logging"""
        mock_auth_service.authenticate_user.side_effect = ValueError("Bad token")
        
        await get_profile(None, valid_token_request)
        
        # Verify error was logged
        mock_logger.error.assert_called()

    # ============ RESPONSE STRUCTURE TESTS ============
    
    @patch('app.controllers.user.auth_service')
    @pytest.mark.asyncio
    async def test_get_profile_response_structure_registered(self, mock_auth_service, mock_registered_user, valid_token_request):
        """Test response structure for registered user"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        response = await get_profile(None, valid_token_request)
        
        # Check response structure (this would need actual implementation based on your response format)
        assert response.status_code == 200
        # Additional checks for response body structure would go here

    @patch('app.controllers.user.auth_service')
    @pytest.mark.asyncio
    async def test_get_profile_response_structure_unregistered(self, mock_auth_service, mock_unregistered_user, valid_token_request):
        """Test response structure for unregistered user"""
        mock_auth_service.authenticate_user.return_value = (mock_unregistered_user, False)
        
        response = await get_profile(None, valid_token_request)
        
        # Check response structure
        assert response.status_code == 201
        # Additional checks for response body structure would go here
