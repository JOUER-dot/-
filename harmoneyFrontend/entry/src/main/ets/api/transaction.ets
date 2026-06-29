// file: entry/src/main/ets/api/transaction.ets
import { PageResult, TransactionRecord } from '../models/types';
import { QueryParams, Request } from './request';

export class TransactionApi {
  static list(params?: QueryParams): Promise<PageResult<TransactionRecord>> {
    return Request.get<PageResult<TransactionRecord>>('/auth/transactions', params);
  }
}
