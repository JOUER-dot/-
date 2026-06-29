// file: entry/src/main/ets/api/product.ets
import { PageResult, ProductCreateResult, ProductDetail, ProductListItem, ProductSaveRequest, ProductSubmitRequest, PublicAdvisor } from '../models/types';
import { QueryParams, Request } from './request';

export class ProductApi {
  static listPublished(params?: QueryParams): Promise<PageResult<ProductListItem>> {
    return Request.get<PageResult<ProductListItem>>('/public/advisor-products', params);
  }

  static getPublishedDetail(id: number): Promise<ProductDetail> {
    return Request.get<ProductDetail>(`/public/advisor-products/${id}`);
  }

  static listAdvisors(): Promise<PublicAdvisor[]> {
    return Request.get<PublicAdvisor[]>('/public/advisor-products/advisors');
  }

  static listMine(params?: QueryParams): Promise<PageResult<ProductListItem>> {
    return Request.get<PageResult<ProductListItem>>('/admin/products', params);
  }

  static getMineDetail(id: number): Promise<ProductDetail> {
    return Request.get<ProductDetail>(`/admin/products/${id}`);
  }

  static create(data: ProductSaveRequest): Promise<ProductCreateResult> {
    return Request.post<ProductCreateResult>('/admin/products', data);
  }

  static update(id: number, data: ProductSaveRequest): Promise<void> {
    return Request.put<void>(`/admin/products/${id}`, data);
  }

  static submit(id: number, changeType: string, versionNote: string): Promise<void> {
    const body: ProductSubmitRequest = { changeType: changeType, versionNote: versionNote };
    return Request.post<void>(`/admin/products/${id}/submit`, body);
  }

  static withdraw(id: number): Promise<void> {
    return Request.post<void>(`/admin/products/${id}/withdraw`);
  }

  static offline(id: number): Promise<void> {
    return Request.post<void>(`/admin/products/${id}/offline`);
  }

  static remove(id: number): Promise<void> {
    return Request.delete<void>(`/admin/products/${id}`);
  }

  static copy(id: number): Promise<number> {
    return Request.post<number>(`/admin/products/${id}/copy`);
  }

  static generateNav(id: number): Promise<void> {
    return Request.post<void>(`/admin/products/${id}/nav/generate`);
  }
}
