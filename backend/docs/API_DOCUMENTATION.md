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

#### POST /api/auth/register
Register a new user with complete profile information.

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

#### POST /api/auth/register
Register a new user with complete profile information.

**Request Body:**
```json
{
  "id_token": "firebase_id_token_here",
  "full_name": "John Doe",
  "role": "caregiver",
  "youtube_url": "https://youtube.com/watch?v=example",
  "date_of_birth": "1990-01-15",
  "description": "I am a passionate cricket caregiver with 10 years of experience.",
  "tags": "cricket, rehabilitation, sports medicine, coaching"
}
```

**Available User Roles:**
- `admin` - System administrator
- `caregiver` - Professional caregiver/coach
- `family_member` - Family member of senior citizen
- `senior_citizen` - Senior citizen requiring care
- `interest_group_admin` - Administrator of interest groups
- `support_user` - Support staff member

**Field Requirements:**

**Common Fields (all roles):**
- `id_token` (string, required): Firebase ID token
- `full_name` (string, required): User's full name
- `role` (string, required): User role from available options above
- `date_of_birth` (date, optional): User's date of birth in YYYY-MM-DD format

**Role-Specific Requirements:**

**CAREGIVER role requires:**
- `youtube_url` (string, required): YouTube profile URL
- `description` (string, required): Professional description
- `tags` (string, required): Comma-separated skills/specialties

**All other roles (ADMIN, FAMILY_MEMBER, SENIOR_CITIZEN, INTEREST_GROUP_ADMIN, SUPPORT_USER):**
- Only common fields required (no additional requirements)

**Role-Based Examples:**

**Caregiver Registration:**
```json
{
  "id_token": "firebase_id_token_here",
  "full_name": "John Doe",
  "role": "caregiver",
  "youtube_url": "https://youtube.com/watch?v=example",
  "date_of_birth": "1990-01-15",
  "description": "Experienced cricket coach with sports rehabilitation expertise",
  "tags": "cricket, rehabilitation, sports medicine, coaching"
}
```

**Family Member Registration:**
```json
{
  "id_token": "firebase_id_token_here",
  "full_name": "Jane Smith",
  "role": "family_member",
  "date_of_birth": "1985-03-20"
}
```

**Senior Citizen Registration:**
```json
{
  "id_token": "firebase_id_token_here",
  "full_name": "Robert Johnson",
  "role": "senior_citizen",
  "date_of_birth": "1945-08-10"
}
```

**Admin Registration:**
```json
{
  "id_token": "firebase_id_token_here",
  "full_name": "Admin User",
  "role": "admin",
  "date_of_birth": "1980-12-05"
}
```

**Success Response (201) - User Registered:**
```json
{
  "status_code": 201,
  "message": "User registered successfully.",
  "data": {
    "user": {
      "id": 1,
      "gmail_id": "user@gmail.com",
      "firebase_uid": "firebase_uid_here",
      "full_name": "John Doe",
      "role": "caregiver",
      "youtube_url": "https://youtube.com/watch?v=example",
      "date_of_birth": "1990-01-15",
      "description": "I am a passionate cricket caregiver with 10 years of experience.",
      "tags": "cricket, rehabilitation, sports medicine, coaching",
      "created_at": "2024-01-01T00:00:00",
      "updated_at": "2024-01-01T00:00:00"
    },
    "message": "User registered successfully"
  }
}
```

**Error Response (401) - Invalid Token:**
```json
{
  "status_code": 401,
  "message": "Registration failed. Invalid token."
}
```

**Error Response (400) - Validation Error:**

*Example: Missing required caregiver fields:*
```json
{
  "status_code": 400,
  "message": "Validation error",
  "data": {
    "detail": [
      {
        "loc": ["body", "youtube_url"],
        "msg": "youtube_url is required for caregiver role",
        "type": "value_error"
      },
      {
        "loc": ["body", "description"],
        "msg": "description is required for caregiver role",
        "type": "value_error"
      },
      {
        "loc": ["body", "tags"],
        "msg": "tags is required for caregiver role",
        "type": "value_error"
      }
    ]
  }
}
```

**Error Response (409) - User Already Registered:**
```json
{
  "status_code": 409,
  "message": "User already registered."
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
- `Auth/POST_VerifyToken.bru` - Authentication endpoint
- `Auth/POST_RegisterUser.bru` - User registration endpoint

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
    youtube_url VARCHAR(500),
    date_of_birth DATE,
    description TEXT,
    tags TEXT,
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
