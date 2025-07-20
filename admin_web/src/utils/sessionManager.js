import { UserService } from '@/services/userService'

export class SessionManager {
  // Check if user is logged in and return appropriate route
  static async getInitialRoute() {
    const isLoggedIn = await UserService.isLoggedIn()
    if (!isLoggedIn) {
      return '/login'
    }

    const userData = await UserService.getUserData()
    if (!userData) {
      // Clear invalid session
      await UserService.clearUserData()
      return '/login'
    }

    // Navigate to appropriate dashboard based on user role
    return this._getAppropriateRoute(userData)
  }

  // Get appropriate route based on user role
  static _getAppropriateRoute(userData) {
    const role = userData.role?.toString()

    switch (role) {
      case 'admin':
        return '/dashboard'
      case 'support_user':
        return '/support/dashboard'
      case 'interest_group_admin':
        return '/iga/dashboard'
      default:
        return '/role-selection'
    }
  }

  // Get user display name with fallback
  static async getUserDisplayName() {
    return await UserService.getUserDisplayName()
  }

  // Validate session and redirect if invalid
  static async validateSession(router) {
    const isLoggedIn = await UserService.isLoggedIn()
    const userData = await UserService.getUserData()

    if (!isLoggedIn || !userData) {
      // Session is invalid, redirect to login
      router.push('/login')
      return false
    }

    // Check user status
    const status = userData.status?.toString().toLowerCase()

    if (status === 'blocked') {
      // User is blocked, redirect to login and clear session
      await this.logout(router)
      return false
    }

    // Allow both 'active' and 'pending_approval' users to access
    // pending_approval users will have restricted functionality in UI
    if (status === 'active' || status === 'pending_approval') {
      return true
    }

    // Unknown or invalid status, redirect to login
    await this.logout(router)
    return false
  }

  // Handle logout
  static async logout(router) {
    await UserService.clearUserData()
    router.push('/login')
  }

  // Get user role
  static async getUserRole() {
    return await UserService.getUserRole()
  }

  // Get all user data safely
  static async getUserData() {
    return await UserService.getUserData()
  }

  // Check if user can access a specific route based on role
  static async canAccessRoute(requiredRole) {
    const userRole = await this.getUserRole()
    if (!userRole) return false

    // If no specific role required, just check if user is logged in
    if (!requiredRole) {
      return await UserService.isLoggedIn()
    }

    // Check if user has the required role
    return userRole === requiredRole
  }

  // Get redirect route based on user role
  static async getRedirectRouteForRole() {
    const userData = await UserService.getUserData()
    if (!userData) return '/login'

    return this._getAppropriateRoute(userData)
  }

  // Initialize session on app start
  static async initializeSession() {
    const isLoggedIn = await UserService.isLoggedIn()
    const userData = await UserService.getUserData()

    return {
      isLoggedIn,
      userData,
      userRole: userData ? await UserService.getUserRole() : null,
      canAccess: userData
        ? userData.status === 'active' || userData.status === 'pending_approval'
        : false,
    }
  }

  // Refresh user data from backend
  static async refreshUserData(idToken) {
    try {
      const response = await UserService.refreshUserProfile(idToken)
      if (response.statusCode === 200 && response.data?.data?.user) {
        const userData = response.data.data.user
        await UserService.updateUserData(userData)
        return { success: true, userData }
      }
      return { success: false, error: response.error || 'Failed to refresh user data' }
    } catch (error) {
      return { success: false, error: error.message }
    }
  }

  // Get user permissions based on role
  static async getUserPermissions() {
    const role = await this.getUserRole()

    switch (role) {
      case 'admin':
        return {
          canManageOfficials: true,
          canViewAllTickets: true,
          canManageNotifications: true,
          canApproveCaregivers: true,
          canManageIGA: true,
          canViewDashboard: true,
        }
      case 'support':
        return {
          canManageOfficials: false,
          canViewAllTickets: true,
          canManageNotifications: false,
          canApproveCaregivers: false,
          canManageIGA: false,
          canViewDashboard: true,
        }
      case 'iga':
        return {
          canManageOfficials: false,
          canViewAllTickets: false,
          canManageNotifications: false,
          canApproveCaregivers: false,
          canManageIGA: true,
          canViewDashboard: true,
        }
      default:
        return {
          canManageOfficials: false,
          canViewAllTickets: false,
          canManageNotifications: false,
          canApproveCaregivers: false,
          canManageIGA: false,
          canViewDashboard: false,
        }
    }
  }
}
