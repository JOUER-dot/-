import test from 'node:test'
import assert from 'node:assert/strict'
import axios from 'axios'

import { normalizeApiBaseUrl } from '../src/utils/api-base-url.ts'

test('offline product request should target /api/admin/products/:id/offline', () => {
  const baseURL = normalizeApiBaseUrl('/api')
  const client = axios.create({ baseURL })

  const uri = client.getUri({
    method: 'POST',
    url: '/admin/products/3/offline'
  })

  assert.equal(uri, '/api/admin/products/3/offline')
})

test('offline product request should target absolute api base url', () => {
  const baseURL = normalizeApiBaseUrl('http://localhost:8081/api')
  const client = axios.create({ baseURL })

  const uri = client.getUri({
    method: 'POST',
    url: '/admin/products/3/offline'
  })

  assert.equal(uri, 'http://localhost:8081/api/admin/products/3/offline')
})
