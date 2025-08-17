import { defineStore } from 'pinia'
import { notificationsAPI } from '@/services/notificationsService'

export const useNotificationsStore = defineStore('notifications', {
  state: () => ({
    notifications: [],
    loading: false,
    error: null,
    autoRefresh: true,
    refreshInterval: null,
  }),

  getters: {
    unreadNotifications: (state) => state.notifications.filter((n) => !n.is_read),
    unreadCount: (state) => state.notifications.filter((n) => !n.is_read).length,

    sortedNotifications: (state) => {
      return [...state.notifications].sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
    },

    recentNotifications: (state) => {
      return state.sortedNotifications.slice(0, 5)
    },

    notificationsByType: (state) => {
      const grouped = {}
      state.notifications.forEach((n) => {
        if (!grouped[n.type]) grouped[n.type] = []
        grouped[n.type].push(n)
      })
      return grouped
    },

    dynamicNotifications: (state) => {
      return state.notifications.filter((n) => n.source === 'dynamic')
    },

    staticNotifications: (state) => {
      return state.notifications.filter((n) => n.source === 'database')
    },
  },

  actions: {
    async fetchNotifications() {
      this.loading = true
      this.error = null
      try {
        const response = await notificationsAPI.getAll()
        this.notifications = response.map(notif => ({
          id: notif.id,
          title: this._generateTitle(notif),
          message: notif.body || notif.message || 'No message',
          type: notif.type || 'system',
          priority: notif.priority || 'medium',
          read: notif.is_read !== undefined ? notif.is_read : notif.read || false,
          timestamp: notif.created_at || notif.timestamp || new Date().toISOString(),
          source: notif.source || 'database'
        }))
      } catch (error) {
        this.error = error.message
        console.error('Failed to fetch notifications:', error)
      } finally {
        this.loading = false
      }
    },

    _generateTitle(notif) {
      switch (notif.type) {
        case 'care_request':
          return 'Caregiver Approval Required'
        case 'interest_group':
          return 'Interest Group Admin Approval'
        case 'task':
          return 'Task Notification'
        case 'relation':
          return 'Relationship Update'
        default:
          return 'System Notification'
      }
    },

    async markAsRead(id) {
      console.log('Mark as read disabled - notifications disappear when underlying task is completed')
    },

    async markAllAsRead() {
      console.log('Mark all as read disabled - notifications disappear when underlying tasks are completed')
    },

    addNotification(notification) {
      this.notifications.unshift({
        ...notification,
        id: Date.now(),
        timestamp: new Date().toISOString(),
        read: false,
      })
    },

    removeNotification(id) {
      this.notifications = this.notifications.filter((n) => n.id !== id)
    },

    startAutoRefresh() {
      if (this.refreshInterval) return

      this.refreshInterval = setInterval(() => {
        if (this.autoRefresh) {
          this.fetchNotifications()
        }
      }, 30000) // Refresh every 30 seconds
    },

    stopAutoRefresh() {
      if (this.refreshInterval) {
        clearInterval(this.refreshInterval)
        this.refreshInterval = null
      }
    },

    toggleAutoRefresh() {
      this.autoRefresh = !this.autoRefresh
    },
  },
})
