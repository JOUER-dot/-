<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import PageHeader from '@/components/common/PageHeader.vue'
import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
import {
  approveReview,
  getReviewDetail,
  rejectReview,
  type ReviewApprovePayload,
  type ReviewDetail,
  type ReviewStrategyRule
} from '@/api/review'
import { formatPercent, formatText } from '@/utils/format'
import { productTypeLabel, productStatusLabel, reviewResultLabel } from '@/utils/status'

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const approving = ref(false)
const rejecting = ref(false)
const rejectDialogVisible = ref(false)

const rejectForm = reactive({
  comment: ''
})

const overrideForm = reactive<{
  overrideMinFundCount: number | undefined
  overrideMaxFundCount: number | undefined
  overrideMaxSingleWeight: number | undefined
  decisionComment: string
}>({
  overrideMinFundCount: undefined,
  overrideMaxFundCount: undefined,
  overrideMaxSingleWeight: undefined,
  decisionComment: ''
})

const detail = reactive<ReviewDetail>({
  id: 0,
  name: '',
  type: '',
  riskLevel: '',
  strategyCode: '',
  status: '',
  creatorName: '',
  versionId: 0,
  versionNo: 0,
  versionStatus: '',
  submittedAt: '',
  featureTags: [],
  baseInfo: {},
  params: {},
  components: [],
  reviewSummary: [],
  strategyRule: null,
  baseRule: null
})

const productId = computed(() => Number(route.params.id))
const ruleDetail = computed<ReviewStrategyRule | null>(() => detail.strategyRule || detail.baseRule || null)
const componentCount = computed(() => detail.components.length)
const currentMaxSingleWeight = computed(() => {
  let max = Number.NEGATIVE_INFINITY
  detail.components.forEach((item) => {
    const value = Number(item.weight)
    if (Number.isFinite(value) && value > max) {
      max = value
    }
  })
  return max === Number.NEGATIVE_INFINITY ? null : max
})

const summaryCards = computed(() => [
  {
    label: '版本',
    value: `V${detail.versionNo || '-'}`,
    hint: detail.submittedAt || ''
  },
  {
    label: '成份数量',
    value: String(componentCount.value),
    hint: ''
  },
  {
    label: '最大单基金权重',
    value: formatPercent(currentMaxSingleWeight.value),
    hint: ''
  },
  {
    label: '产品状态',
    value: productStatusLabel(detail.status || '-'),
    hint: ''
  }
])

const ruleCheckItems = computed(() => {
  const checks: Array<{ label: string; ok: boolean; detail: string }> = []
  if (ruleDetail.value?.minFundCount !== null && ruleDetail.value?.minFundCount !== undefined) {
    const min = Number(ruleDetail.value.minFundCount)
    checks.push({
      label: '最少成份数',
      ok: componentCount.value >= min,
      detail: `当前 ${componentCount.value}，要求不少于 ${min}`
    })
  }
  if (ruleDetail.value?.maxFundCount !== null && ruleDetail.value?.maxFundCount !== undefined) {
    const maxCount = Number(ruleDetail.value.maxFundCount)
    checks.push({
      label: '最多成份数',
      ok: componentCount.value <= maxCount,
      detail: `当前 ${componentCount.value}，要求不超过 ${maxCount}`
    })
  }
  if (ruleDetail.value?.maxSingleWeight !== null && ruleDetail.value?.maxSingleWeight !== undefined) {
    const maxWeight = Number(ruleDetail.value.maxSingleWeight)
    checks.push({
      label: '单基金最大权重',
      ok: currentMaxSingleWeight.value === null || currentMaxSingleWeight.value <= maxWeight,
      detail: `当前 ${formatPercent(currentMaxSingleWeight.value)}，要求不超过 ${formatPercent(maxWeight)}`
    })
  }
  return checks
})

const loadDetail = async () => {
  loading.value = true
  try {
    const data = await getReviewDetail(productId.value)
    Object.assign(detail, data)
  } finally {
    loading.value = false
  }
}

const buildApprovePayload = (): ReviewApprovePayload => {
  const payload: ReviewApprovePayload = {}
  if (overrideForm.overrideMinFundCount !== undefined) {
    payload.overrideMinFundCount = overrideForm.overrideMinFundCount
  }
  if (overrideForm.overrideMaxFundCount !== undefined) {
    payload.overrideMaxFundCount = overrideForm.overrideMaxFundCount
  }
  if (overrideForm.overrideMaxSingleWeight !== undefined) {
    payload.overrideMaxSingleWeight = overrideForm.overrideMaxSingleWeight
  }
  const decisionComment = overrideForm.decisionComment.trim()
  if (decisionComment) {
    payload.decisionComment = decisionComment
  }
  return payload
}

const handleApprove = async () => {
  try {
    await ElMessageBox.confirm('确认审核通过吗？通过后产品将上架为 PUBLISHED。', '审核通过', {
      type: 'warning'
    })
  } catch {
    return
  }

  approving.value = true
  try {
    await approveReview(productId.value, buildApprovePayload())
    ElMessage.success('审核通过成功')
    await router.replace('/review/pending')
  } catch {
    return
  } finally {
    approving.value = false
  }
}

const submitReject = async () => {
  if (!rejectForm.comment.trim()) {
    ElMessage.error('驳回意见不能为空')
    return
  }

  rejecting.value = true
  try {
    await rejectReview(productId.value, { comment: rejectForm.comment.trim() })
    ElMessage.success('审核驳回成功')
    rejectDialogVisible.value = false
    await router.replace('/review/pending')
  } finally {
    rejecting.value = false
  }
}

void loadDetail()
</script>

<template>
  <PageContainer>
  <div v-loading="loading" class="app-page review-page">
    <PageHeader title="审核详情">
      <template #actions>
        <el-button @click="router.push('/review/pending')">返回待审列表</el-button>
        <el-button type="success" :loading="approving" @click="handleApprove">审核通过</el-button>
        <el-button type="danger" :loading="rejecting" @click="rejectDialogVisible = true">审核驳回</el-button>
      </template>
    </PageHeader>

    <div class="stat-grid">
      <StatCard
        v-for="item in summaryCards"
        :key="item.label"
        :label="item.label"
        :value="item.value"
        :hint="item.hint"
      />
    </div>

    <SectionCard title="审核摘要">
      <div class="check-list">
        <div v-for="item in ruleCheckItems" :key="item.label" class="check-card" :class="{ 'is-pass': item.ok, 'is-fail': !item.ok }">
          <div class="check-card__title">{{ item.label }}</div>
          <div class="check-card__result">{{ item.ok ? '符合要求' : '需要关注' }}</div>
          <div class="check-card__detail">{{ item.detail }}</div>
        </div>
        <el-empty v-if="ruleCheckItems.length === 0" description="暂无规则校验结果" />
      </div>
    </SectionCard>

    <SectionCard title="基本信息">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="产品名称">{{ detail.name }}</el-descriptions-item>
        <el-descriptions-item label="策略编码">{{ formatText(detail.strategyCode) }}</el-descriptions-item>
        <el-descriptions-item label="产品类型">{{ productTypeLabel(detail.type) }}</el-descriptions-item>
        <el-descriptions-item label="风险等级">{{ detail.riskLevel }}</el-descriptions-item>
        <el-descriptions-item label="创建人">{{ formatText(detail.creatorName) }}</el-descriptions-item>
        <el-descriptions-item label="产品状态">{{ productStatusLabel(detail.status) }}</el-descriptions-item>
        <el-descriptions-item label="版本">V{{ detail.versionNo }}</el-descriptions-item>
        <el-descriptions-item label="版本状态">{{ reviewResultLabel(detail.versionStatus) }}</el-descriptions-item>
        <el-descriptions-item label="提交时间">{{ formatText(detail.submittedAt) }}</el-descriptions-item>
        <el-descriptions-item label="产品标签">
          <el-space wrap>
            <el-tag v-for="tag in detail.featureTags" :key="tag" effect="plain">{{ tag }}</el-tag>
          </el-space>
        </el-descriptions-item>
      </el-descriptions>
    </SectionCard>

    <SectionCard title="基础信息">
      <el-descriptions :column="1" border>
        <el-descriptions-item label="产品简介">
          {{ formatText(detail.baseInfo.productSummary || detail.baseInfo.intro) }}
        </el-descriptions-item>
        <el-descriptions-item label="目标客户">
          {{ formatText(detail.baseInfo.targetCustomer || detail.baseInfo.targetUser) }}
        </el-descriptions-item>
        <el-descriptions-item label="风险提示">
          {{ formatText(detail.baseInfo.riskTips) }}
        </el-descriptions-item>
      </el-descriptions>
    </SectionCard>

    <SectionCard title="策略参数">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="调仓周期（天）">
          {{ formatText(detail.params.rebalanceCycleDays) }}
        </el-descriptions-item>
        <el-descriptions-item label="单基金最小权重">
          {{ formatPercent(detail.params.minSingleFundWeight) }}
        </el-descriptions-item>
        <el-descriptions-item label="单基金最大权重">
          {{ formatPercent(detail.params.maxSingleFundWeight) }}
        </el-descriptions-item>
        <el-descriptions-item label="建议持有期（月）">
          {{ formatText(detail.params.investHorizonMonths) }}
        </el-descriptions-item>
      </el-descriptions>
    </SectionCard>

    <SectionCard title="基金成份">
      <el-table :data="detail.components" border>
        <el-table-column prop="fundCode" label="基金代码" min-width="120" />
        <el-table-column prop="fundName" label="基金名称" min-width="180" />
        <el-table-column prop="fundType" label="基金类型" min-width="120" />
        <el-table-column prop="riskLevel" label="风险等级" width="100" />
          <el-table-column label="权重" width="120">
            <template #default="{ row }">
              {{ formatPercent(row.weight) }}
            </template>
          </el-table-column>
      </el-table>
    </SectionCard>

    <SectionCard title="规则覆盖">
      <div class="rule-block">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="默认最少成份数">
            {{ formatText(ruleDetail?.minFundCount) }}
          </el-descriptions-item>
          <el-descriptions-item label="默认最多成份数">
            {{ formatText(ruleDetail?.maxFundCount) }}
          </el-descriptions-item>
          <el-descriptions-item label="默认单基金最小权重">
            {{ formatPercent(ruleDetail?.minSingleWeight) }}
          </el-descriptions-item>
          <el-descriptions-item label="默认单基金最大权重">
            {{ formatPercent(ruleDetail?.maxSingleWeight) }}
          </el-descriptions-item>
          <el-descriptions-item label="当前成份数量">
            {{ componentCount }}
          </el-descriptions-item>
          <el-descriptions-item label="当前最大单基金权重">
            {{ formatPercent(currentMaxSingleWeight) }}
          </el-descriptions-item>
        </el-descriptions>
      </div>
      <el-form label-position="top" class="rule-form">
        <div class="rule-form-grid">
          <el-form-item label="覆盖最少成份数">
            <el-input-number
              v-model="overrideForm.overrideMinFundCount"
              :min="0"
              :step="1"
              step-strictly
              controls-position="right"
              class="rule-input"
            />
          </el-form-item>
          <el-form-item label="覆盖最多成份数">
            <el-input-number
              v-model="overrideForm.overrideMaxFundCount"
              :min="0"
              :step="1"
              step-strictly
              controls-position="right"
              class="rule-input"
            />
          </el-form-item>
          <el-form-item label="覆盖最大单基金权重">
            <el-input-number
              v-model="overrideForm.overrideMaxSingleWeight"
              :min="0"
              :max="1"
              :step="0.0001"
              :precision="4"
              controls-position="right"
              class="rule-input"
            />
          </el-form-item>
        </div>
        <el-form-item label="覆盖说明">
          <el-input
            v-model="overrideForm.decisionComment"
            type="textarea"
            :rows="3"
            maxlength="500"
            show-word-limit
            placeholder="填写说明"
          />
        </el-form-item>
      </el-form>
    </SectionCard>

    <SectionCard title="历史审核记录">
      <el-empty v-if="detail.reviewSummary.length === 0" description="暂无审核记录" />
      <el-timeline v-else>
        <el-timeline-item
          v-for="(item, index) in detail.reviewSummary"
          :key="index"
          :timestamp="item.reviewedAt"
        >
          <div class="review-title">{{ reviewResultLabel(item.result) }} / {{ item.reviewerName || '审核人' }}</div>
          <div class="review-comment">{{ item.comment || '无审核意见' }}</div>
        </el-timeline-item>
      </el-timeline>
    </SectionCard>

    <el-dialog v-model="rejectDialogVisible" title="审核驳回" width="560px">
      <el-form label-position="top">
        <el-form-item label="驳回意见" required>
          <el-input
            v-model="rejectForm.comment"
            type="textarea"
            :rows="4"
            maxlength="500"
            show-word-limit
            placeholder="请输入内容"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="rejectDialogVisible = false">取消</el-button>
        <el-button type="danger" :loading="rejecting" @click="submitReject">确认驳回</el-button>
      </template>
    </el-dialog>
  </div>
  </PageContainer>
</template>

<style scoped>
.review-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.stat-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
}

.rule-block {
  margin-bottom: 16px;
}

.rule-form {
  margin-top: 16px;
}

.rule-form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 0 16px;
}

.rule-input {
  width: 100%;
}

.check-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 12px;
}

.check-card {
  padding: 16px;
  border-radius: var(--radius-card);
  border: 1px solid var(--color-border);
  background: var(--color-bg-card);
}

.check-card.is-pass {
  background: rgba(18, 183, 106, 0.08);
  border-color: rgba(18, 183, 106, 0.18);
}

.check-card.is-fail {
  background: rgba(217, 45, 32, 0.08);
  border-color: rgba(217, 45, 32, 0.18);
}

.check-card__title {
  color: var(--color-text-2);
  font-size: 13px;
}

.check-card__result {
  margin-top: 8px;
  font-size: 20px;
  font-weight: 700;
  color: var(--color-text-1);
}

.check-card__detail {
  margin-top: 8px;
  color: var(--color-text-2);
  line-height: 20px;
}

.review-title {
  margin-bottom: 6px;
  font-weight: 600;
  color: var(--color-text-1);
}

.review-comment {
  color: var(--color-text-2);
  line-height: 1.7;
}
</style>
