import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/auth/LoginPage.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/register',
    name: 'Registration',
    component: () => import('@/views/auth/RegistrationPage.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/role-selection',
    name: 'RoleSelection',
    component: () => import('@/views/auth/RoleSelectionPage.vue'),
    meta: { requiresAuth: true },
  },
  {
    path: '/',
    name: 'Home',
    redirect: '/login',
    meta: { isRoot: true },
  },

  // Admin Routes
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: () => import('@/views/admin/DashboardPage.vue'),
    meta: { requiresAuth: true, role: 'admin' },
  },
  {
    path: '/officials',
    name: 'ManageOfficials',
    component: () => import('@/views/admin/ManageOfficialsPage.vue'),
    meta: { requiresAuth: true, role: 'admin' },
  },
  {
    path: '/notifications',
    name: 'Notifications',
    component: () => import('@/views/admin/NotificationsPage.vue'),
    meta: { requiresAuth: true, role: 'admin' },
  },
  {
    path: '/caregivers/approvals',
    name: 'CaregiverApprovals',
    component: () => import('@/views/caregivers/CaregiverApprovalsPage.vue'),
    meta: { requiresAuth: true, role: 'admin' },
  },
  {
    path: '/caregivers',
    name: 'CaregiverList',
    component: () => import('@/views/caregivers/CaregiverListPage.vue'),
    meta: { requiresAuth: true, role: 'admin' },
  },
  {
    path: '/admin/interest-group-admins/approvals',
    name: 'InterestGroupAdminApprovals',
    component: () => import('@/views/admin/InterestGroupAdminApprovalsPage.vue'),
    meta: { requiresAuth: true, role: 'admin' },
  },
  {
    path: '/admin/interest-group-admins',
    name: 'InterestGroupAdminList',
    component: () => import('@/views/admin/InterestGroupAdminListPage.vue'),
    meta: { requiresAuth: true, role: 'admin' },
  },
  {
    path: '/admin/interest-groups',
    name: 'AdminManageInterestGroups',
    component: () => import('@/views/iga/ManageGroupsPage.vue'),
    meta: { requiresAuth: true, role: 'admin' },
  },

  // Shared Routes (accessible to admin and support)
  {
    path: '/tickets',
    name: 'TicketsList',
    component: () => import('@/views/support/TicketsListPage.vue'),
    meta: { requiresAuth: true, roles: ['admin', 'support'] },
  },
  {
    path: '/tickets/:id',
    name: 'TicketDetail',
    component: () => import('@/views/support/TicketDetailPage.vue'),
    meta: { requiresAuth: true, roles: ['admin', 'support'] },
  },

  // Profile (accessible to all authenticated users)
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('@/views/admin/ProfilePage.vue'),
    meta: { requiresAuth: true },
  },

  // Support User Routes
  {
    path: '/support/dashboard',
    name: 'SupportDashboard',
    component: () => import('@/views/support/SupportDashboardPage.vue'),
    meta: { requiresAuth: true, role: 'support' },
  },

  // Interest Group Admin Routes
  {
    path: '/iga/dashboard',
    name: 'IGADashboard',
    component: () => import('@/views/iga/IgaDashboardPage.vue'),
    meta: { requiresAuth: true, role: 'iga' },
  },
  {
    path: '/iga/groups',
    name: 'IGAManageGroups',
    component: () => import('@/views/iga/ManageGroupsPage.vue'),
    meta: { requiresAuth: true, role: 'iga' },
  },

  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    redirect: '/role-selection',
  },
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
})

// Navigation guard
router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()

  // Special handling for root route - redirect authenticated users to their dashboard
  if (to.meta.isRoot && authStore.isAuthenticated) {
    const userRole = authStore.userRole
    switch (userRole) {
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

  // If route requires auth and user is not authenticated
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
    return
  }

  // If user is authenticated but trying to access login
  if (to.path === '/login' && authStore.isAuthenticated) {
    // Redirect based on user role
    const userRole = authStore.userRole
    switch (userRole) {
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

  // Check role-based access
  const userRole = authStore.userRole
  const routeRole = to.meta.role
  const routeRoles = to.meta.roles

  // If route requires specific role(s)
  if (routeRole || routeRoles) {
    // Check if user status allows access
    if (authStore.isBlocked) {
      // User is blocked, redirect to login and clear session
      await authStore.logout()
      next('/login')
      return
    }

    // Allow both active and pending_approval users to access
    // pending_approval users will have restricted functionality in UI
    if (!authStore.canAccess && !authStore.isPendingApproval) {
      // User has invalid status, redirect to login
      await authStore.logout()
      next('/login')
      return
    }

    // Check if user has the required role
    let hasAccess = false
    if (routeRole) {
      hasAccess = userRole === routeRole
    } else if (routeRoles) {
      hasAccess = routeRoles.includes(userRole)
    }

    if (!hasAccess) {
      // Redirect to appropriate dashboard based on user role
      if (userRole) {
        switch (userRole) {
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
      // If no role, go to role selection
      next('/role-selection')
      return
    }
  }

  next()
})

export default router
