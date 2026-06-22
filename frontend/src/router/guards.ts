import type { Router } from 'vue-router'

import { useUserStore } from '@/stores/user'

export function setupRouterGuards(router: Router) {
  let restoring = false

  router.beforeEach(async (to) => {
    const userStore = useUserStore()
    const requiresAuth = Boolean(to.meta.requiresAuth)
    const guestOnly = Boolean(to.meta.guestOnly)
    const requiredRoles = (to.meta.roles as string[] | undefined) ?? []

    if (userStore.token && !userStore.userInfo && !restoring) {
      restoring = true
      try {
        await userStore.restoreSession()
      } catch {
        await userStore.logout(false)
        restoring = false
        return {
          path: '/login',
          query: { redirect: to.fullPath }
        }
      } finally {
        restoring = false
      }
    }

    if (guestOnly && userStore.isLoggedIn) {
      return '/'
    }

    if (requiresAuth && !userStore.isLoggedIn) {
      return {
        path: '/login',
        query: { redirect: to.fullPath }
      }
    }

    if (requiresAuth && requiredRoles.length > 0 && !userStore.hasAnyRole(requiredRoles)) {
      return '/403'
    }

    return true
  })
}
