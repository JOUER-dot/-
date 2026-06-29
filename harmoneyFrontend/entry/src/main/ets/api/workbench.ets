// file: entry/src/main/ets/api/workbench.ets
import { WorkbenchData } from '../models/types';
import { Request } from './request';

export class WorkbenchApi {
  static data(): Promise<WorkbenchData> {
    return Request.get<WorkbenchData>('/admin/workbench');
  }
}
