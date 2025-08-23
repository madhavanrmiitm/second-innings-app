<template>
  <AppLayout>
    <div class="container-fluid">
      <!-- Header -->
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3">Manage Interest Groups</h1>
        <div class="d-flex gap-2">
          <button @click="refreshData" class="btn btn-outline-secondary" :disabled="loading">
            <i class="bi bi-arrow-clockwise me-2"></i>Refresh
          </button>
          <button @click="exportData" class="btn btn-outline-success" :disabled="loading">
            <i class="bi bi-download me-2"></i>Export
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
                placeholder="Search by title or description..."
                @input="updateFilters"
              />
            </div>
            <div class="col-12 col-md-2">
              <select v-model="filters.status" class="form-select" @change="updateFilters">
                <option value="">All Status</option>
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>
            <div class="col-12 col-md-2">
              <select v-model="filters.category" class="form-select" @change="updateFilters">
                <option value="">All Categories</option>
                <option v-for="cat in categories" :key="cat.value" :value="cat.value">
                  {{ cat.label }}
                </option>
              </select>
            </div>
            <div class="col-12 col-md-2">
              <select v-model="filters.creator" class="form-select" @change="updateFilters">
                <option value="">All Creators</option>
                <option v-for="creator in uniqueCreators" :key="creator" :value="creator">
                  {{ creator }}
                </option>
              </select>
            </div>
            <div class="col-12 col-md-3">
              <button @click="resetFilters" class="btn btn-secondary w-100">
                <i class="bi bi-arrow-counterclockwise me-2"></i>Reset Filters
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Interest Groups Table -->
      <div class="card">
        <div class="card-body p-0">
          <DataTable
            :columns="columns"
            :data="filteredInterestGroups"
            :loading="loading"
            empty-message="No interest groups found"
          >
            <template #cell-group="{ item }">
              <div class="d-flex align-items-center">
                <div class="bg-primary bg-opacity-10 rounded-circle p-2 me-3">
                  <i :class="`bi bi-${getCategoryIcon(item.category)} text-primary`"></i>
                </div>
                <div>
                  <div class="fw-medium">{{ item.title }}</div>
                  <small class="text-muted">{{ item.description }}</small>
                </div>
              </div>
            </template>
            <template #cell-creator="{ item }">
              <div class="d-flex align-items-center">
                <img
                  :src="`https://ui-avatars.com/api/?name=${item.creator_name || 'User'}`"
                  :alt="item.creator_name"
                  class="avatar me-2"
                />
                <div>
                  <div class="fw-medium">{{ item.creator_name || 'Unknown' }}</div>
                  <small class="text-muted">{{ item.creator_email || 'No email' }}</small>
                </div>
              </div>
            </template>
            <template #cell-category="{ item }">
              <span class="badge bg-light text-dark">
                <i :class="`bi bi-${getCategoryIcon(item.category)} me-1`"></i>
                {{ item.category || 'Other' }}
              </span>
            </template>
            <template #cell-status="{ item }">
              <span :class="`badge bg-${item.status === 'active' ? 'success' : 'secondary'}`">
                {{ item.status === 'active' ? 'Active' : 'Inactive' }}
              </span>
            </template>
            <template #cell-members="{ item }">
              <span class="badge bg-info">
                <i class="bi bi-people me-1"></i>
                {{ item.member_count || 0 }}
              </span>
            </template>
            <template #cell-timing="{ item }">
              <span v-if="item.timing" class="badge bg-info">
                <i class="bi bi-calendar me-1"></i>
                {{ formatTiming(item.timing) }}
              </span>
              <span v-else class="badge bg-secondary">No Event</span>
            </template>
            <template #cell-created="{ item }">
              {{ formatDate(item.created_at) }}
            </template>
            <template #cell-actions="{ item }">
              <div class="btn-group btn-group-sm" role="group">
                <button @click="viewMembers(item)" class="btn btn-outline-info" title="View Members">
                  <i class="bi bi-people"></i>
                </button>
                <button @click="viewDetails(item)" class="btn btn-outline-primary" title="View Details">
                  <i class="bi bi-eye"></i>
                </button>
                <button @click="editGroup(item)" class="btn btn-outline-warning" title="Edit">
                  <i class="bi bi-pencil"></i>
                </button>
                <button @click="toggleStatus(item)" class="btn btn-outline-secondary" title="Toggle Status">
                  <i :class="`bi bi-${item.status === 'active' ? 'pause' : 'play'}`"></i>
                </button>
                <button @click="deleteGroup(item)" class="btn btn-outline-danger" title="Delete">
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
            <h5 class="modal-title">Interest Group Details</h5>
            <button type="button" class="btn-close" @click="closeDetailsModal"></button>
          </div>
          <div class="modal-body">
            <div class="row">
              <div class="col-md-6">
                <p><strong>Title:</strong> {{ selected.title }}</p>
                <p><strong>Description:</strong> {{ selected.description || 'No description' }}</p>
                <p><strong>Category:</strong> {{ selected.category || 'Other' }}</p>
                <p><strong>Status:</strong> {{ formatStatus(selected.status) }}</p>
                <p><strong>Created:</strong> {{ formatDate(selected.created_at) }}</p>
              </div>
              <div class="col-md-6">
                <p><strong>Creator:</strong> {{ selected.creator_name || 'Unknown' }}</p>
                <p><strong>Member Count:</strong> {{ selected.member_count || 0 }}</p>
                <p v-if="selected.whatsapp_link">
                  <strong>WhatsApp Link:</strong>
                  <a :href="selected.whatsapp_link" target="_blank">{{ selected.whatsapp_link }}</a>
                </p>
                <p v-if="selected.timing">
                  <strong>Next Event:</strong> {{ formatTiming(selected.timing) }}
                </p>
                <p><strong>Last Updated:</strong> {{ formatDate(selected.updated_at) }}</p>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeDetailsModal">Close</button>
            <button @click="viewMembers(selected)" class="btn btn-primary">
              <i class="bi bi-people me-2"></i>View Members
            </button>
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
import { useToast } from 'vue-toast-notification'
import interestGroupsService from '@/services/interestGroupsService'

const toast = useToast()
const router = useRouter()
const loading = ref(false)
const showDetailsModal = ref(false)
const selected = ref({})
const interestGroups = ref([])

const filters = ref({ search: '', status: '', category: '', creator: '' })

// Get categories from service
const categories = computed(() => interestGroupsService.getCategories())

const columns = [
  { key: 'group', label: 'Interest Group' },
  { key: 'creator', label: 'Created By' },
  { key: 'category', label: 'Category' },
  { key: 'status', label: 'Status' },
  { key: 'members', label: 'Members' },
  { key: 'timing', label: 'Next Event' },
  { key: 'created', label: 'Created Date' },
  { key: 'actions', label: 'Actions', class: 'text-end' },
]

// Computed properties
const filteredInterestGroups = computed(() => {
  return interestGroups.value.filter((group) => {
    const matchesSearch = [group.title, group.description].some((field) =>
      field?.toLowerCase().includes(filters.value.search.toLowerCase()),
    )
    const matchesStatus = filters.value.status ? group.status === filters.value.status : true
    const matchesCategory = filters.value.category ? group.category === filters.value.category : true
    const matchesCreator = filters.value.creator ? group.creator_name === filters.value.creator : true
    return matchesSearch && matchesStatus && matchesCategory && matchesCreator
  })
})

const uniqueCreators = computed(() => {
  const creators = new Set(interestGroups.value.map(g => g.creator_name).filter(Boolean))
  return Array.from(creators).sort()
})

// Helper functions
const getCategoryIcon = (category) => {
  return interestGroupsService.getCategoryIcon(category)
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString()
}

const formatStatus = (status) => {
  return status === 'active' ? 'Active' : 'Inactive'
}

const formatTiming = (timing) => {
  return interestGroupsService.formatTiming(timing)
}

// Load interest groups from API
const loadInterestGroups = async () => {
  loading.value = true
  try {
    const response = await interestGroupsService.getInterestGroups()
    // API returns { data: { interest_groups: [...] } }
    const groups = response.data?.interest_groups || response.interest_groups || []

    // Transform data to include creator information
    interestGroups.value = groups.map(group => ({
      ...group,
      creator_name: group.created_by_name || 'Unknown',
      creator_email: group.created_by_email || 'No email'
    }))
  } catch (error) {
    console.error('Failed to load interest groups:', error)
    toast.error('Failed to load interest groups')
  } finally {
    loading.value = false
  }
}

// Filter functions
const updateFilters = () => {
  // Filters are applied in computed property
}

const resetFilters = () => {
  filters.value = { search: '', status: '', category: '', creator: '' }
}

// Action functions
const viewMembers = (group) => {
  router.push(`/admin/interest-groups/${group.id}/members`)
}

const viewDetails = (group) => {
  selected.value = group
  showDetailsModal.value = true
}

const editGroup = (group) => {
  router.push(`/admin/interest-groups/edit/${group.id}`)
}

const toggleStatus = async (group) => {
  try {
    const newStatus = group.status === 'active' ? 'inactive' : 'active'

    await interestGroupsService.updateInterestGroup(group.id, {
      status: newStatus
    })

    // Update local state
    group.status = newStatus
    const statusText = newStatus === 'active' ? 'activated' : 'deactivated'
    toast.success(`Group "${group.title}" has been ${statusText}`)
  } catch (error) {
    console.error('Failed to toggle group status:', error)
    toast.error('Failed to update group status')
  }
}

const deleteGroup = async (group) => {
  if (!confirm(`Are you sure you want to delete "${group.title}"? This action cannot be undone.`)) {
    return
  }

  try {
    await interestGroupsService.deleteInterestGroup(group.id)
    toast.success('Group deleted successfully')
    await loadInterestGroups()
  } catch (error) {
    console.error('Failed to delete group:', error)
    toast.error('Failed to delete group')
  }
}

const closeDetailsModal = () => {
  showDetailsModal.value = false
  selected.value = {}
}

const refreshData = async () => {
  await loadInterestGroups()
}

const exportData = () => {
  // TODO: Implement export functionality
  toast.info('Export functionality coming soon!')
}

// Initialize
onMounted(async () => {
  await loadInterestGroups()
})
</script>

<style scoped>
.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
}
</style>
