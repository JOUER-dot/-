import { describe, it, expect } from 'vitest'
import {
  productStatusLabel,
  productStatusTagType,
  productTypeLabel,
  productTypeOptions,
  subscriptionStatusLabel,
  subscriptionStatusTagType,
  reviewResultLabel
} from './status'

describe('productStatusLabel', () => {
  it('should return "草稿" for DRAFT', () => {
    expect(productStatusLabel('DRAFT')).toBe('草稿')
  })

  it('should return "待审核" for PENDING_REVIEW', () => {
    expect(productStatusLabel('PENDING_REVIEW')).toBe('待审核')
  })

  it('should return "已驳回" for REJECTED', () => {
    expect(productStatusLabel('REJECTED')).toBe('已驳回')
  })

  it('should return "已上架" for PUBLISHED', () => {
    expect(productStatusLabel('PUBLISHED')).toBe('已上架')
  })

  it('should return "已下架" for OFFLINE', () => {
    expect(productStatusLabel('OFFLINE')).toBe('已下架')
  })

  it('should return the input itself for unknown status', () => {
    expect(productStatusLabel('UNKNOWN')).toBe('UNKNOWN')
  })
})

describe('productStatusTagType', () => {
  it('should return "success" for PUBLISHED', () => {
    expect(productStatusTagType('PUBLISHED')).toBe('success')
  })

  it('should return "warning" for PENDING_REVIEW', () => {
    expect(productStatusTagType('PENDING_REVIEW')).toBe('warning')
  })

  it('should return "danger" for REJECTED', () => {
    expect(productStatusTagType('REJECTED')).toBe('danger')
  })

  it('should return "info" for DRAFT', () => {
    expect(productStatusTagType('DRAFT')).toBe('info')
  })

  it('should return "info" for OFFLINE', () => {
    expect(productStatusTagType('OFFLINE')).toBe('info')
  })

  it('should return "info" for unknown status', () => {
    expect(productStatusTagType('UNKNOWN')).toBe('info')
  })
})

describe('productTypeLabel', () => {
  it('should return "策略组合" for STRATEGY', () => {
    expect(productTypeLabel('STRATEGY')).toBe('策略组合')
  })

  it('should return "FOF组合" for FOF', () => {
    expect(productTypeLabel('FOF')).toBe('FOF组合')
  })

  it('should return the input itself for unknown type', () => {
    expect(productTypeLabel('STOCK_PICKING')).toBe('STOCK_PICKING')
  })
})

describe('productTypeOptions', () => {
  it('should return both type options', () => {
    const options = productTypeOptions()
    expect(options).toHaveLength(2)
    expect(options[0]).toEqual({ label: '策略组合', value: 'STRATEGY' })
    expect(options[1]).toEqual({ label: 'FOF组合', value: 'FOF' })
  })
})

describe('subscriptionStatusLabel', () => {
  it('should return "已订阅" for ACTIVE', () => {
    expect(subscriptionStatusLabel('ACTIVE')).toBe('已订阅')
  })

  it('should return "已取消" for CANCELLED', () => {
    expect(subscriptionStatusLabel('CANCELLED')).toBe('已取消')
  })

  it('should return the input for unknown status', () => {
    expect(subscriptionStatusLabel('UNKNOWN')).toBe('UNKNOWN')
  })
})

describe('subscriptionStatusTagType', () => {
  it('should return "success" for ACTIVE', () => {
    expect(subscriptionStatusTagType('ACTIVE')).toBe('success')
  })

  it('should return "warning" for CANCELLED', () => {
    expect(subscriptionStatusTagType('CANCELLED')).toBe('warning')
  })

  it('should return "info" for unknown', () => {
    expect(subscriptionStatusTagType('UNKNOWN')).toBe('info')
  })
})

describe('reviewResultLabel', () => {
  it('should return "已通过" for APPROVED', () => {
    expect(reviewResultLabel('APPROVED')).toBe('已通过')
  })

  it('should return "已驳回" for REJECTED', () => {
    expect(reviewResultLabel('REJECTED')).toBe('已驳回')
  })

  it('should return "已提交" for SUBMITTED', () => {
    expect(reviewResultLabel('SUBMITTED')).toBe('已提交')
  })

  it('should return "已撤回" for WITHDRAWN', () => {
    expect(reviewResultLabel('WITHDRAWN')).toBe('已撤回')
  })

  it('should return the input for unknown status', () => {
    expect(reviewResultLabel('UNKNOWN')).toBe('UNKNOWN')
  })
})
