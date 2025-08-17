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

The system includes **story characters** and **additional test users** with realistic data:

### Story Characters (Primary Test Users)

#### Asha - Senior Citizen
| Token | Email | Name | Firebase UID | Status |
|-------|-------|------|--------------|--------|
| `story_asha_token_001` | asha.senior@example.com | Asha | story_asha_uid_001 | ACTIVE |

**Description**: 80-year-old Indian woman with kind eyes, short grey hair, and glasses. Enjoys gardening and staying active.

#### Rohan - Family Member
| Token | Email | Name | Firebase UID | Status |
|-------|-------|------|--------------|--------|
| `story_rohan_token_001` | rohan.family@example.com | Rohan | story_rohan_uid_001 | ACTIVE |

**Description**: 45-year-old professional Indian man with short black hair and grey streaks at temples. Caring son managing his mother Asha's care.

#### Priya - Caregiver
| Token | Email | Name | Firebase UID | Status |
|-------|-------|------|--------------|--------|
| `story_priya_token_001` | priya.caregiver@example.com | Priya | story_priya_uid_001 | ACTIVE |

**Description**: 28-year-old Indian woman with warm smile and long dark hair in ponytail. Specializes in physiotherapy and companionship.

#### Mr. Verma - Interest Group Admin
| Token | Email | Name | Firebase UID | Status |
|-------|-------|------|--------------|--------|
| `story_verma_token_001` | verma.groupadmin@example.com | Mr. Verma | story_verma_uid_001 | ACTIVE |

**Description**: 70-year-old retired Indian gentleman with cheerful demeanor, neat white mustache, and glasses. Community leader organizing activities for seniors.

### Backward Compatibility Tokens

For existing tests and API calls, the following legacy tokens are still supported and map to story characters:

| Legacy Token | Maps To | Story Character | Use Case |
|--------------|---------|-----------------|----------|
| `test_caregiver_token_001` | `story_priya_token_001` | Priya | Caregiver features, care requests |
| `test_family_token_001` | `story_rohan_token_001` | Rohan | Family member features, task management |
| `test_senior_token_001` | `story_asha_token_001` | Asha | Senior citizen features, local groups |
| `test_groupadmin_token_001` | `story_verma_token_001` | Mr. Verma | Group management, community features |

**Note**: These backward compatibility tokens provide the same functionality as the story character tokens, ensuring existing tests continue to work while using the new story-based data.

### Complete Token Reference

For quick reference, here's the complete mapping of all available tokens:

| Token | Maps To | Role | Description |
|-------|---------|------|-------------|
| `story_asha_token_001` | Asha | Senior Citizen | Primary story character |
| `story_rohan_token_001` | Rohan | Family Member | Primary story character |
| `story_priya_token_001` | Priya | Caregiver | Primary story character |
| `story_verma_token_001` | Mr. Verma | Interest Group Admin | Primary story character |
| `test_caregiver_token_001` | Priya | Caregiver | Backward compatibility |
| `test_family_token_001` | Rohan | Family Member | Backward compatibility |
| `test_senior_token_001` | Asha | Senior Citizen | Backward compatibility |
| `test_groupadmin_token_001` | Mr. Verma | Interest Group Admin | Backward compatibility |
| `test_admin_token_001` | Ashwin | Admin | System admin |
| `test_admin_token_002` | Nakshatra | Admin | System admin |
| `test_caregiver_token_002` | Test Caregiver Two | Caregiver | Additional test user |
| `test_family_token_002` | Test Family Member Two | Family Member | Additional test user |
| `test_senior_token_002` | Test Senior Citizen Two | Senior Citizen | Additional test user |
| `test_groupadmin_token_002` | Test Group Admin Two | Interest Group Admin | Additional test user |
| `test_support_token_001` | Test Support User One | Support User | Support specialist |
| `test_support_token_002` | Test Support User Two | Support User | Customer service |

### Admin Users
| Token | Email | Name | Firebase UID | Status |
|-------|-------|------|--------------|--------|
| `test_admin_token_001` | 21f3001600@ds.study.iitm.ac.in | Ashwin Narayanan S | qEGg9NTOjfgSaw646IhSRCXKtaZ2 | ACTIVE |
| `test_admin_token_002` | nakshatra.nsb@gmail.com | Nakshatra Gupta | 4N2P7ZAWGPgXXoQmp2YAKXJTw253 | ACTIVE |

### Additional Test Users

#### Caregiver Users
| Token | Email | Name | Firebase UID | Status |
|-------|-------|------|--------------|--------|
| `test_caregiver_token_002` | caregiver2@test.com | Test Caregiver Two | test_caregiver_uid_002 | PENDING_APPROVAL |

#### Family Member Users
| Token | Email | Name | Firebase UID | Status |
|-------|-------|------|--------------|--------|
| `test_family_token_002` | family2@test.com | Test Family Member Two | test_family_uid_002 | ACTIVE |

#### Senior Citizen Users
| Token | Email | Name | Firebase UID | Status |
|-------|-------|------|--------------|--------|
| `test_senior_token_002` | senior2@test.com | Test Senior Citizen Two | test_senior_uid_002 | ACTIVE |

#### Interest Group Admin Users
| Token | Email | Name | Firebase UID | Status |
|-------|-------|------|--------------|--------|
| `test_groupadmin_token_002` | groupadmin2@test.com | Test Group Admin Two | test_groupadmin_uid_002 | PENDING_APPROVAL |

#### Support User Users
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
2. **Use story character tokens**: For realistic testing scenarios
3. **Example request**:
   ```json
   POST /api/auth/verify-token
   {
     "id_token": "story_priya_token_001"
   }
   ```

### Using cURL

```bash
# Test story character authentication
curl -X POST http://localhost:8000/api/auth/verify-token \
  -H "Content-Type: application/json" \
  -d '{"id_token": "story_asha_token_001"}'

# Test caregiver authentication
curl -X POST http://localhost:8000/api/auth/verify-token \
  -H "Content-Type: application/json" \
  -d '{"id_token": "story_priya_token_001"}'
```

### Testing Story Scenarios

#### 1. Testing Asha's Experience (Senior Citizen)
```json
POST /api/auth/verify-token
{
  "id_token": "story_asha_token_001"
}
```
**Use for**: Senior citizen features, local groups discovery, task management

#### 2. Testing Rohan's Care Management (Family Member)
```json
POST /api/auth/verify-token
{
  "id_token": "story_rohan_token_001"
}
```
**Use for**: Family member features, task creation, caregiver hiring

#### 3. Testing Priya's Caregiver Profile
```json
POST /api/auth/verify-token
{
  "id_token": "story_priya_token_001"
}
```
**Use for**: Caregiver features, care requests, profile management

#### 4. Testing Mr. Verma's Group Management
```json
POST /api/auth/verify-token
{
  "id_token": "story_verma_token_001"
}
```
**Use for**: Interest group creation, group management, community features

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
      "name": "storyAshaToken",
      "value": "story_asha_token_001"
    },
    {
      "name": "storyRohanToken",
      "value": "story_rohan_token_001"
    },
    {
      "name": "storyPriyaToken",
      "value": "story_priya_token_001"
    },
    {
      "name": "storyVermaToken",
      "value": "story_verma_token_001"
    },
    {
      "name": "adminToken",
      "value": "test_admin_token_001"
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
Test token verified for user: story_asha_uid_001
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
   - Update your environment variables to use story character tokens
   - Ensure baseUrl points to your local server

### Verification

To verify test mode is working:
```bash
# Check server logs for test mode initialization
grep "Test mode enabled" logs/app.log

# Test a story character auth request
curl -X POST http://localhost:8000/api/auth/verify-token \
  -H "Content-Type: application/json" \
  -d '{"id_token": "story_asha_token_001"}'
```

## Contributing

When adding new test users or modifying test data:

1. Update `app/modules/auth/test_data.py`
2. Update this documentation
3. Update Bruno test collections if needed
4. Test all user roles and scenarios
