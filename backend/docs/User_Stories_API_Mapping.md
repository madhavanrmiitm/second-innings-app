# User Stories to API Mapping

This document maps the user stories to the implemented APIs and external integrations in the Second Innings platform.

## Admin User Stories

### 1. Approve Caregiver Profiles
**User Story:** As an admin, I want to approve caregiver profiles only after verifying their identity and qualification documents, so that the platform ensures trust, safety, and professional standards for all senior citizens and their families.

**External APIs Integrated:**
- Firebase Authentication (ID token verification)

**APIs Created:**
- `POST /admin/caregivers/{id}/verify` - Verify and activate caregiver accounts after document verification
- `GET /admin/caregivers` - List all caregivers for admin review

### 2. Approve Interest Group Admin Profiles
**User Story:** As an admin, I want to approve interest group admin profiles only after verifying their background and community involvement, so that the platform ensures quality community leadership and engaging activities for senior citizens.

**External APIs Integrated:**
- Firebase Authentication (ID token verification)

**APIs Created:**
- `POST /admin/interest-group-admins/{id}/verify` - Verify and activate interest group admin accounts after background verification
- `GET /admin/interest-group-admins` - List all interest group admins for admin review

### 3. CRUD Operations on Support User Accounts
**User Story:** As an admin, I want to perform create, read, update and delete (CRUD) operations on support user accounts, so that I can efficiently manage the support team and ensure timely assistance for all users.

**External APIs Integrated:**
- Firebase Authentication (ID token verification)

**APIs Created:**
- `GET /admin/users` - Read all user accounts for management
- `DELETE /admin/users/{id}` - Delete user accounts when needed

### 4. View and Respond to Support Tickets
**User Story:** As a support user, I want to view and respond to all raised tickets, so that I can provide timely resolutions and maintain user satisfaction across the platform.

**External APIs Integrated:**
- Firebase Authentication (ID token verification)

**APIs Created:**
- `GET /admin/tickets` - View all support tickets
- `POST /admin/tickets/{id}/resolve` - Resolve and respond to tickets
- `GET /admin/tickets/stats` - Get ticket statistics for monitoring

## Caregiver User Stories

### 4. Caregiver Registration with Introduction Video
**User Story:** As a caregiver, I want to register and upload my profile along with an introduction video, so that families can learn about my background and feel confident in selecting me for caregiving services.

**External APIs Integrated:**
- Firebase Authentication (Google Sign-In)
- YouTube (for introduction video hosting)
- Gemini AI (for analyzing introduction videos to generate profile tags and descriptions)

**APIs Created:**
- `POST /api/auth/register` - Register caregiver profile with YouTube URL; Gemini AI analyzes the video to auto-generate professional tags and description

### 5. Receive Job Opportunities
**User Story:** As a caregiver, I want to receive job opportunities based on my availability, location, and caregiving specialization, so that I can be matched with suitable clients and provide effective, personalized care.

**External APIs Integrated:**
- Firebase Authentication (ID token verification)

**APIs Created:**
- `GET /care-requests` - View available care opportunities
- `POST /caregivers/requests/{id}/apply` - Apply for specific care requests
- `GET /caregivers` - List available caregivers with their specializations

### 6. Deactivate Account
**User Story:** As a caregiver, I want to be able to deactivate my account, so that I can take a break or discontinue my services when needed, without losing control over my profile.

**External APIs Integrated:**
- Firebase Authentication (ID token verification)

**APIs Created:**
- *Note: Account deactivation would be handled through the admin user management APIs*

## Family Member User Stories

### 7. Register Using Google Sign-In
**User Story:** As a family member, I want to be able to register on the app using Google Sign-In, so that I can quickly and securely access the platform to manage care and support for my loved ones.

**External APIs Integrated:**
- Firebase Authentication (Google Sign-In)

**APIs Created:**
- `POST /api/auth/register` - Register family member accounts using Firebase ID tokens
- `POST /auth/verify-token` - Verify authentication tokens for secure access

### 8. Add Senior Citizens to App
**User Story:** As a family member, I want to be able to add senior citizens related to me to the app, so that I can manage their care, preferences, and activities in a centralized and supportive environment.

**External APIs Integrated:**
- Firebase Authentication (ID token verification)

**APIs Created:**
- `POST /senior-citizens/me/family-members` - Add senior citizen family members with relationship details
- `GET /senior-citizens/me/family-members` - View all connected family members

### 9. Track Health Information
**User Story:** As a family member, I want to be able to track the health information of the senior citizen(s) related to me, so that I can monitor their well-being and take timely action if any health concerns arise.

**External APIs Integrated:**
- Firebase Authentication (ID token verification)

**APIs Created:**
- `GET /tasks` - View health-related tasks and reminders for senior citizens
- `POST /tasks` - Create health tracking tasks and reminders

### 10. AI-Generated Conversation Reminders
**User Story:** As a family member, I want to receive periodic reminders with AI-generated conversation ideas, so that I can engage my senior relatives more effectively and maintain a strong emotional connection.

**External APIs Integrated:**
- Firebase Authentication (ID token verification)

**APIs Created:**
- `GET /notifications` - Receive messages and updates from family members
- `GET /reminders` - Get periodic engagement reminders (will be implemented in the next sprint)

### 11. Review and Select Caregivers
**User Story:** As a family member, I want to review and select a caregiver based on ratings, location and profile video, so that I can make an informed decision and ensure the best care for my senior relatives.

**External APIs Integrated:**
- Firebase Authentication (ID token verification)
- YouTube (for caregiver profile videos)

**APIs Created:**
- `GET /caregivers` - Browse available caregivers with ratings and locations
- `POST /care-requests` - Create care requests for specific caregivers
- `PUT /care-requests/{id}` - Update care request details and selections

## Senior Citizen User Stories

### 12. Create and Find Interest-Based Groups
**User Story:** As a senior citizen, I want to create and find local interest-based groups, so that I can socialize, pursue my hobbies, and maintain an active and engaged lifestyle.

**External APIs Integrated:**
- Firebase Authentication (ID token verification)

**APIs Created:**
- `GET /interest-groups` - Browse available interest-based groups
- `POST /interest-groups` - Create new interest groups
- `POST /interest-groups/{id}/join` - Join existing interest groups

### 13. AI-Based Group Recommendations
**User Story:** As a senior citizen, I want an AI-based recommendation system that suggests group activities tailored to my interests, so that I can easily discover and participate in events without the hassle of manual searching.

**External APIs Integrated:**
- Firebase Authentication (ID token verification)

**APIs Created:**
- `GET /interest-groups` - Browse available interest-based groups (basic listing, AI recommendations will be implemented in the next sprint)

### 14. Receive Family Messages
**User Story:** As a senior citizen, I want to receive positive and empathetic messages from my family, so that I feel emotionally supported and valued.

**External APIs Integrated:**
- Firebase Authentication (ID token verification)

**APIs Created:**
- `GET /notifications` - Receive messages and updates from family members
- `POST /notifications/{id}/read` - Mark family messages as read

### 15. Medicine and Checkup Reminders
**User Story:** As a senior citizen, I want to receive reminders from my family members to take medicine and attend checkups, so that I can maintain my health and follow my care routine effectively.

**External APIs Integrated:**
- Firebase Authentication (ID token verification)

**APIs Created:**
- `GET /reminders` - Get medication and appointment reminders
- `GET /tasks` - View health-related tasks set by family members
- `POST /tasks/{id}/complete` - Mark tasks as completed

### 16. Track Medications
**User Story:** As a senior citizen, I want to be able to keep track of my medications, so that I can manage my health independently and avoid missing doses.

**External APIs Integrated:**
- Firebase Authentication (ID token verification)

**APIs Created:**
- `GET /tasks` - View medication tracking tasks
- `POST /tasks` - Create personal medication reminders
- `POST /tasks/{id}/complete` - Log medication intake

## Senior Engagement Coordinator User Stories

### 17. Create Interest-Based Groups
**User Story:** As a senior engagement coordinator, I want to create interest-based groups, so that senior citizens can connect with like-minded peers and engage in meaningful activities.

**External APIs Integrated:**
- Firebase Authentication (ID token verification)

**APIs Created:**
- `POST /interest-groups` - Create and manage interest-based groups for seniors
- `GET /interest-groups` - Monitor existing groups and participation

### 18. Coordinator Registration
**User Story:** As a senior engagement coordinator, I want to be able to register on the app, so that I can manage and facilitate groups effectively for senior citizens.

**External APIs Integrated:**
- Firebase Authentication (Google Sign-In)
- Gemini AI (for analyzing introduction videos to generate profile tags and descriptions for interest group admin role)

**APIs Created:**
- `POST /api/auth/register` - Register coordinator accounts with appropriate role permissions; supports YouTube video analysis for interest group admin profiles

## Common APIs

### User Profile Management
- `POST /user/profile` - Get and manage user profile information across all user types

### Health Check
- `GET /` - Health check endpoint to verify server status

## External API Integrations Summary

1. **Firebase Authentication** - Used throughout for secure user authentication and authorization
2. **YouTube** - Used for hosting caregiver introduction videos (URLs stored, not direct API integration)
3. **Gemini AI** - Used specifically for analyzing caregiver and interest group admin YouTube videos during registration to generate tags and descriptions
4. **Google OAuth** - Enables seamless Google Sign-In functionality via Firebase

## Notes

- All authenticated endpoints use Bearer token authentication via Firebase ID tokens
- The platform maintains role-based access control for different user types
- **Gemini AI is currently only used for YouTube video analysis during registration** - conversation suggestions and activity recommendations are stretch goals as they can be implemented during integration with the frontend tailored for each user type.
- Some functionality like detailed health tracking, reminders system, and AI-powered recommendations are stretch goals but not yet fully implemented
- The current API specification provides a solid foundation for the core user stories with room for future AI enhancements
