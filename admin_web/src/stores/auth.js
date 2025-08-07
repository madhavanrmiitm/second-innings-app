import { defineStore } from 'pinia'
import { FirebaseAuthService } from '@/services/firebaseAuth'
import { TestAuthService } from '@/services/testAuthService'
import { UserService } from '@/services/userService'
import { SessionManager } from '@/utils/sessionManager'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    firebaseUser: null,
    isAuthenticated: false,
    loading: false,
    error: null,
  }),

  getters: {
    userRole: (state) => {
      if (!state.user?.role) return ''
      // Map backend roles to frontend roles
      switch (state.user.role) {
        case 'interest_group_admin':
          return 'iga'
        case 'support_user':
          return 'support'
        case 'admin':
          return 'admin'
        default:
          return state.user.role
      }
    },
    userName: (state) =>
      state.user?.full_name || state.user?.name || state.firebaseUser?.displayName || '',
    userEmail: (state) => state.user?.email || state.firebaseUser?.email || '',
    userId: (state) => state.user?.id || state.firebaseUser?.uid || null,
    isNewUser: (state) => !state.user?.id,
    userStatus: (state) => state.user?.status || '',
    canAccess: (state) => state.user?.status === 'active',
    isBlocked: (state) => state.user?.status === 'blocked',
    isPendingApproval: (state) => state.user?.status === 'pending_approval',
    isTestModeEnabled: () => TestAuthService.isTestModeEnabled(),
  },

  actions: {
    async signInWithGoogle() {
      this.loading = true
      this.error = null

      try {
        // Step 1: Sign in with Firebase
        const firebaseResult = await FirebaseAuthService.signInWithGoogle()

        if (!firebaseResult.success) {
          throw new Error(firebaseResult.error)
        }

        this.firebaseUser = firebaseResult.user

        // Step 2: Verify token with backend
        const authFlowResult = await UserService.handleAuthFlow(firebaseResult.idToken)

        if (authFlowResult.hasError) {
          throw new Error(authFlowResult.error)
        }

        if (authFlowResult.isExistingUser) {
          // Existing user - set user data and authenticate
          this.user = authFlowResult.userData
          this.isAuthenticated = true

          return {
            success: true,
            type: 'existing_user',
            redirectTo: await SessionManager.getRedirectRouteForRole(),
          }
        } else if (authFlowResult.isNewUser) {
          // New user - they need to complete registration
          this.isAuthenticated = false // Not fully authenticated until registered

          return {
            success: true,
            type: 'new_user',
            userInfo: {
              gmailId: authFlowResult.gmailId,
              firebaseUid: authFlowResult.firebaseUid,
              fullName: authFlowResult.fullName,
            },
            redirectTo: '/register', // Direct to registration page for IGA self-registration
          }
        }
      } catch (error) {
        console.error('Google Sign-In failed:', error)
        this.error = error.message
        await this.clearSession()
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    async signInWithTestUser(testToken) {
      this.loading = true
      this.error = null

      try {
        // Step 1: Sign in with test user
        const testResult = await TestAuthService.signInWithTestUser(testToken)

        if (!testResult.success) {
          throw new Error(testResult.error)
        }

        this.firebaseUser = testResult.user

        // Store test token for API calls
        localStorage.setItem('testToken', testToken)

        // Step 2: Verify token with backend (using test token)
        const authFlowResult = await UserService.handleAuthFlow(testResult.idToken)

        if (authFlowResult.hasError) {
          throw new Error(authFlowResult.error)
        }

        if (authFlowResult.isExistingUser) {
          // Existing user - set user data and authenticate
          this.user = authFlowResult.userData
          this.isAuthenticated = true

          return {
            success: true,
            type: 'existing_user',
            redirectTo: await SessionManager.getRedirectRouteForRole(),
          }
        } else if (authFlowResult.isNewUser) {
          // New user - they need to complete registration
          this.isAuthenticated = false // Not fully authenticated until registered

          return {
            success: true,
            type: 'new_user',
            userInfo: {
              gmailId: authFlowResult.gmailId,
              firebaseUid: authFlowResult.firebaseUid,
              fullName: authFlowResult.fullName,
            },
            redirectTo: '/register', // Direct to registration page for IGA self-registration
          }
        }
      } catch (error) {
        console.error('Test Sign-In failed:', error)
        this.error = error.message
        await this.clearSession()
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    async logout() {
      this.loading = true

      try {
        // Sign out from Firebase
        await FirebaseAuthService.signOut()

        // Clear local session
        await this.clearSession()

        return { success: true }
      } catch (error) {
        console.error('Logout error:', error)
        await this.clearSession() // Clear anyway
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    async clearSession() {
      // Clear store state
      this.user = null
      this.firebaseUser = null
      this.isAuthenticated = false
      this.error = null
      
      // Clear all localStorage items through UserService
      await UserService.clearUserData()

      // Clear test token if in test mode
      if (TestAuthService.isTestModeEnabled()) {
        localStorage.removeItem('testToken')
        sessionStorage.removeItem('testToken')
      }
      
      // Reset any other stores that might have cached data
      // This is important for tickets store
    },

    async initializeAuth() {
      try {
        // Initialize session from stored data
        const sessionData = await SessionManager.initializeSession()

        if (sessionData.isLoggedIn && sessionData.userData) {
          this.user = sessionData.userData

          // Set authentication status based on user status
          const status = sessionData.userData.status?.toLowerCase()
          this.isAuthenticated = status === 'active' || status === 'pending_approval'

          // Check Firebase auth state
          const firebaseUser = FirebaseAuthService.getCurrentUser()
          if (firebaseUser) {
            this.firebaseUser = {
              uid: firebaseUser.uid,
              email: firebaseUser.email,
              displayName: firebaseUser.displayName,
              photoURL: firebaseUser.photoURL,
            }
          }
        }
      } catch (error) {
        console.error('Failed to initialize auth:', error)
        await this.clearSession()
      }
    },

    async updateProfile(profileData) {
      if (this.user) {
        const success = await UserService.updateUserData(profileData)
        if (success) {
          this.user = { ...this.user, ...profileData }
        }
        return success
      }
      return false
    },

    async refreshUserProfile() {
      try {
        const idToken = await FirebaseAuthService.getCurrentUserIdToken()
        if (idToken) {
          const response = await UserService.refreshUserProfile(idToken)
          if (response.statusCode === 200 && response.data?.data?.user) {
            const userData = response.data.data.user
            await UserService.updateUserData(userData)
            this.user = userData

            // Update authentication status based on user status
            this.isAuthenticated =
              userData.status === 'active' || userData.status === 'pending_approval'

            return { success: true, userData }
          }
          return { success: false, error: response.error || 'Failed to refresh profile' }
        }
        return { success: false, error: 'No valid session' }
      } catch (error) {
        console.error('Failed to refresh profile:', error)
        return { success: false, error: error.message }
      }
    },

    // Complete user registration and automatically log them in
    async completeRegistration(registrationData) {
      this.loading = true
      this.error = null

      try {
        const result = await UserService.handleRegistration(registrationData)

        if (result.isSuccess) {
          // User is now registered and logged in
          this.user = result.userData
          this.isAuthenticated = true

          return {
            success: true,
            userData: result.userData,
            message: result.message,
            redirectTo: await SessionManager.getRedirectRouteForRole(),
          }
        } else {
          return { success: false, error: result.error }
        }
      } catch (error) {
        console.error('Registration error:', error)
        this.error = error.message
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },

    async hasPermission(permission) {
      const permissions = await SessionManager.getUserPermissions()
      return permissions[permission] || false
    },
  },
})
