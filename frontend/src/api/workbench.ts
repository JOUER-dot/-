import request from '@/utils/request'

export interface WorkbenchData {
  overview: {
    totalProducts: number
    publishedProducts: number
    pendingReviewProducts: number
    rejectedProducts: number
    draftProducts: number
    totalSubscriptions: number
    recentWeekSubscriptions: number
  }
  urgentProducts: Array<{
    id: number
    name: string
    type: string
    riskLevel: string
    status: string
    lastRejectComment: string
    updatedAt: string
    waitingDays: number
  }>
  productRankings: Array<{
    id: number
    name: string
    type: string
    riskLevel: string
    latestNav: string
    cumReturn: string
    subscriberCount: number
  }>
}

export function getWorkbench() {
  return request.get<WorkbenchData>('/admin/workbench')
}
