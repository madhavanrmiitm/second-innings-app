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
            :loading="loading"
            empty-message="No pending approvals"
          >
            <template #cell-name="{ item }">
              <div>{{ item.name }}</div>
            </template>
            <template #cell-email="{ item }">
              <div>{{ item.email }}</div>
            </template>
            <template #cell-requestedDate="{ item }">
              <div>{{ item.requestedDate }}</div>
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
            <p><strong>Name:</strong> {{ selected.name }}</p>
            <p><strong>Email:</strong> {{ selected.email }}</p>
            <p><strong>Phone:</strong> {{ selected.phone }}</p>
            <p><strong>Address:</strong> {{ selected.address }}</p>
            <p><strong>Bio:</strong> {{ selected.bio }}</p>
            <p>
              <strong>YouTube:</strong>
              <a :href="selected.youtube" target="_blank">{{ selected.youtube }}</a>
            </p>
          </div>
          <div class="modal-footer">
            <button class="btn btn-danger" @click="reject()">Reject</button>
            <button class="btn btn-success" @click="approve()">Approve</button>
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
import { useToast } from 'vue-toast-notification'

const toast = useToast()
const loading = ref(false)
const showModal = ref(false)
const selected = ref({})

const columns = [
  { key: 'name', label: 'Name' },
  { key: 'email', label: 'Email' },
  { key: 'requestedDate', label: 'Requested Date' },
  { key: 'actions', label: 'Actions', class: 'text-end' },
]

// mock data
const caregivers = ref([
  {
    id: 1,
    name: 'Ramesh Kumar',
    email: 'ramesh.kumar@example.com',
    phone: '+91 98765 43211',
    address: 'Mumbai, Maharashtra',
    bio: 'Experienced caregiver with 5 years of senior care.',
    youtube: 'https://youtu.be/example1',
    requestedDate: '2024-06-20',
  },
  {
    id: 2,
    name: 'Meena Patel',
    email: 'meena.patel@example.com',
    phone: '+91 98765 43212',
    address: 'Delhi, Delhi',
    bio: 'Professional caregiver specializing in mobility assistance.',
    youtube: 'https://youtu.be/example2',
    requestedDate: '2024-06-25',
  },
])

const pendingCaregivers = computed(() => caregivers.value)

const viewDetails = (item) => {
  selected.value = item
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  selected.value = {}
}

const approve = () => {
  // implement API call here
  toast.success(`${selected.value.name} approved`)
  closeModal()
}

const reject = () => {
  // implement API call here
  toast.error(`${selected.value.name} rejected`)
  closeModal()
}

onMounted(() => {
  loading.value = true
  // fetch caregivers pending approvals
  setTimeout(() => {
    loading.value = false
  }, 500)
})
</script>
