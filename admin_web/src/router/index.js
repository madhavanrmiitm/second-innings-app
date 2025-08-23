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
    component: () => import('@/views/admin/AdminInterestGroupsPage.vue'),
    meta: { requiresAuth: true, role: 'admin' },
  },
  {
    path: '/admin/interest-groups/:groupId/members',
    name: 'AdminGroupMembers',
    component: () => import('@/views/iga/GroupMembersPage.vue'),
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
    path: '/iga/my-groups',
    name: 'IGAMyGroups',
    component: () => import('@/views/iga/MyGroupsPage.vue'),
    meta: { requiresAuth: true, role: 'iga' },
  },
  {
    path: '/iga/groups/:groupId/members',
    name: 'IGAGroupMembers',
    component: () => import('@/views/iga/GroupMembersPage.vue'),
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

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()

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

  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
    return
  }

  if (to.path === '/login' && authStore.isAuthenticated) {
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

  const userRole = authStore.userRole
  const routeRole = to.meta.role
  const routeRoles = to.meta.roles

  if (routeRole || routeRoles) {
    if (authStore.isBlocked) {
      await authStore.logout()
      next('/login')
      return
    }

    if (!authStore.canAccess && !authStore.isPendingApproval) {
      await authStore.logout()
      next('/login')
      return
    }

    let hasAccess = false
    if (routeRole) {
      hasAccess = userRole === routeRole
    } else if (routeRoles) {
      hasAccess = routeRoles.includes(userRole)
    }

    if (!hasAccess) {
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
      next('/role-selection')
      return
    }
  }

  next()
})

export default router
