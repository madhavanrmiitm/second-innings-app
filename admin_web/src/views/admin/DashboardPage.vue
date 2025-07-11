<template>
  <AppLayout>
    <div class="container-fluid">
      <!-- Header -->
      <div class="mb-4">
        <h1 class="h3 mb-0">Dashboard</h1>
      </div>

      <!-- Stats Grid -->
      <div class="row g-3 mb-4">
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Total Officials"
            :value="officialsStore.totalOfficials"
            icon="users"
            color="primary"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Active Officials"
            :value="officialsStore.activeOfficials"
            icon="user-check"
            color="success"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Open Tickets"
            :value="ticketsStore.openTickets"
            icon="ticket"
            color="warning"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Notifications"
            :value="notificationsStore.unreadCount"
            icon="bell"
            color="danger"
          />
        </div>
      </div>

      <!-- Recent Activity -->
      <div class="row g-3">
        <!-- Recent Tickets -->
        <div class="col-12">
          <div class="card">
            <div class="card-header">
              <h5 class="card-title mb-0">Recent Tickets</h5>
            </div>
            <div class="card-body">
              <div v-if="recentTickets.length === 0" class="text-center text-muted py-3">
                No tickets found
              </div>
              <div v-else class="list-group list-group-flush">
                <div
                  v-for="ticket in recentTickets"
                  :key="ticket.id"
                  class="list-group-item d-flex justify-content-between align-items-center"
                >
                  <div>
                    <h6 class="mb-1">{{ ticket.title }}</h6>
                    <small class="text-muted">{{ ticket.createdBy }}</small>
                  </div>
                  <span :class="`badge bg-${getStatusColor(ticket.status)}`">
                    {{ ticket.status }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import AppLayout from '@/components/common/AppLayout.vue'
import StatCard from '@/components/ui/StatCard.vue'
import { useOfficialsStore } from '@/stores/officials'
import { useTicketsStore } from '@/stores/tickets'
import { useNotificationsStore } from '@/stores/notifications'

const officialsStore = useOfficialsStore()
const ticketsStore = useTicketsStore()
const notificationsStore = useNotificationsStore()

const recentTickets = computed(() => ticketsStore.tickets.slice(0, 5))

const getStatusColor = (status) => {
  const colors = {
    Open: 'warning',
    'In Progress': 'info',
    Closed: 'success',
  }
  return colors[status] || 'secondary'
}

onMounted(async () => {
  await Promise.all([
    officialsStore.fetchOfficials(),
    ticketsStore.fetchTickets(),
    notificationsStore.fetchNotifications(),
  ])
})
</script>
