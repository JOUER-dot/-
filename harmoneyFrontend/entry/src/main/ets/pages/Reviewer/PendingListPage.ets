// file: entry/src/main/ets/pages/Reviewer/PendingListPage.ets
import router from '@ohos.router';
import { ReviewApi } from '../../api/review';
import { QueryParam } from '../../api/request';
import { ProductListItem } from '../../models/types';
import { StatusTag } from '../../components/ui/StatusTag';
import { EmptyState } from '../../components/ui/EmptyState';
import { SkeletonLoader } from '../../components/ui/SkeletonLoader';
import { ColorConstants } from '../../theme/ColorConstants';
import { shortDate } from '../../utils/format';

@Component
export struct PendingListPage {
  @State keyword: string = '';
  @State riskLevel: string = '';
  @State products: ProductListItem[] = [];
  @State total: number = 0;
  @State loading: boolean = true;

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.loading = true;
    try {
      const page = await ReviewApi.listPending([
        new QueryParam('keyword', this.keyword),
        new QueryParam('riskLevel', this.riskLevel),
        new QueryParam('pageNum', 1),
        new QueryParam('pageSize', 30)
      ]);
      this.products = page.records || [];
      this.total = page.total || 0;
    } finally {
      this.loading = false;
    }
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Row() {
          Text('待审核')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
          Text(`共 ${this.total} 条`)
            .fontSize(13)
            .fontColor(ColorConstants.TEXT_SECONDARY)
        }
        Row({ space: 8 }) {
          TextInput({ text: this.keyword, placeholder: '搜索产品/策略码' })
            .height(40)
            .layoutWeight(1)
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(12)
            .onChange((value: string) => this.keyword = value)
          Button('查询')
            .height(40)
            .backgroundColor(ColorConstants.BRAND_600)
            .onClick(() => this.load())
        }
        Scroll() {
          Row({ space: 8 }) {
            this.riskChip('全部', '')
            ForEach(['R1', 'R2', 'R3', 'R4', 'R5'], (risk: string) => this.riskChip(risk, risk), (risk: string) => risk)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)

        if (this.loading) {
          SkeletonLoader({ rows: 3 })
        } else if (this.products.length === 0) {
          EmptyState({ message: '暂无待审产品' })
        } else {
          ForEach(this.products, (item: ProductListItem) => {
            Column({ space: 8 }) {
              Row() {
                Text(item.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)
                StatusTag({ status: item.status || 'PENDING_REVIEW', type: 'product' })
              }
              Row({ space: 8 }) {
                StatusTag({ status: item.riskLevel, type: 'risk' })
                Text(`创建人：${item.creatorName || '-'}`)
                  .fontSize(12)
                  .fontColor(ColorConstants.TEXT_SECONDARY)
                Text(`V${item.versionNo || '-'}`)
                  .fontSize(12)
                  .fontColor(ColorConstants.TEXT_HINT)
              }
              Row() {
                Text(`${item.changeType || 'NORMAL'} · ${shortDate(item.submittedAt)}`)
                  .fontSize(12)
                  .fontColor(item.changeType === 'MAJOR' ? ColorConstants.DANGER : ColorConstants.INFO)
                  .layoutWeight(1)
                Text('查看审核 →')
                  .fontSize(12)
                  .fontColor(ColorConstants.BRAND_600)
              }
            }
            .padding(16)
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(16)
            .border({ width: 1, color: ColorConstants.BORDER })
            .onClick(() => router.pushUrl({ url: 'pages/Reviewer/ReviewDetailPage', params: { id: item.id } }))
          }, (item: ProductListItem) => `${item.id}`)
        }
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }

  @Builder
  riskChip(label: string, value: string) {
    Text(label)
      .fontSize(12)
      .fontColor(this.riskLevel === value ? Color.White : ColorConstants.TEXT_SECONDARY)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.riskLevel === value ? ColorConstants.BRAND_600 : ColorConstants.BG_CARD)
      .borderRadius(999)
      .onClick(() => { this.riskLevel = value; this.load(); })
  }
}
