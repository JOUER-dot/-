// file: entry/src/main/ets/pages/Reviewer/ReviewHistoryPage.ets
import { ReviewApi } from '../../api/review';
import { QueryParam } from '../../api/request';
import { ReviewRecord } from '../../models/types';
import { StatusTag } from '../../components/ui/StatusTag';
import { EmptyState } from '../../components/ui/EmptyState';
import { ColorConstants } from '../../theme/ColorConstants';
import { shortDate } from '../../utils/format';

@Component
export struct ReviewHistoryPage {
  @State records: ReviewRecord[] = [];

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.records = await ReviewApi.history([
      new QueryParam('pageNum', 1),
      new QueryParam('pageSize', 50)
    ]);
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text('我的审核记录')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
        if (this.records.length === 0) {
          EmptyState({ message: '暂无审核记录' })
        } else {
          ForEach(this.records, (record: ReviewRecord) => {
            Column({ space: 8 }) {
              Row() {
                Text(record.productName || '审核记录')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)
                StatusTag({ status: record.result, type: 'review' })
              }
              Text(record.comment || '无批语')
                .fontSize(13)
                .fontColor(ColorConstants.TEXT_SECONDARY)
              Text(shortDate(record.reviewedAt))
                .fontSize(12)
                .fontColor(ColorConstants.TEXT_HINT)
            }
            .padding(16)
            .backgroundColor(ColorConstants.BG_CARD)
            .borderRadius(16)
          }, (record: ReviewRecord) => `${record.result}-${record.reviewedAt}`)
        }
      }
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ColorConstants.BG_PAGE)
  }
}
