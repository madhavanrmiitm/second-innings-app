class TestModeConfig {
  // Test mode flag - set to false for production
  static const bool isTestMode = true;

  // Test users data - Based on story characters and additional test users
  static const List<TestUser> testUsers = [
    // Admin Users
    TestUser(
      token: 'admin_ashwin_token_001',
      email: '21f3001600@ds.study.iitm.ac.in',
      name: 'Ashwin Narayanan S',
      firebaseUid: 'qEGg9NTOjfgSaw646IhSRCXKtaZ2',
      status: 'ACTIVE',
      role: 'admin',
      dateOfBirth: '1990-01-01',
      description: 'System administrator',
      tags: 'admin,system',
    ),
    TestUser(
      token: 'admin_nakshatra_token_001',
      email: 'nakshatra.nsb@gmail.com',
      name: 'Nakshatra Gupta',
      firebaseUid: '4N2P7ZAWGPgXXoQmp2YAKXJTw253',
      status: 'ACTIVE',
      role: 'admin',
      dateOfBirth: '1990-01-01',
      description: 'System administrator',
      tags: 'admin,system',
    ),

    // Story Characters - Senior Citizens
    TestUser(
      token: 'story_asha_token_001',
      email: 'asha.senior@example.com',
      name: 'Asha',
      firebaseUid: 'story_asha_uid_001',
      status: 'ACTIVE',
      role: 'senior_citizen',
      dateOfBirth: '1945-03-15',
      description:
          '80-year-old Indian woman with kind eyes, short grey hair, and glasses. Enjoys gardening and staying active.',
      tags: 'senior,indian,gardening,active',
    ),
    TestUser(
      token: 'test_senior_token_002',
      email: 'senior2@test.com',
      name: 'Test Senior Citizen Two',
      firebaseUid: 'test_senior_uid_002',
      status: 'ACTIVE',
      role: 'senior_citizen',
      dateOfBirth: '1950-09-30',
      description: 'Former engineer with passion for gardening',
      tags: 'senior,engineer,gardening',
    ),

    // Story Characters - Family Members
    TestUser(
      token: 'story_rohan_token_001',
      email: 'rohan.family@example.com',
      name: 'Rohan',
      firebaseUid: 'story_rohan_uid_001',
      status: 'ACTIVE',
      role: 'family_member',
      dateOfBirth: '1980-08-22',
      description:
          '45-year-old professional Indian man with short black hair and grey streaks at temples. Caring son managing his mother Asha\'s care.',
      tags: 'family,professional,caring,indian',
    ),
    TestUser(
      token: 'test_family_token_002',
      email: 'family2@test.com',
      name: 'Test Family Member Two',
      firebaseUid: 'test_family_uid_002',
      status: 'ACTIVE',
      role: 'family_member',
      dateOfBirth: '1988-04-18',
      description: 'Devoted child managing care for senior citizen',
      tags: 'family,devoted',
    ),

    // Story Characters - Caregivers
    TestUser(
      token: 'story_priya_token_001',
      email: 'priya.caregiver@example.com',
      name: 'Priya',
      firebaseUid: 'story_priya_uid_001',
      status: 'ACTIVE',
      role: 'caregiver',
      dateOfBirth: '1997-11-08',
      description:
          '28-year-old Indian woman with warm smile and long dark hair in ponytail. Specializes in physiotherapy and companionship.',
      tags: 'caregiver,physiotherapy,companionship,indian',
      youtubeUrl: 'https://www.youtube.com/watch?v=priya_intro',
    ),
    TestUser(
      token: 'test_caregiver_token_002',
      email: 'caregiver2@test.com',
      name: 'Test Caregiver Two',
      firebaseUid: 'test_caregiver_uid_002',
      status: 'PENDING_APPROVAL',
      role: 'caregiver',
      dateOfBirth: '1990-08-25',
      description: 'Certified nurse with 5 years of experience in home care',
      tags: 'caregiver,nurse,home-care',
      youtubeUrl: 'https://www.youtube.com/watch?v=test2',
    ),

    // Story Characters - Interest Group Admins
    TestUser(
      token: 'story_verma_token_001',
      email: 'verma.groupadmin@example.com',
      name: 'Mr. Verma',
      firebaseUid: 'story_verma_uid_001',
      status: 'ACTIVE',
      role: 'interest_group_admin',
      dateOfBirth: '1955-06-10',
      description:
          '70-year-old retired Indian gentleman with cheerful demeanor, neat white mustache, and glasses. Community leader organizing activities for seniors.',
      tags: 'group-admin,retired,community,indian',
      youtubeUrl: 'https://www.youtube.com/watch?v=verma_intro',
    ),
    TestUser(
      token: 'test_groupadmin_token_002',
      email: 'groupadmin2@test.com',
      name: 'Test Group Admin Two',
      firebaseUid: 'test_groupadmin_uid_002',
      status: 'PENDING_APPROVAL',
      role: 'interest_group_admin',
      dateOfBirth: '1972-11-08',
      description: 'Art therapist creating engaging programs for elderly',
      tags: 'group-admin,art-therapy,programs',
      youtubeUrl: 'https://www.youtube.com/watch?v=testgroup2',
    ),

    // Support Users
    TestUser(
      token: 'test_support_token_001',
      email: 'support1@test.com',
      name: 'Test Support User One',
      firebaseUid: 'test_support_uid_001',
      status: 'ACTIVE',
      role: 'support_user',
      dateOfBirth: '1992-01-12',
      description: 'Support specialist helping users with platform issues',
      tags: 'support,specialist',
    ),
    TestUser(
      token: 'test_support_token_002',
      email: 'support2@test.com',
      name: 'Test Support User Two',
      firebaseUid: 'test_support_uid_002',
      status: 'ACTIVE',
      role: 'support_user',
      dateOfBirth: '1987-05-07',
      description: 'Customer service representative for platform support',
      tags: 'support,customer-service',
    ),

    // Legacy test users for backward compatibility
    TestUser(
      token: 'test_caregiver_token_001',
      email: 'caregiver1@test.com',
      name: 'Test Caregiver One',
      firebaseUid: 'test_caregiver_uid_001',
      status: 'ACTIVE',
      role: 'caregiver',
      dateOfBirth: '1990-01-01',
      description: 'Legacy test caregiver user',
      tags: 'caregiver,legacy',
    ),
    TestUser(
      token: 'test_family_token_001',
      email: 'family1@test.com',
      name: 'Test Family Member One',
      firebaseUid: 'test_family_uid_001',
      status: 'ACTIVE',
      role: 'family_member',
      dateOfBirth: '1990-01-01',
      description: 'Legacy test family member user',
      tags: 'family,legacy',
    ),
    TestUser(
      token: 'test_senior_token_001',
      email: 'senior1@test.com',
      name: 'Test Senior Citizen One',
      firebaseUid: 'test_senior_uid_001',
      status: 'ACTIVE',
      role: 'senior_citizen',
      dateOfBirth: '1990-01-01',
      description: 'Legacy test senior citizen user',
      tags: 'senior,legacy',
    ),

    // Unregistered Users (for testing registration flow)
    TestUser(
      token: 'test_unregistered_token_001',
      email: 'unregistered1@test.com',
      name: 'Test Unregistered User One',
      firebaseUid: 'test_unregistered_uid_001',
      status: 'UNREGISTERED',
      role: 'unregistered',
      dateOfBirth: '1990-01-01',
      description: 'Unregistered test user',
      tags: 'unregistered,test',
    ),
    TestUser(
      token: 'test_unregistered_token_002',
      email: 'unregistered2@test.com',
      name: 'Test Unregistered User Two',
      firebaseUid: 'test_unregistered_uid_002',
      status: 'UNREGISTERED',
      role: 'unregistered',
      dateOfBirth: '1990-01-01',
      description: 'Unregistered test user',
      tags: 'unregistered,test',
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

  // Get story characters specifically
  static List<TestUser> getStoryCharacters() {
    return testUsers
        .where(
          (user) =>
              user.name == 'Asha' ||
              user.name == 'Rohan' ||
              user.name == 'Priya' ||
              user.name == 'Mr. Verma',
        )
        .toList();
  }

  // Get admin users
  static List<TestUser> getAdminUsers() {
    return testUsers.where((user) => user.role == 'admin').toList();
  }

  // Get support users
  static List<TestUser> getSupportUsers() {
    return testUsers.where((user) => user.role == 'support_user').toList();
  }
}

class TestUser {
  final String token;
  final String email;
  final String name;
  final String firebaseUid;
  final String status;
  final String role;
  final String? dateOfBirth;
  final String? description;
  final String? tags;
  final String? youtubeUrl;

  const TestUser({
    required this.token,
    required this.email,
    required this.name,
    required this.firebaseUid,
    required this.status,
    required this.role,
    this.dateOfBirth,
    this.description,
    this.tags,
    this.youtubeUrl,
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
      'date_of_birth': dateOfBirth ?? '1990-01-01',
      'description': description,
      'tags': tags,
      'youtube_url': youtubeUrl,
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
      case 'admin':
        return 'Administrator';
      case 'caregiver':
        return 'Caregiver';
      case 'family_member':
        return 'Family Member';
      case 'senior_citizen':
        return 'Senior Citizen';
      case 'interest_group_admin':
        return 'Interest Group Admin';
      case 'support_user':
        return 'Support User';
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

  // Check if user is a story character
  bool get isStoryCharacter {
    return name == 'Asha' ||
        name == 'Rohan' ||
        name == 'Priya' ||
        name == 'Mr. Verma';
  }

  // Get age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    try {
      final birthDate = DateTime.parse(dateOfBirth!);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }
}
