# Second Innings Backend

A FastAPI-based backend with Firebase authentication, PostgreSQL database, and modular architecture.

## ⚡ Quick Start

### Recommended Setup (Python + Docker for DB)

1. **Start PostgreSQL:**
   ```bash
   docker-compose up db -d
   ```

2. **Setup Python environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On macOS/Linux
   pip install -r requirements.txt
   ```

3. **Configure environment:**
   ```bash
   cp .env.example .env
   # Update DATABASE_URL in .env file
   ```

4. **Run the application:**
   ```bash
   python main.py --init-db --reload
   ```

5. **Access:**
   - API: http://localhost:8000
   - Docs: http://localhost:8000/docs

## 📚 Documentation

- **[Development Setup](docs/DEVELOPMENT_SETUP.md)** - Recommended development environment
- **[Docker Setup](docs/DOCKER_SETUP.md)** - Full Docker containerization
- **[Local Setup](docs/LOCAL_SETUP.md)** - Local setup without Docker
- **[API Documentation](docs/API_DOCUMENTATION.md)** - Complete API reference

## 🏗️ Project Structure

```
backend/
├── app/
│   ├── controllers/           # Request handlers and business logic
│   │   ├── auth.py           # Authentication controller
│   │   └── test.py           # Test endpoints controller
│   ├── database/             # Database configuration and schema
│   │   ├── db.py            # Database connection management
│   │   ├── init_db.py       # Database initialization
│   │   └── schema.sql       # Database schema (users, items tables)
│   ├── modules/              # Business logic modules
│   │   ├── auth/            # Authentication module
│   │   │   ├── __init__.py
│   │   │   └── auth_service.py  # Firebase authentication service
│   │   └── test/            # Test module
│   │       └── test.py
│   ├── routes/               # API route definitions
│   │   ├── auth.py          # Authentication routes
│   │   └── test.py          # Test routes
│   ├── utils/                # Utility functions
│   │   ├── request_validator.py   # Request validation decorators
│   │   └── response_formatter.py  # Standardized response formatting
│   ├── config.py             # Application configuration
│   ├── logger.py             # Logging configuration
│   └── payloads.py           # Pydantic models and schemas
├── bruno/                    # API testing collection
│   └── second-innings-backend/
│       ├── Auth/             # Authentication API tests
│       ├── Test/             # Test endpoint API tests
│       └── Root/             # Health check tests
├── docs/                     # Documentation files
│   ├── API_DOCUMENTATION.md
│   ├── DEVELOPMENT_SETUP.md
│   ├── DOCKER_SETUP.md
│   └── LOCAL_SETUP.md
├── main.py                   # Application entry point
├── requirements.txt          # Python dependencies
├── docker-compose.yml        # Development Docker configuration
├── docker-compose.prod.yml   # Production Docker configuration
├── second-innings-iitm-firebase-adminsdk-fbsvc-3521fdd41b.json  # Firebase Admin SDK
└── README.md                 # This file
```

## ✨ Features

- **🔐 Firebase Authentication**: Complete Firebase ID token verification with user management
- **🏗️ Modular Architecture**: Clean separation of controllers, services, routes, and utilities
- **📊 Database Integration**: PostgreSQL with automated schema management and connection pooling
- **🌐 CORS Support**: Configured for cross-origin requests from web and mobile clients
- **📝 Request Validation**: Pydantic-based request/response validation with automatic OpenAPI docs
- **🔄 Standardized Responses**: Consistent JSON response format across all endpoints
- **🧪 Comprehensive Testing**: Bruno API collection with automated status code validation
- **📋 Code Quality**: Pre-commit hooks with Black formatter, isort, and linting
- **🐳 Container Ready**: Docker support for both development and production deployments
- **⚙️ CLI Interface**: Command-line options for database initialization and server configuration

## 🔧 Quick Commands

```bash
# Development with auto-reload
python main.py --init-db --reload

# Run tests
bru run bruno/second-innings-backend --env Local

# Docker development
docker-compose up --build

# Production deployment
POSTGRES_PASSWORD=secure_pass docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose logs -f backend
```

## 🔗 Key API Endpoints

- **Health Check**: `GET /` - Application status
- **Authentication**: `POST /api/auth/verify-token` - Firebase token verification
- **Test Endpoints**: `GET /api/test`, `POST /api/items` - Testing and examples
- **API Docs**: `http://localhost:8000/docs` - Interactive documentation

## 🤝 Contributing

1. Follow the [Development Setup](docs/DEVELOPMENT_SETUP.md) guide
2. Create feature branches from `main`
3. Write tests for new endpoints in Bruno collection
4. Ensure pre-commit hooks pass
5. Submit pull requests with clear descriptions

## 📄 License

This project is part of the Second Innings IITM software engineering coursework.
