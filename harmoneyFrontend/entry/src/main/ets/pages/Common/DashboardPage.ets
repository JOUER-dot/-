// file: entry/src/main/ets/pages/Common/DashboardPage.ets
import { WorkbenchApi } from '../../api/workbench';
import { ProductListItem, WorkbenchData } from '../../models/types';
import { StatCard } from '../../components/ui/StatCard';
import { EmptyState } from '../../components/ui/EmptyState';
import { ColorConstants } from '../../theme/ColorConstants';

@Component
export struct DashboardPage {
  @State data: WorkbenchData | null = null;

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.data = await WorkbenchApi.data();
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text('工作台')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
        if (this.data === null) {
          EmptyState({ message: '暂无工作台数据' })
        } else {
          Grid() {
            GridItem() { StatCard({ label: '产品总数', value: `${this.data!.overview.totalProducts}` }) }
            GridItem() { StatCard({ label: '已发布', value: `${this.data!.overview.publishedProducts}`, color: ColorConstants.SUCCESS }) }
            GridItem() { StatCard({ label: '待审核', value: `${this.data!.overview.pendingReviewProducts}`, color: ColorConstants.WARNING }) }
            GridItem() { StatCard({ label: '被驳回', value: `${this.data!.overview.rejectedProducts}`, color: ColorConstants.DANGER }) }
            GridItem() { StatCard({ label: '草稿', value: `${this.data!.overview.draftProducts}` }) }
            GridItem() { StatCard({ label: '总订阅', value: `${this.data!.overview.totalSubscriptions}` }) }
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(10)
          .rowsGap(10)
          .width('100%')

          Text('紧急事项')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
          ForEach(this.data!.urgentProducts || [], (item: ProductListItem) => {
            Text(`${item.name} · ${item.status} · ${item.lastRejectComment || '待处理'}`)
              .fontSize(13)
              .fontColor(ColorConstants.DANGER)
              .padding(12)
              .width('100%')
              .backgroundColor(ColorConstants.DANGER_BG)
              .borderRadius(12)
          }, (item: ProductListItem) => `${item.id}`)

          Text('产品排名')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
          ForEach(this.data!.productRankings || [], (item: ProductListItem, index: number) => {
            Row() {
              Text(`${index + 1}`).fontSize(15).fontWeight(FontWeight.Bold).fontColor(ColorConstants.GOLD).width(28)
              Text(item.name).fontSize(14).layoutWeight(1)
              Text(item.riskLevel).fontSize(12).fontColor(ColorConstants.TEXT_HINT)
            }
            .padding(12)
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(12)
          }, (item: ProductListItem) => `${item.id}`)
        }
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
