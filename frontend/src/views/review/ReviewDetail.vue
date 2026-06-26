<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import PageHeader from '@/components/common/PageHeader.vue'
import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
import StatusTag from '@/components/ui/StatusTag.vue'
import {
  approveReview,
  getReviewDetail,
  rejectReview,
  type ReviewApprovePayload,
  type ReviewDetail
} from '@/api/review'
import type { ProductComponentItem } from '@/api/product'
import type { ReviewComponentDiffDisplayItem } from './review-detail-diff'
import { formatPercent, formatText, formatDecimal } from '@/utils/format'
import { productTypeLabel, reviewResultLabel } from '@/utils/status'
import {
  formatReviewFieldDiffValue,
  getReviewDetailDiffSummary,
  getReviewImpactNotice,
  groupReviewComponentDiffs
} from './review-detail-diff'

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const approving = ref(false)
const rejecting = ref(false)
const rejectDialogVisible = ref(false)
const fundDialogVisible = ref(false)
const selectedFund = ref<ProductComponentItem | ReviewComponentDiffDisplayItem | null>(null)

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
const componentCount = computed(() => detail.components.length)
const diffSummary = computed(() => getReviewDetailDiffSummary(detail))
const groupedComponentDiffs = computed(() => groupReviewComponentDiffs(detail.componentDiffs || []))
const hasComponentDiffs = computed(
  () =>
    groupedComponentDiffs.value.added.length > 0 ||
    groupedComponentDiffs.value.removed.length > 0 ||
    groupedComponentDiffs.value.updated.length > 0
)
const impactNotice = computed(() => getReviewImpactNotice(detail.changeType))
const changeTypeLabel = computed(() => {
  if (detail.changeType === 'MAJOR') return '重大变更'
  if (detail.changeType === 'NORMAL') return '普通变更'
  return '待识别'
})
const currentMaxSingleWeight = computed(() => {
  let max = Number.NEGATIVE_INFINITY
  detail.components.forEach((item) => {
    const value = Number(item.weight)
    if (Number.isFinite(value) && value > max) max = value
  })
  return max === Number.NEGATIVE_INFINITY ? null : max
})
const weightSum = computed(() => {
  let sum = 0
  detail.components.forEach((item) => {
    const w = Number(item.weight)
    if (Number.isFinite(w)) sum += w
  })
  return sum
})

// 审核摘要：产品信息完整性检查
const auditChecks = computed(() => {
  const checks: Array<{ label: string; ok: boolean; detail: string; type: 'info' | 'rule' | 'warn' }> = []

  // 基础信息
  checks.push({
    label: '产品名称',
    ok: !!detail.name,
    detail: detail.name || '未填写',
    type: 'info'
  })
  checks.push({
    label: '产品类型',
    ok: !!detail.type,
    detail: detail.type ? productTypeLabel(detail.type) : '未选择',
    type: 'info'
  })
  checks.push({
    label: '风险等级',
    ok: !!detail.riskLevel,
    detail: detail.riskLevel || '未选择',
    type: 'info'
  })
  checks.push({
    label: '策略编码',
    ok: !!detail.strategyCode,
    detail: detail.strategyCode || '未填写',
    type: 'info'
  })

  // 产品简介
  const summary = String(detail.baseInfo?.productSummary || '')
  checks.push({
    label: '产品简介',
    ok: summary.length >= 10,
    detail: summary ? `${summary.slice(0, 50)}${summary.length > 50 ? '...' : ''}` : '未填写',
    type: summary ? 'info' : 'warn'
  })

  // 基金成分
  checks.push({
    label: '基金成分数量',
    ok: componentCount.value >= 1,
    detail: `当前 ${componentCount.value} 只基金`,
    type: componentCount.value >= 1 ? 'info' : 'warn'
  })
  checks.push({
    label: '权重合计',
    ok: Math.abs(weightSum.value - 1) < 0.001,
    detail: `当前 ${formatDecimal(weightSum.value, 4)}，应等于 1.0000`,
    type: Math.abs(weightSum.value - 1) < 0.001 ? 'info' : 'warn'
  })

  // 单个基金最大权重检查
  if (currentMaxSingleWeight.value !== null && currentMaxSingleWeight.value > 0.5) {
    checks.push({
      label: '单基金最大权重',
      ok: currentMaxSingleWeight.value <= 0.5,
      detail: `当前 ${formatPercent(currentMaxSingleWeight.value)}，建议不超过 50%`,
      type: 'warn'
    })
  }

  return checks
})

const summaryCards = computed(() => [
  {
    label: '待审版本',
    value: `V${detail.currentVersionSummary?.versionNo ?? detail.versionNo ?? '-'}`,
    hint: detail.currentVersionSummary?.submittedAt || detail.submittedAt || ''
  },
  {
    label: '基线版本',
    value: detail.baseVersionSummary?.versionNo ? `V${detail.baseVersionSummary.versionNo}` : '首版提交',
    hint: detail.baseVersionSummary?.submittedAt || ''
  },
  {
    label: '基金数量',
    value: String(componentCount.value),
    hint: ''
  },
  {
    label: '变更类型',
    value: changeTypeLabel.value,
    hint: ''
  }
])

const handleFundClick = (fund: ProductComponentItem | ReviewComponentDiffDisplayItem) => {
  selectedFund.value = fund
  fundDialogVisible.value = true
}

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
  if (overrideForm.overrideMinFundCount !== undefined) payload.overrideMinFundCount = overrideForm.overrideMinFundCount
  if (overrideForm.overrideMaxFundCount !== undefined) payload.overrideMaxFundCount = overrideForm.overrideMaxFundCount
  if (overrideForm.overrideMaxSingleWeight !== undefined) payload.overrideMaxSingleWeight = overrideForm.overrideMaxSingleWeight
  const decisionComment = overrideForm.decisionComment.trim()
  if (decisionComment) payload.decisionComment = decisionComment
  return payload
}

const handleApprove = async () => {
  try {
    await ElMessageBox.confirm(
      detail.changeType === 'MAJOR'
        ? '确认审核通过吗？通过后将发布该版本，并触发已订阅用户确认流程。'
        : '确认审核通过吗？通过后将发布该版本，并向已订阅用户发送版本更新提醒。',
      '审核通过',
      { type: 'warning' }
    )
  } catch {
    return
  }
  approving.value = true
  try {
    await approveReview(productId.value, buildApprovePayload())
    ElMessage.success('审核通过成功')
    await router.replace('/review/pending')
  } catch {
    // handled by interceptor
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
      <StatCard v-for="item in summaryCards" :key="item.label" :label="item.label" :value="item.value" :hint="item.hint" />
    </div>

    <!-- 产品基本信息 -->
    <SectionCard title="产品信息">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="产品名称" :span="2">{{ detail.name }}</el-descriptions-item>
        <el-descriptions-item label="产品类型">{{ productTypeLabel(detail.type) }}</el-descriptions-item>
        <el-descriptions-item label="风险等级">{{ detail.riskLevel }}</el-descriptions-item>
        <el-descriptions-item label="策略编码">{{ formatText(detail.strategyCode) }}</el-descriptions-item>
        <el-descriptions-item label="创建人">{{ formatText(detail.creatorName) }}</el-descriptions-item>
        <el-descriptions-item label="产品标签" :span="2">
          <el-space wrap>
            <el-tag v-for="tag in detail.featureTags" :key="tag" effect="plain" size="small">{{ tag }}</el-tag>
            <span v-if="!detail.featureTags?.length" class="text-muted">无</span>
          </el-space>
        </el-descriptions-item>
        <el-descriptions-item label="产品简介" :span="2">{{ formatText(detail.baseInfo?.productSummary) }}</el-descriptions-item>
        <el-descriptions-item label="目标客户" :span="2">{{ formatText(detail.baseInfo?.targetCustomer) }}</el-descriptions-item>
        <el-descriptions-item label="风险提示" :span="2">{{ formatText(detail.baseInfo?.riskTips) }}</el-descriptions-item>
      </el-descriptions>
    </SectionCard>

    <!-- 策略参数 -->
    <SectionCard title="策略参数" v-if="detail.params && Object.keys(detail.params).length > 0">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="调仓周期（天）">{{ formatText(detail.params?.rebalanceCycleDays) }}</el-descriptions-item>
        <el-descriptions-item label="单基金最小权重">{{ formatPercent(detail.params?.minSingleFundWeight) }}</el-descriptions-item>
        <el-descriptions-item label="单基金最大权重">{{ formatPercent(detail.params?.maxSingleFundWeight) }}</el-descriptions-item>
        <el-descriptions-item label="建议持有期（月）">{{ formatText(detail.params?.investHorizonMonths) }}</el-descriptions-item>
        <el-descriptions-item label="策略说明" :span="2">{{ formatText(detail.params?.strategyNotes) }}</el-descriptions-item>
      </el-descriptions>
    </SectionCard>

    <!-- 审核摘要：产品完整性检查 -->
    <SectionCard title="审核摘要">
      <div class="check-list">
        <div
          v-for="item in auditChecks"
          :key="item.label"
          class="check-card"
          :class="{ 'is-pass': item.ok, 'is-fail': !item.ok, 'is-warn': !item.ok && item.type === 'warn' }"
        >
          <div class="check-card__title">{{ item.label }}</div>
          <div class="check-card__result">{{ item.ok ? '✓' : '需关注' }}</div>
          <div class="check-card__detail">{{ item.detail }}</div>
        </div>
      </div>
    </SectionCard>

    <!-- 版本信息 -->
    <SectionCard title="版本信息">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="当前版本">V{{ detail.currentVersionSummary?.versionNo ?? detail.versionNo }}</el-descriptions-item>
        <el-descriptions-item label="版本状态">{{ reviewResultLabel(detail.currentVersionSummary?.versionStatus || detail.versionStatus) }}</el-descriptions-item>
        <el-descriptions-item label="基线版本">{{ detail.baseVersionSummary?.versionNo ? `V${detail.baseVersionSummary.versionNo}` : '首版提交' }}</el-descriptions-item>
        <el-descriptions-item label="基线版本状态">{{ detail.baseVersionSummary?.versionStatus ? reviewResultLabel(detail.baseVersionSummary.versionStatus) : '-' }}</el-descriptions-item>
        <el-descriptions-item label="变更类型">
          <el-tag :type="detail.changeType === 'MAJOR' ? 'danger' : 'info'" effect="plain">{{ changeTypeLabel }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="提交时间">{{ formatText(detail.currentVersionSummary?.submittedAt || detail.submittedAt) }}</el-descriptions-item>
        <el-descriptions-item label="版本摘要" :span="2">{{ formatText(detail.versionNote) }}</el-descriptions-item>
      </el-descriptions>
    </SectionCard>

    <!-- 核心字段差异（有基线版本时显示） -->
    <SectionCard title="核心字段差异" v-if="detail.fieldDiffs?.length">
      <div class="field-diff-list">
        <div v-for="item in detail.fieldDiffs" :key="item.fieldKey" class="field-diff-card">
          <div class="field-diff-card__header">
            <span class="field-diff-card__title">{{ item.fieldLabel }}</span>
            <el-tag v-if="item.majorSignal" type="danger" effect="plain" size="small">重大变更</el-tag>
          </div>
          <div class="field-diff-card__values">
            <div class="field-diff-card__value">
              <span class="field-diff-card__label">原值</span>
              <span>{{ formatReviewFieldDiffValue(item, item.beforeValue) }}</span>
            </div>
            <span class="field-diff-card__arrow">→</span>
            <div class="field-diff-card__value is-current">
              <span class="field-diff-card__label">新值</span>
              <span>{{ formatReviewFieldDiffValue(item, item.afterValue) }}</span>
            </div>
          </div>
        </div>
      </div>
    </SectionCard>

    <!-- 基金成分 -->
    <SectionCard title="基金成分">
      <template v-if="hasComponentDiffs">
        <div class="diff-notice">相较基线版本存在以下变更：</div>
        <div class="component-diff-groups">
          <div v-if="groupedComponentDiffs.added.length" class="component-diff-group">
            <div class="component-diff-group__title">新增（{{ groupedComponentDiffs.added.length }}）</div>
            <div class="component-diff-list">
              <div v-for="item in groupedComponentDiffs.added" :key="item.fundId" class="component-item" @click="handleFundClick(item)">
                <div class="component-item__header">
                  <span class="component-item__name">{{ item.fundName }}</span>
                  <el-tag size="small" effect="plain">{{ item.fundCode }}</el-tag>
                  <el-tag type="success" size="small" effect="dark">新增</el-tag>
                </div>
                <div class="component-item__meta">权重 {{ item.afterWeightText }}</div>
              </div>
            </div>
          </div>
          <div v-if="groupedComponentDiffs.removed.length" class="component-diff-group">
            <div class="component-diff-group__title">移除（{{ groupedComponentDiffs.removed.length }}）</div>
            <div class="component-diff-list">
              <div v-for="item in groupedComponentDiffs.removed" :key="item.fundId" class="component-item" @click="handleFundClick(item)">
                <div class="component-item__header">
                  <span class="component-item__name">{{ item.fundName }}</span>
                  <el-tag size="small" effect="plain">{{ item.fundCode }}</el-tag>
                  <el-tag type="danger" size="small" effect="dark">移除</el-tag>
                </div>
                <div class="component-item__meta">原权重 {{ item.beforeWeightText }}</div>
              </div>
            </div>
          </div>
          <div v-if="groupedComponentDiffs.updated.length" class="component-diff-group">
            <div class="component-diff-group__title">调仓（{{ groupedComponentDiffs.updated.length }}）</div>
            <div class="component-diff-list">
              <div v-for="item in groupedComponentDiffs.updated" :key="item.fundId" class="component-item" @click="handleFundClick(item)">
                <div class="component-item__header">
                  <span class="component-item__name">{{ item.fundName }}</span>
                  <el-tag size="small" effect="plain">{{ item.fundCode }}</el-tag>
                  <el-tag type="warning" size="small" effect="dark">调仓</el-tag>
                </div>
                <div class="component-item__meta">{{ item.beforeWeightText }} → {{ item.afterWeightText }}（{{ item.deltaText }}）</div>
              </div>
            </div>
          </div>
        </div>
      </template>
      <template v-else>
        <div class="component-list">
          <div v-for="(item, idx) in detail.components" :key="idx" class="component-item" @click="handleFundClick(item)">
            <div class="component-item__header">
              <span class="component-item__name">{{ item.fundName || '未命名基金' }}</span>
              <el-tag size="small" effect="plain">{{ item.fundCode }}</el-tag>
            </div>
            <div class="component-item__meta">
              权重 {{ formatPercent(item.weight) }} · {{ formatText(item.fundType) }}
              <template v-if="item.riskLevel"> · 风险 {{ item.riskLevel }}</template>
            </div>
          </div>
          <el-empty v-if="!detail.components.length" description="未配置基金成分" />
        </div>
      </template>
    </SectionCard>

    <!-- 审核影响 -->
    <SectionCard title="审核影响">
      <el-alert :type="impactNotice.tone" :closable="false" :title="impactNotice.title" show-icon>
        <template #default>
          <div class="impact-alert__desc">{{ impactNotice.description }}</div>
        </template>
      </el-alert>
    </SectionCard>

    <!-- 规则覆盖（仅审核员需要时展开） -->
    <SectionCard title="规则覆盖（可选）">
      <div class="rule-block">
        <el-descriptions :column="2" border size="small">
          <el-descriptions-item label="当前成份数量">{{ componentCount }}</el-descriptions-item>
          <el-descriptions-item label="当前最大单基金权重">{{ formatPercent(currentMaxSingleWeight) }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <el-form label-position="top" class="rule-form">
        <el-row :gutter="16">
          <el-col :span="8">
            <el-form-item label="覆盖最少成份数">
              <el-input-number v-model="overrideForm.overrideMinFundCount" :min="0" :step="1" step-strictly controls-position="right" class="rule-input" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="覆盖最多成份数">
              <el-input-number v-model="overrideForm.overrideMaxFundCount" :min="0" :step="1" step-strictly controls-position="right" class="rule-input" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="覆盖最大单基金权重">
              <el-input-number v-model="overrideForm.overrideMaxSingleWeight" :min="0" :max="1" :step="0.0001" :precision="4" controls-position="right" class="rule-input" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="覆盖说明">
          <el-input v-model="overrideForm.decisionComment" type="textarea" :rows="2" maxlength="500" show-word-limit placeholder="填写覆盖原因（必填）" />
        </el-form-item>
      </el-form>
    </SectionCard>

    <!-- 历史审核记录 -->
    <SectionCard title="历史审核记录">
      <el-empty v-if="detail.reviewSummary.length === 0" description="暂无审核记录" />
      <el-timeline v-else>
        <el-timeline-item v-for="(item, index) in detail.reviewSummary" :key="index" :timestamp="item.reviewedAt">
          <div class="review-title">{{ reviewResultLabel(item.result) }} / {{ item.reviewerName || '审核人' }}</div>
          <div class="review-comment">{{ item.comment || '无审核意见' }}</div>
        </el-timeline-item>
      </el-timeline>
    </SectionCard>

    <!-- 驳回对话框 -->
    <el-dialog v-model="rejectDialogVisible" title="审核驳回" width="560px">
      <el-form label-position="top">
        <el-form-item label="驳回意见" required>
          <el-input v-model="rejectForm.comment" type="textarea" :rows="4" maxlength="500" show-word-limit placeholder="请输入驳回原因" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="rejectDialogVisible = false">取消</el-button>
        <el-button type="danger" :loading="rejecting" @click="submitReject">确认驳回</el-button>
      </template>
    </el-dialog>

    <!-- 基金详情对话框 -->
    <el-dialog v-model="fundDialogVisible" :title="selectedFund?.fundName || '基金详情'" width="520px">
      <template v-if="selectedFund">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="基金名称">{{ selectedFund.fundName }}</el-descriptions-item>
          <el-descriptions-item label="基金代码">{{ formatText(selectedFund.fundCode) }}</el-descriptions-item>
          <el-descriptions-item label="基金类型">{{ formatText((selectedFund as ProductComponentItem).fundType) }}</el-descriptions-item>
          <el-descriptions-item label="风险等级">{{ formatText((selectedFund as ProductComponentItem).riskLevel) }}</el-descriptions-item>
          <el-descriptions-item label="基金公司">{{ formatText((selectedFund as ProductComponentItem).companyName) }}</el-descriptions-item>
          <el-descriptions-item label="配置权重">
            {{ 'weight' in selectedFund ? formatPercent(selectedFund.weight) : ((selectedFund as ReviewComponentDiffDisplayItem).beforeWeightText + ' → ' + (selectedFund as ReviewComponentDiffDisplayItem).afterWeightText) }}
          </el-descriptions-item>
        </el-descriptions>
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

.check-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 10px;
}

.check-card {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 14px 16px;
  border: 1px solid var(--color-border);
  border-radius: 12px;
  background: var(--color-bg-card);
}

.check-card.is-pass {
  border-color: var(--success-600);
  background: var(--success-50);
}

.check-card.is-fail {
  border-color: var(--danger-600);
  background: var(--danger-50);
}

.check-card.is-warn {
  border-color: var(--warning-600);
  background: var(--warning-50);
}

.check-card__title {
  font-size: 13px;
  font-weight: 600;
  color: var(--color-text-1);
}

.check-card__result {
  font-size: 12px;
  font-weight: 700;
}

.is-pass .check-card__result { color: var(--success-600); }
.is-fail .check-card__result { color: var(--danger-600); }
.is-warn .check-card__result { color: var(--warning-600); }

.check-card__detail {
  font-size: 12px;
  color: var(--color-text-2);
  line-height: 1.5;
}

.text-muted {
  color: var(--color-text-3);
  font-size: 13px;
}

.field-diff-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.field-diff-card {
  padding: 14px 16px;
  border: 1px solid var(--color-border);
  border-radius: 12px;
}

.field-diff-card__header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.field-diff-card__title {
  font-weight: 600;
  font-size: 14px;
}

.field-diff-card__values {
  display: flex;
  align-items: center;
  gap: 12px;
}

.field-diff-card__value {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
  padding: 8px 12px;
  border-radius: 8px;
  background: var(--color-bg-muted);
  font-size: 13px;
}

.field-diff-card__value.is-current {
  background: var(--brand-50);
}

.field-diff-card__label {
  font-size: 11px;
  color: var(--color-text-3);
}

.field-diff-card__arrow {
  color: var(--color-text-3);
  font-weight: 700;
}

.diff-notice {
  font-size: 13px;
  color: var(--color-text-2);
  margin-bottom: 12px;
}

.component-diff-groups {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.component-diff-group__title {
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 8px;
  color: var(--color-text-1);
}

.component-list,
.component-diff-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.component-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 14px 16px;
  border: 1px solid var(--color-border);
  border-radius: 12px;
  background: var(--color-bg-card);
  cursor: pointer;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.component-item:hover {
  border-color: var(--color-primary);
  box-shadow: var(--shadow-focus);
}

.component-item__header {
  display: flex;
  align-items: center;
  gap: 8px;
}

.component-item__name {
  font-weight: 600;
  font-size: 14px;
  color: var(--color-text-1);
}

.component-item__meta {
  font-size: 12px;
  color: var(--color-text-2);
}

.rule-block {
  margin-bottom: 16px;
}

.rule-form {
  margin-top: 12px;
}

.rule-input {
  width: 100%;
}

.impact-alert__desc {
  font-size: 13px;
  line-height: 1.6;
}

.review-title {
  margin-bottom: 4px;
  font-weight: 600;
  color: var(--color-text-1);
}

.review-comment {
  color: var(--color-text-2);
  font-size: 13px;
  line-height: 1.6;
}

@media (max-width: 768px) {
  .check-list {
    grid-template-columns: 1fr;
  }
}
</style>
