import request from '@/utils/request'
import type { PageResult } from '@/api/fund'
import type { ProductComponentItem } from '@/api/product'

export interface PublicProductListItem {
  id: number
  name: string
  type: string
  riskLevel: string
  strategyCode: string
  featureTags: string[]
  latestNav?: number
  latestCumReturn?: number
}

export interface PublicProductNavPoint {
  navDate: string
  nav: number
  cumReturn?: number
}

export interface PublicProductDetail {
  id: number
  name: string
  type: string
  riskLevel: string
  strategyCode: string
  versionId: number
  versionNo: number
  featureTags: string[]
  baseInfo: Record<string, unknown>
  params: Record<string, unknown>
  components: ProductComponentItem[]
  navList: PublicProductNavPoint[]
  holdingSnapshot: Record<string, unknown>
  holdingSnapshotDate?: string
}

export interface PublicProductQueryParams {
  keyword?: string
  type?: string
  riskLevel?: string
  pageNum?: number
  pageSize?: number
}

export function getPublishedProductList(params: PublicProductQueryParams) {
  return request.get<PageResult<PublicProductListItem>>('/public/advisor-products', { params })
}

export function getPublishedProductDetail(productId: number) {
  return request.get<PublicProductDetail>(`/public/advisor-products/${productId}`)
}
