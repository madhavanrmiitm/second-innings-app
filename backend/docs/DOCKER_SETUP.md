# Docker Setup Guide

This document covers setting up the application using Docker containers.

## 🐳 Full Docker Setup

If you prefer to run everything in Docker containers, this section provides the complete Docker setup.

### Docker Prerequisites
- Docker and Docker Compose installed on your system
- No need for Python virtual environment when using full Docker

### Quick Start with Full Docker

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
POSTGRES_PASSWORD=secure_password GEMINI_API_KEY=your_api_key docker-compose -f docker-compose.prod.yml up --build -d
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
