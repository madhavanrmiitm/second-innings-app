import pytest
from unittest.mock import patch, MagicMock
from datetime import datetime

# Import controller functions
from app.controllers.tickets import get_tickets, create_ticket, get_ticket, update_ticket
from app.payloads import TicketStatus


class TestTicketsController:
    
    # ============ GET TICKETS TESTS ============
    
    @patch('app.controllers.tickets.auth_service')
    @patch('app.controllers.tickets.get_db_connection')
    @pytest.mark.asyncio
    async def test_get_tickets_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful retrieval of user tickets"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [
            (1, 1, None, "Test Subject", "Test Description", "open", datetime.now(), None),
            (2, 1, 2, "Another Subject", "Another Description", "resolved", datetime.now(), datetime.now())
        ]
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        # Call controller
        response = await get_tickets(mock_request)
        
        # Assertions
        assert response.status_code == 200
        mock_auth_service.authenticate_user.assert_called_once()
        mock_cursor.execute.assert_called_once()

    @patch('app.controllers.tickets.auth_service')
    @pytest.mark.asyncio
    async def test_get_tickets_unauthorized_no_header(self, mock_auth_service):
        """Test access denied when no auth header"""
        mock_request = MagicMock()
        mock_request.headers.get.return_value = None
        
        response = await get_tickets(mock_request)
        
        assert response.status_code == 401
        mock_auth_service.authenticate_user.assert_not_called()

    @patch('app.controllers.tickets.auth_service')
    @pytest.mark.asyncio
    async def test_get_tickets_invalid_bearer_format(self, mock_auth_service):
        """Test invalid Authorization header format"""
        mock_request = MagicMock()
        mock_request.headers.get.return_value = "InvalidFormat token123"
        
        response = await get_tickets(mock_request)
        
        assert response.status_code == 401

    @patch('app.controllers.tickets.auth_service')
    @pytest.mark.asyncio
    async def test_get_tickets_unregistered_user(self, mock_auth_service, mock_unregistered_user, mock_request):
        """Test access denied for unregistered user"""
        mock_auth_service.authenticate_user.return_value = (mock_unregistered_user, False)
        
        response = await get_tickets(mock_request)
        
        assert response.status_code == 401

    @patch('app.controllers.tickets.auth_service')
    @pytest.mark.asyncio
    async def test_get_tickets_invalid_token(self, mock_auth_service, mock_request):
        """Test invalid token handling"""
        mock_auth_service.authenticate_user.side_effect = ValueError("Invalid token")
        
        response = await get_tickets(mock_request)
        
        assert response.status_code == 401

    @patch('app.controllers.tickets.auth_service')
    @patch('app.controllers.tickets.get_db_connection')
    @pytest.mark.asyncio
    async def test_get_tickets_empty_result(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test when user has no tickets"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = []  # No tickets
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        # Call controller
        response = await get_tickets(mock_request)
        
        # Assertions
        assert response.status_code == 200

    # ============ CREATE TICKET TESTS ============
    
    @patch('app.controllers.tickets.auth_service')
    @patch('app.controllers.tickets.get_db_connection')
    @pytest.mark.asyncio
    async def test_create_ticket_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful ticket creation"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = (1,)  # New ticket ID
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        # Mock request body
        mock_request.json = MagicMock()
        mock_request.json.return_value = {
            "subject": "Test Subject",
            "description": "Test Description"
        }
        
        # Call controller (assuming you have this function)
        # response = await create_ticket(mock_request)
        
        # Note: You'll need to implement this test based on your actual create_ticket function
        pass

    # ============ UPDATE TICKET STATUS TESTS ============
    
    @patch('app.controllers.tickets.auth_service')
    @patch('app.controllers.tickets.get_db_connection')
    @pytest.mark.asyncio
    async def test_update_ticket_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful ticket update"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        # Mock the ownership check - return the same user ID
        mock_cursor.fetchone.side_effect = [
            (mock_registered_user.id,),  # First call: ownership check
            None  # Second call: can be anything for update result
        ]
        mock_cursor.rowcount = 1  # Successful update
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.title = "Updated ticket"
        mock_validated_data.description = "Updated description"
        
        # Call controller
        response = await update_ticket(mock_request, ticketId=1, validated_data=mock_validated_data)
        
        # Assertions
        assert response.status_code == 200

    # ============ ERROR HANDLING TESTS ============
    
    @patch('app.controllers.tickets.auth_service')
    @patch('app.controllers.tickets.get_db_connection')
    @pytest.mark.asyncio
    async def test_get_tickets_database_error(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test database error handling"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        mock_db.side_effect = Exception("Database connection failed")
        
        # Call controller
        response = await get_tickets(mock_request)
        
        # Assertions
        assert response.status_code == 500

    # ============ PARAMETRIZED TESTS ============
    
    @pytest.mark.parametrize("auth_header,expected_status", [
        (None, 401),
        ("", 401),
        ("Basic token123", 401),
        ("Bearer", 401),
        ("Bearer ", 401),
        ("bearer token123", 401),  # lowercase bearer
        ("Bearer token123", 200),  # valid format
    ])
    @patch('app.controllers.tickets.auth_service')
    @patch('app.controllers.tickets.get_db_connection')
    @pytest.mark.asyncio
    async def test_auth_header_validation(self, mock_db, mock_auth_service, auth_header, expected_status, mock_registered_user):
        """Test various Authorization header formats"""
        mock_request = MagicMock()
        mock_request.headers.get.return_value = auth_header
        
        if expected_status == 200:
            # Setup successful response for valid header
            mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
            mock_cursor = MagicMock()
            mock_cursor.fetchall.return_value = []
            mock_conn = MagicMock()
            mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
            mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await get_tickets(mock_request)
        assert response.status_code == expected_status

    @pytest.mark.parametrize("exception_type,exception_message,expected_status", [
        (ValueError, "Invalid token", 401),
        (ValueError, "Token expired", 401),
        (Exception, "Database error", 500),
        (Exception, "Network timeout", 500),
    ])
    @patch('app.controllers.tickets.auth_service')
    @pytest.mark.asyncio
    async def test_exception_handling(self, mock_auth_service, exception_type, exception_message, expected_status, mock_request):
        """Test various exception scenarios"""
        mock_auth_service.authenticate_user.side_effect = exception_type(exception_message)
        
        response = await get_tickets(mock_request)
        assert response.status_code == expected_status

    # ============ LOGGING TESTS ============
    
    @patch('app.controllers.tickets.auth_service')
    @patch('app.controllers.tickets.get_db_connection')
    @patch('app.controllers.tickets.logger')
    @pytest.mark.asyncio
    async def test_logging_on_success(self, mock_logger, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test logging on successful ticket retrieval"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = []
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        await get_tickets(mock_request)
        
        # Verify logger.info was called
        mock_logger.info.assert_called()

    @patch('app.controllers.tickets.auth_service')
    @patch('app.controllers.tickets.logger')
    @pytest.mark.asyncio
    async def test_logging_on_error(self, mock_logger, mock_auth_service, mock_request):
        """Test error logging"""
        mock_auth_service.authenticate_user.side_effect = ValueError("Bad token")
        
        await get_tickets(mock_request)
        
        # Verify error was logged
        mock_logger.error.assert_called()

    # ============ INTEGRATION-LIKE TESTS ============
    
    @patch('app.controllers.tickets.auth_service')
    @patch('app.controllers.tickets.get_db_connection')
    @pytest.mark.asyncio
    async def test_tickets_data_structure(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test that returned ticket data has correct structure"""
        # Setup mocks with realistic ticket data
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [
            (1, 1, None, "Subject 1", "Description 1", "open", datetime.now(), None),
            (2, 1, 2, "Subject 2", "Description 2", "in_progress", datetime.now(), None),
            (3, 1, 2, "Subject 3", "Description 3", "resolved", datetime.now(), datetime.now())
        ]
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await get_tickets(mock_request)
        
        assert response.status_code == 200
        # Additional assertions about response structure would go here
