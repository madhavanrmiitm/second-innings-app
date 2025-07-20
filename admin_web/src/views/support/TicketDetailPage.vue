<template>
  <RoleBasedLayout>
    <div class="container-fluid" v-if="currentTicket">
      <!-- Header -->
      <div class="d-flex justify-content-between align-items-start mb-4">
        <div>
          <div class="d-flex align-items-center gap-2 mb-2">
            <router-link to="/tickets" class="text-decoration-none">
              <i class="bi bi-arrow-left"></i> Back to Tickets
            </router-link>
          </div>
          <h1 class="h3 mb-0">{{ currentTicket.title }}</h1>
          <div class="text-muted">Ticket #{{ currentTicket.id }}</div>
        </div>
        <div class="d-flex gap-2">
          <button class="btn btn-outline-secondary"><i class="bi bi-pencil me-2"></i>Edit</button>
          <button class="btn btn-outline-danger"><i class="bi bi-trash me-2"></i>Delete</button>
        </div>
      </div>

      <div class="row">
        <!-- Main Content -->
        <div class="col-12 col-lg-8">
          <!-- Ticket Info -->
          <div class="card mb-4">
            <div class="card-body">
              <h5 class="card-title">Description</h5>
              <p class="card-text">{{ currentTicket.description }}</p>

              <hr />

              <div class="row">
                <div class="col-6">
                  <small class="text-muted">Created by</small>
                  <p class="mb-0">{{ currentTicket.createdBy }}</p>
                </div>
                <div class="col-6">
                  <small class="text-muted">Created at</small>
                  <p class="mb-0">{{ formatDate(currentTicket.createdAt) }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Comments -->
          <div class="card">
            <div class="card-header">
              <h5 class="card-title mb-0">Comments</h5>
            </div>
            <div class="card-body">
              <div class="text-center text-muted py-3">No comments yet</div>

              <!-- Add Comment Form -->
              <div class="mt-4">
                <form @submit.prevent="addComment">
                  <div class="mb-3">
                    <textarea
                      v-model="newComment"
                      class="form-control"
                      rows="3"
                      placeholder="Add a comment..."
                      required
                    ></textarea>
                  </div>
                  <button type="submit" class="btn btn-primary">Post Comment</button>
                </form>
              </div>
            </div>
          </div>
        </div>

        <!-- Sidebar -->
        <div class="col-12 col-lg-4">
          <!-- Status Card -->
          <div class="card mb-4">
            <div class="card-header">
              <h6 class="mb-0">Ticket Details</h6>
            </div>
            <div class="card-body">
              <div class="mb-3">
                <label class="form-label small text-muted">Status</label>
                <select v-model="currentTicket.status" class="form-select" @change="updateStatus">
                  <option value="Open">Open</option>
                  <option value="In Progress">In Progress</option>
                  <option value="Closed">Closed</option>
                </select>
              </div>

              <div class="mb-3">
                <label class="form-label small text-muted">Priority</label>
                <div>
                  <span :class="`badge bg-${getPriorityColor(currentTicket.priority)}`">
                    {{ currentTicket.priority }}
                  </span>
                </div>
              </div>

              <div class="mb-3">
                <label class="form-label small text-muted">Category</label>
                <p class="mb-0">{{ currentTicket.category }}</p>
              </div>

              <div>
                <label class="form-label small text-muted">Assigned To</label>
                <p class="mb-0">{{ currentTicket.assignedTo }}</p>
              </div>
            </div>
          </div>

          <!-- Activity Log -->
          <div class="card">
            <div class="card-header">
              <h6 class="mb-0">Activity Log</h6>
            </div>
            <div class="card-body">
              <div class="text-center text-muted py-3">No activity yet</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-else-if="loading" class="text-center py-5">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>
    </div>
  </RoleBasedLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import RoleBasedLayout from '@/components/common/RoleBasedLayout.vue'
import { useTicketsStore } from '@/stores/tickets'
import { useToast } from 'vue-toast-notification'

const route = useRoute()
const ticketsStore = useTicketsStore()
const toast = useToast()

const newComment = ref('')
const loading = computed(() => ticketsStore.loading)
const currentTicket = computed(() => ticketsStore.currentTicket)

const getPriorityColor = (priority) => {
  const colors = {
    Low: 'secondary',
    Medium: 'warning',
    High: 'danger',
  }
  return colors[priority] || 'secondary'
}

const formatDate = (date) => {
  return new Date(date).toLocaleString()
}

const updateStatus = async () => {
  const result = await ticketsStore.updateTicketStatus(
    currentTicket.value.id,
    currentTicket.value.status,
  )

  if (result.success) {
    toast.success('Ticket status updated')
  } else {
    toast.error('Failed to update status')
  }
}

const addComment = () => {
  // Implement comment functionality
  toast.success('Comment added')
  newComment.value = ''
}

onMounted(() => {
  const ticketId = route.params.id
  ticketsStore.fetchTicketById(ticketId)
})
</script>
