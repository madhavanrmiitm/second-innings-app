import { defineStore } from 'pinia'
import { notificationsAPI } from '@/services/api'

export const useNotificationsStore = defineStore('notifications', {
  state: () => ({
    notifications: [],
    loading: false,
    error: null,
    autoRefresh: true,
    refreshInterval: null,
  }),

  getters: {
    unreadNotifications: (state) => state.notifications.filter((n) => !n.read),
    unreadCount: (state) => state.notifications.filter((n) => !n.read).length,

    sortedNotifications: (state) => {
      return [...state.notifications].sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
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
  },

  actions: {
    async fetchNotifications() {
      this.loading = true
      this.error = null
      try {
        this.notifications = await notificationsAPI.getAll()
      } catch (error) {
        this.error = error.message
        console.error('Failed to fetch notifications:', error)
      } finally {
        this.loading = false
      }
    },

    async markAsRead(id) {
      try {
        await notificationsAPI.markAsRead(id)
        const notification = this.notifications.find((n) => n.id === id)
        if (notification) {
          notification.read = true
        }
      } catch (error) {
        console.error('Failed to mark notification as read:', error)
      }
    },

    async markAllAsRead() {
      try {
        const unreadIds = this.unreadNotifications.map((n) => n.id)
        await Promise.all(unreadIds.map((id) => notificationsAPI.markAsRead(id)))
        this.notifications.forEach((n) => {
          if (!n.read) n.read = true
        })
      } catch (error) {
        console.error('Failed to mark all as read:', error)
      }
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
