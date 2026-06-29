// file: entry/src/main/ets/api/fund.ets
import { FundOption, PageResult } from '../models/types';
import { QueryParams, Request } from './request';

export class FundApi {
  static list(params?: QueryParams): Promise<PageResult<FundOption>> {
    return Request.get<PageResult<FundOption>>('/admin/funds', params);
  }
}
