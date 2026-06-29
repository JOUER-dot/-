// file: entry/src/main/ets/pages/User/SubscriptionsPage.ets
import promptAction from '@ohos.promptAction';
import { SubscriptionApi } from '../../api/subscription';
import { QueryParam } from '../../api/request';
import { SubscriptionAction, SubscriptionItem } from '../../models/types';
import { StatusTag } from '../../components/ui/StatusTag';
import { EmptyState } from '../../components/ui/EmptyState';
import { ColorConstants } from '../../theme/ColorConstants';
import { percent, shortDate } from '../../utils/format';

@Component
export struct SubscriptionsPage {
  @State keyword: string = '';
  @State status: string = '';
  @State items: SubscriptionItem[] = [];

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    const page = await SubscriptionApi.listMine([
      new QueryParam('keyword', this.keyword),
      new QueryParam('subscriptionStatus', this.status),
      new QueryParam('pageNum', 1),
      new QueryParam('pageSize', 50)
    ]);
    this.items = page.records || [];
  }

  async cancel(item: SubscriptionItem): Promise<void> {
    await SubscriptionApi.unsubscribe(item.productId);
    promptAction.showToast({ message: '已取消订阅' });
    this.load();
  }

  async decide(item: SubscriptionItem, decision: string): Promise<void> {
    await SubscriptionApi.decide(item.subscriptionId, decision);
    promptAction.showToast({ message: decision === 'CONFIRM' ? '已接受变更' : '已取消订阅' });
    this.load();
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text('我的订阅')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
        Row({ space: 8 }) {
          TextInput({ text: this.keyword, placeholder: '搜索订阅产品' })
            .height(40)
            .layoutWeight(1)
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(12)
            .onChange((value: string) => this.keyword = value)
          Button('查询').height(40).backgroundColor(ColorConstants.BRAND_600).onClick(() => this.load())
        }
        Row({ space: 8 }) {
          this.chip('全部', '')
          this.chip('已订阅', 'ACTIVE')
          this.chip('已取消', 'CANCELLED')
        }
        if (this.items.length === 0) {
          EmptyState({ message: '暂无订阅' })
        } else {
          ForEach(this.items, (item: SubscriptionItem) => {
            Column({ space: 10 }) {
              Row() {
                Text(item.productName)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)
                StatusTag({ status: item.riskLevel, type: 'risk' })
                StatusTag({ status: item.status, type: 'product' })
              }
              Text(`${item.type} · 最新净值 ${item.latestNav?.toFixed(4) || '-'} · 累计收益 ${percent(item.latestCumReturn)}`)
                .fontSize(13)
                .fontColor(ColorConstants.TEXT_SECONDARY)
              Text(`订阅时间：${shortDate(item.subscribedAt)}`)
                .fontSize(12)
                .fontColor(ColorConstants.TEXT_HINT)
              if ((item.pendingVersionActions || []).length > 0) {
                Column({ space: 6 }) {
                  ForEach(item.pendingVersionActions || [], (action: SubscriptionAction) => {
                    Text(`${action.changeType || 'NORMAL'}：${action.versionNote || '产品版本变更'}`)
                      .fontSize(12)
                      .fontColor(ColorConstants.WARNING)
                  }, (action: SubscriptionAction) => `${action.id}`)
                  Row({ space: 8 }) {
                    Button('接受变更').height(32).fontSize(12).backgroundColor(ColorConstants.BRAND_600)
                      .onClick(() => this.decide(item, 'CONFIRM'))
                    Button('取消订阅').height(32).fontSize(12).backgroundColor(ColorConstants.DANGER_BG).fontColor(ColorConstants.DANGER)
                      .onClick(() => this.decide(item, 'CANCEL'))
                  }
                }
                .padding(10)
                .backgroundColor(ColorConstants.WARNING_BG)
                .borderRadius(12)
              }
              if (item.status === 'ACTIVE') {
                Button('取消订阅')
                  .height(34)
                  .fontSize(12)
                  .backgroundColor(ColorConstants.BG_MUTED)
                  .fontColor(ColorConstants.TEXT_SECONDARY)
                  .onClick(() => AlertDialog.show({
                    message: '确认取消订阅？',
                    primaryButton: { value: '取消', action: () => {} },
                    secondaryButton: { value: '确认', action: () => this.cancel(item) }
                  }))
              }
            }
            .padding(16)
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(16)
            .border({ width: 1, color: ColorConstants.BORDER })
          }, (item: SubscriptionItem) => `${item.subscriptionId}`)
        }
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }

  @Builder
  chip(label: string, value: string) {
    Text(label)
      .fontSize(12)
      .fontColor(this.status === value ? Color.White : ColorConstants.TEXT_SECONDARY)
      .padding({ left: 12, right: 12, top: 7, bottom: 7 })
      .backgroundColor(this.status === value ? ColorConstants.BRAND_600 : ColorConstants.BG_CARD)
      .borderRadius(999)
      .onClick(() => { this.status = value; this.load(); })
  }
}
