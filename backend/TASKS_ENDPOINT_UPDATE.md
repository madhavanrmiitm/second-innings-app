# Tasks Endpoint Update: Conditional Senior Citizen Task Retrieval

## Overview
The `/tasks` endpoint has been updated to only fetch tasks for linked senior citizens when a `senior_citizen_id` query parameter is explicitly provided. This change improves performance and provides more granular control over data access.

## Changes Made

### 1. Controller Logic Update (`app/controllers/tasks.py`)
- **Before**: Automatically fetched all linked senior citizen tasks for family members
- **After**: Only fetches linked senior citizen tasks when `senior_citizen_id` query parameter is provided
- **Added**: Relationship verification to ensure the family member has access to the specified senior citizen

### 2. Route Documentation (`app/routes/tasks.py`)
- Added comprehensive docstring explaining the new query parameter functionality
- Documented example usage: `GET /tasks?senior_citizen_id=9`

### 3. Bruno Test Files
- **Updated**: `GET_Tasks.bru` with description of new functionality
- **Added**: `GET_Tasks_WithSeniorCitizen.bru` to test valid senior_citizen_id parameter
- **Added**: `GET_Tasks_WithInvalidSeniorCitizen.bru` to test invalid parameter handling

## API Usage

### Basic Usage (No Query Parameters)
```http
GET /api/tasks
Authorization: Bearer <token>
```
- Returns tasks created by or assigned to the authenticated user
- For family members: only returns their own tasks

### With Senior Citizen ID (Family Members Only)
```http
GET /api/tasks?senior_citizen_id=9
Authorization: Bearer <family_member_token>
```
- Returns tasks created by or assigned to the specified senior citizen (ID 9)
- Only works if the family member has a verified relationship with the senior citizen
- Falls back to own tasks if invalid senior_citizen_id is provided

## Security Features

1. **Relationship Verification**: Checks if the family member has a valid relationship with the specified senior citizen
2. **Parameter Validation**: Safely handles invalid senior_citizen_id values
3. **Role-Based Access**: Only family members can access senior citizen tasks
4. **Graceful Fallback**: Invalid parameters result in returning only own tasks

## Performance Benefits

- **Reduced Database Queries**: No unnecessary JOIN operations when not needed
- **Smaller Result Sets**: Only fetches relevant data based on explicit parameters
- **Better Scalability**: Avoids loading all linked senior citizen tasks by default

## Example Scenarios

### Scenario 1: Family Member Views Own Tasks
```
GET /api/tasks
User: Family Member (ID: 7)
Result: Tasks created by or assigned to user ID 7
```

### Scenario 2: Family Member Views Senior Citizen Tasks
```
GET /api/tasks?senior_citizen_id=9
User: Family Member (ID: 7)
Senior Citizen: ID 9 (verified relationship exists)
Result: Tasks created by or assigned to senior citizen ID 9
```

### Scenario 3: Family Member Views Invalid Senior Citizen
```
GET /api/tasks?senior_citizen_id=999
User: Family Member (ID: 7)
Result: Only own tasks (ID 7), invalid parameter ignored
```

## Backward Compatibility

- **Existing calls without query parameters**: Continue to work as before
- **Family members**: Now get only their own tasks by default (more secure)
- **New functionality**: Available through optional query parameter

## Testing

The new functionality is covered by comprehensive Bruno tests:
1. Basic tasks retrieval
2. Tasks with valid senior_citizen_id
3. Tasks with invalid senior_citizen_id
4. Proper relationship verification
5. Data integrity validation
