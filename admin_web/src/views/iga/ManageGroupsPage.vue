<template>
  <RoleBasedLayout>
    <div class="container-fluid">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3">Manage Interest Groups</h1>
        <button class="btn btn-success" @click="showAddModal = true" :disabled="loading">
          <i class="bi bi-plus-circle me-2"></i>Add Group
        </button>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      </div>

      <!-- Groups Grid -->
      <div v-else class="row g-4">
        <div v-if="groups.length === 0" class="col-12">
          <div class="card">
            <div class="card-body text-center py-5">
              <i class="bi bi-collection text-muted" style="font-size: 3rem"></i>
              <h5 class="mt-3 text-muted">No Interest Groups Found</h5>
              <p class="text-muted">Create your first interest group to get started!</p>
              <button class="btn btn-success" @click="showAddModal = true">
                <i class="bi bi-plus-circle me-2"></i>Add Your First Group
              </button>
            </div>
          </div>
        </div>

        <div v-for="group in groups" :key="group.id" class="col-12 col-md-6 col-lg-4">
          <div class="card h-100">
            <div class="card-body">
              <div class="d-flex justify-content-between align-items-start mb-3">
                <h5 class="card-title">{{ group.title }}</h5>
                <span :class="`badge bg-${group.status === 'active' ? 'success' : 'secondary'}`">
                  {{ group.status === 'active' ? 'Active' : 'Inactive' }}
                </span>
              </div>

              <p class="card-text text-muted">{{ group.description || 'No description provided' }}</p>

              <div v-if="group.category" class="mb-3">
                <span class="badge bg-light text-dark">
                  <i :class="`bi bi-${getCategoryIcon(group.category)} me-1`"></i>
                  {{ group.category }}
                </span>
              </div>

              <div class="mb-3">
                <small class="text-muted">
                  <i class="bi bi-people me-1"></i>
                  {{ group.member_count || 0 }} members
                </small>
              </div>

              <div v-if="group.timing" class="mb-3">
                <small class="text-muted">
                  <i class="bi bi-calendar me-1"></i>
                  Next Event: {{ formatTiming(group.timing) }}
                </small>
              </div>

              <div v-if="group.whatsapp_link" class="mb-3">
                <a
                  :href="group.whatsapp_link"
                  target="_blank"
                  class="btn btn-sm btn-success w-100"
                >
                  <i class="bi bi-whatsapp me-1"></i>WhatsApp Group
                </a>
              </div>

              <div class="d-flex gap-2">
                <button class="btn btn-sm btn-outline-info" @click="viewMembers(group)">
                  <i class="bi bi-people me-1"></i>View Members
                </button>
                <button class="btn btn-sm btn-outline-primary" @click="editGroup(group)">
                  <i class="bi bi-pencil me-1"></i>Edit
                </button>
                <button
                  class="btn btn-sm btn-outline-danger"
                  @click="deleteGroup(group)"
                  :disabled="deleting === group.id"
                >
                  <i class="bi bi-trash me-1"></i>Delete
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Add/Edit Modal -->
    <div
      class="modal fade"
      :class="{ show: showAddModal || showEditModal }"
      :style="{ display: showAddModal || showEditModal ? 'block' : 'none' }"
    >
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              {{ showEditModal ? 'Edit Group' : 'Add New Group' }}
            </h5>
            <button type="button" class="btn-close" @click="closeModal"></button>
          </div>
          <form @submit.prevent="saveGroup">
            <div class="modal-body">
              <div class="mb-3">
                <label class="form-label">Group Name <span class="text-danger">*</span></label>
                <input
                  v-model="formData.title"
                  type="text"
                  class="form-control"
                  required
                  maxlength="255"
                />
              </div>

              <div class="mb-3">
                <label class="form-label">Description</label>
                <textarea
                  v-model="formData.description"
                  class="form-control"
                  rows="3"
                  placeholder="Describe what this group is about..."
                ></textarea>
              </div>

              <div class="mb-3">
                <label class="form-label">Category</label>
                <select v-model="formData.category" class="form-select">
                  <option value="">Select Category</option>
                  <option v-for="cat in categories" :key="cat.value" :value="cat.value">
                    {{ cat.label }}
                  </option>
                </select>
              </div>

              <div class="mb-3">
                <label class="form-label">WhatsApp Group Link</label>
                <input
                  v-model="formData.whatsapp_link"
                  type="url"
                  class="form-control"
                  placeholder="https://chat.whatsapp.com/..."
                />
                <div class="form-text">
                  Optional: Link to the WhatsApp group for this community
                </div>
                <div v-if="whatsappLinkError" class="text-danger small">
                  {{ whatsappLinkError }}
                </div>
              </div>

              <div class="mb-3">
                <label class="form-label">Status</label>
                <select v-model="formData.status" class="form-select">
                  <option value="active">Active</option>
                  <option value="inactive">Inactive</option>
                </select>
              </div>
            </div>

            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" @click="closeModal">
                Cancel
              </button>
              <button type="submit" class="btn btn-primary" :disabled="saving">
                <span v-if="saving" class="spinner-border spinner-border-sm me-2"></span>
                {{ showEditModal ? 'Update Group' : 'Create Group' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Modal Backdrop -->
    <div
      v-if="showAddModal || showEditModal"
      class="modal-backdrop fade show"
      @click="closeModal"
    ></div>
  </RoleBasedLayout>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import RoleBasedLayout from '@/components/common/RoleBasedLayout.vue'
import { useToast } from 'vue-toast-notification'
import interestGroupsService from '@/services/interestGroupsService'

const toast = useToast()
const router = useRouter()

const loading = ref(false)
const saving = ref(false)
const deleting = ref(null)
const groups = ref([])
const showAddModal = ref(false)
const showEditModal = ref(false)

const categories = computed(() => interestGroupsService.getCategories())

const formData = ref({
  id: null,
  title: '',
  description: '',
  category: '',
  whatsapp_link: '',
  timing: '',
  status: 'active'
})

const whatsappLinkError = computed(() => {
  if (!formData.value.whatsapp_link) return null
  if (!interestGroupsService.validateWhatsAppLink(formData.value.whatsapp_link)) {
    return 'WhatsApp link must be in format: https://chat.whatsapp.com/...'
  }
  return null
})

const getCategoryIcon = (category) => {
  return interestGroupsService.getCategoryIcon(category)
}

const formatTiming = (timing) => {
  if (!timing) return 'No specific time'
  try {
    const date = new Date(timing)
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
  } catch (error) {
    return 'Invalid date'
  }
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString()
}

const loadGroups = async () => {
  loading.value = true
  try {
    const response = await interestGroupsService.getInterestGroups()
    groups.value = response.data?.interest_groups || response.interest_groups || []
  } catch (error) {
    console.error('Failed to load groups:', error)
    toast.error('Failed to load interest groups')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadGroups()
})

const closeModal = () => {
  showAddModal.value = false
  showEditModal.value = false
  formData.value = {
    id: null,
    title: '',
    description: '',
    category: '',
    whatsapp_link: '',
    timing: '',
    status: 'active'
  }
}

const editGroup = (group) => {
  formData.value = {
    id: group.id,
    title: group.title,
    description: group.description || '',
    category: group.category || '',
    whatsapp_link: group.whatsapp_link || '',
    timing: group.timing ? new Date(group.timing).toISOString().slice(0, 16) : '',
    status: group.status || 'active'
  }
  showEditModal.value = true
}

const saveGroup = async () => {
  if (whatsappLinkError.value) {
    toast.error(whatsappLinkError.value)
    return
  }

  saving.value = true
  try {
    const groupData = {
      title: formData.value.title,
      description: formData.value.description,
      category: formData.value.category,
      whatsapp_link: formData.value.whatsapp_link,
      timing: formData.value.timing ? new Date(formData.value.timing).toISOString() : null,
      status: formData.value.status
    }

    if (showEditModal.value) {
      // Update existing group
      await interestGroupsService.updateInterestGroup(formData.value.id, groupData)
      toast.success('Group updated successfully')
    } else {
      await interestGroupsService.createInterestGroup(groupData)
      toast.success('Group created successfully')
    }

    closeModal()
    await loadGroups()
  } catch (error) {
    console.error('Failed to save group:', error)
    toast.error(error.response?.data?.message || 'Failed to save group')
  } finally {
    saving.value = false
  }
}

const deleteGroup = async (group) => {
  if (!confirm(`Are you sure you want to delete "${group.title}"? This action cannot be undone.`)) {
    return
  }

  deleting.value = group.id
  try {
    await interestGroupsService.deleteInterestGroup(group.id)
    toast.success('Group deleted successfully')
    await loadGroups()
  } catch (error) {
    console.error('Failed to delete group:', error)
    toast.error(error.response?.data?.message || 'Failed to delete group')
  } finally {
    deleting.value = null
  }
}

const viewMembers = (group) => {
  router.push(`/iga/groups/${group.id}/members`)
}
</script>
