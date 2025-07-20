<template>
  <RoleBasedLayout>
    <div class="container-fluid">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3">Support Tickets</h1>
        <button class="btn btn-success"><i class="bi bi-plus-circle me-2"></i>New Ticket</button>
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
              <select v-model="filters.assignedTo" class="form-select" @change="updateFilters">
                <option value="">All Assignees</option>
                <option value="Jane Smith">Jane Smith</option>
                <option value="John Doe">John Doe</option>
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
  </RoleBasedLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import RoleBasedLayout from '@/components/common/RoleBasedLayout.vue'
import DataTable from '@/components/ui/DataTable.vue'
import { useTicketsStore } from '@/stores/tickets'

const ticketsStore = useTicketsStore()

const filters = ref({
  status: '',
  priority: '',
  assignedTo: '',
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

onMounted(() => {
  ticketsStore.fetchTickets()
})
</script>
