import { describe, it, expect, vi, beforeEach } from 'vitest'
import {
  createProduct,
  updateProduct,
  getProductList,
  getProductDetail,
  submitProduct,
  withdrawProduct,
  offlineProduct,
  deleteProduct,
  copyProduct,
  getProductReviews,
  getProductFlowLogs,
  mapFundToComponent
} from '@/api/product'
import type { FundOption } from '@/api/fund'

// Mock request module
const mockRequest = vi.fn() as any
mockRequest.post = vi.fn()
mockRequest.put = vi.fn()
mockRequest.get = vi.fn()
mockRequest.delete = vi.fn()

vi.mock('@/utils/request', () => ({
  default: mockRequest
}))

describe('product API', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('createProduct', () => {
    it('should POST to /admin/products with payload', async () => {
      const payload = {
        name: '测试产品',
        type: 'STRATEGY',
        riskLevel: 'LOW',
        strategyCode: 'S001',
        featureTags: ['稳健'],
        baseInfo: { manager: '张三' },
        params: {},
        components: []
      }
      mockRequest.post.mockResolvedValue({ productId: 1 })

      const result = await createProduct(payload)
      expect(mockRequest.post).toHaveBeenCalledWith('/admin/products', payload)
      expect(result).toEqual({ productId: 1 })
    })
  })

  describe('updateProduct', () => {
    it('should PUT to /admin/products/:id with payload', async () => {
      const payload = {
        name: '更新产品',
        type: 'FOF',
        riskLevel: 'MEDIUM',
        strategyCode: '',
        featureTags: [],
        baseInfo: {},
        params: {},
        components: []
      }

      await updateProduct(1, payload)
      expect(mockRequest.put).toHaveBeenCalledWith('/admin/products/1', payload)
    })
  })

  describe('getProductList', () => {
    it('should GET /admin/products with query params', async () => {
      mockRequest.get.mockResolvedValue({ records: [], total: 0 })

      const result = await getProductList({ status: 'PUBLISHED', pageNum: 1, pageSize: 20 })
      expect(mockRequest.get).toHaveBeenCalledWith('/admin/products', {
        params: { status: 'PUBLISHED', pageNum: 1, pageSize: 20 }
      })
      expect(result).toEqual({ records: [], total: 0 })
    })
  })

  describe('getProductDetail', () => {
    it('should GET /admin/products/:id', async () => {
      const mockDetail = { id: 1, name: '产品', status: 'PUBLISHED' }
      mockRequest.get.mockResolvedValue(mockDetail)

      const result = await getProductDetail(1)
      expect(mockRequest.get).toHaveBeenCalledWith('/admin/products/1')
      expect(result).toEqual(mockDetail)
    })
  })

  describe('submitProduct', () => {
    it('should POST /admin/products/:id/submit with optional payload', async () => {
      await submitProduct(1, { changeType: 'NORMAL', versionNote: '首次' })
      expect(mockRequest.post).toHaveBeenCalledWith('/admin/products/1/submit', { changeType: 'NORMAL', versionNote: '首次' })
    })

    it('should POST with empty object when no payload', async () => {
      await submitProduct(1)
      expect(mockRequest.post).toHaveBeenCalledWith('/admin/products/1/submit', {})
    })
  })

  describe('withdrawProduct', () => {
    it('should POST /admin/products/:id/withdraw', async () => {
      await withdrawProduct(1)
      expect(mockRequest.post).toHaveBeenCalledWith('/admin/products/1/withdraw')
    })
  })

  describe('offlineProduct', () => {
    it('should POST /admin/products/:id/offline', async () => {
      await offlineProduct(1)
      expect(mockRequest.post).toHaveBeenCalledWith('/admin/products/1/offline')
    })
  })

  describe('deleteProduct', () => {
    it('should DELETE /admin/products/:id', async () => {
      await deleteProduct(1)
      expect(mockRequest.delete).toHaveBeenCalledWith('/admin/products/1')
    })
  })

  describe('copyProduct', () => {
    it('should POST /admin/products/:id/copy and return new id', async () => {
      mockRequest.post.mockResolvedValue(2)
      const result = await copyProduct(1)
      expect(mockRequest.post).toHaveBeenCalledWith('/admin/products/1/copy')
      expect(result).toBe(2)
    })
  })

  describe('getProductReviews', () => {
    it('should GET /admin/products/:id/reviews', async () => {
      const reviews = [{ result: 'APPROVED', comment: '通过' }]
      mockRequest.get.mockResolvedValue(reviews)
      const result = await getProductReviews(1)
      expect(mockRequest.get).toHaveBeenCalledWith('/admin/products/1/reviews')
      expect(result).toEqual(reviews)
    })
  })

  describe('getProductFlowLogs', () => {
    it('should GET /admin/products/:id/flow-logs', async () => {
      const logs = [{ id: 1, actionType: 'CREATE', comment: '创建' }]
      mockRequest.get.mockResolvedValue(logs)
      const result = await getProductFlowLogs(1)
      expect(mockRequest.get).toHaveBeenCalledWith('/admin/products/1/flow-logs')
      expect(result).toEqual(logs)
    })
  })

  describe('mapFundToComponent', () => {
    it('should map FundOption to ProductComponentItem', () => {
      const fund: FundOption = {
        id: 10,
        fundCode: 'FUND001',
        fundName: '测试基金',
        fundType: 'EQUITY',
        riskLevel: 'LOW',
        companyName: '测试公司'
      }

      const result = mapFundToComponent(fund)
      expect(result.fundId).toBe(10)
      expect(result.fundCode).toBe('FUND001')
      expect(result.fundName).toBe('测试基金')
      expect(result.fundType).toBe('EQUITY')
      expect(result.riskLevel).toBe('LOW')
      expect(result.companyName).toBe('测试公司')
      expect(result.weight).toBe(0)
    })
  })
})
