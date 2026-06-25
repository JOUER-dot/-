<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import PageHeader from '@/components/common/PageHeader.vue'
import ActionBar from '@/components/ui/ActionBar.vue'
import StatCard from '@/components/ui/StatCard.vue'
import ProductBaseForm from '@/components/product/ProductBaseForm.vue'
import ProductParamForm from '@/components/product/ProductParamForm.vue'
import ComponentEditor from '@/components/product/ComponentEditor.vue'
import {
  createProduct,
  getProductDetail,
  submitProduct,
  type ProductComponentItem,
  type ProductDetail,
  type ProductSavePayload,
  updateProduct,
  withdrawProduct
} from '@/api/product'
import { productStatusLabel, reviewResultLabel } from '@/utils/status'

const router = useRouter()
const route = useRoute()

const loading = ref(false)
const saving = ref(false)
const submitting = ref(false)
const withdrawing = ref(false)

const productForm = reactive({
  id: 0,
  name: '',
  type: '',
  riskLevel: '',
  strategyCode: '',
  featureTags: [] as string[],
  status: 'DRAFT',
  lastRejectComment: '',
  baseInfo: {
    productSummary: '',
    targetCustomer: '',
    riskTips: ''
  },
  params: {
    rebalanceCycleDays: null as number | null,
    minSingleFundWeight: null as number | null,
    maxSingleFundWeight: null as number | null,
    investHorizonMonths: null as number | null,
    strategyNotes: ''
  },
  components: [] as ProductComponentItem[],
  reviewSummary: [] as ProductDetail['reviewSummary'],
  publishedVersion: null as ProductDetail['publishedVersion']
})

const productId = computed(() => {
  const raw = route.params.id
  return raw ? Number(raw) : 0
})

const isCreateMode = computed(() => !productId.value)
const isDetailMode = computed(() => route.name === 'AdvisorProductDetail')
const canEditDraft = computed(() => ['DRAFT', 'REJECTED'].includes(productForm.status))
const readOnly = computed(() => !isCreateMode.value && (isDetailMode.value || !canEditDraft.value))

const pageTitle = computed(() => {
  if (isCreateMode.value) {
    return '创建产品'
  }
  return readOnly.value ? '产品详情' : '编辑草稿'
})

const weightTotal = computed(() =>
  productForm.components.reduce((sum, item) => sum + Number(item.weight || 0), 0)
)

const summaryCards = computed(() => {
  const missingBase =
    !productForm.name.trim() || !productForm.type || !productForm.riskLevel
  const componentOk = productForm.components.length > 0
  const weightOk = Math.abs(weightTotal.value - 1) < 0.000001
  return [
    {
      label: '基础信息',
      value: missingBase ? '待完善' : '已完成',
      hint: ''
    },
    {
      label: '基金成份',
      value: componentOk ? `${productForm.components.length} 只` : '未选择',
      hint: componentOk ? '' : '至少 1 只'
    },
    {
      label: '权重合计',
      value: weightOk ? '1.0000' : weightTotal.value.toFixed(4),
      hint: weightOk ? '' : '需等于 1.0000'
    },
    {
      label: '当前状态',
      value: productForm.status,
      hint: readOnly.value ? '' : ''
    }
  ]
})

const fillForm = (detail: ProductDetail) => {
  productForm.id = detail.id
  productForm.name = detail.name
  productForm.type = detail.type
  productForm.riskLevel = detail.riskLevel
  productForm.strategyCode = detail.strategyCode || ''
  productForm.featureTags = detail.featureTags || []
  productForm.status = detail.status
  productForm.lastRejectComment = detail.lastRejectComment || ''
  productForm.baseInfo = {
    productSummary: String(detail.baseInfo?.productSummary || ''),
    targetCustomer: String(detail.baseInfo?.targetCustomer || ''),
    riskTips: String(detail.baseInfo?.riskTips || '')
  }
  productForm.params = {
    rebalanceCycleDays:
      typeof detail.params?.rebalanceCycleDays === 'number' ? Number(detail.params.rebalanceCycleDays) : null,
    minSingleFundWeight:
      typeof detail.params?.minSingleFundWeight === 'number' ? Number(detail.params.minSingleFundWeight) : null,
    maxSingleFundWeight:
      typeof detail.params?.maxSingleFundWeight === 'number' ? Number(detail.params.maxSingleFundWeight) : null,
    investHorizonMonths:
      typeof detail.params?.investHorizonMonths === 'number' ? Number(detail.params.investHorizonMonths) : null,
    strategyNotes: String(detail.params?.strategyNotes || '')
  }
  productForm.components = detail.components || []
  productForm.reviewSummary = detail.reviewSummary || []
  productForm.publishedVersion = detail.publishedVersion
}

const loadDetail = async () => {
  if (!productId.value) {
    return
  }
  loading.value = true
  try {
    const detail = await getProductDetail(productId.value)
    fillForm(detail)
  } finally {
    loading.value = false
  }
}

const validateDraftBeforeSave = () => {
  if (!productForm.name.trim()) {
    throw new Error('产品名称不能为空')
  }
  if (!productForm.type) {
    throw new Error('产品类型不能为空')
  }
  if (!productForm.riskLevel) {
    throw new Error('风险等级不能为空')
  }
}

const validateBeforeSubmit = () => {
  validateDraftBeforeSave()
  if (productForm.components.length === 0) {
    throw new Error('请至少选择一只基金')
  }
  if (Math.abs(weightTotal.value - 1) > 0.000001) {
    throw new Error('组合权重合计必须等于 1')
  }
}

const buildPayload = (): ProductSavePayload => ({
  name: productForm.name.trim(),
  type: productForm.type,
  riskLevel: productForm.riskLevel,
  strategyCode: productForm.strategyCode.trim(),
  featureTags: productForm.featureTags,
  baseInfo: {
    productSummary: productForm.baseInfo.productSummary.trim(),
    targetCustomer: productForm.baseInfo.targetCustomer.trim(),
    riskTips: productForm.baseInfo.riskTips.trim()
  },
  params: {
    rebalanceCycleDays: productForm.params.rebalanceCycleDays,
    minSingleFundWeight: productForm.params.minSingleFundWeight,
    maxSingleFundWeight: productForm.params.maxSingleFundWeight,
    investHorizonMonths: productForm.params.investHorizonMonths,
    strategyNotes: productForm.params.strategyNotes.trim()
  },
  components: productForm.components.map((item) => ({
    fundId: item.fundId,
    weight: Number(item.weight)
  }))
})

const saveDraft = async () => {
  validateDraftBeforeSave()
  const payload = buildPayload()

  saving.value = true
  try {
    if (isCreateMode.value) {
      const data = await createProduct(payload)
      ElMessage.success('草稿已创建')
      await router.replace(`/admin/products/${data.productId}/edit`)
      return
    }
    await updateProduct(productId.value, payload)
    ElMessage.success('草稿已保存')
    await loadDetail()
  } finally {
    saving.value = false
  }
}

const handleSaveDraft = async () => {
  try {
    await saveDraft()
  } catch (error) {
    ElMessage.error(error instanceof Error ? error.message : '保存失败')
  }
}

const handleSubmit = async () => {
  try {
    validateBeforeSubmit()
    await ElMessageBox.confirm('确认提交审核吗？提交后将进入待审状态。', '提交审核', {
      type: 'warning'
    })
  } catch (error) {
    if (error instanceof Error) {
      ElMessage.error(error.message)
    }
    return
  }

  submitting.value = true
  try {
    let targetProductId = productId.value
    const payload = buildPayload()
    if (isCreateMode.value) {
      const data = await createProduct(payload)
      targetProductId = data.productId
    } else {
      await updateProduct(targetProductId, payload)
    }
    await submitProduct(targetProductId)
    ElMessage.success('已提交审核')
    await router.replace(`/admin/products/${targetProductId}`)
  } finally {
    submitting.value = false
  }
}

const handleWithdraw = async () => {
  if (!productId.value) {
    return
  }
  try {
    await ElMessageBox.confirm('确认撤回审核吗？产品状态将恢复为草稿。', '撤回审核', {
      type: 'warning'
    })
  } catch {
    return
  }

  withdrawing.value = true
  try {
    await withdrawProduct(productId.value)
    ElMessage.success('已撤回审核')
    await loadDetail()
  } finally {
    withdrawing.value = false
  }
}

void loadDetail()
</script>

<template>
  <div v-loading="loading" class="app-page">
    <PageHeader :title="pageTitle" />

    <div class="stat-grid">
      <StatCard
        v-for="item in summaryCards"
        :key="item.label"
        :label="item.label"
        :value="String(item.value)"
        :hint="item.hint"
      />
    </div>

    <el-alert
      v-if="productForm.status === 'REJECTED' && productForm.lastRejectComment"
      title="最近一次驳回意见"
      :description="productForm.lastRejectComment"
      type="error"
      show-icon
      :closable="false"
      class="mb-16"
    />

    <el-alert
      v-if="productForm.status === 'PENDING_REVIEW'"
      title="当前产品正在审核中，仅支持查看详情或撤回审核。"
      type="warning"
      show-icon
      :closable="false"
      class="mb-16"
    />

    <div class="edit-content">
      <div id="section-base" class="section-anchor"></div>
      <ProductBaseForm :model-value="productForm" :read-only="readOnly" />

      <div id="section-params" class="section-anchor"></div>
      <ProductParamForm
        :model-value="productForm.params"
        :read-only="readOnly"
        @update:model-value="(value) => (productForm.params = value)"
      />

      <div id="section-components" class="section-anchor"></div>
      <ComponentEditor
        :model-value="productForm.components"
        :read-only="readOnly"
        @update:model-value="(value) => (productForm.components = value)"
      />

      <div id="section-review" class="section-anchor"></div>
      <el-card
        shadow="never"
        class="section-card"
        :class="{ 'section-card--muted': isCreateMode && productForm.reviewSummary.length === 0 }"
      >
        <template #header>
          <div class="section-title">审核记录</div>
        </template>
        <div v-if="isCreateMode && productForm.reviewSummary.length === 0" class="section-placeholder">
          提交审核后在这里查看记录
        </div>
        <el-empty v-else-if="productForm.reviewSummary.length === 0" description="暂无审核记录" />
        <el-timeline v-else>
          <el-timeline-item
            v-for="(item, index) in productForm.reviewSummary"
            :key="index"
            :timestamp="item.reviewedAt"
          >
            <div class="review-item-title">{{ reviewResultLabel(item.result) }} / {{ item.reviewerName || '审核人' }}</div>
            <div class="review-item-comment">{{ item.comment || '无审核意见' }}</div>
          </el-timeline-item>
        </el-timeline>
      </el-card>

      <el-card v-if="productForm.publishedVersion" shadow="never" class="section-card">
        <template #header>
          <div class="section-title">已发布版本</div>
        </template>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="版本号">
            V{{ productForm.publishedVersion.versionNo }}
          </el-descriptions-item>
          <el-descriptions-item label="版本状态">
            {{ productForm.publishedVersion.versionStatus }}
          </el-descriptions-item>
          <el-descriptions-item label="提交时间">
            {{ productForm.publishedVersion.submittedAt || '-' }}
          </el-descriptions-item>
        </el-descriptions>
      </el-card>
    </div>

    <ActionBar
      :title="`当前状态：${productStatusLabel(productForm.status)}`"
    >
      <el-button @click="router.push('/admin/products')">返回列表</el-button>
      <el-button v-if="!readOnly" type="primary" :loading="saving" @click="handleSaveDraft">保存草稿</el-button>
      <el-button v-if="!readOnly" type="success" :loading="submitting" @click="handleSubmit">提交审核</el-button>
      <el-button
        v-if="productForm.status === 'PENDING_REVIEW'"
        type="warning"
        :loading="withdrawing"
        @click="handleWithdraw"
      >
        撤回审核
      </el-button>
    </ActionBar>
  </div>
</template>

<style scoped>
.edit-content {
  display: flex;
  flex-direction: column;
}

.stat-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
  margin-bottom: 16px;
}

.section-anchor {
  position: relative;
  top: -124px;
  height: 0;
}

.section-card {
  margin-bottom: 16px;
}

.section-card--muted {
  border-style: dashed;
  background: linear-gradient(180deg, rgba(248, 250, 252, 0.72) 0%, rgba(255, 255, 255, 0.92) 100%);
}

.section-title {
  font-size: 16px;
  font-weight: 700;
  color: var(--color-text-1);
}

.section-placeholder {
  color: var(--color-text-2);
  font-size: 13px;
  line-height: 20px;
}

.review-item-title {
  margin-bottom: 6px;
  font-weight: 700;
  color: var(--color-text-1);
}

.review-item-comment {
  color: var(--color-text-2);
  line-height: 1.7;
}

.mb-16 {
  margin-bottom: 16px;
}
</style>
