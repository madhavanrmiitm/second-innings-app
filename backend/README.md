# Second Innings Backend

This is a FastAPI project initialized with a modular structure, featuring standardized JSON responses, request validation, and database integration.

## Table of Contents

- [💻 Development Setup (Recommended)](#-development-setup-recommended)
  - [Prerequisites](#prerequisites)
  - [Quick Start](#quick-start)
  - [PostgreSQL with Docker](#postgresql-with-docker)
  - [Python Environment Setup](#python-environment-setup)
  - [Running the Application](#running-the-application-1)
- [🔧 Local Setup (No Docker)](#-local-setup-no-docker)
  - [Local Prerequisites](#local-prerequisites)
  - [PostgreSQL Installation](#postgresql-installation)
  - [Database Setup](#database-setup)
  - [Python Setup](#python-setup)
  - [Environment Configuration](#environment-configuration)
  - [Running Locally](#running-locally)
- [🐳 Full Docker Setup (Alternative)](#-full-docker-setup-alternative)
  - [Docker Prerequisites](#docker-prerequisites)
  - [Quick Start with Full Docker](#quick-start-with-full-docker)
  - [Docker Services](#docker-services)
  - [Development Environment](#development-environment)
  - [Production Deployment](#production-deployment)
  - [Docker Commands Reference](#docker-commands-reference)
- [Project Structure](#project-structure)
- [Features](#features)
- [Code Quality & Pre-commit Hooks](#code-quality--pre-commit-hooks)
  - [Setup Pre-commit Hooks](#setup-pre-commit-hooks)
  - [What Gets Checked](#what-gets-checked)
  - [Manual Run](#manual-run)
- [Database Initialization](#database-initialization)
- [Running the Application](#running-the-application)
  - [Basic Usage](#basic-usage)
  - [With Database Initialization](#with-database-initialization)
  - [Available Command-Line Options](#available-command-line-options)
  - [Examples](#examples)
  - [Alternative: Using uvicorn directly](#alternative-using-uvicorn-directly)
- [Testing](#testing)
  - [Testing Philosophy](#testing-philosophy)
  - [Bruno API Testing](#bruno-api-testing)
  - [Testing Workflow](#testing-workflow)
  - [Environment Configuration](#environment-configuration)
- [API Documentation](#api-documentation)
- [API Endpoints](#api-endpoints)
  - [Health Check](#health-check)
  - [Test Endpoints](#test-endpoints)

## 💻 Development Setup (Recommended)

The recommended development setup uses Python installed locally with Docker only for PostgreSQL. This approach provides the best development experience with excellent IDE integration and debugging capabilities.

### Prerequisites

- Python 3.8+ installed locally
- Docker and Docker Compose for PostgreSQL
- Git for version control

### Quick Start

1. **Start PostgreSQL with Docker:**
   ```bash
   docker-compose up db -d
   ```

2. **Set up Python environment:**
   ```bash
   # Create virtual environment
   python3 -m venv venv

   # Activate virtual environment
   source venv/bin/activate  # On macOS/Linux
   # venv\Scripts\activate   # On Windows

   # Install dependencies
   pip install -r requirements.txt
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env
   ```

   Update the `.env` file with these database credentials:
   ```env
   DATABASE_URL=postgresql://fastapi_user:fastapi_password@localhost:5433/fastapi_db
   ```

4. **Run the application:**
   ```bash
   python main.py --init-db --reload
   ```

5. **Access the application:**
   - API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs
   - PostgreSQL: localhost:5433

### PostgreSQL with Docker

The PostgreSQL database runs in Docker for consistency and easy setup:

```bash
# Start only PostgreSQL
docker-compose up db -d

# View PostgreSQL logs
docker-compose logs db

# Stop PostgreSQL
docker-compose stop db

# Reset PostgreSQL data
docker-compose down db -v
```

**Database Configuration:**
- Host: `localhost`
- Port: `5433`
- Database: `fastapi_db`
- Username: `fastapi_user`
- Password: `fastapi_password`
- Connection URL: `postgresql://fastapi_user:fastapi_password@localhost:5433/fastapi_db`

### Python Environment Setup

1. **Create and activate virtual environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On macOS/Linux
   # venv\Scripts\activate   # On Windows
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Install pre-commit hooks:**
   ```bash
   pre-commit install
   ```

### Running the Application

```bash
# Start with database initialization and auto-reload
python main.py --init-db --reload

# Or start without auto-reload
python main.py --init-db

# Alternative: using uvicorn directly
uvicorn main:app --reload
```

## 🔧 Local Setup (No Docker)

For developers who prefer a completely local setup without any Docker dependencies, this section provides instructions for setting up PostgreSQL and Python natively on your system.

### Local Prerequisites

- Python 3.8+ installed locally
- PostgreSQL 12+ installed locally
- Git for version control

### PostgreSQL Installation

#### macOS

**Using Homebrew (Recommended):**
```bash
# Install PostgreSQL
brew install postgresql@15

# Start PostgreSQL service
brew services start postgresql@15

# Add to PATH (add to your shell profile)
export PATH="/usr/local/opt/postgresql@15/bin:$PATH"
```

**Using PostgreSQL.app:**
1. Download from [PostgreSQL.app](https://postgresapp.com/)
2. Install and start the application
3. Add to PATH: `export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin`

#### Ubuntu/Debian

```bash
# Update package list
sudo apt update

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

#### Windows

1. Download PostgreSQL installer from [postgresql.org](https://www.postgresql.org/download/windows/)
2. Run the installer and follow the setup wizard
3. Remember the password you set for the `postgres` user
4. Add PostgreSQL bin directory to your PATH environment variable

#### CentOS/RHEL/Fedora

```bash
# Install PostgreSQL
sudo dnf install postgresql postgresql-server  # Fedora
# sudo yum install postgresql postgresql-server  # CentOS/RHEL

# Initialize database
sudo postgresql-setup initdb

# Start and enable service
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Database Setup

1. **Access PostgreSQL:**
   ```bash
   # Switch to postgres user (Linux/macOS)
   sudo -u postgres psql

   # Or directly connect (if PostgreSQL is in PATH)
   psql -U postgres
   ```

2. **Create database and user:**
   ```sql
   -- Create user
   CREATE USER fastapi_user WITH PASSWORD 'fastapi_password';

   -- Create database
   CREATE DATABASE fastapi_db OWNER fastapi_user;

   -- Grant privileges
   GRANT ALL PRIVILEGES ON DATABASE fastapi_db TO fastapi_user;

   -- Exit PostgreSQL
   \q
   ```

3. **Test connection:**
   ```bash
   psql -U fastapi_user -d fastapi_db -h localhost
   ```

### Python Setup

1. **Create and activate virtual environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On macOS/Linux
   # venv\Scripts\activate   # On Windows
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Install pre-commit hooks:**
   ```bash
   pre-commit install
   ```

### Environment Configuration

1. **Create environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Update the `.env` file with local database credentials:**
   ```env
   DATABASE_URL=postgresql://fastapi_user:fastapi_password@localhost:5432/fastapi_db
   ```

   **Note:** Use port `5432` (default PostgreSQL port) instead of `5433` when running PostgreSQL locally.

### Running Locally

1. **Ensure PostgreSQL is running:**
   ```bash
   # Check if PostgreSQL is running
   pg_isready -h localhost -p 5432

   # Start PostgreSQL if needed (macOS with Homebrew)
   brew services start postgresql@15

   # Start PostgreSQL if needed (Linux)
   sudo systemctl start postgresql
   ```

2. **Run the application:**
   ```bash
   # Start with database initialization and auto-reload
   python main.py --init-db --reload

   # Or without auto-reload
   python main.py --init-db

   # Alternative: using uvicorn directly
   uvicorn main:app --reload
   ```

3. **Access the application:**
   - API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs
   - PostgreSQL: localhost:5432

**Troubleshooting Local Setup:**

- **Connection refused:** Ensure PostgreSQL service is running
- **Authentication failed:** Verify username/password in `.env` file
- **Database does not exist:** Run the database setup commands again
- **Permission denied:** Check user privileges on the database

## 🐳 Full Docker Setup (Alternative)

If you prefer to run everything in Docker containers, this section provides the complete Docker setup.

### Docker Prerequisites
- Docker and Docker Compose installed on your system
- No need for Python virtual environment when using full Docker

### Quick Start with Full Docker

1. **Start all services:**
   ```bash
   docker-compose up --build
   ```

   Or use the convenient script:
   ```bash
   chmod +x docker-start.sh
   ./docker-start.sh
   ```

2. **Access the application:**
   - API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs
   - PostgreSQL: localhost:5433 (development) / localhost:5432 (production)

3. **Stop the services:**
   ```bash
   docker-compose down
   ```

### Docker Services

- **backend**: FastAPI application running on port 8000
- **db**: PostgreSQL 15 database with automatic health checks

### Development Environment

The default `docker-compose.yml` is configured for development with:

- **PostgreSQL**: Exposed on port 5433 (host) → 5432 (container)
- **Auto-reload**: Enabled for live code changes
- **Volume mounting**: Local code changes are reflected immediately
- **Database initialization**: Automatic on container startup

**Environment Variables (Development):**
- Database: `fastapi_db`
- Username: `fastapi_user`
- Password: `fastapi_password`
- Database URL: `postgresql://fastapi_user:fastapi_password@db:5432/fastapi_db`

### Production Deployment

For production, use the production compose file with enhanced security:

```bash
POSTGRES_PASSWORD=your_secure_password docker-compose -f docker-compose.prod.yml up --build -d
```

**Production differences:**
- **PostgreSQL**: Exposed on port 5432 (standard port)
- **No auto-reload**: Optimized for production performance
- **Environment-based password**: Uses `POSTGRES_PASSWORD` environment variable
- **No volume mounting**: Uses built Docker image for code

### Docker Commands Reference

```bash
# Start services (development)
docker-compose up --build

# Start in background
docker-compose up --build -d

# Stop services
docker-compose down

# View logs
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# Restart specific service
docker-compose restart backend

# Remove volumes (complete reset)
docker-compose down -v

# Production deployment
POSTGRES_PASSWORD=secure_password docker-compose -f docker-compose.prod.yml up --build -d
```

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

## Testing

This project includes comprehensive API testing using Bruno, focusing on status code validation for fast and reliable testing.

### Testing Philosophy

The project follows a **status code first** testing approach:
- ✅ **Primary focus**: HTTP status code validation (200, 201, 404, etc.)
- ✅ **Fast execution**: Minimal assertions for quick feedback
- ✅ **Reliable**: Less brittle than detailed response body testing
- ✅ **Essential validation**: Confirms endpoints respond correctly

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

#### Running Tests via CLI

**Run all tests:**
```bash
cd bruno/second-innings-backend
bru run --env Local
```

**Run specific test:**
```bash
cd bruno/second-innings-backend
bru run "Root/GET_HealthCheck.bru" --env Local
```

**Run from backend root:**
```bash
bru run bruno/second-innings-backend --env Local
```

**Available test files:**
- `Root/GET_HealthCheck.bru` - Health check endpoint (expects 200)
- `Test/GET_TestMessage.bru` - Test message endpoint (expects 200)
- `Test/POST_CreateItem.bru` - Item creation endpoint (expects 201)

#### Test Output Options

```bash
# Verbose output
bru run --env Local --reporter verbose

# Save results to file
bru run --env Local --output results.json

# Stop on first failure
bru run --env Local --bail

# Set custom timeout
bru run --env Local --timeout 5000
```

### Testing Workflow

1. **Start server**: `python main.py --init-db`
2. **Run tests**: `bru run bruno/second-innings-backend --env Local`
3. **Check results**: All tests should pass with correct status codes

### Environment Configuration

Tests use the **Local** environment with:
- `baseUrl`: http://127.0.0.1:8000
- `apiPrefix`: /api

Modify `bruno/second-innings-backend/environments/Local.bru` if your server runs on different host/port.

## API Documentation

This project includes comprehensive API documentation in two formats:

### 1. Interactive Swagger Documentation
FastAPI automatically generates interactive API documentation available at:
- **Swagger UI**: `http://127.0.0.1:8000/docs`
- **ReDoc**: `http://127.0.0.1:8000/redoc`

### 2. Bruno API Collection
The project includes working examples and documentation in the Bruno collection located in the `bruno/` directory.

**Using the Bruno Collection:**
1. **Install Bruno**: Download from [usebruno.com](https://usebruno.com/)
2. **Open Collection**: In Bruno, open the `bruno/second-innings-backend/` directory
3. **Start Testing**: The collection includes all endpoints with example requests and automated tests

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
