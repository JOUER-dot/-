import type { ProductChangeType } from '@/api/product'
import type { ReviewDetail, ReviewDiffComponent, ReviewDiffField } from '@/api/review'
import { formatPercent as fp, formatText as ft } from '@/utils/format'

export interface ReviewDetailDiffSummary {
  hasDiff: boolean
  hasMajorSignals: boolean
  fieldDiffCount: number
  componentDiffCount: number
  addedCount: number
  removedCount: number
  updatedCount: number
  changedFieldKeys: string[]
}

export interface ReviewComponentDiffDisplayItem extends ReviewDiffComponent {
  beforeWeightText: string
  afterWeightText: string
  deltaText: string
}

export interface GroupedReviewComponentDiffs {
  added: ReviewComponentDiffDisplayItem[]
  removed: ReviewComponentDiffDisplayItem[]
  updated: ReviewComponentDiffDisplayItem[]
}

export interface ReviewImpactNotice {
  tone: 'warning' | 'info'
  title: string
  description: string
}

function countComponentDiffs(componentDiffs: ReviewDiffComponent[], diffType: ReviewDiffComponent['diffType']) {
  return componentDiffs.filter((item) => item.diffType === diffType).length
}

export function getReviewDetailDiffSummary(detail: Pick<ReviewDetail, 'fieldDiffs' | 'componentDiffs'>): ReviewDetailDiffSummary {
  const fieldDiffs = detail.fieldDiffs || []
  const componentDiffs = detail.componentDiffs || []

  return {
    hasDiff: fieldDiffs.length > 0 || componentDiffs.length > 0,
    hasMajorSignals: fieldDiffs.some((item) => item.majorSignal),
    fieldDiffCount: fieldDiffs.length,
    componentDiffCount: componentDiffs.length,
    addedCount: countComponentDiffs(componentDiffs, 'ADDED'),
    removedCount: countComponentDiffs(componentDiffs, 'REMOVED'),
    updatedCount: countComponentDiffs(componentDiffs, 'UPDATED'),
    changedFieldKeys: fieldDiffs.map((item) => item.fieldKey)
  }
}

function isPercentField(fieldKey: string) {
  return ['minSingleFundWeight', 'maxSingleFundWeight'].includes(fieldKey)
}

function isProductTypeValue(value: unknown) {
  return value === 'FUND' || value === 'STRATEGY' || value === 'COMPOSITE'
}

function toComponentDisplayItem(item: ReviewDiffComponent): ReviewComponentDiffDisplayItem {
  const delta = Number(item.deltaWeight)
  const deltaText = Number.isFinite(delta) ? `${delta > 0 ? '+' : ''}${fp(delta)}` : '0.00%'
  return {
    ...item,
    beforeWeightText: item.beforeWeight === null || item.beforeWeight === undefined ? '未持有' : fp(item.beforeWeight),
    afterWeightText: item.afterWeight === null || item.afterWeight === undefined ? '未持有' : fp(item.afterWeight),
    deltaText
  }
}

export function groupReviewComponentDiffs(items: ReviewDiffComponent[]): GroupedReviewComponentDiffs {
  const grouped: GroupedReviewComponentDiffs = {
    added: [],
    removed: [],
    updated: []
  }

  items.forEach((item) => {
    const displayItem = toComponentDisplayItem(item)
    if (item.diffType === 'ADDED') {
      grouped.added.push(displayItem)
      return
    }
    if (item.diffType === 'REMOVED') {
      grouped.removed.push(displayItem)
      return
    }
    grouped.updated.push(displayItem)
  })

  return grouped
}

export function formatReviewDiffValue(value: unknown): string {
  if (Array.isArray(value)) {
    const texts = value.map((item) => ft(item)).filter((item) => item !== '-')
    return texts.length > 0 ? texts.join(' / ') : '未填写'
  }
  if (value === null || value === undefined || value === '') {
    return '未填写'
  }
  return ft(value)
}

export function formatReviewFieldDiffValue(field: Pick<ReviewDiffField, 'fieldKey'>, value: unknown): string {
  if (field.fieldKey === 'type' && isProductTypeValue(value)) {
    return value === 'FUND' ? '基金' : value === 'STRATEGY' ? '策略组合' : '组合产品'
  }
  if (isPercentField(field.fieldKey)) {
    return value === null || value === undefined || value === '' ? '未填写' : fp(value)
  }
  return formatReviewDiffValue(value)
}

export function getReviewImpactNotice(changeType?: ProductChangeType | null): ReviewImpactNotice {
  if (changeType === 'MAJOR') {
    return {
      tone: 'warning',
      title: '审核通过后将触发已订阅用户确认流程',
      description: '该版本会把存量订阅带入待确认状态，用户需要选择继续订阅或取消订阅。'
    }
  }
  return {
    tone: 'info',
    title: '审核通过后仅发送版本更新提醒',
    description: '该版本不会中断现有订阅关系，系统只会向已订阅用户发送更新通知。'
  }
}
