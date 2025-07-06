import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/auth/LoginPage.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/role-selection',
    name: 'RoleSelection',
    component: () => import('@/views/auth/RoleSelectionPage.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/',
    redirect: '/role-selection'
  },
  
  // Admin Routes
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('@/views/admin/DashboardPage.vue'),
    meta: { requiresAuth: true, role: 'admin' }
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('@/views/admin/ProfilePage.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/officials',
    name: 'ManageOfficials',
    component: () => import('@/views/admin/ManageOfficialsPage.vue'),
    meta: { requiresAuth: true, role: 'admin' }
  },
  {
    path: '/notifications',
    name: 'Notifications',
    component: () => import('@/views/admin/NotificationsPage.vue'),
    meta: { requiresAuth: true, role: 'admin' }
  },
  {
    path: '/tickets',
    name: 'TicketsList',
    component: () => import('@/views/support/TicketsListPage.vue'),
    meta: { requiresAuth: true, role: 'admin' }
  },
  {
    path: '/tickets/:id',
    name: 'TicketDetail',
    component: () => import('@/views/support/TicketDetailPage.vue'),
    meta: { requiresAuth: true, role: 'admin' }
  },
  {
    path: '/iga/register',
    name: 'IGARegister',
    component: () => import('@/views/iga/RegisterPage.vue'),
    meta: { requiresAuth: true, role: 'admin' }
  },
  {
    path: '/iga/groups',
    name: 'IGAManageGroups',
    component: () => import('@/views/iga/ManageGroupsPage.vue'),
    meta: { requiresAuth: true, role: 'admin' }
  },
  {
    path: '/caregivers/approvals',
    name: 'CaregiverApprovals',
    component: () => import('@/views/caregivers/CaregiverApprovalsPage.vue'),
    meta: { requiresAuth: true, role: 'admin' }
  },
  {
    path: '/caregivers',
    name: 'CaregiverList',
    component: () => import('@/views/caregivers/CaregiverListPage.vue'),
    meta: { requiresAuth: true, role: 'admin' }
  },

  // Support User Routes
  {
    path: '/support/dashboard',
    name: 'SupportDashboard',
    component: () => import('@/views/support/SupportDashboardPage.vue'),
    meta: { requiresAuth: true, role: 'support' }
  },

  // Interest Group Admin Routes
  {
    path: '/iga/dashboard',
    name: 'IGADashboard',
    component: () => import('@/views/iga/IGADashboardPage.vue'),
    meta: { requiresAuth: true, role: 'iga' }
  },

  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    redirect: '/role-selection'
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

// Navigation guard
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  
  // If route requires auth and user is not authenticated
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
    return
  }
  
  // If user is authenticated but trying to access login
  if (to.path === '/login' && authStore.isAuthenticated) {
    next('/role-selection')
    return
  }
  
  // If route requires specific role
  if (to.meta.role && authStore.user?.selectedRole !== to.meta.role) {
    // Only redirect if user has a selected role but it's wrong
    if (authStore.user?.selectedRole) {
      switch(authStore.user.selectedRole) {
        case 'admin':
          next('/dashboard')
          break
        case 'support':
          next('/support/dashboard')
          break
        case 'iga':
          next('/iga/dashboard')
          break
        default:
          next('/role-selection')
      }
      return
    }
    // If no role selected, go to role selection
    next('/role-selection')
    return
  }
  
  next()
})

export default router