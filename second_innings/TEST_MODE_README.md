# Test Mode Feature

## Overview

The Test Mode feature allows developers to test the Second Innings Flutter app without requiring Firebase authentication or a running backend server. This is useful for:

- Local development and testing
- UI/UX testing with different user roles
- Quick feature testing without external dependencies
- Demo purposes

## How to Enable Test Mode

### 1. Enable Test Mode Flag

In `lib/config/test_mode_config.dart`, set the test mode flag:

```dart
static const bool isTestMode = true; // Set to false for production
```

### 2. Backend Test Mode

Ensure your backend is running in test mode by setting the environment variable:

```bash
export TEST_MODE=true
```

## Using Test Mode

### 1. Launch the App

When test mode is enabled, you'll see a "Test Mode" button below the "Continue With Google" button on the welcome screen.

### 2. Select Test User

Tap the "Test Mode" button to open the test user selection screen. Here you can:

- **Filter Users**: Use the filter chips to view users by role or status
- **View User Details**: Each user card shows name, email, role, and status
- **Select User**: Tap the login icon to authenticate as that user

### 3. Available Test Users

The app includes 8 predefined test users for the 3 main roles:

#### Active Users
- **Senior Citizens**: 2 users (senior1@test.com, senior2@test.com)
- **Family Members**: 2 users (family1@test.com, family2@test.com)
- **Caregivers**: 1 active user (caregiver1@test.com)

#### Users with Special Status
- **Pending Approval**: caregiver2@test.com
- **Unregistered**: 2 users for testing registration flow

### 4. Test Registration Flow

To test the registration process:

1. Select an "Unregistered" user from the test user selection screen
2. Complete the registration form
3. The app will simulate the registration process and navigate to the appropriate dashboard

## Test Mode Features

### Authentication Flow
- Bypasses Firebase authentication
- Uses predefined test tokens
- Simulates API calls with realistic delays
- Handles both existing and new user flows

### User Management
- Predefined test users with realistic data
- Different user roles and statuses
- Mock user data storage and retrieval

### Registration Testing
- Complete registration flow simulation
- Role-specific form fields (caregiver, family, senior citizen)
- Mock data persistence

## Configuration

### Test Users Configuration

Test users are defined in `lib/config/test_mode_config.dart`:

```dart
static const List<TestUser> testUsers = [
  // Caregiver Users
  TestUser(
    token: 'test_caregiver_token_001',
    email: 'caregiver1@test.com',
    name: 'Test Caregiver One',
    firebaseUid: 'test_caregiver_uid_001',
    status: 'ACTIVE',
    role: 'caregiver',
  ),
  // Family Member Users
  TestUser(
    token: 'test_family_token_001',
    email: 'family1@test.com',
    name: 'Test Family Member One',
    firebaseUid: 'test_family_uid_001',
    status: 'ACTIVE',
    role: 'family_member',
  ),
  // Senior Citizen Users
  TestUser(
    token: 'test_senior_token_001',
    email: 'senior1@test.com',
    name: 'Test Senior Citizen One',
    firebaseUid: 'test_senior_uid_001',
    status: 'ACTIVE',
    role: 'senior_citizen',
  ),
  // ... more users
];
```

### API Configuration

The API configuration automatically detects test mode:

```dart
// In lib/config/api_config.dart
static bool get isTestMode => TestModeConfig.isTestMode;
```

## Security Considerations

⚠️ **Important**: Test mode should NEVER be enabled in production builds.

1. **Disable for Production**: Set `isTestMode = false` before building for production
2. **Test Tokens**: Test tokens are publicly known and should only be used in development
3. **Backend Security**: Ensure your backend test mode is properly secured

## Troubleshooting

### Common Issues

1. **Test Mode Button Not Visible**
   - Check that `TestModeConfig.isTestMode = true`
   - Restart the app after changing the flag

2. **Authentication Fails**
   - Ensure backend is running in test mode
   - Check that test tokens match backend configuration

3. **Registration Issues**
   - Verify test user tokens are correct
   - Check form validation rules

### Debug Information

Test mode includes debug logging to help troubleshoot issues:

```dart
// Check test mode status
print('Test mode enabled: ${TestModeConfig.isTestMode}');

// List available test users
print('Available test users: ${TestModeConfig.testUsers.length}');
```

## Development Workflow

1. **Enable Test Mode**: Set `isTestMode = true`
2. **Start Backend**: Ensure backend is running with `TEST_MODE=true`
3. **Test Features**: Use test users to test different app features
4. **Disable for Production**: Set `isTestMode = false` before release

## File Structure

```
lib/
├── config/
│   ├── test_mode_config.dart      # Test mode configuration
│   └── api_config.dart           # API configuration with test mode
├── auth/
│   ├── test_user_selection.dart  # Test user selection screen
│   ├── welcome.dart              # Welcome screen with test mode button
│   └── register.dart             # Registration screen (test mode support)
└── services/
    ├── user_service.dart         # User service with test mode
    └── registration_service.dart # Registration service with test mode
```

This test mode implementation provides a comprehensive testing environment for the Second Innings app while maintaining security and production readiness.
