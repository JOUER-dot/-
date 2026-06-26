import test from 'node:test'
import assert from 'node:assert/strict'

import { getMySubscriptionsFilterSummary } from '../src/views/public/my-subscriptions-summary.ts'

test('getMySubscriptionsFilterSummary returns default summary when only default sorting is used', () => {
  assert.deepEqual(
    getMySubscriptionsFilterSummary({
      keyword: '',
      productStatus: '',
      subscriptionStatus: '',
      sortBy: 'subscribedAtDesc'
    }),
    {
      hasFilters: false,
      summary: '默认按最近订阅查看'
    }
  )
})

test('getMySubscriptionsFilterSummary combines keyword, status and sort text', () => {
  assert.deepEqual(
    getMySubscriptionsFilterSummary({
      keyword: '纳指',
      productStatus: 'OFFLINE',
      subscriptionStatus: 'ACTIVE',
      sortBy: 'productStatusFirst'
    }),
    {
      hasFilters: true,
      summary: '关键词：纳指 / 已订阅 / 已下架 / 产品状态优先'
    }
  )
})
