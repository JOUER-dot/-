type SummaryInput = {
  keyword: string
  productStatus: string
  subscriptionStatus: string
  sortBy: string
}

const subscriptionStatusMap: Record<string, string> = {
  ACTIVE: '已订阅',
  CANCELLED: '已取消'
}

const productStatusMap: Record<string, string> = {
  PUBLISHED: '已上架',
  OFFLINE: '已下架',
  PENDING_REVIEW: '待审核',
  REJECTED: '已驳回'
}

const sortLabelMap: Record<string, string> = {
  subscribedAtDesc: '默认按最近订阅查看',
  subscribedAtAsc: '最早订阅优先',
  productNameAsc: '产品名称排序',
  productStatusFirst: '产品状态优先'
}

export function getMySubscriptionsFilterSummary(input: SummaryInput) {
  const segments: string[] = []
  const keyword = input.keyword.trim()

  if (keyword) {
    segments.push(`关键词：${keyword}`)
  }
  if (input.subscriptionStatus) {
    segments.push(subscriptionStatusMap[input.subscriptionStatus] || input.subscriptionStatus)
  }
  if (input.productStatus) {
    segments.push(productStatusMap[input.productStatus] || input.productStatus)
  }

  const sortLabel = sortLabelMap[input.sortBy] || sortLabelMap.subscribedAtDesc
  if (segments.length === 0 && input.sortBy === 'subscribedAtDesc') {
    return {
      hasFilters: false,
      summary: sortLabel
    }
  }

  segments.push(sortLabel)
  return {
    hasFilters: true,
    summary: segments.join(' / ')
  }
}
