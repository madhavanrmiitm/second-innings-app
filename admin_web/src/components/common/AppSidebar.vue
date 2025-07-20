<template>
  <nav class="sidebar">
    <div class="p-3">
      <ul class="nav flex-column">
        <li class="nav-item" v-for="item in menuItems" :key="item.path">
          <router-link :to="item.path" class="nav-link">
            <i :class="item.icon"></i>
            {{ item.name }}
          </router-link>
        </li>
      </ul>
    </div>
  </nav>
</template>

<script setup>
// Props
const props = defineProps({
  menuItems: {
    type: Array,
    required: true,
    default: () => [],
  },
})
</script>

<style scoped>
/* Sidebar styles */
.sidebar {
  width: 250px;
  min-height: calc(100vh - 56px);
  background-color: #f8f9fa;
  border-right: 1px solid #dee2e6;
}

.nav-link {
  color: #495057;
  padding: 0.75rem 1rem;
  border-radius: 0.375rem;
  margin-bottom: 0.125rem;
  transition: all 0.15s ease-in-out;
}

.nav-link:hover {
  background-color: #e9ecef;
  color: #212529;
}

.nav-link.router-link-active {
  background-color: #16a34a;
  color: white;
}

.nav-link i {
  margin-right: 0.5rem;
  width: 1rem;
}
</style>
