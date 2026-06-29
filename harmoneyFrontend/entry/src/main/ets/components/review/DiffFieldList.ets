// file: entry/src/main/ets/components/review/DiffFieldList.ets
import { ReviewDiffField } from '../../models/types';
import { ColorConstants } from '../../theme/ColorConstants';

@Component
export struct DiffFieldList {
  @Prop fields: ReviewDiffField[] = [];

  build() {
    Column({ space: 8 }) {
      ForEach(this.fields, (item: ReviewDiffField) => {
        Column({ space: 6 }) {
          Text(item.fieldLabel || item.fieldKey)
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor(item.majorSignal ? ColorConstants.DANGER : ColorConstants.TEXT_PRIMARY)
          Row({ space: 8 }) {
            Text(JSON.stringify(item.beforeValue))
              .fontSize(12)
              .fontColor(ColorConstants.TEXT_HINT)
              .decoration({ type: TextDecorationType.LineThrough })
              .layoutWeight(1)
            Text('→')
              .fontColor(ColorConstants.TEXT_HINT)
            Text(JSON.stringify(item.afterValue))
              .fontSize(12)
              .fontColor(ColorConstants.BRAND_600)
              .layoutWeight(1)
          }
        }
        .padding(10)
        .backgroundColor(item.majorSignal ? ColorConstants.DANGER_BG : ColorConstants.BG_MUTED)
        .borderRadius(12)
      }, (item: ReviewDiffField) => item.fieldKey)
    }
  }
}
