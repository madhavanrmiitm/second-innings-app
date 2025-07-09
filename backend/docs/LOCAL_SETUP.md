# Local Setup Guide (No Docker)

This document provides instructions for setting up the application completely locally without any Docker dependencies.

## 🔧 Local Setup Prerequisites

- Python 3.8+ installed locally
- PostgreSQL 12+ installed locally
- Git for version control

## PostgreSQL Installation

### macOS

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

### Ubuntu/Debian

```bash
# Update package list
sudo apt update

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Windows

1. Download PostgreSQL installer from [postgresql.org](https://www.postgresql.org/download/windows/)
2. Run the installer and follow the setup wizard
3. Remember the password you set for the `postgres` user
4. Add PostgreSQL bin directory to your PATH environment variable

### CentOS/RHEL/Fedora

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

## Database Setup

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

## Python Setup

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

## Environment Configuration

1. **Create environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Update the `.env` file with local database credentials:**
   ```env
   DATABASE_URL=postgresql://fastapi_user:fastapi_password@localhost:5432/fastapi_db
   FIREBASE_ADMIN_SDK_PATH=second-innings-iitm-firebase-adminsdk-fbsvc-3521fdd41b.json
   ```

   **Note:** Use port `5432` (default PostgreSQL port) instead of `5433` when running PostgreSQL locally.

## Running Locally

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

## Troubleshooting Local Setup

### Common Issues

- **Connection refused:** Ensure PostgreSQL service is running
- **Authentication failed:** Verify username/password in `.env` file
- **Database does not exist:** Run the database setup commands again
- **Permission denied:** Check user privileges on the database
- **Port in use:** Change the port in your run command
- **Python module errors:** Ensure virtual environment is activated

### PostgreSQL Management Commands

```bash
# Start PostgreSQL (macOS with Homebrew)
brew services start postgresql@15

# Stop PostgreSQL (macOS with Homebrew)
brew services stop postgresql@15

# Restart PostgreSQL (macOS with Homebrew)
brew services restart postgresql@15

# Start PostgreSQL (Linux)
sudo systemctl start postgresql

# Stop PostgreSQL (Linux)
sudo systemctl stop postgresql

# Check PostgreSQL status (Linux)
sudo systemctl status postgresql

# View PostgreSQL logs (Linux)
sudo journalctl -u postgresql
```

### Database Management

```bash
# Connect to database
psql -U fastapi_user -d fastapi_db -h localhost

# List databases
psql -U postgres -l

# Drop and recreate database (if needed)
psql -U postgres -c "DROP DATABASE fastapi_db;"
psql -U postgres -c "CREATE DATABASE fastapi_db OWNER fastapi_user;"
```
