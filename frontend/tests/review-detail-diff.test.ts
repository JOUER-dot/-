import test from 'node:test'
import assert from 'node:assert/strict'

import type { ReviewDetail } from '../src/api/review.ts'
import {
  formatReviewDiffValue,
  getReviewDetailDiffSummary,
  groupReviewComponentDiffs
} from '../src/views/review/review-detail-diff.ts'

const reviewDetail: ReviewDetail = {
  id: 9,
  name: '稳健精选',
  type: 'STRATEGY',
  riskLevel: 'MEDIUM',
  strategyCode: 'BALANCE_ALPHA',
  status: 'PENDING_REVIEW',
  creatorName: '顾问甲',
  versionId: 18,
  versionNo: 3,
  versionStatus: 'SUBMITTED',
  submittedAt: '2026-06-26T10:00:00',
  featureTags: ['稳健'],
  baseInfo: {},
  params: {},
  components: [],
  reviewSummary: [],
  strategyRule: null,
  baseRule: null,
  baseVersionSummary: {
    versionId: 17,
    versionNo: 2,
    versionStatus: 'APPROVED',
    submittedAt: '2026-06-20T09:00:00'
  },
  currentVersionSummary: {
    versionId: 18,
    versionNo: 3,
    versionStatus: 'SUBMITTED',
    submittedAt: '2026-06-26T10:00:00'
  },
  fieldDiffs: [
    {
      fieldKey: 'riskLevel',
      fieldLabel: '风险等级',
      beforeValue: 'LOW',
      afterValue: 'MEDIUM',
      majorSignal: true
    },
    {
      fieldKey: 'productSummary',
      fieldLabel: '产品简介',
      beforeValue: '旧文案',
      afterValue: '新文案',
      majorSignal: false
    }
  ],
  componentDiffs: [
    {
      diffType: 'ADDED',
      fundId: 1001,
      fundCode: 'F1001',
      fundName: '新增基金',
      beforeWeight: null,
      afterWeight: 0.2,
      deltaWeight: 0.2
    },
    {
      diffType: 'UPDATED',
      fundId: 1002,
      fundCode: 'F1002',
      fundName: '调仓基金',
      beforeWeight: 0.3,
      afterWeight: 0.4,
      deltaWeight: 0.1
    },
    {
      diffType: 'REMOVED',
      fundId: 1003,
      fundCode: 'F1003',
      fundName: '移除基金',
      beforeWeight: 0.1,
      afterWeight: null,
      deltaWeight: -0.1
    }
  ],
  changeType: 'MAJOR',
  versionNote: '调仓并提升风险等级'
}

test('getReviewDetailDiffSummary returns field and component diff overview', () => {
  assert.deepEqual(getReviewDetailDiffSummary(reviewDetail), {
    hasDiff: true,
    hasMajorSignals: true,
    fieldDiffCount: 2,
    componentDiffCount: 3,
    addedCount: 1,
    removedCount: 1,
    updatedCount: 1,
    changedFieldKeys: ['riskLevel', 'productSummary']
  })
})

test('groupReviewComponentDiffs splits component changes and formats delta text', () => {
  const grouped = groupReviewComponentDiffs(reviewDetail.componentDiffs || [])

  assert.equal(grouped.added.length, 1)
  assert.equal(grouped.removed.length, 1)
  assert.equal(grouped.updated.length, 1)
  assert.equal(grouped.updated[0].deltaText, '+10.00%')
})

test('formatReviewDiffValue renders arrays and empty values for display', () => {
  assert.equal(formatReviewDiffValue(['稳健', '指数增强']), '稳健 / 指数增强')
  assert.equal(formatReviewDiffValue(null), '未填写')
})
