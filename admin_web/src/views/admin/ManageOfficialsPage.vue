<template>
  <AppLayout>
    <div class="container-fluid">
      <!-- Header -->
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3">Manage Officials</h1>
        <button @click="showAddModal = true" class="btn btn-success">
          <i class="bi bi-plus-circle me-2"></i>Add Official
        </button>
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
              >
            </div>
            <div class="col-12 col-md-3">
              <select
                v-model="filters.status"
                class="form-select"
                @change="updateFilters"
              >
                <option value="">All Status</option>
                <option value="Active">Active</option>
                <option value="Inactive">Inactive</option>
              </select>
            </div>
            <div class="col-12 col-md-3">
              <select
                v-model="filters.department"
                class="form-select"
                @change="updateFilters"
              >
                <option value="">All Departments</option>
                <option value="Support">Support</option>
                <option value="Admin">Admin</option>
                <option value="IGA">IGA</option>
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

      <!---- Officials Table ---->
       
      <div class="card">
        <div class="card-body p-0">
          <DataTable
            :columns="columns"
            :data="filteredOfficials"
            :loading="officialsStore.loading"
            empty-message="No officials found"
          >
            <template #cell-official="{ item }">
              <div class="d-flex align-items-center">
                <img
                  :src="`https://ui-avatars.com/api/?name=${item.name}`"
                  :alt="item.name"
                  class="avatar me-3"
                >
                <div>
                  <div class="fw-medium">{{ item.name }}</div>
                  <small class="text-muted">{{ item.email }}</small>
                </div>
              </div>
            </template>
            
            <template #cell-status="{ item }">
              <span :class="`badge bg-${item.status === 'Active' ? 'success' : 'secondary'}`">
                {{ item.status }}
              </span>
            </template>
            
            <template #cell-actions="{ item }">
              <div class="btn-group btn-group-sm" role="group">
                <button 
                  @click="editOfficial(item)" 
                  class="btn btn-outline-primary"
                  title="Edit"
                >
                  <i class="bi bi-pencil"></i>
                </button>
                <button 
                  @click="confirmDelete(item)" 
                  class="btn btn-outline-danger"
                  title="Delete"
                >
                  <i class="bi bi-trash"></i>
                </button>
              </div>
            </template>
          </DataTable>
        </div>
      </div>
    </div>

    <!-- Add/Edit Modal -->
    <div 
      class="modal fade" 
      id="officialModal" 
      tabindex="-1"
      :class="{ show: showAddModal || showEditModal }"
      :style="{ display: showAddModal || showEditModal ? 'block' : 'none' }"
    >
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              {{ showEditModal ? 'Edit Official' : 'Add New Official' }}
            </h5>
            <button 
              type="button" 
              class="btn-close" 
              @click="closeModal"
            ></button>
          </div>
          <form @submit.prevent="saveOfficial">
            <div class="modal-body">
              <div class="mb-3">
                <label class="form-label">Name</label>
                <input
                  v-model="formData.name"
                  type="text"
                  class="form-control"
                  required
                >
              </div>
              <div class="mb-3">
                <label class="form-label">Email</label>
                <input
                  v-model="formData.email"
                  type="email"
                  class="form-control"
                  required
                >
              </div>
              <div class="mb-3">
                <label class="form-label">Department</label>
                <select
                  v-model="formData.department"
                  class="form-select"
                  required
                >
                  <option value="">Select Department</option>
                  <option value="Support">Support</option>
                  <option value="Admin">Admin</option>
                  <option value="IGA">IGA</option>
                </select>
              </div>
              <div class="mb-3">
                <label class="form-label">Role</label>
                <input
                  v-model="formData.role"
                  type="text"
                  class="form-control"
                  required
                >
              </div>
              <div class="mb-3">
                <label class="form-label">Status</label>
                <select
                  v-model="formData.status"
                  class="form-select"
                  required
                >
                  <option value="Active">Active</option>
                  <option value="Inactive">Inactive</option>
                </select>
              </div>
            </div>
            <div class="modal-footer">
              <button 
                type="button" 
                class="btn btn-secondary" 
                @click="closeModal"
              >
                Cancel
              </button>
              <button 
                type="submit" 
                class="btn btn-success"
                :disabled="saving"
              >
                <span v-if="saving" class="spinner-border spinner-border-sm me-2"></span>
                {{ showEditModal ? 'Update' : 'Add' }} Official
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div 
      v-if="showAddModal || showEditModal" 
      class="modal-backdrop fade show"
      @click="closeModal"
    ></div>
  </AppLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import AppLayout from '@/components/common/AppLayout.vue'
import DataTable from '@/components/ui/DataTable.vue'
import { useOfficialsStore } from '@/stores/officials'
import { useToast } from 'vue-toast-notification'

const officialsStore = useOfficialsStore()
const toast = useToast()

const showAddModal = ref(false)
const showEditModal = ref(false)
const saving = ref(false)
const editingId = ref(null)

const filters = ref({
  search: '',
  status: '',
  department: ''
})

const formData = ref({
  name: '',
  email: '',
  department: '',
  role: '',
  status: 'Active'
})

const columns = [
  { key: 'official', label: 'Official' },
  { key: 'department', label: 'Department' },
  { key: 'status', label: 'Status' },
  { key: 'joinedDate', label: 'Joined Date' },
  { key: 'actions', label: 'Actions', class: 'text-end' }
]

const filteredOfficials = computed(() => officialsStore.filteredOfficials)

const updateFilters = () => {
  officialsStore.updateFilters(filters.value)
}

const resetFilters = () => {
  filters.value = {
    search: '',
    status: '',
    department: ''
  }
  updateFilters()
}

const editOfficial = (official) => {
  editingId.value = official.id
  formData.value = { ...official }
  showEditModal.value = true
}

const closeModal = () => {
  showAddModal.value = false
  showEditModal.value = false
  editingId.value = null
  formData.value = {
    name: '',
    email: '',
    department: '',
    role: '',
    status: 'Active'
  }
}

const saveOfficial = async () => {
  saving.value = true
  
  try {
    let result
    if (showEditModal.value) {
      result = await officialsStore.updateOfficial(editingId.value, formData.value)
    } else {
      result = await officialsStore.addOfficial(formData.value)
    }
    
    if (result.success) {
      toast.success(`Official ${showEditModal.value ? 'updated' : 'added'} successfully!`)
      closeModal()
    } else {
      toast.error(result.error || 'Operation failed')
    }
  } catch (error) {
    toast.error('An error occurred')
  } finally {
    saving.value = false
  }
}

const confirmDelete = (official) => {
  if (confirm(`Are you sure you want to delete ${official.name}?`)) {
    deleteOfficial(official.id)
  }
}

const deleteOfficial = async (id) => {
  const result = await officialsStore.deleteOfficial(id)
  if (result.success) {
    toast.success('Official deleted successfully!')
  } else {
    toast.error(result.error || 'Delete failed')
  }
}

onMounted(() => {
  officialsStore.fetchOfficials()
})
</script>