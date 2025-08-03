// Test Authentication Service for Development/Testing Mode
// This service provides predefined test users and bypasses Firebase authentication

export class TestAuthService {
  // Test Users Data from Backend Documentation
  static get testUsers() {
    return {
      // Admin Users
      test_admin_token_001: {
        token: 'test_admin_token_001',
        email: 'admin1@test.com',
        name: 'Test Admin One',
        firebase_uid: 'test_admin_uid_001',
        role: 'admin',
        status: 'ACTIVE',
        id: 1,
        full_name: 'Test Admin One',
        date_of_birth: '1980-01-01',
        created_at: '2024-01-01T00:00:00Z'
      },
      test_admin_token_002: {
        token: 'test_admin_token_002',
        email: 'admin2@test.com',
        name: 'Test Admin Two',
        firebase_uid: 'test_admin_uid_002',
        role: 'admin',
        status: 'ACTIVE',
        id: 2,
        full_name: 'Test Admin Two',
        date_of_birth: '1981-01-01',
        created_at: '2024-01-01T00:00:00Z'
      },

      // Caregiver Users
      test_caregiver_token_001: {
        token: 'test_caregiver_token_001',
        email: 'caregiver1@test.com',
        name: 'Test Caregiver One',
        firebase_uid: 'test_caregiver_uid_001',
        role: 'caregiver',
        status: 'ACTIVE',
        id: 3,
        full_name: 'Test Caregiver One',
        date_of_birth: '1985-01-01',
        created_at: '2024-01-01T00:00:00Z'
      },
      test_caregiver_token_002: {
        token: 'test_caregiver_token_002',
        email: 'caregiver2@test.com',
        name: 'Test Caregiver Two',
        firebase_uid: 'test_caregiver_uid_002',
        role: 'caregiver',
        status: 'PENDING_APPROVAL',
        id: 4,
        full_name: 'Test Caregiver Two',
        date_of_birth: '1986-01-01',
        created_at: '2024-01-01T00:00:00Z'
      },

      // Family Member Users
      test_family_token_001: {
        token: 'test_family_token_001',
        email: 'family1@test.com',
        name: 'Test Family Member One',
        firebase_uid: 'test_family_uid_001',
        role: 'family_member',
        status: 'ACTIVE',
        id: 5,
        full_name: 'Test Family Member One',
        date_of_birth: '1990-01-01',
        created_at: '2024-01-01T00:00:00Z'
      },
      test_family_token_002: {
        token: 'test_family_token_002',
        email: 'family2@test.com',
        name: 'Test Family Member Two',
        firebase_uid: 'test_family_uid_002',
        role: 'family_member',
        status: 'ACTIVE',
        id: 6,
        full_name: 'Test Family Member Two',
        date_of_birth: '1991-01-01',
        created_at: '2024-01-01T00:00:00Z'
      },

      // Senior Citizen Users
      test_senior_token_001: {
        token: 'test_senior_token_001',
        email: 'senior1@test.com',
        name: 'Test Senior Citizen One',
        firebase_uid: 'test_senior_uid_001',
        role: 'senior_citizen',
        status: 'ACTIVE',
        id: 7,
        full_name: 'Test Senior Citizen One',
        date_of_birth: '1950-01-01',
        created_at: '2024-01-01T00:00:00Z'
      },
      test_senior_token_002: {
        token: 'test_senior_token_002',
        email: 'senior2@test.com',
        name: 'Test Senior Citizen Two',
        firebase_uid: 'test_senior_uid_002',
        role: 'senior_citizen',
        status: 'ACTIVE',
        id: 8,
        full_name: 'Test Senior Citizen Two',
        date_of_birth: '1951-01-01',
        created_at: '2024-01-01T00:00:00Z'
      },

      // Interest Group Admin Users
      test_groupadmin_token_001: {
        token: 'test_groupadmin_token_001',
        email: 'groupadmin1@test.com',
        name: 'Test Group Admin One',
        firebase_uid: 'test_groupadmin_uid_001',
        role: 'interest_group_admin',
        status: 'ACTIVE',
        id: 9,
        full_name: 'Test Group Admin One',
        date_of_birth: '1975-01-01',
        created_at: '2024-01-01T00:00:00Z'
      },
      test_groupadmin_token_002: {
        token: 'test_groupadmin_token_002',
        email: 'groupadmin2@test.com',
        name: 'Test Group Admin Two',
        firebase_uid: 'test_groupadmin_uid_002',
        role: 'interest_group_admin',
        status: 'PENDING_APPROVAL',
        id: 10,
        full_name: 'Test Group Admin Two',
        date_of_birth: '1976-01-01',
        created_at: '2024-01-01T00:00:00Z'
      },

      // Support User Users
      test_support_token_001: {
        token: 'test_support_token_001',
        email: 'support1@test.com',
        name: 'Test Support User One',
        firebase_uid: 'test_support_uid_001',
        role: 'support_user',
        status: 'ACTIVE',
        id: 11,
        full_name: 'Test Support User One',
        date_of_birth: '1988-01-01',
        created_at: '2024-01-01T00:00:00Z'
      },
      test_support_token_002: {
        token: 'test_support_token_002',
        email: 'support2@test.com',
        name: 'Test Support User Two',
        firebase_uid: 'test_support_uid_002',
        role: 'support_user',
        status: 'ACTIVE',
        id: 12,
        full_name: 'Test Support User Two',
        date_of_birth: '1989-01-01',
        created_at: '2024-01-01T00:00:00Z'
      },

      // Unregistered Users (for testing registration flow)
      test_unregistered_token_001: {
        token: 'test_unregistered_token_001',
        email: 'unregistered1@test.com',
        name: 'Test Unregistered User One',
        firebase_uid: 'test_unregistered_uid_001',
        role: null,
        status: 'UNREGISTERED',
        id: null,
        full_name: 'Test Unregistered User One',
        date_of_birth: null,
        created_at: null
      },
      test_unregistered_token_002: {
        token: 'test_unregistered_token_002',
        email: 'unregistered2@test.com',
        name: 'Test Unregistered User Two',
        firebase_uid: 'test_unregistered_uid_002',
        role: null,
        status: 'UNREGISTERED',
        id: null,
        full_name: 'Test Unregistered User Two',
        date_of_birth: null,
        created_at: null
      }
    }
  }

  // Get test users grouped by role for UI display
  static get testUsersByRole() {
    const users = this.testUsers
    const grouped = {}

    Object.values(users).forEach(user => {
      const role = user.role || 'unregistered'
      if (!grouped[role]) {
        grouped[role] = []
      }
      grouped[role].push(user)
    })

    return grouped
  }

  // Get user by token
  static getUserByToken(token) {
    return this.testUsers[token] || null
  }

  // Check if test mode is enabled
  static isTestModeEnabled() {
    // Check for VITE_TEST_MODE environment variable
    return import.meta.env.VITE_TEST_MODE === 'true'
  }

  // Simulate Firebase sign-in with test user
  static async signInWithTestUser(token) {
    try {
      const user = this.getUserByToken(token)

      if (!user) {
        return {
          success: false,
          error: 'Invalid test token'
        }
      }

      // Simulate Firebase user object
      return {
        success: true,
        user: {
          uid: user.firebase_uid,
          email: user.email,
          displayName: user.full_name,
          photoURL: null
        },
        idToken: token // Use the test token as ID token
      }
    } catch (error) {
      console.error('Test Sign-In Error:', error)
      return {
        success: false,
        error: error.message
      }
    }
  }

  // Get all test users for selection UI
  static getTestUsersForSelection() {
    const users = Object.values(this.testUsers)

    // Group users by role for better organization
    const roleOrder = ['admin', 'support_user', 'interest_group_admin', 'caregiver', 'family_member', 'senior_citizen', 'unregistered']
    const roleLabels = {
      admin: 'Admin',
      support_user: 'Support User',
      interest_group_admin: 'Interest Group Admin',
      caregiver: 'Caregiver',
      family_member: 'Family Member',
      senior_citizen: 'Senior Citizen',
      unregistered: 'Unregistered'
    }

    const grouped = {}

    users.forEach(user => {
      const role = user.role || 'unregistered'
      if (!grouped[role]) {
        grouped[role] = {
          label: roleLabels[role] || role,
          users: []
        }
      }
      grouped[role].users.push({
        token: user.token,
        name: user.full_name,
        email: user.email,
        status: user.status,
        role: user.role
      })
    })

    // Return in the defined order
    return roleOrder
      .filter(role => grouped[role])
      .map(role => ({
        role,
        ...grouped[role]
      }))
  }

  // Sign out (no-op for test mode)
  static async signOut() {
    return { success: true }
  }

  // Get current user ID token (return the stored test token)
  static async getCurrentUserIdToken() {
    // In test mode, we'd need to store the current test token somewhere
    // For now, return null as we don't have session persistence for test tokens
    return null
  }

  // Check if user is signed in (always false in test mode since we don't persist)
  static isSignedIn() {
    return false
  }

  // Get current user info (always null in test mode since we don't persist)
  static getCurrentUserInfo() {
    return null
  }

  // Listen to auth state changes (no-op for test mode)
  static onAuthStateChanged(callback) {
    // Return a no-op unsubscribe function
    return () => {}
  }

  // Get current user (always null in test mode since we don't persist)
  static getCurrentUser() {
    return null
  }
}
