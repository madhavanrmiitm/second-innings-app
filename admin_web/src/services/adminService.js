import { ApiService } from './apiService'
import { FirebaseAuthService } from './firebaseAuth'
import { TestAuthService } from './testAuthService'

export class AdminService {
  static get apiPrefix() {
    return '/api/admin'
  }

  static async getAuthHeaders() {
    try {
      if (TestAuthService.isTestModeEnabled()) {
        const testToken = localStorage.getItem('testToken') || sessionStorage.getItem('testToken')
        if (testToken) {
          return { Authorization: `Bearer ${testToken}` }
        }
        console.warn('Test mode enabled but no test token found. Please sign in with a test user first.')
        return {}
      }

      const idToken = await FirebaseAuthService.getCurrentUserIdToken()
      if (idToken) {
        return { Authorization: `Bearer ${idToken}` }
      }

      console.warn('No authentication token available')
      return {}
    } catch (error) {
      console.error('Failed to get auth headers:', error)
      return {}
    }
  }

  static async getAllUsers() {
    try {
      const headers = await this.getAuthHeaders()
      const response = await ApiService.get(`${this.apiPrefix}/users`, {
        headers
      })

      if (response.isSuccess) {
        return {
          success: true,
          users: response.data?.data?.users || [],
          message: response.data?.message
        }
      } else {
        return {
          success: false,
          error: response.error,
          users: []
        }
      }
    } catch (error) {
      console.error('Failed to fetch users:', error)
      return {
        success: false,
        error: 'Failed to fetch users',
        users: []
      }
    }
  }

  static async deleteUser(userId, idToken) {
    try {
      let headers
      if (idToken) {
        headers = { Authorization: `Bearer ${idToken}` }
      } else {
        headers = await this.getAuthHeaders()
      }

      const response = await ApiService.delete(`${this.apiPrefix}/users/${userId}`, {
        headers: {
          ...headers,
          'Content-Type': 'application/json'
        },
        body: {
          id_token: idToken
        }
      })

      if (response.isSuccess) {
        return {
          success: true,
          message: response.data?.message || 'User deleted successfully'
        }
      } else {
        return {
          success: false,
          error: response.error
        }
      }
    } catch (error) {
      console.error('Failed to delete user:', error)
      return {
        success: false,
        error: 'Failed to delete user'
      }
    }
  }

  static async getCaregivers() {
    try {
      const headers = await this.getAuthHeaders()
      const response = await ApiService.get(`${this.apiPrefix}/caregivers`, {
        headers
      })

      if (response.isSuccess) {
        return {
          success: true,
          caregivers: response.data?.data?.caregivers || [],
          message: response.data?.message
        }
      } else {
        return {
          success: false,
          error: response.error,
          caregivers: []
        }
      }
    } catch (error) {
      console.error('Failed to fetch caregivers:', error)
      return {
        success: false,
        error: 'Failed to fetch caregivers',
        caregivers: []
      }
    }
  }

  static async verifyCaregiver(caregiverId, status, idToken) {
    try {
      const headers = await this.getAuthHeaders()
      const response = await ApiService.post(`${this.apiPrefix}/caregivers/${caregiverId}/verify`, {
        body: {
          id_token: idToken,
          status: status
        },
        headers
      })

      if (response.isSuccess) {
        return {
          success: true,
          message: response.data?.message || `Caregiver status updated to ${status}`
        }
      } else {
        return {
          success: false,
          error: response.error
        }
      }
    } catch (error) {
      console.error('Failed to verify caregiver:', error)
      return {
        success: false,
        error: 'Failed to verify caregiver'
      }
    }
  }

  static async getInterestGroupAdmins() {
    try {
      const headers = await this.getAuthHeaders()
      const response = await ApiService.get(`${this.apiPrefix}/interest-group-admins`, {
        headers
      })

      if (response.isSuccess) {
        return {
          success: true,
          interestGroupAdmins: response.data?.data?.interest_group_admins || [],
          message: response.data?.message
        }
      } else {
        return {
          success: false,
          error: response.error,
          interestGroupAdmins: []
        }
      }
    } catch (error) {
      console.error('Failed to fetch interest group admins:', error)
      return {
        success: false,
        error: 'Failed to fetch interest group admins',
        interestGroupAdmins: []
      }
    }
  }

  static async verifyInterestGroupAdmin(interestGroupAdminId, status, idToken) {
    try {
      const headers = await this.getAuthHeaders()
      const response = await ApiService.post(`${this.apiPrefix}/interest-group-admins/${interestGroupAdminId}/verify`, {
        body: {
          id_token: idToken,
          status: status
        },
        headers
      })

      if (response.isSuccess) {
        return {
          success: true,
          message: response.data?.message || `Interest group admin status updated to ${status}`
        }
      } else {
        return {
          success: false,
          error: response.error
        }
      }
    } catch (error) {
      console.error('Failed to verify interest group admin:', error)
      return {
        success: false,
        error: 'Failed to verify interest group admin'
      }
    }
  }

  static async getAdminStats() {
    try {
      const [usersResponse, caregiversResponse, interestGroupAdminsResponse] = await Promise.all([
        this.getAllUsers(),
        this.getCaregivers(),
        this.getInterestGroupAdmins()
      ])

      const users = usersResponse.users || []
      const caregivers = caregiversResponse.caregivers || []
      const interestGroupAdmins = interestGroupAdminsResponse.interestGroupAdmins || []

      return {
        success: true,
        stats: {
          totalUsers: users.length,
          activeUsers: users.filter(u => u.status === 'active').length,
          pendingUsers: users.filter(u => u.status === 'pending_approval').length,
          blockedUsers: users.filter(u => u.status === 'blocked').length,
          pendingCaregivers: caregivers.length,
          totalCaregivers: caregivers.length,
          pendingInterestGroupAdmins: interestGroupAdmins.length,
          totalInterestGroupAdmins: interestGroupAdmins.length,
          adminUsers: users.filter(u => u.role === 'admin').length,
          supportUsers: users.filter(u => u.role === 'support_user').length,
          igaUsers: users.filter(u => u.role === 'interest_group_admin').length
        }
      }
    } catch (error) {
      console.error('Failed to fetch admin stats:', error)
      return {
        success: false,
        error: 'Failed to fetch admin statistics',
        stats: {}
      }
    }
  }
}
