// file: entry/src/main/ets/pages/Public/ProductDetailPage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ProductApi } from '../../api/product';
import { SubscriptionApi } from '../../api/subscription';
import { NavPoint, ProductComponentItem, ProductDetail } from '../../models/types';
import { StatusTag } from '../../components/ui/StatusTag';
import { EmptyState } from '../../components/ui/EmptyState';
import { SectionCard } from '../../components/ui/SectionCard';
import { ColorConstants } from '../../theme/ColorConstants';
import { USER_TOKEN_KEY } from '../../utils/persist';
import { jsonText, percent, weightPercent } from '../../utils/format';

interface DetailParams {
  id?: number | string;
}

@Entry
@Component
struct ProductDetailPage {
  @StorageLink(USER_TOKEN_KEY) token: string = '';
  @State productId: number = 0;
  @State detail: ProductDetail | null = null;
  @State loading: boolean = true;
  @State subscribed: boolean = false;

  aboutToAppear(): void {
    const params = router.getParams() as DetailParams;
    const rawId = params.id || 0;
    this.productId = Number(rawId);
    this.load();
  }

  async load(): Promise<void> {
    this.loading = true;
    try {
      this.detail = await ProductApi.getPublishedDetail(this.productId);
    } finally {
      this.loading = false;
    }
  }

  async toggleSubscribe(): Promise<void> {
    if (this.token.length === 0) {
      router.pushUrl({ url: 'pages/Auth/LoginPage' });
      return;
    }
    if (this.subscribed) {
      await SubscriptionApi.unsubscribe(this.productId);
      this.subscribed = false;
      promptAction.showToast({ message: '已取消订阅' });
    } else {
      await SubscriptionApi.subscribe(this.productId);
      this.subscribed = true;
      promptAction.showToast({ message: '订阅成功' });
    }
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Text('‹')
          .fontSize(34)
          .fontColor(ColorConstants.BRAND_600)
          .onClick(() => router.back())
        Text(this.detail?.name || '产品详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ColorConstants.TEXT_PRIMARY)
          .layoutWeight(1)
      }
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(ColorConstants.BG_CARD)

      if (this.loading) {
        LoadingProgress()
          .layoutWeight(1)
          .color(ColorConstants.BRAND_600)
      } else if (this.detail === null) {
        EmptyState({ message: '产品不存在' })
      } else {
        Scroll() {
          Column({ space: 14 }) {
            SectionCard({ title: '基本信息' }) {
              Row({ space: 8 }) {
                StatusTag({ status: this.detail!.riskLevel, type: 'risk' })
                Text(this.detail!.type)
                  .fontSize(12)
                  .fontColor(ColorConstants.TEXT_SECONDARY)
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor(ColorConstants.BG_MUTED)
                  .borderRadius(8)
              }
              Text(`策略码：${this.detail!.strategyCode}`)
                .fontSize(13)
                .fontColor(ColorConstants.TEXT_SECONDARY)
              Text(`创建人：${this.detail!.creatorName || '-'}`)
                .fontSize(13)
                .fontColor(ColorConstants.TEXT_SECONDARY)
              Row({ space: 6 }) {
                ForEach(this.detail!.featureTags || [], (tag: string) => {
                  Text(tag)
                    .fontSize(11)
                    .fontColor(ColorConstants.BRAND_600)
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .backgroundColor(ColorConstants.BRAND_50)
                    .borderRadius(8)
                }, (tag: string) => tag)
              }
            }

            SectionCard({ title: '净值走势' }) {
              if ((this.detail!.navList || []).length === 0) {
                EmptyState({ message: '暂无净值数据' })
              } else {
                ForEach((this.detail!.navList || []).slice(0, 6), (point: NavPoint) => {
                  Row() {
                    Text(point.navDate)
                      .fontSize(12)
                      .fontColor(ColorConstants.TEXT_SECONDARY)
                      .layoutWeight(1)
                    Text(`${point.nav.toFixed(4)} / ${percent(point.cumReturn)}`)
                      .fontSize(12)
                      .fontColor(ColorConstants.TEXT_PRIMARY)
                  }
                }, (point: NavPoint) => point.navDate)
              }
            }

            SectionCard({ title: '成分基金' }) {
              ForEach(this.detail!.components || [], (item: ProductComponentItem) => {
                Row() {
                  Column({ space: 4 }) {
                    Text(`${item.fundCode || '-'} ${item.fundName || '-'}`)
                      .fontSize(13)
                      .fontWeight(FontWeight.Medium)
                    Text(`${item.fundType || '-'} · ${item.riskLevel || '-'} · ${item.companyName || '-'}`)
                      .fontSize(11)
                      .fontColor(ColorConstants.TEXT_HINT)
                  }
                  .layoutWeight(1)
                  Text(weightPercent(item.weight))
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(ColorConstants.BRAND_600)
                }
                .padding({ top: 8, bottom: 8 })
              }, (item: ProductComponentItem) => `${item.fundId}`)
            }

            SectionCard({ title: '参数配置' }) {
              Text(jsonText(this.detail!.params))
                .fontSize(12)
                .fontColor(ColorConstants.TEXT_SECONDARY)
            }
          }
          .padding(16)
        }
        .layoutWeight(1)

        Button(this.token.length === 0 ? '登录后订阅' : (this.subscribed ? '取消订阅' : '立即订阅'))
          .width('100%')
          .height(50)
          .fontColor(Color.White)
          .backgroundColor(this.subscribed ? ColorConstants.TEXT_HINT : ColorConstants.BRAND_600)
          .borderRadius(0)
          .onClick(() => this.toggleSubscribe())
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
