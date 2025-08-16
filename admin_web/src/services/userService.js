import { ApiService } from './apiService'
import { ApiConfig } from '@/config/api'

export class UserService {
  static get _userDataKey() {
    return 'user_data'
  }
  static get _isLoggedInKey() {
    return 'is_logged_in'
  }

  // Verify token with backend
  static async verifyToken(idToken) {
    return await ApiService.post(ApiConfig.verifyTokenEndpoint, {
      body: { id_token: idToken },
    })
  }

  // Handle authentication flow after Google Sign-In
  static async handleAuthFlow(idToken) {
    try {
      const response = await this.verifyToken(idToken)

      if (response.statusCode === 201) {
        // New user - extract user info from response
        const userInfo = response.data?.data?.user_info
        if (userInfo) {
          return AuthFlowResult.newUser({
            gmailId: userInfo.gmail_id || '',
            firebaseUid: userInfo.firebase_uid || '',
            fullName: userInfo.full_name || '',
          })
        } else {
          return AuthFlowResult.error('Invalid response format for new user')
        }
      } else if (response.statusCode === 200) {
        // Existing user - store data and return success
        const userData = response.data?.data?.user
        if (userData) {
          await this._saveUserData(userData)
          return AuthFlowResult.existingUser(userData)
        } else {
          return AuthFlowResult.error('Invalid response format for existing user')
        }
      } else {
        return AuthFlowResult.error(response.error || 'Authentication failed')
      }
    } catch (error) {
      return AuthFlowResult.error(`Authentication error: ${error.message}`)
    }
  }

 static async _saveUserData(userData) {
  try {
    // Save full user object
    localStorage.setItem(this._userDataKey, JSON.stringify(userData))
    localStorage.setItem(this._isLoggedInKey, 'true')
    
    // CRITICAL: Save userId and userRole separately for easy access
    if (userData.id) {
      localStorage.setItem('userId', userData.id.toString())
    }
    if (userData.role) {
      localStorage.setItem('userRole', userData.role)
    }
    
    return true
  } catch (error) {
    console.error('Error saving user data:', error)
    return false
  }
}

  // Get user data from localStorage
  static async getUserData() {
    try {
      const userDataString = localStorage.getItem(this._userDataKey)
      if (userDataString) {
        return JSON.parse(userDataString)
      }
      return null
    } catch (error) {
      console.error('Error getting user data:', error)
      return null
    }
  }

  // Check if user is logged in
  static async isLoggedIn() {
    try {
      return localStorage.getItem(this._isLoggedInKey) === 'true'
    } catch (error) {
      console.error('Error checking login status:', error)
      return false
    }
  }

  // Clear user data (logout)
static async clearUserData() {
  try {
    // Clear ALL user-related items
    localStorage.removeItem(this._userDataKey)
    localStorage.removeItem(this._isLoggedInKey)
    localStorage.removeItem('userId')
    localStorage.removeItem('userRole')
    return true
  } catch (error) {
    console.error('Error clearing user data:', error)
    return false
  }
}


  // Get specific user field
  static async getUserField(field) {
    const userData = await this.getUserData()
    return userData?.[field]?.toString()
  }

  // Update user data - also update the separate fields
static async updateUserData(newData) {
  try {
    const currentData = (await this.getUserData()) || {}
    const updatedData = { ...currentData, ...newData }
    
    // Use the existing _saveUserData which now handles separate fields
    return await this._saveUserData(updatedData)
  } catch (error) {
    console.error('Error updating user data:', error)
    return false
  }
}

  // Fetch user profile from backend
  static async fetchUserProfile() {
    try {
      // Get current user data to check if session exists
      const userData = await this.getUserData()
      if (!userData) {
        return {
          statusCode: 401,
          error: 'No user session found',
          isSuccess: false,
        }
      }

      // For now, return stored user data
      // In a real implementation, you might want to make an API call with fresh ID token
      return {
        statusCode: 200,
        data: {
          data: { user: userData },
        },
        isSuccess: true,
      }
    } catch (error) {
      console.error('Error fetching user profile:', error)
      return {
        statusCode: 500,
        error: `Failed to fetch user profile: ${error.message}`,
        isSuccess: false,
      }
    }
  }

  // Refresh user profile from backend
  static async refreshUserProfile(idToken) {
    return await ApiService.post(ApiConfig.profileEndpoint, {
      body: { id_token: idToken },
    })
  }

  // Register new Interest Group Admin user with backend
  static async registerUser({
    idToken,
    fullName,
    role,
    dateOfBirth,
    youtubeUrl = null,
    description = null,
    tags = null,
  }) {
    // Prepare the request body
    const requestBody = {
      id_token: idToken,
      full_name: fullName,
      role: role,
      date_of_birth: dateOfBirth,
    }

    // Add optional fields for specific roles
    if (role === 'interest_group_admin' || role === 'caregiver') {
      if (youtubeUrl) {
        requestBody.youtube_url = youtubeUrl
      }
      if (description) {
        requestBody.description = description
      }
      if (tags) {
        requestBody.tags = tags
      }
    }

    return await ApiService.post(ApiConfig.registerEndpoint, {
      body: requestBody,
    })
  }

  // Handle registration flow with automatic login
  static async handleRegistration({
    idToken,
    fullName,
    role,
    dateOfBirth,
    youtubeUrl = null,
    description = null,
    tags = null,
  }) {
    try {
      // Make registration API call
      const response = await this.registerUser({
        idToken,
        fullName,
        role,
        dateOfBirth,
        youtubeUrl,
        description,
        tags,
      })

      if (response.statusCode === 201) {
        // Registration successful - get user data and automatically log them in
        const userData = response.data?.data?.user
        if (userData) {
          await this._saveUserData(userData)

          // Refresh user profile to get the latest status from backend
          try {
            const profileResponse = await this.refreshUserProfile(idToken)
            if (profileResponse.statusCode === 200 && profileResponse.data?.data?.user) {
              const updatedUserData = profileResponse.data.data.user
              await this._saveUserData(updatedUserData)

              return RegistrationResult.success({
                userData: updatedUserData,
                message: response.data?.data?.message || 'Registration successful',
              })
            }
          } catch (profileError) {
            console.warn('Could not refresh profile after registration:', profileError)
            // Continue with original user data if profile refresh fails
          }

          return RegistrationResult.success({
            userData,
            message: response.data?.data?.message || 'Registration successful',
          })
        } else {
          return RegistrationResult.error('Invalid response format')
        }
      } else {
        return RegistrationResult.error(response.error || 'Registration failed')
      }
    } catch (error) {
      return RegistrationResult.error(`Registration error: ${error.message}`)
    }
  }

  // Check if user status allows access
  static async canUserAccess() {
    const userData = await this.getUserData()
    if (!userData) return false

    const status = userData.status?.toString().toLowerCase()
    return status === 'active'
  }

  // Check if user is blocked
  static async isUserBlocked() {
    const userData = await this.getUserData()
    if (!userData) return false

    const status = userData.status?.toString().toLowerCase()
    return status === 'blocked'
  }

  // Check if user is pending approval
  static async isUserPendingApproval() {
    const userData = await this.getUserData()
    if (!userData) return false

    const status = userData.status?.toString().toLowerCase()
    return status === 'pending_approval'
  }

  // Get user role - mapping admin app specific roles
  static async getUserRole() {
    const userData = await this.getUserData()
    const role = userData?.role?.toString()

    // Map backend roles to frontend roles
    switch (role) {
      case 'interest_group_admin':
        return 'iga'
      case 'support_user':
        return 'support'
      case 'admin':
        return 'admin'
      default:
        return role
    }
  }

  // Get user status
  static async getUserStatus() {
    const userData = await this.getUserData()
    return userData?.status?.toString()
  }

  // Get user display name
  static async getUserDisplayName() {
    const userData = await this.getUserData()
    return userData?.full_name || userData?.name || userData?.email || 'User'
  }

  // Check if user has specific role
  static async hasRole(role) {
    const userRole = await this.getUserRole()
    return userRole === role
  }

  // Check if user is admin
  static async isAdmin() {
    return await this.hasRole('admin')
  }

  // Check if user is support
  static async isSupport() {
    return await this.hasRole('support')
  }

  // Check if user is IGA
  static async isIGA() {
    return await this.hasRole('iga')
  }
}

// Result class for authentication flow
export class AuthFlowResult {
  constructor({
    type,
    userData = null,
    error = null,
    gmailId = null,
    firebaseUid = null,
    fullName = null,
  }) {
    this.type = type
    this.userData = userData
    this.error = error
    this.gmailId = gmailId
    this.firebaseUid = firebaseUid
    this.fullName = fullName
  }

  static newUser({ gmailId, firebaseUid, fullName }) {
    return new AuthFlowResult({
      type: AuthFlowType.NEW_USER,
      gmailId,
      firebaseUid,
      fullName,
    })
  }

  static existingUser(userData) {
    return new AuthFlowResult({
      type: AuthFlowType.EXISTING_USER,
      userData,
    })
  }

  static error(error) {
    return new AuthFlowResult({
      type: AuthFlowType.ERROR,
      error,
    })
  }

  get isNewUser() {
    return this.type === AuthFlowType.NEW_USER
  }

  get isExistingUser() {
    return this.type === AuthFlowType.EXISTING_USER
  }

  get hasError() {
    return this.type === AuthFlowType.ERROR
  }
}

export const AuthFlowType = {
  NEW_USER: 'newUser',
  EXISTING_USER: 'existingUser',
  ERROR: 'error',
}

// Registration result class
export class RegistrationResult {
  constructor({ type, userData = null, error = null, message = null }) {
    this.type = type
    this.userData = userData
    this.error = error
    this.message = message
  }

  static success({ userData, message = null }) {
    return new RegistrationResult({
      type: RegistrationResultType.SUCCESS,
      userData,
      message,
    })
  }

  static error(error) {
    return new RegistrationResult({
      type: RegistrationResultType.ERROR,
      error,
    })
  }

  get isSuccess() {
    return this.type === RegistrationResultType.SUCCESS
  }

  get hasError() {
    return this.type === RegistrationResultType.ERROR
  }
}

export const RegistrationResultType = {
  SUCCESS: 'success',
  ERROR: 'error',
}
