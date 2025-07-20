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
        this.tickets = await ticketsAPI.getAll(this.filters)
      } catch (error) {
        this.error = error.message
        console.error('Failed to fetch tickets:', error)
      } finally {
        this.loading = false
      }
    },

    async fetchTicketById(id) {
      this.loading = true
      this.error = null
      try {
        this.currentTicket = await ticketsAPI.getById(id)
      } catch (error) {
        this.error = error.message
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
        console.error('Failed to create ticket:', error)
        return { success: false, error: error.message }
      }
    },

    async updateTicketStatus(id, status) {
      try {
        await ticketsAPI.updateStatus(id, status)
        const ticket = this.tickets.find((t) => t.id === id)
        if (ticket) {
          ticket.status = status
        }
        if (this.currentTicket?.id === id) {
          this.currentTicket.status = status
        }
        return { success: true }
      } catch (error) {
        console.error('Failed to update ticket status:', error)
        return { success: false, error: error.message }
      }
    },

    async assignTicket(id, assignedTo) {
      try {
        await ticketsAPI.assign(id, assignedTo)
        const ticket = this.tickets.find((t) => t.id === id)
        if (ticket) {
          ticket.assignedTo = assignedTo
        }
        if (this.currentTicket?.id === id) {
          this.currentTicket.assignedTo = assignedTo
        }
        return { success: true }
      } catch (error) {
        console.error('Failed to assign ticket:', error)
        return { success: false, error: error.message }
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
