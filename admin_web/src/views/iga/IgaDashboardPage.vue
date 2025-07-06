<template>
  <IgaLayout>
    <div class="container-fluid">
      <!-- Header -->
      <div class="mb-4">
        <h1 class="h3 mb-0">Interest Group Admin Dashboard</h1>
        <p class="text-muted">Manage your groups and community activities</p>
      </div>

      <!-- Stats Grid -->
      <div class="row g-3 mb-4">
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="My Groups"
            :value="myGroups.length"
            icon="users"
            color="primary"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Total Members"
            :value="totalMembers"
            icon="user-check"
            color="success"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="Active Groups"
            :value="activeGroupsCount"
            icon="bell"
            color="info"
          />
        </div>
        <div class="col-12 col-sm-6 col-lg-3">
          <StatCard
            title="This Month Events"
            value="8"
            icon="ticket"
            color="warning"
          />
        </div>
      </div>

      <!-- My Groups -->
      <div class="row g-3">
        <div class="col-12">
          <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
              <h5 class="card-title mb-0">My Groups</h5>
              <button class="btn btn-success btn-sm">
                <i class="bi bi-plus-circle me-2"></i>Create Group
              </button>
            </div>
            <div class="card-body">
              <DataTable
                :columns="columns"
                :data="myGroups"
                :loading="loading"
                empty-message="No groups found"
              >
                <template #cell-group="{ item }">
                  <div class="d-flex align-items-center">
                    <div class="bg-primary bg-opacity-10 rounded-circle p-2 me-3">
                      <i :class="`bi bi-${getGroupIcon(item.category)} text-primary`"></i>
                    </div>
                    <div>
                      <div class="fw-medium">{{ item.name }}</div>
                      <small class="text-muted">{{ item.description }}</small>
                    </div>
                  </div>
                </template>
                
                <template #cell-status="{ item }">
                  <span :class="`badge bg-${item.active ? 'success' : 'secondary'}`">
                    {{ item.active ? 'Active' : 'Inactive' }}
                  </span>
                </template>
                
                <template #cell-members="{ item }">
                  <div class="text-center">
                    <strong>{{ item.members }}</strong>
                  </div>
                </template>
                
                <template #cell-actions="{ item }">
                  <div class="btn-group btn-group-sm">
                    <button 
                      @click="manageGroup(item)"
                      class="btn btn-outline-primary"
                    >
                      Manage
                    </button>
                    <button 
                      @click="viewMembers(item)"
                      class="btn btn-outline-info"
                    >
                      Members
                    </button>
                    <button 
                      @click="toggleStatus(item)"
                      :class="`btn btn-outline-${item.active ? 'warning' : 'success'}`"
                    >
                      {{ item.active ? 'Pause' : 'Activate' }}
                    </button>
                  </div>
                </template>
              </DataTable>
            </div>
          </div>
        </div>
      </div>
    </div>
  </IgaLayout>
</template>

<script setup>
import { ref, computed } from 'vue'
import IgaLayout from '@/components/layouts/IgaLayout.vue'
import StatCard from '@/components/ui/StatCard.vue'
import DataTable from '@/components/ui/DataTable.vue'
import { useToast } from 'vue-toast-notification'

const toast = useToast()
const loading = ref(false)

// Hardcoded groups data for current IGA
const myGroups = ref([
  {
    id: 1,
    name: 'Morning Yoga Group',
    description: 'Daily yoga sessions for seniors',
    category: 'health',
    members: 25,
    active: true,
    createdAt: '2024-01-15'
  },
  {
    id: 2,
    name: 'Book Reading Club',
    description: 'Weekly book discussions',
    category: 'education',
    members: 18,
    active: true,
    createdAt: '2024-02-20'
  },
  {
    id: 3,
    name: 'Garden Enthusiasts',
    description: 'Gardening tips and plant care',
    category: 'hobby',
    members: 32,
    active: false,
    createdAt: '2024-03-10'
  },
  {
    id: 4,
    name: 'Tech Learning Circle',
    description: 'Learn smartphones and internet',
    category: 'technology',
    members: 15,
    active: true,
    createdAt: '2024-04-05'
  }
])

const columns = [
  { key: 'group', label: 'Group' },
  { key: 'category', label: 'Category' },
  { key: 'members', label: 'Members' },
  { key: 'status', label: 'Status' },
  { key: 'actions', label: 'Actions', class: 'text-end' }
]

const totalMembers = computed(() => 
  myGroups.value.reduce((total, group) => total + group.members, 0)
)

const activeGroupsCount = computed(() => 
  myGroups.value.filter(g => g.active).length
)

const getGroupIcon = (category) => {
  const icons = {
    'health': 'heart',
    'education': 'book',
    'hobby': 'palette',
    'technology': 'laptop',
    'sports': 'trophy',
    'social': 'people'
  }
  return icons[category] || 'circle'
}

const manageGroup = (group) => {
  toast.info(`Managing group: ${group.name}`)
}

const viewMembers = (group) => {
  toast.info(`Viewing ${group.members} members of ${group.name}`)
}

const toggleStatus = (group) => {
  group.active = !group.active
  const status = group.active ? 'activated' : 'paused'
  toast.success(`Group ${group.name} has been ${status}`)
}
</script>