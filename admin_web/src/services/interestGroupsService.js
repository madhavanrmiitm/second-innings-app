import { ApiService } from './apiService'

class InterestGroupsService {
  /**
   * Get all interest groups (for admins/IGAs) or public groups
   */
  async getInterestGroups(isPublic = false) {
    try {
      const endpoint = isPublic ? '/api/interest-groups/public' : '/api/interest-groups'
      const response = await ApiService.get(endpoint)
      // API returns { data: { interest_groups: [...] } }
      return response.data || response
    } catch (error) {
      console.error('Error fetching interest groups:', error)
      throw error
    }
  }

  /**
   * Get a specific interest group by ID
   */
  async getInterestGroup(groupId) {
    try {
      const response = await ApiService.get(`/api/interest-groups/${groupId}`)
      return response.data || response
    } catch (error) {
      console.error('Error fetching interest group:', error)
      throw error
    }
  }

  /**
   * Create a new interest group
   */
  async createInterestGroup(groupData) {
    try {
      // Validate WhatsApp link format
      if (groupData.whatsapp_link && !groupData.whatsapp_link.startsWith('https://chat.whatsapp.com/')) {
        throw new Error('WhatsApp link must start with "https://chat.whatsapp.com/"')
      }

      const response = await ApiService.post('/api/interest-groups', { body: groupData })
      return response.data || response
    } catch (error) {
      console.error('Error creating interest group:', error)
      throw error
    }
  }

  /**
   * Update an existing interest group
   */
  async updateInterestGroup(groupId, groupData) {
    try {
      // Validate WhatsApp link format if provided
      if (groupData.whatsapp_link && !groupData.whatsapp_link.startsWith('https://chat.whatsapp.com/')) {
        throw new Error('WhatsApp link must start with "https://chat.whatsapp.com/"')
      }

      const response = await ApiService.put(`/api/interest-groups/${groupId}`, { body: groupData })
      return response.data || response
    } catch (error) {
      console.error('Error updating interest group:', error)
      throw error
    }
  }

  /**
   * Delete an interest group
   */
  async deleteInterestGroup(groupId) {
    try {
      const response = await ApiService.delete(`/api/interest-groups/${groupId}`)
      return response.data || response
    } catch (error) {
      console.error('Error deleting interest group:', error)
      throw error
    }
  }

  /**
   * Get available categories for interest groups
   */
  getCategories() {
    return [
      { value: 'Health', label: 'Health & Wellness' },
      { value: 'Arts', label: 'Arts & Crafts' },
      { value: 'Technology', label: 'Technology' },
      { value: 'Education', label: 'Education & Learning' },
      { value: 'Social', label: 'Social Activities' },
      { value: 'Sports', label: 'Sports & Fitness' },
      { value: 'Hobby', label: 'Hobbies & Interests' },
      { value: 'Other', label: 'Other' }
    ]
  }

  /**
   * Validate WhatsApp link format
   */
  validateWhatsAppLink(link) {
    if (!link) return true // Optional field
    
    const whatsappPattern = /^https:\/\/chat\.whatsapp\.com\/[A-Za-z0-9]+$/
    return whatsappPattern.test(link)
  }

  /**
   * Format timing for display
   */
  formatTiming(timing) {
    if (!timing) return 'No specific time'
    
    try {
      const date = new Date(timing)
      return date.toLocaleString('en-US', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    } catch (error) {
      return 'Invalid date'
    }
  }

  /**
   * Get category icon for display
   */
  getCategoryIcon(category) {
    const icons = {
      'Health': 'heart',
      'Arts': 'palette',
      'Technology': 'laptop',
      'Education': 'book',
      'Social': 'people',
      'Sports': 'trophy',
      'Hobby': 'star',
      'Other': 'circle'
    }
    return icons[category] || 'circle'
  }

  /**
   * Get status badge class
   */
  getStatusClass(status) {
    return status === 'active' ? 'success' : 'secondary'
  }
}

export default new InterestGroupsService()
