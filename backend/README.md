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
   # Update the following in .env file:
   # - DATABASE_URL: PostgreSQL connection string
   # - GEMINI_API_KEY: Google Gemini AI API key for YouTube processing
   ```

4. **Run the application:**
   ```bash
   python main.py --init-db --reload
   ```

5. **Access:**
   - API: http://localhost:8000
   - Docs: http://localhost:8000/docs

## 🔑 Default Admin Account

The database schema includes a default admin account for immediate system access:
- **Email**: 21f3001600@ds.study.iitm.ac.in
- **Firebase UID**: qEGg9NTOjfgSaw646IhSRCXKtaZ2
- **Full Name**: Ashwin Narayanan S
- **Role**: admin
- **Status**: active

This account is automatically created when the database is initialized.

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
│   │   └── user.py           # User profile controller
│   ├── database/             # Database configuration and schema
│   │   ├── db.py            # Database connection management
│   │   ├── init_db.py       # Database initialization
│   │   └── schema.sql       # Database schema with user roles, status, and default admin
│   ├── modules/              # Business logic modules
│   │   ├── auth/            # Authentication module
│   │   │   └── auth_service.py  # Firebase authentication service
│   │   └── youtube/         # YouTube processing module
│   │       └── youtube_processor.py  # AI-powered video analysis for content generation
│   ├── routes/               # API route definitions
│   │   ├── auth.py          # Authentication routes
│   │   └── user.py          # User profile routes
│   ├── utils/                # Utility functions
│   │   ├── request_validator.py   # Request validation decorators
│   │   └── response_formatter.py  # Standardized response formatting
│   ├── config.py             # Application configuration
│   ├── logger.py             # Logging configuration
│   └── payloads.py           # Pydantic models and schemas
├── bruno/                    # API testing collection
│   └── second-innings-backend/
│       ├── Auth/             # Authentication API tests
│       ├── User/             # User profile API tests
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
- **👤 User Profile Management**: Secure profile retrieval with role-based access control
- **👑 Default Admin Access**: Pre-configured admin account for immediate system administration
- **📊 Status-Based Approval System**: Automatic status assignment with pending approval for caregivers and interest group admins
- **🏗️ Modular Architecture**: Clean separation of controllers, services, routes, and utilities
- **📊 Database Integration**: PostgreSQL with automated schema management, connection pooling, and default admin account
- **🤖 AI-Powered Content Generation**: Automatic tag and description generation for caregiver and interest group admin profiles using Google Gemini AI and YouTube URLs
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

# Docker development (ensure GEMINI_API_KEY is set in .env file)
docker-compose up --build

# Production deployment
POSTGRES_PASSWORD=secure_pass GEMINI_API_KEY=your_api_key docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose logs -f backend
```

## 🔗 Key API Endpoints

- **Health Check**: `GET /` - Application status
- **Authentication**: `POST /api/auth/verify-token` - Firebase token verification
- **User Registration**: `POST /api/auth/register` - Complete user registration with profile and status assignment
- **User Profile**: `POST /api/user/profile` - Retrieve user profile information
- **API Documentation**: `http://localhost:8000/docs` - Interactive Swagger UI

## 🤝 Contributing

1. Follow the [Development Setup](docs/DEVELOPMENT_SETUP.md) guide
2. Create feature branches from `main`
3. Write tests for new endpoints in Bruno collection
4. Ensure pre-commit hooks pass
5. Submit pull requests with clear descriptions

## 📄 License

This project is part of the Second Innings IITM software engineering coursework.
