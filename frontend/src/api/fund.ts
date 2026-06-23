import request from '@/utils/request'

export interface FundOption {
  id: number
  fundCode: string
  fundName: string
  fundType: string
  riskLevel: string
  companyName: string
  status: number
}

export interface PageResult<T> {
  records: T[]
  total: number
  pageNum: number
  pageSize: number
}

export interface FundQueryParams {
  keyword?: string
  fundType?: string
  pageNum?: number
  pageSize?: number
}

export function getFundList(params: FundQueryParams) {
  return request.get<PageResult<FundOption>>('/admin/funds', { params })
}
