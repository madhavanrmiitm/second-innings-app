# Firebase Authentication Setup - Admin Web App

## 🔥 Authentication Flow Implementation

This document describes the Firebase Google Sign-In authentication flow implemented for the Vue.js admin web application, including the new Test Mode feature for development and testing.

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

### 2. Test Mode Flow

```
User selects test user from dropdown
    ↓
Get predefined test user data
    ↓
Send test token to backend /api/auth/verify-token
    ↓
Backend responds with 200 (existing user)
    ↓
User logged in and redirected to dashboard
```

### 3. Response Handling

#### **200 Response - Existing User**

- User data retrieved from backend
- User automatically logged in
- Redirected to appropriate dashboard based on role:
  - `admin` → `/dashboard`
  - `support_user` → `/support/dashboard`
  - `interest_group_admin` → `/iga/dashboard`
  - `caregiver` → `/caregiver/dashboard`
  - `family_member` → `/family/dashboard`
  - `senior_citizen` → `/senior/dashboard`

#### **201 Response - New User**

- User redirected to registration form (`/register`)
- Form pre-filled with Google account data:
  - Gmail ID (non-editable)
  - Full Name (editable)
- User completes additional fields:
  - Date of Birth
  - Role selection
  - YouTube URL (for Interest Group Admin only)

### 4. Registration Flow

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

## 🧪 Test Mode Implementation

### **Test Mode Features**

- **Bypass Firebase Authentication**: No Google sign-in required
- **14 Predefined Test Users**: Covering all roles and statuses
- **Environment-Based Activation**: Controlled by `VITE_TEST_MODE` environment variable
- **Development Workflow**: Faster testing and development cycles

### **Available Test Users**

| Role | Email | Status | Description |
|------|-------|--------|-------------|
| Admin | 21f3001600@ds.study.iitm.ac.in | ACTIVE | Ashwin Narayanan S |
| Admin | nakshatra.nsb@gmail.com | ACTIVE | Nakshatra Gupta |
| Support | support1@test.com | ACTIVE | Test Support User One |
| Support | support2@test.com | ACTIVE | Test Support User Two |
| IGA | verma.groupadmin@example.com | ACTIVE | Mr. Verma - 70-year-old retired community leader |
| IGA | groupadmin2@test.com | PENDING_APPROVAL | Test Group Admin Two |
| Caregiver | priya.caregiver@example.com | ACTIVE | Priya - 28-year-old physiotherapy specialist |
| Caregiver | caregiver2@test.com | PENDING_APPROVAL | Test Caregiver Two |
| Family | rohan.family@example.com | ACTIVE | Rohan - 45-year-old professional, Asha's son |
| Family | family2@test.com | ACTIVE | Test Family Member Two |
| Senior | asha.senior@example.com | ACTIVE | Asha - 80-year-old Indian woman, enjoys gardening |
| Senior | senior2@test.com | ACTIVE | Test Senior Citizen Two |
| Unregistered | unregistered1@test.com | - | For testing registration |
| Unregistered | unregistered2@test.com | - | For testing registration |

### **Story-Based Test Characters**

The test mode includes realistic story characters for comprehensive testing:

#### **Asha & Rohan Family Story**
- **Asha** (ID 3): 80-year-old Indian woman with kind eyes, short grey hair, and glasses. Enjoys gardening and staying active.
- **Rohan** (ID 4): Her 45-year-old son, professional Indian man with short black hair and grey streaks at temples. Caring son managing his mother's care.
- **Priya** (ID 5): 28-year-old Indian woman with warm smile and long dark hair in ponytail. Specializes in physiotherapy and companionship.
- **Mr. Verma** (ID 6): 70-year-old retired Indian gentleman with cheerful demeanor, neat white mustache, and glasses. Community leader organizing activities for seniors.

#### **Realistic Test Scenarios**
- Family care management between Rohan and Asha
- Caregiver services provided by Priya
- Community groups organized by Mr. Verma (Sunrise Walkers Club, Laughter Yoga, Garden Lovers, etc.)
- Support tickets and notifications for various scenarios
- Interest group activities and member management

### **Test Mode Setup**

1. **Enable Test Mode**
   ```bash
   # In .env file
   VITE_TEST_MODE=true
   ```

2. **Backend Configuration**
   ```bash
   # Ensure backend also has TEST_MODE=true
   TEST_MODE=true
   ```

3. **Test Token Format**
   ```javascript
   // Test tokens follow the pattern:
   test_{role}_token_{number}
   // Example: test_admin_token_001
   ```

## 🛠️ Files Structure

### **Authentication Services**

- `src/config/firebase.js` - Firebase configuration
- `src/services/firebaseAuth.js` - Firebase auth operations
- `src/services/testAuthService.js` - Test mode authentication service
- `src/services/userService.js` - User data management & API calls
- `src/services/apiService.js` - HTTP client for backend communication

### **UI Components**

- `src/views/auth/LoginPage.vue` - Google Sign-In button and test mode UI
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

# Test Mode (optional)
VITE_TEST_MODE=false
```

For production:

```bash
VITE_API_BASE_URL=https://second-innings-iitm-249726620429.asia-south1.run.app
VITE_TEST_MODE=false  # Always false in production
```

### 2. Backend API Requirements

Your backend must implement these endpoints:

#### **POST /api/auth/verify-token**

**Request:**

```json
{
  "id_token": "firebase_id_token_here" // or test token
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
      "role": "admin|support_user|interest_group_admin|caregiver|family_member|senior_citizen",
      "status": "ACTIVE|PENDING_APPROVAL|BLOCKED"
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
  "role": "admin|support_user|interest_group_admin|caregiver|family_member|senior_citizen",
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
      "status": "ACTIVE|PENDING_APPROVAL"
    },
    "message": "Registration successful"
  }
}
```

## 🎯 Role Management

### **Admin App Roles**

- `admin` - Full system access and user management
- `support_user` - Ticket management access
- `interest_group_admin` - Interest group management access
- `caregiver` - Care service management
- `family_member` - Senior citizen family management
- `senior_citizen` - Personal care and community access

### **Role-Based Routing**

- Users are automatically redirected based on their assigned role
- Route guards prevent unauthorized access
- Invalid/blocked users are signed out automatically

### **Status-Based Access**

- **ACTIVE**: Full access to role-specific features
- **PENDING_APPROVAL**: Limited access, dashboard view only
- **BLOCKED**: No access, contact support required

## 🔒 Security Features

1. **Firebase ID Token Verification** - All tokens verified with backend
2. **Test Token Validation** - Test tokens validated against predefined list
3. **Role-Based Access Control** - Routes protected by user roles
4. **Session Validation** - Invalid sessions automatically cleared
5. **Status Checking** - Blocked/pending users handled appropriately
6. **HTTPS Required** - Production uses HTTPS endpoints
7. **Environment Protection** - Test mode disabled in production

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

### Test Mode Testing:

1. Enable test mode in `.env` file
2. Visit login page - should show test mode warning
3. Select a test user from dropdown
4. Click "Sign in as Test User"
5. Should redirect to appropriate dashboard
6. Test different roles and statuses

## 📝 Notes

- YouTube URL validation for Interest Group Admin role
- Minimum age validation (13 years)
- Form field validation and error handling
- Loading states and user feedback
- Session persistence across browser restarts
- Test mode should never be enabled in production
- Test tokens are publicly known and only safe for development

## 🚀 Deployment

Ensure these are configured for production:

1. Update `VITE_API_BASE_URL` environment variable
2. Set `VITE_TEST_MODE=false` (or remove entirely)
3. Configure Firebase project settings
4. Verify backend CORS settings
5. Test with production API endpoints
6. Ensure test mode is disabled

## 🔧 Development Workflow

### **With Test Mode**

1. Set `VITE_TEST_MODE=true` in `.env`
2. Start development server
3. Use predefined test users for quick testing
4. Test all roles and statuses instantly
5. No Firebase setup required

### **With Firebase Authentication**

1. Set `VITE_TEST_MODE=false` in `.env`
2. Configure Firebase project
3. Set up Google Authentication
4. Test with real Google accounts
5. Full authentication flow testing
