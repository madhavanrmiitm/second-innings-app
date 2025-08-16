<template>
  <AppLayout>
    <div class="container-fluid">
      <!-- Header -->
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3">Manage Interest Group Admins</h1>
        <div>
          <button @click="goToApprovals" class="btn btn-primary">
            <i class="bi bi-person-check me-2"></i>Approve Interest Group Admins
          </button>
        </div>
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
                <option value="Pending">Pending</option>
                <option value="Approved">Approved</option>
                <option value="Rejected">Rejected</option>
              </select>
            </div>
            <div class="col-12 col-md-3">
              <select v-model="filters.specialization" class="form-select" @change="updateFilters">
                <option value="">All Specializations</option>
                <option value="Technology">Technology</option>
                <option value="Health">Health</option>
                <option value="Education">Education</option>
                <option value="Sports">Sports</option>
                <option value="Arts">Arts</option>
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

      <!-- Interest Group Admins Table -->
      <div class="card">
        <div class="card-body p-0">
          <DataTable
            :columns="columns"
            :data="filteredInterestGroupAdmins"
            :loading="adminStore.loading.interestGroupAdmins"
            empty-message="No interest group admins found"
          >
            <template #cell-admin="{ item }">
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
            <template #cell-specialization="{ item }">
              {{ item.tags || 'N/A' }}
            </template>
            <template #cell-status="{ item }">
              <span
                :class="`badge bg-${
                  item.status === 'active'
                    ? 'success'
                    : item.status === 'blocked'
                      ? 'danger'
                      : 'warning'
                }`"
              >
                {{ formatStatus(item.status) }}
              </span>
            </template>
            <template #cell-actions="{ item }">
              <div class="btn-group btn-group-sm" role="group">
                <button @click="viewDetails(item)" class="btn btn-outline-info" title="View">
                  <i class="bi bi-eye"></i>
                </button>
                <button
                  v-if="item.status === 'pending_approval'"
                  @click="approveInterestGroupAdmin(item)"
                  class="btn btn-outline-success"
                  title="Approve"
                >
                  <i class="bi bi-check-circle"></i>
                </button>
                <button
                  v-if="item.status === 'pending_approval'"
                  @click="rejectInterestGroupAdmin(item)"
                  class="btn btn-outline-warning"
                  title="Reject"
                >
                  <i class="bi bi-x-circle"></i>
                </button>
                <button @click="confirmDelete(item)" class="btn btn-outline-danger" title="Delete">
                  <i class="bi bi-trash"></i>
                </button>
              </div>
            </template>
          </DataTable>
        </div>
      </div>
    </div>

    <!-- Details Modal -->
    <div
      class="modal fade"
      tabindex="-1"
      :class="{ show: showDetailsModal }"
      :style="{ display: showDetailsModal ? 'block' : 'none' }"
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Interest Group Admin Details</h5>
            <button type="button" class="btn-close" @click="closeDetailsModal"></button>
          </div>
          <div class="modal-body">
            <div class="row">
              <div class="col-md-6">
                <p><strong>Name:</strong> {{ selected.full_name }}</p>
                <p><strong>Email:</strong> {{ selected.gmail_id }}</p>
                <p><strong>Status:</strong> {{ formatStatus(selected.status) }}</p>
                <p><strong>Created:</strong> {{ formatDate(selected.created_at) }}</p>
              </div>
              <div class="col-md-6">
                <p><strong>Description:</strong> {{ selected.description || 'N/A' }}</p>
                <p><strong>Tags:</strong> {{ selected.tags || 'N/A' }}</p>
                <p v-if="selected.youtube_url">
                  <strong>YouTube URL:</strong>
                  <a :href="selected.youtube_url" target="_blank">{{ selected.youtube_url }}</a>
                </p>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeDetailsModal">Close</button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="showDetailsModal" class="modal-backdrop fade show" @click="closeDetailsModal"></div>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import AppLayout from '@/components/common/AppLayout.vue'
import DataTable from '@/components/ui/DataTable.vue'
import { useAdminStore } from '@/stores/admin'
import { useToast } from 'vue-toast-notification'

const toast = useToast()
const router = useRouter()
const adminStore = useAdminStore()
const showDetailsModal = ref(false)
const selected = ref({})

const filters = ref({ search: '', status: '', specialization: '' })

const columns = [
  { key: 'admin', label: 'Interest Group Admin' },
  { key: 'specialization', label: 'Specialization' },
  { key: 'status', label: 'Status' },
  { key: 'created_at', label: 'Joined Date' },
  { key: 'actions', label: 'Actions', class: 'text-end' },
]

const filteredInterestGroupAdmins = computed(() => {
  const interestGroupAdmins = adminStore.interestGroupAdmins || []
  return interestGroupAdmins.filter((iga) => {
    const matchesSearch = [iga.full_name, iga.gmail_id].some((field) =>
      field?.toLowerCase().includes(filters.value.search.toLowerCase()),
    )
    const matchesStatus = filters.value.status ? iga.status === filters.value.status : true
    const matchesSpec = filters.value.specialization
      ? iga.tags?.includes(filters.value.specialization)
      : true
    return matchesSearch && matchesStatus && matchesSpec
  })
})

const updateFilters = () => {
  // Filters are applied in computed property
}

const resetFilters = () => {
  filters.value = { search: '', status: '', specialization: '' }
}

const viewDetails = (item) => {
  selected.value = item
  showDetailsModal.value = true
}

const approveInterestGroupAdmin = async (item) => {
  if (confirm(`Approve ${item.full_name}?`)) {
    try {
      const result = await adminStore.verifyInterestGroupAdmin(item.id, 'active')
      if (result.success) {
        toast.success(`${item.full_name} approved successfully`)
        // Refresh the interest group admins list
        await adminStore.fetchInterestGroupAdmins()
      } else {
        toast.error(result.error || 'Failed to approve interest group admin')
      }
    } catch (error) {
      console.error('Failed to approve interest group admin:', error)
      toast.error('Failed to approve interest group admin')
    }
  }
}

const rejectInterestGroupAdmin = async (item) => {
  if (confirm(`Reject ${item.full_name}?`)) {
    try {
      const result = await adminStore.verifyInterestGroupAdmin(item.id, 'blocked')
      if (result.success) {
        toast.success(`${item.full_name} rejected`)
        // Refresh the interest group admins list
        await adminStore.fetchInterestGroupAdmins()
      } else {
        toast.error(result.error || 'Failed to reject interest group admin')
      }
    } catch (error) {
      console.error('Failed to reject interest group admin:', error)
      toast.error('Failed to reject interest group admin')
    }
  }
}

const confirmDelete = (item) => {
  if (confirm(`Delete ${item.full_name}?`)) {
    // Note: Delete functionality would need to be implemented in the backend
    toast.error('Delete functionality not implemented yet')
  }
}

const closeDetailsModal = () => {
  showDetailsModal.value = false
  selected.value = {}
}

const goToApprovals = () => {
  router.push('/admin/interest-group-admins/approvals')
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString()
}

const formatStatus = (status) => {
  const statusMap = {
    active: 'Active',
    pending_approval: 'Pending Approval',
    blocked: 'Blocked',
  }
  return statusMap[status] || status
}

onMounted(async () => {
  // Load interest group admins data - authentication will be handled by API calls
  try {
    await adminStore.fetchInterestGroupAdmins()
  } catch (error) {
    console.error('Failed to fetch interest group admins:', error)
    toast.error('Failed to load interest group admins')
  }
})
</script>
