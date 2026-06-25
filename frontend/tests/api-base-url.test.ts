import test from 'node:test'
import assert from 'node:assert/strict'

import { normalizeApiBaseUrl } from '../src/utils/api-base-url.ts'

test('normalizeApiBaseUrl falls back to /api when env is missing', () => {
  assert.equal(normalizeApiBaseUrl(undefined), '/api')
  assert.equal(normalizeApiBaseUrl(''), '/api')
})

test('normalizeApiBaseUrl normalizes relative api base to an absolute root path', () => {
  assert.equal(normalizeApiBaseUrl('api'), '/api')
  assert.equal(normalizeApiBaseUrl('/api/'), '/api')
})

test('normalizeApiBaseUrl keeps absolute URLs intact', () => {
  assert.equal(normalizeApiBaseUrl('http://localhost:8081/api/'), 'http://localhost:8081/api')
})
