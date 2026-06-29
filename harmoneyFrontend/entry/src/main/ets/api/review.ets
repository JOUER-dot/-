// file: entry/src/main/ets/api/review.ets
import { PageResult, ProductListItem, ReviewApproveRequest, ReviewDetail, ReviewRecord, ReviewRejectRequest } from '../models/types';
import { QueryParams, Request } from './request';

export class ReviewApi {
  static listPending(params?: QueryParams): Promise<PageResult<ProductListItem>> {
    return Request.get<PageResult<ProductListItem>>('/reviewer/products/pending', params);
  }

  static detail(id: number): Promise<ReviewDetail> {
    return Request.get<ReviewDetail>(`/reviewer/products/${id}`);
  }

  static approve(id: number, decisionComment: string): Promise<void> {
    const body: ReviewApproveRequest = { decisionComment: decisionComment };
    return Request.post<void>(`/reviewer/products/${id}/approve`, body);
  }

  static reject(id: number, comment: string): Promise<void> {
    const body: ReviewRejectRequest = { comment: comment };
    return Request.post<void>(`/reviewer/products/${id}/reject`, body);
  }

  static history(params?: QueryParams): Promise<ReviewRecord[]> {
    return Request.get<ReviewRecord[]>('/reviewer/products/my-history', params);
  }
}
