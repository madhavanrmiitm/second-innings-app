<template>
  <AppLayout>
    <div class="container-fluid">
      <div class="mb-4">
        <h1 class="h3 mb-2">Interest Groups</h1>
        <p class="text-muted">Join community groups and connect with others who share your interests</p>
      </div>

      <!-- Category Filter -->
      <div class="row mb-4">
        <div class="col-md-4">
          <select v-model="selectedCategory" class="form-select">
            <option value="">All Categories</option>
            <option v-for="category in categories" :key="category.value" :value="category.value">
              {{ category.label }}
            </option>
          </select>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      </div>

      <!-- Groups Grid -->
      <div v-else class="row g-4">
        <div v-if="filteredGroups.length === 0" class="col-12">
          <div class="card">
            <div class="card-body text-center py-5">
              <i class="bi bi-collection text-muted" style="font-size: 3rem"></i>
              <h5 class="mt-3 text-muted">No Interest Groups Found</h5>
              <p class="text-muted">
                {{ selectedCategory ? 'No groups found in this category.' : 'Check back later for new groups!' }}
              </p>
            </div>
          </div>
        </div>

        <div v-for="group in filteredGroups" :key="group.id" class="col-12 col-md-6 col-lg-4">
          <div class="card h-100">
            <div class="card-body">
              <div class="d-flex justify-content-between align-items-start mb-3">
                <h5 class="card-title">{{ group.title }}</h5>
                <span class="badge bg-success">Active</span>
              </div>

              <p class="card-text text-muted">{{ group.description || 'No description provided' }}</p>

              <div v-if="group.category" class="mb-3">
                <span class="badge bg-light text-dark">
                  <i :class="`bi bi-${getCategoryIcon(group.category)} me-1`"></i>
                  {{ group.category }}
                </span>
              </div>

              <div v-if="group.timing" class="mb-3">
                <small class="text-muted">
                  <i class="bi bi-calendar-event me-1"></i>
                  <strong>Next Event:</strong> {{ formatTiming(group.timing) }}
                </small>
              </div>

              <div v-if="group.whatsapp_link" class="d-grid">
                <a 
                  :href="group.whatsapp_link" 
                  target="_blank" 
                  class="btn btn-success"
                >
                  <i class="bi bi-whatsapp me-2"></i>Join WhatsApp Group
                </a>
              </div>
              <div v-else class="d-grid">
                <button class="btn btn-outline-secondary" disabled>
                  <i class="bi bi-info-circle me-2"></i>Contact Admin for Details
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import AppLayout from '@/components/common/AppLayout.vue'
import { useToast } from 'vue-toast-notification'
import interestGroupsService from '@/services/interestGroupsService'

const toast = useToast()

// State
const loading = ref(false)
const groups = ref([])
const selectedCategory = ref('')

// Get categories from service
const categories = computed(() => interestGroupsService.getCategories())

// Filter groups by selected category
const filteredGroups = computed(() => {
  if (!selectedCategory.value) return groups.value
  return groups.value.filter(group => group.category === selectedCategory.value)
})

// Helper functions
const getCategoryIcon = (category) => {
  return interestGroupsService.getCategoryIcon(category)
}

const formatTiming = (timing) => {
  return interestGroupsService.formatTiming(timing)
}

// Load public groups from API
const loadGroups = async () => {
  loading.value = true
  try {
    const response = await interestGroupsService.getInterestGroups(true) // isPublic = true
    groups.value = response.interest_groups || []
  } catch (error) {
    console.error('Failed to load groups:', error)
    toast.error('Failed to load interest groups')
  } finally {
    loading.value = false
  }
}

// Initialize
onMounted(() => {
  loadGroups()
})
</script>

<style scoped>
.card {
  transition: transform 0.2s;
}

.card:hover {
  transform: translateY(-2px);
}
</style>
