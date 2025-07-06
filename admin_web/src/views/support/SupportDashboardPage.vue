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
            :value="myTickets.length"
            icon="ticket"
            color="primary"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Open Tickets"
            :value="openTicketsCount"
            icon="bell"
            color="warning"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Resolved Today"
            :value="resolvedTodayCount"
            icon="user-check"
            color="success"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Avg Response Time"
            value="2.5h"
            icon="users"
            color="info"
          />
        </div>
      </div>

      <!-- My Tickets -->
      <div class="row g-3">
        <div class="col-12">
          <div class="card">
            <div class="card-header">
              <h5 class="card-title mb-0">My Assigned Tickets</h5>
            </div>
            <div class="card-body">
              <DataTable
                :columns="columns"
                :data="myTickets"
                :loading="loading"
                empty-message="No tickets assigned"
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
                
                <template #cell-actions="{ item }">
                  <div class="btn-group btn-group-sm">
                    <button 
                      @click="updateStatus(item, 'In Progress')"
                      class="btn btn-outline-primary"
                      v-if="item.status === 'Open'"
                    >
                      Start
                    </button>
                    <button 
                      @click="updateStatus(item, 'Closed')"
                      class="btn btn-outline-success"
                      v-if="item.status === 'In Progress'"
                    >
                      Resolve
                    </button>
                    <button 
                      @click="viewTicket(item)"
                      class="btn btn-outline-info"
                    >
                      View
                    </button>
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
import { ref, computed } from 'vue'
import SupportLayout from '@/components/layouts/SupportLayout.vue'
import StatCard from '@/components/ui/StatCard.vue'
import DataTable from '@/components/ui/DataTable.vue'
import { useToast } from 'vue-toast-notification'

const toast = useToast()
const loading = ref(false)

// Hardcoded ticket data assigned to current support user
const myTickets = ref([
  {
    id: 'TICK-001',
    title: 'Login Issue',
    description: 'User cannot access their account',
    status: 'Open',
    priority: 'High',
    createdBy: 'Ramesh Kumar',
    createdAt: '2024-07-06T08:30:00Z'
  },
  {
    id: 'TICK-003',
    title: 'Password Reset',
    description: 'Forgot password functionality not working',
    status: 'In Progress',
    priority: 'Medium',
    createdBy: 'Meena Patel',
    createdAt: '2024-07-06T10:15:00Z'
  },
  {
    id: 'TICK-005',
    title: 'Profile Update Error',
    description: 'Cannot update profile information',
    status: 'Open',
    priority: 'Low',
    createdBy: 'Sunita Das',
    createdAt: '2024-07-06T11:45:00Z'
  },
  {
    id: 'TICK-007',
    title: 'Notification Issues',
    description: 'Not receiving email notifications',
    status: 'Closed',
    priority: 'Medium',
    createdBy: 'Priya Sharma',
    createdAt: '2024-07-05T14:20:00Z'
  }
])

const columns = [
  { key: 'id', label: 'Ticket ID' },
  { key: 'title', label: 'Issue' },
  { key: 'status', label: 'Status' },
  { key: 'priority', label: 'Priority' },
  { key: 'createdBy', label: 'Customer' },
  { key: 'actions', label: 'Actions', class: 'text-end' }
]

const openTicketsCount = computed(() => 
  myTickets.value.filter(t => t.status === 'Open').length
)

const resolvedTodayCount = computed(() => 
  myTickets.value.filter(t => t.status === 'Closed' && 
    new Date(t.createdAt).toDateString() === new Date().toDateString()
  ).length
)

const getStatusColor = (status) => {
  const colors = {
    'Open': 'warning',
    'In Progress': 'info',
    'Closed': 'success'
  }
  return colors[status] || 'secondary'
}

const getPriorityColor = (priority) => {
  const colors = {
    'Low': 'secondary',
    'Medium': 'warning',
    'High': 'danger'
  }
  return colors[priority] || 'secondary'
}

const updateStatus = (ticket, newStatus) => {
  ticket.status = newStatus
  toast.success(`Ticket ${ticket.id} status updated to ${newStatus}`)
}

const viewTicket = (ticket) => {
  toast.info(`Viewing details for ticket ${ticket.id}`)
}
</script>