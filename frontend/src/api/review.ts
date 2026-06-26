import request from '@/utils/request'
import type { PageResult } from '@/api/fund'
import type { ProductChangeType, ProductComponentItem, ReviewRecord } from '@/api/product'

export interface ReviewStrategyRule {
  minFundCount?: number | null
  maxFundCount?: number | null
  minSingleWeight?: number | string | null
  maxSingleWeight?: number | string | null
}

export interface ReviewPendingItem {
  id: number
  name: string
  type: string
  riskLevel: string
  strategyCode: string
  status: string
  creatorName: string
  versionNo: number
  baseVersionNo?: number | null
  submittedAt: string
  featureTags: string[]
  changeType?: ProductChangeType | null
  versionNote?: string | null
}

export interface ReviewVersionSummary {
  versionId: number
  versionNo: number
  versionStatus: string
  submittedAt: string | null
}

export interface ReviewDiffField {
  fieldKey: string
  fieldLabel: string
  beforeValue: unknown
  afterValue: unknown
  majorSignal: boolean
}

export interface ReviewDiffComponent {
  diffType: 'ADDED' | 'REMOVED' | 'UPDATED'
  fundId: number
  fundCode?: string | null
  fundName?: string | null
  beforeWeight?: number | string | null
  afterWeight?: number | string | null
  deltaWeight?: number | string | null
}

export interface ReviewDetail {
  id: number
  name: string
  type: string
  riskLevel: string
  strategyCode: string
  status: string
  creatorName: string
  versionId: number
  versionNo: number
  versionStatus: string
  submittedAt: string
  featureTags: string[]
  baseInfo: Record<string, unknown>
  params: Record<string, unknown>
  components: ProductComponentItem[]
  reviewSummary: ReviewRecord[]
  strategyRule?: ReviewStrategyRule | null
  baseRule?: ReviewStrategyRule | null
  baseVersionSummary?: ReviewVersionSummary | null
  currentVersionSummary?: ReviewVersionSummary | null
  fieldDiffs?: ReviewDiffField[]
  componentDiffs?: ReviewDiffComponent[]
  changeType?: ProductChangeType | null
  versionNote?: string | null
}

export interface ReviewApprovePayload {
  overrideMinFundCount?: number
  overrideMaxFundCount?: number
  overrideMaxSingleWeight?: number
  decisionComment?: string
}

export interface ReviewQueryParams {
  keyword?: string
  type?: string
  riskLevel?: string
  pageNum?: number
  pageSize?: number
}

export interface ReviewRejectPayload {
  comment: string
}

export function getPendingReviewList(params: ReviewQueryParams) {
  return request.get<PageResult<ReviewPendingItem>>('/reviewer/products/pending', { params })
}

export function getReviewDetail(productId: number) {
  return request.get<ReviewDetail>(`/reviewer/products/${productId}`)
}

export function approveReview(productId: number, payload?: ReviewApprovePayload) {
  return request.post<void>(`/reviewer/products/${productId}/approve`, payload || {})
}

export function rejectReview(productId: number, payload: ReviewRejectPayload) {
  return request.post<void>(`/reviewer/products/${productId}/reject`, payload)
}

export function batchApproveReviews(productIds: number[], payload?: ReviewApprovePayload) {
  const ids = productIds.join(',')
  return request.post<void>(`/reviewer/products/batch-approve?ids=${ids}`, payload || {})
}

export function batchRejectReviews(productIds: number[], payload: ReviewRejectPayload) {
  const ids = productIds.join(',')
  return request.post<void>(`/reviewer/products/batch-reject?ids=${ids}`, payload)
}

export interface ReviewHistoryItem {
  id: number
  productId: number
  productName: string
  result: string
  comment: string
  reviewedAt: string
}

export function getMyReviewHistory(pageNum = 1, pageSize = 10) {
  return request.get<ReviewHistoryItem[]>(`/reviewer/products/my-history`, {
    params: { pageNum, pageSize }
  })
}
