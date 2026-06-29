// file: entry/src/main/ets/components/ui/EmptyState.ets
import { ColorConstants } from '../../theme/ColorConstants';

@Component
export struct EmptyState {
  @Prop message: string = '暂无数据';

  build() {
    Column({ space: 10 }) {
      Text('∅')
        .fontSize(42)
        .fontColor(ColorConstants.TEXT_HINT)
      Text(this.message)
        .fontSize(14)
        .fontColor(ColorConstants.TEXT_SECONDARY)
    }
    .width('100%')
    .padding(32)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
