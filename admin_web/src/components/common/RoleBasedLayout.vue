<template>
  <component :is="currentLayout">
    <slot />
  </component>
</template>

<script setup>
import { computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import AppLayout from './AppLayout.vue'
import IgaLayout from '../layouts/IgaLayout.vue'
import SupportLayout from '../layouts/SupportLayout.vue'

const authStore = useAuthStore()

// Select the appropriate layout based on user role
const currentLayout = computed(() => {
  const userRole = authStore.userRole

  switch (userRole) {
    case 'admin':
      return AppLayout
    case 'support':
      return SupportLayout
    case 'iga':
      return IgaLayout
    default:
      return AppLayout // Fallback to AppLayout for unknown roles
  }
})
</script>
