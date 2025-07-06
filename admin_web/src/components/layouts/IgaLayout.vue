<template>
  <div>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm">
      <div class="container-fluid">
        <a class="navbar-brand fw-bold text-success" href="#">
          <i class="bi bi-heart-fill text-danger"></i>
          2nd Innings - IGA
        </a>
        
        <div class="ms-auto d-flex align-items-center gap-3">
          <!-- Profile Dropdown -->
          <div class="dropdown">
            <a 
              class="d-flex align-items-center text-decoration-none dropdown-toggle" 
              href="#" 
              role="button" 
              data-bs-toggle="dropdown"
            >
              <img 
                :src="user?.profileImage || `https://ui-avatars.com/api/?name=${user?.name}`" 
                :alt="user?.name" 
                class="avatar me-2"
              >
              <span class="text-dark">{{ user?.name }}</span>
            </a>
            
            <ul class="dropdown-menu dropdown-menu-end">
              <li>
                <router-link to="/profile" class="dropdown-item">
                  <i class="bi bi-person me-2"></i>Profile
                </router-link>
              </li>
              <li>
                <router-link to="/role-selection" class="dropdown-item">
                  <i class="bi bi-arrow-left-right me-2"></i>Switch Role
                </router-link>
              </li>
              <li><hr class="dropdown-divider"></li>
              <li>
                <a href="#" @click.prevent="handleLogout" class="dropdown-item text-danger">
                  <i class="bi bi-box-arrow-right me-2"></i>Logout
                </a>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </nav>
    
    <!-- Main Layout -->
    <div class="d-flex">
      <!-- Sidebar -->
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
      
      <!-- Main Content -->
      <main class="main-content">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const user = computed(() => authStore.user)

const menuItems = [
  { name: 'Dashboard', path: '/iga/dashboard', icon: 'bi bi-speedometer2' },
  { name: 'My Groups', path: '/iga/groups', icon: 'bi bi-people' },
  { name: 'Profile', path: '/profile', icon: 'bi bi-person' }
]

const handleLogout = async () => {
  await authStore.logout()
  router.push('/login')
}
</script>