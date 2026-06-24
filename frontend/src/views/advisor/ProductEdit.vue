<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import PageHeader from '@/components/common/PageHeader.vue'
import SectionNav, { type SectionNavItem } from '@/components/common/SectionNav.vue'
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
      hint: missingBase ? '名称 / 类型 / 风险等级必填' : '可以继续完善策略参数'
    },
    {
      label: '基金成份',
      value: componentOk ? `${productForm.components.length} 只` : '未选择',
      hint: componentOk ? '建议检查成份风险与分布' : '提交前至少选择 1 只基金'
    },
    {
      label: '权重合计',
      value: weightOk ? '1.0000' : weightTotal.value.toFixed(4),
      hint: weightOk ? '满足提交审核条件' : '提交审核前必须等于 1.0000'
    },
    {
      label: '当前状态',
      value: productForm.status,
      hint: readOnly.value ? '仅可查看' : '可编辑草稿并提交审核'
    }
  ]
})

const sections = computed<SectionNavItem[]>(() => [
  { id: 'section-base', label: '基础信息', hint: productForm.name ? '已填写' : '待填写' },
  { id: 'section-params', label: '策略参数', hint: productForm.strategyCode ? '已配置' : '可选' },
  { id: 'section-components', label: '基金成份', hint: `${productForm.components.length} 只` },
  { id: 'section-review', label: '审核记录', hint: `${productForm.reviewSummary.length} 条` }
])

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
    <PageHeader :title="pageTitle" description="草稿编辑、成份维护、提交审核与撤回审核都在同一页面内完成。" />

    <div class="sticky-actions">
      <div class="sticky-actions__inner">
        <div class="sticky-actions__title">
          <strong>{{ pageTitle }}</strong>
          <span>建议按“基础信息 → 策略参数 → 成份维护 → 提交审核”顺序完成</span>
        </div>
        <div class="sticky-actions__buttons">
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
        </div>
      </div>
    </div>

    <div class="summary-grid">
      <div v-for="item in summaryCards" :key="item.label" class="summary-card">
        <div class="summary-card__label">{{ item.label }}</div>
        <div class="summary-card__value">{{ item.value }}</div>
        <div class="summary-card__hint">{{ item.hint }}</div>
      </div>
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

    <div class="content-grid">
      <div class="content-grid__main">
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
        <el-card shadow="never" class="section-card">
          <template #header>
            <div class="section-title">审核记录</div>
          </template>
          <el-empty v-if="productForm.reviewSummary.length === 0" description="暂无审核记录" />
          <el-timeline v-else>
            <el-timeline-item
              v-for="(item, index) in productForm.reviewSummary"
              :key="index"
              :timestamp="item.reviewedAt"
            >
              <div class="review-item-title">{{ item.result }} / {{ item.reviewerName || '审核人' }}</div>
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
      <div class="content-grid__side">
        <SectionNav :sections="sections" :offset-top="124" />
      </div>
    </div>
  </div>
</template>

<style scoped>
.section-anchor {
  position: relative;
  top: -124px;
  height: 0;
}

.section-card {
  margin-bottom: 16px;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.review-item-title {
  margin-bottom: 6px;
  font-weight: 600;
  color: #303133;
}

.review-item-comment {
  color: #606266;
  line-height: 1.7;
}

.mb-16 {
  margin-bottom: 16px;
}
</style>
