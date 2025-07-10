# Second Innings Backend - Bruno API Collection

This directory contains the Bruno API collection for testing and documenting the Second Innings Backend API.

## About Bruno

[Bruno](https://usebruno.com/) is a fast and Git-friendly open-source API client. Unlike other API clients, Bruno stores collections as plain text files in your filesystem, making them perfect for version control and collaboration.

## Collection Structure

```
bruno/second-innings-backend/
├── bruno.json                    # Collection configuration
├── environments/
│   └── Local.bru                # Local environment variables
├── Root/                        # Main app routes (from main.py)
│   └── GET_HealthCheck.bru      # GET / - Health check
├── Auth/                        # Authentication routes
│   ├── POST_VerifyToken.bru     # POST /api/auth/verify-token - Token verification
│   └── POST_RegisterUser.bru    # POST /api/auth/register - User registration
└── README.md                    # This file
```

**Organization:**
- **One folder per controller** - Each controller file gets its own folder
- **One file per route** - Each API endpoint gets its own `.bru` file with working example
- **Method-first naming** - `METHOD_PurposeInThisCase` format (e.g., `GET_HealthCheck`)
- **Status code focused testing** - Simple, fast tests validating HTTP response codes

## Prerequisites

1. **Install Bruno**: Download from [usebruno.com](https://usebruno.com/) or install via package manager:
   ```bash
   # macOS
   brew install bruno

   # Windows (via Chocolatey)
   choco install bruno

   # Or download the installer from the website
   ```

2. **Start the API server**: Make sure your FastAPI server is running:
   ```bash
   # From the backend directory
   python main.py
   # or with database initialization
   python main.py --init-db
   ```

## Usage

### Opening the Collection

1. Open Bruno
2. Click "Open Collection"
3. Navigate to the `bruno/second-innings-backend` directory
4. Select the directory (Bruno will detect the `bruno.json` file)

### Environment Configuration

The collection includes a **Local** environment with the following variables:
- `baseUrl`: http://127.0.0.1:8000
- `apiPrefix`: /api

If your server runs on a different host/port, you can:
1. Modify the environment variables in Bruno
2. Or create a new environment for your specific setup

### Running Requests

**Available requests:**
1. **GET_HealthCheck**: Test if the server is running
2. **POST_VerifyToken**: Verify Firebase authentication tokens
3. **POST_RegisterUser**: Register new users with role-based validation

### Running Tests

Each request includes automated tests focused on **status code validation**:
- HTTP status codes (200, 201, 404, etc.)
- Fast execution with minimal assertions
- Essential endpoint verification without brittle response body checks

Click the "Send" button to execute requests and see the test results.

### Command Line Testing

You can also run tests via Bruno CLI:

```bash
# Install Bruno CLI
npm install -g @usebruno/cli

# Run all tests
bru run --env Local

# Run specific test
bru run "Auth/POST_VerifyToken.bru" --env Local

# Run with verbose output
bru run --env Local --reporter verbose
```

## API Endpoints Documentation

### GET /
- **Purpose**: Health check endpoint
- **Response**: Welcome message
- **Status**: 200 OK

### POST /api/auth/verify-token
- **Purpose**: Verify Firebase ID tokens and authenticate users
- **Request Body**: JSON with id_token
- **Success Response**: 200 (existing user) or 201 (new user)
- **Error Responses**: 401 (invalid token)

### POST /api/auth/register
- **Purpose**: Register new users with role-based profile data
- **Request Body**: JSON with user details and role-specific requirements
- **Success Response**: 201 Created with user data
- **Error Responses**: 400 (validation), 409 (already registered), 401 (invalid token)

## Extending the Collection

**For new controllers:**
1. Create a new folder (e.g., `User/`, `Activity/`, `Group/`)
2. Add `.bru` files for each route in that controller

**For new routes in existing controllers:**
1. Add a new `.bru` file in the appropriate folder
2. Use naming: `METHOD_PurposeInThisCase.bru` (e.g., `GET_UserProfile.bru`, `POST_CreateActivity.bru`)
3. Include only working examples with valid request/response data
4. Focus tests on status code validation for reliability

**Testing Guidelines:**
- **Primary test**: Always include status code validation
- **Keep it simple**: Avoid complex response body assertions
- **Fast execution**: Minimal tests for quick feedback
- **Essential validation**: Confirm endpoint responds correctly

Example test structure:
```javascript
tests {
  test("Status code is 200", function() {
    expect(res.getStatus()).to.equal(200);
  });
}
```

## Tips

- Use Bruno's **Environment Variables** for different deployment environments (dev, staging, prod)
- Leverage **Pre-request Scripts** for authentication or dynamic data generation
- **Focus on status codes** for reliable, maintainable tests
- Export/import collections for sharing with team members
- Use CLI for automated testing in CI/CD pipelines
