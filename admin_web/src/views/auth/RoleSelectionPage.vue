<template>
  <div class="min-vh-100 d-flex align-items-center justify-content-center bg-light">
    <div class="container">
      <div class="text-center mb-5">
        <div class="bg-success bg-opacity-10 rounded-3 p-3 d-inline-block mb-3">
          <i class="bi bi-heart-fill text-danger fs-1"></i>
        </div>
        <h1 class="h2 mb-1">Welcome to 2nd Innings</h1>
        <p class="text-muted">Please select your role to continue</p>
      </div>
      
      <div class="row g-4 justify-content-center">
        <div class="col-12 col-md-4">
          <div class="card h-100 shadow-sm role-card" @click="selectRole('admin')">
            <div class="card-body text-center p-4">
              <div class="bg-primary bg-opacity-10 rounded-3 p-3 d-inline-block mb-3">
                <i class="bi bi-shield-check text-primary fs-1"></i>
              </div>
              <h5 class="card-title">Admin</h5>
              <p class="text-muted">Manage system, officials, and platform operations</p>
            </div>
          </div>
        </div>
        
        <div class="col-12 col-md-4">
          <div class="card h-100 shadow-sm role-card" @click="selectRole('support')">
            <div class="card-body text-center p-4">
              <div class="bg-info bg-opacity-10 rounded-3 p-3 d-inline-block mb-3">
                <i class="bi bi-headset text-info fs-1"></i>
              </div>
              <h5 class="card-title">Support User</h5>
              <p class="text-muted">Handle tickets and provide customer support</p>
            </div>
          </div>
        </div>
        
        <div class="col-12 col-md-4">
          <div class="card h-100 shadow-sm role-card" @click="selectRole('iga')">
            <div class="card-body text-center p-4">
              <div class="bg-warning bg-opacity-10 rounded-3 p-3 d-inline-block mb-3">
                <i class="bi bi-people text-warning fs-1"></i>
              </div>
              <h5 class="card-title">Interest Group Admin</h5>
              <p class="text-muted">Manage interest groups and community activities</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const selectRole = (role) => {
  // Store the selected role
  authStore.user.selectedRole = role
  
  // Redirect based on role
  switch(role) {
    case 'admin':
      router.push('/dashboard')
      break
    case 'support':
      router.push('/support/dashboard')
      break
    case 'iga':
      router.push('/iga/dashboard')
      break
  }
}
</script>

<style scoped>
.role-card {
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
}

.role-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0,0,0,0.15) !important;
}
</style>