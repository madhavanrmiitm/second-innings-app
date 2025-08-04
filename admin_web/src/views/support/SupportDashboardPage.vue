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
            title="Total Tickets" 
            :value="ticketsStore.tickets.length" 
            icon="ticket" 
            color="primary" 
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard 
            title="Open Tickets" 
            :value="ticketsStore.openTickets" 
            icon="bell" 
            color="warning" 
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="In Progress"
            :value="ticketsStore.inProgressTickets"
            icon="clock"
            color="info"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard 
            title="Closed Tickets" 
            :value="ticketsStore.closedTickets" 
            icon="check-circle" 
            color="success" 
          />
        </div>
      </div>

      <!-- All Tickets -->
      <div class="row g-3">
        <div class="col-12">
          <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
              <h5 class="card-title mb-0">All Tickets</h5>
              <button class="btn btn-sm btn-primary" @click="refreshTickets">
                <i class="bi bi-arrow-clockwise me-2"></i>Refresh
              </button>
            </div>
            <div class="card-body">
              <DataTable
                :columns="columns"
                :data="ticketsStore.tickets"
                :loading="ticketsStore.loading"
                empty-message="No tickets found"
              >
                <template #cell-title="{ item }">
                  <div class="fw-medium">{{ item.title }}</div>
                  <small class="text-muted">{{ item.description }}</small>
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

                <template #cell-createdBy="{ item }">
                  {{ item.createdBy || 'Unknown' }}
                </template>

                <template #cell-assignedTo="{ item }">
                  {{ item.assignedTo || 'Unassigned' }}
                </template>

                <template #cell-actions="{ item }">
                  <div class="btn-group btn-group-sm">
                    <button
                      @click="updateStatus(item, 'In Progress')"
                      class="btn btn-outline-primary"
                      v-if="item.status === 'Open'"
                      :disabled="updatingStatus"
                    >
                      Start
                    </button>
                    <button
                      @click="updateStatus(item, 'Closed')"
                      class="btn btn-outline-success"
                      v-if="item.status === 'In Progress'"
                      :disabled="updatingStatus"
                    >
                      Resolve
                    </button>
                    <router-link 
                      :to="`/tickets/${item.id}`" 
                      class="btn btn-outline-info"
                    >
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
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import SupportLayout from '@/components/layouts/SupportLayout.vue'
import StatCard from '@/components/ui/StatCard.vue'
import DataTable from '@/components/ui/DataTable.vue'
import { useTicketsStore } from '@/stores/tickets'
import { useToast } from 'vue-toast-notification'

const router = useRouter()
const toast = useToast()
const ticketsStore = useTicketsStore()
const updatingStatus = ref(false)

const columns = [
  { key: 'id', label: 'Ticket ID' },
  { key: 'title', label: 'Issue' },
  { key: 'status', label: 'Status' },
  { key: 'priority', label: 'Priority' },
  { key: 'createdBy', label: 'Customer' },
  { key: 'assignedTo', label: 'Assigned To' },
  { key: 'actions', label: 'Actions', class: 'text-end' },
]

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

const updateStatus = async (ticket, newStatus) => {
  updatingStatus.value = true
  const result = await ticketsStore.updateTicketStatus(ticket.id, newStatus)
  
  if (result.success) {
    toast.success(`Ticket ${ticket.id} status updated to ${newStatus}`)
  } else {
    toast.error(result.error || 'Failed to update ticket status')
  }
  updatingStatus.value = false
}

const refreshTickets = async () => {
  await ticketsStore.fetchTickets()
  toast.success('Tickets refreshed')
}

onMounted(() => {
  ticketsStore.fetchTickets()
})
</script>