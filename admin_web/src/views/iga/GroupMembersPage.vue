<template>
  <RoleBasedLayout>
    <div class="container-fluid">
      <!-- Header -->
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h1 class="h3 mb-0">Group Members</h1>
          <p class="text-muted">{{ groupTitle }}</p>
        </div>
        <div class="d-flex gap-2">
          <button class="btn btn-outline-secondary" @click="goBack">
            <i class="bi bi-arrow-left me-2"></i>Back to Groups
          </button>
        </div>
      </div>

      <!-- Group Info Card -->
      <div class="card mb-4">
        <div class="card-body">
          <div class="row">
            <div class="col-md-8">
              <h5 class="card-title">{{ groupTitle }}</h5>
              <p class="card-text text-muted">{{ groupDescription }}</p>
              <div class="d-flex gap-3 mb-3">
                <span class="badge bg-light text-dark">
                  <i :class="`bi bi-${getCategoryIcon(groupCategory)} me-1`"></i>
                  {{ groupCategory }}
                </span>
                <span :class="`badge bg-${groupStatus === 'active' ? 'success' : 'secondary'}`">
                  {{ groupStatus === 'active' ? 'Active' : 'Inactive' }}
                </span>
                <span class="badge bg-info">
                  <i class="bi bi-people me-1"></i>
                  {{ members.length }} members
                </span>
              </div>
              <div v-if="groupTiming" class="mb-2">
                <small class="text-muted">
                  <i class="bi bi-calendar me-1"></i>
                  Next Event: {{ formatTiming(groupTiming) }}
                </small>
              </div>
            </div>
            <div class="col-md-4 text-md-end">
              <div v-if="groupWhatsAppLink" class="mb-2">
                <a
                  :href="groupWhatsAppLink"
                  target="_blank"
                  class="btn btn-success btn-sm"
                >
                  <i class="bi bi-whatsapp me-1"></i>WhatsApp Group
                </a>
              </div>
              <div class="mb-2">
                <small class="text-muted">
                  <i class="bi bi-calendar-plus me-1"></i>
                  Created: {{ formatDate(groupCreatedAt) }}
                </small>
              </div>
              <div v-if="groupUpdatedAt && groupUpdatedAt !== groupCreatedAt">
                <small class="text-muted">
                  <i class="bi bi-calendar-check me-1"></i>
                  Updated: {{ formatDate(groupUpdatedAt) }}
                </small>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      </div>

      <!-- Members Table -->
      <div v-else class="card">
        <div class="card-header">
          <h5 class="card-title mb-0">Group Members</h5>
        </div>
        <div class="card-body p-0">
          <DataTable
            :columns="columns"
            :data="members"
            :loading="loading"
            empty-message="No members found in this group"
          >
            <template #cell-member="{ item }">
              <div class="d-flex align-items-center">
                <img
                  :src="`https://ui-avatars.com/api/?name=${item.full_name || 'User'}`"
                  :alt="item.full_name"
                  class="avatar me-3"
                />
                <div>
                  <div class="fw-medium">{{ item.full_name }}</div>
                  <small class="text-muted">ID: {{ item.user_id }}</small>
                </div>
              </div>
            </template>
            <template #cell-role="{ item }">
              <span :class="`badge bg-${getRoleBadgeClass(item.role)}`">
                {{ formatRole(item.role) }}
              </span>
            </template>
            <template #cell-status="{ item }">
              <span :class="`badge bg-${getStatusBadgeClass(item.status)}`">
                {{ formatStatus(item.status) }}
              </span>
            </template>
            <template #cell-joined="{ item }">
              {{ formatDate(item.joined_at) }}
            </template>
            <template #cell-actions="{ item }">
              <!-- No actions available yet -->
            </template>
          </DataTable>
        </div>
      </div>
    </div>
  </RoleBasedLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import RoleBasedLayout from '@/components/common/RoleBasedLayout.vue'
import DataTable from '@/components/ui/DataTable.vue'
import { useToast } from 'vue-toast-notification'
import interestGroupsService from '@/services/interestGroupsService'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const toast = useToast()

// State
const loading = ref(false)
const groupInfo = ref({})
const members = ref([])

// Route params
const groupId = computed(() => parseInt(route.params.groupId))

// Computed properties
const groupTitle = computed(() => groupInfo.value.group_title || 'Loading...')
const groupDescription = computed(() => groupInfo.value.group_description || 'No description available')
const groupCategory = computed(() => groupInfo.value.group_category || 'Other')
const groupStatus = computed(() => groupInfo.value.group_status || 'unknown')
const groupWhatsAppLink = computed(() => groupInfo.value.group_whatsapp_link)
const groupCreatedAt = computed(() => groupInfo.value.group_created_at)
const groupUpdatedAt = computed(() => groupInfo.value.group_updated_at)
const groupTiming = computed(() => groupInfo.value.group_timing)
const currentUserId = computed(() => authStore.user?.id)

// Check if current user can manage this group
const canManageGroup = computed(() => {
  return authStore.userRole === 'admin' ||
         (authStore.userRole === 'iga' && groupInfo.value.created_by === currentUserId.value)
})

// Table columns
const columns = [
  { key: 'member', label: 'Member' },
  { key: 'role', label: 'Role' },
  { key: 'status', label: 'Status' },
  { key: 'joined', label: 'Joined Date' },
  { key: 'actions', label: 'Actions', class: 'text-end' },
]

// Helper functions
const getCategoryIcon = (category) => {
  return interestGroupsService.getCategoryIcon(category)
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString()
}

const formatRole = (role) => {
  const roleMap = {
    'admin': 'Admin',
    'iga': 'Interest Group Admin',
    'support': 'Support',
    'user': 'User'
  }
  return roleMap[role] || role
}

const formatStatus = (status) => {
  const statusMap = {
    'active': 'Active',
    'pending_approval': 'Pending',
    'blocked': 'Blocked'
  }
  return statusMap[status] || status
}

const formatTiming = (timing) => {
  if (!timing) return 'N/A'
  const [date, time] = timing.split('T')
  return `${date} at ${time}`
}

const getRoleBadgeClass = (role) => {
  const classes = {
    'admin': 'danger',
    'iga': 'purple',
    'support': 'secondary',
    'user': 'primary'
  }
  return classes[role] || 'secondary'
}

const getStatusBadgeClass = (status) => {
  const classes = {
    'active': 'success',
    'pending_approval': 'warning',
    'blocked': 'danger'
  }
  return classes[status] || 'secondary'
}

// Load group members
const loadGroupMembers = async () => {
  loading.value = true
  try {
    const response = await interestGroupsService.getGroupMembers(groupId.value)
    // API returns { data: { group_id, group_title, members } }
    const data = response.data || response

    // Extract group info and members
    groupInfo.value = {
      group_title: data.group_title,
      group_description: data.group_description,
      group_category: data.group_category,
      group_status: data.group_status,
      group_whatsapp_link: data.group_whatsapp_link,
      group_created_at: data.group_created_at,
      group_updated_at: data.group_updated_at,
      group_timing: data.group_timing,
      created_by: data.created_by
    }
    members.value = data.members || []

  } catch (error) {
    console.error('Failed to load group members:', error)
    toast.error('Failed to load group members')
  } finally {
    loading.value = false
  }
}

// Navigation functions
const goBack = () => {
  if (authStore.userRole === 'admin') {
    router.push('/admin/interest-groups')
  } else {
    router.push('/iga/groups')
  }
}

// Initialize
onMounted(() => {
  if (groupId.value) {
    loadGroupMembers()
  } else {
    toast.error('Invalid group ID')
    goBack()
  }
})
</script>

<style scoped>
.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
}
</style>
