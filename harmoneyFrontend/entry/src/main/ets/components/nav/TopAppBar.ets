// file: entry/src/main/ets/components/nav/TopAppBar.ets
import router from '@ohos.router';
import { ColorConstants } from '../../theme/ColorConstants';
import { NotificationStore } from '../../stores/NotificationStore';
import { firstChar } from '../../utils/format';
import { USER_INFO_KEY, UNREAD_COUNT_KEY } from '../../utils/persist';
import { UserInfo } from '../../models/types';

@Component
export struct TopAppBar {
  @Prop title: string = '';
  @StorageLink(UNREAD_COUNT_KEY) unreadCount: number = 0;
  @StorageLink(USER_INFO_KEY) userInfo: UserInfo | null = null;

  aboutToAppear(): void {
    NotificationStore.refreshUnreadCount();
  }

  build() {
    Row() {
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(ColorConstants.TEXT_PRIMARY)
        .layoutWeight(1)

      Stack({ alignContent: Alignment.TopEnd }) {
        Text('🔔')
          .fontSize(22)
          .padding(8)
        if (this.unreadCount > 0) {
          Text(this.unreadCount > 99 ? '99+' : `${this.unreadCount}`)
            .fontSize(9)
            .fontColor(Color.White)
            .padding({ left: 5, right: 5, top: 2, bottom: 2 })
            .backgroundColor(ColorConstants.DANGER)
            .borderRadius(99)
        }
      }
      .onClick(() => router.pushUrl({ url: 'pages/Common/NotificationsPage' }))

      Text(firstChar(this.userInfo?.nickname || this.userInfo?.username))
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .width(34)
        .height(34)
        .backgroundColor(ColorConstants.BRAND_600)
        .borderRadius(17)
        .margin({ left: 8 })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(ColorConstants.BG_CARD)
    .border({ width: { bottom: 1 }, color: ColorConstants.BORDER })
  }
}
