// file: entry/src/main/ets/pages/Advisor/ProductManagePage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ProductApi } from '../../api/product';
import { QueryParam } from '../../api/request';
import { ProductListItem } from '../../models/types';
import { StatusTag } from '../../components/ui/StatusTag';
import { EmptyState } from '../../components/ui/EmptyState';
import { SkeletonLoader } from '../../components/ui/SkeletonLoader';
import { ColorConstants } from '../../theme/ColorConstants';
import { productStatusText } from '../../utils/status';
import { shortDate } from '../../utils/format';

@Component
export struct ProductManagePage {
  @State keyword: string = '';
  @State status: string = '';
  @State products: ProductListItem[] = [];
  @State loading: boolean = true;

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.loading = true;
    try {
      const page = await ProductApi.listMine([
        new QueryParam('keyword', this.keyword),
        new QueryParam('status', this.status),
        new QueryParam('pageNum', 1),
        new QueryParam('pageSize', 30)
      ]);
      this.products = page.records || [];
    } finally {
      this.loading = false;
    }
  }

  async action(id: number, actionType: string): Promise<void> {
    try {
      if (actionType === 'submit') {
        await ProductApi.submit(id, 'NORMAL', '移动端提交审核');
      } else if (actionType === 'withdraw') {
        await ProductApi.withdraw(id);
      } else if (actionType === 'offline') {
        await ProductApi.offline(id);
      } else if (actionType === 'delete') {
        await ProductApi.remove(id);
      } else if (actionType === 'copy') {
        await ProductApi.copy(id);
      } else if (actionType === 'nav') {
        await ProductApi.generateNav(id);
      }
      promptAction.showToast({ message: '操作成功' });
      this.load();
    } catch (error) {
      promptAction.showToast({ message: '操作失败' });
    }
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Row() {
          Text('我的产品')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(ColorConstants.TEXT_PRIMARY)
            .layoutWeight(1)
          Button('创建产品')
            .height(38)
            .backgroundColor(ColorConstants.BRAND_600)
            .onClick(() => router.pushUrl({ url: 'pages/Advisor/ProductEditPage' }))
        }

        Row({ space: 8 }) {
          TextInput({ text: this.keyword, placeholder: '搜索产品' })
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
            ForEach(['', 'DRAFT', 'PENDING_REVIEW', 'PUBLISHED', 'REJECTED', 'OFFLINE'], (item: string) => {
              Text(item.length === 0 ? '全部' : productStatusText(item))
                .fontSize(12)
                .fontColor(this.status === item ? Color.White : ColorConstants.TEXT_SECONDARY)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(this.status === item ? ColorConstants.BRAND_600 : ColorConstants.BG_CARD)
                .borderRadius(999)
                .onClick(() => { this.status = item; this.load(); })
            }, (item: string) => item || 'ALL')
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)

        if (this.loading) {
          SkeletonLoader({ rows: 3 })
        } else if (this.products.length === 0) {
          EmptyState({ message: '暂无产品' })
        } else {
          ForEach(this.products, (item: ProductListItem) => {
            Column({ space: 10 }) {
              Row() {
                Text(item.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)
                StatusTag({ status: item.status || 'DRAFT', type: 'product' })
              }
              Row({ space: 8 }) {
                StatusTag({ status: item.riskLevel, type: 'risk' })
                Text(item.type)
                  .fontSize(12)
                  .fontColor(ColorConstants.TEXT_SECONDARY)
                Text(shortDate(item.updatedAt))
                  .fontSize(12)
                  .fontColor(ColorConstants.TEXT_HINT)
              }
              if ((item.lastRejectComment || '').length > 0) {
                Text(`驳回原因：${item.lastRejectComment}`)
                  .fontSize(12)
                  .fontColor(ColorConstants.DANGER)
              }
              this.actionBar(item)
            }
            .padding(16)
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(16)
            .border({ width: 1, color: ColorConstants.BORDER })
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
  actionBar(item: ProductListItem) {
    Row({ space: 8 }) {
      if ((item.status || 'DRAFT') === 'DRAFT' || item.status === 'REJECTED') {
        Button('编辑').height(32).fontSize(12).backgroundColor(ColorConstants.BRAND_50).fontColor(ColorConstants.BRAND_600)
          .onClick(() => router.pushUrl({ url: 'pages/Advisor/ProductEditPage', params: { productId: item.id } }))
        Button(item.status === 'REJECTED' ? '重新提交' : '提交审核').height(32).fontSize(12).backgroundColor(ColorConstants.BRAND_600)
          .onClick(() => this.confirmAction(item.id, 'submit', '确认提交审核？'))
        Button('删除').height(32).fontSize(12).backgroundColor(ColorConstants.DANGER_BG).fontColor(ColorConstants.DANGER)
          .onClick(() => this.confirmAction(item.id, 'delete', '确认删除产品？'))
      } else if (item.status === 'PENDING_REVIEW') {
        Button('撤回').height(32).fontSize(12).backgroundColor(ColorConstants.WARNING_BG).fontColor(ColorConstants.WARNING)
          .onClick(() => this.confirmAction(item.id, 'withdraw', '确认撤回审核？'))
      } else if (item.status === 'PUBLISHED') {
        Button('下架').height(32).fontSize(12).backgroundColor(ColorConstants.WARNING_BG).fontColor(ColorConstants.WARNING)
          .onClick(() => this.confirmAction(item.id, 'offline', '确认下架产品？'))
        Button('重算净值').height(32).fontSize(12).backgroundColor(ColorConstants.BRAND_50).fontColor(ColorConstants.BRAND_600)
          .onClick(() => this.action(item.id, 'nav'))
      }
      Button('复制').height(32).fontSize(12).backgroundColor(ColorConstants.BG_MUTED).fontColor(ColorConstants.TEXT_SECONDARY)
        .onClick(() => this.action(item.id, 'copy'))
    }
  }

  confirmAction(id: number, actionType: string, message: string): void {
    AlertDialog.show({
      message: message,
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: { value: '确认', action: () => this.action(id, actionType) }
    });
  }
}
