import { createApp } from 'vue'
import { createPinia } from 'pinia'
import VueToast from 'vue-toast-notification'
import 'vue-toast-notification/dist/theme-sugar.css'

// Bootstrap CSS
import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap-icons/font/bootstrap-icons.css'

// Bootstrap JS
import * as bootstrap from 'bootstrap'
window.bootstrap = bootstrap

import App from './App.vue'
import router from './router'
import './assets/main.scss'

// Firebase auth
import { FirebaseAuthService } from './services/firebaseAuth'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(VueToast, {
  position: 'top-right',
  duration: 3000,
})

// Initialize auth store after pinia is ready
import { useAuthStore } from './stores/auth'

// Wait for Firebase auth state to be restored before mounting the app
const initializeApp = async () => {
  return new Promise((resolve) => {
    // Set a timeout to prevent infinite waiting
    const timeout = setTimeout(() => {
      console.log('Firebase auth state timeout, proceeding anyway')
      resolve()
    }, 3000)

    const unsubscribe = FirebaseAuthService.onAuthStateChanged(async (user) => {
      clearTimeout(timeout)
      unsubscribe() // Stop listening after first state change
      
      // Initialize auth store with current state
      const authStore = useAuthStore()
      await authStore.initializeAuth()
      
      resolve()
    })
  })
}

initializeApp().then(() => {
  app.use(router)
  app.mount('#app')
})
