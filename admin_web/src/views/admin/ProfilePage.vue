<template>
  <AppLayout>
    <div class="container-fluid">
      <h1 class="h3 mb-4">Profile</h1>
      
      <div class="row">
        <div class="col-12 col-md-4">
          <!-- Profile Card -->
          <div class="card mb-4">
            <div class="card-body text-center">
              <img
                :src="user?.profileImage || `https://ui-avatars.com/api/?name=${user?.name}`"
                :alt="user?.name"
                class="rounded-circle mb-3"
                style="width: 150px; height: 150px; object-fit: cover;"
              >
              <h5 class="card-title">{{ user?.name }}</h5>
              <p class="text-muted">{{ user?.role }}</p>
              <button class="btn btn-outline-primary btn-sm">
                <i class="bi bi-camera me-2"></i>Change Photo
              </button>
            </div>
          </div>
          
          <!-- Quick Stats -->
          <div class="card">
            <div class="card-header">
              <h6 class="mb-0">Quick Stats</h6>
            </div>
            <div class="card-body">
              <div class="d-flex justify-content-between mb-2">
                <span>Member Since</span>
                <strong>{{ memberSince }}</strong>
              </div>
              <div class="d-flex justify-content-between mb-2">
                <span>Status</span>
                <span class="badge bg-success">Active</span>
              </div>
              <div class="d-flex justify-content-between">
                <span>Department</span>
                <strong>{{ user?.department || 'Admin' }}</strong>
              </div>
            </div>
          </div>
        </div>
        
        <div class="col-12 col-md-8">
          <!-- Profile Form -->
          <div class="card">
            <div class="card-header">
              <h6 class="mb-0">Profile Information</h6>
            </div>
            <div class="card-body">
              <form @submit.prevent="updateProfile">
                <div class="row g-3">
                  <div class="col-12 col-md-6">
                    <label class="form-label">First Name</label>
                    <input
                      v-model="profileForm.firstName"
                      type="text"
                      class="form-control"
                      required
                    >
                  </div>
                  <div class="col-12 col-md-6">
                    <label class="form-label">Last Name</label>
                    <input
                      v-model="profileForm.lastName"
                      type="text"
                      class="form-control"
                      required
                    >
                  </div>
                  <div class="col-12">
                    <label class="form-label">Email</label>
                    <input
                      v-model="profileForm.email"
                      type="email"
                      class="form-control"
                      readonly
                    >
                  </div>
                  <div class="col-12">
                    <label class="form-label">Phone</label>
                    <input
                      v-model="profileForm.phone"
                      type="tel"
                      class="form-control"
                    >
                  </div>
                  <div class="col-12">
                    <label class="form-label">Bio</label>
                    <textarea
                      v-model="profileForm.bio"
                      class="form-control"
                      rows="3"
                    ></textarea>
                  </div>
                </div>
                
                <hr class="my-4">
                
                <div class="d-flex justify-content-end gap-2">
                  <button type="button" class="btn btn-secondary" @click="resetForm">
                    Cancel
                  </button>
                  <button type="submit" class="btn btn-success" :disabled="saving">
                    <span v-if="saving" class="spinner-border spinner-border-sm me-2"></span>
                    Save Changes
                  </button>
                </div>
              </form>
            </div>
          </div>
          
          <!-- Change Password -->
          <div class="card mt-4">
            <div class="card-header">
              <h6 class="mb-0">Change Password</h6>
            </div>
            <div class="card-body">
              <form @submit.prevent="changePassword">
                <div class="row g-3">
                  <div class="col-12">
                    <label class="form-label">Current Password</label>
                    <input
                      v-model="passwordForm.current"
                      type="password"
                      class="form-control"
                      required
                    >
                  </div>
                  <div class="col-12">
                    <label class="form-label">New Password</label>
                    <input
                      v-model="passwordForm.new"
                      type="password"
                      class="form-control"
                      required
                    >
                  </div>
                  <div class="col-12">
                    <label class="form-label">Confirm New Password</label>
                    <input
                      v-model="passwordForm.confirm"
                      type="password"
                      class="form-control"
                      required
                    >
                  </div>
                </div>
                
                <div class="d-flex justify-content-end mt-3">
                  <button type="submit" class="btn btn-primary" :disabled="changingPassword">
                    <span v-if="changingPassword" class="spinner-border spinner-border-sm me-2"></span>
                    Change Password
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import AppLayout from '@/components/common/AppLayout.vue'
import { useAuthStore } from '@/stores/auth'
import { useToast } from 'vue-toast-notification'

const authStore = useAuthStore()
const toast = useToast()

const user = computed(() => authStore.user)
const memberSince = computed(() => {
  if (!user.value?.createdAt) return 'N/A'
  return new Date(user.value.createdAt).toLocaleDateString()
})

const saving = ref(false)
const changingPassword = ref(false)

const profileForm = ref({
  firstName: '',
  lastName: '',
  email: '',
  phone: '',
  bio: ''
})

const passwordForm = ref({
  current: '',
  new: '',
  confirm: ''
})

const initializeForm = () => {
  if (user.value) {
    const names = user.value.name?.split(' ') || ['', '']
    profileForm.value = {
      firstName: names[0],
      lastName: names[1] || '',
      email: user.value.email,
      phone: user.value.phone || '',
      bio: user.value.bio || ''
    }
  }
}

const resetForm = () => {
  initializeForm()
}

const updateProfile = async () => {
  saving.value = true
  
  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    toast.success('Profile updated successfully!')
  } catch (error) {
    toast.error('Failed to update profile')
  } finally {
    saving.value = false
  }
}

const changePassword = async () => {
  if (passwordForm.value.new !== passwordForm.value.confirm) {
    toast.error('New passwords do not match')
    return
  }
  
  changingPassword.value = true
  
  try {
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000))
    
    passwordForm.value = {
      current: '',
      new: '',
      confirm: ''
    }
    
    toast.success('Password changed successfully!')
  } catch (error) {
    toast.error('Failed to change password')
  } finally {
    changingPassword.value = false
  }
}

onMounted(() => {
  initializeForm()
})
</script>