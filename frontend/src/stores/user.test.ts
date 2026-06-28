import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'

// Mock request module before importing store
vi.mock('@/utils/request', () => {
  const mockRequest: any = vi.fn()
  mockRequest.post = vi.fn()
  mockRequest.get = vi.fn()
  mockRequest.put = vi.fn()
  mockRequest.delete = vi.fn()
  mockRequest.default = mockRequest
  return { default: mockRequest, AUTH_STORAGE_KEY: 'finance_auth_state' }
})

describe('user store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    localStorage.clear()
  })

  afterEach(() => {
    vi.clearAllMocks()
  })

  it('should login and persist auth state', async () => {
    const requestModule = await import('@/utils/request')
    const mockRequest = requestModule.default

    const loginResponse = {
      token: 'jwt-token-123',
      tokenHead: 'Bearer ',
      userInfo: { id: 1, username: 'testuser', nickname: '测试用户' },
      roles: ['USER']
    }
    vi.mocked(mockRequest.post).mockResolvedValue(loginResponse)

    const { useUserStore } = await import('@/stores/user')
    const store = useUserStore()

    await store.login({ username: 'testuser', password: 'pass123' })

    expect(store.token).toBe('jwt-token-123')
    expect(store.tokenHead).toBe('Bearer ')
    expect(store.userInfo?.username).toBe('testuser')
    expect(store.roles).toEqual(['USER'])
    expect(store.isLoggedIn).toBe(true)

    // Verify persistence
    const persisted = localStorage.getItem('finance_auth_state')
    expect(persisted).toBeTruthy()
    const parsed = JSON.parse(persisted!)
    expect(parsed.token).toBe('jwt-token-123')
  })

  it('should logout and clear state', async () => {
    const requestModule = await import('@/utils/request')
    const mockRequest = requestModule.default

    // First login
    vi.mocked(mockRequest.post).mockResolvedValue({
      token: 'token',
      tokenHead: 'Bearer ',
      userInfo: { id: 1, username: 'u', nickname: 'U' },
      roles: ['USER']
    })

    const { useUserStore } = await import('@/stores/user')
    const store = useUserStore()
    await store.login({ username: 'u', password: 'p' })

    // Then logout
    vi.mocked(mockRequest.post).mockResolvedValue(undefined)
    await store.logout(true)

    expect(store.token).toBe('')
    expect(store.userInfo).toBeNull()
    expect(store.roles).toEqual([])
    expect(store.isLoggedIn).toBe(false)
    expect(localStorage.getItem('finance_auth_state')).toBeNull()
  })

  it('should restore session from persisted state', async () => {
    // Pre-populate localStorage
    localStorage.setItem('finance_auth_state', JSON.stringify({
      token: 'restored-token',
      tokenHead: 'Bearer ',
      userInfo: { id: 2, username: 'restored', nickname: '已恢复' },
      roles: ['ADVISOR']
    }))

    const { useUserStore } = await import('@/stores/user')
    const store = useUserStore()

    expect(store.token).toBe('restored-token')
    expect(store.userInfo?.username).toBe('restored')
    expect(store.roles).toEqual(['ADVISOR'])
    expect(store.isLoggedIn).toBe(true)
  })

  it('should restore session by calling API', async () => {
    localStorage.setItem('finance_auth_state', JSON.stringify({
      token: 'valid-token',
      tokenHead: 'Bearer ',
      userInfo: null,
      roles: []
    }))

    const requestModule = await import('@/utils/request')
    const mockRequest = requestModule.default
    vi.mocked(mockRequest.get).mockResolvedValue({
      id: 1,
      username: 'loaded',
      nickname: '已加载',
      roles: ['USER']
    })

    const { useUserStore } = await import('@/stores/user')
    const store = useUserStore()

    const result = await store.restoreSession()
    expect(result).toBeTruthy()
    expect(store.userInfo?.username).toBe('loaded')
    expect(store.roles).toEqual(['USER'])
  })

  it('should return null from restoreSession when no token', async () => {
    const { useUserStore } = await import('@/stores/user')
    const store = useUserStore()

    const result = await store.restoreSession()
    expect(result).toBeNull()
  })

  it('should check role permission with hasAnyRole', async () => {
    const requestModule = await import('@/utils/request')
    const mockRequest = requestModule.default
    vi.mocked(mockRequest.post).mockResolvedValue({
      token: 't',
      tokenHead: 'Bearer ',
      userInfo: { id: 1, username: 'u', nickname: 'U' },
      roles: ['ADVISOR', 'USER']
    })

    const { useUserStore } = await import('@/stores/user')
    const store = useUserStore()
    await store.login({ username: 'u', password: 'p' })

    expect(store.hasAnyRole(['ADVISOR'])).toBe(true)
    expect(store.hasAnyRole(['REVIEWER'])).toBe(false)
    expect(store.hasAnyRole(['USER', 'REVIEWER'])).toBe(true)
    expect(store.hasAnyRole([])).toBe(true)
    expect(store.hasAnyRole(['ADMIN'])).toBe(false)
  })

  it('should handle corrupted persisted state gracefully', async () => {
    localStorage.setItem('finance_auth_state', 'not-valid-json')

    // The store's readPersistedState catches JSON parse errors
    // and returns empty defaults
    const { useUserStore } = await import('@/stores/user')
    const store = useUserStore()
    expect(store.token).toBe('')
    expect(store.userInfo).toBeNull()
    expect(store.roles).toEqual([])
  })
})
