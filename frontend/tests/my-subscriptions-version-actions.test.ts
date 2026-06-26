import test from 'node:test'
import assert from 'node:assert/strict'

import type { MySubscriptionItem } from '../src/api/subscription.ts'
import { getMySubscriptionVersionActionState } from '../src/views/public/my-subscriptions-version-actions.ts'

test('getMySubscriptionVersionActionState returns confirmable state for pending major change', () => {
  const item: MySubscriptionItem = {
    subscriptionId: 10,
    productId: 3,
    productName: '全球精选组合',
    type: 'STRATEGY',
    riskLevel: 'MEDIUM',
    status: 'ACTIVE',
    productStatus: 'OFFLINE',
    latestNav: 1.23,
    latestCumReturn: 0.15,
    subscribedAt: '2026-06-01T10:00:00',
    pendingVersionActions: [
      {
        id: 99,
        productVersionId: 18,
        actionType: 'CONFIRM_REQUIRED',
        actionStatus: 'PENDING',
        changeType: 'MAJOR',
        versionNote: '调仓并提升风险等级',
        createdAt: '2026-06-26T11:00:00',
        handledAt: null
      }
    ]
  }

  assert.deepEqual(getMySubscriptionVersionActionState(item), {
    visible: true,
    requiresDecision: true,
    tone: 'warning',
    summary: '调仓并提升风险等级',
    actionLabel: '待确认继续订阅',
    decisionOptions: ['CONFIRM', 'CANCEL']
  })
})

test('getMySubscriptionVersionActionState hides action area when there is no pending action', () => {
  const item: MySubscriptionItem = {
    subscriptionId: 11,
    productId: 4,
    productName: '现金管理组合',
    type: 'STRATEGY',
    riskLevel: 'LOW',
    status: 'ACTIVE',
    productStatus: 'PUBLISHED',
    latestNav: 1.01,
    latestCumReturn: 0.03,
    subscribedAt: '2026-05-01T08:00:00',
    pendingVersionActions: []
  }

  assert.deepEqual(getMySubscriptionVersionActionState(item), {
    visible: false,
    requiresDecision: false,
    tone: 'default',
    summary: '',
    actionLabel: '',
    decisionOptions: []
  })
})

test('getMySubscriptionVersionActionState prefers pending confirm action over notice action', () => {
  const item: MySubscriptionItem = {
    subscriptionId: 12,
    productId: 6,
    productName: '稳健增强组合',
    type: 'STRATEGY',
    riskLevel: 'MEDIUM',
    status: 'ACTIVE',
    productStatus: 'PUBLISHED',
    latestNav: 1.11,
    latestCumReturn: 0.08,
    subscribedAt: '2026-06-10T09:00:00',
    pendingVersionActions: [
      {
        id: 100,
        productVersionId: 21,
        actionType: 'NOTICE',
        actionStatus: 'PENDING',
        changeType: 'NORMAL',
        versionNote: '小幅调仓提醒',
        createdAt: '2026-06-26T12:00:00',
        handledAt: null
      },
      {
        id: 101,
        productVersionId: 22,
        actionType: 'CONFIRM_REQUIRED',
        actionStatus: 'PENDING',
        changeType: 'MAJOR',
        versionNote: '风险等级提升，需要确认是否继续订阅',
        createdAt: '2026-06-26T12:05:00',
        handledAt: null
      }
    ]
  }

  assert.deepEqual(getMySubscriptionVersionActionState(item), {
    visible: true,
    requiresDecision: true,
    tone: 'warning',
    summary: '风险等级提升，需要确认是否继续订阅',
    actionLabel: '待确认继续订阅',
    decisionOptions: ['CONFIRM', 'CANCEL']
  })
})
