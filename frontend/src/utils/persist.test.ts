import { describe, it, expect, vi, beforeEach } from 'vitest'
import { loadPersisted, savePersisted } from './persist'

describe('persist utilities', () => {
  beforeEach(() => {
    localStorage.clear()
  })

  describe('loadPersisted', () => {
    it('should return fallback when key does not exist', () => {
      expect(loadPersisted('nonexistent', 'default')).toBe('default')
    })

    it('should return parsed value when key exists', () => {
      localStorage.setItem('testKey', JSON.stringify({ a: 1, b: 2 }))
      const result = loadPersisted('testKey', {})
      expect(result).toEqual({ a: 1, b: 2 })
    })

    it('should return fallback for invalid JSON', () => {
      localStorage.setItem('invalid', '{not json}')
      expect(loadPersisted('invalid', 'fallback')).toBe('fallback')
    })

    it('should return fallback for null value', () => {
      expect(loadPersisted('nullKey', null)).toBeNull()
    })

    it('should return number type correctly', () => {
      localStorage.setItem('numKey', '42')
      expect(loadPersisted('numKey', 0)).toBe(42)
    })

    it('should return boolean type correctly', () => {
      localStorage.setItem('boolKey', 'true')
      expect(loadPersisted('boolKey', false)).toBe(true)
    })

    it('should return array type correctly', () => {
      localStorage.setItem('arrKey', JSON.stringify([1, 2, 3]))
      expect(loadPersisted('arrKey', [])).toEqual([1, 2, 3])
    })
  })

  describe('savePersisted', () => {
    it('should save a value to localStorage', () => {
      savePersisted('key', { name: 'test' })
      const raw = localStorage.getItem('key')
      expect(raw).toBe(JSON.stringify({ name: 'test' }))
    })

    it('should save a string value', () => {
      savePersisted('strKey', 'hello')
      expect(localStorage.getItem('strKey')).toBe('"hello"')
    })

    it('should save a number', () => {
      savePersisted('numKey', 123)
      expect(localStorage.getItem('numKey')).toBe('123')
    })

    it('should save null', () => {
      savePersisted('nullKey', null)
      expect(localStorage.getItem('nullKey')).toBe('null')
    })

    it('should save an array', () => {
      savePersisted('arrKey', [1, 2, 3])
      expect(JSON.parse(localStorage.getItem('arrKey')!)).toEqual([1, 2, 3])
    })

    it('should overwrite existing key', () => {
      localStorage.setItem('key', 'old')
      savePersisted('key', 'new')
      expect(localStorage.getItem('key')).toBe('"new"')
    })
  })

  describe('loadPersisted + savePersisted round-trip', () => {
    it('should round-trip complex objects', () => {
      const obj = { user: { id: 1, name: 'Alice' }, roles: ['USER', 'ADVISOR'] }
      savePersisted('session', obj)
      const loaded = loadPersisted('session', null)
      expect(loaded).toEqual(obj)
    })
  })
})
