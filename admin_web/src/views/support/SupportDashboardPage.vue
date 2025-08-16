<template>
  <SupportLayout>
    <div class="container-fluid">
      <!-- Header -->
      <div class="mb-4">
        <h1 class="h3 mb-0">Support Dashboard</h1>
        <p class="text-muted">Manage and resolve customer tickets</p>
      </div>

      <!-- Stats Grid -->
      <div class="row g-3 mb-4">
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard 
            title="My Tickets" 
            :value="ticketsStore.stats.myTickets" 
            icon="ticket" 
            color="primary" 
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard 
            title="Open Tickets" 
            :value="ticketsStore.stats.open" 
            icon="bell" 
            color="warning" 
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Unassigned"
            :value="ticketsStore.stats.unassigned"
            icon="exclamation-circle"
            color="danger"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard 
            title="Total Tickets" 
            :value="ticketsStore.stats.total" 
            icon="layers" 
            color="info" 
          />
        </div>
      </div>

      <!-- My Tickets Table -->
      <div class="row g-3">
        <div class="col-12">
          <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
              <h5 class="card-title mb-0">My Assigned Tickets</h5>
              <button @click="fetchTickets" class="btn btn-sm btn-outline-secondary">
                <i class="bi bi-arrow-clockwise"></i> Refresh
              </button>
            </div>
            <div class="card-body">
              <DataTable
                :columns="columns"
                :data="myTickets"
                :loading="ticketsStore.loading"
                empty-message="No tickets assigned to you"
              >
                <template #cell-subject="{ item }">
                  <router-link :to="`/tickets/${item.id}`" class="text-decoration-none">
                    <div class="fw-medium">{{ item.subject }}</div>
                    <small class="text-muted">{{ item.description?.substring(0, 50) }}...</small>
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

                <template #cell-actions="{ item }">
                  <div class="btn-group btn-group-sm">
                    <button
                      @click="startTicket(item)"
                      class="btn btn-outline-primary"
                      v-if="item.status === 'open'"
                      :disabled="ticketsStore.loading"
                    >
                      Start
                    </button>
                    <button
                      @click="resolveTicket(item)"
                      class="btn btn-outline-success"
                      v-if="item.status === 'in_progress'"
                      :disabled="ticketsStore.loading"
                    >
                      Resolve
                    </button>
                    <router-link :to="`/tickets/${item.id}`" class="btn btn-outline-info">
                      View
                    </router-link>
                  </div>
                </template>
              </DataTable>
            </div>
          </div>
        </div>
      </div>
    </div>
  </SupportLayout>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import SupportLayout from '@/components/layouts/SupportLayout.vue'
import StatCard from '@/components/ui/StatCard.vue'
import DataTable from '@/components/ui/DataTable.vue'
import { useTicketsStore } from '@/stores/tickets'
import { useToast } from 'vue-toast-notification'

const router = useRouter()
const ticketsStore = useTicketsStore()
const toast = useToast()

// Get my tickets from store
const myTickets = computed(() => ticketsStore.myTickets)

const columns = [
  { key: 'id', label: 'ID' },
  { key: 'subject', label: 'Subject' },
  { key: 'status', label: 'Status' },
  { key: 'priority', label: 'Priority' },
  { key: 'createdBy', label: 'Created By' },
  { key: 'createdAt', label: 'Created' },
  { key: 'actions', label: 'Actions', class: 'text-end' },
]

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

// Color functions
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

// Actions
const startTicket = async (ticket) => {
  const result = await ticketsStore.startTicket(ticket.id)
  if (result.success) {
    toast.success('Ticket started')
  } else {
    toast.error(result.error || 'Failed to start ticket')
  }
}

const resolveTicket = async (ticket) => {
  const result = await ticketsStore.resolveTicket(ticket.id)
  if (result.success) {
    toast.success('Ticket resolved')
  } else {
    toast.error(result.error || 'Failed to resolve ticket')
  }
}

const fetchTickets = () => {
  ticketsStore.fetchTickets()
}

onMounted(() => {
  fetchTickets()
})
</script>