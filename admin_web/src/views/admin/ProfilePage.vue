<template>
  <RoleBasedLayout>
    <div class="container-fluid">
      <h1 class="h3 mb-4">Profile</h1>

      <div class="row">
        <div class="col-12 col-md-4">
          <!-- Profile Card -->
          <div class="card mb-4">
            <div class="card-body text-center">
              <img
                :src="user?.profileImage || `https://ui-avatars.com/api/?name=${user?.full_name}`"
                :alt="user?.full_name"
                class="rounded-circle mb-3"
                style="width: 150px; height: 150px; object-fit: cover"
              />
              <h5 class="card-title">{{ user?.full_name || 'User' }}</h5>
              <p class="text-muted">{{ getRoleDisplayName(authStore.userRole) }}</p>

              <!-- Status Badge -->
              <div class="mb-3">
                <span :class="getStatusBadgeClass(user?.status)">
                  <i :class="getStatusIcon(user?.status)" class="me-1"></i>
                  {{ getStatusDisplayName(user?.status) }}
                </span>
              </div>

              <!-- Status-specific messaging for IGA -->
              <div
                v-if="isIGA && user?.status === 'pending_approval'"
                class="alert alert-warning py-2"
              >
                <small>
                  <i class="bi bi-clock me-1"></i>
                  Your application is under review. You'll be notified once approved.
                </small>
              </div>
            </div>
          </div>

          <!-- Account Info -->
          <div class="card">
            <div class="card-header">
              <h6 class="mb-0">Account Information</h6>
            </div>
            <div class="card-body">
              <div class="d-flex justify-content-between mb-2">
                <span>Member Since</span>
                <strong>{{ memberSince }}</strong>
              </div>
              <div class="d-flex justify-content-between mb-2">
                <span>Role</span>
                <strong>{{ getRoleDisplayName(authStore.userRole) }}</strong>
              </div>
              <div class="d-flex justify-content-between mb-2">
                <span>Email</span>
                <small class="text-muted">{{ user?.email || user?.gmail_id }}</small>
              </div>
              <div v-if="isIGA" class="d-flex justify-content-between">
                <span>Groups Managed</span>
                <strong>{{ user?.groups_count || '0' }}</strong>
              </div>
            </div>
          </div>
        </div>

        <div class="col-12 col-md-8">
          <!-- Basic Profile Form -->
          <div class="card">
            <div class="card-header">
              <h6 class="mb-0">Basic Information</h6>
            </div>
            <div class="card-body">
              <form @submit.prevent="updateProfile">
                <div class="row g-3">
                  <div class="col-12">
                    <label class="form-label">Full Name</label>
                    <input
                      v-model="profileForm.fullName"
                      type="text"
                      class="form-control"
                      required
                      :readonly="!canEditProfile"
                    />
                    <div v-if="!canEditProfile && isIGA" class="form-text text-warning">
                      <i class="bi bi-info-circle me-1"></i>
                      Profile editing is disabled until account is approved
                    </div>
                  </div>

                  <div class="col-12">
                    <label class="form-label">Email Address</label>
                    <input
                      :value="user?.email || user?.gmail_id"
                      type="email"
                      class="form-control"
                      readonly
                      disabled
                    />
                    <div class="form-text">Email address cannot be changed</div>
                  </div>

                  <div v-if="isIGA" class="col-12">
                    <label class="form-label">Date of Birth</label>
                    <input
                      v-model="profileForm.dateOfBirth"
                      type="date"
                      class="form-control"
                      :readonly="!canEditProfile"
                    />
                  </div>
                </div>

                <hr class="my-4" />

                <div class="d-flex justify-content-end gap-2">
                  <button
                    type="button"
                    class="btn btn-secondary"
                    @click="resetForm"
                    :disabled="!canEditProfile"
                  >
                    Reset
                  </button>
                  <button
                    type="submit"
                    class="btn btn-success"
                    :disabled="saving || !canEditProfile"
                  >
                    <span v-if="saving" class="spinner-border spinner-border-sm me-2"></span>
                    Save Changes
                  </button>
                </div>
              </form>
            </div>
          </div>

          <!-- IGA-specific Verification Information (Read-only) -->
          <div v-if="isIGA && (user?.youtube_url || user?.description || user?.tags)" class="card mt-4">
            <div class="card-header">
              <h6 class="mb-0">
                <i class="bi bi-patch-check me-2"></i>
                Verification Information
              </h6>
            </div>
            <div class="card-body">
              <div v-if="user?.youtube_url" class="mb-3">
                <label class="form-label">Verification Video</label>
                <div class="input-group">
                  <input
                    :value="user.youtube_url"
                    type="url"
                    class="form-control"
                    readonly
                  />
                  <a
                    :href="user.youtube_url"
                    target="_blank"
                    class="btn btn-outline-primary"
                  >
                    <i class="bi bi-play-circle me-1"></i>
                    Watch
                  </a>
                </div>
                <div class="form-text">
                  YouTube video submitted during registration for verification
                </div>
              </div>

              <div v-if="user?.description" class="mb-3">
                <label class="form-label">AI-Generated Profile</label>
                <textarea
                  :value="user.description"
                  class="form-control"
                  rows="3"
                  readonly
                ></textarea>
                <div class="form-text">
                  <i class="bi bi-robot me-1"></i>
                  Automatically generated from your verification video
                </div>
              </div>

              <div v-if="user?.tags" class="mb-3">
                <label class="form-label">Activity Tags</label>
                <div class="mt-2">
                  <span
                    v-for="(tag, index) in parseUserTags"
                    :key="index"
                    class="badge bg-primary me-2 mb-2 p-2"
                  >
                    {{ tag }}
                  </span>
                </div>
                <div class="form-text">
                  <i class="bi bi-robot me-1"></i>
                  Tags extracted from your verification video to categorize your interests
                </div>
              </div>

              <div class="alert alert-info">
                <i class="bi bi-info-circle me-2"></i>
                <strong>Note:</strong> This verification information was automatically generated during your registration and cannot be edited. Contact support if you need to update your verification details.
              </div>
            </div>
          </div>

          <!-- Note for non-editable profiles -->
          <div v-if="!canEditProfile && isIGA" class="card mt-4">
            <div class="card-body">
              <div class="d-flex align-items-center text-info">
                <i class="bi bi-info-circle fs-4 me-3"></i>
                <div>
                  <h6 class="mb-1">Profile Under Review</h6>
                  <p class="mb-0">
                    Your Interest Group Admin application is currently being reviewed. Profile
                    editing and group management features will be available once your account is
                    approved.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </RoleBasedLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import RoleBasedLayout from '@/components/common/RoleBasedLayout.vue'
import { useAuthStore } from '@/stores/auth'
import { useToast } from 'vue-toast-notification'

const authStore = useAuthStore()
const toast = useToast()

const user = computed(() => authStore.user)
const isIGA = computed(() => authStore.userRole === 'iga')

// Check if profile can be edited (only active users can edit)
const canEditProfile = computed(() => {
  return authStore.canAccess && user.value?.status === 'active'
})

const memberSince = computed(() => {
  if (!user.value?.created_at && !user.value?.createdAt) return 'Recently'
  const date = user.value.created_at || user.value.createdAt
  return new Date(date).toLocaleDateString()
})

// Parse user tags for display (read-only)
const parseUserTags = computed(() => {
  if (!user.value?.tags) return []
  
  if (Array.isArray(user.value.tags)) {
    return user.value.tags
  }
  
  if (typeof user.value.tags === 'string') {
    return user.value.tags
      .split(',')
      .map((tag) => tag.trim())
      .filter((tag) => tag.length > 0)
  }
  
  return []
})

const saving = ref(false)

const profileForm = ref({
  fullName: '',
  dateOfBirth: '',
})

// Get role display name
const getRoleDisplayName = (role) => {
  switch (role) {
    case 'admin':
      return 'Administrator'
    case 'support':
      return 'Support User'
    case 'iga':
      return 'Interest Group Admin'
    default:
      return role || 'User'
  }
}

// Get status display name
const getStatusDisplayName = (status) => {
  switch (status?.toLowerCase()) {
    case 'active':
      return 'Active'
    case 'pending_approval':
      return 'Pending Approval'
    case 'blocked':
      return 'Blocked'
    default:
      return 'Unknown'
  }
}

const getStatusBadgeClass = (status) => {
  switch (status?.toLowerCase()) {
    case 'active':
      return 'badge bg-success'
    case 'pending_approval':
      return 'badge bg-warning'
    case 'blocked':
      return 'badge bg-danger'
    default:
      return 'badge bg-secondary'
  }
}

const getStatusIcon = (status) => {
  switch (status?.toLowerCase()) {
    case 'active':
      return 'bi bi-check-circle-fill'
    case 'pending_approval':
      return 'bi bi-clock-fill'
    case 'blocked':
      return 'bi bi-x-circle-fill'
    default:
      return 'bi bi-question-circle-fill'
  }
}

const initializeForm = () => {
  if (user.value) {
    profileForm.value = {
      fullName: user.value.full_name || '',
      dateOfBirth: user.value.date_of_birth || '',
    }
  }
}

const resetForm = () => {
  initializeForm()
}

const updateProfile = async () => {
  if (!canEditProfile.value) {
    toast.warning('Profile editing is disabled until account approval')
    return
  }

  saving.value = true

  try {
    const success = await authStore.updateProfile({
      full_name: profileForm.value.fullName,
      date_of_birth: profileForm.value.dateOfBirth,
    })

    if (success) {
      toast.success('Profile updated successfully!')
    } else {
      toast.error('Failed to update profile')
    }
  } catch (error) {
    console.error('Profile update error:', error)
    toast.error('Failed to update profile')
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  initializeForm()
})
</script>
