<template>
  <div>
    <!-- Navbar -->
    <AppNavbar brand-text="2nd Innings - Support" :show-notifications="false" />

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
import AppNavbar from '@/components/common/AppNavbar.vue'
import AppSidebar from '@/components/common/AppSidebar.vue'

const menuItems = [
  { name: 'Dashboard', path: '/support/dashboard', icon: 'bi bi-speedometer2' },
  { name: 'Support Tickets', path: '/tickets', icon: 'bi bi-ticket-perforated' },
  { name: 'Profile', path: '/profile', icon: 'bi bi-person' },
]
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
