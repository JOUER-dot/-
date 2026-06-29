// file: entry/src/main/ets/pages/Reviewer/ReviewDetailPage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ReviewApi } from '../../api/review';
import { ProductComponentItem, ReviewDetail, ReviewRecord } from '../../models/types';
import { StatusTag } from '../../components/ui/StatusTag';
import { SectionCard } from '../../components/ui/SectionCard';
import { DiffFieldList } from '../../components/review/DiffFieldList';
import { DiffComponentList } from '../../components/review/DiffComponentList';
import { ColorConstants } from '../../theme/ColorConstants';
import { jsonText, weightPercent } from '../../utils/format';

interface ReviewParams {
  id?: number | string;
}

@Entry
@Component
struct ReviewDetailPage {
  @State productId: number = 0;
  @State detail: ReviewDetail | null = null;
  @State comment: string = '';
  @State loading: boolean = true;

  aboutToAppear(): void {
    const params = router.getParams() as ReviewParams;
    this.productId = Number(params.id || 0);
    this.load();
  }

  async load(): Promise<void> {
    this.loading = true;
    try {
      this.detail = await ReviewApi.detail(this.productId);
    } finally {
      this.loading = false;
    }
  }

  async approve(): Promise<void> {
    await ReviewApi.approve(this.productId, this.comment);
    promptAction.showToast({ message: '已通过' });
    router.back();
  }

  async reject(): Promise<void> {
    if (this.comment.trim().length === 0) {
      AlertDialog.show({ message: '驳回原因必填' });
      return;
    }
    await ReviewApi.reject(this.productId, this.comment);
    promptAction.showToast({ message: '已驳回' });
    router.back();
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Text('‹')
          .fontSize(34)
          .fontColor(ColorConstants.BRAND_600)
          .onClick(() => router.back())
        Text(this.detail?.name || '审核详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
      }
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(ColorConstants.BG_CARD)

      if (this.loading || this.detail === null) {
        LoadingProgress().layoutWeight(1).color(ColorConstants.BRAND_600)
      } else {
        Scroll() {
          Column({ space: 14 }) {
            SectionCard({ title: '基本信息' }) {
              Row({ space: 8 }) {
                StatusTag({ status: this.detail!.riskLevel, type: 'risk' })
                Text(this.detail!.type).fontSize(12).fontColor(ColorConstants.TEXT_SECONDARY)
                Text(`V${this.detail!.versionNo || '-'}`).fontSize(12).fontColor(ColorConstants.TEXT_HINT)
              }
              Text(`策略码：${this.detail!.strategyCode}`).fontSize(13).fontColor(ColorConstants.TEXT_SECONDARY)
              Text(`创建人：${this.detail!.creatorName || '-'}`).fontSize(13).fontColor(ColorConstants.TEXT_SECONDARY)
            }
            SectionCard({ title: '变更说明' }) {
              Text(`${this.detail!.changeType || 'NORMAL'}：${this.detail!.versionNote || '无'}`)
                .fontSize(13)
                .fontColor(this.detail!.changeType === 'MAJOR' ? ColorConstants.DANGER : ColorConstants.INFO)
            }
            SectionCard({ title: '字段差异' }) {
              DiffFieldList({ fields: this.detail!.fieldDiffs || [] })
            }
            SectionCard({ title: '成分差异' }) {
              DiffComponentList({ items: this.detail!.componentDiffs || [] })
            }
            SectionCard({ title: '完整成分' }) {
              ForEach(this.detail!.components || [], (item: ProductComponentItem) => {
                Row() {
                  Text(item.fundName || item.fundCode || '-').fontSize(13).layoutWeight(1)
                  Text(weightPercent(item.weight)).fontSize(13).fontColor(ColorConstants.BRAND_600)
                }
                .padding({ top: 6, bottom: 6 })
              }, (item: ProductComponentItem) => `${item.fundId}`)
              Text(jsonText(this.detail!.params)).fontSize(11).fontColor(ColorConstants.TEXT_HINT)
            }
            SectionCard({ title: '审核记录' }) {
              ForEach(this.detail!.reviewSummary || [], (record: ReviewRecord) => {
                Text(`${record.result} · ${record.reviewerName || '-'} · ${record.reviewedAt || '-'}\n${record.comment || ''}`)
                  .fontSize(12)
                  .fontColor(ColorConstants.TEXT_SECONDARY)
              }, (record: ReviewRecord) => `${record.result}-${record.reviewedAt}`)
            }
            TextArea({ text: this.comment, placeholder: '输入审核意见/驳回原因' })
              .height(96)
              .backgroundColor(ColorConstants.BG_CARD)
              .borderRadius(12)
              .onChange((value: string) => this.comment = value)
          }
          .padding(16)
        }
        .layoutWeight(1)
        Row({ space: 10 }) {
          Button('驳回')
            .layoutWeight(1)
            .height(48)
            .backgroundColor(ColorConstants.DANGER)
            .onClick(() => this.reject())
          Button('通过')
            .layoutWeight(1)
            .height(48)
            .backgroundColor(ColorConstants.BRAND_600)
            .onClick(() => this.approve())
        }
        .padding(16)
        .backgroundColor(ColorConstants.BG_CARD)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
