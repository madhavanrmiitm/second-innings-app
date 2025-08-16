// Import the functions you need from the SDKs you need
import { initializeApp } from 'firebase/app'
import { getAuth, GoogleAuthProvider, setPersistence, browserLocalPersistence } from 'firebase/auth'

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: 'AIzaSyAE-WaYmLylZpahIOX1iHp2HewI2jKR8aM',
  authDomain: 'second-innings-iitm.firebaseapp.com',
  projectId: 'second-innings-iitm',
  storageBucket: 'second-innings-iitm.firebasestorage.app',
  messagingSenderId: '937122069187',
  appId: '1:937122069187:web:ea8468375678be5f280076',
}

// Initialize Firebase
const app = initializeApp(firebaseConfig)

// Initialize Firebase Authentication and get a reference to the service
export const auth = getAuth(app)

// Set persistence to local storage to survive browser restarts
setPersistence(auth, browserLocalPersistence).catch((error) => {
  console.error('Failed to set Firebase auth persistence:', error)
})

// Configure Google Auth Provider
export const googleProvider = new GoogleAuthProvider()
googleProvider.addScope('email')
googleProvider.addScope('profile')

export default app
