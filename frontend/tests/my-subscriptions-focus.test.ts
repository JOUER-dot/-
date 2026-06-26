import test from 'node:test'
import assert from 'node:assert/strict'

import {
  getMySubscriptionsFocusState,
  isAffectedSubscription,
  type MySubscriptionsFocusKey
} from '../src/views/public/my-subscriptions-focus.ts'

test('isAffectedSubscription returns true for active subscriptions on non-published products', () => {
  assert.equal(isAffectedSubscription({ status: 'ACTIVE', productStatus: 'OFFLINE' }), true)
  assert.equal(isAffectedSubscription({ status: 'ACTIVE', productStatus: 'PENDING_REVIEW' }), true)
})

test('isAffectedSubscription returns false for normal active published subscriptions', () => {
  assert.equal(isAffectedSubscription({ status: 'ACTIVE', productStatus: 'PUBLISHED' }), false)
  assert.equal(isAffectedSubscription({ status: 'CANCELLED', productStatus: 'OFFLINE' }), false)
})

test('getMySubscriptionsFocusState returns default state for all subscriptions', () => {
  assert.deepEqual(getMySubscriptionsFocusState('all'), {
    key: 'all',
    title: '全部订阅',
    subtitle: '当前查看全部订阅记录',
    hasFilters: false
  })
})

test('getMySubscriptionsFocusState returns focused state for affected subscriptions', () => {
  assert.deepEqual(getMySubscriptionsFocusState('affected'), {
    key: 'affected',
    title: '受影响订阅',
    subtitle: '有效订阅中状态异常的产品',
    hasFilters: true
  })
})

test('getMySubscriptionsFocusState covers all supported focus keys', () => {
  const focusKeys: MySubscriptionsFocusKey[] = ['all', 'active', 'cancelled', 'affected']
  assert.equal(focusKeys.every((key) => Boolean(getMySubscriptionsFocusState(key).title)), true)
})
