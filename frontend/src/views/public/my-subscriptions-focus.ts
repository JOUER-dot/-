export type MySubscriptionsFocusKey = 'all' | 'active' | 'cancelled' | 'affected'

type SubscriptionFocusItem = {
  status: string
  productStatus: string
}

const focusStateMap: Record<
  MySubscriptionsFocusKey,
  { key: MySubscriptionsFocusKey; title: string; subtitle: string; hasFilters: boolean }
> = {
  all: {
    key: 'all',
    title: '全部订阅',
    subtitle: '当前查看全部订阅记录',
    hasFilters: false
  },
  active: {
    key: 'active',
    title: '有效订阅',
    subtitle: '当前查看仍在生效的订阅',
    hasFilters: true
  },
  cancelled: {
    key: 'cancelled',
    title: '已取消',
    subtitle: '当前查看已取消的订阅记录',
    hasFilters: true
  },
  affected: {
    key: 'affected',
    title: '受影响订阅',
    subtitle: '有效订阅中状态异常的产品',
    hasFilters: true
  }
}

export function isAffectedSubscription(item: SubscriptionFocusItem) {
  return item.status === 'ACTIVE' && item.productStatus !== 'PUBLISHED'
}

export function getMySubscriptionsFocusState(focusKey: MySubscriptionsFocusKey) {
  return focusStateMap[focusKey]
}
