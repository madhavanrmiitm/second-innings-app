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

        <!-- Test Mode Section -->
        <div v-if="authStore.isTestModeEnabled" class="mb-4">
          <div class="alert alert-warning mb-3">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            <strong>Test Mode Enabled</strong><br>
            <small>Select a test user below to bypass authentication</small>
          </div>

          <div class="mb-3">
            <label for="testUserSelect" class="form-label">Select Test User:</label>
            <select
              id="testUserSelect"
              v-model="selectedTestUser"
              class="form-select"
              :disabled="loading"
            >
              <option value="">-- Select a test user --</option>
              <optgroup v-for="roleGroup in testUsers" :key="roleGroup.role" :label="roleGroup.label">
                <option
                  v-for="user in roleGroup.users"
                  :key="user.token"
                  :value="user.token"
                >
                  {{ user.name }} ({{ user.email }}) - {{ user.status }}
                </option>
              </optgroup>
            </select>
          </div>

          <button
            @click="handleTestLogin"
            :disabled="loading || !selectedTestUser"
            class="btn btn-primary w-100 mb-3"
          >
            <i class="bi bi-person-check me-2"></i>
            <span>Sign in as Test User</span>
            <span v-if="loading" class="spinner-border spinner-border-sm ms-2" role="status">
              <span class="visually-hidden">Loading...</span>
            </span>
          </button>

          <div class="text-center mb-3">
            <small class="text-muted">OR</small>
          </div>
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
import { TestAuthService } from '@/services/testAuthService'

const router = useRouter()
const authStore = useAuthStore()
const toast = useToast()
const loading = ref(false)

// Test mode variables
const selectedTestUser = ref('')
const testUsers = ref([])

// Check if user is already authenticated on component mount
onMounted(async () => {
  if (authStore.isAuthenticated) {
    // User is already logged in, redirect to appropriate dashboard
    const redirectRoute = await SessionManager.getRedirectRouteForRole()
    router.push(redirectRoute)
  }

  // Load test users if test mode is enabled
  if (authStore.isTestModeEnabled) {
    testUsers.value = TestAuthService.getTestUsersForSelection()
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

const handleTestLogin = async () => {
  if (!selectedTestUser.value) {
    toast.error('Please select a test user')
    return
  }

  loading.value = true

  try {
    const result = await authStore.signInWithTestUser(selectedTestUser.value)

    if (result.success) {
      if (result.type === 'existing_user') {
        toast.success('Welcome back! (Test Mode)')
        // Use the redirect route from the auth store result
        router.push(result.redirectTo)
      } else if (result.type === 'new_user') {
        toast.info('Welcome! Please complete your Interest Group Admin registration. (Test Mode)')
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
      toast.error(result.error || 'Test login failed. Please try again.')
    }
  } catch (error) {
    console.error('Test login error:', error)
    toast.error('An error occurred during test login.')
  } finally {
    loading.value = false
  }
}
</script>
