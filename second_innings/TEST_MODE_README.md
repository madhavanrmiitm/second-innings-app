# Test Mode Configuration - Updated

This document describes the updated test mode configuration for the Second Innings application, which now includes comprehensive test users based on the database schema and story characters.

## Overview

The test mode has been enhanced to include:
- **Story Characters**: Main characters for testing the application flow
- **All User Roles**: Complete coverage of all user types in the system
- **Rich User Data**: Detailed descriptions, ages, and metadata for realistic testing
- **Enhanced Filtering**: Better organization and filtering of test users

## Test Users

### Admin Users
- **Ashwin Narayanan S** (`21f3001600@ds.study.iitm.ac.in`)
  - Role: `admin`
  - Status: `ACTIVE`
  - Description: System administrator

- **Nakshatra Gupta** (`nakshatra.nsb@gmail.com`)
  - Role: `admin`
  - Status: `ACTIVE`
  - Description: System administrator

### Story Characters

#### Senior Citizens
- **Asha** (`asha.senior@example.com`)
  - Role: `senior_citizen`
  - Status: `ACTIVE`
  - Age: 80 years (born 1945-03-15)
  - Description: 80-year-old Indian woman with kind eyes, short grey hair, and glasses. Enjoys gardening and staying active.
  - Tags: senior, indian, gardening, active

- **Test Senior Citizen Two** (`senior2@test.com`)
  - Role: `senior_citizen`
  - Status: `ACTIVE`
  - Age: 74 years (born 1950-09-30)
  - Description: Former engineer with passion for gardening
  - Tags: senior, engineer, gardening

#### Family Members
- **Rohan** (`rohan.family@example.com`)
  - Role: `family_member`
  - Status: `ACTIVE`
  - Age: 44 years (born 1980-08-22)
  - Description: 45-year-old professional Indian man with short black hair and grey streaks at temples. Caring son managing his mother Asha's care.
  - Tags: family, professional, caring, indian

- **Test Family Member Two** (`family2@test.com`)
  - Role: `family_member`
  - Status: `ACTIVE`
  - Age: 36 years (born 1988-04-18)
  - Description: Devoted child managing care for senior citizen
  - Tags: family, devoted

#### Caregivers
- **Priya** (`priya.caregiver@example.com`)
  - Role: `caregiver`
  - Status: `ACTIVE`
  - Age: 27 years (born 1997-11-08)
  - Description: 28-year-old Indian woman with warm smile and long dark hair in ponytail. Specializes in physiotherapy and companionship.
  - Tags: caregiver, physiotherapy, companionship, indian
  - YouTube URL: `https://www.youtube.com/watch?v=priya_intro`

- **Test Caregiver Two** (`caregiver2@test.com`)
  - Role: `caregiver`
  - Status: `PENDING_APPROVAL`
  - Age: 34 years (born 1990-08-25)
  - Description: Certified nurse with 5 years of experience in home care
  - Tags: caregiver, nurse, home-care
  - YouTube URL: `https://www.youtube.com/watch?v=test2`

#### Interest Group Admins
- **Mr. Verma** (`verma.groupadmin@example.com`)
  - Role: `interest_group_admin`
  - Status: `ACTIVE`
  - Age: 69 years (born 1955-06-10)
  - Description: 70-year-old retired Indian gentleman with cheerful demeanor, neat white mustache, and glasses. Community leader organizing activities for seniors.
  - Tags: group-admin, retired, community, indian
  - YouTube URL: `https://www.youtube.com/watch?v=verma_intro`

- **Test Group Admin Two** (`groupadmin2@test.com`)
  - Role: `interest_group_admin`
  - Status: `PENDING_APPROVAL`
  - Age: 52 years (born 1972-11-08)
  - Description: Art therapist creating engaging programs for elderly
  - Tags: group-admin, art-therapy, programs
  - YouTube URL: `https://www.youtube.com/watch?v=testgroup2`

### Support Users
- **Test Support User One** (`support1@test.com`)
  - Role: `support_user`
  - Status: `ACTIVE`
  - Age: 32 years (born 1992-01-12)
  - Description: Support specialist helping users with platform issues
  - Tags: support, specialist

- **Test Support User Two** (`support2@test.com`)
  - Role: `support_user`
  - Status: `ACTIVE`
  - Age: 37 years (born 1987-05-07)
  - Description: Customer service representative for platform support
  - Tags: support, customer-service

### Legacy Test Users
- **Test Caregiver One** (`caregiver1@test.com`)
  - Role: `caregiver`
  - Status: `ACTIVE`
  - Description: Legacy test caregiver user
  - Tags: caregiver, legacy

- **Test Family Member One** (`family1@test.com`)
  - Role: `family_member`
  - Status: `ACTIVE`
  - Description: Legacy test family member user
  - Tags: family, legacy

- **Test Senior Citizen One** (`senior1@test.com`)
  - Role: `senior_citizen`
  - Status: `ACTIVE`
  - Description: Legacy test senior citizen user
  - Tags: senior, legacy

### Unregistered Users
- **Test Unregistered User One** (`unregistered1@test.com`)
  - Role: `unregistered`
  - Status: `UNREGISTERED`
  - Description: Unregistered test user
  - Tags: unregistered, test

- **Test Unregistered User Two** (`unregistered2@test.com`)
  - Role: `unregistered`
  - Status: `UNREGISTERED`
  - Description: Unregistered test user
  - Tags: unregistered, test

## Features

### Enhanced User Cards
- **Story Character Indicator**: 🌟 icon for main story characters
- **Age Display**: Calculated age from date of birth
- **Rich Descriptions**: Detailed user descriptions and tags
- **Status and Role Chips**: Visual indicators for user status and role

### Advanced Filtering
- **All Users**: Complete list of all test users
- **Active Users**: Only active users
- **Story Characters**: Main story characters (Asha, Rohan, Priya, Mr. Verma)
- **Administrators**: Admin users
- **Support Users**: Support team members
- **Role-based Filters**: Filter by specific user roles
- **Unregistered Users**: Users pending registration

### Helper Methods
- `getStoryCharacters()`: Get main story characters
- `getAdminUsers()`: Get administrator users
- `getSupportUsers()`: Get support team users
- `isStoryCharacter`: Check if user is a story character
- `age`: Calculate and display user age

## Usage

### In Test Mode
1. Navigate to the test user selection screen
2. Use filters to find specific user types
3. Select a user to log in with their test credentials
4. Story characters are marked with 🌟 for easy identification

### For Developers
```dart
// Get story characters
final storyUsers = TestModeConfig.getStoryCharacters();

// Get users by role
final caregivers = TestModeConfig.getTestUsersByRole('caregiver');

// Check if user is a story character
if (user.isStoryCharacter) {
  // Handle story character specific logic
}

// Get user age
final userAge = user.age; // Returns calculated age or null
```

## Database Schema Alignment

This test configuration aligns with the database schema including:
- All user roles from the `user_role` ENUM
- User statuses from the `user_status` ENUM
- Additional fields like `date_of_birth`, `description`, `tags`, and `youtube_url`
- Proper foreign key relationships and constraints

## Testing Scenarios

### Family Care Flow
- **Rohan** (Family Member) → **Asha** (Senior Citizen)
- Test task creation, care requests, and family management

### Caregiver Services
- **Priya** (Caregiver) → **Asha** (Senior Citizen)
- Test care request acceptance, task assignment, and service delivery

### Community Activities
- **Mr. Verma** (Group Admin) → Interest Groups
- Test group creation, member management, and activity coordination

### Support System
- **Support Users** → User assistance
- Test ticket creation, assignment, and resolution

## Notes

- All test users have realistic data for comprehensive testing
- Story characters provide a narrative context for testing user interactions
- Legacy test users maintain backward compatibility
- Age calculations are dynamic based on current date
- YouTube URLs are included for caregiver and group admin profiles
