import request from '@/utils/request'

export interface AdminDashboard {
  totalProducts: number
  publishedProducts: number
  pendingReviewProducts: number
  totalAdvisors: number
  totalUsers: number
  totalSubscriptions: number
  topSubscribedProducts: Array<{
    productId: number
    productName: string
    subscriberCount: number
  }>
  recentChanges: Array<{
    productId: number
    productName: string
    actionType: string
    operatorName: string
    createdAt: string
  }>
}

export interface AdminUser {
  id: number
  username: string
  nickname: string
  phone: string
  email: string
  status: number
  roles: string[]
  createdAt: string
}

export function getAdminDashboard() {
  return request.get<AdminDashboard>('/admin/system/dashboard')
}

export function getAdvisorDashboard() {
  return request.get<AdminDashboard>('/admin/system/advisor/dashboard')
}

export function listAdminUsers() {
  return request.get<AdminUser[]>('/admin/system/users')
}

export function toggleUserStatus(userId: number, enabled: boolean) {
  return request.put<void>(`/admin/system/users/${userId}/status?enabled=${enabled}`)
}

export function assignUserRole(userId: number, roleCode: string) {
  return request.post<void>(`/admin/system/users/${userId}/assign-role?roleCode=${roleCode}`)
}

export function setUserRole(userId: number, roleCode: string) {
  return request.put<void>(`/admin/system/users/${userId}/role`, { roleCode })
}
