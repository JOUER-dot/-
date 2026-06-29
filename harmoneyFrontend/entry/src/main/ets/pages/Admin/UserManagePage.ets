// file: entry/src/main/ets/pages/Admin/UserManagePage.ets
import promptAction from '@ohos.promptAction';
import { AdminApi } from '../../api/admin';
import { AdminUser } from '../../models/types';
import { EmptyState } from '../../components/ui/EmptyState';
import { ColorConstants } from '../../theme/ColorConstants';
import { roleText } from '../../utils/status';
import { shortDate } from '../../utils/format';

@Component
export struct UserManagePage {
  @State users: AdminUser[] = [];

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.users = await AdminApi.users();
  }

  async toggleStatus(user: AdminUser, enabled: boolean): Promise<void> {
    await AdminApi.setUserStatus(user.id, enabled);
    promptAction.showToast({ message: enabled ? '已启用' : '已禁用' });
    this.load();
  }

  async setRole(user: AdminUser, role: string): Promise<void> {
    await AdminApi.setUserRole(user.id, role);
    promptAction.showToast({ message: '角色已更新' });
    this.load();
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text('用户管理')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
        if (this.users.length === 0) {
          EmptyState({ message: '暂无用户' })
        } else {
          ForEach(this.users, (user: AdminUser) => {
            Column({ space: 10 }) {
              Row() {
                Column({ space: 4 }) {
                  Text(user.username)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                  Text(`${user.nickname || '-'} · ${user.phone || '-'} · ${shortDate(user.createdAt)}`)
                    .fontSize(12)
                    .fontColor(ColorConstants.TEXT_HINT)
                }
                .layoutWeight(1)
                Toggle({ type: ToggleType.Switch, isOn: user.status === 1 })
                  .onChange((isOn: boolean) => this.toggleStatus(user, isOn))
              }
              Row({ space: 6 }) {
                ForEach(user.roles || [], (role: string) => {
                  Text(roleText(role))
                    .fontSize(11)
                    .fontColor(ColorConstants.BRAND_600)
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor(ColorConstants.BRAND_50)
                    .borderRadius(999)
                }, (role: string) => role)
              }
              Row({ space: 8 }) {
                ForEach(['USER', 'ADVISOR', 'REVIEWER', 'ADMIN'], (role: string) => {
                  Button(roleText(role))
                    .height(30)
                    .fontSize(11)
                    .backgroundColor(ColorConstants.BG_MUTED)
                    .fontColor(ColorConstants.TEXT_SECONDARY)
                    .onClick(() => this.setRole(user, role))
                }, (role: string) => role)
              }
            }
            .padding(16)
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(16)
            .border({ width: 1, color: ColorConstants.BORDER })
          }, (user: AdminUser) => `${user.id}`)
        }
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
