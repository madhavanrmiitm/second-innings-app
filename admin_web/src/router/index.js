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
    path: '/',
    redirect: '/dashboard'
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('@/views/admin/DashboardPage.vue'),
    meta: { requiresAuth: true }
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
    meta: { requiresAuth: true }
  },
  {
    path: '/tickets',
    name: 'TicketsList',
    component: () => import('@/views/support/TicketsListPage.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/tickets/:id',
    name: 'TicketDetail',
    component: () => import('@/views/support/TicketDetailPage.vue'),
    meta: { requiresAuth: true }
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
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    redirect: '/dashboard'
  },
  {
    path: '/caregivers/approvals',
    name: 'CaregiverApprovals',
    component: () => import('@/views/caregivers/CaregiverApprovalsPage.vue'),
    meta: { requiresAuth: true }
  },
    {
    path: '/caregivers',
    name: 'CaregiverList',
    component: () => import('@/views/caregivers/CaregiverListPage.vue'),
    meta: { requiresAuth: true }
  }

]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

// Navigation guard
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
  } else if (to.meta.role && authStore.userRole !== to.meta.role) {
    next('/dashboard')
  } else if (to.path === '/login' && authStore.isAuthenticated) {
    next('/dashboard')
  } else {
    next()
  }
})

export default router