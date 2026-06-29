// file: entry/src/main/ets/components/product/ProductCard.ets
import { ProductListItem } from '../../models/types';
import { ColorConstants } from '../../theme/ColorConstants';
import { percent } from '../../utils/format';
import { StatusTag } from '../ui/StatusTag';

@Component
export struct ProductCard {
  @Prop item: ProductListItem = {
    id: 0,
    name: '',
    type: '',
    riskLevel: ''
  };
  @Prop selected: boolean = false;

  build() {
    Column({ space: 12 }) {
      Row() {
        Text(this.item.name)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(ColorConstants.TEXT_PRIMARY)
          .maxLines(2)
          .layoutWeight(1)
        StatusTag({ status: this.item.riskLevel, type: 'risk' })
        Text(this.item.type)
          .fontSize(11)
          .fontColor(ColorConstants.TEXT_SECONDARY)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(ColorConstants.BG_MUTED)
          .borderRadius(999)
          .margin({ left: 6 })
      }

      Row() {
        this.metric('投顾', this.item.creatorName || '-')
        this.metric('策略码', this.item.strategyCode || '-')
        this.metric('累计收益', percent(this.item.latestCumReturn), (this.item.latestCumReturn || 0) >= 0 ? ColorConstants.SUCCESS : ColorConstants.DANGER)
      }

      Text((this.item.fundCompanies || []).join(' / ') || '基金公司待披露')
        .fontSize(13)
        .fontColor(ColorConstants.TEXT_SECONDARY)

      Row({ space: 6 }) {
        ForEach((this.item.featureTags || []).slice(0, 3), (tag: string) => {
          Text(tag)
            .fontSize(11)
            .fontColor(ColorConstants.TEXT_SECONDARY)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(ColorConstants.BG_MUTED)
            .borderRadius(8)
        }, (tag: string) => tag)
      }

      Text('点击查看详情 →')
        .fontSize(12)
        .fontColor(ColorConstants.TEXT_HINT)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ColorConstants.BG_CARD)
    .borderRadius(16)
    .border({ width: 1, color: this.selected ? ColorConstants.BRAND_600 : ColorConstants.BORDER })
  }

  @Builder
  metric(label: string, value: string, color: string = ColorConstants.TEXT_PRIMARY) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(11)
        .fontColor(ColorConstants.TEXT_HINT)
      Text(value)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(color)
        .maxLines(1)
    }
    .layoutWeight(1)
  }
}
