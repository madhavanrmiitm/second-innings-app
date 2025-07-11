<template>
  <AppLayout>
    <div class="container-fluid">
      <!-- Header -->
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3">Manage Caregivers</h1>
        <div>
          <button @click="goToApprovals" class="btn btn-primary me-2">
            <i class="bi bi-person-check me-2"></i>Approve Caregivers
          </button>
          <button @click="showAddModal = true" class="btn btn-success">
            <i class="bi bi-plus-circle me-2"></i>Add Caregiver
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
                <option value="Medical Assistance">Medical Assistance</option>
                <option value="Mobility Support">Mobility Support</option>
                <option value="Daily Living">Daily Living</option>
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

      <!-- Caregivers Table -->
      <div class="card">
        <div class="card-body p-0">
          <DataTable
            :columns="columns"
            :data="filteredCaregivers"
            :loading="loading"
            empty-message="No caregivers found"
          >
            <template #cell-caregiver="{ item }">
              <div class="d-flex align-items-center">
                <img
                  :src="`https://ui-avatars.com/api/?name=${item.name}`"
                  :alt="item.name"
                  class="avatar me-3"
                />
                <div>
                  <div class="fw-medium">{{ item.name }}</div>
                  <small class="text-muted">{{ item.email }}</small>
                </div>
              </div>
            </template>
            <template #cell-specialization="{ item }">
              {{ item.specialization }}
            </template>
            <template #cell-status="{ item }">
              <span
                :class="`badge bg-${
                  item.status === 'Approved'
                    ? 'success'
                    : item.status === 'Rejected'
                      ? 'danger'
                      : 'warning'
                }`"
              >
                {{ item.status }}
              </span>
            </template>
            <template #cell-actions="{ item }">
              <div class="btn-group btn-group-sm" role="group">
                <button @click="editCaregiver(item)" class="btn btn-outline-primary" title="Edit">
                  <i class="bi bi-pencil"></i>
                </button>
                <button @click="viewDetails(item)" class="btn btn-outline-info" title="View">
                  <i class="bi bi-eye"></i>
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

    <!-- Add/Edit Modal -->
    <div
      class="modal fade"
      tabindex="-1"
      :class="{ show: showAddModal || showEditModal }"
      :style="{ display: showAddModal || showEditModal ? 'block' : 'none' }"
    >
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              {{ showEditModal ? 'Edit Caregiver' : 'Add New Caregiver' }}
            </h5>
            <button type="button" class="btn-close" @click="closeModal"></button>
          </div>
          <form @submit.prevent="saveCaregiver">
            <div class="modal-body">
              <div class="mb-3">
                <label class="form-label">Name</label>
                <input v-model="formData.name" type="text" class="form-control" required />
              </div>
              <div class="mb-3">
                <label class="form-label">Email</label>
                <input v-model="formData.email" type="email" class="form-control" required />
              </div>
              <div class="mb-3">
                <label class="form-label">Phone</label>
                <input v-model="formData.phone" type="text" class="form-control" required />
              </div>
              <div class="mb-3">
                <label class="form-label">Specialization</label>
                <select v-model="formData.specialization" class="form-select" required>
                  <option value="">Select Specialization</option>
                  <option value="Medical Assistance">Medical Assistance</option>
                  <option value="Mobility Support">Mobility Support</option>
                  <option value="Daily Living">Daily Living</option>
                </select>
              </div>
              <div class="mb-3">
                <label class="form-label">Status</label>
                <select v-model="formData.status" class="form-select" required>
                  <option value="Pending">Pending</option>
                  <option value="Approved">Approved</option>
                  <option value="Rejected">Rejected</option>
                </select>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" @click="closeModal">Cancel</button>
              <button type="submit" class="btn btn-success" :disabled="saving">
                <span v-if="saving" class="spinner-border spinner-border-sm me-2"></span>
                {{ showEditModal ? 'Update' : 'Add' }} Caregiver
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
import { useRouter } from 'vue-router'
import AppLayout from '@/components/common/AppLayout.vue'
import DataTable from '@/components/ui/DataTable.vue'
import { useToast } from 'vue-toast-notification'

const toast = useToast()
const router = useRouter()
const loading = ref(false)
const showAddModal = ref(false)
const showEditModal = ref(false)
const saving = ref(false)
const editingId = ref(null)

const filters = ref({ search: '', status: '', specialization: '' })
const formData = ref({ name: '', email: '', phone: '', specialization: '', status: 'Pending' })

const columns = [
  { key: 'caregiver', label: 'Caregiver' },
  { key: 'specialization', label: 'Specialization' },
  { key: 'status', label: 'Status' },
  { key: 'joinedDate', label: 'Joined Date' },
  { key: 'actions', label: 'Actions', class: 'text-end' },
]

// Mock data
const caregivers = ref([
  {
    id: 1,
    name: 'Ramesh Kumar',
    email: 'ramesh.kumar@example.com',
    phone: '+91 98765 43211',
    specialization: 'Medical Assistance',
    status: 'Approved',
    joinedDate: '2024-01-15',
  },
  {
    id: 2,
    name: 'Meena Patel',
    email: 'meena.patel@example.com',
    phone: '+91 98765 43212',
    specialization: 'Mobility Support',
    status: 'Pending',
    joinedDate: '2024-03-10',
  },
  {
    id: 3,
    name: 'Sunita Das',
    email: 'sunita.das@example.com',
    phone: '+91 98765 43213',
    specialization: 'Daily Living',
    status: 'Rejected',
    joinedDate: '2024-02-25',
  },
])

const filteredCaregivers = computed(() => {
  return caregivers.value.filter((c) => {
    const matchesSearch = [c.name, c.email].some((field) =>
      field.toLowerCase().includes(filters.value.search.toLowerCase()),
    )
    const matchesStatus = filters.value.status ? c.status === filters.value.status : true
    const matchesSpec = filters.value.specialization
      ? c.specialization === filters.value.specialization
      : true
    return matchesSearch && matchesStatus && matchesSpec
  })
})

const updateFilters = () => {}
const resetFilters = () => {
  filters.value = { search: '', status: '', specialization: '' }
}

const editCaregiver = (item) => {
  editingId.value = item.id
  formData.value = { ...item }
  showEditModal.value = true
}

const viewDetails = (item) => {
  toast.info(`Viewing details for ${item.name}`)
}

const confirmDelete = (item) => {
  if (confirm(`Delete ${item.name}?`)) {
    caregivers.value = caregivers.value.filter((c) => c.id !== item.id)
    toast.success('Caregiver deleted')
  }
}

const closeModal = () => {
  showAddModal.value = false
  showEditModal.value = false
  editingId.value = null
  formData.value = { name: '', email: '', phone: '', specialization: '', status: 'Pending' }
}

const saveCaregiver = () => {
  saving.value = true
  setTimeout(() => {
    if (showEditModal.value) {
      const idx = caregivers.value.findIndex((c) => c.id === editingId.value)
      caregivers.value[idx] = { id: editingId.value, ...formData.value }
      toast.success('Caregiver updated')
    } else {
      const newId = Math.max(...caregivers.value.map((c) => c.id)) + 1
      caregivers.value.push({
        id: newId,
        joinedDate: new Date().toISOString().split('T')[0],
        ...formData.value,
      })
      toast.success('Caregiver added')
    }
    closeModal()
    saving.value = false
  }, 500)
}

const goToApprovals = () => {
  router.push('/caregivers/approvals')
}

onMounted(() => {
  loading.value = false
})
</script>
