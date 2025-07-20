<template>
  <div class="min-vh-100 d-flex align-items-center justify-content-center bg-light">
    <div class="card shadow" style="width: 400px">
      <div class="card-body p-5">
        <div class="text-center mb-4">
          <div class="bg-success bg-opacity-10 rounded-3 p-3 d-inline-block mb-3">
            <i class="bi bi-heart-fill text-danger fs-1"></i>
          </div>
          <h1 class="h3 mb-1">2nd innings</h1>
          <p class="text-muted">For the old by the young</p>
        </div>

        <button
          @click="handleGoogleLogin"
          :disabled="loading"
          class="btn btn-outline-secondary w-100 d-flex align-items-center justify-content-center gap-2"
        >
          <img src="https://www.google.com/favicon.ico" alt="Google" width="20" height="20" />
          <span>Continue with Google</span>
          <span v-if="loading" class="spinner-border spinner-border-sm ms-2" role="status">
            <span class="visually-hidden">Loading...</span>
          </span>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useToast } from 'vue-toast-notification'
import { SessionManager } from '@/utils/sessionManager'

const router = useRouter()
const authStore = useAuthStore()
const toast = useToast()
const loading = ref(false)

// Check if user is already authenticated on component mount
onMounted(async () => {
  if (authStore.isAuthenticated) {
    // User is already logged in, redirect to appropriate dashboard
    const redirectRoute = await SessionManager.getRedirectRouteForRole()
    router.push(redirectRoute)
  }
})

const handleGoogleLogin = async () => {
  loading.value = true

  try {
    const result = await authStore.signInWithGoogle()

    if (result.success) {
      if (result.type === 'existing_user') {
        toast.success('Welcome back!')
        // Use the redirect route from the auth store result
        router.push(result.redirectTo)
      } else if (result.type === 'new_user') {
        toast.info('Welcome! Please complete your Interest Group Admin registration.')
        // Redirect to registration page with user info
        router.push({
          name: 'Registration',
          query: {
            gmailId: result.userInfo.gmailId,
            fullName: result.userInfo.fullName,
            firebaseUid: result.userInfo.firebaseUid,
          },
        })
      }
    } else {
      toast.error(result.error || 'Login failed. Please try again.')
    }
  } catch (error) {
    console.error('Login error:', error)
    toast.error('An error occurred during login.')
  } finally {
    loading.value = false
  }
}
</script>
