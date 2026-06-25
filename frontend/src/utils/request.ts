import axios, { type AxiosError, type AxiosRequestConfig } from 'axios'
import { ElMessage } from 'element-plus'

import router from '@/router'
import { normalizeApiBaseUrl } from '@/utils/api-base-url'
import { emitAuthEvent } from '@/utils/auth-events'

type ApiResponse<T> = {
  code: number
  message: string
  data: T
}

const AUTH_STORAGE_KEY = 'finance_auth_state'

function getStoredToken() {
  const raw = localStorage.getItem(AUTH_STORAGE_KEY)
  if (!raw) {
    return ''
  }
  try {
    const parsed = JSON.parse(raw) as { token?: string; tokenHead?: string }
    if (!parsed.token) {
      return ''
    }
    return `${parsed.tokenHead || 'Bearer '}${parsed.token}`
  } catch {
    return ''
  }
}

function clearAuth() {
  localStorage.removeItem(AUTH_STORAGE_KEY)
}

const service = axios.create({
  baseURL: normalizeApiBaseUrl(import.meta.env.VITE_APP_BASE_API),
  timeout: 15000
})

service.interceptors.request.use((config) => {
  const authorization = getStoredToken()
  if (authorization) {
    config.headers.Authorization = authorization
  }
  return config
})

service.interceptors.response.use(
  (response) => response,
  (error: AxiosError<ApiResponse<unknown>>) => {
    const status = error.response?.status
    const message = error.response?.data?.message || error.message || '请求失败'
    if (status === 401) {
      ElMessage.error('登录已失效，请重新登录')
      clearAuth()
      emitAuthEvent('logout', { reason: 'unauthorized' })
      return Promise.reject(error)
    }
    if (status === 403) {
      ElMessage.error('无权限访问')
      void router.push('/403')
      return Promise.reject(error)
    }
    ElMessage.error(message)
    return Promise.reject(error)
  }
)

async function request<T>(config: AxiosRequestConfig) {
  const response = await service.request<ApiResponse<T>>(config)
  const result = response.data
  if (result.code !== 0) {
    ElMessage.error(result.message || '请求失败')
    return Promise.reject(new Error(result.message || '请求失败'))
  }
  return result.data
}

request.get = function <T>(url: string, config?: AxiosRequestConfig) {
  return request<T>({
    ...config,
    method: 'GET',
    url
  })
}

request.post = function <T>(url: string, data?: unknown, config?: AxiosRequestConfig) {
  return request<T>({
    ...config,
    method: 'POST',
    url,
    data
  })
}

request.put = function <T>(url: string, data?: unknown, config?: AxiosRequestConfig) {
  return request<T>({
    ...config,
    method: 'PUT',
    url,
    data
  })
}

export default request as typeof request & {
  get: <T>(url: string, config?: AxiosRequestConfig) => Promise<T>
  post: <T>(url: string, data?: unknown, config?: AxiosRequestConfig) => Promise<T>
  put: <T>(url: string, data?: unknown, config?: AxiosRequestConfig) => Promise<T>
}
export { AUTH_STORAGE_KEY }
