import { ApiService } from './apiService'

export class OfficialsService {
  static get apiPrefix() {
    return '/api/admin/officials'
  }

  // Get all officials
  static async getAll() {
    try {
      const response = await ApiService.get(this.apiPrefix)

      if (response.isSuccess && response.data?.data) {
        return response.data.data.officials || []
      }

      throw new Error(response.error || 'Failed to fetch officials')
    } catch (error) {
      console.error('Failed to fetch officials:', error)
      throw error
    }
  }

  // Get official by ID
  static async getById(id) {
    try {
      const response = await ApiService.get(`${this.apiPrefix}/${id}`)

      if (response.isSuccess && response.data?.data) {
        return response.data.data.official
      }

      throw new Error(response.error || 'Failed to fetch official')
    } catch (error) {
      console.error('Failed to fetch official:', error)
      throw error
    }
  }

  // Create new official
  static async create(officialData) {
    try {
      const response = await ApiService.post(this.apiPrefix, {
        body: officialData
      })

      if (response.isSuccess && response.data?.data) {
        return response.data.data.official
      }

      throw new Error(response.error || 'Failed to create official')
    } catch (error) {
      console.error('Failed to create official:', error)
      throw error
    }
  }

  // Update official
  static async update(id, data) {
    try {
      const response = await ApiService.put(`${this.apiPrefix}/${id}`, {
        body: data
      })

      if (response.isSuccess) {
        return { ...data, id, updatedAt: new Date().toISOString() }
      }

      throw new Error(response.error || 'Failed to update official')
    } catch (error) {
      console.error('Failed to update official:', error)
      throw error
    }
  }

  // Delete official
  static async delete(id) {
    try {
      const response = await ApiService.delete(`${this.apiPrefix}/${id}`)

      if (response.isSuccess) {
        return { success: true, id }
      }

      throw new Error(response.error || 'Failed to delete official')
    } catch (error) {
      console.error('Failed to delete official:', error)
      throw error
    }
  }
}

export const officialsAPI = {
  async getAll() {
    return OfficialsService.getAll()
  },

  async getById(id) {
    return OfficialsService.getById(id)
  },

  async create(official) {
    return OfficialsService.create(official)
  },

  async update(id, data) {
    return OfficialsService.update(id, data)
  },

  async delete(id) {
    return OfficialsService.delete(id)
  }
}
