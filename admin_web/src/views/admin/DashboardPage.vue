<template>
  <AppLayout>
    <div class="container-fluid">
      <!-- Header -->
      <div class="mb-4">
        <h1 class="h3 mb-0">Dashboard</h1>
      </div>

      <!-- Stats Grid -->
      <div class="row g-3 mb-4">
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Total Users"
            :value="adminStore.stats.totalUsers"
            icon="users"
            color="primary"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Active Users"
            :value="adminStore.stats.activeUsers"
            icon="user-check"
            color="success"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Pending Approvals"
            :value="adminStore.stats.pendingUsers"
            icon="clock"
            color="warning"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Pending Caregivers"
            :value="adminStore.stats.pendingCaregivers"
            icon="heart"
            color="info"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Pending IGA Admins"
            :value="adminStore.stats.pendingInterestGroupAdmins"
            icon="people"
            color="purple"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Interest Groups"
            :value="adminStore.stats.interestGroups || 0"
            icon="collection"
            color="secondary"
          />
        </div>
      </div>

      <!-- Additional Stats Grid -->
      <div class="row g-3 mb-4">
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Admin Users"
            :value="adminStore.stats.adminUsers"
            icon="shield"
            color="danger"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Support Users"
            :value="adminStore.stats.supportUsers"
            icon="headphones"
            color="secondary"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="IGA Users"
            :value="adminStore.stats.igaUsers"
            icon="people"
            color="purple"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Blocked Users"
            :value="adminStore.stats.blockedUsers"
            icon="ban"
            color="dark"
          />
        </div>
      </div>

    

      <!-- Recent Activity -->
      <div class="row g-3">
        <!-- Recent Users -->
        <div class="col-12 col-md-6">
          <div class="card">
            <div class="card-header">
              <h5 class="card-title mb-0">Recent Users</h5>
            </div>
            <div class="card-body">
              <div v-if="recentUsers.length === 0" class="text-center text-muted py-3">
                No users found
              </div>
              <div v-else class="list-group list-group-flush">
                <div
                  v-for="user in recentUsers"
                  :key="user.id"
                  class="list-group-item d-flex justify-content-between align-items-center"
                >
                  <div>
                    <h6 class="mb-1">{{ user.full_name }}</h6>
                    <small class="text-muted">{{ user.gmail_id }}</small>
                  </div>
                  <span :class="`badge bg-${getStatusColor(user.status)}`">
                    {{ formatUserStatus(user.status) }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Pending Caregivers -->
        <div class="col-12 col-md-6">
          <div class="card">
            <div class="card-header">
              <h5 class="card-title mb-0">Pending Caregiver Approvals</h5>
            </div>
            <div class="card-body">
              <div v-if="recentCaregivers.length === 0" class="text-center text-muted py-3">
                No pending caregivers
              </div>
              <div v-else class="list-group list-group-flush">
                <div
                  v-for="caregiver in recentCaregivers"
                  :key="caregiver.id"
                  class="list-group-item d-flex justify-content-between align-items-center"
                >
                  <div>
                    <h6 class="mb-1">{{ caregiver.full_name }}</h6>
                    <small class="text-muted">{{ caregiver.gmail_id }}</small>
                  </div>
                  <span class="badge bg-warning">Pending</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Pending Interest Group Admins -->
        <div class="col-12 col-md-6">
          <div class="card">
            <div class="card-header">
              <h5 class="card-title mb-0">Pending Interest Group Admin Approvals</h5>
            </div>
            <div class="card-body">
              <div v-if="recentInterestGroupAdmins.length === 0" class="text-center text-muted py-3">
                No pending interest group admins
              </div>
              <div v-else class="list-group list-group-flush">
                <div
                  v-for="iga in recentInterestGroupAdmins"
                  :key="iga.id"
                  class="list-group-item d-flex justify-content-between align-items-center"
                >
                  <div>
                    <h6 class="mb-1">{{ iga.full_name }}</h6>
                    <small class="text-muted">{{ iga.gmail_id }}</small>
                  </div>
                  <span class="badge bg-warning">Pending</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </AppLayout>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import AppLayout from '@/components/common/AppLayout.vue'
import StatCard from '@/components/ui/StatCard.vue'
import { useAdminStore } from '@/stores/admin'
import { useRouter } from 'vue-router'

const adminStore = useAdminStore()
const router = useRouter()

const recentUsers = computed(() => adminStore.users.slice(0, 5))
const recentCaregivers = computed(() => adminStore.pendingCaregivers.slice(0, 5))
const recentInterestGroupAdmins = computed(() => adminStore.pendingInterestGroupAdmins.slice(0, 5))

const getStatusColor = (status) => {
  const colors = {
    active: 'success',
    pending_approval: 'warning',
    blocked: 'danger',
  }
  return colors[status] || 'secondary'
}

const formatUserStatus = (status) => {
  const statusMap = {
    active: 'Active',
    pending_approval: 'Pending',
    blocked: 'Blocked',
  }
  return statusMap[status] || status
}

// Navigation functions
const goToInterestGroups = () => {
  router.push('/admin/interest-groups')
}

const goToIGAApprovals = () => {
  router.push('/admin/interest-group-admins/approvals')
}

const goToCaregiverApprovals = () => {
  router.push('/caregivers/approvals')
}

const goToNotifications = () => {
  router.push('/notifications')
}

onMounted(async () => {
  // Load admin data - authentication will be handled by API calls
  await Promise.all([
    adminStore.fetchAdminStats(),
    adminStore.fetchUsers(),
    adminStore.fetchCaregivers(),
    adminStore.fetchInterestGroupAdmins(),
  ])
})
</script>
