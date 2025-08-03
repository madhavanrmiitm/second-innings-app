# Test Mode Documentation

## Overview

The **Test Mode** feature allows you to run the Second Innings Backend application locally without depending on Firebase authentication. This is useful for:

- Local development and testing
- CI/CD pipelines
- Isolated testing environments
- Quick feature testing without external dependencies

When test mode is enabled, the application bypasses Firebase authentication and uses predefined test users with mock tokens.

## Enabling Test Mode

### Option 1: Environment Variable
Add the following to your `.env` file:
```bash
TEST_MODE=true
```

### Option 2: Environment Export
Set the environment variable directly:
```bash
export TEST_MODE=true
```

### Option 3: Docker Environment
If using Docker, add it to your docker-compose file:
```yaml
environment:
  - TEST_MODE=true
```

## Test Users

The system includes **12 predefined test users** (2 per role) with realistic data:

### Admin Users
| Token | Email | Name | Firebase UID | Status |
|-------|-------|------|--------------|--------|
| `test_admin_token_001` | admin1@test.com | Test Admin One | test_admin_uid_001 | ACTIVE |
| `test_admin_token_002` | admin2@test.com | Test Admin Two | test_admin_uid_002 | ACTIVE |

### Caregiver Users
| Token | Email | Name | Firebase UID | Status |
|-------|-------|------|--------------|--------|
| `test_caregiver_token_001` | caregiver1@test.com | Test Caregiver One | test_caregiver_uid_001 | ACTIVE |
| `test_caregiver_token_002` | caregiver2@test.com | Test Caregiver Two | test_caregiver_uid_002 | PENDING_APPROVAL |

### Family Member Users
| Token | Email | Name | Firebase UID | Status |
|-------|-------|------|--------------|--------|
| `test_family_token_001` | family1@test.com | Test Family Member One | test_family_uid_001 | ACTIVE |
| `test_family_token_002` | family2@test.com | Test Family Member Two | test_family_uid_002 | ACTIVE |

### Senior Citizen Users
| Token | Email | Name | Firebase UID | Status |
|-------|-------|------|--------------|--------|
| `test_senior_token_001` | senior1@test.com | Test Senior Citizen One | test_senior_uid_001 | ACTIVE |
| `test_senior_token_002` | senior2@test.com | Test Senior Citizen Two | test_senior_uid_002 | ACTIVE |

### Interest Group Admin Users
| Token | Email | Name | Firebase UID | Status |
|-------|-------|------|--------------|--------|
| `test_groupadmin_token_001` | groupadmin1@test.com | Test Group Admin One | test_groupadmin_uid_001 | ACTIVE |
| `test_groupadmin_token_002` | groupadmin2@test.com | Test Group Admin Two | test_groupadmin_uid_002 | PENDING_APPROVAL |

### Support User Users
| Token | Email | Name | Firebase UID | Status |
|-------|-------|------|--------------|--------|
| `test_support_token_001` | support1@test.com | Test Support User One | test_support_uid_001 | ACTIVE |
| `test_support_token_002` | support2@test.com | Test Support User Two | test_support_uid_002 | ACTIVE |

### Unregistered Users (for testing registration flow)
| Token | Email | Name | Firebase UID |
|-------|-------|------|--------------|
| `test_unregistered_token_001` | unregistered1@test.com | Test Unregistered User One | test_unregistered_uid_001 |
| `test_unregistered_token_002` | unregistered2@test.com | Test Unregistered User Two | test_unregistered_uid_002 |

## Usage Examples

### Using Bruno/Postman

1. **Set the base URL**: `http://localhost:8000`
2. **Use test tokens**: Replace Firebase tokens with test tokens from the table above
3. **Example request**:
   ```json
   POST /api/auth/verify-token
   {
     "id_token": "test_admin_token_001"
   }
   ```

### Using cURL

```bash
# Test admin authentication
curl -X POST http://localhost:8000/api/auth/verify-token \
  -H "Content-Type: application/json" \
  -d '{"id_token": "test_admin_token_001"}'

# Test caregiver authentication
curl -X POST http://localhost:8000/api/auth/verify-token \
  -H "Content-Type: application/json" \
  -d '{"id_token": "test_caregiver_token_001"}'
```

### Testing Different Scenarios

#### 1. Testing Existing User Authentication
```json
POST /api/auth/verify-token
{
  "id_token": "test_admin_token_001"
}
```
**Expected Response**: 200 with user data

#### 2. Testing Unregistered User
```json
POST /api/auth/verify-token
{
  "id_token": "test_unregistered_token_001"
}
```
**Expected Response**: 201 with unregistered user info

#### 3. Testing User Registration
```json
POST /api/auth/register
{
  "id_token": "test_unregistered_token_001",
  "full_name": "New Test User",
  "role": "family_member",
  "date_of_birth": "1990-01-01"
}
```
**Expected Response**: 201 with newly registered user (mock data in test mode)

#### 4. Testing Role-Based Access
Use tokens with specific roles to test different endpoints:
- Admin endpoints: Use `test_admin_token_001` or `test_admin_token_002`
- Caregiver endpoints: Use `test_caregiver_token_001` or `test_caregiver_token_002`
- Family member endpoints: Use `test_family_token_001` or `test_family_token_002`

## Bruno Test Collection Updates

Update your Bruno environment variables for local testing:

```json
{
  "name": "Local Test Mode",
  "values": [
    {
      "name": "baseUrl",
      "value": "http://localhost:8000"
    },
    {
      "name": "adminToken",
      "value": "test_admin_token_001"
    },
    {
      "name": "userToken",
      "value": "test_senior_token_001"
    },
    {
      "name": "caregiverToken",
      "value": "test_caregiver_token_001"
    }
  ]
}
```

## Important Notes

### ⚠️ Limitations in Test Mode

1. **Database Operations**: User registration in test mode returns mock data and doesn't actually save to the database
2. **YouTube Processing**: YouTube video processing is skipped in test mode
3. **Firebase Features**: All Firebase-specific features are bypassed
4. **Data Persistence**: Test mode uses in-memory data that resets on server restart

### 🚨 Security Considerations

1. **Never use test mode in production**
2. **Test tokens are publicly known and should only be used in development**
3. **Always set `TEST_MODE=false` or omit it entirely in production environments**

### 🔧 Debugging

When test mode is enabled, you'll see log messages like:
```
Test mode enabled - Firebase Admin SDK initialization skipped
Test Auth Service initialized - Firebase authentication bypassed
Test token verified for user: test_admin_uid_001
```

## Switching Back to Production Mode

To disable test mode:

1. **Remove from .env**: Delete `TEST_MODE=true` line
2. **Set to false**: Change to `TEST_MODE=false`
3. **Unset environment**: `unset TEST_MODE`
4. **Restart the server** to ensure changes take effect

## Troubleshooting

### Common Issues

1. **"Invalid test token" error**
   - Ensure you're using exact token values from the tables above
   - Check that TEST_MODE=true is set correctly

2. **Server still trying to connect to Firebase**
   - Restart the server after setting TEST_MODE=true
   - Verify the environment variable is loaded correctly

3. **Bruno tests failing**
   - Update your environment variables to use test tokens
   - Ensure baseUrl points to your local server

### Verification

To verify test mode is working:
```bash
# Check server logs for test mode initialization
grep "Test mode enabled" logs/app.log

# Test a simple auth request
curl -X POST http://localhost:8000/api/auth/verify-token \
  -H "Content-Type: application/json" \
  -d '{"id_token": "test_admin_token_001"}'
```

## Contributing

When adding new test users or modifying test data:

1. Update `app/modules/auth/test_data.py`
2. Update this documentation
3. Update Bruno test collections if needed
4. Test all user roles and scenarios
