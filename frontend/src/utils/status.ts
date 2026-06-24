export function productStatusLabel(status: string): string {
  if (status === 'DRAFT') return '草稿'
  if (status === 'PENDING_REVIEW') return '待审核'
  if (status === 'REJECTED') return '已驳回'
  if (status === 'PUBLISHED') return '已上架'
  if (status === 'OFFLINE') return '已下架'
  return status
}

export function productStatusTagType(status: string): 'success' | 'warning' | 'danger' | 'info' {
  if (status === 'PUBLISHED') return 'success'
  if (status === 'PENDING_REVIEW') return 'warning'
  if (status === 'REJECTED') return 'danger'
  return 'info'
}

export function productTypeLabel(type: string): string {
  if (type === 'STRATEGY') return '策略组合'
  if (type === 'FOF') return 'FOF组合'
  return type
}

export function productTypeOptions() {
  return [
    { label: '策略组合', value: 'STRATEGY' },
    { label: 'FOF组合', value: 'FOF' }
  ]
}

export function subscriptionStatusLabel(status: string): string {
  if (status === 'ACTIVE') return '已订阅'
  if (status === 'CANCELLED') return '已取消'
  return status
}

export function subscriptionStatusTagType(status: string): 'success' | 'warning' | 'info' {
  if (status === 'ACTIVE') return 'success'
  if (status === 'CANCELLED') return 'warning'
  return 'info'
}

export function reviewResultLabel(status: string): string {
  if (status === 'APPROVED') return '已通过'
  if (status === 'REJECTED') return '已驳回'
  if (status === 'SUBMITTED') return '已提交'
  if (status === 'WITHDRAWN') return '已撤回'
  return status
}
