import axios from 'axios'
import { mockUsers, mockOfficials, mockTickets, mockNotifications } from './mockData'

// Create axios instance
const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
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

// Mock API implementations
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

export const ticketsAPI = {
  async getAll(filters = {}) {
    await delay(800)
    let tickets = [...mockTickets]

    // Apply filters
    if (filters.status) {
      tickets = tickets.filter((t) => t.status === filters.status)
    }
    if (filters.priority) {
      tickets = tickets.filter((t) => t.priority === filters.priority)
    }
    if (filters.assignedTo) {
      tickets = tickets.filter((t) => t.assignedTo === filters.assignedTo)
    }

    return tickets
  },

  async getById(id) {
    await delay(600)
    return mockTickets.find((t) => t.id === id) || null
  },

  async create(ticketData) {
    await delay(1000)
    return {
      ...ticketData,
      id: 'TICK-' + Date.now(),
      status: 'Open',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    }
  },

  async updateStatus(id, status) {
    await delay(800)
    return { id, status, updatedAt: new Date().toISOString() }
  },

  async assign(id, assignedTo) {
    await delay(700)
    return { id, assignedTo, updatedAt: new Date().toISOString() }
  },

  async addComment(ticketId, comment) {
    await delay(600)
    return {
      id: Date.now(),
      ticketId,
      ...comment,
      createdAt: new Date().toISOString(),
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
