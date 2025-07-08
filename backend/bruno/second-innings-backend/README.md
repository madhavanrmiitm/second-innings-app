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
│   └── Get Health Check.bru     # GET / - Health check
├── Test/                        # Test controller routes
│   ├── Get Test Message.bru     # GET /api/test - Test message
│   └── Post Create Item.bru     # POST /api/items - Create item
└── README.md                    # This file
```

**Organization:**
- **One folder per controller** - Each controller file gets its own folder
- **One file per route** - Each API endpoint gets its own `.bru` file with working example
- **Simple naming** - HTTP method prefix + descriptive name
- **Sequential numbering** - Routes numbered across all folders for order

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

**Root controller:**
1. **Get Health Check**: Test if the server is running

**Test controller:**
2. **Get Test Message**: Verify the test endpoint functionality
3. **Post Create Item**: Test item creation with valid data

### Running Tests

Each request includes automated tests that verify:
- Response status codes
- Response body structure
- Expected data values

Click the "Send" button to execute requests and see the test results.

## API Endpoints Documentation

### GET /
- **Purpose**: Health check endpoint
- **Response**: Welcome message
- **Status**: 200 OK

### GET /api/test
- **Purpose**: Returns test data from the test module
- **Response**: Standardized JSON with test message
- **Status**: 200 OK

### POST /api/items
- **Purpose**: Create a new item in the database
- **Request Body**: JSON with name, description, price, and optional tax
- **Success Response**: 201 Created with item data
- **Error Responses**:
  - 422 Unprocessable Entity (validation errors)
  - 500 Internal Server Error (database errors)

## Database Requirements

For the `POST /api/items` endpoint to work properly:
1. Ensure PostgreSQL is running
2. Configure your `.env` file with correct database credentials
3. Initialize the database schema using `python main.py --init-db`

## Extending the Collection

**For new controllers:**
1. Create a new folder (e.g., `User/`, `Product/`)
2. Add `.bru` files for each route in that controller

**For new routes in existing controllers:**
1. Add a new `.bru` file in the appropriate folder
2. Use naming: `{HTTP Method} {Route Name}.bru`
3. Update sequence numbers to maintain order
4. Include only working examples with valid request/response data

## Tips

- Use Bruno's **Environment Variables** for different deployment environments (dev, staging, prod)
- Leverage **Pre-request Scripts** for authentication or dynamic data generation
- Utilize **Tests** to ensure API reliability and catch regressions
- Export/import collections for sharing with team members
