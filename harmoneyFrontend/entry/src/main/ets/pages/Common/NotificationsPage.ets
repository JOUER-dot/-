// file: entry/src/main/ets/pages/Common/NotificationsPage.ets
import router from '@ohos.router';
import { NotificationApi } from '../../api/notification';
import { QueryParam } from '../../api/request';
import { NotificationItem } from '../../models/types';
import { EmptyState } from '../../components/ui/EmptyState';
import { NotificationStore } from '../../stores/NotificationStore';
import { ColorConstants } from '../../theme/ColorConstants';
import { shortDate } from '../../utils/format';

@Entry
@Component
struct NotificationsPage {
  @State items: NotificationItem[] = [];

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.items = await NotificationApi.list([
      new QueryParam('pageNum', 1),
      new QueryParam('pageSize', 50)
    ]);
    NotificationStore.refreshUnreadCount();
  }

  async read(item: NotificationItem): Promise<void> {
    await NotificationApi.read(item.id);
    this.load();
  }

  async readAll(): Promise<void> {
    await NotificationApi.readAll();
    this.load();
  }

  build() {
    Column() {
      Row() {
        Text('‹').fontSize(34).fontColor(ColorConstants.BRAND_600).onClick(() => router.back())
        Text('消息通知').fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1)
        Text('全部已读').fontSize(13).fontColor(ColorConstants.BRAND_600).onClick(() => this.readAll())
      }
      .height(56)
      .padding({ left: 16, right: 16 })
      Scroll() {
        Column({ space: 12 }) {
          if (this.items.length === 0) {
            EmptyState({ message: '暂无通知' })
          } else {
            ForEach(this.items, (item: NotificationItem) => {
              Row({ space: 10 }) {
                if (!item.read) {
                  Circle().width(8).height(8).fill(ColorConstants.INFO)
                }
                Text(item.type || '🔔').fontSize(22)
                Column({ space: 4 }) {
                  Text(item.title).fontSize(15).fontWeight(item.read ? FontWeight.Regular : FontWeight.Bold)
                  Text(item.content).fontSize(12).fontColor(ColorConstants.TEXT_SECONDARY).maxLines(2)
                  Text(shortDate(item.createdAt)).fontSize(11).fontColor(ColorConstants.TEXT_HINT)
                }
                .layoutWeight(1)
              }
              .padding(14)
              .backgroundColor(item.read ? ColorConstants.BG_CARD : ColorConstants.BRAND_50)
              .borderRadius(16)
              .onClick(() => this.read(item))
            }, (item: NotificationItem) => `${item.id}`)
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
