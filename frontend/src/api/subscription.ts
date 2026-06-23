import request from '@/utils/request'

export interface MySubscriptionItem {
  subscriptionId: number
  productId: number
  productName: string
  type: string
  riskLevel: string
  status: string
  latestNav?: number
  latestCumReturn?: number
  subscribedAt: string
}

export function subscribeProduct(productId: number) {
  return request.post<void>(`/public/advisor-products/${productId}/subscribe`)
}

export function getMySubscriptions() {
  return request.get<MySubscriptionItem[]>('/auth/my-subscriptions')
}
