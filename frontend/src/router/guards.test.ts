import { describe, it, expect, beforeEach, vi } from 'vitest'
import type { Router } from 'vue-router'

// Mock user store
const mockLogout = vi.fn()
const mockRestoreSession = vi.fn()
vi.mock('@/stores/user', () => ({
  useUserStore: vi.fn(() => ({
    token: 'test-token',
    userInfo: { id: 1, username: 'test', nickname: 'Test' },
    roles: ['USER'],
    isLoggedIn: true,
    hasAnyRole: (roles: string[]) => roles.length === 0 || roles.includes('USER'),
    restoreSession: mockRestoreSession,
    logout: mockLogout
  }))
}))

// Mock role-home
vi.mock('@/utils/role-home', () => ({
  getDefaultHomeByRoles: vi.fn((roles: string[]) => {
    if (roles.includes('USER')) return '/advisor-zone'
    if (roles.includes('ADVISOR')) return '/admin/products'
    if (roles.includes('REVIEWER')) return '/review/pending'
    return '/'
  })
}))

import { setupRouterGuards } from '@/router/guards'

describe('router guards', () => {
  let mockRouter: Router

  beforeEach(() => {
    vi.clearAllMocks()
    mockRouter = {
      beforeEach: vi.fn()
    } as unknown as Router
  })

  it('should register a beforeEach guard', () => {
    setupRouterGuards(mockRouter)
    expect(mockRouter.beforeEach).toHaveBeenCalledTimes(1)
    expect(typeof (mockRouter.beforeEach as any).mock.calls[0][0]).toBe('function')
  })

  it('should redirect authenticated user to default home on initial navigation to /', async () => {
    setupRouterGuards(mockRouter)
    const guard = (mockRouter.beforeEach as any).mock.calls[0][0]

    const to = { path: '/', meta: {} }
    const from = { name: null } // isInitialNavigation = true
    const result = await guard(to, from)

    expect(result).toBe('/advisor-zone')
  })

  it('should redirect unauthenticated user to /advisor-zone on initial navigation', async () => {
    // Override the mock for this test
    const userStore = await import('@/stores/user')
    ;(userStore.useUserStore as any).mockReturnValue({
      token: '',
      userInfo: null,
      roles: [],
      isLoggedIn: false,
      hasAnyRole: () => true,
      restoreSession: mockRestoreSession,
      logout: mockLogout
    })

    setupRouterGuards(mockRouter)
    const guard = (mockRouter.beforeEach as any).mock.calls[0][0]

    const to = { path: '/', meta: {} }
    const from = { name: null }
    const result = await guard(to, from)

    expect(result).toBe('/advisor-zone')
  })

  it('should redirect guest-only page to home when already logged in', async () => {
    setupRouterGuards(mockRouter)
    const guard = (mockRouter.beforeEach as any).mock.calls[0][0]

    const to = { path: '/login', meta: { guestOnly: true } }
    const from = { name: 'some-route' }
    const result = await guard(to, from)

    expect(result).toBe('/advisor-zone')
  })

  it('should redirect to login when auth required and not logged in', async () => {
    const userStore = await import('@/stores/user')
    ;(userStore.useUserStore as any).mockReturnValue({
      token: '',
      userInfo: null,
      roles: [],
      isLoggedIn: false,
      hasAnyRole: () => false,
      restoreSession: mockRestoreSession,
      logout: mockLogout
    })

    setupRouterGuards(mockRouter)
    const guard = (mockRouter.beforeEach as any).mock.calls[0][0]

    const to = { path: '/dashboard', meta: { requiresAuth: true }, fullPath: '/dashboard' }
    const from = { name: 'some-route' }
    const result = await guard(to, from)

    expect(result).toEqual({ path: '/login', query: { redirect: '/dashboard' } })
  })

  it('should redirect to /403 when user lacks required roles', async () => {
    const userStore = await import('@/stores/user')
    ;(userStore.useUserStore as any).mockReturnValue({
      token: 't',
      userInfo: { id: 1, username: 'u', nickname: 'n' },
      roles: ['USER'],
      isLoggedIn: true,
      hasAnyRole: (roles: string[]) => roles.length === 0 || roles.includes('USER'),
      restoreSession: mockRestoreSession,
      logout: mockLogout
    })

    setupRouterGuards(mockRouter)
    const guard = (mockRouter.beforeEach as any).mock.calls[0][0]

    const to = { path: '/admin', meta: { requiresAuth: true, roles: ['ADMIN'] } }
    const from = { name: 'some-route' }
    const result = await guard(to, from)

    expect(result).toBe('/403')
  })

  it('should allow navigation when all conditions pass', async () => {
    setupRouterGuards(mockRouter)
    const guard = (mockRouter.beforeEach as any).mock.calls[0][0]

    const to = { path: '/dashboard', meta: { requiresAuth: true } }
    const from = { name: 'some-route' }
    const result = await guard(to, from)

    expect(result).toBe(true)
  })

  it('should restore session when token exists but userInfo missing', async () => {
    const userStore = await import('@/stores/user')
    mockRestoreSession.mockResolvedValue({ id: 1 })

    ;(userStore.useUserStore as any).mockReturnValue({
      token: 't',
      userInfo: null,
      roles: [],
      isLoggedIn: true,
      hasAnyRole: () => true,
      restoreSession: mockRestoreSession,
      logout: mockLogout
    })

    setupRouterGuards(mockRouter)
    const guard = (mockRouter.beforeEach as any).mock.calls[0][0]

    const to = { path: '/dashboard', meta: { requiresAuth: true } }
    const from = { name: 'some-route' }
    await guard(to, from)

    expect(mockRestoreSession).toHaveBeenCalled()
  })

  it('should redirect to login when session restore fails', async () => {
    const userStore = await import('@/stores/user')
    mockRestoreSession.mockRejectedValue(new Error('unauthorized'))

    ;(userStore.useUserStore as any).mockReturnValue({
      token: 't',
      userInfo: null,
      roles: [],
      isLoggedIn: false,
      hasAnyRole: () => true,
      restoreSession: mockRestoreSession,
      logout: mockLogout
    })

    setupRouterGuards(mockRouter)
    const guard = (mockRouter.beforeEach as any).mock.calls[0][0]

    const to = { path: '/dashboard', meta: { requiresAuth: true }, fullPath: '/dashboard' }
    const from = { name: 'some-route' }
    const result = await guard(to, from)

    expect(mockLogout).toHaveBeenCalledWith(false)
    expect(result).toEqual({ path: '/login', query: { redirect: '/dashboard' } })
  })
})
