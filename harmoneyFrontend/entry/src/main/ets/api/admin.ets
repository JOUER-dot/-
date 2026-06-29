// file: entry/src/main/ets/api/admin.ets
import { AdminDashboardData, AdminRoleRequest, AdminUser } from '../models/types';
import { QueryParam } from './request';
import { Request } from './request';

export class AdminApi {
  static dashboard(): Promise<AdminDashboardData> {
    return Request.get<AdminDashboardData>('/admin/system/dashboard');
  }

  static users(): Promise<AdminUser[]> {
    return Request.get<AdminUser[]>('/admin/system/users');
  }

  static setUserStatus(id: number, enabled: boolean): Promise<void> {
    return Request.put<void>(`/admin/system/users/${id}/status`, undefined, [new QueryParam('enabled', enabled)]);
  }

  static setUserRole(id: number, roleCode: string): Promise<void> {
    const body: AdminRoleRequest = { roleCode: roleCode };
    return Request.put<void>(`/admin/system/users/${id}/role`, body);
  }
}
