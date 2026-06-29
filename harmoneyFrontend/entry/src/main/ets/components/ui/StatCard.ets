// file: entry/src/main/ets/components/ui/StatCard.ets
import { ColorConstants } from '../../theme/ColorConstants';

@Component
export struct StatCard {
  @Prop label: string = '';
  @Prop value: string = '0';
  @Prop hint: string = '';
  @Prop color: string = ColorConstants.BRAND_600;

  build() {
    Column({ space: 6 }) {
      Text(this.value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.color)
      Text(this.label)
        .fontSize(13)
        .fontColor(ColorConstants.TEXT_SECONDARY)
      if (this.hint.length > 0) {
        Text(this.hint)
          .fontSize(11)
          .fontColor(ColorConstants.TEXT_HINT)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(14)
    .backgroundColor(ColorConstants.BG_CARD)
    .borderRadius(16)
    .border({ width: 1, color: ColorConstants.BORDER })
  }
}
