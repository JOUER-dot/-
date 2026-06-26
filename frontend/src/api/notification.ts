import request from '@/utils/request'

export interface NotificationItem {
  id: number
  userId: number
  title: string
  content: string
  type: string
  read: boolean
  relatedUrl: string
  createdAt: string
}

export function getNotifications(pageNum = 1, pageSize = 20) {
  return request.get<NotificationItem[]>('/notifications', { params: { pageNum, pageSize } })
}

export function getUnreadCount() {
  return request.get<{ count: number }>('/notifications/unread-count')
}

export function markAsRead(id: number) {
  return request.post<void>(`/notifications/${id}/read`)
}

export function markAllAsRead() {
  return request.post<void>('/notifications/read-all')
}
