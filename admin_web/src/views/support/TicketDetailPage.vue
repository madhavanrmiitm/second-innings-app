<template>
  <RoleBasedLayout>
    <div class="container-fluid" v-if="currentTicket">
      <!-- Header -->
      <div class="d-flex justify-content-between align-items-start mb-4">
        <div>
          <div class="d-flex align-items-center gap-2 mb-2">
            <router-link to="/tickets" class="text-decoration-none">
              <i class="bi bi-arrow-left"></i> Back to Tickets
            </router-link>
          </div>
          <h1 class="h3 mb-0">{{ currentTicket.subject }}</h1>
          <div class="text-muted">Ticket #{{ currentTicket.id }}</div>
        </div>
      </div>

      <div class="row">
        <!-- Main Content -->
        <div class="col-12 col-lg-8">
          <!-- Ticket Info -->
          <div class="card mb-4">
            <div class="card-body">
              <h5 class="card-title">Description</h5>
              <p class="card-text">{{ currentTicket.description }}</p>

              <hr />

              <div class="row">
                <div class="col-6">
                  <small class="text-muted">Created by</small>
                  <p class="mb-0">{{ currentTicket.createdBy }}</p>
                </div>
                <div class="col-6">
                  <small class="text-muted">Created at</small>
                  <p class="mb-0">{{ formatDate(currentTicket.createdAt) }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Sidebar -->
        <div class="col-12 col-lg-4">
          <!-- Status Card -->
          <div class="card mb-4">
            <div class="card-header">
              <h6 class="mb-0">Ticket Details</h6>
            </div>
            <div class="card-body">
              <div class="mb-3">
                <label class="form-label small text-muted">Status</label>
                <select 
                  v-model="localStatus" 
                  class="form-select" 
                  @change="updateStatus"
                  :disabled="ticketsStore.loading"
                >
                  <option value="open">Open</option>
                  <option value="in_progress">In Progress</option>
                  <option value="closed">Closed</option>
                </select>
              </div>

              <div class="mb-3">
                <label class="form-label small text-muted">Priority</label>
                <select 
                  v-model="localPriority" 
                  class="form-select" 
                  @change="updatePriority"
                  :disabled="ticketsStore.loading"
                >
                  <option value="low">Low</option>
                  <option value="medium">Medium</option>
                  <option value="high">High</option>
                </select>
              </div>

              <div class="mb-3">
                <label class="form-label small text-muted">Category</label>
                <p class="mb-0">{{ currentTicket.category || 'Not specified' }}</p>
              </div>

              <div class="mb-3">
                <label class="form-label small text-muted">Assigned To</label>
                <select 
                  v-model="localAssignedTo" 
                  class="form-select" 
                  @change="updateAssignment"
                  :disabled="ticketsStore.loading"
                >
                  <option :value="null">Unassigned</option>
                  <!-- Show current assigned user even if not in assignableUsers list yet -->
                  <option 
                    v-if="currentTicket.assignedTo && currentTicket.assignedToName && !assignableUsers.find(u => u.id === currentTicket.assignedTo)"
                    :value="currentTicket.assignedTo"
                  >
                    {{ currentTicket.assignedToName }}
                  </option>
                  <option v-for="user in assignableUsers" :key="user.id" :value="user.id">
                    {{ user.name }}
                  </option>
                </select>
              </div>

              <div v-if="currentTicket.resolvedAt">
                <label class="form-label small text-muted">Resolved At</label>
                <p class="mb-0">{{ formatDate(currentTicket.resolvedAt) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-else-if="loading" class="text-center py-5">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>
    </div>
  </RoleBasedLayout>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import RoleBasedLayout from '@/components/common/RoleBasedLayout.vue'
import { useTicketsStore } from '@/stores/tickets'
import { useToast } from 'vue-toast-notification'

const route = useRoute()
const ticketsStore = useTicketsStore()
const toast = useToast()

const loading = computed(() => ticketsStore.loading)
const currentTicket = computed(() => ticketsStore.currentTicket)
const assignableUsers = computed(() => ticketsStore.assignableUsers)

// Local state for selects
const localStatus = ref('')
const localPriority = ref('')
const localAssignedTo = ref(null)

// Watch for ticket changes to update local state
watch(currentTicket, (ticket) => {
  if (ticket) {
    localStatus.value = ticket.status
    localPriority.value = ticket.priority
    localAssignedTo.value = ticket.assignedTo
  }
})

const formatDate = (date) => {
  if (!date) return 'N/A'
  return new Date(date).toLocaleString()
}

const updateStatus = async () => {
  const result = await ticketsStore.updateTicketStatus(currentTicket.value.id, localStatus.value)
  if (result.success) {
    toast.success('Status updated')
  } else {
    toast.error('Failed to update status')
    // Revert on failure
    localStatus.value = currentTicket.value.status
  }
}

const updatePriority = async () => {
  const result = await ticketsStore.updateTicket(currentTicket.value.id, { 
    priority: localPriority.value 
  })
  if (result.success) {
    toast.success('Priority updated')
  } else {
    toast.error('Failed to update priority')
    // Revert on failure
    localPriority.value = currentTicket.value.priority
  }
}

const updateAssignment = async () => {
  const result = await ticketsStore.assignTicket(currentTicket.value.id, localAssignedTo.value)
  if (result.success) {
    toast.success('Assignment updated')
  } else {
    toast.error('Failed to update assignment')
    // Revert on failure
    localAssignedTo.value = currentTicket.value.assignedTo
  }
}

onMounted(async () => {
  const ticketId = route.params.id
  await ticketsStore.fetchTicketById(ticketId)
  await ticketsStore.fetchAssignableUsers()
})
</script>