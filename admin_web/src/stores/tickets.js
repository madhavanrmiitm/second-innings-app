import { defineStore } from 'pinia'
import { ticketsAPI } from '@/services/ticketsService'

export const useTicketsStore = defineStore('tickets', {
  state: () => ({
    tickets: [],
    currentTicket: null,
    assignableUsers: [],
    loading: false,
    error: null,
    filters: {
      status: '',
      priority: '',
      assigned_to: '', // backend field
    },
    stats: {
      total: 0,
      open: 0,
      inProgress: 0,
      closed: 0,
      unassigned: 0,
      myTickets: 0,
      urgent: 0,
    },
  }),

  getters: {
    unassignedTickets: (state) =>
      state.tickets.filter(t => !t.assignedTo && t.status === 'open'),

    myTickets: (state) => {
      const currentUserId = localStorage.getItem('userId')
      if (!currentUserId) return []
      return state.tickets.filter(t => t.assignedTo === parseInt(currentUserId))
    },

    urgentTickets: (state) =>
      state.tickets.filter(t => t.priority === 'high' && t.status !== 'closed'),

    filteredTickets: (state) => {
      let result = [...state.tickets]

      if (state.filters.status) {
        result = result.filter(t => t.status === state.filters.status)
      }

      if (state.filters.priority) {
        result = result.filter(t => t.priority === state.filters.priority)
      }

      if (state.filters.assigned_to) {
        result = result.filter(t => t.assignedTo === parseInt(state.filters.assigned_to))
      }

      return result
    },
  },

  actions: {
    async fetchTickets() {
      this.loading = true
      this.error = null

      try {
        const params = new URLSearchParams()
        if (this.filters.status) params.append('status', this.filters.status)
        if (this.filters.priority) params.append('priority', this.filters.priority)
        if (this.filters.assigned_to) params.append('assigned_to', this.filters.assigned_to)

        const response = await ticketsAPI.getAll(params.toString())

        this.tickets = response.tickets.map(ticket => ({
          id: ticket.id,
          userId: ticket.user_id,
          assignedTo: ticket.assigned_to,
          assignedToName: ticket.assigned_to_name || 'Unassigned',
          subject: ticket.subject,
          description: ticket.description,
          priority: ticket.priority,
          category: ticket.category || 'General',
          status: ticket.status,
          createdBy: ticket.created_by_name,
          createdAt: ticket.created_at,
          updatedAt: ticket.updated_at,
          resolvedAt: ticket.resolved_at,
        }))

        this.updateStats()
      } catch (error) {
        this.error = error.message || 'Failed to fetch tickets'
        console.error('Failed to fetch tickets:', error)
      } finally {
        this.loading = false
      }
    },

    async fetchTicketById(id) {
      this.loading = true
      this.error = null

      try {
        const response = await ticketsAPI.getById(id)

        this.currentTicket = {
          id: response.ticket.id,
          userId: response.ticket.user_id,
          assignedTo: response.ticket.assigned_to,
          assignedToName: response.ticket.assigned_to_name || 'Unassigned',
          subject: response.ticket.subject,
          description: response.ticket.description,
          priority: response.ticket.priority,
          category: response.ticket.category || 'General',
          status: response.ticket.status,
          createdBy: response.ticket.created_by_name,
          createdAt: response.ticket.created_at,
          updatedAt: response.ticket.updated_at,
          resolvedAt: response.ticket.resolved_at,
        }

      } catch (error) {
        this.error = error.message || 'Failed to fetch ticket'
        console.error('Failed to fetch ticket:', error)
      } finally {
        this.loading = false
      }
    },

    async createTicket(ticketData) {
      try {
        const response = await ticketsAPI.create({
          subject: ticketData.subject,
          description: ticketData.description,
          priority: ticketData.priority || 'medium',
          category: ticketData.category || 'General',
        })

        await this.fetchTickets()

        return { success: true, ticketId: response.ticket_id }
      } catch (error) {
        console.error('Failed to create ticket:', error)
        return { success: false, error: error.message }
      }
    },

    async updateTicket(id, updates) {
      try {
        const payload = {}
        if (updates.status) payload.status = updates.status
        if (updates.priority) payload.priority = updates.priority
        if (updates.assigned_to !== undefined) payload.assigned_to = updates.assigned_to
        if (updates.subject) payload.subject = updates.subject
        if (updates.description) payload.description = updates.description
        if (updates.category) payload.category = updates.category

        await ticketsAPI.update(id, payload)

        const index = this.tickets.findIndex(t => t.id === id)
        if (index !== -1) {
          this.tickets[index] = { ...this.tickets[index], ...updates }
        }

        if (this.currentTicket?.id === id) {
          this.currentTicket = { ...this.currentTicket, ...updates }
        }

        this.updateStats()

        return { success: true }
      } catch (error) {
        console.error('Failed to update ticket:', error)
        return { success: false, error: error.message }
      }
    },

    async assignTicket(ticketId, userId) {
      return this.updateTicket(ticketId, { assigned_to: userId })
    },

    async updateTicketStatus(ticketId, status) {
      return this.updateTicket(ticketId, { status })
    },

    async fetchAssignableUsers() {
      try {
        const response = await ticketsAPI.getAssignableUsers()
        this.assignableUsers = response.users || []
      } catch (error) {
        console.error('Failed to fetch assignable users:', error)
        this.assignableUsers = []
      }
    },

    async updateFilters(filters) {
      this.filters = { ...this.filters, ...filters }
      await this.fetchTickets()
    },

    clearFilters() {
      this.filters = {
        status: '',
        priority: '',
        assigned_to: '',
      }
      this.fetchTickets()
    },

    updateStats() {
      const currentUserId = localStorage.getItem('userId')
      const userIdInt = currentUserId ? parseInt(currentUserId) : null

      this.stats = {
        total: this.tickets.length,
        open: this.tickets.filter(t => t.status === 'open').length,
        inProgress: this.tickets.filter(t => t.status === 'in_progress').length,
        closed: this.tickets.filter(t => t.status === 'closed').length,
        unassigned: this.tickets.filter(t => !t.assignedTo).length,
        myTickets: userIdInt ? this.tickets.filter(t => t.assignedTo === userIdInt).length : 0,
        urgent: this.tickets.filter(t => t.priority === 'high' && t.status !== 'closed').length,
      }
    },

    async startTicket(ticketId) {
      const currentUserId = localStorage.getItem('userId')
      if (!currentUserId) {
        return { success: false, error: 'No user session' }
      }

      const ticket = this.tickets.find(t => t.id === ticketId)

      if (!ticket.assignedTo) {
        await this.assignTicket(ticketId, parseInt(currentUserId))
      }

      return this.updateTicketStatus(ticketId, 'in_progress')
    },

    async resolveTicket(ticketId) {
      return this.updateTicketStatus(ticketId, 'closed')
    },
  },
})
