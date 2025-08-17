import { initializeApp } from 'firebase/app'
import { getAuth, GoogleAuthProvider, setPersistence, browserLocalPersistence } from 'firebase/auth'

const firebaseConfig = {
  apiKey: 'AIzaSyAE-WaYmLylZpahIOX1iHp2HewI2jKR8aM',
  authDomain: 'second-innings-iitm.firebaseapp.com',
  projectId: 'second-innings-iitm',
  storageBucket: 'second-innings-iitm.firebasestorage.app',
  messagingSenderId: '937122069187',
  appId: '1:937122069187:web:ea8468375678be5f280076',
}

const app = initializeApp(firebaseConfig)

export const auth = getAuth(app)

setPersistence(auth, browserLocalPersistence).catch((error) => {
  console.error('Failed to set Firebase auth persistence:', error)
})

export const googleProvider = new GoogleAuthProvider()
googleProvider.addScope('email')
googleProvider.addScope('profile')

export default app
