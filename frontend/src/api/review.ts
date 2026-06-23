import request from '@/utils/request'
import type { PageResult } from '@/api/fund'
import type { ProductComponentItem, ReviewRecord } from '@/api/product'

export interface ReviewPendingItem {
  id: number
  name: string
  type: string
  riskLevel: string
  strategyCode: string
  status: string
  creatorName: string
  versionNo: number
  submittedAt: string
  featureTags: string[]
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

export function approveReview(productId: number) {
  return request.post<void>(`/reviewer/products/${productId}/approve`)
}

export function rejectReview(productId: number, payload: ReviewRejectPayload) {
  return request.post<void>(`/reviewer/products/${productId}/reject`, payload)
}
