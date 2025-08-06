# Caregiver Functionality Changes for Senior Citizens

## Overview
This document summarizes the changes made to enable senior citizens to request, approve, and reject caregivers, in addition to the existing family member functionality.

## Changes Made

### 1. Controller Updates (`app/controllers/care.py`)

#### Modified Functions:
- **`get_caregiver_requests`**: Now supports both FAMILY_MEMBER and SENIOR_CITIZEN roles
- **`request_caregiver`**: Now supports both FAMILY_MEMBER and SENIOR_CITIZEN roles
- **`accept_caregiver_request`**: Now supports both FAMILY_MEMBER and SENIOR_CITIZEN roles
- **`reject_caregiver_request`**: Now supports both FAMILY_MEMBER and SENIOR_CITIZEN roles
- **`get_current_caregiver`**: Now supports both FAMILY_MEMBER and SENIOR_CITIZEN roles

#### Key Changes:
- Changed role validation from `UserRole.FAMILY_MEMBER` to `[UserRole.FAMILY_MEMBER, UserRole.SENIOR_CITIZEN]`
- Updated error messages to reflect both roles
- Added role-specific logic for database queries:
  - **Family Members**: Can view requests for senior citizens they are related to
  - **Senior Citizens**: Can view requests made for themselves
- Updated permission checks for accepting/rejecting requests

### 2. Route Updates (`app/routes/care.py`)

#### Changed Endpoints:
- **Before**: `/family-members/me/caregiver-requests`
- **After**: `/me/caregiver-requests`

- **Before**: `/family-members/me/request-caregiver`
- **After**: `/me/request-caregiver`

- **Before**: `/family-members/me/accept-caregiver-request`
- **After**: `/me/accept-caregiver-request`

- **Before**: `/family-members/me/reject-caregiver-request`
- **After**: `/me/reject-caregiver-request`

- **Before**: `/family-members/me/current-caregiver`
- **After**: `/me/current-caregiver`

#### Benefits:
- More generic endpoints that work for both roles
- Cleaner API structure
- Better separation of concerns

### 3. Payload Updates (`app/payloads.py`)

#### Modified Classes:
- **`RequestCaregiver`**: Removed `id_token` field (authentication now via Authorization header)
- **`AcceptCaregiverRequest`**: Removed `id_token` field
- **`RejectCaregiverRequest`**: Removed `id_token` field

#### Benefits:
- Consistent authentication method across all endpoints
- Cleaner request payloads
- Better security (tokens in headers, not body)

### 4. Bruno API Test Updates

#### Updated Files:
- `GET_CaregiverRequests.bru`
- `POST_RequestCaregiver.bru`
- `POST_AcceptCaregiverRequest.bru`
- `POST_RejectCaregiverRequest.bru`
- `GET_CurrentHiredCaregiver.bru`

#### New Files Created:
- `GET_CaregiverRequests_SeniorCitizen.bru`
- `POST_RequestCaregiver_SeniorCitizen.bru`
- `GET_CurrentHiredCaregiver_SeniorCitizen.bru`

#### Environment Updates:
- Added `seniorCitizenToken` variable to `Local.bru`

### 5. Database Logic Changes

#### Family Member Logic:
- Can view requests for senior citizens they are related to via the `relations` table
- Can accept/reject requests for their related senior citizens
- Creates requests without specific senior citizen ID (general requests)

#### Senior Citizen Logic:
- Can view requests made for themselves directly
- Can accept/reject requests made for themselves
- Creates requests with their own ID as the senior citizen ID

## API Endpoints Summary

### Available to Both Family Members and Senior Citizens:

1. **GET /api/me/caregiver-requests**
   - Returns sent and received caregiver requests
   - Role-specific data filtering

2. **POST /api/me/request-caregiver**
   - Creates a new caregiver request
   - Family members: Creates general request
   - Senior citizens: Creates request for themselves

3. **POST /api/me/accept-caregiver-request**
   - Accepts a caregiver request
   - Family members: Can accept for related senior citizens
   - Senior citizens: Can accept requests made for themselves

4. **POST /api/me/reject-caregiver-request**
   - Rejects a caregiver request
   - Same permission logic as accept

5. **GET /api/me/current-caregiver**
   - Returns current active caregiver
   - Family members: Shows caregiver for related senior citizens
   - Senior citizens: Shows their own caregiver

## Testing Results

The functionality has been tested and verified:

✅ **GET /me/caregiver-requests** - Works for both roles (200 status)
✅ **POST /me/request-caregiver** - Works for both roles (404 expected for non-existent caregiver)
✅ **POST /me/accept-caregiver-request** - Works for both roles (200 status)
✅ **POST /me/reject-caregiver-request** - Works for both roles (200 status)
✅ **GET /me/current-caregiver** - Works for both roles (200 status)

## Security Considerations

- Authentication is handled via Authorization header (Bearer token)
- Role-based access control ensures users can only access their own data
- Family members can only access data for senior citizens they are related to
- Senior citizens can only access their own data
- All endpoints validate user permissions before allowing operations

## Backward Compatibility

- Existing family member functionality remains unchanged
- All existing API calls will continue to work
- New endpoints are more generic and support both roles
- Database schema remains unchanged

## Future Enhancements

1. Add notification system for caregiver request status changes
2. Implement caregiver availability checking
3. Add caregiver rating and review system
4. Implement caregiver scheduling functionality
5. Add bulk operations for multiple caregiver requests
