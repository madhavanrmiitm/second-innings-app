# Second Innings Backend - Bruno API Collection

This directory contains the Bruno API collection for testing and documenting the Second Innings Backend API.

## About Bruno

[Bruno](https://usebruno.com/) is a fast and Git-friendly open-source API client. Unlike other API clients, Bruno stores collections as plain text files in your filesystem, making them perfect for version control and collaboration.

## Collection Structure

```
bruno/second-innings-backend/
├── bruno.json                    # Collection configuration
├── environments/
│   └── Local.bru                # Local environment variables
├── Root/                        # Main app routes (from main.py)
│   ├── GET_HealthCheck.bru      # GET / - Health check
│   ├── GET_ComprehensiveTestData.bru  # Comprehensive test data validation
│   └── GET_TestDataValidation.bru     # Test data validation across endpoints
├── Admin/                       # Admin routes
│   ├── GET_Users.bru            # GET /api/admin/users - Get all users
│   ├── GET_Caregivers.bru       # GET /api/admin/caregivers - Get caregivers
│   ├── GET_Tickets.bru          # GET /api/admin/tickets - Get all tickets
│   ├── GET_TicketStats.bru      # GET /api/admin/ticket-stats - Get ticket statistics
│   ├── POST_VerifyCaregiver.bru # POST /api/admin/verify-caregiver - Verify caregiver
│   ├── POST_VerifyInterestGroupAdmin.bru # POST /api/admin/verify-interest-group-admin
│   ├── POST_ResolveTicket.bru   # POST /api/admin/resolve-ticket - Resolve ticket
│   └── DELETE_User.bru          # DELETE /api/admin/users/{user_id} - Delete user
├── Auth/                        # Authentication routes
│   ├── POST_VerifyToken.bru     # POST /api/auth/verify-token - Token verification
│   └── POST_RegisterUser.bru    # POST /api/auth/register - User registration
├── Care/                        # Care routes
│   ├── GET_Caregivers.bru       # GET /api/caregivers - Get available caregivers
│   ├── GET_CareRequests.bru     # GET /api/care-requests - Get care requests
│   ├── GET_CareRequest.bru      # GET /api/care-requests/{request_id} - Get specific request
│   ├── POST_CreateCareRequest.bru # POST /api/care-requests - Create care request
│   ├── POST_ApplyForRequest.bru # POST /api/care-requests/{request_id}/apply - Apply for request
│   └── PUT_UpdateCareRequest.bru # PUT /api/care-requests/{request_id} - Update request
├── Family/                      # Family routes
│   ├── GET_FamilyMembers.bru    # GET /api/senior-citizens/me/family-members
│   ├── POST_AddFamilyMember.bru # POST /api/senior-citizens/me/family-members
│   └── DELETE_FamilyMember.bru  # DELETE /api/senior-citizens/me/family-members/{member_id}
├── InterestGroups/              # Interest group routes
│   ├── GET_InterestGroups.bru   # GET /api/interest-groups - Get interest groups
│   ├── POST_CreateInterestGroup.bru # POST /api/interest-groups - Create group
│   └── POST_JoinGroup.bru       # POST /api/interest-groups/{group_id}/join - Join group
├── Notifications/               # Notification routes
│   ├── GET_Notifications.bru    # GET /api/notifications - Get notifications
│   └── POST_MarkAsRead.bru     # POST /api/notifications/{notification_id}/mark-read
├── Tasks/                       # Task routes
│   ├── GET_Tasks.bru            # GET /api/tasks - Get tasks
│   ├── GET_Task.bru             # GET /api/tasks/{task_id} - Get specific task

│   ├── POST_CreateTask.bru      # POST /api/tasks - Create task
│   └── POST_CompleteTask.bru    # POST /api/tasks/{task_id}/complete - Complete task
├── Tickets/                     # Support ticket routes
│   ├── GET_UserTickets.bru      # GET /api/tickets - Get user tickets
│   └── POST_CreateTicket.bru    # POST /api/tickets - Create support ticket
├── User/                        # User routes
│   └── POST_GetProfile.bru      # POST /api/user/profile - Get user profile
└── README.md                    # This file
```

**Organization:**
- **One folder per controller** - Each controller file gets its own folder
- **One file per route** - Each API endpoint gets its own `.bru` file with working example
- **Method-first naming** - `METHOD_PurposeInThisCase` format (e.g., `GET_HealthCheck`)
- **Status code focused testing** - Simple, fast tests validating HTTP response codes

## Prerequisites

1. **Install Bruno**: Download from [usebruno.com](https://usebruno.com/) or install via package manager:
   ```bash
   # macOS
   brew install bruno

   # Windows (via Chocolatey)
   choco install bruno

   # Or download the installer from the website
   ```

2. **Start the API server**: Make sure your FastAPI server is running:
   ```bash
   # From the backend directory
   python main.py
   # or with database initialization
   python main.py --init-db
   ```

## Usage

### Opening the Collection

1. Open Bruno
2. Click "Open Collection"
3. Navigate to the `bruno/second-innings-backend` directory
4. Select the directory (Bruno will detect the `bruno.json` file)

### Environment Configuration

The collection includes a **Local** environment with the following variables:
- `baseUrl`: http://127.0.0.1:8000
- `apiPrefix`: /api

If your server runs on a different host/port, you can:
1. Modify the environment variables in Bruno
2. Or create a new environment for your specific setup

### Running Requests

**Available requests:**
1. **GET_HealthCheck**: Test if the server is running
2. **POST_VerifyToken**: Verify Firebase authentication tokens
3. **POST_RegisterUser**: Register new users with role-based validation

### Running Tests

Each request includes **upgraded automated tests** that validate:

#### **Basic Validation**
- HTTP status codes (200, 201, 404, etc.)
- Response structure and required fields
- Data type validation

#### **Comprehensive Test Data Validation**
- **Status-based testing**: All enum values are represented
- **Relationship testing**: Assigned/unassigned scenarios
- **Time-based testing**: Creation and completion times
- **Content validation**: Descriptions, tags, links, etc.

#### **Specific Test Scenarios**
- **Users**: All roles and statuses present
- **Tasks**: All statuses with assignment scenarios
- **Care Requests**: All statuses with location/timing
- **Tickets**: All statuses with assignment scenarios
- **Notifications**: All types and priorities
- **Interest Groups**: Active/inactive with timing

Click the "Send" button to execute requests and see the comprehensive test results.

### Command Line Testing

You can also run tests via Bruno CLI:

```bash
# Install Bruno CLI
npm install -g @usebruno/cli

# Run all tests
bru run --env Local

# Run specific test
bru run "Auth/POST_VerifyToken.bru" --env Local

# Run with verbose output
bru run --env Local --reporter verbose
```

## Comprehensive Test Data

The Bruno collection now includes **upgraded tests** that validate comprehensive test data across all endpoints. The database schema includes extensive test data with:

### **Users Test Data**
- **All user roles**: admin, caregiver, family_member, senior_citizen, interest_group_admin, support_user
- **All user statuses**: active, pending_approval, blocked
- **Users with YouTube URLs**: For caregivers and interest group admins
- **Users with descriptions and tags**: For better profile testing
- **Users with date of birth**: For age-related features

### **Relations Test Data**
- **Family relationships**: Father-Son, Mother-Daughter relationships
- **Multiple relations**: Different types of family connections

### **Tasks Test Data**
- **All task statuses**: pending, in_progress, completed, cancelled
- **Assigned and unassigned tasks**: For testing assignment scenarios
- **Tasks with completion times**: For completed task testing
- **Tasks with descriptions**: For detailed task information

### **Care Requests Test Data**
- **All request statuses**: pending, accepted, rejected, cancelled
- **Requests with locations**: For location-based testing
- **Requests with timing**: For scheduling features
- **Multiple scenarios**: Different care request situations

### **Interest Groups Test Data**
- **Active and inactive groups**: For status-based filtering
- **Groups with timing**: For scheduled activities
- **Groups without timing**: For ongoing activities
- **Groups with links**: For external resource integration

### **Tickets Test Data**
- **All ticket statuses**: open, in_progress, resolved, closed
- **Assigned and unassigned tickets**: For support workflow testing
- **Tickets with descriptions**: For detailed issue tracking
- **Resolved tickets with resolution times**: For completion tracking

### **Notifications Test Data**
- **All notification types**: task, care_request, interest_group, support_ticket, relation
- **All priority levels**: low, medium, high
- **Read and unread notifications**: For notification management
- **Different creation times**: For time-based filtering

## API Endpoints Documentation

### GET /
- **Purpose**: Health check endpoint
- **Response**: Welcome message
- **Status**: 200 OK

### POST /api/auth/verify-token
- **Purpose**: Verify Firebase ID tokens and authenticate users
- **Request Body**: JSON with id_token
- **Success Response**: 200 (existing user) or 201 (new user)
- **Error Responses**: 401 (invalid token)

### POST /api/auth/register
- **Purpose**: Register new users with role-based profile data
- **Request Body**: JSON with user details and role-specific requirements
- **Success Response**: 201 Created with user data
- **Error Responses**: 400 (validation), 409 (already registered), 401 (invalid token)

## Extending the Collection

**For new controllers:**
1. Create a new folder (e.g., `User/`, `Activity/`, `Group/`)
2. Add `.bru` files for each route in that controller

**For new routes in existing controllers:**
1. Add a new `.bru` file in the appropriate folder
2. Use naming: `METHOD_PurposeInThisCase.bru` (e.g., `GET_UserProfile.bru`, `POST_CreateActivity.bru`)
3. Include only working examples with valid request/response data
4. Focus tests on status code validation for reliability

**Testing Guidelines:**
- **Primary test**: Always include status code validation
- **Keep it simple**: Avoid complex response body assertions
- **Fast execution**: Minimal tests for quick feedback
- **Essential validation**: Confirm endpoint responds correctly

Example test structure:
```javascript
tests {
  test("Status code is 200", function() {
    expect(res.getStatus()).to.equal(200);
  });
}
```

## Tips

- Use Bruno's **Environment Variables** for different deployment environments (dev, staging, prod)
- Leverage **Pre-request Scripts** for authentication or dynamic data generation
- **Focus on status codes** for reliable, maintainable tests
- Export/import collections for sharing with team members
- Use CLI for automated testing in CI/CD pipelines
