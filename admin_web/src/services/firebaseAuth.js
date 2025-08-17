import { signInWithPopup, signOut, onAuthStateChanged, getIdToken } from 'firebase/auth'
import { auth, googleProvider } from '@/config/firebase'

export class FirebaseAuthService {
  static async signInWithGoogle() {
    try {
      const result = await signInWithPopup(auth, googleProvider)
      const user = result.user

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

  static getCurrentUser() {
    return auth.currentUser
  }

  static onAuthStateChanged(callback) {
    return onAuthStateChanged(auth, callback)
  }

  static isSignedIn() {
    return !!auth.currentUser
  }

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
