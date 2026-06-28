import { describe, it, expect } from 'vitest'
import { formatDecimal, formatPercent, formatText } from './format'

describe('formatDecimal', () => {
  it('should format a number to 4 decimal places by default', () => {
    expect(formatDecimal(1.23456789)).toBe('1.2346')
  })

  it('should format with custom digits', () => {
    expect(formatDecimal(1.23456789, 2)).toBe('1.23')
  })

  it('should return "-" for NaN', () => {
    expect(formatDecimal(NaN)).toBe('-')
  })

  it('should return "-" for Infinity', () => {
    expect(formatDecimal(Infinity)).toBe('-')
  })

  it('should return "-" for -Infinity', () => {
    expect(formatDecimal(-Infinity)).toBe('-')
  })

  it('should handle string input', () => {
    expect(formatDecimal('3.14159', 2)).toBe('3.14')
  })

  it('should handle null input', () => {
    expect(formatDecimal(null)).toBe('0.0000')
  })

  it('should handle undefined input', () => {
    expect(formatDecimal(undefined)).toBe('-')
  })

  it('should format 0 correctly', () => {
    expect(formatDecimal(0)).toBe('0.0000')
  })

  it('should format negative numbers', () => {
    expect(formatDecimal(-1.5, 2)).toBe('-1.50')
  })
})

describe('formatPercent', () => {
  it('should convert decimal to percentage with 2 decimal places', () => {
    expect(formatPercent(0.0567)).toBe('5.67%')
  })

  it('should handle zero', () => {
    expect(formatPercent(0)).toBe('0.00%')
  })

  it('should handle 1 (100%)', () => {
    expect(formatPercent(1)).toBe('100.00%')
  })

  it('should return "-" for NaN', () => {
    expect(formatPercent(NaN)).toBe('-')
  })

  it('should return "-" for Infinity', () => {
    expect(formatPercent(Infinity)).toBe('-')
  })

  it('should handle string input', () => {
    expect(formatPercent('0.1234')).toBe('12.34%')
  })

  it('should handle negative values', () => {
    expect(formatPercent(-0.05)).toBe('-5.00%')
  })

  it('should handle custom digits', () => {
    expect(formatPercent(0.123456, 4)).toBe('12.3456%')
  })
})

describe('formatText', () => {
  it('should return the string for a string input', () => {
    expect(formatText('hello')).toBe('hello')
  })

  it('should return "-" for null', () => {
    expect(formatText(null)).toBe('-')
  })

  it('should return "-" for undefined', () => {
    expect(formatText(undefined)).toBe('-')
  })

  it('should return "-" for empty string', () => {
    expect(formatText('')).toBe('-')
  })

  it('should convert number to string', () => {
    expect(formatText(42)).toBe('42')
  })

  it('should convert boolean to string', () => {
    expect(formatText(true)).toBe('true')
  })
})
