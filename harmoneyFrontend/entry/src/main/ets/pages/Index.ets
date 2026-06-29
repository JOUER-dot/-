// file: entry/src/main/ets/pages/Index.ets
import router from '@ohos.router';
import { ColorConstants } from '../theme/ColorConstants';
import { UserStore } from '../stores/UserStore';

@Entry
@Component
struct Index {
  @State booting: boolean = true;

  aboutToAppear(): void {
    this.bootstrap();
  }

  async bootstrap(): Promise<void> {
    const state = await UserStore.restoreSession();
    if (state.token.length > 0) {
      router.replaceUrl({ url: 'pages/MainFrame' });
    } else {
      router.replaceUrl({ url: 'pages/Auth/LoginPage' });
    }
    this.booting = false;
  }

  build() {
    Column({ space: 12 }) {
      LoadingProgress()
        .color(ColorConstants.BRAND_600)
        .width(42)
        .height(42)
      Text('智能投顾')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(ColorConstants.BRAND_600)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
