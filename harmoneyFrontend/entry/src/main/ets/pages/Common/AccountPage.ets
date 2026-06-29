// file: entry/src/main/ets/pages/Common/AccountPage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { AuthApi, ProfileUpdateRequest } from '../../api/auth';
import { UserStore } from '../../stores/UserStore';
import { UserInfo } from '../../models/types';
import { ColorConstants } from '../../theme/ColorConstants';
import { firstChar } from '../../utils/format';
import { roleText } from '../../utils/status';
import { USER_INFO_KEY, USER_ROLES_KEY } from '../../utils/persist';

@Component
export struct AccountPage {
  @StorageLink(USER_INFO_KEY) userInfo: UserInfo | null = null;
  @StorageLink(USER_ROLES_KEY) roles: string[] = [];
  @State nickname: string = '';
  @State phone: string = '';
  @State email: string = '';

  aboutToAppear(): void {
    this.nickname = this.userInfo?.nickname || '';
    this.phone = this.userInfo?.phone || '';
    this.email = this.userInfo?.email || '';
  }

  async saveProfile(): Promise<void> {
    const body: ProfileUpdateRequest = {
      nickname: this.nickname,
      phone: this.phone,
      email: this.email
    };
    await UserStore.updateProfile(body);
    promptAction.showToast({ message: '资料已更新' });
  }

  async logout(): Promise<void> {
    await UserStore.logout(true);
    router.replaceUrl({ url: 'pages/Auth/LoginPage' });
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 10 }) {
          Text(firstChar(this.userInfo?.nickname || this.userInfo?.username))
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .width(76)
            .height(76)
            .backgroundColor(ColorConstants.BRAND_600)
            .borderRadius(38)
          Text(this.userInfo?.username || '-')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          Row({ space: 6 }) {
            ForEach(this.roles, (role: string) => {
              Text(roleText(role))
                .fontSize(11)
                .fontColor(ColorConstants.BRAND_600)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor(ColorConstants.BRAND_50)
                .borderRadius(999)
            }, (role: string) => role)
          }
        }
        .width('100%')
        .padding(20)
        .backgroundColor(ColorConstants.BG_CARD)
        .borderRadius(16)
        .alignItems(HorizontalAlign.Center)

        this.field('昵称', this.nickname, (value: string) => this.nickname = value)
        this.field('手机号', this.phone, (value: string) => this.phone = value)
        this.field('邮箱', this.email, (value: string) => this.email = value)
        Button('保存资料')
          .width('100%')
          .height(44)
          .backgroundColor(ColorConstants.BRAND_600)
          .onClick(() => this.saveProfile())

        Button('交易记录')
          .width('100%')
          .height(44)
          .backgroundColor(ColorConstants.BRAND_50)
          .fontColor(ColorConstants.BRAND_600)
          .onClick(() => router.pushUrl({ url: 'pages/User/TransactionPage' }))
        Button('设置交易密码')
          .width('100%')
          .height(44)
          .backgroundColor(ColorConstants.BG_CARD)
          .fontColor(ColorConstants.TEXT_SECONDARY)
          .onClick(() => AuthApi.setPin('123456').then(() => promptAction.showToast({ message: '已设置默认交易密码' })))
        Button('退出登录')
          .width('100%')
          .height(44)
          .backgroundColor(ColorConstants.DANGER_BG)
          .fontColor(ColorConstants.DANGER)
          .onClick(() => AlertDialog.show({
            message: '确认退出登录？',
            primaryButton: { value: '取消', action: () => {} },
            secondaryButton: { value: '退出', action: () => this.logout() }
          }))
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }

  @Builder
  field(label: string, value: string, onChange: (value: string) => void) {
    Column({ space: 6 }) {
      Text(label).fontSize(13).fontColor(ColorConstants.TEXT_SECONDARY)
      TextInput({ text: value, placeholder: label })
        .height(44)
        .backgroundColor(ColorConstants.BG_CARD)
        .borderRadius(12)
        .onChange(onChange)
    }
  }
}
