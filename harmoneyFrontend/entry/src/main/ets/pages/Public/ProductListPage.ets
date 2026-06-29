// file: entry/src/main/ets/pages/Public/ProductListPage.ets
import router from '@ohos.router';
import { ProductApi } from '../../api/product';
import { QueryParam } from '../../api/request';
import { PublicAdvisor, ProductListItem } from '../../models/types';
import { ProductCard } from '../../components/product/ProductCard';
import { EmptyState } from '../../components/ui/EmptyState';
import { SkeletonLoader } from '../../components/ui/SkeletonLoader';
import { ColorConstants } from '../../theme/ColorConstants';

@Component
export struct ProductListPage {
  @State keyword: string = '';
  @State type: string = '';
  @State riskLevel: string = '';
  @State creatorId: number = 0;
  @State sort: string = '推荐排序';
  @State products: ProductListItem[] = [];
  @State advisors: PublicAdvisor[] = [];
  @State loading: boolean = true;

  aboutToAppear(): void {
    this.load();
    this.loadAdvisors();
  }

  async load(): Promise<void> {
    this.loading = true;
    try {
      const page = await ProductApi.listPublished([
        new QueryParam('keyword', this.keyword),
        new QueryParam('type', this.type),
        new QueryParam('riskLevel', this.riskLevel),
        new QueryParam('creatorId', this.creatorId > 0 ? this.creatorId : undefined),
        new QueryParam('pageNum', 1),
        new QueryParam('pageSize', 20)
      ]);
      this.products = page.records || [];
    } finally {
      this.loading = false;
    }
  }

  async loadAdvisors(): Promise<void> {
    try {
      this.advisors = await ProductApi.listAdvisors();
    } catch (error) {
      this.advisors = [];
    }
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Row({ space: 8 }) {
          TextInput({ text: this.keyword, placeholder: '搜索产品名称...' })
            .height(42)
            .layoutWeight(1)
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(12)
            .onChange((value: string) => this.keyword = value)
          Button('查询')
            .height(42)
            .backgroundColor(ColorConstants.BRAND_600)
            .onClick(() => this.load())
        }

        Scroll() {
          Row({ space: 8 }) {
            this.filterChip('全部', this.type === '', () => this.type = '')
            this.filterChip('策略组合', this.type === 'STRATEGY', () => this.type = 'STRATEGY')
            this.filterChip('FOF组合', this.type === 'FOF', () => this.type = 'FOF')
            ForEach(['R1', 'R2', 'R3', 'R4', 'R5'], (risk: string) => {
              this.filterChip(risk, this.riskLevel === risk, () => this.riskLevel = risk)
            }, (risk: string) => risk)
            this.filterChip(this.sort, true, () => this.sort = this.sort === '推荐排序' ? '风险从低到高' : '推荐排序')
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)

        if (this.loading) {
          SkeletonLoader({ rows: 3 })
        } else if (this.products.length === 0) {
          EmptyState({ message: '暂无产品' })
        } else {
          Column({ space: 12 }) {
            ForEach(this.products, (item: ProductListItem) => {
              ProductCard({ item: item })
                .onClick(() => router.pushUrl({ url: 'pages/Public/ProductDetailPage', params: { id: item.id } }))
            }, (item: ProductListItem) => `${item.id}`)
          }
        }
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }

  @Builder
  filterChip(label: string, active: boolean, action: () => void) {
    Text(label)
      .fontSize(12)
      .fontWeight(active ? FontWeight.Bold : FontWeight.Regular)
      .fontColor(active ? Color.White : ColorConstants.TEXT_SECONDARY)
      .padding({ left: 12, right: 12, top: 7, bottom: 7 })
      .backgroundColor(active ? ColorConstants.BRAND_600 : ColorConstants.BG_CARD)
      .borderRadius(999)
      .border({ width: 1, color: active ? ColorConstants.BRAND_600 : ColorConstants.BORDER })
      .onClick(action)
  }
}
