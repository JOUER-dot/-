// file: entry/src/main/ets/components/nav/BottomTabBar.ets
import { ColorConstants } from '../../theme/ColorConstants';

export class TabItem {
  icon: string;
  text: string;

  constructor(icon: string, text: string) {
    this.icon = icon;
    this.text = text;
  }
}

@Component
export struct BottomTabBar {
  @Prop currentIndex: number = 0;
  @Prop tabs: TabItem[] = [];
  onChange: (index: number) => void = (index: number) => {};

  build() {
    Row() {
      ForEach(this.tabs, (item: TabItem, index: number) => {
        Column({ space: 3 }) {
          Text(item.icon)
            .fontSize(20)
          Text(item.text)
            .fontSize(11)
            .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Regular)
            .fontColor(this.currentIndex === index ? ColorConstants.BRAND_600 : ColorConstants.TEXT_HINT)
        }
        .layoutWeight(1)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onChange(index))
      }, (item: TabItem) => item.text)
    }
    .width('100%')
    .height(56)
    .backgroundColor(ColorConstants.BG_CARD)
    .border({ width: { top: 1 }, color: ColorConstants.BORDER })
  }
}
