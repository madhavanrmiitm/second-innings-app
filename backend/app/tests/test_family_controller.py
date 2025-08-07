import pytest
from unittest.mock import patch, MagicMock

# Import controller functions
from app.controllers.family import (
    get_family_members,
    add_family_member,
    remove_family_member,
    get_linked_senior_citizens,
    link_senior_citizen
)


class TestFamilyController:
    
    # ============ GET FAMILY MEMBERS TESTS ============
    
    @patch('app.controllers.family.auth_service')
    @patch('app.controllers.family.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_family_members_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful retrieval of family members"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [
            (1, "Family Member 1", "member1@test.com", "senior_citizen"),
        ]
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await get_family_members(mock_request)
        
        assert response.status_code == 200

    @patch('app.controllers.family.auth_service')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_family_members_unauthorized(self, mock_auth_service):
        """Test access denied when no auth header"""
        mock_request = MagicMock()
        mock_request.headers.get.return_value = None
        
        response = await get_family_members(mock_request)
        
        assert response.status_code == 401

    # ============ ADD FAMILY MEMBER TESTS ============
    
    @patch('app.controllers.family.auth_service')
    @patch('app.controllers.family.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_add_family_member_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful addition of family member"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = (1,)  # New member ID
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.gmail_id = "newmember@test.com"
        
        response = await add_family_member(mock_request, mock_validated_data)
        
        assert response.status_code == 201

    # ============ REMOVE FAMILY MEMBER TESTS ============
    
    @patch('app.controllers.family.auth_service')
    @patch('app.controllers.family.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_remove_family_member_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful removal of family member"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        
        response = await remove_family_member(mock_request, 1, mock_validated_data)
        
        assert response.status_code == 200

    @patch('app.controllers.family.auth_service')
    @patch('app.controllers.family.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_remove_family_member_not_found(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test removal of non-existent family member"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 0  # No rows affected
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        
        response = await remove_family_member(mock_request, 999, mock_validated_data)
        
        assert response.status_code == 404

    # ============ GET LINKED SENIOR CITIZENS TESTS ============
    
    @patch('app.controllers.family.auth_service')
    @patch('app.controllers.family.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_linked_senior_citizens_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful retrieval of linked senior citizens"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [
            (1, "Senior Citizen 1", "senior1@test.com"),
        ]
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await get_linked_senior_citizens(mock_request)
        
        assert response.status_code == 200

    # ============ LINK SENIOR CITIZEN TESTS ============
    
    @patch('app.controllers.family.auth_service')
    @patch('app.controllers.family.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_link_senior_citizen_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful linking of senior citizen"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = (1,)
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.senior_citizen_gmail_id = "senior@test.com"
        
        response = await link_senior_citizen(mock_request, mock_validated_data)
        
        assert response.status_code == 201

    # ============ ERROR HANDLING TESTS ============
    
    @patch('app.controllers.family.auth_service')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_invalid_token_error(self, mock_auth_service, mock_request):
        """Test invalid token handling"""
        mock_auth_service.authenticate_user.side_effect = ValueError("Invalid token")
        
        response = await get_family_members(mock_request)
        
        assert response.status_code == 401

    @patch('app.controllers.family.auth_service')
    @patch('app.controllers.family.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_database_error_handling(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test database error handling"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        mock_db.side_effect = Exception("Database connection failed")
        
        response = await get_family_members(mock_request)
        
        assert response.status_code == 500
