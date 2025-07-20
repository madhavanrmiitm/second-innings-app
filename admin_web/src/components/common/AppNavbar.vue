<template>
  <nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm">
    <div class="container-fluid">
      <a class="navbar-brand fw-bold text-success" href="#">
        <i class="bi bi-heart-fill text-danger"></i>
        {{ brandText }}
      </a>

      <div class="ms-auto d-flex align-items-center gap-3">
        <!-- Notifications (Admin only) -->
        <router-link
          v-if="showNotifications"
          to="/notifications"
          class="position-relative text-decoration-none text-dark"
        >
          <i class="bi bi-bell fs-5"></i>
          <span
            v-if="unreadCount > 0"
            class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger"
          >
            {{ unreadCount }}
          </span>
        </router-link>

        <!-- Profile Dropdown -->
        <div class="dropdown">
          <a
            class="d-flex align-items-center text-decoration-none dropdown-toggle"
            href="#"
            role="button"
            data-bs-toggle="dropdown"
          >
            <img
              :src="
                user?.profileImage ||
                `https://ui-avatars.com/api/?name=${user?.full_name || user?.name}`
              "
              :alt="user?.full_name || user?.name"
              class="avatar me-2"
            />
            <span class="text-dark">{{ user?.full_name || user?.name }}</span>
          </a>

          <ul class="dropdown-menu dropdown-menu-end">
            <li>
              <router-link to="/profile" class="dropdown-item">
                <i class="bi bi-person me-2"></i>Profile
              </router-link>
            </li>
            <li><hr class="dropdown-divider" /></li>
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
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useNotificationsStore } from '@/stores/notifications'

// Props
const props = defineProps({
  brandText: {
    type: String,
    default: '2nd Innings Admin',
  },
  showNotifications: {
    type: Boolean,
    default: false,
  },
})

const router = useRouter()
const authStore = useAuthStore()
const notificationsStore = useNotificationsStore()

const user = computed(() => authStore.user)
const unreadCount = computed(() => notificationsStore.unreadCount)

const handleLogout = async () => {
  await authStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  object-fit: cover;
}
</style>
