import test from 'node:test'
import assert from 'node:assert/strict'

import { buildMySubscriptionsQueryParams } from '../src/views/public/my-subscriptions-query.ts'

test('buildMySubscriptionsQueryParams builds default query for all subscriptions', () => {
  assert.deepEqual(
    buildMySubscriptionsQueryParams({
      focusKey: 'all',
      keyword: '',
      productStatus: '',
      subscriptionStatus: '',
      sortBy: 'subscribedAtDesc',
      pageNum: 1,
      pageSize: 10
    }),
    {
      sortBy: 'subscribedAtDesc',
      pageNum: 1,
      pageSize: 10
    }
  )
})

test('buildMySubscriptionsQueryParams maps active and affected focus correctly', () => {
  assert.deepEqual(
    buildMySubscriptionsQueryParams({
      focusKey: 'active',
      keyword: '纳指',
      productStatus: '',
      subscriptionStatus: '',
      sortBy: 'subscribedAtAsc',
      pageNum: 2,
      pageSize: 20
    }),
    {
      keyword: '纳指',
      subscriptionStatus: 'ACTIVE',
      sortBy: 'subscribedAtAsc',
      pageNum: 2,
      pageSize: 20
    }
  )

  assert.deepEqual(
    buildMySubscriptionsQueryParams({
      focusKey: 'affected',
      keyword: '',
      productStatus: 'OFFLINE',
      subscriptionStatus: '',
      sortBy: 'productStatusFirst',
      pageNum: 1,
      pageSize: 10
    }),
    {
      subscriptionStatus: 'ACTIVE',
      productStatus: 'OFFLINE',
      sortBy: 'productStatusFirst',
      pageNum: 1,
      pageSize: 10
    }
  )
})

test('buildMySubscriptionsQueryParams allows explicit cancelled focus to override status filter', () => {
  assert.deepEqual(
    buildMySubscriptionsQueryParams({
      focusKey: 'cancelled',
      keyword: '',
      productStatus: '',
      subscriptionStatus: '',
      sortBy: 'productNameAsc',
      pageNum: 3,
      pageSize: 10
    }),
    {
      subscriptionStatus: 'CANCELLED',
      sortBy: 'productNameAsc',
      pageNum: 3,
      pageSize: 10
    }
  )
})
