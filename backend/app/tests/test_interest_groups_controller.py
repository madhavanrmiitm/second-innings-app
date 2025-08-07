import pytest
from unittest.mock import patch, MagicMock

# Import controller functions
from app.controllers.interest_groups import (
    get_interest_groups,
    create_interest_group,
    get_interest_group,
    update_interest_group,
    join_interest_group,
    leave_interest_group
)


class TestInterestGroupsController:
    
    # ============ GET INTEREST GROUPS TESTS ============
    
    @patch('app.controllers.interest_groups.auth_service')
    @patch('app.controllers.interest_groups.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_interest_groups_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful retrieval of interest groups"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [
            (1, "Group 1", "Description 1", 1, "Admin Name", 5, 100),
        ]
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await get_interest_groups(mock_request)
        
        assert response.status_code == 200

    @patch('app.controllers.interest_groups.auth_service')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_interest_groups_unauthorized(self, mock_auth_service):
        """Test access denied when no auth header"""
        mock_request = MagicMock()
        mock_request.headers.get.return_value = None
        
        response = await get_interest_groups(mock_request)
        
        assert response.status_code == 401

    # ============ CREATE INTEREST GROUP TESTS ============
    
    @patch('app.controllers.interest_groups.auth_service')
    @patch('app.controllers.interest_groups.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_create_interest_group_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful creation of interest group"""
        # Create a user with interest_group_admin role
        mock_user = MagicMock()
        mock_user.role.value = "interest_group_admin"
        mock_user.id = 1
        mock_auth_service.authenticate_user.return_value = (mock_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = (1,)  # New group ID
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.name = "New Group"
        mock_validated_data.description = "Group Description"
        
        response = await create_interest_group(mock_request, mock_validated_data)
        
        assert response.status_code == 201

    @patch('app.controllers.interest_groups.auth_service')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_create_interest_group_forbidden(self, mock_auth_service, mock_registered_user, mock_request):
        """Test access denied for non-IGA users"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        
        response = await create_interest_group(mock_request, mock_validated_data)
        
        assert response.status_code == 403

    # ============ GET INTEREST GROUP TESTS ============
    
    @patch('app.controllers.interest_groups.auth_service')
    @patch('app.controllers.interest_groups.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_interest_group_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful retrieval of specific interest group"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = (1, "Group 1", "Description", 1, "Admin", 5)
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await get_interest_group(mock_request, 1)
        
        assert response.status_code == 200

    @patch('app.controllers.interest_groups.auth_service')
    @patch('app.controllers.interest_groups.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_interest_group_not_found(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test retrieval of non-existent interest group"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = None
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await get_interest_group(mock_request, 999)
        
        assert response.status_code == 404

    # ============ UPDATE INTEREST GROUP TESTS ============
    
    @patch('app.controllers.interest_groups.auth_service')
    @patch('app.controllers.interest_groups.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_update_interest_group_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful update of interest group"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.name = "Updated Group"
        mock_validated_data.description = "Updated Description"
        
        response = await update_interest_group(mock_request, 1, mock_validated_data)
        
        assert response.status_code == 200

    # ============ JOIN INTEREST GROUP TESTS ============
    
    @patch('app.controllers.interest_groups.auth_service')
    @patch('app.controllers.interest_groups.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_join_interest_group_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful joining of interest group"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = (1,)  # Group exists
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        
        response = await join_interest_group(mock_request, 1, mock_validated_data)
        
        assert response.status_code == 200

    # ============ LEAVE INTEREST GROUP TESTS ============
    
    @patch('app.controllers.interest_groups.auth_service')
    @patch('app.controllers.interest_groups.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_leave_interest_group_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful leaving of interest group"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        
        response = await leave_interest_group(mock_request, 1, mock_validated_data)
        
        assert response.status_code == 200

    # ============ ERROR HANDLING TESTS ============
    
    @patch('app.controllers.interest_groups.auth_service')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_invalid_token_error(self, mock_auth_service, mock_request):
        """Test invalid token handling"""
        mock_auth_service.authenticate_user.side_effect = ValueError("Invalid token")
        
        response = await get_interest_groups(mock_request)
        
        assert response.status_code == 401

    @patch('app.controllers.interest_groups.auth_service')
    @patch('app.controllers.interest_groups.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_database_error_handling(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test database error handling"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        mock_db.side_effect = Exception("Database connection failed")
        
        response = await get_interest_groups(mock_request)
        
        assert response.status_code == 500
