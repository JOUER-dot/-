// file: entry/src/main/ets/components/ui/StatusTag.ets
import { ColorConstants } from '../../theme/ColorConstants';
import { productStatusColor, productStatusText, reviewStatusText, riskColor } from '../../utils/status';

@Component
export struct StatusTag {
  @Prop status: string = '';
  @Prop type: string = 'product';

  private tagText(): string {
    if (this.type === 'risk') {
      return this.status;
    }
    if (this.type === 'review') {
      return reviewStatusText(this.status);
    }
    if (this.status === 'ACTIVE') {
      return '已订阅';
    }
    if (this.status === 'CANCELLED') {
      return '已取消';
    }
    return productStatusText(this.status);
  }

  private tagColor(): string {
    if (this.type === 'risk') {
      return riskColor(this.status);
    }
    return productStatusColor(this.status);
  }

  build() {
    Text(this.tagText())
      .fontSize(11)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.tagColor())
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .backgroundColor(ColorConstants.BG_MUTED)
      .borderRadius(999)
      .border({ width: 1, color: this.tagColor() })
  }
}
