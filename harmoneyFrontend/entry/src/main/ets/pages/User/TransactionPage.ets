// file: entry/src/main/ets/pages/User/TransactionPage.ets
import router from '@ohos.router';
import { TransactionApi } from '../../api/transaction';
import { QueryParam } from '../../api/request';
import { TransactionRecord } from '../../models/types';
import { EmptyState } from '../../components/ui/EmptyState';
import { ColorConstants } from '../../theme/ColorConstants';
import { money, shortDate } from '../../utils/format';

@Entry
@Component
struct TransactionPage {
  @State records: TransactionRecord[] = [];

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    const page = await TransactionApi.list([
      new QueryParam('pageNum', 1),
      new QueryParam('pageSize', 50)
    ]);
    this.records = page.records || [];
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Text('‹').fontSize(34).fontColor(ColorConstants.BRAND_600).onClick(() => router.back())
        Text('交易记录').fontSize(20).fontWeight(FontWeight.Bold)
      }
      .height(56)
      .padding({ left: 16, right: 16 })
      Scroll() {
        Column({ space: 12 }) {
          if (this.records.length === 0) {
            EmptyState({ message: '暂无交易记录' })
          } else {
            ForEach(this.records, (record: TransactionRecord) => {
              Row() {
                Column({ space: 4 }) {
                  Text(record.productName).fontSize(15).fontWeight(FontWeight.Bold)
                  Text(`${record.type} · ${record.status} · ${shortDate(record.createdAt)}`)
                    .fontSize(12).fontColor(ColorConstants.TEXT_HINT)
                }
                .layoutWeight(1)
                Text(money(record.amount)).fontSize(15).fontWeight(FontWeight.Bold).fontColor(ColorConstants.BRAND_600)
              }
              .padding(16)
              .backgroundColor(ColorConstants.BG_CARD)
              .borderRadius(16)
            }, (record: TransactionRecord) => `${record.id}`)
          }
        }
        .padding(16)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
