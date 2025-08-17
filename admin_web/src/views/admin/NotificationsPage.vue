<template>
  <AppLayout>
    <div class="container-fluid">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3">Notifications</h1>
      </div>

      <div class="card">
        <div class="card-body p-0">
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Loading...</span>
            </div>
          </div>

          <div v-else-if="sortedNotifications.length === 0" class="text-center py-5 text-muted">
            <i class="bi bi-bell-slash fs-1 mb-3 d-block"></i>
            <p>No notifications yet</p>
          </div>

          <div v-else class="list-group list-group-flush">
            <div
              v-for="notification in sortedNotifications"
              :key="notification.id"
              class="list-group-item"
              :class="{ 'bg-light': !notification.read }"
            >
              <div class="d-flex align-items-start">
                <div
                  class="rounded-circle p-2 me-3"
                  :class="getNotificationIconClass(notification.type)"
                >
                  <i :class="getNotificationIcon(notification.type)"></i>
                </div>
                <div class="flex-grow-1">
                  <div class="d-flex justify-content-between align-items-start mb-1">
                    <h6 class="mb-0">{{ notification.title }}</h6>
                    <small class="text-muted">{{ formatTime(notification.timestamp) }}</small>
                  </div>
                  <p class="mb-0 text-muted">{{ notification.message }}</p>
                </div>
                <div v-if="!notification.read" class="ms-3">
                  <span class="badge bg-primary rounded-pill">New</span>
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
import { useRouter } from 'vue-router'
import AppLayout from '@/components/common/AppLayout.vue'
import { useNotificationsStore } from '@/stores/notifications'

const router = useRouter()
const notificationsStore = useNotificationsStore()

const loading = computed(() => notificationsStore.loading)
const sortedNotifications = computed(() => notificationsStore.sortedNotifications)
const unreadCount = computed(() => notificationsStore.unreadCount)

const getNotificationIcon = (type) => {
  const icons = {
    ticket: 'bi-ticket-perforated',
    user: 'bi-person',
    system: 'bi-gear',
    alert: 'bi-exclamation-triangle',
  }
  return icons[type] || 'bi-bell'
}

const getNotificationIconClass = (type) => {
  const classes = {
    ticket: 'bg-primary bg-opacity-10 text-primary',
    user: 'bg-success bg-opacity-10 text-success',
    system: 'bg-info bg-opacity-10 text-info',
    alert: 'bg-danger bg-opacity-10 text-danger',
  }
  return classes[type] || 'bg-secondary bg-opacity-10 text-secondary'
}

const formatTime = (timestamp) => {
  const date = new Date(timestamp)
  const now = new Date()
  const diff = now - date

  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)

  if (minutes < 60) return `${minutes}m ago`
  if (hours < 24) return `${hours}h ago`
  if (days < 7) return `${days}d ago`

  return date.toLocaleDateString()
}


onMounted(() => {
  notificationsStore.fetchNotifications()
})
</script>
