// file: entry/src/main/ets/pages/Auth/LoginPage.ets
import router from '@ohos.router';
import { UserStore } from '../../stores/UserStore';
import { ColorConstants } from '../../theme/ColorConstants';

@Entry
@Component
struct LoginPage {
  @State username: string = 'user01';
  @State password: string = '123456';
  @State remember: boolean = true;
  @State loading: boolean = false;
  @State showPassword: boolean = false;

  async login(): Promise<void> {
    if (this.username.trim().length === 0 || this.password.length === 0) {
      AlertDialog.show({ message: '请输入用户名和密码' });
      return;
    }
    this.loading = true;
    try {
      await UserStore.login(this.username.trim(), this.password);
      router.replaceUrl({ url: 'pages/MainFrame' });
    } catch (error) {
      const rawMessage = `${error}`;
      const message = rawMessage.replace('BUSINESS_ERROR: ', '').replace('NETWORK_ERROR: ', '');
      AlertDialog.show({ message: `登录失败：${message}` });
    } finally {
      this.loading = false;
    }
  }

  build() {
    Scroll() {
      Column({ space: 22 }) {
        Blank()
          .height(56)
        Column({ space: 8 }) {
          Text('📈')
            .fontSize(48)
          Text('智能投顾')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(ColorConstants.BRAND_600)
          Text('一站式基金投顾管理平台')
            .fontSize(13)
            .fontColor(ColorConstants.TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.Center)

        Column({ space: 16 }) {
          TextInput({ text: this.username, placeholder: '请输入用户名' })
            .height(48)
            .borderRadius(12)
            .backgroundColor(ColorConstants.BG_MUTED)
            .onChange((value: string) => this.username = value)
          Row() {
            TextInput({ text: this.password, placeholder: '请输入密码' })
              .type(this.showPassword ? InputType.Normal : InputType.Password)
              .height(48)
              .layoutWeight(1)
              .backgroundColor(Color.Transparent)
              .onChange((value: string) => this.password = value)
            Text(this.showPassword ? '隐藏' : '显示')
              .fontSize(12)
              .fontColor(ColorConstants.BRAND_600)
              .padding({ right: 12 })
              .onClick(() => this.showPassword = !this.showPassword)
          }
          .height(48)
          .borderRadius(12)
          .backgroundColor(ColorConstants.BG_MUTED)

          Row() {
            Toggle({ type: ToggleType.Checkbox, isOn: this.remember })
              .onChange((isOn: boolean) => this.remember = isOn)
            Text('记住我')
              .fontSize(13)
              .fontColor(ColorConstants.TEXT_SECONDARY)
              .margin({ left: 6 })
            Blank()
            Text('默认账号可直接切换登录')
              .fontSize(12)
              .fontColor(ColorConstants.TEXT_HINT)
          }

          Button() {
            Row({ space: 8 }) {
              if (this.loading) {
                LoadingProgress()
                  .width(18)
                  .height(18)
                  .color(Color.White)
              }
              Text(this.loading ? '登录中' : '登录')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
            }
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height(48)
          .borderRadius(10)
          .backgroundColor(ColorConstants.BRAND_600)
          .enabled(!this.loading)
          .onClick(() => this.login())

          Row({ space: 8 }) {
            Button('管理员')
              .height(32)
              .fontSize(12)
              .backgroundColor(ColorConstants.BRAND_50)
              .fontColor(ColorConstants.BRAND_600)
              .onClick(() => { this.username = 'admin'; this.password = 'admin123'; })
            Button('投顾')
              .height(32)
              .fontSize(12)
              .backgroundColor(ColorConstants.BRAND_50)
              .fontColor(ColorConstants.BRAND_600)
              .onClick(() => { this.username = 'advisor01'; this.password = '123456'; })
            Button('审核员')
              .height(32)
              .fontSize(12)
              .backgroundColor(ColorConstants.BRAND_50)
              .fontColor(ColorConstants.BRAND_600)
              .onClick(() => { this.username = 'reviewer01'; this.password = '123456'; })
            Button('用户')
              .height(32)
              .fontSize(12)
              .backgroundColor(ColorConstants.BRAND_50)
              .fontColor(ColorConstants.BRAND_600)
              .onClick(() => { this.username = 'user01'; this.password = '123456'; })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .padding(20)
        .backgroundColor(ColorConstants.BG_CARD)
        .borderRadius(16)

        Row({ space: 6 }) {
          Text('没有账号？')
            .fontSize(13)
            .fontColor(ColorConstants.TEXT_SECONDARY)
          Text('立即注册')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor(ColorConstants.BRAND_600)
            .onClick(() => router.pushUrl({ url: 'pages/Auth/RegisterPage' }))
        }
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .padding(24)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
