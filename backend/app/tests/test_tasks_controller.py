import pytest
from unittest.mock import patch, MagicMock

# Import controller functions
from app.controllers.tasks import (
    get_tasks,
    create_task,
    get_task,
    update_task,
    mark_task_done,
    delete_task,
    get_reminders,
    create_reminder,
    update_reminder,
    snooze_reminder,
    cancel_reminder
)


class TestTasksController:
    
    # ============ GET TASKS TESTS ============
    
    @patch('app.controllers.tasks.auth_service')
    @patch('app.controllers.tasks.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_tasks_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful retrieval of tasks"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [
            (1, "Test Task", "Task Description", "pending", "2024-01-01", "2024-01-02"),
        ]
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await get_tasks(mock_request)
        
        assert response.status_code == 200

    @patch('app.controllers.tasks.auth_service')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_tasks_unauthorized(self, mock_auth_service):
        """Test access denied when no auth header"""
        mock_request = MagicMock()
        mock_request.headers.get.return_value = None
        
        response = await get_tasks(mock_request)
        
        assert response.status_code == 401

    # ============ CREATE TASK TESTS ============
    
    @patch('app.controllers.tasks.auth_service')
    @patch('app.controllers.tasks.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_create_task_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful task creation"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = (1,)  # New task ID
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.title = "New Task"
        mock_validated_data.description = "Task Description"
        mock_validated_data.due_date = "2024-01-01"
        
        response = await create_task(mock_request, mock_validated_data)
        
        assert response.status_code == 201

    # ============ GET TASK TESTS ============
    
    @patch('app.controllers.tasks.auth_service')
    @patch('app.controllers.tasks.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_task_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful retrieval of specific task"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = (1, "Task Title", "Description", "pending", "2024-01-01")
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await get_task(mock_request, 1)
        
        assert response.status_code == 200

    @patch('app.controllers.tasks.auth_service')
    @patch('app.controllers.tasks.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_task_not_found(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test retrieval of non-existent task"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = None
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await get_task(mock_request, 999)
        
        assert response.status_code == 404

    # ============ UPDATE TASK TESTS ============
    
    @patch('app.controllers.tasks.auth_service')
    @patch('app.controllers.tasks.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_update_task_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful task update"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.title = "Updated Task"
        mock_validated_data.description = "Updated Description"
        
        response = await update_task(mock_request, 1, mock_validated_data)
        
        assert response.status_code == 200

    # ============ MARK TASK DONE TESTS ============
    
    @patch('app.controllers.tasks.auth_service')
    @patch('app.controllers.tasks.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_mark_task_done_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful marking task as done"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        
        response = await mark_task_done(mock_request, 1, mock_validated_data)
        
        assert response.status_code == 200

    # ============ DELETE TASK TESTS ============
    
    @patch('app.controllers.tasks.auth_service')
    @patch('app.controllers.tasks.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_delete_task_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful task deletion"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        
        response = await delete_task(mock_request, 1, mock_validated_data)
        
        assert response.status_code == 200

    # ============ GET REMINDERS TESTS ============
    
    @patch('app.controllers.tasks.auth_service')
    @patch('app.controllers.tasks.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_get_reminders_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful retrieval of reminders"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [
            (1, "Test Reminder", "2024-01-01 10:00:00", "active"),
        ]
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        response = await get_reminders(mock_request)
        
        assert response.status_code == 200

    # ============ CREATE REMINDER TESTS ============
    
    @patch('app.controllers.tasks.auth_service')
    @patch('app.controllers.tasks.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_create_reminder_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful reminder creation"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = (1,)  # New reminder ID
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.title = "New Reminder"
        mock_validated_data.reminder_time = "2024-01-01 10:00:00"
        
        response = await create_reminder(mock_request, mock_validated_data)
        
        assert response.status_code == 201

    # ============ ERROR HANDLING TESTS ============
    
    @patch('app.controllers.tasks.auth_service')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_invalid_token_error(self, mock_auth_service, mock_request):
        """Test invalid token handling"""
        mock_auth_service.authenticate_user.side_effect = ValueError("Invalid token")
        
        response = await get_tasks(mock_request)
        
        assert response.status_code == 401

    @patch('app.controllers.tasks.auth_service')
    @patch('app.controllers.tasks.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_database_error_handling(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test database error handling"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        mock_db.side_effect = Exception("Database connection failed")
        
        response = await get_tasks(mock_request)
        
        assert response.status_code == 500

    # ============ SNOOZE AND CANCEL REMINDER TESTS ============
    
    @patch('app.controllers.tasks.auth_service')
    @patch('app.controllers.tasks.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_snooze_reminder_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful reminder snoozing"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        mock_validated_data.snooze_until = "2024-01-01 11:00:00"
        
        response = await snooze_reminder(mock_request, 1, mock_validated_data)
        
        assert response.status_code == 200

    @patch('app.controllers.tasks.auth_service')
    @patch('app.controllers.tasks.get_db_connection')
    @pytest.mark.asyncio
    @pytest.mark.asyncio
    async def test_cancel_reminder_success(self, mock_db, mock_auth_service, mock_registered_user, mock_request):
        """Test successful reminder cancellation"""
        mock_auth_service.authenticate_user.return_value = (mock_registered_user, True)
        
        mock_cursor = MagicMock()
        mock_cursor.rowcount = 1
        mock_conn = MagicMock()
        mock_conn.cursor.return_value.__enter__.return_value = mock_cursor
        mock_db.return_value.__enter__.return_value = mock_conn
        
        mock_validated_data = MagicMock()
        mock_validated_data.id_token = "test_token"
        
        response = await cancel_reminder(mock_request, 1, mock_validated_data)
        
        assert response.status_code == 200
