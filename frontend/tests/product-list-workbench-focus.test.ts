import test from 'node:test'
import assert from 'node:assert/strict'

import { getWorkbenchFocusState } from '../src/views/advisor/product-list-workbench-focus.ts'

test('getWorkbenchFocusState returns all-products state when no filters are active', () => {
  assert.deepEqual(
    getWorkbenchFocusState({
      status: '',
      type: '',
      riskLevel: '',
      keyword: ''
    }),
    {
      title: '全部产品',
      subtitle: '当前查看全部产品',
      hasFilters: false
    }
  )
})

test('getWorkbenchFocusState summarizes active filters', () => {
  assert.deepEqual(
    getWorkbenchFocusState({
      status: 'REJECTED',
      type: 'STRATEGY',
      riskLevel: 'R4',
      keyword: '纳指'
    }),
    {
      title: '驳回待改',
      subtitle: '驳回产品 / 策略组合 / R4 / 关键词：纳指',
      hasFilters: true
    }
  )
})
