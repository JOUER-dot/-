export type BatchActionItem = {
  status: 'DRAFT' | 'PENDING_REVIEW' | 'REJECTED' | 'PUBLISHED' | 'OFFLINE'
}

const SUBMITTABLE_STATUSES = new Set<BatchActionItem['status']>(['DRAFT', 'REJECTED'])
const OFFLINABLE_STATUSES = new Set<BatchActionItem['status']>(['PUBLISHED'])

export function getBatchActionState(items: BatchActionItem[]) {
  const selectedCount = items.length

  if (selectedCount === 0) {
    return {
      selectedCount,
      canBatchSubmit: false,
      canBatchOffline: false
    }
  }

  const canBatchSubmit = items.every((item) => SUBMITTABLE_STATUSES.has(item.status))
  const canBatchOffline = items.every((item) => OFFLINABLE_STATUSES.has(item.status))

  return {
    selectedCount,
    canBatchSubmit,
    canBatchOffline
  }
}
