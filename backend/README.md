# Second Innings Backend

This is a FastAPI project initialized with a modular structure, featuring standardized JSON responses, request validation, and database integration.

## Project Structure

```
backend/
├── app/
│   ├── controllers/
│   │   └── test.py
│   ├── database/
│   │   ├── db.py
│   │   ├── init_db.py
│   │   └── schema.sql
│   ├── modules/
│   │   └── test/
│   │       └── test.py
│   ├── routes/
│   │   └── test.py
│   ├── utils/
│   │   ├── request_validator.py
│   │   └── response_formatter.py
│   └── payloads.py
├── bruno/
│   └── second-innings-backend/
│       ├── bruno.json
│       ├── environments/
│       │   └── Local.bru
│       ├── Root/
│       │   └── Get Health Check.bru
│       ├── Test/
│       │   ├── Get Test Message.bru
│       │   └── Post Create Item.bru
│       └── README.md
├── main.py
├── requirements.txt
├── .env.example
└── README.md
```

## Features

-   **Modular Architecture**: Code is organized into `controllers`, `modules`, `routes`, and `utils`.
-   **Database Initialization**: Easily set up the database schema using command-line flags.
-   **Standardized Responses**: A utility function formats all API responses for consistency.
-   **Request Validation**: A decorator validates incoming request bodies against Pydantic models.
-   **Comprehensive API Documentation**: Includes both FastAPI's interactive docs and Bruno API collection.
-   **Command-Line Interface**: Server configuration through command-line arguments.
-   **Code Quality**: Pre-commit hooks with Black formatter, isort, and file hygiene checks.
-   **Dependency Management**: All required packages are listed in `requirements.txt`.

## Setup

1.  **Create a virtual environment:**

    ```bash
    python3 -m venv venv
    ```

2.  **Activate the virtual environment:**

    -   On macOS and Linux:
        ```bash
        source venv/bin/activate
        ```
    -   On Windows:
        ```bash
        venv\\Scripts\\activate
        ```

3.  **Install dependencies:**

    ```bash
    pip install -r requirements.txt
    ```

4.  **Set up environment variables:**

    Create a `.env` file by copying the example:

    ```bash
    cp .env.example .env
    ```

    Update the `.env` file with your PostgreSQL database credentials.

## Code Quality & Pre-commit Hooks

This project uses pre-commit hooks to maintain code quality and consistency.

### Setup Pre-commit Hooks

The hooks are automatically installed when you install the development dependencies:

```bash
pip install -r requirements.txt
pre-commit install
```

### What Gets Checked

- **Black**: Automatically formats Python code with consistent style
- **isort**: Sorts and organizes imports
- **File hygiene**: Removes trailing whitespace, fixes end-of-file newlines
- **YAML/JSON validation**: Checks syntax of configuration files
- **Large file detection**: Prevents accidentally committing large files

### Manual Run

You can run all hooks manually on all files:

```bash
pre-commit run --all-files
```

Or run on staged files only:

```bash
pre-commit run
```

The hooks will run automatically on every `git commit` and will prevent commits if any checks fail.

## Database Initialization

The application includes a command-line flag to initialize the database schema on startup. This will execute the SQL commands in `app/database/schema.sql`.

## Running the Application

### Basic Usage

To run the FastAPI application with default settings:

```bash
python main.py
```

### With Database Initialization

To run the application and initialize the database schema on startup:

```bash
python main.py --init-db
```

### Available Command-Line Options

```bash
python main.py [OPTIONS]
```

**Options:**
- `--init-db`: Initialize database schema from schema.sql on startup
- `--host HOST`: Host to bind the server to (default: 127.0.0.1)
- `--port PORT`: Port to bind the server to (default: 8000)
- `--reload`: Enable auto-reload for development

### Examples

```bash
# Run with database initialization
python main.py --init-db

# Run on a different host and port
python main.py --host 0.0.0.0 --port 8080

# Run with auto-reload for development
python main.py --reload

# Combine multiple options
python main.py --init-db --host 0.0.0.0 --port 8080 --reload
```

### Alternative: Using uvicorn directly

You can still run the application using uvicorn directly (without command-line flags):

```bash
uvicorn main:app --reload
```

**Note:** When using uvicorn directly, database initialization must be done separately by running:

```bash
python app/database/init_db.py
```

The application will be available at `http://127.0.0.1:8000` (or your specified host:port).

You can access the interactive API documentation at `http://127.0.0.1:8000/docs`.

## API Documentation

This project includes comprehensive API documentation in two formats:

### 1. Interactive Swagger Documentation
FastAPI automatically generates interactive API documentation available at:
- **Swagger UI**: `http://127.0.0.1:8000/docs`
- **ReDoc**: `http://127.0.0.1:8000/redoc`

### 2. Bruno API Collection
The project includes a [Bruno](https://usebruno.com/) API collection for testing and documentation located in the `bruno/` directory.

**What is Bruno?**
Bruno is a fast, open-source API client that stores collections as plain text files, making them perfect for version control and team collaboration.

**Using the Bruno Collection:**
1. **Install Bruno**: Download from [usebruno.com](https://usebruno.com/)
2. **Open Collection**: In Bruno, open the `bruno/second-innings-backend/` directory
3. **Start Testing**: The collection includes all endpoints with example requests, documentation, and automated tests

**Collection Features:**
- ✅ **Simple organization** - One folder per controller, one file per route
- ✅ **All API endpoints documented** with working examples only
- ✅ **Environment variables** for easy configuration (local/dev/prod)
- ✅ **Automated tests** for each endpoint to verify functionality
- ✅ **HTTP method prefixes** for clear route identification
- ✅ **Clean and minimal** - No error scenarios, just working examples

For detailed instructions, see [`bruno/second-innings-backend/README.md`](bruno/second-innings-backend/README.md).

## API Endpoints

### Health Check

-   **GET /**: Returns a welcome message confirming the application is running.

### Test Endpoints

-   **GET /api/test**: Returns a static test message.
-   **POST /api/items**: Creates a new item in the database.
    -   **Request Body**:
        ```json
        {
            "name": "string",
            "description": "string",
            "price": 0.0
        }
        ```
    -   **Success Response (201)**:
        ```json
        {
            "message": "Item created successfully.",
            "data": {
                "id": 1,
                "name": "string",
                "description": "string",
                "price": 0.0
            }
        }
        ```
    -   **Validation Error Response (422)**:
        ```json
        {
            "message": "Validation Error",
            "data": [
                {
                    "loc": ["body", "field_name"],
                    "msg": "error message",
                    "type": "error_type"
                }
            ]
        }
        ```
