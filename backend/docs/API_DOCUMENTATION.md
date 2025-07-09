# API Documentation

This document provides comprehensive information about the API endpoints, testing, and usage.

## API Overview

The Second Innings Backend provides a REST API built with FastAPI, featuring:

- **Authentication**: Firebase-based user authentication
- **Database Integration**: PostgreSQL with automated schema management
- **CORS Support**: Configured for cross-origin requests
- **Request Validation**: Pydantic-based request/response validation
- **Standardized Responses**: Consistent JSON response format

## Base URL

- **Development**: `http://localhost:8000`
- **API Prefix**: `/api`

## Authentication

The API uses Firebase ID tokens for authentication. Include the token in your requests to protected endpoints.

### Authentication Flow

1. Client obtains Firebase ID token
2. Client sends token to `/api/auth/verify-token`
3. Server verifies token and returns user information
4. Use returned data for subsequent authenticated requests

## API Endpoints

### Health Check

#### GET /
Returns a welcome message confirming the application is running.

**Response:**
```json
{
  "message": "Welcome to the FastAPI application"
}
```

### Authentication

#### POST /api/auth/verify-token
Verify Firebase ID token and authenticate user.

**Request Body:**
```json
{
  "id_token": "firebase_id_token_here"
}
```

**Success Response (200) - Existing User:**
```json
{
  "status_code": 200,
  "message": "User authenticated successfully.",
  "data": {
    "user": {
      "id": 1,
      "gmail_id": "user@gmail.com",
      "firebase_uid": "firebase_uid_here",
      "full_name": "User Name",
      "created_at": "2024-01-01T00:00:00",
      "updated_at": "2024-01-01T00:00:00"
    },
    "is_new_user": false
  }
}
```

**Success Response (201) - New User:**
```json
{
  "status_code": 201,
  "message": "User verified but not registered in system.",
  "data": {
    "user_info": {
      "firebase_uid": "firebase_uid_here",
      "gmail_id": "user@gmail.com",
      "full_name": "User Name"
    },
    "is_registered": false
  }
}
```

**Error Response (401) - Invalid Token:**
```json
{
  "status_code": 401,
  "message": "Authentication failed. Invalid token."
}
```

### Test Endpoints

#### GET /api/test
Returns a static test message.

**Response:**
```json
{
  "status_code": 200,
  "message": "Test data retrieved successfully.",
  "data": {
    "message": "This is a test message from the module."
  }
}
```

#### POST /api/items
Creates a new item in the database.

**Request Body:**
```json
{
  "name": "Item Name",
  "description": "Item Description",
  "price": 29.99,
  "tax": 2.10
}
```

**Success Response (201):**
```json
{
  "status_code": 201,
  "message": "Item created successfully.",
  "data": {
    "id": 1,
    "name": "Item Name",
    "description": "Item Description",
    "price": 29.99
  }
}
```

## Interactive Documentation

FastAPI automatically generates interactive API documentation:

- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

These interfaces allow you to:
- Explore all endpoints
- Test API calls directly
- View request/response schemas
- Understand authentication requirements

## Testing

### Bruno API Testing

The project uses [Bruno](https://usebruno.com/) for API testing and documentation.

#### Prerequisites

1. **Install Bruno CLI**:
   ```bash
   npm install -g @usebruno/cli
   ```

2. **Start the API server**:
   ```bash
   python main.py --init-db
   ```

#### Running Tests

**Run all tests:**
```bash
cd bruno/second-innings-backend
bru run --env Local
```

**Run specific test:**
```bash
cd bruno/second-innings-backend
bru run "Auth/POST_VerifyToken.bru" --env Local
```

**Available test files:**
- `Root/GET_HealthCheck.bru` - Health check endpoint
- `Test/GET_TestMessage.bru` - Test message endpoint
- `Test/POST_CreateItem.bru` - Item creation endpoint
- `Auth/POST_VerifyToken.bru` - Authentication endpoint

#### Test Configuration

Tests use the **Local** environment with:
- `baseUrl`: http://127.0.0.1:8000
- `apiPrefix`: /api

### Testing Philosophy

The project follows a **status code first** testing approach:
- ✅ **Primary focus**: HTTP status code validation (200, 201, 404, etc.)
- ✅ **Fast execution**: Minimal assertions for quick feedback
- ✅ **Reliable**: Less brittle than detailed response body testing
- ✅ **Essential validation**: Confirms endpoints respond correctly

## Error Handling

The API uses standardized error responses:

### Common HTTP Status Codes

- **200**: Success (GET requests)
- **201**: Created (POST requests)
- **400**: Bad Request (validation errors)
- **401**: Unauthorized (authentication failures)
- **404**: Not Found (resource doesn't exist)
- **500**: Internal Server Error (server-side issues)

### Error Response Format

```json
{
  "status_code": 400,
  "message": "Validation error message",
  "data": null
}
```

## Rate Limiting

Currently, no rate limiting is implemented. For production deployments, consider adding rate limiting middleware.

## CORS Configuration

The API is configured to allow cross-origin requests from all origins for development. In production, configure specific allowed origins for security.

## Database Schema

### Users Table
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    gmail_id VARCHAR(255) UNIQUE NOT NULL,
    firebase_uid VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Items Table
```sql
CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL
);
```
