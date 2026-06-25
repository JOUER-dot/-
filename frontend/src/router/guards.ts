import type { Router } from 'vue-router'

import { useUserStore } from '@/stores/user'
import { getDefaultHomeByRoles } from '@/utils/role-home'

export function setupRouterGuards(router: Router) {
  let restoring = false

  router.beforeEach(async (to, from) => {
    const userStore = useUserStore()
    const requiresAuth = Boolean(to.meta.requiresAuth)
    const guestOnly = Boolean(to.meta.guestOnly)
    const requiredRoles = (to.meta.roles as string[] | undefined) ?? []
    const isInitialNavigation = !from.name

    if (isInitialNavigation && to.path === '/') {
      if (userStore.token && !userStore.userInfo && !restoring) {
        restoring = true
        try {
          await userStore.restoreSession()
        } catch {
          await userStore.logout(false)
        } finally {
          restoring = false
        }
      }
      if (userStore.isLoggedIn) {
        return getDefaultHomeByRoles(userStore.roles)
      }
      return '/advisor-zone'
    }

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
      return getDefaultHomeByRoles(userStore.roles)
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
