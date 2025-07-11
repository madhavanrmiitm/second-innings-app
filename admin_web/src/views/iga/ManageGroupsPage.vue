<template>
  <AppLayout>
    <div class="container-fluid">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3">Manage Interest Groups</h1>
        <button class="btn btn-success" @click="showAddModal = true">
          <i class="bi bi-plus-circle me-2"></i>Add Group
        </button>
      </div>

      <!-- Groups Grid -->
      <div class="row g-4">
        <div v-for="group in groups" :key="group.id" class="col-12 col-md-6 col-lg-4">
          <div class="card h-100">
            <div class="card-body">
              <div class="d-flex justify-content-between align-items-start mb-3">
                <h5 class="card-title">{{ group.name }}</h5>
                <span :class="`badge bg-${group.active ? 'success' : 'secondary'}`">
                  {{ group.active ? 'Active' : 'Inactive' }}
                </span>
              </div>

              <p class="card-text text-muted">{{ group.description }}</p>

              <div class="d-flex justify-content-between align-items-center mb-3">
                <small class="text-muted">
                  <i class="bi bi-people me-1"></i>
                  {{ group.members }} members
                </small>
                <small class="text-muted">
                  <i class="bi bi-calendar-event me-1"></i>
                  {{ group.events }} events
                </small>
              </div>

              <div class="mb-3">
                <small class="text-muted d-block mb-1">Admin:</small>
                <div class="d-flex align-items-center">
                  <img
                    :src="`https://ui-avatars.com/api/?name=${group.admin}`"
                    :alt="group.admin"
                    class="avatar-sm me-2"
                  />
                  <span>{{ group.admin }}</span>
                </div>
              </div>

              <div class="d-flex gap-2">
                <button class="btn btn-sm btn-outline-primary" @click="editGroup(group)">
                  <i class="bi bi-pencil me-1"></i>Edit
                </button>
                <button class="btn btn-sm btn-outline-info">
                  <i class="bi bi-eye me-1"></i>View
                </button>
                <button class="btn btn-sm btn-outline-danger" @click="deleteGroup(group)">
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
                <label class="form-label">Group Name</label>
                <input v-model="formData.name" type="text" class="form-control" required />
              </div>
              <div class="mb-3">
                <label class="form-label">Description</label>
                <textarea
                  v-model="formData.description"
                  class="form-control"
                  rows="3"
                  required
                ></textarea>
              </div>
              <div class="mb-3">
                <label class="form-label">Category</label>
                <select v-model="formData.category" class="form-select" required>
                  <option value="">Select Category</option>
                  <option value="sports">Sports & Fitness</option>
                  <option value="arts">Arts & Culture</option>
                  <option value="tech">Technology</option>
                  <option value="social">Social Activities</option>
                </select>
              </div>
              <div class="mb-3">
                <label class="form-label">Admin</label>
                <select v-model="formData.adminId" class="form-select" required>
                  <option value="">Select Admin</option>
                  <option value="1">John Doe</option>
                  <option value="2">Jane Smith</option>
                </select>
              </div>
              <div class="mb-3">
                <div class="form-check">
                  <input
                    v-model="formData.active"
                    type="checkbox"
                    class="form-check-input"
                    id="activeCheck"
                  />
                  <label class="form-check-label" for="activeCheck"> Active </label>
                </div>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" @click="closeModal">Cancel</button>
              <button type="submit" class="btn btn-success" :disabled="saving">
                <span v-if="saving" class="spinner-border spinner-border-sm me-2"></span>
                {{ showEditModal ? 'Update' : 'Create' }} Group
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div
      v-if="showAddModal || showEditModal"
      class="modal-backdrop fade show"
      @click="closeModal"
    ></div>
  </AppLayout>
</template>

<script setup>
import { ref } from 'vue'
import AppLayout from '@/components/common/AppLayout.vue'
import { useToast } from 'vue-toast-notification'

const toast = useToast()

const showAddModal = ref(false)
const showEditModal = ref(false)
const saving = ref(false)

const groups = ref([
  {
    id: 1,
    name: 'Morning Walkers',
    description: 'Daily morning walks in the park for health and socializing',
    category: 'sports',
    members: 45,
    events: 120,
    admin: 'John Doe',
    active: true,
  },
  {
    id: 2,
    name: 'Book Club',
    description: 'Monthly book discussions and literary activities',
    category: 'arts',
    members: 28,
    events: 24,
    admin: 'Jane Smith',
    active: true,
  },
  {
    id: 3,
    name: 'Tech Seniors',
    description: 'Learning and exploring technology together',
    category: 'tech',
    members: 32,
    events: 48,
    admin: 'Mike Johnson',
    active: false,
  },
])

const formData = ref({
  name: '',
  description: '',
  category: '',
  adminId: '',
  active: true,
})

const editGroup = (group) => {
  formData.value = { ...group }
  showEditModal.value = true
}

const deleteGroup = (group) => {
  if (confirm(`Are you sure you want to delete "${group.name}"?`)) {
    groups.value = groups.value.filter((g) => g.id !== group.id)
    toast.success('Group deleted successfully')
  }
}

const closeModal = () => {
  showAddModal.value = false
  showEditModal.value = false
  formData.value = {
    name: '',
    description: '',
    category: '',
    adminId: '',
    active: true,
  }
}

const saveGroup = async () => {
  saving.value = true

  try {
    await new Promise((resolve) => setTimeout(resolve, 1000))

    if (showEditModal.value) {
      // Update existing group
      const index = groups.value.findIndex((g) => g.id === formData.value.id)
      if (index !== -1) {
        groups.value[index] = { ...formData.value }
      }
      toast.success('Group updated successfully')
    } else {
      // Add new group
      groups.value.push({
        ...formData.value,
        id: Date.now(),
        members: 0,
        events: 0,
        admin: 'New Admin',
      })
      toast.success('Group created successfully')
    }

    closeModal()
  } catch (error) {
    toast.error('Operation failed')
  } finally {
    saving.value = false
  }
}
</script>
