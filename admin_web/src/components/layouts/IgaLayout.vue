<template>
  <div>
    <!-- Navbar -->
    <AppNavbar brand-text="2nd Innings - IGA" :show-notifications="false" />

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
import AppNavbar from '@/components/common/AppNavbar.vue'
import AppSidebar from '@/components/common/AppSidebar.vue'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

// Check if user can access group management features
const canAccessGroups = computed(() => {
  return authStore.canAccess && authStore.userStatus === 'active'
})

// Dynamic menu items based on user status
const menuItems = computed(() => {
  const baseItems = [{ name: 'Dashboard', path: '/iga/dashboard', icon: 'bi bi-speedometer2' }]

  // Only show group management for active users
  if (canAccessGroups.value) {
    baseItems.push({ name: 'My Groups', path: '/iga/groups', icon: 'bi bi-people' })
  }

  // Profile is always accessible
  baseItems.push({ name: 'Profile', path: '/profile', icon: 'bi bi-person' })

  return baseItems
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
