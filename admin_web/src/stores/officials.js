import { defineStore } from 'pinia'
import { officialsAPI } from '@/services/officialsService'

export const useOfficialsStore = defineStore('officials', {
  state: () => ({
    officials: [],
    loading: false,
    error: null,
    filters: {
      search: '',
      status: '',
      department: '',
    },
  }),

  getters: {
    filteredOfficials: (state) => {
      let result = state.officials

      if (state.filters.search) {
        const search = state.filters.search.toLowerCase()
        result = result.filter(
          (official) =>
            official.name.toLowerCase().includes(search) ||
            official.email.toLowerCase().includes(search),
        )
      }

      if (state.filters.status) {
        result = result.filter((official) => official.status === state.filters.status)
      }

      if (state.filters.department) {
        result = result.filter((official) => official.department === state.filters.department)
      }

      return result
    },

    totalOfficials: (state) => state.officials.length,

    activeOfficials: (state) => state.officials.filter((o) => o.status === 'Active').length,

    departments: (state) => {
      const depts = new Set(state.officials.map((o) => o.department))
      return Array.from(depts)
    },
  },

  actions: {
    async fetchOfficials() {
      this.loading = true
      this.error = null
      try {
        this.officials = await officialsAPI.getAll()
      } catch (error) {
        this.error = error.message
        console.error('Failed to fetch officials:', error)
      } finally {
        this.loading = false
      }
    },

    async addOfficial(officialData) {
      try {
        const newOfficial = await officialsAPI.create(officialData)
        this.officials.push(newOfficial)
        return { success: true, data: newOfficial }
      } catch (error) {
        console.error('Failed to add official:', error)
        return { success: false, error: error.message }
      }
    },

    async updateOfficial(id, data) {
      try {
        const updated = await officialsAPI.update(id, data)
        const index = this.officials.findIndex((o) => o.id === id)
        if (index !== -1) {
          this.officials[index] = { ...this.officials[index], ...updated }
        }
        return { success: true, data: updated }
      } catch (error) {
        console.error('Failed to update official:', error)
        return { success: false, error: error.message }
      }
    },

    async deleteOfficial(id) {
      try {
        await officialsAPI.delete(id)
        this.officials = this.officials.filter((o) => o.id !== id)
        return { success: true }
      } catch (error) {
        console.error('Failed to delete official:', error)
        return { success: false, error: error.message }
      }
    },

    updateFilters(filters) {
      this.filters = { ...this.filters, ...filters }
    },

    clearFilters() {
      this.filters = {
        search: '',
        status: '',
        department: '',
      }
    },
  },
})
