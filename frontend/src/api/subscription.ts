import request from '@/utils/request'
import type { PageResult } from '@/api/fund'
import type { ProductChangeType } from '@/api/product'

export type SubscriptionStatus = 'ACTIVE' | 'CANCELLED'
export type SubscriptionVersionActionType = 'NOTICE' | 'CONFIRM_REQUIRED'
export type SubscriptionVersionActionStatus = 'PENDING' | 'NOTIFIED' | 'CONFIRMED' | 'CANCELLED'
export type SubscriptionVersionDecision = 'CONFIRM' | 'CANCEL'

export interface SubscriptionVersionActionItem {
  id: number
  productVersionId: number
  actionType: SubscriptionVersionActionType
  actionStatus: SubscriptionVersionActionStatus
  changeType?: ProductChangeType | null
  versionNote?: string | null
  createdAt: string
  handledAt?: string | null
}

export interface MySubscriptionItem {
  subscriptionId: number
  productId: number
  productName: string
  type: string
  riskLevel: string
  status: SubscriptionStatus
  productStatus: string
  latestNav?: number
  latestCumReturn?: number
  subscribedAt: string
  pendingVersionActions?: SubscriptionVersionActionItem[]
}

export interface MySubscriptionsQueryParams {
  keyword?: string
  subscriptionStatus?: string
  productStatus?: string
  sortBy?: string
  pageNum?: number
  pageSize?: number
}

export interface SubscriptionVersionDecisionPayload {
  decision: SubscriptionVersionDecision
}

export function subscribeProduct(productId: number, amount?: number) {
  return request.post<void>(`/public/advisor-products/${productId}/subscribe`, amount ? { amount } : {})
}

export function unsubscribeProduct(productId: number) {
  return request.post<void>(`/public/advisor-products/${productId}/unsubscribe`)
}

export function getMySubscriptions(params: MySubscriptionsQueryParams) {
  return request.get<PageResult<MySubscriptionItem>>('/auth/my-subscriptions', { params })
}

export function decideMySubscriptionVersionAction(
  subscriptionId: number,
  payload: SubscriptionVersionDecisionPayload
) {
  return request.post<void>(`/auth/my-subscriptions/${subscriptionId}/version-decision`, payload)
}
