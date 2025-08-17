<template>
  <div>
    <!-- Navbar -->
    <AppNavbar
      brand-text="2nd Innings Admin"
      :show-notifications="authStore.userRole === 'admin'"
    />

    <!-- Main Layout -->
    <div class="d-flex">
      <!-- Sidebar -->
      <AppSidebar :menu-items="menuItems" />

      <!-- Main Content -->
      <main class="main-content">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import AppNavbar from './AppNavbar.vue'
import AppSidebar from './AppSidebar.vue'

const authStore = useAuthStore()

// Role-specific menu items
const menuItems = computed(() => {
  const userRole = authStore.userRole

  switch (userRole) {
    case 'admin':
      return [
        { name: 'Dashboard', path: '/dashboard', icon: 'bi bi-speedometer2' },
        { name: 'Manage Officials', path: '/officials', icon: 'bi bi-people' },
        { name: 'View Tickets', path: '/tickets', icon: 'bi bi-ticket-perforated' },
        { name: 'Interest Groups', path: '/admin/interest-groups', icon: 'bi bi-collection' },
        { name: 'Approve Caregivers', path: '/caregivers/approvals', icon: 'bi bi-heart' },
        { name: 'Interest Group Admins', path: '/admin/interest-group-admins/approvals', icon: 'bi bi-people-fill' },
        { name: 'Notifications', path: '/notifications', icon: 'bi bi-bell' },
        { name: 'Profile', path: '/profile', icon: 'bi bi-person' },
      ]
    case 'support':
      return [
        { name: 'Dashboard', path: '/support/dashboard', icon: 'bi bi-speedometer2' },
        { name: 'Support Tickets', path: '/tickets', icon: 'bi bi-ticket-perforated' },
        { name: 'Profile', path: '/profile', icon: 'bi bi-person' },
      ]
    case 'iga':
      return [
        { name: 'Dashboard', path: '/iga/dashboard', icon: 'bi bi-speedometer2' },
        { name: 'Manage Groups', path: '/iga/groups', icon: 'bi bi-people' },
        { name: 'Profile', path: '/profile', icon: 'bi bi-person' },
      ]
    default:
      return []
  }
})
</script>

<style scoped>
.main-content {
  flex: 1;
  padding: 2rem;
  background-color: #f5f5f5;
  min-height: calc(100vh - 56px);
  overflow-y: auto;
}

@media (max-width: 768px) {
  .main-content {
    padding: 1rem;
  }
}
</style>
