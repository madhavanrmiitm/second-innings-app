import pytest
from unittest.mock import patch, MagicMock

# Import controller functions
from app.controllers.care import (
    view_open_requests,
    get_caregiver_requests,
    request_caregiver,
    accept_caregiver_request,
    reject_caregiver_request,
    get_current_caregiver,
    get_care_request,
    create_care_request,
    update_care_request,
    close_care_request,
    get_caregivers,
    get_caregiver_profile,
    apply_for_request,
    accept_engagement,
    decline_engagement
)


class TestCareController:
    
    # ============ VIEW OPEN REQUESTS TESTS ============
    
    @patch('app.controllers.care.auth_service')
    @patch('app.controllers.care.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_view_open_requests_success(self, mock_db, mock_auth_service, mock_caregiver_user, mock_request):
        """Test successful viewing of open requests by caregiver"""
        mock_auth_service.authenticate_user.return_value = (mock_caregiver_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [
            (1, 101, "Senior User", "Morning", "Location A", "2024-01-01"),
        ]
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await view_open_requests(mock_request)
        
        assert response.status_code == 200

    @patch('app.controllers.care.auth_service')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_view_open_requests_unauthorized(self, mock_auth_service, mock_registered_user, mock_request):
        """Test access denied for non-caregiver users"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        response = await view_open_requests(mock_request)
        
        assert response.status_code == 403

    # ============ GET CAREGIVER REQUESTS TESTS ============
    
    @patch('app.controllers.care.auth_service')
    @patch('app.controllers.care.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_caregiver_requests_success(self, mock_db, mock_auth_service, mock_caregiver_user, mock_request):
        """Test successful retrieval of caregiver's requests"""
        mock_auth_service.authenticate_user.return_value = (mock_caregiver_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = []
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await get_caregiver_requests(mock_request)
        
        assert response.status_code == 200

    # ============ REQUEST CAREGIVER TESTS ============
    
    @patch('app.controllers.care.auth_service')
    @patch('app.controllers.care.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_request_caregiver_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful caregiver request creation"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = (1,)  # New request ID
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.timing_to_visit = "Morning"
        mock_validated_data.location = "Test Location"
        
        response = await request_caregiver(mock_request, mock_validated_data)
        
        assert response.status_code == 201

    # ============ ACCEPT CAREGIVER REQUEST TESTS ============
    
    @patch('app.controllers.care.auth_service')
    @patch('app.controllers.care.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_accept_caregiver_request_success(self, mock_db, mock_auth_service, mock_caregiver_user, mock_request):
        """Test successful acceptance of caregiver request"""
        mock_auth_service.authenticate_user.return_value = (mock_caregiver_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.request_id = 1
        
        response = await accept_caregiver_request(mock_request, mock_validated_data)
        
        assert response.status_code == 200

    # ============ REJECT CAREGIVER REQUEST TESTS ============
    
    @patch('app.controllers.care.auth_service')
    @patch('app.controllers.care.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_reject_caregiver_request_success(self, mock_db, mock_auth_service, mock_caregiver_user, mock_request):
        """Test successful rejection of caregiver request"""
        mock_auth_service.authenticate_user.return_value = (mock_caregiver_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.request_id = 1
        
        response = await reject_caregiver_request(mock_request, mock_validated_data)
        
        assert response.status_code == 200

    # ============ GET CURRENT CAREGIVER TESTS ============
    
    @patch('app.controllers.care.auth_service')
    @patch('app.controllers.care.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_current_caregiver_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful retrieval of current caregiver"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = (1, "Caregiver Name", "caregiver@test.com")
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await get_current_caregiver(mock_request)
        
        assert response.status_code == 200

    # ============ GET CARE REQUEST TESTS ============
    
    @patch('app.controllers.care.auth_service')
    @patch('app.controllers.care.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_care_request_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful retrieval of care request"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = (1, 101, "Morning", "Location", "open")
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await get_care_request(mock_request, 1)
        
        assert response.status_code == 200

    # ============ CREATE CARE REQUEST TESTS ============
    
    @patch('app.controllers.care.auth_service')
    @patch('app.controllers.care.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_create_care_request_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful creation of care request"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = (1,)
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.timing_to_visit = "Morning"
        mock_validated_data.location = "Test Location"
        
        response = await create_care_request(mock_request, mock_validated_data)
        
        assert response.status_code == 201

    # ============ UPDATE CARE REQUEST TESTS ============
    
    @patch('app.controllers.care.auth_service')
    @patch('app.controllers.care.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_update_care_request_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful update of care request"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.timing_to_visit = "Evening"
        
        response = await update_care_request(mock_request, 1, mock_validated_data)
        
        assert response.status_code == 200

    # ============ CLOSE CARE REQUEST TESTS ============
    
    @patch('app.controllers.care.auth_service')
    @patch('app.controllers.care.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_close_care_request_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful closure of care request"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await close_care_request(mock_request, 1)
        
        assert response.status_code == 200

    # ============ GET CAREGIVERS TESTS ============
    
    @patch('app.controllers.care.auth_service')
    @patch('app.controllers.care.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_caregivers_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful retrieval of caregivers list"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [
            (1, "Caregiver One", "caregiver1@test.com", "youtube1"),
        ]
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await get_caregivers(mock_request)
        
        assert response.status_code == 200

    # ============ ERROR HANDLING TESTS ============
    
    @patch('app.controllers.care.auth_service')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_invalid_token_error(self, mock_auth_service, mock_request):
        """Test invalid token handling"""
        mock_auth_service.authenticate_user.side_effect = ValueError("Invalid token")
        
        response = await view_open_requests(mock_request)
        
        assert response.status_code == 401

    @patch('app.controllers.care.auth_service')
    @patch('app.controllers.care.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_database_error_handling(self, mock_db, mock_auth_service, mock_caregiver_user, mock_request):
        """Test database error handling"""
        mock_auth_service.authenticate_user.return_value = (mock_caregiver_user, True)
        mock_db.side_effect = Exception("Database connection failed")
        
        response = await view_open_requests(mock_request)
        
        assert response.status_code == 500
