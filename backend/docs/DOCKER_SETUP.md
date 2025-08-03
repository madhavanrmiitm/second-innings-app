# Docker Setup Guide - **PREFERRED FOR TESTING**

**🐳 Docker is the preferred method for running the backend for testing** as it provides a consistent, isolated environment with all dependencies pre-configured.

This document covers setting up the application using Docker containers.

## 🚀 Quick Start (Recommended for Testing)

### Why Docker is Preferred for Testing

- ✅ **Consistent Environment**: Same setup across all machines
- ✅ **No Local Dependencies**: No need to install Python, PostgreSQL locally
- ✅ **Isolated Testing**: Clean environment for each test run
- ✅ **Quick Setup**: One command to get everything running
- ✅ **Easy Reset**: Simple commands to reset database and start fresh
- ✅ **Reproducible**: Exact same environment every time

### 🐳 Full Docker Setup

If you prefer to run everything in Docker containers, this section provides the complete Docker setup.

#### Docker Prerequisites
- Docker and Docker Compose installed on your system
- No need for Python virtual environment when using full Docker

#### Quick Start with Full Docker

1. **Set up environment variables:**
   ```bash
   # Create .env file with required variables
   echo "GEMINI_API_KEY=your_gemini_api_key_here" > .env
   ```

2. **Start all services:**
   ```bash
   docker-compose up --build
   ```

   Or use the convenient script:
   ```bash
   chmod +x docker-start.sh
   ./docker-start.sh
   ```

3. **Access the application:**
   - API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs
   - PostgreSQL: localhost:5433 (development) / localhost:5432 (production)

4. **Default Admin Account:**

   A pre-configured admin account is automatically available:
   - **Email**: `21f3001600@ds.study.iitm.ac.in`
   - **Firebase UID**: `qEGg9NTOjfgSaw646IhSRCXKtaZ2`
   - **Full Name**: `Ashwin Narayanan S`
   - **Role**: `admin`
   - **Status**: `active`

5. **Stop the services:**
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
- **CORS**: Configured for cross-origin requests

**Environment Variables (Development):**
- Database: `fastapi_db`
- Username: `fastapi_user`
- Password: `fastapi_password`
- Database URL: `postgresql://fastapi_user:fastapi_password@db:5432/fastapi_db`
- Gemini API Key: Set via `GEMINI_API_KEY` environment variable (required for YouTube processing)

### Production Deployment

For production, use the production compose file with enhanced security:

```bash
POSTGRES_PASSWORD=your_secure_password GEMINI_API_KEY=your_gemini_api_key docker-compose -f docker-compose.prod.yml up --build -d
```

**Production differences:**
- **PostgreSQL**: Exposed on port 5432 (standard port)
- **No auto-reload**: Optimized for production performance
- **Environment-based password**: Uses `POSTGRES_PASSWORD` environment variable
- **No volume mounting**: Uses built Docker image for code

## 🔧 Docker Commands Reference

### Essential Commands for Testing

```bash
# Start services (development) - PREFERRED FOR TESTING
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
POSTGRES_PASSWORD=secure_password GEMINI_API_KEY=your_api_key docker-compose -f docker-compose.prod.yml up --build -d
```

### Testing-Specific Commands

```bash
# Quick reset for fresh testing
docker-compose down -v && docker-compose up --build

# View backend logs during testing
docker-compose logs -f backend

# Restart backend for code changes
docker-compose restart backend

# Check service status
docker-compose ps
```

## Docker Troubleshooting

### Common Issues

1. **Port conflicts**: Change ports in docker-compose.yml if needed
2. **Build failures**: Clear Docker cache with `docker system prune`
3. **Database connection**: Ensure containers are on same network
4. **Volume issues**: Remove volumes with `docker-compose down -v`

### Useful Docker Commands

```bash
# View running containers
docker ps

# View all containers
docker ps -a

# View Docker logs for specific service
docker-compose logs backend
docker-compose logs db

# Execute commands in running container
docker-compose exec backend bash
docker-compose exec db psql -U fastapi_user -d fastapi_db

# Remove all stopped containers
docker container prune

# Remove all unused images
docker image prune

# Remove all unused volumes
docker volume prune
```

## Health Checks

The Docker setup includes health checks for:

- **Database**: Checks PostgreSQL connectivity
- **Backend**: Monitors API endpoint availability

Health status can be viewed with:
```bash
docker-compose ps
```

## 🧪 Testing with Docker

### Running API Tests with Docker

1. **Start the backend with Docker:**
   ```bash
   docker-compose up --build
   ```

2. **Run Bruno API tests:**
   ```bash
   cd bruno/second-innings-backend
   bru run --env Local
   ```

3. **Test specific modules:**
   ```bash
   bru run Admin --env Local           # Admin functionality
   bru run Care --env Local            # Care management
   bru run Family --env Local          # Family member management
   bru run Tasks --env Local           # Task and reminder system
   bru run InterestGroups --env Local  # Interest group management
   bru run Tickets --env Local         # Support ticket system
   bru run Notifications --env Local   # Notification system
   bru run Auth --env Local            # Authentication system
   bru run User --env Local            # User profile management
   ```

### Benefits of Docker for Testing

- **Isolated Environment**: Each test run starts with a clean state
- **Consistent Setup**: Same environment across different machines
- **Easy Reset**: Simple commands to reset database and start fresh
- **No Conflicts**: No local Python/PostgreSQL version conflicts
- **Reproducible**: Exact same environment every time
