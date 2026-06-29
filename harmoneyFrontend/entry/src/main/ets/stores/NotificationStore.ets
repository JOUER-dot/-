// file: entry/src/main/ets/stores/NotificationStore.ets
import { NotificationApi } from '../api/notification';
import { UNREAD_COUNT_KEY } from '../utils/persist';

export class NotificationStore {
  static get unreadCount(): number {
    return AppStorage.get<number>(UNREAD_COUNT_KEY) || 0;
  }

  static async refreshUnreadCount(): Promise<number> {
    const result = await NotificationApi.unreadCount();
    const count = result.count || 0;
    AppStorage.setOrCreate<number>(UNREAD_COUNT_KEY, count);
    return count;
  }
}
