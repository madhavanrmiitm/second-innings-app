<template>
  <AppLayout>
    <div class="container-fluid">
      <!-- Header -->
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3">Manage Users</h1>
        <!-- Note: User creation is handled through registration flow -->
      </div>

      <!-- Filters -->
      <div class="card mb-4">
        <div class="card-body">
          <div class="row g-3">
            <div class="col-12 col-md-3">
              <input
                v-model="filters.search"
                type="text"
                class="form-control"
                placeholder="Search by name or email..."
                @input="updateFilters"
              />
            </div>
            <div class="col-12 col-md-3">
              <select v-model="filters.status" class="form-select" @change="updateFilters">
                <option value="">All Status</option>
                <option value="active">Active</option>
                <option value="pending_approval">Pending Approval</option>
                <option value="blocked">Blocked</option>
              </select>
            </div>
            <div class="col-12 col-md-3">
              <select v-model="filters.role" class="form-select" @change="updateFilters">
                <option value="">All Roles</option>
                <option value="admin">Admin</option>
                <option value="support_user">Support User</option>
                <option value="interest_group_admin">IGA</option>
                <option value="caregiver">Caregiver</option>
                <option value="family_member">Family Member</option>
                <option value="senior_citizen">Senior Citizen</option>
              </select>
            </div>
            <div class="col-12 col-md-3">
              <button @click="resetFilters" class="btn btn-secondary w-100">
                <i class="bi bi-arrow-counterclockwise me-2"></i>Reset
              </button>
            </div>
          </div>
        </div>
      </div>

      <!---- Users Table ---->

      <div class="card">
        <div class="card-body p-0">
          <DataTable
            :columns="columns"
            :data="filteredUsers"
            :loading="adminStore.loading.users"
            empty-message="No users found"
          >
            <template #cell-user="{ item }">
              <div class="d-flex align-items-center">
                <img
                  :src="`https://ui-avatars.com/api/?name=${item.full_name || 'User'}`"
                  :alt="item.full_name"
                  class="avatar me-3"
                />
                <div>
                  <div class="fw-medium">{{ item.full_name }}</div>
                  <small class="text-muted">{{ item.gmail_id }}</small>
                </div>
              </div>
            </template>

            <template #cell-role="{ item }">
              <span class="badge bg-primary">{{ formatRole(item.role) }}</span>
            </template>

            <template #cell-status="{ item }">
              <span :class="`badge bg-${getStatusColor(item.status)}`">
                {{ formatStatus(item.status) }}
              </span>
            </template>

            <template #cell-created_at="{ item }">
              <span>{{ formatDate(item.created_at) }}</span>
            </template>

            <template #cell-actions="{ item }">
              <div class="btn-group btn-group-sm" role="group">
                <button
                  @click="confirmDelete(item)"
                  class="btn btn-outline-danger"
                  title="Delete"
                  :disabled="adminStore.loading.deleteUser || item.role === 'admin'"
                >
                  <i class="bi bi-trash"></i>
                </button>
              </div>
            </template>
          </DataTable>
        </div>
      </div>
    </div>


  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import AppLayout from '@/components/common/AppLayout.vue'
import DataTable from '@/components/ui/DataTable.vue'
import { useAdminStore } from '@/stores/admin'
import { useToast } from 'vue-toast-notification'

const adminStore = useAdminStore()
const toast = useToast()

const filters = ref({
  search: '',
  status: '',
  role: '',
})

const columns = [
  { key: 'user', label: 'User' },
  { key: 'role', label: 'Role' },
  { key: 'status', label: 'Status' },
  { key: 'created_at', label: 'Created Date' },
  { key: 'actions', label: 'Actions', class: 'text-end' },
]

const filteredUsers = computed(() => adminStore.filteredUsers)

const updateFilters = () => {
  adminStore.updateFilters(filters.value)
}

const resetFilters = () => {
  filters.value = {
    search: '',
    status: '',
    role: '',
  }
  updateFilters()
}

const getStatusColor = (status) => {
  const colors = {
    active: 'success',
    pending_approval: 'warning',
    blocked: 'danger',
  }
  return colors[status] || 'secondary'
}

const formatStatus = (status) => {
  const statusMap = {
    active: 'Active',
    pending_approval: 'Pending Approval',
    blocked: 'Blocked',
  }
  return statusMap[status] || status
}

const formatRole = (role) => {
  const roleMap = {
    admin: 'Admin',
    support_user: 'Support User',
    interest_group_admin: 'IGA',
    caregiver: 'Caregiver',
    family_member: 'Family Member',
    senior_citizen: 'Senior Citizen',
  }
  return roleMap[role] || role
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString()
}

const confirmDelete = (user) => {
  if (user.role === 'admin') {
    toast.error('Cannot delete admin users')
    return
  }

  const userId = user.id || user.user_id || user._id

  if (confirm(`Are you sure you want to delete ${user.full_name}?`)) {
    deleteUser(userId)
  }
}

const deleteUser = async (id) => {
  if (!id) {
    toast.error('Invalid user ID')
    return
  }

  const result = await adminStore.deleteUser(id)

  if (result.success) {
    toast.success('User deleted successfully!')
  } else {
    toast.error(result.error || 'Delete failed')
  }
}

onMounted(() => {
  // Check if user is authenticated for admin operations
  if (!adminStore.isAuthenticatedForAdmin()) {
    console.warn('User not authenticated for admin operations')
    return
  }

  adminStore.fetchUsers()
})
</script>
