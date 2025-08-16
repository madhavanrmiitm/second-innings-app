import { ApiService } from './apiService'

export class NotificationsService {
  static get apiPrefix() {
    return '/api/notifications'
  }

  // Get all notifications
  static async getAll() {
    try {
      const response = await ApiService.get(this.apiPrefix)

      if (response.isSuccess && response.data?.data) {
        return response.data.data.notifications || []
      }

      throw new Error(response.error || 'Failed to fetch notifications')
    } catch (error) {
      console.error('Failed to fetch notifications:', error)
      throw error
    }
  }

  // Mark notification as read - DISABLED
  static async markAsRead(id) {
    // Mark as read functionality disabled - notifications auto-disappear when tasks completed
    console.log('Mark as read disabled - notifications disappear when underlying task is completed')
    return { id, read: false }
  }

  // Mark all notifications as read - DISABLED
  static async markAllAsRead() {
    // Mark all as read functionality disabled - notifications auto-disappear when tasks completed
    console.log('Mark all as read disabled - notifications disappear when underlying tasks are completed')
    return { success: true }
  }

  // Delete notification
  static async delete(id) {
    try {
      const response = await ApiService.delete(`${this.apiPrefix}/${id}`)

      if (response.isSuccess) {
        return { success: true, id }
      }

      throw new Error(response.error || 'Failed to delete notification')
    } catch (error) {
      console.error('Failed to delete notification:', error)
      throw error
    }
  }
}

export const notificationsAPI = {
  async getAll() {
    return NotificationsService.getAll()
  },

  async markAsRead(id) {
    return NotificationsService.markAsRead(id)
  },

  async markAllAsRead() {
    return NotificationsService.markAllAsRead()
  },

  async delete(id) {
    return NotificationsService.delete(id)
  }
}
