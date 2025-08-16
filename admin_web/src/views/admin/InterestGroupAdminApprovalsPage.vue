<template>
  <AppLayout>
    <div class="container-fluid">
      <!-- Header -->
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3">Approve Interest Group Admins</h1>
      </div>

      <!-- Interest Group Admins Table -->
      <div class="card">
        <div class="card-body p-0">
          <DataTable
            :columns="columns"
            :data="pendingInterestGroupAdmins"
            :loading="adminStore.loading.interestGroupAdmins"
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
            <h5 class="modal-title">Interest Group Admin Details</h5>
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
              :disabled="adminStore.loading.verifyInterestGroupAdmin"
            >
              Reject
            </button>
            <button
              class="btn btn-success"
              @click="approve()"
              :disabled="adminStore.loading.verifyInterestGroupAdmin"
            >
              <span v-if="adminStore.loading.verifyInterestGroupAdmin" class="spinner-border spinner-border-sm me-2"></span>
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

const pendingInterestGroupAdmins = computed(() => adminStore.pendingInterestGroupAdmins)

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
  const result = await adminStore.verifyInterestGroupAdmin(selected.value.id, 'active')
  if (result.success) {
    toast.success(`${selected.value.full_name} approved successfully`)
    closeModal()
    // Refresh the interest group admins list
    adminStore.fetchInterestGroupAdmins()
  } else {
    toast.error(result.error || 'Failed to approve interest group admin')
  }
}

const reject = async () => {
  const result = await adminStore.verifyInterestGroupAdmin(selected.value.id, 'blocked')
  if (result.success) {
    toast.success(`${selected.value.full_name} rejected`)
    closeModal()
    // Refresh the interest group admins list
    adminStore.fetchInterestGroupAdmins()
  } else {
    toast.error(result.error || 'Failed to reject interest group admin')
  }
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
