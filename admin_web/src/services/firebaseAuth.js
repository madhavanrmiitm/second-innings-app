import { signInWithPopup, signOut, onAuthStateChanged, getIdToken } from 'firebase/auth'
import { auth, googleProvider } from '@/config/firebase'

export class FirebaseAuthService {
  // Sign in with Google
  static async signInWithGoogle() {
    try {
      const result = await signInWithPopup(auth, googleProvider)
      const user = result.user

      // Get the ID token
      const idToken = await getIdToken(user)

      return {
        success: true,
        user: {
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoURL,
        },
        idToken,
      }
    } catch (error) {
      console.error('Google Sign-In Error:', error)
      return {
        success: false,
        error: this._getErrorMessage(error),
      }
    }
  }

  // Sign out
  static async signOut() {
    try {
      await signOut(auth)
      return { success: true }
    } catch (error) {
      console.error('Sign-Out Error:', error)
      return {
        success: false,
        error: this._getErrorMessage(error),
      }
    }
  }

  // Get current user ID token
  static async getCurrentUserIdToken() {
    try {
      const user = auth.currentUser
      if (user) {
        return await getIdToken(user, /* forceRefresh */ true)
      }
      return null
    } catch (error) {
      console.error('Error getting ID token:', error)
      return null
    }
  }

  // Get current user
  static getCurrentUser() {
    return auth.currentUser
  }

  // Listen to auth state changes
  static onAuthStateChanged(callback) {
    return onAuthStateChanged(auth, callback)
  }

  // Check if user is signed in
  static isSignedIn() {
    return !!auth.currentUser
  }

  // Get user info
  static getCurrentUserInfo() {
    const user = auth.currentUser
    if (user) {
      return {
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoURL: user.photoURL,
        emailVerified: user.emailVerified,
      }
    }
    return null
  }

  // Private method to format error messages
  static _getErrorMessage(error) {
    switch (error.code) {
      case 'auth/popup-closed-by-user':
        return 'Sign-in was cancelled'
      case 'auth/popup-blocked':
        return 'Sign-in popup was blocked by your browser'
      case 'auth/cancelled-popup-request':
        return 'Sign-in request was cancelled'
      case 'auth/network-request-failed':
        return 'Network error occurred. Please check your connection'
      case 'auth/internal-error':
        return 'An internal error occurred. Please try again'
      default:
        return error.message || 'An error occurred during authentication'
    }
  }
}
