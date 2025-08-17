<template>
  <RoleBasedLayout>
    <div class="container-fluid">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3">Support Tickets</h1>
        <button @click="showCreateModal = true" class="btn btn-success">
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
                <option value="open">Open</option>
                <option value="in_progress">In Progress</option>
                <option value="closed">Closed</option>
              </select>
            </div>
            <div class="col-12 col-md-4">
              <select v-model="filters.priority" class="form-select" @change="updateFilters">
                <option value="">All Priority</option>
                <option value="low">Low</option>
                <option value="medium">Medium</option>
                <option value="high">High</option>
              </select>
            </div>
            <div class="col-12 col-md-4">
              <select v-model="filters.assigned_to" class="form-select" @change="updateFilters">
                <option value="">All Assignees</option>
                <option v-for="user in assignableUsers" :key="user.id" :value="user.id">
                  {{ user.name }}
                </option>
              </select>
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
            <template #cell-subject="{ item }">
              <router-link :to="`/tickets/${item.id}`" class="text-decoration-none fw-medium">
                {{ item.subject }}
              </router-link>
            </template>

            <template #cell-status="{ item }">
              <span :class="`badge bg-${getStatusColor(item.status)}`">
                {{ formatStatus(item.status) }}
              </span>
            </template>

            <template #cell-priority="{ item }">
              <span :class="`badge bg-${getPriorityColor(item.priority)}`">
                {{ formatPriority(item.priority) }}
              </span>
            </template>

            <template #cell-assignedToName="{ item }">
              {{ item.assignedToName || 'Unassigned' }}
            </template>

            <template #cell-createdAt="{ item }">
              {{ formatDate(item.createdAt) }}
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
    <div v-if="showCreateModal" class="modal d-block" tabindex="-1" style="background: rgba(0,0,0,0.5)">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Create New Ticket</h5>
            <button type="button" class="btn-close" @click="showCreateModal = false"></button>
          </div>
          <form @submit.prevent="createTicket">
            <div class="modal-body">
              <div class="mb-3">
                <label class="form-label">Subject</label>
                <input v-model="newTicket.subject" type="text" class="form-control" required>
              </div>
              <div class="mb-3">
                <label class="form-label">Description</label>
                <textarea v-model="newTicket.description" class="form-control" rows="4" required></textarea>
              </div>
              <div class="mb-3">
                <label class="form-label">Priority</label>
                <select v-model="newTicket.priority" class="form-select" required>
                  <option value="low">Low</option>
                  <option value="medium">Medium</option>
                  <option value="high">High</option>
                </select>
              </div>
              <div class="mb-3">
                <label class="form-label">Category</label>
                <input v-model="newTicket.category" type="text" class="form-control" placeholder="Optional">
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" @click="showCreateModal = false">Cancel</button>
              <button type="submit" class="btn btn-primary" :disabled="ticketsStore.loading">
                Create Ticket
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
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

const showCreateModal = ref(false)
const filters = ref({
  status: '',
  priority: '',
  assigned_to: '',
})

const newTicket = ref({
  subject: '',
  description: '',
  priority: 'medium',
  category: ''
})

const columns = [
  { key: 'id', label: 'ID' },
  { key: 'subject', label: 'Subject' },
  { key: 'category', label: 'Category' },
  { key: 'status', label: 'Status' },
  { key: 'priority', label: 'Priority' },
  { key: 'assignedToName', label: 'Assigned To' },
  { key: 'createdAt', label: 'Created' },
  { key: 'actions', label: 'Actions', class: 'text-end' },
]

const filteredTickets = computed(() => ticketsStore.filteredTickets)
const assignableUsers = computed(() => ticketsStore.assignableUsers)

// Format functions
const formatStatus = (status) => {
  const map = {
    'open': 'Open',
    'in_progress': 'In Progress',
    'closed': 'Closed'
  }
  return map[status] || status
}

const formatPriority = (priority) => {
  const map = {
    'low': 'Low',
    'medium': 'Medium',
    'high': 'High'
  }
  return map[priority] || priority
}

const getStatusColor = (status) => {
  const colors = {
    'open': 'warning',
    'in_progress': 'info',
    'closed': 'success'
  }
  return colors[status] || 'secondary'
}

const getPriorityColor = (priority) => {
  const colors = {
    'low': 'secondary',
    'medium': 'warning',
    'high': 'danger'
  }
  return colors[priority] || 'secondary'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  
  const date = new Date(dateString)
  if (isNaN(date.getTime())) return 'Invalid Date'
  
  const now = new Date()
  const isToday = date.toDateString() === now.toDateString()
  const isYesterday = new Date(now.getTime() - 86400000).toDateString() === date.toDateString()
  const isThisWeek = (now - date) < (7 * 24 * 60 * 60 * 1000)
  
  const timeString = date.toLocaleTimeString('en-US', { 
    hour: '2-digit', 
    minute: '2-digit' 
  })
  
  if (isToday) {
    return `Today, ${timeString}`
  } else if (isYesterday) {
    return `Yesterday, ${timeString}`
  } else if (isThisWeek) {
    return date.toLocaleDateString('en-US', { 
      weekday: 'short',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  } else {
    return date.toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: date.getFullYear() !== now.getFullYear() ? 'numeric' : undefined,
      hour: '2-digit',
      minute: '2-digit'
    })
  }
}

const updateFilters = () => {
  ticketsStore.updateFilters(filters.value)
}

const createTicket = async () => {
  const result = await ticketsStore.createTicket(newTicket.value)
  if (result.success) {
    toast.success('Ticket created successfully')
    showCreateModal.value = false
    // Reset form
    newTicket.value = {
      subject: '',
      description: '',
      priority: 'medium',
      category: ''
    }
  } else {
    toast.error(result.error || 'Failed to create ticket')
  }
}

onMounted(async () => {
  await ticketsStore.fetchTickets()
  await ticketsStore.fetchAssignableUsers()
})
</script>