<template>
  <IgaLayout>
    <div class="container-fluid">
      <!-- Header -->
      <div class="mb-4">
        <h1 class="h3 mb-0">Interest Group Admin Dashboard</h1>
        <p class="text-muted">Manage your groups and community activities</p>
      </div>

      <!-- Status Alert for Pending Approval -->
      <div v-if="userStatus === 'pending_approval'" class="alert alert-warning mb-4" role="alert">
        <div class="d-flex align-items-center">
          <i class="bi bi-exclamation-triangle-fill me-3 fs-4"></i>
          <div>
            <h5 class="alert-heading mb-1">Account Under Review</h5>
            <p class="mb-2">
              Your Interest Group Admin application is currently being reviewed by our
              administrators. You will receive an email notification once your account is approved.
            </p>
            <p class="mb-0">
              <strong>Current Status:</strong> Pending Approval &nbsp;|&nbsp;
              <strong>Next Steps:</strong> Wait for admin approval to access group management
              features.
            </p>
          </div>
        </div>
      </div>

      <!-- Status Alert for Blocked -->
      <div v-if="userStatus === 'blocked'" class="alert alert-danger mb-4" role="alert">
        <div class="d-flex align-items-center">
          <i class="bi bi-x-circle-fill me-3 fs-4"></i>
          <div>
            <h5 class="alert-heading mb-1">Account Access Restricted</h5>
            <p class="mb-0">
              Your account has been restricted. Please contact support for assistance at
              <a href="mailto:support@2ndinnings.com">support@2ndinnings.com</a>
            </p>
          </div>
        </div>
      </div>

      <!-- Stats Grid - Only show for active users -->
      <div v-if="canManageGroups" class="row g-3 mb-4">
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard title="My Groups" :value="myGroups.length" icon="users" color="primary" />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard title="Active Groups" :value="activeGroupsCount" icon="bell" color="info" />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard title="Total Categories" :value="uniqueCategories" icon="grid" color="success" />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard title="Upcoming Events" :value="upcomingEvents" icon="calendar" color="warning" />
        </div>
      </div>

      <!-- Pending Approval Information Card -->
      <div v-if="!canManageGroups && userStatus === 'pending_approval'" class="row g-3 mb-4">
        <div class="col-12">
          <div class="card border-warning">
            <div class="card-body text-center py-5">
              <div class="mb-4">
                <i class="bi bi-hourglass-split text-warning" style="font-size: 4rem"></i>
              </div>
              <h4 class="text-warning mb-3">Application Under Review</h4>
              <p class="lead mb-4">
                Thank you for applying to become an Interest Group Admin! Our team is reviewing your
                application.
              </p>
              <div class="row justify-content-center">
                <div class="col-md-8">
                  <div class="alert alert-light border">
                    <h6 class="mb-2">What happens next?</h6>
                    <ul class="list-unstyled mb-0 text-start">
                      <li class="mb-1">
                        <i class="bi bi-check2 text-success me-2"></i>Application received and being
                        reviewed
                      </li>
                      <li class="mb-1">
                        <i class="bi bi-clock text-warning me-2"></i>Admin team will verify your
                        information
                      </li>
                      <li class="mb-1">
                        <i class="bi bi-envelope text-info me-2"></i>You'll receive email
                        notification once approved
                      </li>
                      <li>
                        <i class="bi bi-unlock text-success me-2"></i>Full access to group
                        management features will be granted
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
              <p class="text-muted mb-0">
                <small>
                  <i class="bi bi-info-circle me-1"></i>
                  Review typically takes 1-3 business days. You can update your profile information
                  while waiting.
                </small>
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- My Groups - Only show for active users -->
      <div v-if="canManageGroups" class="row g-3">
        <div class="col-12">
          <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
              <h5 class="card-title mb-0">My Groups</h5>
              <button class="btn btn-success btn-sm" @click="createGroup">
                <i class="bi bi-plus-circle me-2"></i>Create Group
              </button>
            </div>
            <div class="card-body">
              <DataTable
                :columns="columns"
                :data="myGroups"
                :loading="loading"
                empty-message="No groups found. Create your first group to get started!"
              >
                <template #cell-group="{ item }">
                  <div class="d-flex align-items-center">
                    <div class="bg-primary bg-opacity-10 rounded-circle p-2 me-3">
                      <i :class="`bi bi-${getGroupIcon(item.category)} text-primary`"></i>
                    </div>
                    <div>
                      <div class="fw-medium">{{ item.name }}</div>
                      <small class="text-muted">{{ item.description }}</small>
                    </div>
                  </div>
                </template>

                <template #cell-category="{ item }">
                  <span class="badge bg-light text-dark">{{ item.category }}</span>
                </template>

                <template #cell-status="{ item }">
                  <span :class="`badge bg-${item.status === 'active' ? 'success' : 'secondary'}`">
                    {{ item.status === 'active' ? 'Active' : 'Inactive' }}
                  </span>
                </template>

                <template #cell-timing="{ item }">
                  <small class="text-muted">{{ formatTiming(item.timing) }}</small>
                </template>

                <template #cell-actions="{ item }">
                  <div class="btn-group btn-group-sm">
                    <button @click="manageGroup(item)" class="btn btn-outline-primary">
                      Manage
                    </button>
                    <button 
                      v-if="item.whatsapp_link" 
                      @click="viewWhatsApp(item)" 
                      class="btn btn-outline-success"
                    >
                      WhatsApp
                    </button>
                    <button
                      @click="toggleStatus(item)"
                      :class="`btn btn-outline-${item.status === 'active' ? 'warning' : 'success'}`"
                    >
                      {{ item.status === 'active' ? 'Pause' : 'Activate' }}
                    </button>
                  </div>
                </template>
              </DataTable>
            </div>
          </div>
        </div>
      </div>
    </div>
  </IgaLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import IgaLayout from '@/components/layouts/IgaLayout.vue'
import StatCard from '@/components/ui/StatCard.vue'
import DataTable from '@/components/ui/DataTable.vue'
import { useToast } from 'vue-toast-notification'
import { useAuthStore } from '@/stores/auth'
import interestGroupsService from '@/services/interestGroupsService'

const toast = useToast()
const authStore = useAuthStore()
const loading = ref(false)
const myGroups = ref([])

// User status from auth store
const userStatus = computed(() => authStore.userStatus)

// Check if user can manage groups (only active users)
const canManageGroups = computed(() => {
  return authStore.canAccess && userStatus.value === 'active'
})

const columns = [
  { key: 'group', label: 'Group' },
  { key: 'category', label: 'Category' },
  { key: 'status', label: 'Status' },
  { key: 'timing', label: 'Next Event' },
  { key: 'actions', label: 'Actions', class: 'text-end' },
]

const totalMembers = computed(() => {
  // For MVP, we don't track membership, so this is placeholder
  return myGroups.value.length * 15 // Estimated average
})

const activeGroupsCount = computed(() => 
  myGroups.value.filter((g) => g.status === 'active').length
)

const uniqueCategories = computed(() => {
  const categories = new Set(myGroups.value.map(g => g.category).filter(Boolean))
  return categories.size
})

const upcomingEvents = computed(() => {
  const now = new Date()
  return myGroups.value.filter(g => {
    if (!g.timing) return false
    const eventDate = new Date(g.timing)
    return eventDate > now && g.status === 'active'
  }).length
})

const getGroupIcon = (category) => {
  return interestGroupsService.getCategoryIcon(category)
}

// Load interest groups from API
const loadInterestGroups = async () => {
  loading.value = true
  try {
    const response = await interestGroupsService.getInterestGroups()
    // API returns { data: { interest_groups: [...] } }
    const groups = response.data?.interest_groups || response.interest_groups || []
    myGroups.value = groups.map(group => ({
      id: group.id,
      name: group.title,
      description: group.description,
      category: group.category || 'Other',
      whatsapp_link: group.whatsapp_link,
      status: group.status,
      timing: group.timing,
      created_at: group.created_at,
      updated_at: group.updated_at
    }))
  } catch (error) {
    console.error('Failed to load interest groups:', error)
    toast.error('Failed to load interest groups')
  } finally {
    loading.value = false
  }
}

// Initialize component and refresh user profile
onMounted(async () => {
  // Refresh user profile to get latest status
  loading.value = true
  try {
    await authStore.refreshUserProfile()
    if (canManageGroups.value) {
      await loadInterestGroups()
    }
  } catch (error) {
    console.error('Failed to refresh user profile:', error)
    toast.error('Failed to refresh user status')
  } finally {
    loading.value = false
  }
})

const createGroup = () => {
  // Navigate to create group page or open modal
  window.location.href = '/iga/groups'
}

const manageGroup = (group) => {
  // Navigate to manage group page
  window.location.href = `/iga/groups?edit=${group.id}`
}

const viewWhatsApp = (group) => {
  if (group.whatsapp_link) {
    window.open(group.whatsapp_link, '_blank')
  } else {
    toast.warning('No WhatsApp link available for this group')
  }
}

const toggleStatus = async (group) => {
  try {
    const newStatus = group.status === 'active' ? 'inactive' : 'active'
    
    await interestGroupsService.updateInterestGroup(group.id, {
      status: newStatus
    })
    
    // Only update local state and show success if API call succeeded
    group.status = newStatus
    const statusText = newStatus === 'active' ? 'activated' : 'deactivated'
    toast.success(`Group ${group.name} has been ${statusText}`)
  } catch (error) {
    console.error('Failed to toggle group status:', error)
    // Show specific error message if available
    const errorMessage = error.response?.data?.message || 'Failed to update group status'
    toast.error(errorMessage)
  }
}

const formatTiming = (timing) => {
  return interestGroupsService.formatTiming(timing)
}
</script>
