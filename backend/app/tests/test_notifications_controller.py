import pytest
from unittest.mock import patch, MagicMock

# Import controller functions
from app.controllers.notifications import (
    get_notifications,
    mark_as_read
)


class TestNotificationsController:
    
    # ============ GET NOTIFICATIONS TESTS ============
    
    @patch('app.controllers.notifications.auth_service')
    @patch('app.controllers.notifications.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_notifications_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful retrieval of notifications"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [
            (1, "Test Notification", "Test Message", False, "2024-01-01"),
        ]
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await get_notifications(mock_request)
        
        assert response.status_code == 200

    @patch('app.controllers.notifications.auth_service')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_notifications_unauthorized(self, mock_auth_service):
        """Test access denied when no auth header"""
        mock_request = MagicMock()
        mock_request.headers.get.return_value = None
        
        response = await get_notifications(mock_request)
        
        assert response.status_code == 401

    @patch('app.controllers.notifications.auth_service')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_notifications_unregistered_user(self, mock_auth_service, mock_unregistered_user, mock_request):
        """Test access denied for unregistered user"""
        mock_auth_service.authenticate_user.return_value = (mock_unregistered_user, False)
        
        response = await get_notifications(mock_request)
        
        assert response.status_code == 401

    # ============ MARK AS READ TESTS ============
    
    @patch('app.controllers.notifications.auth_service')
    @patch('app.controllers.notifications.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_mark_as_read_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful marking notification as read"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        
        response = await mark_as_read(mock_request, 1, mock_validated_data)
        
        assert response.status_code == 200

    @patch('app.controllers.notifications.auth_service')
    @patch('app.controllers.notifications.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_mark_as_read_not_found(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test marking non-existent notification as read"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 0  # No rows affected
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        
        response = await mark_as_read(mock_request, 999, mock_validated_data)
        
        assert response.status_code == 404

    # ============ ERROR HANDLING TESTS ============
    
    @patch('app.controllers.notifications.auth_service')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_invalid_token_error(self, mock_auth_service, mock_request):
        """Test invalid token handling"""
        mock_auth_service.authenticate_user.side_effect = ValueError("Invalid token")
        
        response = await get_notifications(mock_request)
        
        assert response.status_code == 401

    @patch('app.controllers.notifications.auth_service')
    @patch('app.controllers.notifications.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_database_error_handling(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test database error handling"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        mock_db.side_effect = Exception("Database connection failed")
        
        response = await get_notifications(mock_request)
        
        assert response.status_code == 500

    # ============ AUTHENTICATION HEADER TESTS ============
    
    @pytest.mark.parametrize("auth_header,expected_status", [
        (None, 401),
        ("", 401),
        ("Basic token123", 401),
        ("Bearer", 401),
        ("Bearer ", 401),
        ("bearer token123", 401),  # lowercase bearer
    ])
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_auth_header_validation(self, auth_header, expected_status):
        """Test various Authorization header formats"""
        mock_request = MagicMock()
        mock_request.headers.get.return_value = auth_header
        
        response = await get_notifications(mock_request)
        assert response.status_code == expected_status
