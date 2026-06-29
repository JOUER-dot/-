// file: entry/src/main/ets/api/subscription.ets
import { PageResult, SubscribeRequest, SubscriptionDecisionRequest, SubscriptionItem } from '../models/types';
import { QueryParams, Request } from './request';

export class SubscriptionApi {
  static subscribe(productId: number, amount?: number): Promise<void> {
    const body: SubscribeRequest = { amount: amount || 0 };
    return Request.post<void>(`/public/advisor-products/${productId}/subscribe`, body);
  }

  static unsubscribe(productId: number): Promise<void> {
    return Request.post<void>(`/public/advisor-products/${productId}/unsubscribe`);
  }

  static listMine(params?: QueryParams): Promise<PageResult<SubscriptionItem>> {
    return Request.get<PageResult<SubscriptionItem>>('/auth/my-subscriptions', params);
  }

  static decide(subscriptionId: number, decision: string): Promise<void> {
    const body: SubscriptionDecisionRequest = { decision: decision };
    return Request.post<void>(`/auth/my-subscriptions/${subscriptionId}/version-decision`, body);
  }
}
