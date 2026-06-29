// file: entry/src/main/ets/pages/Advisor/ProductEditPage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { ProductApi } from '../../api/product';
import { MapObject, ProductComponentItem, ProductDetail, ProductSaveComponent, ProductSaveRequest } from '../../models/types';
import { ComponentEditor } from '../../components/product/ComponentEditor';
import { FundSelectDialog } from '../../components/product/FundSelectDialog';
import { ColorConstants } from '../../theme/ColorConstants';

interface EditParams {
  productId?: number | string;
}

@Entry
@Component
struct ProductEditPage {
  @State productId: number = 0;
  @State name: string = '';
  @State type: string = 'STRATEGY';
  @State riskLevel: string = 'R3';
  @State strategyCode: string = '';
  @State tagsText: string = '';
  @State paramsText: string = '{}';
  @State components: ProductComponentItem[] = [];
  @State loading: boolean = false;

  private fundDialog: CustomDialogController = new CustomDialogController({
    builder: FundSelectDialog({
      onConfirm: (items: ProductComponentItem[]) => {
        this.components = this.components.concat(items);
      }
    }),
    alignment: DialogAlignment.Center
  });

  aboutToAppear(): void {
    const params = router.getParams() as EditParams;
    this.productId = Number(params.productId || 0);
    if (this.productId > 0) {
      this.load();
    }
  }

  async load(): Promise<void> {
    const detail: ProductDetail = await ProductApi.getMineDetail(this.productId);
    this.name = detail.name;
    this.type = detail.type;
    this.riskLevel = detail.riskLevel;
    this.strategyCode = detail.strategyCode;
    this.tagsText = (detail.featureTags || []).join(',');
    this.paramsText = JSON.stringify(detail.params || {});
    this.components = detail.components || [];
  }

  private totalWeight(): number {
    let total = 0;
    this.components.forEach((item: ProductComponentItem) => total += item.weight);
    return total;
  }

  private buildRequest(): ProductSaveRequest {
    const baseInfo: MapObject = new MapObject();
    const params: MapObject = JSON.parse(this.paramsText || '{}') as MapObject;
    const components: ProductSaveComponent[] = this.components.map((item: ProductComponentItem) => {
      const component: ProductSaveComponent = { fundId: item.fundId, weight: item.weight };
      return component;
    });
    const request: ProductSaveRequest = {
      name: this.name,
      type: this.type,
      riskLevel: this.riskLevel,
      strategyCode: this.strategyCode,
      featureTags: this.tagsText.split(',').filter((item: string) => item.trim().length > 0).map((item: string) => item.trim()),
      baseInfo: baseInfo,
      params: params,
      components: components
    };
    return request;
  }

  async save(submit: boolean = false): Promise<void> {
    if (this.name.trim().length === 0 || this.strategyCode.trim().length === 0) {
      AlertDialog.show({ message: '请填写产品名和策略码' });
      return;
    }
    if (Math.abs(this.totalWeight() - 100) > 0.01) {
      AlertDialog.show({ message: '成分基金权重合计必须等于 100%' });
      return;
    }
    this.loading = true;
    try {
      const body = this.buildRequest();
      let id = this.productId;
      if (id > 0) {
        await ProductApi.update(id, body);
      } else {
        const created = await ProductApi.create(body);
        id = created.productId;
        this.productId = id;
      }
      if (submit) {
        await ProductApi.submit(id, 'NORMAL', '移动端保存并提交');
      }
      promptAction.showToast({ message: submit ? '已保存并提交' : '保存成功' });
      router.back();
    } catch (error) {
      AlertDialog.show({ message: '保存失败，请检查表单或后端服务' });
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Text('‹')
          .fontSize(34)
          .fontColor(ColorConstants.BRAND_600)
          .onClick(() => router.back())
        Text(this.productId > 0 ? '编辑产品' : '创建产品')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
      }
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(ColorConstants.BG_CARD)

      Scroll() {
        Column({ space: 16 }) {
          this.sectionTitle('Step 1 基本信息')
          this.field('产品名', this.name, '请输入产品名', (value: string) => this.name = value)
          this.field('类型', this.type, 'STRATEGY / FOF', (value: string) => this.type = value)
          this.field('风险等级', this.riskLevel, 'R1-R5', (value: string) => this.riskLevel = value)
          this.field('策略码', this.strategyCode, '请输入策略码', (value: string) => this.strategyCode = value)
          this.field('特性标签', this.tagsText, '用英文逗号分隔', (value: string) => this.tagsText = value)

          Row() {
            this.sectionTitle('Step 2 成分基金')
            Blank()
            Button('添加基金')
              .height(36)
              .backgroundColor(ColorConstants.BRAND_600)
              .onClick(() => this.fundDialog.open())
          }
          ComponentEditor({
            components: $components,
            onRemove: (index: number) => {
              this.components.splice(index, 1);
              this.components = this.components.slice();
            },
            onWeightChange: (index: number, value: string) => {
              this.components[index].weight = Number(value) || 0;
              this.components = this.components.slice();
            }
          })
          Text(`权重合计：${this.totalWeight().toFixed(2)}%`)
            .fontSize(13)
            .fontColor(Math.abs(this.totalWeight() - 100) <= 0.01 ? ColorConstants.SUCCESS : ColorConstants.DANGER)

          this.sectionTitle('Step 3 参数配置')
          TextArea({ text: this.paramsText, placeholder: '{"rebalance":"monthly"}' })
            .height(120)
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(12)
            .onChange((value: string) => this.paramsText = value)
        }
        .padding(16)
      }
      .layoutWeight(1)

      Row({ space: 10 }) {
        Button(this.loading ? '保存中' : '保存')
          .layoutWeight(1)
          .height(48)
          .backgroundColor(ColorConstants.BRAND_50)
          .fontColor(ColorConstants.BRAND_600)
          .onClick(() => this.save(false))
        Button('提交审核')
          .layoutWeight(1)
          .height(48)
          .backgroundColor(ColorConstants.BRAND_600)
          .fontColor(Color.White)
          .onClick(() => this.save(true))
      }
      .padding(16)
      .backgroundColor(ColorConstants.BG_CARD)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }

  @Builder
  sectionTitle(title: string) {
    Text(title)
      .fontSize(17)
      .fontWeight(FontWeight.Bold)
      .fontColor(ColorConstants.TEXT_PRIMARY)
  }

  @Builder
  field(label: string, value: string, placeholder: string, onChange: (value: string) => void) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(13)
        .fontColor(ColorConstants.TEXT_SECONDARY)
      TextInput({ text: value, placeholder: placeholder })
        .height(44)
        .backgroundColor(ColorConstants.BG_CARD)
        .borderRadius(12)
        .onChange(onChange)
    }
    .width('100%')
  }
}
