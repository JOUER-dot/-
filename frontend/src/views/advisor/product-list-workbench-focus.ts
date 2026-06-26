type WorkbenchQuery = {
  status: string
  type: string
  riskLevel: string
  keyword: string
}

const statusTitleMap: Record<string, string> = {
  DRAFT: '待处理草稿',
  PENDING_REVIEW: '待审核',
  REJECTED: '驳回待改',
  PUBLISHED: '可下架',
  OFFLINE: '已下架'
}

const statusFilterMap: Record<string, string> = {
  DRAFT: '草稿产品',
  PENDING_REVIEW: '待审核产品',
  REJECTED: '驳回产品',
  PUBLISHED: '已上架产品',
  OFFLINE: '已下架产品'
}

const typeLabelMap: Record<string, string> = {
  STRATEGY: '策略组合',
  FOF: 'FOF组合'
}

export function getWorkbenchFocusState(query: WorkbenchQuery) {
  const segments: string[] = []

  if (query.status) {
    segments.push(statusFilterMap[query.status] || query.status)
  }
  if (query.type) {
    segments.push(typeLabelMap[query.type] || query.type)
  }
  if (query.riskLevel) {
    segments.push(query.riskLevel)
  }
  if (query.keyword.trim()) {
    segments.push(`关键词：${query.keyword.trim()}`)
  }

  return {
    title: query.status ? statusTitleMap[query.status] || query.status : '全部产品',
    subtitle: segments.length > 0 ? segments.join(' / ') : '当前查看全部产品',
    hasFilters: segments.length > 0
  }
}
