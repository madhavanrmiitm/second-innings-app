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

The system includes **14 predefined test users** across all roles:

### Admin Users
- **Test Admin One** (`admin1@test.com`) - ACTIVE
- **Test Admin Two** (`admin2@test.com`) - ACTIVE

### Support Users
- **Test Support User One** (`support1@test.com`) - ACTIVE
- **Test Support User Two** (`support2@test.com`) - ACTIVE

### Interest Group Admin Users
- **Test Group Admin One** (`groupadmin1@test.com`) - ACTIVE
- **Test Group Admin Two** (`groupadmin2@test.com`) - PENDING_APPROVAL

### Caregiver Users
- **Test Caregiver One** (`caregiver1@test.com`) - ACTIVE
- **Test Caregiver Two** (`caregiver2@test.com`) - PENDING_APPROVAL

### Family Member Users
- **Test Family Member One** (`family1@test.com`) - ACTIVE
- **Test Family Member Two** (`family2@test.com`) - ACTIVE

### Senior Citizen Users
- **Test Senior Citizen One** (`senior1@test.com`) - ACTIVE
- **Test Senior Citizen Two** (`senior2@test.com`) - ACTIVE

### Unregistered Users
- **Test Unregistered User One** (`unregistered1@test.com`) - For testing registration flow
- **Test Unregistered User Two** (`unregistered2@test.com`) - For testing registration flow

## Backend Requirements

**Important**: Ensure your backend is also running in test mode by setting `TEST_MODE=true` in the backend's environment variables. Otherwise, the test tokens won't be recognized by the backend API.

## Testing Different Scenarios

### 1. Test Active Users
- Sign in with any ACTIVE user to access their respective dashboard
- Admin → Admin Dashboard
- Support → Support Dashboard
- IGA → IGA Dashboard

### 2. Test Pending Approval
- Sign in with PENDING_APPROVAL users to see approval workflow

### 3. Test Registration Flow
- Sign in with unregistered users to test the registration process

## UI Features

- **Role-based grouping**: Test users are organized by role in the dropdown
- **Status indication**: Each user shows their current status (ACTIVE, PENDING_APPROVAL, etc.)
- **Clear messaging**: Toast notifications indicate test mode is active
- **Fallback option**: Regular Google login is still available below the test mode section

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
