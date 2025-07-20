<template>
  <div class="min-vh-100 d-flex align-items-center justify-content-center bg-light">
    <div class="container">
      <div class="row justify-content-center">
        <div class="col-12 col-md-8 col-lg-6">
          <div class="card shadow">
            <div class="card-body p-5">
              <div class="text-center mb-4">
                <div class="bg-success bg-opacity-10 rounded-3 p-3 d-inline-block mb-3">
                  <i class="bi bi-person-plus-fill text-success fs-1"></i>
                </div>
                <h1 class="h3 mb-1">Interest Group Admin Registration</h1>
                <p class="text-muted">
                  Complete your registration to become an Interest Group Admin
                </p>
              </div>

              <form @submit.prevent="handleRegistration">
                <!-- Gmail ID (Non-editable) -->
                <div class="mb-3">
                  <label for="gmailId" class="form-label">Email Address</label>
                  <input
                    type="email"
                    class="form-control"
                    id="gmailId"
                    :value="formData.gmailId"
                    readonly
                    disabled
                  />
                  <div class="form-text">This email is linked to your Google account</div>
                </div>

                <!-- Full Name (Editable) -->
                <div class="mb-3">
                  <label for="fullName" class="form-label">Full Name *</label>
                  <input
                    type="text"
                    class="form-control"
                    id="fullName"
                    v-model="formData.fullName"
                    :class="{ 'is-invalid': errors.fullName }"
                    required
                  />
                  <div v-if="errors.fullName" class="invalid-feedback">
                    {{ errors.fullName }}
                  </div>
                </div>

                <!-- Date of Birth -->
                <div class="mb-3">
                  <label for="dateOfBirth" class="form-label">Date of Birth *</label>
                  <input
                    type="date"
                    class="form-control"
                    id="dateOfBirth"
                    v-model="formData.dateOfBirth"
                    :class="{ 'is-invalid': errors.dateOfBirth }"
                    :max="maxDate"
                    required
                  />
                  <div v-if="errors.dateOfBirth" class="invalid-feedback">
                    {{ errors.dateOfBirth }}
                  </div>
                </div>

                <!-- YouTube URL (Required for Interest Group Admin) -->
                <div class="mb-3">
                  <label for="youtubeUrl" class="form-label">YouTube Video URL *</label>
                  <input
                    type="url"
                    class="form-control"
                    id="youtubeUrl"
                    v-model="formData.youtubeUrl"
                    :class="{ 'is-invalid': errors.youtubeUrl }"
                    placeholder="https://youtube.com/watch?v=..."
                    required
                  />
                  <div class="form-text">
                    Please provide a YouTube video URL for your Interest Group Admin application
                  </div>
                  <div v-if="errors.youtubeUrl" class="invalid-feedback">
                    {{ errors.youtubeUrl }}
                  </div>
                </div>

                <!-- Submit Button -->
                <div class="d-grid gap-2">
                  <button type="submit" class="btn btn-primary" :disabled="loading">
                    <span
                      v-if="loading"
                      class="spinner-border spinner-border-sm me-2"
                      role="status"
                    >
                      <span class="visually-hidden">Loading...</span>
                    </span>
                    Complete Registration
                  </button>

                  <button
                    type="button"
                    class="btn btn-outline-secondary"
                    @click="goBack"
                    :disabled="loading"
                  >
                    Back to Login
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useToast } from 'vue-toast-notification'
import { FirebaseAuthService } from '@/services/firebaseAuth'
import { UserService } from '@/services/userService'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const toast = useToast()
const authStore = useAuthStore()

const loading = ref(false)
const errors = ref({})

// Form data - Role is fixed as 'interest_group_admin' for self-registration
const formData = reactive({
  gmailId: '',
  fullName: '',
  dateOfBirth: '',
  role: 'interest_group_admin', // Fixed role for IGA registration
  youtubeUrl: '',
})

// Get current date for max date validation
const maxDate = computed(() => {
  const today = new Date()
  today.setFullYear(today.getFullYear() - 13) // Minimum age 13
  return today.toISOString().split('T')[0]
})

// Initialize form with user info from route params or Firebase
onMounted(async () => {
  // Get user info from route query params (passed from login)
  const { gmailId, fullName, firebaseUid } = route.query

  if (gmailId && fullName) {
    formData.gmailId = gmailId
    formData.fullName = fullName
  } else {
    // Try to get from Firebase auth if available
    const firebaseUser = FirebaseAuthService.getCurrentUser()
    if (firebaseUser) {
      formData.gmailId = firebaseUser.email || ''
      formData.fullName = firebaseUser.displayName || ''
    } else {
      // No user info available, redirect to login
      toast.error('Session expired. Please sign in again.')
      router.push('/login')
    }
  }
})

// Validate form
const validateForm = () => {
  errors.value = {}

  if (!formData.fullName.trim()) {
    errors.value.fullName = 'Full name is required'
  }

  if (!formData.dateOfBirth) {
    errors.value.dateOfBirth = 'Date of birth is required'
  } else {
    const birthDate = new Date(formData.dateOfBirth)
    const today = new Date()
    const age = today.getFullYear() - birthDate.getFullYear()

    if (
      age < 13 ||
      (age === 13 &&
        today < new Date(today.getFullYear(), birthDate.getMonth(), birthDate.getDate()))
    ) {
      errors.value.dateOfBirth = 'You must be at least 13 years old'
    }
  }

  // Validate YouTube URL (required for Interest Group Admin)
  if (!formData.youtubeUrl.trim()) {
    errors.value.youtubeUrl = 'YouTube URL is required for Interest Group Admin registration'
  } else if (!isValidYouTubeUrl(formData.youtubeUrl)) {
    errors.value.youtubeUrl = 'Please enter a valid YouTube URL'
  }

  return Object.keys(errors.value).length === 0
}

// Validate YouTube URL - Enhanced format validation
const isValidYouTubeUrl = (url) => {
  return url.startsWith('https://y')
}

// Handle registration
const handleRegistration = async () => {
  if (!validateForm()) {
    return
  }

  loading.value = true

  try {
    // Get fresh ID token from Firebase
    const idToken = await FirebaseAuthService.getCurrentUserIdToken()

    if (!idToken) {
      throw new Error('Authentication session expired. Please sign in again.')
    }

    // Prepare registration data for Interest Group Admin
    const registrationData = {
      idToken,
      fullName: formData.fullName.trim(),
      role: formData.role, // Always 'interest_group_admin'
      dateOfBirth: formData.dateOfBirth,
      youtubeUrl: formData.youtubeUrl.trim(), // Always required for IGA
    }

    // Complete registration and automatically log user in
    const result = await authStore.completeRegistration(registrationData)

    if (result.success) {
      toast.success(result.message || 'Registration completed successfully!')

      // Redirect to appropriate dashboard
      router.push(result.redirectTo)
    } else {
      toast.error(result.error || 'Registration failed. Please try again.')
    }
  } catch (error) {
    console.error('Registration error:', error)
    toast.error(error.message || 'An error occurred during registration.')
  } finally {
    loading.value = false
  }
}

// Get redirect route based on role
const getRedirectRoute = (role) => {
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

// Go back to login
const goBack = async () => {
  // Sign out from Firebase to clear session
  await FirebaseAuthService.signOut()
  await authStore.clearSession()
  router.push('/login')
}
</script>

<style scoped>
.form-control:disabled {
  background-color: #f8f9fa;
  opacity: 1;
}

.card {
  border: none;
}

.form-text {
  font-size: 0.875rem;
}
</style>
