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
          <StatCard title="Total Members" :value="totalMembers" icon="user-check" color="success" />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard title="Active Groups" :value="activeGroupsCount" icon="bell" color="info" />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard title="This Month Events" value="8" icon="ticket" color="warning" />
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

                <template #cell-status="{ item }">
                  <span :class="`badge bg-${item.active ? 'success' : 'secondary'}`">
                    {{ item.active ? 'Active' : 'Inactive' }}
                  </span>
                </template>

                <template #cell-members="{ item }">
                  <div class="text-center">
                    <strong>{{ item.members }}</strong>
                  </div>
                </template>

                <template #cell-actions="{ item }">
                  <div class="btn-group btn-group-sm">
                    <button @click="manageGroup(item)" class="btn btn-outline-primary">
                      Manage
                    </button>
                    <button @click="viewMembers(item)" class="btn btn-outline-info">Members</button>
                    <button
                      @click="toggleStatus(item)"
                      :class="`btn btn-outline-${item.active ? 'warning' : 'success'}`"
                    >
                      {{ item.active ? 'Pause' : 'Activate' }}
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

const toast = useToast()
const authStore = useAuthStore()
const loading = ref(false)

// User status from auth store
const userStatus = computed(() => authStore.userStatus)

// Check if user can manage groups (only active users)
const canManageGroups = computed(() => {
  return authStore.canAccess && userStatus.value === 'active'
})

// Hardcoded groups data for current IGA
const myGroups = ref([
  {
    id: 1,
    name: 'Morning Yoga Group',
    description: 'Daily yoga sessions for seniors',
    category: 'health',
    members: 25,
    active: true,
    createdAt: '2024-01-15',
  },
  {
    id: 2,
    name: 'Book Reading Club',
    description: 'Weekly book discussions',
    category: 'education',
    members: 18,
    active: true,
    createdAt: '2024-02-20',
  },
  {
    id: 3,
    name: 'Garden Enthusiasts',
    description: 'Gardening tips and plant care',
    category: 'hobby',
    members: 32,
    active: false,
    createdAt: '2024-03-10',
  },
  {
    id: 4,
    name: 'Tech Learning Circle',
    description: 'Learn smartphones and internet',
    category: 'technology',
    members: 15,
    active: true,
    createdAt: '2024-04-05',
  },
])

const columns = [
  { key: 'group', label: 'Group' },
  { key: 'category', label: 'Category' },
  { key: 'members', label: 'Members' },
  { key: 'status', label: 'Status' },
  { key: 'actions', label: 'Actions', class: 'text-end' },
]

const totalMembers = computed(() =>
  myGroups.value.reduce((total, group) => total + group.members, 0),
)

const activeGroupsCount = computed(() => myGroups.value.filter((g) => g.active).length)

const getGroupIcon = (category) => {
  const icons = {
    health: 'heart',
    education: 'book',
    hobby: 'palette',
    technology: 'laptop',
    sports: 'trophy',
    social: 'people',
  }
  return icons[category] || 'circle'
}

// Initialize component and refresh user profile
onMounted(async () => {
  // Refresh user profile to get latest status
  loading.value = true
  try {
    await authStore.refreshUserProfile()
  } catch (error) {
    console.error('Failed to refresh user profile:', error)
    toast.error('Failed to refresh user status')
  } finally {
    loading.value = false
  }
})

const createGroup = () => {
  toast.info('Create new group functionality coming soon')
}

const manageGroup = (group) => {
  toast.info(`Managing group: ${group.name}`)
}

const viewMembers = (group) => {
  toast.info(`Viewing ${group.members} members of ${group.name}`)
}

const toggleStatus = (group) => {
  group.active = !group.active
  const status = group.active ? 'activated' : 'paused'
  toast.success(`Group ${group.name} has been ${status}`)
}
</script>
