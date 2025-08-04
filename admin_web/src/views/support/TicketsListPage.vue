<template>
  <RoleBasedLayout>
    <div class="container-fluid">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3">Support Tickets</h1>
        <button class="btn btn-success" @click="showCreateModal = true">
          <i class="bi bi-plus-circle me-2"></i>New Ticket
        </button>
      </div>

      <!-- Filters -->
      <div class="card mb-4">
        <div class="card-body">
          <div class="row g-3">
            <div class="col-12 col-md-4">
              <select v-model="filters.status" class="form-select" @change="updateFilters">
                <option value="">All Status</option>
                <option value="Open">Open</option>
                <option value="In Progress">In Progress</option>
                <option value="Closed">Closed</option>
              </select>
            </div>
            <div class="col-12 col-md-4">
              <select v-model="filters.priority" class="form-select" @change="updateFilters">
                <option value="">All Priority</option>
                <option value="Low">Low</option>
                <option value="Medium">Medium</option>
                <option value="High">High</option>
              </select>
            </div>
            <div class="col-12 col-md-4">
              <button class="btn btn-outline-secondary" @click="clearFilters">
                Clear Filters
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Tickets Table -->
      <div class="card">
        <div class="card-body p-0">
          <DataTable
            :columns="columns"
            :data="filteredTickets"
            :loading="ticketsStore.loading"
            empty-message="No tickets found"
          >
            <template #cell-title="{ item }">
              <router-link :to="`/tickets/${item.id}`" class="text-decoration-none fw-medium">
                {{ item.title }}
              </router-link>
            </template>

            <template #cell-status="{ item }">
              <span :class="`badge bg-${getStatusColor(item.status)}`">
                {{ item.status }}
              </span>
            </template>

            <template #cell-priority="{ item }">
              <span :class="`badge bg-${getPriorityColor(item.priority)}`">
                {{ item.priority }}
              </span>
            </template>

            <template #cell-actions="{ item }">
              <router-link :to="`/tickets/${item.id}`" class="btn btn-sm btn-outline-primary">
                View
              </router-link>
            </template>
          </DataTable>
        </div>
      </div>
    </div>

    <!-- Create Ticket Modal -->
    <div 
      class="modal fade" 
      :class="{ show: showCreateModal }" 
      :style="{ display: showCreateModal ? 'block' : 'none' }"
      tabindex="-1"
    >
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Create New Ticket</h5>
            <button 
              type="button" 
              class="btn-close" 
              @click="closeCreateModal"
            ></button>
          </div>
          <form @submit.prevent="createTicket">
            <div class="modal-body">
              <div class="mb-3">
                <label class="form-label">Title <span class="text-danger">*</span></label>
                <input 
                  v-model="newTicket.title" 
                  type="text" 
                  class="form-control" 
                  required
                  placeholder="Brief description of the issue"
                >
              </div>
              
              <div class="mb-3">
                <label class="form-label">Description</label>
                <textarea 
                  v-model="newTicket.description" 
                  class="form-control" 
                  rows="3"
                  placeholder="Detailed description of the issue"
                ></textarea>
              </div>
              
              <div class="mb-3">
                <label class="form-label">Priority</label>
                <select v-model="newTicket.priority" class="form-select">
                  <option value="Low">Low</option>
                  <option value="Medium">Medium</option>
                  <option value="High">High</option>
                </select>
              </div>
              
              <div class="mb-3">
                <label class="form-label">Category</label>
                <input 
                  v-model="newTicket.category" 
                  type="text" 
                  class="form-control"
                  placeholder="e.g., Technical, Billing, General"
                >
              </div>
            </div>
            <div class="modal-footer">
              <button 
                type="button" 
                class="btn btn-secondary" 
                @click="closeCreateModal"
              >
                Cancel
              </button>
              <button 
                type="submit" 
                class="btn btn-primary"
                :disabled="creating"
              >
                {{ creating ? 'Creating...' : 'Create Ticket' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    
    <!-- Modal Backdrop -->
    <div 
      v-if="showCreateModal" 
      class="modal-backdrop fade show"
      @click="closeCreateModal"
    ></div>
  </RoleBasedLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import RoleBasedLayout from '@/components/common/RoleBasedLayout.vue'
import DataTable from '@/components/ui/DataTable.vue'
import { useTicketsStore } from '@/stores/tickets'
import { useToast } from 'vue-toast-notification'

const ticketsStore = useTicketsStore()
const toast = useToast()

const filters = ref({
  status: '',
  priority: '',
  assignedTo: '',
})

const showCreateModal = ref(false)
const creating = ref(false)
const newTicket = ref({
  title: '',
  description: '',
  priority: 'Medium',
  category: '',
})

const columns = [
  { key: 'id', label: 'ID' },
  { key: 'title', label: 'Title' },
  { key: 'category', label: 'Category' },
  { key: 'status', label: 'Status' },
  { key: 'priority', label: 'Priority' },
  { key: 'assignedTo', label: 'Assigned To' },
  { key: 'createdAt', label: 'Created' },
  { key: 'actions', label: 'Actions', class: 'text-end' },
]

const filteredTickets = computed(() => ticketsStore.filteredTickets)

const getStatusColor = (status) => {
  const colors = {
    Open: 'warning',
    'In Progress': 'info',
    Closed: 'success',
  }
  return colors[status] || 'secondary'
}

const getPriorityColor = (priority) => {
  const colors = {
    Low: 'secondary',
    Medium: 'warning',
    High: 'danger',
  }
  return colors[priority] || 'secondary'
}

const updateFilters = () => {
  ticketsStore.updateFilters(filters.value)
  ticketsStore.fetchTickets()
}

const clearFilters = () => {
  filters.value = {
    status: '',
    priority: '',
    assignedTo: '',
  }
  ticketsStore.clearFilters()
  ticketsStore.fetchTickets()
}

const closeCreateModal = () => {
  showCreateModal.value = false
  // Reset form
  newTicket.value = {
    title: '',
    description: '',
    priority: 'Medium',
    category: '',
  }
}

const createTicket = async () => {
  creating.value = true
  
  const result = await ticketsStore.createTicket(newTicket.value)
  
  if (result.success) {
    toast.success('Ticket created successfully')
    closeCreateModal()
  } else {
    toast.error(result.error || 'Failed to create ticket')
  }
  
  creating.value = false
}

onMounted(() => {
  ticketsStore.fetchTickets()
})
</script>