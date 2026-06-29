// file: entry/src/main/ets/components/product/FundSelectDialog.ets
import { FundApi } from '../../api/fund';
import { QueryParam } from '../../api/request';
import { FundOption, ProductComponentItem } from '../../models/types';
import { ColorConstants } from '../../theme/ColorConstants';
import { EmptyState } from '../ui/EmptyState';

@CustomDialog
export struct FundSelectDialog {
  controller: CustomDialogController;
  onConfirm: (items: ProductComponentItem[]) => void = (items: ProductComponentItem[]) => {};
  @State keyword: string = '';
  @State funds: FundOption[] = [];
  @State selected: FundOption[] = [];

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    const page = await FundApi.list([
      new QueryParam('keyword', this.keyword),
      new QueryParam('pageNum', 1),
      new QueryParam('pageSize', 20)
    ]);
    this.funds = page.records || [];
  }

  private isSelected(id: number): boolean {
    return this.selected.some((item: FundOption) => item.id === id);
  }

  private toggle(item: FundOption): void {
    if (this.isSelected(item.id)) {
      this.selected = this.selected.filter((current: FundOption) => current.id !== item.id);
    } else {
      this.selected = this.selected.concat([item]);
    }
  }

  build() {
    Column({ space: 12 }) {
      Text('选择基金')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(ColorConstants.TEXT_PRIMARY)
      Row({ space: 8 }) {
        TextInput({ text: this.keyword, placeholder: '搜索基金名称/代码' })
          .layoutWeight(1)
          .onChange((value: string) => this.keyword = value)
        Button('搜索')
          .backgroundColor(ColorConstants.BRAND_600)
          .onClick(() => this.load())
      }
      if (this.funds.length === 0) {
        EmptyState({ message: '暂无基金' })
      } else {
        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.funds, (item: FundOption) => {
              Row({ space: 10 }) {
                Toggle({ type: ToggleType.Checkbox, isOn: this.isSelected(item.id) })
                  .onChange(() => this.toggle(item))
                Column({ space: 4 }) {
                  Text(`${item.fundCode} ${item.fundName}`)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(ColorConstants.TEXT_PRIMARY)
                  Text(`${item.fundType} · ${item.riskLevel} · ${item.companyName}`)
                    .fontSize(12)
                    .fontColor(ColorConstants.TEXT_SECONDARY)
                }
                .layoutWeight(1)
              }
              .padding(10)
              .backgroundColor(ColorConstants.BG_MUTED)
              .borderRadius(12)
              .onClick(() => this.toggle(item))
            }, (item: FundOption) => `${item.id}`)
          }
        }
        .height(320)
      }
      Row({ space: 10 }) {
        Button('取消')
          .layoutWeight(1)
          .backgroundColor(ColorConstants.BG_MUTED)
          .fontColor(ColorConstants.TEXT_SECONDARY)
          .onClick(() => this.controller.close())
        Button(`确认(${this.selected.length})`)
          .layoutWeight(1)
          .backgroundColor(ColorConstants.BRAND_600)
          .onClick(() => {
            const items: ProductComponentItem[] = this.selected.map((fund: FundOption) => {
              const item: ProductComponentItem = {
                fundId: fund.id,
                fundCode: fund.fundCode,
                fundName: fund.fundName,
                fundType: fund.fundType,
                riskLevel: fund.riskLevel,
                companyName: fund.companyName,
                weight: 0
              };
              return item;
            });
            this.onConfirm(items);
            this.controller.close();
          })
      }
    }
    .width('92%')
    .padding(18)
    .backgroundColor(ColorConstants.BG_CARD)
    .borderRadius(20)
  }
}
