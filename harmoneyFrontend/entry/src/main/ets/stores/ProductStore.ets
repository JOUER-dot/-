// file: entry/src/main/ets/stores/ProductStore.ets
import { ProductApi } from '../api/product';
import { PageResult, ProductListItem } from '../models/types';
import { QueryParam } from '../api/request';

export class ProductStore {
  static async loadPublished(params?: QueryParam[]): Promise<PageResult<ProductListItem>> {
    return ProductApi.listPublished(params);
  }

  static async loadMine(params?: QueryParam[]): Promise<PageResult<ProductListItem>> {
    return ProductApi.listMine(params);
  }
}
