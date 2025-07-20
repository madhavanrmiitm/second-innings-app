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
                <span>Groups</span>
                <strong>{{ user?.groups_count || '0' }}</strong>
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
                  <div class="col-12">
                    <label class="form-label">Full Name</label>
                    <input
                      v-model="profileForm.fullName"
                      type="text"
                      class="form-control"
                      required
                      :readonly="!canEditProfile"
                    />
                    <div v-if="!canEditProfile" class="form-text text-warning">
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

                  <div v-if="isIGA" class="col-12">
                    <label class="form-label">YouTube Video URL</label>
                    <input
                      v-model="profileForm.youtubeUrl"
                      type="url"
                      class="form-control"
                      placeholder="https://youtube.com/watch?v=..."
                      :readonly="!canEditProfile"
                    />
                    <div class="form-text">
                      Your YouTube video for Interest Group Admin verification
                    </div>
                  </div>

                  <div v-if="isIGA" class="col-12">
                    <label class="form-label">Video Description</label>
                    <textarea
                      v-model="profileForm.description"
                      class="form-control"
                      rows="4"
                      placeholder="Description extracted from your YouTube video..."
                      :readonly="!canEditProfile"
                    ></textarea>
                    <div class="form-text">
                      <i class="bi bi-info-circle me-1"></i>
                      This description is automatically extracted from your YouTube video
                    </div>
                  </div>

                  <div v-if="isIGA" class="col-12">
                    <label class="form-label">Tags</label>
                    <div class="input-group">
                      <input
                        v-model="tagsInput"
                        type="text"
                        class="form-control"
                        placeholder="Add tags separated by commas..."
                        :readonly="!canEditProfile"
                        @keypress.enter.prevent="addTag"
                      />
                      <button
                        v-if="canEditProfile && tagsInput.trim()"
                        type="button"
                        class="btn btn-outline-primary"
                        @click="addTag"
                      >
                        Add
                      </button>
                    </div>

                    <!-- Display Tags -->
                    <div v-if="profileForm.tags.length > 0" class="mt-2">
                      <span
                        v-for="(tag, index) in profileForm.tags"
                        :key="index"
                        class="badge bg-primary me-2 mb-2 p-2"
                      >
                        {{ tag }}
                        <button
                          v-if="canEditProfile"
                          type="button"
                          class="btn-close btn-close-white ms-2"
                          style="font-size: 0.7em"
                          @click="removeTag(index)"
                        ></button>
                      </span>
                    </div>

                    <div class="form-text">
                      <i class="bi bi-info-circle me-1"></i>
                      Tags help categorize your interest group and are partially extracted from your
                      YouTube video
                    </div>
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

const saving = ref(false)

const profileForm = ref({
  fullName: '',
  dateOfBirth: '',
  youtubeUrl: '',
  description: '',
  tags: [],
})

const tagsInput = ref('')

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

// Get status badge class
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

// Get status icon
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
    // Parse tags - handle both string and array formats
    let parsedTags = []
    if (user.value.tags) {
      if (Array.isArray(user.value.tags)) {
        parsedTags = user.value.tags
      } else if (typeof user.value.tags === 'string') {
        // If tags is a string, split by comma and clean up
        parsedTags = user.value.tags
          .split(',')
          .map((tag) => tag.trim())
          .filter((tag) => tag.length > 0)
      }
    } else if (isIGA.value) {
      // Demo tags for IGA users if no tags exist
      parsedTags = [
        'Cooking',
        'Reading',
        'Group Activities',
        'Entertainment',
        'Fitness',
        'Learning',
      ]
    }

    profileForm.value = {
      fullName: user.value.full_name || '',
      dateOfBirth: user.value.date_of_birth || '',
      youtubeUrl: user.value.youtube_url || '',
      description:
        user.value.description ||
        'Sample description extracted from your YouTube video about interest group activities, cooking tutorials, and community engagement...',
      tags: parsedTags,
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
    // Update the auth store with new profile data
    const success = await authStore.updateProfile({
      full_name: profileForm.value.fullName,
      date_of_birth: profileForm.value.dateOfBirth,
      youtube_url: profileForm.value.youtubeUrl,
      description: profileForm.value.description,
      tags: profileForm.value.tags,
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

const addTag = () => {
  if (canEditProfile.value && tagsInput.value.trim()) {
    const newTags = tagsInput.value
      .split(',')
      .map((tag) => tag.trim())
      .filter((tag) => tag.length > 0 && !profileForm.value.tags.includes(tag))

    profileForm.value.tags.push(...newTags)
    tagsInput.value = ''
  }
}

const removeTag = (index) => {
  profileForm.value.tags.splice(index, 1)
}

onMounted(() => {
  initializeForm()
})
</script>
