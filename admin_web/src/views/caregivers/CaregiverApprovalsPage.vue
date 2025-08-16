<template>
  <AppLayout>
    <div class="container-fluid">
      <!-- Header -->
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3">Approve Caregivers</h1>
      </div>

      <!-- Caregivers Table -->
      <div class="card">
        <div class="card-body p-0">
          <DataTable
            :columns="columns"
            :data="pendingCaregivers"
            :loading="adminStore.loading.caregivers"
            empty-message="No pending approvals"
          >
            <template #cell-name="{ item }">
              <div>{{ item.full_name }}</div>
            </template>
            <template #cell-email="{ item }">
              <div>{{ item.gmail_id }}</div>
            </template>
            <template #cell-created_at="{ item }">
              <div>{{ formatDate(item.created_at) }}</div>
            </template>
            <template #cell-actions="{ item }">
              <button class="btn btn-sm btn-primary" @click="viewDetails(item)">View</button>
            </template>
          </DataTable>
        </div>
      </div>
    </div>

    <!-- Details Modal -->
    <div
      class="modal fade"
      tabindex="-1"
      :class="{ show: showModal }"
      :style="{ display: showModal ? 'block' : 'none' }"
    >
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Caregiver Details</h5>
            <button type="button" class="btn-close" @click="closeModal"></button>
          </div>
          <div class="modal-body">
            <p><strong>Name:</strong> {{ selected.full_name }}</p>
            <p><strong>Email:</strong> {{ selected.gmail_id }}</p>
            <p><strong>Description:</strong> {{ selected.description }}</p>
            <p><strong>Tags:</strong> {{ selected.tags }}</p>
            <p>
              <strong>YouTube URL:</strong>
              <a :href="selected.youtube_url" target="_blank">{{ selected.youtube_url }}</a>
            </p>
            <p><strong>Created:</strong> {{ formatDate(selected.created_at) }}</p>
          </div>
          <div class="modal-footer">
            <button
              class="btn btn-danger"
              @click="reject()"
              :disabled="adminStore.loading.verifyCaregiver"
            >
              Reject
            </button>
            <button
              class="btn btn-success"
              @click="approve()"
              :disabled="adminStore.loading.verifyCaregiver"
            >
              <span v-if="adminStore.loading.verifyCaregiver" class="spinner-border spinner-border-sm me-2"></span>
              Approve
            </button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="showModal" class="modal-backdrop fade show" @click="closeModal"></div>
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
const showModal = ref(false)
const selected = ref({})

const columns = [
  { key: 'name', label: 'Name' },
  { key: 'email', label: 'Email' },
  { key: 'created_at', label: 'Created Date' },
  { key: 'actions', label: 'Actions', class: 'text-end' },
]

const pendingCaregivers = computed(() => adminStore.pendingCaregivers)

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString()
}

const viewDetails = (item) => {
  selected.value = item
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  selected.value = {}
}

const approve = async () => {
  const result = await adminStore.verifyCaregiver(selected.value.id, 'active')
  if (result.success) {
    toast.success(`${selected.value.full_name} approved successfully`)
    closeModal()
    // Refresh the caregivers list
    adminStore.fetchCaregivers()
  } else {
    toast.error(result.error || 'Failed to approve caregiver')
  }
}

const reject = async () => {
  const result = await adminStore.verifyCaregiver(selected.value.id, 'blocked')
  if (result.success) {
    toast.success(`${selected.value.full_name} rejected`)
    closeModal()
    // Refresh the caregivers list
    adminStore.fetchCaregivers()
  } else {
    toast.error(result.error || 'Failed to reject caregiver')
  }
}

onMounted(async () => {
  // Load caregivers data - authentication will be handled by API calls
  try {
    await adminStore.fetchCaregivers()
  } catch (error) {
    console.error('Failed to fetch caregivers:', error)
    toast.error('Failed to load caregivers')
  }
})
</script>
