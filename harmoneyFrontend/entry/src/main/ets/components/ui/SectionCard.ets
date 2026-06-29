// file: entry/src/main/ets/components/ui/SectionCard.ets
import { ColorConstants } from '../../theme/ColorConstants';
import { ShadowConstants } from '../../theme/ShadowConstants';

@Component
export struct SectionCard {
  @Prop title: string = '';
  @Prop paddingValue: number = 16;
  @BuilderParam content: () => void = this.defaultContent;

  @Builder
  defaultContent() {
  }

  build() {
    Column({ space: 12 }) {
      if (this.title.length > 0) {
        Text(this.title)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(ColorConstants.TEXT_PRIMARY)
      }
      this.content()
    }
    .width('100%')
    .padding(this.paddingValue)
    .backgroundColor(ColorConstants.BG_CARD)
    .borderRadius(16)
    .border({ width: 1, color: ColorConstants.BORDER })
    .shadow(ShadowConstants.SOFT)
  }
}
