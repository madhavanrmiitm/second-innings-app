class TestModeConfig {
  // Test mode flag - set to false for production
  static const bool isTestMode = true;

  // Test users data - Only 3 main roles: Caregiver, Family Member, Senior Citizen
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
    TestUser(
      token: 'test_caregiver_token_002',
      email: 'caregiver2@test.com',
      name: 'Test Caregiver Two',
      firebaseUid: 'test_caregiver_uid_002',
      status: 'PENDING_APPROVAL',
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
    TestUser(
      token: 'test_family_token_002',
      email: 'family2@test.com',
      name: 'Test Family Member Two',
      firebaseUid: 'test_family_uid_002',
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
    TestUser(
      token: 'test_senior_token_002',
      email: 'senior2@test.com',
      name: 'Test Senior Citizen Two',
      firebaseUid: 'test_senior_uid_002',
      status: 'ACTIVE',
      role: 'senior_citizen',
    ),

    // Unregistered Users (for testing registration flow)
    TestUser(
      token: 'test_unregistered_token_001',
      email: 'unregistered1@test.com',
      name: 'Test Unregistered User One',
      firebaseUid: 'test_unregistered_uid_001',
      status: 'UNREGISTERED',
      role: 'unregistered',
    ),
    TestUser(
      token: 'test_unregistered_token_002',
      email: 'unregistered2@test.com',
      name: 'Test Unregistered User Two',
      firebaseUid: 'test_unregistered_uid_002',
      status: 'UNREGISTERED',
      role: 'unregistered',
    ),
  ];

  // Get test users by role
  static List<TestUser> getTestUsersByRole(String role) {
    return testUsers.where((user) => user.role == role).toList();
  }

  // Get all active test users
  static List<TestUser> getActiveTestUsers() {
    return testUsers.where((user) => user.status == 'ACTIVE').toList();
  }

  // Get test user by token
  static TestUser? getTestUserByToken(String token) {
    try {
      return testUsers.firstWhere((user) => user.token == token);
    } catch (e) {
      return null;
    }
  }

  // Get test users by status
  static List<TestUser> getTestUsersByStatus(String status) {
    return testUsers.where((user) => user.status == status).toList();
  }
}

class TestUser {
  final String token;
  final String email;
  final String name;
  final String firebaseUid;
  final String status;
  final String role;

  const TestUser({
    required this.token,
    required this.email,
    required this.name,
    required this.firebaseUid,
    required this.status,
    required this.role,
  });

  // Convert to user data map for storage
  Map<String, dynamic> toUserData() {
    return {
      'id': firebaseUid,
      'gmail_id': email,
      'firebase_uid': firebaseUid,
      'full_name': name,
      'email': email,
      'role': role,
      'status': status,
      'user_type': role,
      'date_of_birth': '1990-01-01', // Default for test users
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Get display name for UI
  String get displayName {
    return name;
  }

  // Get role display name
  String get roleDisplayName {
    switch (role) {
      case 'caregiver':
        return 'Caregiver';
      case 'family_member':
        return 'Family Member';
      case 'senior_citizen':
        return 'Senior Citizen';
      case 'unregistered':
        return 'Unregistered User';
      default:
        return role;
    }
  }

  // Get status display name
  String get statusDisplayName {
    switch (status) {
      case 'ACTIVE':
        return 'Active';
      case 'PENDING_APPROVAL':
        return 'Pending Approval';
      case 'BLOCKED':
        return 'Blocked';
      case 'UNREGISTERED':
        return 'Unregistered';
      default:
        return status;
    }
  }

  // Check if user is active
  bool get isActive => status == 'ACTIVE';

  // Check if user is blocked
  bool get isBlocked => status == 'BLOCKED';

  // Check if user is pending approval
  bool get isPendingApproval => status == 'PENDING_APPROVAL';

  // Check if user is unregistered
  bool get isUnregistered => status == 'UNREGISTERED';
}
