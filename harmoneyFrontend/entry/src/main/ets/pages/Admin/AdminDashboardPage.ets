// file: entry/src/main/ets/pages/Admin/AdminDashboardPage.ets
import { AdminApi } from '../../api/admin';
import { AdminDashboardData, ProductSubscription, RecentChange } from '../../models/types';
import { StatCard } from '../../components/ui/StatCard';
import { EmptyState } from '../../components/ui/EmptyState';
import { ColorConstants } from '../../theme/ColorConstants';
import { shortDate } from '../../utils/format';

@Component
export struct AdminDashboardPage {
  @State data: AdminDashboardData | null = null;

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.data = await AdminApi.dashboard();
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text('运营概览')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
        if (this.data === null) {
          EmptyState({ message: '暂无运营数据' })
        } else {
          Grid() {
            GridItem() { StatCard({ label: '产品总数', value: `${this.data!.totalProducts}` }) }
            GridItem() { StatCard({ label: '已发布', value: `${this.data!.publishedProducts}`, color: ColorConstants.SUCCESS }) }
            GridItem() { StatCard({ label: '待审核', value: `${this.data!.pendingReviewProducts}`, color: ColorConstants.WARNING }) }
            GridItem() { StatCard({ label: '投顾数', value: `${this.data!.totalAdvisors}` }) }
            GridItem() { StatCard({ label: '用户数', value: `${this.data!.totalUsers}` }) }
            GridItem() { StatCard({ label: '总订阅数', value: `${this.data!.totalSubscriptions}`, color: ColorConstants.INFO }) }
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(10)
          .rowsGap(10)
          .width('100%')

          Text('最热产品榜')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
          ForEach(this.data!.topSubscribedProducts || [], (item: ProductSubscription, index: number) => {
            Row() {
              Text(`${index + 1}`).fontSize(15).fontWeight(FontWeight.Bold).fontColor(ColorConstants.GOLD).width(28)
              Text(item.productName).fontSize(14).layoutWeight(1)
              Text(`${item.subscriberCount} 订阅`).fontSize(12).fontColor(ColorConstants.TEXT_SECONDARY)
            }
            .padding(12)
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(12)
          }, (item: ProductSubscription) => `${item.productId}`)

          Text('最近动态')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
          ForEach(this.data!.recentChanges || [], (item: RecentChange) => {
            Column({ space: 4 }) {
              Text(item.productName).fontSize(14).fontWeight(FontWeight.Medium)
              Text(`${item.actionType} · ${item.operatorName} · ${shortDate(item.createdAt)}`)
                .fontSize(12)
                .fontColor(ColorConstants.TEXT_HINT)
            }
            .padding(12)
            .width('100%')
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(12)
          }, (item: RecentChange) => `${item.productId}-${item.createdAt}`)
        }
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
