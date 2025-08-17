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

onMounted(async () => {
  if (!authStore.isAuthenticated) {
    router.push('/login')
    return
  }

  if (authStore.userRole && authStore.userRole !== '') {
    router.push(getRedirectRoute(authStore.userRole))
  } else {
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

</script>

<style scoped>
.spinner-border {
  border-width: 0.3rem;
}
</style>
