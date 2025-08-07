import pytest
from unittest.mock import patch, MagicMock, call
from datetime import datetime

# Import controller functions
from app.controllers.admin import (
    get_system_users,
    delete_user,
    get_caregivers_for_review,
    review_caregiver,
    get_tickets_for_support,
    resolve_ticket,
    get_ticket_stats,
    get_interest_group_admins_for_review,
    review_interest_group_admin
)

from app.payloads import UserRole, UserStatus


class TestAdminController:
    
    # ============ GET SYSTEM USERS TESTS ============
    
    @patch('app.controllers.admin.auth_service')
    @patch('app.controllers.admin.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_system_users_success(self, mock_db, mock_auth_service, mock_admin_user, mock_request):
        """Test successful retrieval of system users by admin"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_admin_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [
            (1, "user1@gmail.com", "User One", "senior_citizen", "active", datetime.now()),
            (2, "user2@gmail.com", "User Two", "family_member", "pending_approval", datetime.now())
        ]
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        # Call controller
        response = await get_system_users(mock_request)
        
        # Assertions
        assert response.status_code == 200
        mock_auth_service.authenticate_user.assert_called_once()
        mock_cursor.execute.assert_called_once()

    @patch('app.controllers.admin.auth_service')
    @pytest.mark.asyncio
    async def test_get_system_users_unauthorized_no_header(self, mock_auth_service):
        """Test access denied when no auth header"""
        mock_request = MagicMock()
        mock_request.headers.get.return_value = None
        
        response = await get_system_users(mock_request)
        
        assert response.status_code == 401
        mock_auth_service.authenticate_user.assert_not_called()

    @patch('app.controllers.admin.auth_service')
    @pytest.mark.asyncio
    async def test_get_system_users_forbidden_non_admin(self, mock_auth_service, mock_registered_user, mock_request):
        """Test access denied for non-admin users"""
        # Setup: regular user (not admin)
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        response = await get_system_users(mock_request)
        
        assert response.status_code == 403

    @patch('app.controllers.admin.auth_service')
    @pytest.mark.asyncio
    async def test_get_system_users_invalid_token(self, mock_auth_service, mock_request):
        """Test invalid token handling"""
        mock_auth_service.authenticate_user.side_effect = ValueError("Invalid token")
        
        response = await get_system_users(mock_request)
        
        assert response.status_code == 401

    # ============ DELETE USER TESTS ============
    
    @patch('app.controllers.admin.auth_service')
    @patch('app.controllers.admin.get_db_connection')
    @pytest.mark.asyncio
    async def test_delete_user_success(self, mock_db, mock_auth_service, mock_admin_user, mock_request):
        """Test successful user deletion by admin"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_admin_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1  # Successful deletion
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        # Call controller
        response = await delete_user(mock_request, user_id=1)
        
        # Assertions
        assert response.status_code == 200
        mock_cursor.execute.assert_called()

    @patch('app.controllers.admin.auth_service')
    @patch('app.controllers.admin.get_db_connection')
    @pytest.mark.asyncio
    async def test_delete_user_not_found(self, mock_db, mock_auth_service, mock_admin_user, mock_request):
        """Test deletion of non-existent user"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_admin_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 0  # No rows affected
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        # Call controller
        response = await delete_user(mock_request, user_id=999)
        
        # Assertions
        assert response.status_code == 404

    # ============ CAREGIVER MANAGEMENT TESTS ============
    
    @patch('app.controllers.admin.auth_service')
    @patch('app.controllers.admin.get_db_connection')
    @pytest.mark.asyncio
    async def test_get_pending_caregivers_success(self, mock_db, mock_auth_service, mock_admin_user, mock_request):
        """Test successful retrieval of pending caregivers"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_admin_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [
            (1, "caregiver1@gmail.com", "Caregiver One", "caregiver", "pending_approval", "https://youtube.com/@caregiver1"),
            (2, "caregiver2@gmail.com", "Caregiver Two", "caregiver", "pending_approval", "https://youtube.com/@caregiver2")
        ]
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        # Call controller
        response = await get_caregivers_for_review(mock_request)
        
        # Assertions
        assert response.status_code == 200
        mock_cursor.execute.assert_called_once()

    @patch('app.controllers.admin.auth_service')
    @patch('app.controllers.admin.get_db_connection')
    @pytest.mark.asyncio
    async def test_verify_caregiver_approve(self, mock_db, mock_auth_service, mock_admin_user, mock_request):
        """Test caregiver approval"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_admin_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        # Mock request body
        mock_request.json = MagicMock()
        mock_request.json.return_value = {"status": "active"}
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.status = "active"
        
        # Call controller
        response = await review_caregiver(mock_request, caregiverId=1, validated_data=mock_validated_data)
        
        # Assertions
        assert response.status_code == 200
        mock_cursor.execute.assert_called()

    @patch('app.controllers.admin.auth_service')
    @patch('app.controllers.admin.get_db_connection')
    @pytest.mark.asyncio
    async def test_verify_caregiver_reject(self, mock_db, mock_auth_service, mock_admin_user, mock_request):
        """Test caregiver rejection"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_admin_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        # Mock request body
        mock_request.json = MagicMock()
        mock_request.json.return_value = {"status": "blocked"}
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.status = "blocked"
        
        # Call controller
        response = await review_caregiver(mock_request, caregiverId=1, validated_data=mock_validated_data)
        
        # Assertions
        assert response.status_code == 200

    # ============ INTEREST GROUP ADMIN TESTS ============
    
    @patch('app.controllers.admin.auth_service')
    @patch('app.controllers.admin.get_db_connection')
    @pytest.mark.asyncio
    async def test_get_pending_interest_group_admins_success(self, mock_db, mock_auth_service, mock_admin_user, mock_request):
        """Test successful retrieval of pending IGAs"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_admin_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [
            (1, "iga1@gmail.com", "IGA One", "interest_group_admin", "pending_approval", datetime.now()),
        ]
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        # Call controller
        response = await get_interest_group_admins_for_review(mock_request)
        
        # Assertions
        assert response.status_code == 200

    @patch('app.controllers.admin.auth_service')
    @patch('app.controllers.admin.get_db_connection')
    @pytest.mark.asyncio
    async def test_verify_interest_group_admin_success(self, mock_db, mock_auth_service, mock_admin_user, mock_request):
        """Test IGA verification"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_admin_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        # Mock request body
        mock_request.json = MagicMock()
        mock_request.json.return_value = {"status": "active"}
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.status = "active"
        
        # Call controller
        response = await review_interest_group_admin(mock_request, interestGroupAdminId=1, validated_data=mock_validated_data)
        
        # Assertions
        assert response.status_code == 200

    # ============ ERROR HANDLING TESTS ============
    
    @patch('app.controllers.admin.auth_service')
    @patch('app.controllers.admin.get_db_connection')
    @pytest.mark.asyncio
    async def test_database_error_handling(self, mock_db, mock_auth_service, mock_admin_user, mock_request):
        """Test database error handling"""
        # Setup mocks
        mock_auth_service.authenticate_user.return_value = (mock_admin_user, True)
        mock_db.side_effect = Exception("Database connection failed")
        
        # Call controller
        response = await get_system_users(mock_request)
        
        # Assertions
        assert response.status_code == 500

    # ============ PARAMETRIZED TESTS ============
    
    @pytest.mark.parametrize("user_role,expected_status", [
        (UserRole.ADMIN, 200),
        (UserRole.SENIOR_CITIZEN, 403),
        (UserRole.FAMILY_MEMBER, 403),
        (UserRole.CAREGIVER, 403),
        (UserRole.INTEREST_GROUP_ADMIN, 403),
        (UserRole.SUPPORT_USER, 403),
    ])
    @patch('app.controllers.admin.auth_service')
    @patch('app.controllers.admin.get_db_connection')
    @pytest.mark.asyncio
    async def test_role_based_access_control(self, mock_db, mock_auth_service, user_role, expected_status, mock_request):
        """Test role-based access control for different user roles"""
        # Create user with specific role
        user = MagicMock()
        user.role = user_role
        mock_auth_service.authenticate_user.return_value = (user, True)
        
        if expected_status == 200:
            # Setup successful DB response for admin
            mock_cursor = MagicMock()
            mock_cursor.fetchall.return_value = []
            mock_conn = MagicMock()
            mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
            mock_db.return_value.__enter__.return_value = mock_conn
        
        # Call controller
        response = await get_system_users(mock_request)
        
        # Assertions
        assert response.status_code == expected_status
