import request from '@/utils/request'
import type { FundOption, PageResult } from '@/api/fund'

export type ProductStatus = 'DRAFT' | 'PENDING_REVIEW' | 'REJECTED' | 'PUBLISHED' | 'OFFLINE'

export interface ProductComponentItem {
  fundId: number
  fundCode?: string
  fundName?: string
  fundType?: string
  riskLevel?: string
  companyName?: string
  weight: number
}

export interface ProductSavePayload {
  name: string
  type: string
  riskLevel: string
  strategyCode: string
  featureTags: string[]
  baseInfo: Record<string, unknown>
  params: Record<string, unknown>
  components: Array<{
    fundId: number
    weight: number
  }>
}

export interface ProductListItem {
  id: number
  name: string
  type: string
  riskLevel: string
  status: ProductStatus
  featureTags: string[]
  updatedAt: string
  lastRejectComment: string
}

export interface ReviewRecord {
  result: string
  comment: string
  reviewerName: string
  reviewedAt: string
}

export interface PublishedVersion {
  versionId: number
  versionNo: number
  versionStatus: string
  submittedAt: string
  baseInfo: Record<string, unknown>
  params: Record<string, unknown>
  components: ProductComponentItem[]
}

export interface ProductDetail {
  id: number
  name: string
  type: string
  riskLevel: string
  strategyCode: string
  featureTags: string[]
  status: ProductStatus
  lastRejectComment: string
  baseInfo: Record<string, unknown>
  params: Record<string, unknown>
  components: ProductComponentItem[]
  publishedVersion: PublishedVersion | null
  reviewSummary: ReviewRecord[]
}

export interface ProductQueryParams {
  status?: string
  type?: string
  riskLevel?: string
  keyword?: string
  pageNum?: number
  pageSize?: number
}

export interface ProductCreateResponse {
  productId: number
}

export function createProduct(payload: ProductSavePayload) {
  return request.post<ProductCreateResponse>('/admin/products', payload)
}

export function updateProduct(productId: number, payload: ProductSavePayload) {
  return request.put<void>(`/admin/products/${productId}`, payload)
}

export function getProductList(params: ProductQueryParams) {
  return request.get<PageResult<ProductListItem>>('/admin/products', { params })
}

export function getProductDetail(productId: number) {
  return request.get<ProductDetail>(`/admin/products/${productId}`)
}

export function submitProduct(productId: number) {
  return request.post<void>(`/admin/products/${productId}/submit`)
}

export function withdrawProduct(productId: number) {
  return request.post<void>(`/admin/products/${productId}/withdraw`)
}

export function offlineProduct(productId: number) {
  return request.post<void>(`/admin/products/${productId}/offline`)
}

export function getProductReviews(productId: number) {
  return request.get<ReviewRecord[]>(`/admin/products/${productId}/reviews`)
}

export function mapFundToComponent(fund: FundOption): ProductComponentItem {
  return {
    fundId: fund.id,
    fundCode: fund.fundCode,
    fundName: fund.fundName,
    fundType: fund.fundType,
    riskLevel: fund.riskLevel,
    companyName: fund.companyName,
    weight: 0
  }
}
