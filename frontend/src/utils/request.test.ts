import { describe, it, expect, vi, beforeEach } from 'vitest'
import { normalizeApiBaseUrl } from './api-base-url'
import request, { AUTH_STORAGE_KEY } from './request'

// Mock axios before importing
vi.mock('axios', () => {
  const mockAxiosInstance = {
    interceptors: {
      request: { use: vi.fn() },
      response: { use: vi.fn() }
    },
    request: vi.fn(),
    get: vi.fn(),
    post: vi.fn(),
    put: vi.fn(),
    delete: vi.fn()
  }

  const mockAxios = Object.assign(
    vi.fn(() => mockAxiosInstance),
    {
      create: vi.fn(() => mockAxiosInstance),
      defaults: {}
    }
  )

  return { default: mockAxios }
})

describe('request utility', () => {
  beforeEach(() => {
    localStorage.clear()
  })

  it('should expose AUTH_STORAGE_KEY', () => {
    expect(AUTH_STORAGE_KEY).toBe('finance_auth_state')
  })

  it('should inject Authorization header from stored token', async () => {
    const authState = {
      token: 'test-token',
      tokenHead: 'Bearer ',
      userInfo: { id: 1, username: 'test', nickname: 'Test' },
      roles: ['USER']
    }
    localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(authState))

    const axiosModule = await import('axios')
    const mockService = axiosModule.default.create()

    // Simulate the request interceptor
    const requestInterceptor = mockService.interceptors.request.use
    expect(requestInterceptor).toHaveBeenCalled()

    // Get the interceptor handler
    const interceptorFn = requestInterceptor.mock.calls[0][0]

    const config = interceptorFn({ headers: {} })
    expect(config.headers.Authorization).toBe('Bearer test-token')
  })

  it('should not inject Authorization header without stored token', async () => {
    const axiosModule = await import('axios')
    const mockService = axiosModule.default.create()
    const interceptorFn = mockService.interceptors.request.use.mock.calls[0][0]

    const config = interceptorFn({ headers: {} })
    expect(config.headers.Authorization).toBeUndefined()
  })

  it('should handle token with custom tokenHead', async () => {
    const authState = {
      token: 'custom-token',
      tokenHead: 'JWT ',
      userInfo: null,
      roles: []
    }
    localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(authState))

    const axiosModule = await import('axios')
    const mockService = axiosModule.default.create()
    const interceptorFn = mockService.interceptors.request.use.mock.calls[0][0]

    const config = interceptorFn({ headers: {} })
    expect(config.headers.Authorization).toBe('JWT custom-token')
  })

  it('should clear auth on 401 response', async () => {
    localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify({
      token: 'some-token',
      tokenHead: 'Bearer ',
      userInfo: null,
      roles: []
    }))

    const axiosModule = await import('axios')
    const mockService = axiosModule.default.create()
    const responseInterceptor = mockService.interceptors.response.use
    const errorHandler = responseInterceptor.mock.calls[0][1]

    const error = {
      response: { status: 401, data: { message: 'token expired' } },
      message: 'Request failed'
    }

    await expect(errorHandler(error)).rejects.toEqual(error)
    expect(localStorage.getItem(AUTH_STORAGE_KEY)).toBeNull()
  })

  it('should not clear auth on non-401 errors', async () => {
    localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify({
      token: 'some-token',
      tokenHead: 'Bearer ',
      userInfo: null,
      roles: []
    }))

    const axiosModule = await import('axios')
    const mockService = axiosModule.default.create()
    const responseInterceptor = mockService.interceptors.response.use
    const errorHandler = responseInterceptor.mock.calls[0][1]

    const error = {
      response: { status: 500, data: { message: 'server error' } },
      message: 'Server error'
    }

    await expect(errorHandler(error)).rejects.toEqual(error)
    expect(localStorage.getItem(AUTH_STORAGE_KEY)).toBeTruthy()
  })
})
