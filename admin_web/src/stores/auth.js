import { defineStore } from 'pinia'
import { authAPI } from '@/services/api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: null,
    isAuthenticated: false,
    loading: false
  }),
  
  getters: {
    userRole: (state) => state.user?.role || '',
    userName: (state) => state.user?.name || '',
    userEmail: (state) => state.user?.email || '',
    userId: (state) => state.user?.id || null
  },
  
  actions: {
    async login(credentials) {
      this.loading = true
      try {
        const response = await authAPI.login(credentials)
        this.user = response.user
        this.token = response.token
        this.isAuthenticated = true
        
        // Store in localStorage for persistence
        localStorage.setItem('token', response.token)
        localStorage.setItem('user', JSON.stringify(response.user))
        
        return { success: true }
      } catch (error) {
        console.error('Login failed:', error)
        return { success: false, error: error.message }
      } finally {
        this.loading = false
      }
    },
    
    async logout() {
      try {
        await authAPI.logout()
      } catch (error) {
        console.error('Logout error:', error)
      } finally {
        this.user = null
        this.token = null
        this.isAuthenticated = false
        localStorage.removeItem('token')
        localStorage.removeItem('user')
      }
    },
    
    initializeAuth() {
      const token = localStorage.getItem('token')
      const user = localStorage.getItem('user')
      
      if (token && user) {
        try {
          this.token = token
          this.user = JSON.parse(user)
          this.isAuthenticated = true
        } catch (error) {
          console.error('Failed to parse user data:', error)
          this.logout()
        }
      }
    },
    
    updateProfile(profileData) {
      if (this.user) {
        this.user = { ...this.user, ...profileData }
        localStorage.setItem('user', JSON.stringify(this.user))
      }
    }
  }
})