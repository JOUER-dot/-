// file: entry/src/main/ets/components/review/DiffComponentList.ets
import { ReviewDiffComponent } from '../../models/types';
import { ColorConstants } from '../../theme/ColorConstants';
import { weightPercent } from '../../utils/format';

@Component
export struct DiffComponentList {
  @Prop items: ReviewDiffComponent[] = [];

  private colorOf(type: string): string {
    if (type === 'ADDED') {
      return ColorConstants.SUCCESS;
    }
    if (type === 'REMOVED') {
      return ColorConstants.DANGER;
    }
    return ColorConstants.INFO;
  }

  private textOf(item: ReviewDiffComponent): string {
    if (item.diffType === 'ADDED') {
      return `+ ${item.fundName || item.fundCode} ${weightPercent(item.afterWeight)}`;
    }
    if (item.diffType === 'REMOVED') {
      return `- ${item.fundName || item.fundCode} ${weightPercent(item.beforeWeight)}`;
    }
    return `${item.fundName || item.fundCode}: ${weightPercent(item.beforeWeight)} → ${weightPercent(item.afterWeight)}`;
  }

  build() {
    Column({ space: 8 }) {
      ForEach(this.items, (item: ReviewDiffComponent) => {
        Text(this.textOf(item))
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.colorOf(item.diffType))
          .padding(10)
          .width('100%')
          .backgroundColor(ColorConstants.BG_MUTED)
          .borderRadius(12)
      }, (item: ReviewDiffComponent) => `${item.diffType}-${item.fundId}`)
    }
  }
}
