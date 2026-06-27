import { describe, it, expect } from 'vitest'
import { getDefaultHomeByRoles } from './role-home'

describe('getDefaultHomeByRoles', () => {
  it('should return advisor zone for USER', () => {
    expect(getDefaultHomeByRoles(['USER'])).toBe('/advisor-zone')
  })

  it('should return admin products for ADVISOR', () => {
    expect(getDefaultHomeByRoles(['ADVISOR'])).toBe('/admin/products')
  })

  it('should return review pending for REVIEWER', () => {
    expect(getDefaultHomeByRoles(['REVIEWER'])).toBe('/review/pending')
  })

  it('should return the first matched role home', () => {
    expect(getDefaultHomeByRoles(['REVIEWER', 'ADVISOR', 'USER'])).toBe('/review/pending')
  })

  it('should return "/" for empty roles', () => {
    expect(getDefaultHomeByRoles([])).toBe('/')
  })

  it('should return "/" for unknown roles', () => {
    expect(getDefaultHomeByRoles(['UNKNOWN_ROLE'])).toBe('/')
  })

  it('should return "/" for roles that have no mapping', () => {
    expect(getDefaultHomeByRoles(['OTHER'])).toBe('/')
  })

  it('should match ADVISOR before USER when both present', () => {
    expect(getDefaultHomeByRoles(['USER', 'ADVISOR'])).toBe('/admin/products')
  })
})
