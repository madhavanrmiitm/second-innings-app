import axios from 'axios'
import { mockUsers, mockOfficials, mockNotifications } from './mockData'

// Create axios instance
const rawBaseURL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000'
const apiClient = axios.create({
  baseURL: `${rawBaseURL}/api`,  // ✅ always append /api
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})


// Request interceptor
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error),
)

// Response interceptor
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  },
)

// Simulate API delay
const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms))

// Field mapping helpers for tickets
const mapTicketToFrontend = (ticket) => {
  if (!ticket) return null
  return {
    ...ticket,
    title: ticket.subject, // Map subject to title
    createdBy: ticket.created_by_name || ticket.user_id,
    assignedTo: ticket.assigned_to_name || ticket.assigned_to,
    // Capitalize status for frontend display
    status: ticket.status ? ticket.status.charAt(0).toUpperCase() + ticket.status.slice(1).replace('_', ' ') : '',
    // Capitalize priority
    priority: ticket.priority ? ticket.priority.charAt(0).toUpperCase() + ticket.priority.slice(1) : 'Medium',
  }
}

const mapTicketToBackend = (ticket) => {
  const mapped = {
    subject: ticket.title || ticket.subject,
    description: ticket.description,
  }
  
  if (ticket.priority) {
    mapped.priority = ticket.priority.toLowerCase()
  }
  
  if (ticket.category) {
    mapped.category = ticket.category
  }
  
  if (ticket.status) {
    mapped.status = ticket.status.toLowerCase().replace(' ', '_')
  }
  
  if (ticket.assigned_to !== undefined) {
    mapped.assigned_to = ticket.assigned_to
  }
  
  return mapped
}

// Mock API implementations (keeping existing ones)
export const authAPI = {
  async login(credentials) {
    await delay(1000)
    // Simulate Google OAuth response
    return {
      user: mockUsers[0],
      token: 'mock-jwt-token-' + Date.now(),
    }
  },

  async logout() {
    await delay(500)
    return { success: true }
  },

  async refreshToken() {
    await delay(800)
    return { token: 'refreshed-token-' + Date.now() }
  },
}

export const officialsAPI = {
  async getAll() {
    await delay(800)
    return mockOfficials
  },

  async getById(id) {
    await delay(600)
    return mockOfficials.find((o) => o.id === id)
  },

  async create(official) {
    await delay(1000)
    return {
      ...official,
      id: Date.now(),
      joinedDate: new Date().toISOString().split('T')[0],
      createdAt: new Date().toISOString(),
    }
  },

  async update(id, data) {
    await delay(800)
    return { ...data, id, updatedAt: new Date().toISOString() }
  },

  async delete(id) {
    await delay(600)
    return { success: true, id }
  },
}

// Updated ticketsAPI to use real API
export const ticketsAPI = {
  async getAll(filters = {}) {
    try {
      // Build query params
      const params = new URLSearchParams()
      if (filters.status) params.append('status', filters.status.toLowerCase().replace(' ', '_'))
      if (filters.priority) params.append('priority', filters.priority.toLowerCase())
      if (filters.assignedTo) params.append('assigned_to', filters.assignedTo)
      
      const response = await apiClient.get('/tickets', { params })
      
      // Map response tickets to frontend format
      const tickets = response.data.data?.tickets || []
      return tickets.map(mapTicketToFrontend)
    } catch (error) {
      console.error('Error fetching tickets:', error)
      throw error
    }
  },

  async getById(id) {
    try {
      const response = await apiClient.get(`/tickets/${id}`)
      const ticket = response.data.data?.ticket
      return mapTicketToFrontend(ticket)
    } catch (error) {
      console.error('Error fetching ticket:', error)
      throw error
    }
  },

  async create(ticketData) {
    try {
      const mappedData = mapTicketToBackend(ticketData)
      const response = await apiClient.post('/tickets', mappedData)
      
      // Fetch the created ticket to get full details
      if (response.data.data?.ticket_id) {
        return await this.getById(response.data.data.ticket_id)
      }
      
      throw new Error('Failed to create ticket')
    } catch (error) {
      console.error('Error creating ticket:', error)
      throw error
    }
  },

  async updateStatus(id, status) {
    try {
      const mappedStatus = status.toLowerCase().replace(' ', '_')
      const response = await apiClient.put(`/tickets/${id}`, { status: mappedStatus })
      return response.data
    } catch (error) {
      console.error('Error updating ticket status:', error)
      throw error
    }
  },

  async assign(id, assignedTo) {
    try {
      const response = await apiClient.put(`/tickets/${id}`, { assigned_to: assignedTo })
      return response.data
    } catch (error) {
      console.error('Error assigning ticket:', error)
      throw error
    }
  },
}

export const notificationsAPI = {
  async getAll() {
    await delay(600)
    return mockNotifications
  },

  async markAsRead(id) {
    await delay(400)
    return { id, read: true }
  },

  async markAllAsRead() {
    await delay(800)
    return { success: true }
  },

  async delete(id) {
    await delay(500)
    return { success: true, id }
  },
}

export const igaAPI = {
  async registerAdmin(data) {
    await delay(1200)
    return {
      ...data,
      id: Date.now(),
      status: 'Pending',
      createdAt: new Date().toISOString(),
    }
  },

  async getGroups() {
    await delay(800)
    return []
  },

  async createGroup(groupData) {
    await delay(1000)
    return {
      ...groupData,
      id: Date.now(),
      members: 0,
      events: 0,
      createdAt: new Date().toISOString(),
    }
  },

  async updateGroup(id, data) {
    await delay(800)
    return { ...data, id, updatedAt: new Date().toISOString() }
  },

  async deleteGroup(id) {
    await delay(600)
    return { success: true, id }
  },
}

export default apiClient