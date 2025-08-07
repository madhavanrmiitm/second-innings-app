# Backend Testing Guide

This guide explains how to run and maintain unit tests for the Second Innings backend API.

## 🧪 Test Structure

Our test suite is organized as follows:

```
backend/app/tests/
├── conftest.py                 # Shared fixtures and utilities
├── test_auth_controller.py     # Authentication tests
├── test_admin_controller.py    # Admin management tests
├── test_user_controller.py     # User profile tests
├── test_tickets_controller.py  # Support tickets tests
└── ... (more controller tests)
```

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd backend
pip install -r requirements.txt
```

### 2. Run All Tests
```bash
# Using the test runner script
./run_tests.sh

# Or directly with pytest
python -m pytest app/tests/ -v
```

### 3. Run Specific Test Categories
```bash
# Authentication tests only
./run_tests.sh auth

# Admin functionality tests
./run_tests.sh admin

# User profile tests
./run_tests.sh user

# Support tickets tests
./run_tests.sh tickets
```

## 📋 Available Test Commands

| Command | Description |
|---------|-------------|
| `./run_tests.sh` | Run all tests |
| `./run_tests.sh auth` | Run authentication tests |
| `./run_tests.sh admin` | Run admin controller tests |
| `./run_tests.sh user` | Run user controller tests |
| `./run_tests.sh tickets` | Run tickets controller tests |
| `./run_tests.sh coverage` | Run tests with coverage report |
| `./run_tests.sh unit` | Run unit tests only |
| `./run_tests.sh integration` | Run integration tests |
| `./run_tests.sh parallel` | Run tests in parallel |
| `./run_tests.sh help` | Show help message |

## 🧩 Test Categories

### Unit Tests
- Test individual functions and methods in isolation
- Mock external dependencies (database, Firebase, etc.)
- Fast execution
- Marked with `@pytest.mark.unit`

### Integration Tests
- Test interaction between components
- Use test database
- Slower execution
- Marked with `@pytest.mark.integration`

## 📊 Coverage Reports

### Generate Coverage Report
```bash
./run_tests.sh coverage
```

This creates:
- Terminal coverage summary
- HTML report in `htmlcov/` directory
- XML report for CI/CD

### View HTML Coverage Report
```bash
# After running coverage
open htmlcov/index.html  # macOS
# or
xdg-open htmlcov/index.html  # Linux
```

## 🔧 Writing New Tests

### 1. Test File Structure
```python
import pytest
from unittest.mock import patch, MagicMock

# Import the controller function you're testing
from app.controllers.your_controller import your_function

class TestYourController:
    
    @patch('app.controllers.your_controller.dependency')
    async def test_your_function_success(self, mock_dependency, mock_user, mock_request):
        # Setup
        mock_dependency.method.return_value = expected_value
        
        # Execute
        response = await your_function(mock_request)
        
        # Assert
        assert response.status_code == 200
        mock_dependency.method.assert_called_once()
```

### 2. Common Patterns

#### Testing Success Cases
```python
@patch('app.controllers.auth.auth_service')
async def test_success_case(self, mock_auth_service, fixtures):
    # Setup mocks
    mock_auth_service.method.return_value = success_value
    
    # Call function
    result = await function_under_test(input_data)
    
    # Verify result
    assert result.status_code == 200
```

#### Testing Error Cases
```python
@patch('app.controllers.auth.auth_service')
async def test_error_case(self, mock_auth_service, fixtures):
    # Setup error
    mock_auth_service.method.side_effect = ValueError("Error message")
    
    # Call function
    result = await function_under_test(input_data)
    
    # Verify error handling
    assert result.status_code == 400
```

#### Parametrized Tests
```python
@pytest.mark.parametrize("input_value,expected_status", [
    ("valid_input", 200),
    ("invalid_input", 400),
    ("", 422),
])
async def test_multiple_scenarios(self, input_value, expected_status):
    result = await function_under_test(input_value)
    assert result.status_code == expected_status
```

### 3. Available Fixtures (from conftest.py)
- `mock_request` - Mock FastAPI request
- `mock_registered_user` - Sample registered user
- `mock_admin_user` - Admin user
- `mock_caregiver_user` - Caregiver user
- `mock_unregistered_user` - Unregistered user data
- `valid_token_request` - Valid token request payload
- `valid_registration_request` - Valid registration payload

## 🎯 Test Best Practices

### 1. Test Naming
- Use descriptive test names: `test_function_condition_expected_result`
- Example: `test_authenticate_user_invalid_token_returns_401`

### 2. Test Structure (AAA Pattern)
```python
async def test_example():
    # Arrange - Set up test data and mocks
    mock_service.method.return_value = expected_value
    
    # Act - Call the function being tested
    result = await function_under_test(input_data)
    
    # Assert - Verify the results
    assert result.status_code == 200
    assert result.data["key"] == expected_value
```

### 3. Mock External Dependencies
- Always mock database connections
- Mock Firebase authentication
- Mock external API calls
- Mock file system operations

### 4. Test Edge Cases
- Empty inputs
- Invalid data types
- Boundary values
- Network timeouts
- Database errors

## 🚨 Common Issues & Solutions

### 1. Import Errors
```bash
# If you see import errors, make sure you're in the backend directory
cd backend
python -m pytest app/tests/
```

### 2. Database Connection Errors
```python
# Always mock database connections in unit tests
@patch('app.controllers.your_controller.get_db_connection')
async def test_your_function(self, mock_db):
    # Your test code here
```

### 3. Async Function Testing
```python
# Use async/await for controller tests
async def test_async_function():
    result = await async_controller_function()
    assert result is not None
```

## 🔄 Continuous Integration

Tests automatically run on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Changes in the `backend/` directory

### GitHub Actions Workflow
- Runs on Ubuntu with Python 3.11
- Sets up PostgreSQL test database
- Runs all tests with coverage
- Uploads coverage reports

## 📈 Adding New Controllers

When adding a new controller, create a corresponding test file:

1. Create `test_new_controller.py` in `app/tests/`
2. Follow the existing test patterns
3. Add new fixtures to `conftest.py` if needed
4. Update this README if introducing new test categories

## 🎓 Learning Resources

- [pytest Documentation](https://docs.pytest.org/)
- [unittest.mock Guide](https://docs.python.org/3/library/unittest.mock.html)
- [FastAPI Testing](https://fastapi.tiangolo.com/tutorial/testing/)
- [Async Testing Best Practices](https://pytest-asyncio.readthedocs.io/)

## 📞 Getting Help

If you encounter issues with tests:
1. Check the test output for specific error messages
2. Verify your test environment setup
3. Review existing test patterns
4. Ask for help in team discussions

---

Happy Testing! 🧪✨
