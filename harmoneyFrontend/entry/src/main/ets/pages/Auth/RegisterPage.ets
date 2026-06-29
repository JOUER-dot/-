// file: entry/src/main/ets/pages/Auth/RegisterPage.ets
import router from '@ohos.router';
import { AuthApi } from '../../api/auth';
import { ColorConstants } from '../../theme/ColorConstants';

@Entry
@Component
struct RegisterPage {
  @State username: string = '';
  @State nickname: string = '';
  @State phone: string = '';
  @State email: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State loading: boolean = false;

  private validate(): string {
    if (this.username.length < 3 || this.username.length > 20) {
      return '用户名需为 3-20 个字符';
    }
    if (this.password.length < 6) {
      return '密码至少 6 位';
    }
    if (this.password !== this.confirmPassword) {
      return '两次密码不一致';
    }
    if (this.phone.length > 0 && !/^1\d{10}$/.test(this.phone)) {
      return '手机号需为 11 位数字';
    }
    return '';
  }

  async register(): Promise<void> {
    const error = this.validate();
    if (error.length > 0) {
      AlertDialog.show({ message: error });
      return;
    }
    this.loading = true;
    try {
      await AuthApi.register({
        username: this.username,
        password: this.password,
        confirmPassword: this.confirmPassword,
        nickname: this.nickname || this.username,
        phone: this.phone,
        email: this.email
      });
      AlertDialog.show({
        message: '注册成功，请登录',
        primaryButton: { value: '去登录', action: () => router.replaceUrl({ url: 'pages/Auth/LoginPage' }) }
      });
    } catch (error) {
      AlertDialog.show({ message: '注册失败，请稍后重试' });
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Text('‹')
          .fontSize(34)
          .fontColor(ColorConstants.BRAND_600)
          .onClick(() => router.back())
        Text('注册账号')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(ColorConstants.TEXT_PRIMARY)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      Scroll() {
        Column({ space: 14 }) {
          this.input('用户名', this.username, '3-20 字符', (value: string) => this.username = value)
          this.input('昵称', this.nickname, '请输入昵称', (value: string) => this.nickname = value)
          this.input('手机号', this.phone, '选填', (value: string) => this.phone = value)
          this.input('邮箱', this.email, '选填', (value: string) => this.email = value)
          this.input('密码', this.password, '6 位以上', (value: string) => this.password = value, true)
          this.input('确认密码', this.confirmPassword, '再次输入密码', (value: string) => this.confirmPassword = value, true)
          Button(this.loading ? '提交中' : '注册')
            .width('100%')
            .height(48)
            .backgroundColor(ColorConstants.BRAND_600)
            .fontColor(Color.White)
            .borderRadius(10)
            .enabled(!this.loading)
            .onClick(() => this.register())
          Row({ space: 4 }) {
            Text('已有账号？')
              .fontSize(13)
              .fontColor(ColorConstants.TEXT_SECONDARY)
            Text('立即登录')
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor(ColorConstants.BRAND_600)
              .onClick(() => router.replaceUrl({ url: 'pages/Auth/LoginPage' }))
          }
          .justifyContent(FlexAlign.Center)
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }

  @Builder
  input(label: string, value: string, placeholder: string, onChange: (value: string) => void, password: boolean = false) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(13)
        .fontColor(ColorConstants.TEXT_SECONDARY)
      TextInput({ text: value, placeholder: placeholder })
        .height(46)
        .type(password ? InputType.Password : InputType.Normal)
        .backgroundColor(ColorConstants.BG_CARD)
        .borderRadius(12)
        .onChange(onChange)
    }
    .width('100%')
  }
}
