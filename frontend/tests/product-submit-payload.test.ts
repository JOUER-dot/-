import test from 'node:test'
import assert from 'node:assert/strict'

import { buildProductSubmitPayload, getProductVersionContext } from '../src/views/advisor/product-submit.ts'

test('buildProductSubmitPayload carries changeType and versionNote for iteration draft', () => {
  const payload = buildProductSubmitPayload(
    {
      isIteration: true,
      currentPublishedVersionNo: 3
    },
    {
      changeType: 'MAJOR',
      versionNote: ' 风险等级提升 '
    }
  )

  assert.deepEqual(payload, {
    changeType: 'MAJOR',
    versionNote: '风险等级提升'
  })
})

test('getProductVersionContext returns iteration context from published version', () => {
  const detail = {
    status: 'DRAFT',
    publishedVersion: {
      versionId: 9,
      versionNo: 3,
      versionStatus: 'APPROVED',
      submittedAt: '2026-06-26T10:00:00',
      baseInfo: {},
      params: {},
      components: []
    }
  }

  assert.deepEqual(getProductVersionContext(detail), {
    isIteration: true,
    currentPublishedVersionNo: 3
  })
})
