<template>
  <div class="min-vh-100 d-flex align-items-center justify-content-center bg-light">
    <div class="container">
      <div class="text-center mb-5">
        <div class="bg-success bg-opacity-10 rounded-3 p-3 d-inline-block mb-3">
          <i class="bi bi-heart-fill text-danger fs-1"></i>
        </div>
        <h1 class="h2 mb-1">Welcome to 2nd Innings</h1>
        <p class="text-muted">Redirecting you to your dashboard...</p>
      </div>

      <!-- Loading spinner -->
      <div class="text-center">
        <div class="spinner-border text-primary" role="status" style="width: 3rem; height: 3rem">
          <span class="visually-hidden">Loading...</span>
        </div>
        <p class="text-muted mt-3">Setting up your dashboard...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useToast } from 'vue-toast-notification'

const router = useRouter()
const authStore = useAuthStore()
const toast = useToast()

// Check if user is authenticated and has a role on mount
onMounted(async () => {
  if (!authStore.isAuthenticated) {
    router.push('/login')
    return
  }

  // If user already has a role, redirect them immediately
  if (authStore.userRole && authStore.userRole !== '') {
    router.push(getRedirectRoute(authStore.userRole))
  } else {
    // If no role found, redirect to login (shouldn't happen in normal flow)
    toast.warning('Please complete the sign-in process.')
    router.push('/login')
  }
})

const getRedirectRoute = (role) => {
  switch (role) {
    case 'admin':
      return '/dashboard'
    case 'support':
      return '/support/dashboard'
    case 'iga':
      return '/iga/dashboard'
    default:
      return '/role-selection'
  }
}

// This page now just redirects users to their appropriate dashboards
// The actual role selection happens during registration
</script>

<style scoped>
/* Minimal styling for redirect page */
.spinner-border {
  border-width: 0.3rem;
}
</style>
