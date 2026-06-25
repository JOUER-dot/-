import test from 'node:test'
import assert from 'node:assert/strict'

import {
  getBatchActionState,
  type BatchActionItem
} from '../src/views/advisor/product-list-batch-actions.ts'

const item = (status: BatchActionItem['status']): BatchActionItem => ({ status })

test('getBatchActionState disables all batch actions when nothing is selected', () => {
  assert.deepEqual(getBatchActionState([]), {
    selectedCount: 0,
    canBatchSubmit: false,
    canBatchOffline: false
  })
})

test('getBatchActionState enables batch submit for draft and rejected products only', () => {
  assert.deepEqual(getBatchActionState([item('DRAFT'), item('REJECTED')]), {
    selectedCount: 2,
    canBatchSubmit: true,
    canBatchOffline: false
  })
})

test('getBatchActionState enables batch offline for published products only', () => {
  assert.deepEqual(getBatchActionState([item('PUBLISHED'), item('PUBLISHED')]), {
    selectedCount: 2,
    canBatchSubmit: false,
    canBatchOffline: true
  })
})

test('getBatchActionState disables mixed-status selections', () => {
  assert.deepEqual(getBatchActionState([item('DRAFT'), item('PUBLISHED')]), {
    selectedCount: 2,
    canBatchSubmit: false,
    canBatchOffline: false
  })
})
