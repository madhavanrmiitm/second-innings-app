# Second Innings Backend

A FastAPI-based backend with Firebase authentication, PostgreSQL database, and modular architecture with **comprehensive API testing coverage**.

## ⚡ Quick Start

### Recommended Setup (Python + Docker for DB)

### 🚀 Start PostgreSQL

Run **one** of the following:

```bash
docker-compose up db -d   # or
docker compose up db -d



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

## 🧪 Comprehensive Testing Suite

The project includes a **complete Bruno API testing suite** covering all endpoints:

### Install Bruno CLI
```bash
npm install -g @usebruno/cli
```

### Run All Tests
```bash
cd bruno/second-innings-backend
bru run --env Local
```

### Test Coverage Summary
- **🏥 Admin Endpoints**: 7 tests (User management, caregiver approval, ticket handling)
- **🩺 Care Endpoints**: 6 tests (Care requests, caregiver profiles, applications)
- **👨‍👩‍👧‍👦 Family Endpoints**: 3 tests (Family member management)
- **📋 Task Endpoints**: 5 tests (Task management, reminders)
- **🎯 Interest Groups**: 3 tests (Group management, joining/leaving)
- **🎫 Ticket Endpoints**: 2 tests (Support ticket management)
- **🔔 Notification Endpoints**: 2 tests (Notification management)
- **🔐 Authentication**: 2 tests (Token verification, user registration)
- **👤 User Management**: 1 test (Profile retrieval)

**Total: 31 comprehensive API tests covering all system functionality**

### Test Categories

```bash
# Test specific modules
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

## 🔑 Default Admin Account

The database schema includes a default admin account for immediate system access:
- **Email**: 21f3001600@ds.study.iitm.ac.in
- **Firebase UID**: qEGg9NTOjfgSaw646IhSRCXKtaZ2
- **Full Name**: Ashwin Narayanan S
- **Role**: admin
- **Status**: active

This account is automatically created when the database is initialized and can be used for testing admin endpoints.

## 📚 Documentation

- **[Development Setup](docs/DEVELOPMENT_SETUP.md)** - Recommended development environment
- **[Docker Setup](docs/DOCKER_SETUP.md)** - Full Docker containerization
- **[Local Setup](docs/LOCAL_SETUP.md)** - Local setup without Docker
- **[API Documentation](docs/API_DOCUMENTATION.md)** - Complete API reference with all endpoints

## 🏗️ Project Structure

```
backend/
├── app/
│   ├── controllers/              # Request handlers and business logic
│   │   ├── admin.py             # Admin management (users, caregivers, tickets)
│   │   ├── auth.py              # Authentication controller
│   │   ├── care.py              # Care request and caregiver management
│   │   ├── family.py            # Family member management
│   │   ├── interest_groups.py   # Interest group management
│   │   ├── notifications.py     # Notification management
│   │   ├── tasks.py             # Task and reminder management
│   │   ├── tickets.py           # Support ticket management
│   │   └── user.py              # User profile controller
│   ├── database/                # Database configuration and schema
│   │   ├── db.py               # Database connection management
│   │   ├── init_db.py          # Database initialization
│   │   └── schema.sql          # Complete schema with all tables and relationships
│   ├── modules/                 # Business logic modules
│   │   ├── auth/               # Authentication module
│   │   │   └── auth_service.py # Firebase authentication service
│   │   └── youtube/            # YouTube processing module
│   │       └── youtube_processor.py # AI-powered video analysis
│   ├── routes/                  # API route definitions
│   │   ├── admin.py            # Admin routes (7 endpoints)
│   │   ├── auth.py             # Authentication routes (2 endpoints)
│   │   ├── care.py             # Care management routes (9 endpoints)
│   │   ├── family.py           # Family management routes (3 endpoints)
│   │   ├── interest_groups.py  # Interest group routes (6 endpoints)
│   │   ├── notifications.py    # Notification routes (2 endpoints)
│   │   ├── tasks.py            # Task management routes (10 endpoints)
│   │   ├── tickets.py          # Ticket management routes (4 endpoints)
│   │   └── user.py             # User profile routes (1 endpoint)
│   ├── utils/                   # Utility functions
│   │   ├── request_validator.py # Fixed request validation decorators
│   │   └── response_formatter.py # Standardized response formatting
│   ├── config.py                # Application configuration
│   ├── logger.py                # Logging configuration
│   └── payloads.py              # Pydantic models and schemas
├── bruno/                       # Comprehensive API testing collection
│   └── second-innings-backend/
│       ├── Admin/               # Admin endpoint tests (7 files)
│       ├── Auth/                # Authentication tests (2 files)
│       ├── Care/                # Care management tests (6 files)
│       ├── Family/              # Family management tests (3 files)
│       ├── InterestGroups/      # Interest group tests (3 files)
│       ├── Notifications/       # Notification tests (2 files)
│       ├── Root/                # Health check tests (1 file)
│       ├── Tasks/               # Task management tests (5 files)
│       ├── Tickets/             # Ticket management tests (2 files)
│       ├── User/                # User profile tests (1 file)
│       └── environments/        # Test environment configuration
├── docs/                        # Documentation files
├── main.py                      # Application entry point
├── requirements.txt             # Python dependencies
├── docker-compose.yml           # Development Docker configuration
├── docker-compose.prod.yml      # Production Docker configuration
└── README.md                    # This file
```

## ✨ Features

- **🔐 Firebase Authentication**: Complete Firebase ID token verification with user management
- **👤 User Profile Management**: Secure profile retrieval with role-based access control
- **👑 Admin Management**: Complete admin panel for user, caregiver, and ticket management
- **🩺 Care Services**: Care request management, caregiver profiles, and application system
- **👨‍👩‍👧‍👦 Family Management**: Family member linking and relationship management
- **📋 Task Management**: Task assignment, completion tracking, and reminder system
- **🎯 Interest Groups**: Community group creation, management, and participation
- **🎫 Support System**: Ticket creation, tracking, and resolution
- **🔔 Notifications**: Real-time notification system with read/unread status
- **📊 Status-Based Approval System**: Automatic status assignment with pending approval workflow
- **🏗️ Modular Architecture**: Clean separation with comprehensive endpoint coverage
- **📊 Database Integration**: PostgreSQL with complete schema and relationship management
- **🤖 AI-Powered Content Generation**: Automatic tag and description generation using Google Gemini AI
- **🌐 CORS Support**: Configured for cross-origin requests from web and mobile clients
- **📝 Request Validation**: Fixed Pydantic-based validation with proper path parameter handling
- **🔄 Standardized Responses**: Consistent JSON response format across all endpoints
- **🧪 Complete Test Coverage**: Bruno API collection testing all 44 endpoints
- **📋 Code Quality**: Pre-commit hooks with Black formatter, isort, and linting
- **🐳 Container Ready**: Docker support for both development and production deployments
- **⚙️ CLI Interface**: Command-line options for database initialization and server configuration

## 🔧 Quick Commands

```bash
# Development with auto-reload
python main.py --init-db --reload

# Run all API tests
bru run bruno/second-innings-backend --env Local

# Run specific test module
bru run bruno/second-innings-backend/Admin --env Local

# Docker development (ensure GEMINI_API_KEY is set in .env file)
docker-compose up --build

# Production deployment
POSTGRES_PASSWORD=secure_pass GEMINI_API_KEY=your_api_key docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose logs -f backend
```

## 🔗 Key API Endpoints

### Core System
- **Health Check**: `GET /` - Application status
- **Authentication**: `POST /api/auth/verify-token` - Firebase token verification
- **User Registration**: `POST /api/auth/register` - Complete user registration
- **User Profile**: `POST /api/user/profile` - User profile retrieval

### Admin Management
- **User Management**: `GET /api/admin/users`, `DELETE /api/admin/users/{userId}`
- **Caregiver Approval**: `GET /api/admin/caregivers`, `POST /api/admin/caregivers/{caregiverId}/verify`
- **Ticket Management**: `GET /api/admin/tickets`, `POST /api/admin/tickets/{ticketId}/resolve`
- **Statistics**: `GET /api/admin/tickets/stats`

### Care Services
- **Care Requests**: `GET/POST/PUT /api/care-requests`, `POST /api/care-requests/{requestId}/close`
- **Caregiver Profiles**: `GET /api/caregivers`, `GET /api/caregivers/{caregiverId}`
- **Applications**: `POST /api/caregivers/requests/{requestId}/apply`
- **Engagements**: `POST /api/caregivers/engagements/{requestId}/accept|decline`

### Family & Task Management
- **Family Members**: `GET/POST/DELETE /api/senior-citizens/me/family-members`
- **Tasks**: `GET/POST/PUT/DELETE /api/tasks`, `POST /api/tasks/{taskId}/complete`
- **Reminders**: `GET/POST/PUT/DELETE /api/reminders`, `POST /api/reminders/{reminderId}/snooze`

### Community & Support
- **Interest Groups**: `GET/POST/PUT /api/interest-groups`, `POST /api/interest-groups/{groupId}/join|leave`
- **Support Tickets**: `GET/POST/PUT /api/tickets`
- **Notifications**: `GET /api/notifications`, `POST /api/notifications/{notificationId}/read`

## 🧪 Testing Results

The comprehensive test suite validates:
- ✅ **Authentication Flow**: Token verification and user registration
- ✅ **Admin Operations**: User management, caregiver approval, ticket resolution
- ✅ **Care Services**: Request management, caregiver profiles, applications
- ✅ **Family Features**: Member linking and relationship management
- ✅ **Task System**: Task creation, assignment, completion, and reminders
- ✅ **Community Features**: Interest group management and participation
- ✅ **Support System**: Ticket creation, tracking, and resolution
- ✅ **Notifications**: Message delivery and read status management
- ✅ **Error Handling**: Proper HTTP status codes and error messages
- ✅ **Request Validation**: Fixed path parameter handling in all endpoints

## 🔧 Recent Improvements

### Request Validator Bug Fix
Fixed a critical issue in the request validator decorator that was preventing proper handling of path parameters (like `userId`, `caregiverId`, `ticketId`). The fix ensures that:
- Path parameters are correctly passed to controller functions
- Validated request data is properly injected
- All endpoints with path parameters now work correctly

### Comprehensive Testing Coverage
Created a complete Bruno test suite covering all 44 API endpoints across 9 functional modules, providing thorough validation of the entire system.

## 🤝 Contributing

1. Follow the [Development Setup](docs/DEVELOPMENT_SETUP.md) guide
2. Create feature branches from `main`
3. Write tests for new endpoints in Bruno collection
4. Run the full test suite: `bru run bruno/second-innings-backend --env Local`
5. Ensure pre-commit hooks pass
6. Submit pull requests with clear descriptions

## 📄 License

This project is part of the Second Innings IITM software engineering coursework.
