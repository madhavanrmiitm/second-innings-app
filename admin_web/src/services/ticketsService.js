import { ApiService } from '@/services/apiService'

export const ticketsAPI = {
  async getAll(params = '') {
    try {
      const endpoint = params ? `/api/tickets?${params}` : '/api/tickets'
      const response = await ApiService.get(endpoint)

      if (response.isSuccess && response.data?.data) {
        return response.data.data // { tickets: [...] }
      }

      throw new Error(response.error || 'Failed to fetch tickets')
    } catch (error) {
      console.error('Error fetching tickets:', error)
      throw error
    }
  },

  async getById(id) {
    try {
      const response = await ApiService.get(`/api/tickets/${id}`)

      if (response.isSuccess && response.data?.data) {
        return response.data.data // { ticket: {...} }
      }

      throw new Error(response.error || 'Failed to fetch ticket')
    } catch (error) {
      console.error('Error fetching ticket:', error)
      throw error
    }
  },

  async create(ticketData) {
    try {
      const response = await ApiService.post('/api/tickets', {
        body: ticketData
      })

      if (response.isSuccess && response.data?.data) {
        return response.data.data // { ticket_id: 123 }
      }

      throw new Error(response.error || 'Failed to create ticket')
    } catch (error) {
      console.error('Error creating ticket:', error)
      throw error
    }
  },

  // Update ticket
  async update(id, updateData) {
    try {
      const response = await ApiService.put(`/api/tickets/${id}`, {
        body: updateData
      })

      if (response.isSuccess) {
        return { success: true }
      }

      throw new Error(response.error || 'Failed to update ticket')
    } catch (error) {
      console.error('Error updating ticket:', error)
      throw error
    }
  },

  async updateStatus(id, status) {
    return this.update(id, { status })
  },

  async assign(id, userId) {
    return this.update(id, { assigned_to: userId })
  },

  async getAssignableUsers() {
    try {
      const response = await ApiService.get('/api/tickets/assignable-users')

      if (response.isSuccess && response.data?.data) {
        return response.data.data // { users: [...] }
      }

      throw new Error(response.error || 'Failed to fetch assignable users')
    } catch (error) {
      console.error('Error fetching assignable users:', error)
      throw error
    }
  }
}
