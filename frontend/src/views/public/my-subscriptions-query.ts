import type { MySubscriptionsFocusKey } from '@/views/public/my-subscriptions-focus'
import type { MySubscriptionsQueryParams } from '@/api/subscription'

type BuildParamsInput = {
  focusKey: MySubscriptionsFocusKey
  keyword: string
  productStatus: string
  subscriptionStatus: string
  sortBy: string
  pageNum: number
  pageSize: number
}

export function buildMySubscriptionsQueryParams(input: BuildParamsInput): MySubscriptionsQueryParams {
  const params: MySubscriptionsQueryParams = {
    sortBy: input.sortBy,
    pageNum: input.pageNum,
    pageSize: input.pageSize
  }

  const keyword = input.keyword.trim()
  if (keyword) {
    params.keyword = keyword
  }

  if (input.focusKey === 'active') {
    params.subscriptionStatus = 'ACTIVE'
  } else if (input.focusKey === 'cancelled') {
    params.subscriptionStatus = 'CANCELLED'
  } else if (input.focusKey === 'affected') {
    params.subscriptionStatus = 'ACTIVE'
  } else if (input.subscriptionStatus) {
    params.subscriptionStatus = input.subscriptionStatus
  }

  if (input.productStatus) {
    params.productStatus = input.productStatus
  }

  return params
}
