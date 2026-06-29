// file: entry/src/main/ets/pages/MainFrame.ets
import { BottomTabBar, TabItem } from '../components/nav/BottomTabBar';
import { TopAppBar } from '../components/nav/TopAppBar';
import { ColorConstants } from '../theme/ColorConstants';
import { USER_ROLES_KEY } from '../utils/persist';
import { homeTitleByRole, primaryRole } from '../utils/role-home';
import { ProductListPage } from './Public/ProductListPage';
import { SubscriptionsPage } from './User/SubscriptionsPage';
import { AccountPage } from './Common/AccountPage';
import { DashboardPage } from './Common/DashboardPage';
import { ProductManagePage } from './Advisor/ProductManagePage';
import { PendingListPage } from './Reviewer/PendingListPage';
import { ReviewHistoryPage } from './Reviewer/ReviewHistoryPage';
import { AdminDashboardPage } from './Admin/AdminDashboardPage';
import { UserManagePage } from './Admin/UserManagePage';

@Entry
@Component
struct MainFrame {
  @StorageLink(USER_ROLES_KEY) roles: string[] = [];
  @State currentTab: number = 0;

  private role(): string {
    return primaryRole(this.roles);
  }

  private tabs(): TabItem[] {
    switch (this.role()) {
      case 'ADMIN':
        return [new TabItem('📈', '运营概览'), new TabItem('👥', '用户管理'), new TabItem('👤', '我的')];
      case 'ADVISOR':
        return [new TabItem('📊', '工作台'), new TabItem('📦', '产品管理'), new TabItem('👤', '我的')];
      case 'REVIEWER':
        return [new TabItem('✅', '待审核'), new TabItem('📜', '审核记录'), new TabItem('👤', '我的')];
      default:
        return [new TabItem('🏠', '产品专区'), new TabItem('📋', '我的订阅'), new TabItem('👤', '我的')];
    }
  }

  private title(): string {
    const list = this.tabs();
    if (this.currentTab >= 0 && this.currentTab < list.length) {
      return list[this.currentTab].text;
    }
    return homeTitleByRole(this.role());
  }

  build() {
    Column() {
      TopAppBar({ title: this.title() })
      Stack() {
        if (this.role() === 'ADMIN') {
          if (this.currentTab === 0) {
            AdminDashboardPage()
          } else if (this.currentTab === 1) {
            UserManagePage()
          } else {
            AccountPage()
          }
        } else if (this.role() === 'ADVISOR') {
          if (this.currentTab === 0) {
            DashboardPage()
          } else if (this.currentTab === 1) {
            ProductManagePage()
          } else {
            AccountPage()
          }
        } else if (this.role() === 'REVIEWER') {
          if (this.currentTab === 0) {
            PendingListPage()
          } else if (this.currentTab === 1) {
            ReviewHistoryPage()
          } else {
            AccountPage()
          }
        } else {
          if (this.currentTab === 0) {
            ProductListPage()
          } else if (this.currentTab === 1) {
            SubscriptionsPage()
          } else {
            AccountPage()
          }
        }
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor(ColorConstants.BG_PAGE)
      BottomTabBar({
        currentIndex: this.currentTab,
        tabs: this.tabs(),
        onChange: (index: number) => this.currentTab = index
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
