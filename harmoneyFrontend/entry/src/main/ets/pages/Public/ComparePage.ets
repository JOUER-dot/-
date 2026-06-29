// file: entry/src/main/ets/pages/Public/ComparePage.ets
import router from '@ohos.router';
import { ColorConstants } from '../../theme/ColorConstants';
import { EmptyState } from '../../components/ui/EmptyState';

@Entry
@Component
struct ComparePage {
  build() {
    Column() {
      Row({ space: 10 }) {
        Text('‹')
          .fontSize(34)
          .fontColor(ColorConstants.BRAND_600)
          .onClick(() => router.back())
        Text('产品对比')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .height(56)
      .padding({ left: 16, right: 16 })
      EmptyState({ message: '请选择产品后进行对比' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
