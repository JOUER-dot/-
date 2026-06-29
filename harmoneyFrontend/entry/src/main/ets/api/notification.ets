// file: entry/src/main/ets/api/notification.ets
import { NotificationItem, NotificationUnreadCount } from '../models/types';
import { QueryParams, Request } from './request';

export class NotificationApi {
  static list(params?: QueryParams): Promise<NotificationItem[]> {
    return Request.get<NotificationItem[]>('/notifications', params);
  }

  static unreadCount(): Promise<NotificationUnreadCount> {
    return Request.get<NotificationUnreadCount>('/notifications/unread-count');
  }

  static read(id: number): Promise<void> {
    return Request.post<void>(`/notifications/${id}/read`);
  }

  static readAll(): Promise<void> {
    return Request.post<void>('/notifications/read-all');
  }
}
