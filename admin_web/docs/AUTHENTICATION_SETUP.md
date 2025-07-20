# Firebase Authentication Setup - Admin Web App

## 🔥 Authentication Flow Implementation

This document describes the Firebase Google Sign-In authentication flow implemented for the Vue.js admin web application.

## 📋 Flow Overview

### 1. Google Sign-In Flow

```
User clicks "Continue with Google"
    ↓
Firebase Google Sign-In popup
    ↓
Get Firebase ID token
    ↓
Send ID token to backend /api/auth/verify-token
    ↓
Backend responds with 200 (existing user) or 201 (new user)
```

### 2. Response Handling

#### **200 Response - Existing User**

- User data retrieved from backend
- User automatically logged in
- Redirected to appropriate dashboard based on role:
  - `admin` → `/dashboard`
  - `support_user` → `/support/dashboard`
  - `interest_group_admin` → `/iga/dashboard`

#### **201 Response - New User**

- User redirected to registration form (`/register`)
- Form pre-filled with Google account data:
  - Gmail ID (non-editable)
  - Full Name (editable)
- User completes additional fields:
  - Date of Birth
  - Role selection
  - YouTube URL (for Interest Group Admin only)

### 3. Registration Flow

```
New user fills registration form
    ↓
Form validation (client-side)
    ↓
POST /api/auth/register with user data
    ↓
Backend creates user account
    ↓
User logged in and redirected to dashboard
```

## 🛠️ Files Structure

### **Authentication Services**

- `src/config/firebase.js` - Firebase configuration
- `src/services/firebaseAuth.js` - Firebase auth operations
- `src/services/userService.js` - User data management & API calls
- `src/services/apiService.js` - HTTP client for backend communication

### **UI Components**

- `src/views/auth/LoginPage.vue` - Google Sign-In button
- `src/views/auth/RegistrationPage.vue` - New user registration form
- `src/views/auth/RoleSelectionPage.vue` - Redirect page (dummy)

### **State Management**

- `src/stores/auth.js` - Pinia store for authentication state
- `src/utils/sessionManager.js` - Session management utilities

### **Configuration**

- `src/config/api.js` - API endpoints and environment config
- `src/utils/apiResponse.js` - Consistent API response handling

## 🔧 Setup Instructions

### 1. Environment Configuration

Create `.env` file:

```bash
# API Configuration
VITE_API_BASE_URL=http://localhost:8000
```

For production:

```bash
VITE_API_BASE_URL=https://second-innings-iitm-249726620429.asia-south1.run.app
```

### 2. Backend API Requirements

Your backend must implement these endpoints:

#### **POST /api/auth/verify-token**

**Request:**

```json
{
  "id_token": "firebase_id_token_here"
}
```

**Response 200 (Existing User):**

```json
{
  "data": {
    "user": {
      "id": "user_id",
      "email": "user@example.com",
      "full_name": "User Name",
      "role": "admin|support_user|interest_group_admin",
      "status": "active|blocked|pending_approval"
    }
  }
}
```

**Response 201 (New User):**

```json
{
  "data": {
    "user_info": {
      "gmail_id": "user@example.com",
      "firebase_uid": "firebase_uid",
      "full_name": "User Name"
    }
  }
}
```

#### **POST /api/auth/register**

**Request:**

```json
{
  "id_token": "firebase_id_token_here",
  "full_name": "User Full Name",
  "role": "admin|support_user|interest_group_admin",
  "date_of_birth": "1990-01-15",
  "youtube_url": "https://youtube.com/watch?v=example" // Required for interest_group_admin
}
```

**Response 201:**

```json
{
  "data": {
    "user": {
      "id": "new_user_id",
      "email": "user@example.com",
      "full_name": "User Name",
      "role": "selected_role",
      "status": "active|pending_approval"
    },
    "message": "Registration successful"
  }
}
```

## 🎯 Role Management

### **Admin App Roles**

- `admin` - Full system access
- `support_user` - Ticket management access
- `interest_group_admin` - Interest group management access

### **Role-Based Routing**

- Users are automatically redirected based on their assigned role
- Route guards prevent unauthorized access
- Invalid/blocked users are signed out automatically

## 🔒 Security Features

1. **Firebase ID Token Verification** - All tokens verified with backend
2. **Role-Based Access Control** - Routes protected by user roles
3. **Session Validation** - Invalid sessions automatically cleared
4. **Status Checking** - Blocked/pending users handled appropriately
5. **HTTPS Required** - Production uses HTTPS endpoints

## 🧪 Testing the Flow

### Test New User Registration:

1. Use a Google account not registered in your backend
2. Click "Continue with Google" on login page
3. Complete Google sign-in
4. Should redirect to registration form
5. Fill out the form with required fields
6. Submit registration
7. Should redirect to appropriate dashboard

### Test Existing User Login:

1. Use a Google account already registered in your backend
2. Click "Continue with Google" on login page
3. Complete Google sign-in
4. Should redirect directly to dashboard

## 📝 Notes

- YouTube URL validation for Interest Group Admin role
- Minimum age validation (13 years)
- Form field validation and error handling
- Loading states and user feedback
- Session persistence across browser restarts

## 🚀 Deployment

Ensure these are configured for production:

1. Update `VITE_API_BASE_URL` environment variable
2. Configure Firebase project settings
3. Verify backend CORS settings
4. Test with production API endpoints
