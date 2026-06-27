import { describe, it, expect } from 'vitest'
import { normalizeApiBaseUrl } from './api-base-url'

describe('normalizeApiBaseUrl', () => {
  it('should return "/api" for undefined input', () => {
    expect(normalizeApiBaseUrl(undefined)).toBe('/api')
  })

  it('should return "/api" for empty string', () => {
    expect(normalizeApiBaseUrl('')).toBe('/api')
  })

  it('should return "/api" for whitespace-only string', () => {
    expect(normalizeApiBaseUrl('   ')).toBe('/api')
  })

  it('should strip trailing slashes from absolute URL', () => {
    expect(normalizeApiBaseUrl('http://localhost:8080///')).toBe('http://localhost:8080')
  })

  it('should not modify normal absolute URL', () => {
    expect(normalizeApiBaseUrl('https://api.example.com/base')).toBe('https://api.example.com/base')
  })

  it('should normalize relative path with leading slash', () => {
    expect(normalizeApiBaseUrl('/api/v2')).toBe('/api/v2')
  })

  it('should normalize relative path without leading slash', () => {
    expect(normalizeApiBaseUrl('api/v2')).toBe('/api/v2')
  })

  it('should normalize relative path with trailing slash', () => {
    expect(normalizeApiBaseUrl('/api/v2/')).toBe('/api/v2')
  })

  it('should handle complex relative paths', () => {
    expect(normalizeApiBaseUrl('  /my-api//  ')).toBe('/my-api')
  })

  it('should keep absolute URL with port intact', () => {
    expect(normalizeApiBaseUrl('http://localhost:3000')).toBe('http://localhost:3000')
  })

  it('should handle https URL', () => {
    expect(normalizeApiBaseUrl('https://prod.example.com/api/')).toBe('https://prod.example.com/api')
  })
})
