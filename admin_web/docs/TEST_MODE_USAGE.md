# Test Mode Usage Guide

## Overview

The frontend now includes a **Test Mode** feature that allows you to bypass Firebase authentication and sign in with predefined test users. This is useful for development and testing purposes.

## Enabling Test Mode

1. Create a `.env` file in the project root (if it doesn't exist)
2. Add the following line to enable test mode:
   ```bash
   VITE_TEST_MODE=true
   ```
3. Restart the development server

## Using Test Mode

When test mode is enabled:

1. **Visit the login page** - You'll see a warning banner indicating test mode is active
2. **Select a test user** - Choose from the dropdown of predefined test users organized by role
3. **Sign in** - Click the "Sign in as Test User" button to authenticate

## Available Test Users

The system includes **14 predefined test users** across all roles, featuring story-based characters:

### Admin Users
- **Ashwin Narayanan S** (`21f3001600@ds.study.iitm.ac.in`) - ACTIVE
- **Nakshatra Gupta** (`nakshatra.nsb@gmail.com`) - ACTIVE

### Support Users
- **Test Support User One** (`support1@test.com`) - ACTIVE
- **Test Support User Two** (`support2@test.com`) - ACTIVE

### Interest Group Admin Users
- **Mr. Verma** (`verma.groupadmin@example.com`) - ACTIVE - 70-year-old retired Indian gentleman, community leader
- **Test Group Admin Two** (`groupadmin2@test.com`) - PENDING_APPROVAL

### Caregiver Users
- **Priya** (`priya.caregiver@example.com`) - ACTIVE - 28-year-old Indian woman, physiotherapy specialist
- **Test Caregiver Two** (`caregiver2@test.com`) - PENDING_APPROVAL

### Family Member Users
- **Rohan** (`rohan.family@example.com`) - ACTIVE - 45-year-old professional, Asha's caring son
- **Test Family Member Two** (`family2@test.com`) - ACTIVE

### Senior Citizen Users
- **Asha** (`asha.senior@example.com`) - ACTIVE - 80-year-old Indian woman, enjoys gardening
- **Test Senior Citizen Two** (`senior2@test.com`) - ACTIVE

### Unregistered Users
- **Test Unregistered User One** (`unregistered1@test.com`) - For testing registration flow
- **Test Unregistered User Two** (`unregistered2@test.com`) - For testing registration flow

## Story-Based Test Users

The test mode includes realistic story characters for comprehensive testing:

### **Asha & Rohan Family Story**
- **Asha** (ID 3): 80-year-old senior citizen with kind eyes, short grey hair, and glasses
- **Rohan** (ID 4): Her 45-year-old son, professional Indian man managing her care
- **Priya** (ID 5): 28-year-old caregiver specializing in physiotherapy and companionship
- **Mr. Verma** (ID 6): 70-year-old retired community leader organizing senior activities

### **Realistic Scenarios**
- Family care management between Rohan and Asha
- Caregiver services provided by Priya
- Community groups organized by Mr. Verma
- Support tickets and notifications for various scenarios

## User Roles and Features

### **Admin Role**
- 📊 **Dashboard**: Platform statistics and metrics
- 👤 **User Management**: Create, edit, block/unblock users
- 🎫 **Ticket System**: View and manage all support tickets
- 📝 **Interest Group Oversight**: Review and approve IGA applications
- 👨‍⚕️ **Caregiver Management**: Approve/reject caregiver applications
- 👨‍👩‍👧‍👦 **Family Member Management**: Manage family member accounts
- 👴 **Senior Citizen Management**: Oversee senior citizen accounts
- 🔔 **Notifications**: System-wide notification management

### **Support Role**
- 🏠 **Support Dashboard**: Ticket overview and metrics
- 🎫 **Ticket Management**: View, reply to, and resolve support tickets
- 👤 **Profile Management**: Support user profile settings

### **Interest Group Admin Role**
- 🏠 **IGA Dashboard**: Group management overview with status-based access
- 👥 **Group Management**: Create, edit, and manage interest groups (active users only)
- 📊 **Member Analytics**: View group membership and engagement statistics
- ⏳ **Status Management**: Pending approval, active, and blocked states
- 🎬 **YouTube Integration**: Video URL submission for verification
- 🏷️ **Tags & Description**: Categorization and description management

### **Caregiver Role**
- 👨‍⚕️ **Caregiver Dashboard**: Care service management and metrics
- 👥 **Client Management**: Manage senior citizen clients
- 📋 **Service Records**: Track care services and schedules
- 👤 **Profile Management**: Caregiver profile and verification status

### **Family Member Role**
- 👨‍👩‍👧‍👦 **Family Dashboard**: Senior citizen family management
- 👴 **Senior Management**: Monitor and support senior family members
- 📞 **Communication Tools**: Connect with caregivers and support
- 👤 **Profile Management**: Family member profile settings

### **Senior Citizen Role**
- 👴 **Senior Dashboard**: Personal care and community engagement
- 👥 **Care Services**: Access to caregiver services
- 🏘️ **Community Groups**: Join interest groups and activities
- 👤 **Profile Management**: Senior citizen profile settings

## Backend Requirements

**Important**: Ensure your backend is also running in test mode by setting `TEST_MODE=true` in the backend's environment variables. Otherwise, the test tokens won't be recognized by the backend API.

## Testing Different Scenarios

### 1. Test Active Users
- Sign in with any ACTIVE user to access their respective dashboard
- Admin → Admin Dashboard
- Support → Support Dashboard
- IGA → IGA Dashboard
- Caregiver → Caregiver Dashboard
- Family Member → Family Dashboard
- Senior Citizen → Senior Dashboard

### 2. Test Pending Approval
- Sign in with PENDING_APPROVAL users to see approval workflow
- IGA users with pending status will see limited dashboard
- Caregiver users with pending status will see approval information

### 3. Test Registration Flow
- Sign in with unregistered users to test the registration process
- Complete registration form with required fields
- Test role-specific registration requirements

### 4. Test Admin Features
- Use admin test users to test user management features
- Test caregiver approval workflow
- Test IGA approval workflow
- Test notification system

### 5. Test Role-Specific Features
- **IGA**: Test group management, YouTube integration, tags
- **Support**: Test ticket management and resolution
- **Caregiver**: Test service management and client handling
- **Family**: Test senior citizen management features
- **Senior**: Test care service access and community features

## UI Features

- **Role-based grouping**: Test users are organized by role in the dropdown
- **Status indication**: Each user shows their current status (ACTIVE, PENDING_APPROVAL, etc.)
- **Clear messaging**: Toast notifications indicate test mode is active
- **Fallback option**: Regular Google login is still available below the test mode section
- **Warning banner**: Clear indication when test mode is enabled
- **User-friendly interface**: Easy selection and authentication process

## Test Token Format

Test tokens follow a specific pattern for easy identification:

```javascript
// Format: test_{role}_token_{number}
test_admin_token_001
test_support_token_001
test_groupadmin_token_001
test_caregiver_token_001
test_family_token_001
test_senior_token_001
test_unregistered_token_001
```

## Disabling Test Mode

To disable test mode:
1. Set `VITE_TEST_MODE=false` in your `.env` file
2. Or remove the `VITE_TEST_MODE` line entirely
3. Restart the development server

The test mode UI will no longer appear on the login page.

## Security Notes

⚠️ **Important Security Considerations**:
- Test mode should **NEVER** be enabled in production
- Test tokens are publicly known and only safe for development
- Always verify `VITE_TEST_MODE` is disabled before deploying to production
- The `.env` file should be added to `.gitignore` to prevent accidental commits
- Test tokens are hardcoded and should not be used in production environments

## Development Workflow

### **Quick Testing**
1. Enable test mode
2. Select any test user
3. Test role-specific features instantly
4. No Firebase setup required

### **Comprehensive Testing**
1. Test all user roles and statuses
2. Test registration flow with unregistered users
3. Test admin approval workflows
4. Test role-specific features and permissions

### **Production Preparation**
1. Disable test mode before deployment
2. Test with real Firebase authentication
3. Verify all features work with real authentication
4. Ensure no test mode code is in production build
