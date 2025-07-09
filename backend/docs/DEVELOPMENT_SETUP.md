# Development Setup Guide

This document provides detailed instructions for setting up the development environment.

## 💻 Recommended Development Setup

The recommended setup uses Python locally with Docker for PostgreSQL only. This provides the best development experience with excellent IDE integration and debugging capabilities.

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

## Command-Line Options

### Available Options

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

## Troubleshooting

### Common Issues

1. **Database connection errors**: Ensure PostgreSQL container is running
2. **Port conflicts**: Use different ports if 8000 or 5433 are in use
3. **Permission errors**: Make sure virtual environment is activated
4. **Import errors**: Verify all dependencies are installed

### Useful Commands

```bash
# Check if services are running
docker-compose ps

# View application logs
docker-compose logs backend

# Restart services
docker-compose restart

# Clean restart
docker-compose down && docker-compose up -d
```
