import { defineStore } from 'pinia'
import { ticketsAPI } from '@/services/api'

export const useTicketsStore = defineStore('tickets', {
  state: () => ({
    tickets: [],
    currentTicket: null,
    loading: false,
    error: null,
    filters: {
      status: '',
      priority: '',
      assignedTo: '',
    },
  }),

  getters: {
    openTickets: (state) => state.tickets.filter((t) => t.status === 'Open').length,
    inProgressTickets: (state) => state.tickets.filter((t) => t.status === 'In Progress').length,
    closedTickets: (state) => state.tickets.filter((t) => t.status === 'Closed').length,

    highPriorityTickets: (state) => state.tickets.filter((t) => t.priority === 'High').length,

    filteredTickets: (state) => {
      let result = state.tickets

      if (state.filters.status) {
        result = result.filter((t) => t.status === state.filters.status)
      }

      if (state.filters.priority) {
        result = result.filter((t) => t.priority === state.filters.priority)
      }

      if (state.filters.assignedTo) {
        result = result.filter((t) => t.assignedTo === state.filters.assignedTo)
      }

      return result
    },

    ticketStats: (state) => ({
      total: state.tickets.length,
      open: state.openTickets,
      inProgress: state.inProgressTickets,
      closed: state.closedTickets,
    }),
  },

  actions: {
    async fetchTickets() {
      this.loading = true
      this.error = null
      try {
        const tickets = await ticketsAPI.getAll(this.filters)
        this.tickets = tickets
      } catch (error) {
        this.error = error.response?.data?.message || error.message || 'Failed to fetch tickets'
        console.error('Failed to fetch tickets:', error)
      } finally {
        this.loading = false
      }
    },

    async fetchTicketById(id) {
      this.loading = true
      this.error = null
      try {
        const ticket = await ticketsAPI.getById(id)
        this.currentTicket = ticket
      } catch (error) {
        this.error = error.response?.data?.message || error.message || 'Failed to fetch ticket'
        console.error('Failed to fetch ticket:', error)
      } finally {
        this.loading = false
      }
    },

    async createTicket(ticketData) {
      try {
        const newTicket = await ticketsAPI.create(ticketData)
        this.tickets.unshift(newTicket)
        return { success: true, data: newTicket }
      } catch (error) {
        const errorMessage = error.response?.data?.message || error.message || 'Failed to create ticket'
        console.error('Failed to create ticket:', error)
        return { success: false, error: errorMessage }
      }
    },

    async updateTicketStatus(id, status) {
      try {
        await ticketsAPI.updateStatus(id, status)
        
        // Update local state
        const ticket = this.tickets.find((t) => t.id === id)
        if (ticket) {
          ticket.status = status
          // Update resolved_at if closing
          if (status === 'Closed') {
            ticket.resolved_at = new Date().toISOString()
          }
        }
        
        if (this.currentTicket?.id === id) {
          this.currentTicket.status = status
          if (status === 'Closed') {
            this.currentTicket.resolved_at = new Date().toISOString()
          }
        }
        
        return { success: true }
      } catch (error) {
        const errorMessage = error.response?.data?.message || error.message || 'Failed to update ticket status'
        console.error('Failed to update ticket status:', error)
        return { success: false, error: errorMessage }
      }
    },

    async assignTicket(id, assignedTo) {
      try {
        await ticketsAPI.assign(id, assignedTo)
        
        // Update local state
        const ticket = this.tickets.find((t) => t.id === id)
        if (ticket) {
          ticket.assignedTo = assignedTo
          ticket.assigned_to = assignedTo // Keep both for compatibility
        }
        
        if (this.currentTicket?.id === id) {
          this.currentTicket.assignedTo = assignedTo
          this.currentTicket.assigned_to = assignedTo
        }
        
        // Refresh to get updated assignee name
        await this.fetchTicketById(id)
        
        return { success: true }
      } catch (error) {
        const errorMessage = error.response?.data?.message || error.message || 'Failed to assign ticket'
        console.error('Failed to assign ticket:', error)
        return { success: false, error: errorMessage }
      }
    },

    updateFilters(filters) {
      this.filters = { ...this.filters, ...filters }
    },

    clearFilters() {
      this.filters = {
        status: '',
        priority: '',
        assignedTo: '',
      }
    },
  },
})