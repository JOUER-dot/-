import request from '@/utils/request'
import type { PageResult } from '@/api/fund'

export interface TransactionItem {
  id: number
  productId: number
  productName: string
  type: string
  amount: number
  status: string
  createdAt: string
}

export function getMyTransactions(pageNum = 1, pageSize = 20) {
  return request.get<PageResult<TransactionItem>>('/auth/transactions', { params: { pageNum, pageSize } })
}
