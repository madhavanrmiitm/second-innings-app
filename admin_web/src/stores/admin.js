import { defineStore } from 'pinia'
import { AdminService } from '@/services/adminService'
import { useAuthStore } from '@/stores/auth'
import { FirebaseAuthService } from '@/services/firebaseAuth'
import { TestAuthService } from '@/services/testAuthService'

export const useAdminStore = defineStore('admin', {
  state: () => ({
    users: [],
    caregivers: [],
    interestGroupAdmins: [],
    loading: {
      users: false,
      caregivers: false,
      interestGroupAdmins: false,
      stats: false,
      deleteUser: false,
      verifyCaregiver: false,
      verifyInterestGroupAdmin: false
    },
    error: null,
    stats: {
      totalUsers: 0,
      activeUsers: 0,
      pendingUsers: 0,
      blockedUsers: 0,
      pendingCaregivers: 0,
      totalCaregivers: 0,
      pendingInterestGroupAdmins: 0,
      totalInterestGroupAdmins: 0,
      adminUsers: 0,
      supportUsers: 0,
      igaUsers: 0
    },
    filters: {
      search: '',
      status: '',
      role: ''
    }
  }),

  getters: {
    filteredUsers: (state) => {
      let result = state.users

      if (state.filters.search) {
        const search = state.filters.search.toLowerCase()
        result = result.filter(
          (user) =>
            user.full_name?.toLowerCase().includes(search) ||
            user.gmail_id?.toLowerCase().includes(search)
        )
      }

      if (state.filters.status) {
        result = result.filter((user) => user.status === state.filters.status)
      }

      if (state.filters.role) {
        result = result.filter((user) => user.role === state.filters.role)
      }

      return result
    },

    pendingCaregivers: (state) => {
      return state.caregivers.filter(caregiver =>
        caregiver.youtube_url && caregiver.description && caregiver.tags
      )
    },

    pendingInterestGroupAdmins: (state) => {
      return state.interestGroupAdmins.filter(iga =>
        iga.youtube_url && iga.description && iga.tags
      )
    },

    usersByRole: (state) => {
      const roles = {}
      state.users.forEach(user => {
        if (!roles[user.role]) {
          roles[user.role] = []
        }
        roles[user.role].push(user)
      })
      return roles
    },

    usersByStatus: (state) => {
      const statuses = {}
      state.users.forEach(user => {
        if (!statuses[user.status]) {
          statuses[user.status] = []
        }
        statuses[user.status].push(user)
      })
      return statuses
    }
  },

  actions: {
    async fetchUsers() {
      this.loading.users = true
      this.error = null

      try {
        const response = await AdminService.getAllUsers()

        if (response.success) {
          this.users = response.users
        } else {
          this.error = response.error
          console.error('Failed to fetch users:', response.error)
        }
      } catch (error) {
        this.error = error.message
        console.error('Failed to fetch users:', error)
      } finally {
        this.loading.users = false
      }
    },

    async deleteUser(userId) {
      this.loading.deleteUser = true
      this.error = null

      try {
        let idToken
        if (TestAuthService.isTestModeEnabled()) {
          idToken = localStorage.getItem('testToken') || sessionStorage.getItem('testToken')
        } else {
          idToken = await FirebaseAuthService.getCurrentUserIdToken()
        }

        const response = await AdminService.deleteUser(userId, idToken)

        if (response.success) {
          // Remove user from local state
          this.users = this.users.filter(user => user.id !== userId)
          return { success: true, message: response.message }
        } else {
          this.error = response.error
          return { success: false, error: response.error }
        }
      } catch (error) {
        this.error = error.message
        console.error('Failed to delete user:', error)
        return { success: false, error: error.message }
      } finally {
        this.loading.deleteUser = false
      }
    },

    async fetchCaregivers() {
      this.loading.caregivers = true
      this.error = null

      try {
        const response = await AdminService.getCaregivers()

        if (response.success) {
          this.caregivers = response.caregivers
        } else {
          this.error = response.error
          console.error('Failed to fetch caregivers:', response.error)
        }
      } catch (error) {
        this.error = error.message
        console.error('Failed to fetch caregivers:', error)
      } finally {
        this.loading.caregivers = false
      }
    },

    async verifyCaregiver(caregiverId, status) {
      this.loading.verifyCaregiver = true
      this.error = null

      try {
        let idToken
        if (TestAuthService.isTestModeEnabled()) {
          idToken = localStorage.getItem('testToken') || sessionStorage.getItem('testToken')
        } else {
          idToken = await FirebaseAuthService.getCurrentUserIdToken()
        }

        const response = await AdminService.verifyCaregiver(caregiverId, status, idToken)

        if (response.success) {
          // Update caregiver status in local state or remove from pending list
          if (status === 'active') {
            this.caregivers = this.caregivers.filter(c => c.id !== caregiverId)
          }
          return { success: true, message: response.message }
        } else {
          this.error = response.error
          return { success: false, error: response.error }
        }
      } catch (error) {
        this.error = error.message
        console.error('Failed to verify caregiver:', error)
        return { success: false, error: error.message }
      } finally {
        this.loading.verifyCaregiver = false
      }
    },

    async fetchInterestGroupAdmins() {
      this.loading.interestGroupAdmins = true
      this.error = null

      try {
        const response = await AdminService.getInterestGroupAdmins()

        if (response.success) {
          this.interestGroupAdmins = response.interestGroupAdmins
        } else {
          this.error = response.error
          console.error('Failed to fetch interest group admins:', response.error)
        }
      } catch (error) {
        this.error = error.message
        console.error('Failed to fetch interest group admins:', error)
      } finally {
        this.loading.interestGroupAdmins = false
      }
    },

    async verifyInterestGroupAdmin(interestGroupAdminId, status) {
      this.loading.verifyInterestGroupAdmin = true
      this.error = null

      try {
        let idToken
        if (TestAuthService.isTestModeEnabled()) {
          idToken = localStorage.getItem('testToken') || sessionStorage.getItem('testToken')
        } else {
          idToken = await FirebaseAuthService.getCurrentUserIdToken()
        }

        const response = await AdminService.verifyInterestGroupAdmin(interestGroupAdminId, status, idToken)

        if (response.success) {
          // Update interest group admin status in local state or remove from pending list
          if (status === 'active') {
            this.interestGroupAdmins = this.interestGroupAdmins.filter(iga => iga.id !== interestGroupAdminId)
          }
          return { success: true, message: response.message }
        } else {
          this.error = response.error
          return { success: false, error: response.error }
        }
      } catch (error) {
        this.error = error.message
        console.error('Failed to verify interest group admin:', error)
        return { success: false, error: error.message }
      } finally {
        this.loading.verifyInterestGroupAdmin = false
      }
    },

    async fetchAdminStats() {
      this.loading.stats = true
      this.error = null

      try {
        const response = await AdminService.getAdminStats()

        if (response.success) {
          this.stats = response.stats
        } else {
          this.error = response.error
          console.error('Failed to fetch admin stats:', response.error)
        }
      } catch (error) {
        this.error = error.message
        console.error('Failed to fetch admin stats:', error)
      } finally {
        this.loading.stats = false
      }
    },

    updateFilters(filters) {
      this.filters = { ...this.filters, ...filters }
    },

    clearFilters() {
      this.filters = {
        search: '',
        status: '',
        role: ''
      }
    },

    clearError() {
      this.error = null
    },

    // Check if user is properly authenticated for admin operations
    isAuthenticatedForAdmin() {
      if (TestAuthService.isTestModeEnabled()) {
        const testToken = localStorage.getItem('testToken') || sessionStorage.getItem('testToken')
        return !!testToken
      }

      // For Firebase mode, we assume if the user is logged in, they have a token
      // The actual token validation will happen in the API calls
      return true
    }
  }
})
