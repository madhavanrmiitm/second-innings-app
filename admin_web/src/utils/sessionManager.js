import { UserService } from '@/services/userService'

export class SessionManager {
  static async getInitialRoute() {
    const isLoggedIn = await UserService.isLoggedIn()
    if (!isLoggedIn) {
      return '/login'
    }

    const userData = await UserService.getUserData()
    if (!userData) {
      await UserService.clearUserData()
      return '/login'
    }

    return this._getAppropriateRoute(userData)
  }

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

  static async getUserDisplayName() {
    return await UserService.getUserDisplayName()
  }

  static async validateSession(router) {
    const isLoggedIn = await UserService.isLoggedIn()
    const userData = await UserService.getUserData()

    if (!isLoggedIn || !userData) {
      router.push('/login')
      return false
    }

    const status = userData.status?.toString().toLowerCase()

    if (status === 'blocked') {
      await this.logout(router)
      return false
    }

    if (status === 'active' || status === 'pending_approval') {
      return true
    }

    await this.logout(router)
    return false
  }

  static async logout(router) {
    await UserService.clearUserData()
    router.push('/login')
  }

  static async getUserRole() {
    return await UserService.getUserRole()
  }

  static async getUserData() {
    return await UserService.getUserData()
  }

  static async canAccessRoute(requiredRole) {
    const userRole = await this.getUserRole()
    if (!userRole) return false

    if (!requiredRole) {
      return await UserService.isLoggedIn()
    }

    return userRole === requiredRole
  }

  static async getRedirectRouteForRole() {
    const userData = await UserService.getUserData()
    if (!userData) return '/login'

    return this._getAppropriateRoute(userData)
  }

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
