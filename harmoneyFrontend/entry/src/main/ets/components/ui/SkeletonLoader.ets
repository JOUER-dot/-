// file: entry/src/main/ets/components/ui/SkeletonLoader.ets
import { ColorConstants } from '../../theme/ColorConstants';

@Component
export struct SkeletonLoader {
  @Prop rows: number = 3;
  @Prop type: string = 'card';

  build() {
    Column({ space: 12 }) {
      ForEach(Array.from({ length: this.rows }), (_: number, index: number) => {
        Column({ space: 10 }) {
          Row()
            .height(18)
            .width('62%')
            .backgroundColor(ColorConstants.BORDER)
            .borderRadius(8)
          Row()
            .height(14)
            .width('88%')
            .backgroundColor(ColorConstants.BG_MUTED)
            .borderRadius(8)
          Row()
            .height(14)
            .width('42%')
            .backgroundColor(ColorConstants.BG_MUTED)
            .borderRadius(8)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(ColorConstants.BG_CARD)
        .borderRadius(this.type === 'card' ? 16 : 8)
        .border({ width: 1, color: ColorConstants.BORDER })
      }, (_: number, index: number) => `${index}`)
    }
    .width('100%')
  }
}
