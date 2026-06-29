// file: entry/src/main/ets/components/product/ComponentEditor.ets
import { ProductComponentItem } from '../../models/types';
import { ColorConstants } from '../../theme/ColorConstants';
import { weightPercent } from '../../utils/format';

@Component
export struct ComponentEditor {
  @Link components: ProductComponentItem[];
  onRemove: (index: number) => void = (index: number) => {};
  onWeightChange: (index: number, value: string) => void = (index: number, value: string) => {};

  build() {
    Column({ space: 10 }) {
      ForEach(this.components, (item: ProductComponentItem, index: number) => {
        Row({ space: 8 }) {
          Column({ space: 4 }) {
            Text(item.fundName || item.fundCode || `基金${item.fundId}`)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(ColorConstants.TEXT_PRIMARY)
            Text(`${item.fundType || '-'} · ${item.companyName || '-'}`)
              .fontSize(12)
              .fontColor(ColorConstants.TEXT_HINT)
          }
          .layoutWeight(1)
          TextInput({ text: `${item.weight}`, placeholder: '权重' })
            .type(InputType.Number)
            .width(72)
            .height(38)
            .onChange((value: string) => this.onWeightChange(index, value))
          Text(weightPercent(item.weight))
            .fontSize(12)
            .fontColor(ColorConstants.TEXT_SECONDARY)
            .width(48)
          Button('删除')
            .fontSize(12)
            .fontColor(ColorConstants.DANGER)
            .backgroundColor(ColorConstants.DANGER_BG)
            .height(32)
            .onClick(() => this.onRemove(index))
        }
        .padding(10)
        .backgroundColor(ColorConstants.BG_MUTED)
        .borderRadius(12)
      }, (item: ProductComponentItem) => `${item.fundId}`)
    }
  }
}
