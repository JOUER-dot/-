<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import PageHeader from '@/components/common/PageHeader.vue'
import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
import StatusTag from '@/components/ui/StatusTag.vue'
import {
  getProductList,
  getProductReviews,
  offlineProduct,
  submitProduct,
  withdrawProduct,
  type ProductListItem,
  type ReviewRecord
} from '@/api/product'
import { getBatchActionState } from '@/views/advisor/product-list-batch-actions'
import { copyToClipboard } from '@/utils/clipboard'
import { formatText } from '@/utils/format'
import { loadPersisted, savePersisted } from '@/utils/persist'
import { productStatusLabel, productTypeLabel, reviewResultLabel } from '@/utils/status'

const router = useRouter()

const loading = ref(false)
const reviewLoading = ref(false)
const reviewDialogVisible = ref(false)
const reviewRecords = ref<ReviewRecord[]>([])
const reviewTarget = ref<ProductListItem | null>(null)
const selectedRows = ref<ProductListItem[]>([])

const queryForm = reactive({
  status: '',
  type: '',
  riskLevel: '',
  keyword: ''
})

const pager = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const records = ref<ProductListItem[]>([])

const storageKey = 'roboadvisor:advisor-product-list:query'

const statusOptions = ['DRAFT', 'PENDING_REVIEW', 'REJECTED', 'PUBLISHED', 'OFFLINE']
const typeOptions = [
  { label: '策略组合', value: 'STRATEGY' },
  { label: 'FOF组合', value: 'FOF' }
]
const riskOptions = ['R1', 'R2', 'R3', 'R4', 'R5']

const statusSummary = computed(() => {
  const countOf = (status: ProductListItem['status']) => records.value.filter((item) => item.status === status).length

  return {
    draft: countOf('DRAFT'),
    pending: countOf('PENDING_REVIEW'),
    rejected: countOf('REJECTED'),
    published: countOf('PUBLISHED'),
    offline: countOf('OFFLINE')
  }
})

const taskCards = computed(() => {
  const summary = statusSummary.value
  return [
    { label: '待处理草稿', value: String(summary.draft), status: 'DRAFT' },
    { label: '待审核', value: String(summary.pending), status: 'PENDING_REVIEW' },
    { label: '驳回待改', value: String(summary.rejected), status: 'REJECTED' },
    { label: '可下架', value: String(summary.published), status: 'PUBLISHED' }
  ] as Array<{
    label: string
    value: string
    status: ProductListItem['status']
  }>
})

const opsCards = computed(() => {
  const summary = statusSummary.value
  const recentChanged = records.value.filter((item) => {
    const updatedAt = new Date(item.updatedAt).getTime()
    if (Number.isNaN(updatedAt)) {
      return false
    }
    return Date.now() - updatedAt <= 7 * 24 * 60 * 60 * 1000
  }).length

  return [
    { label: '产品总数', value: String(pager.total), hint: '' },
    { label: '已上架', value: String(summary.published), hint: '' },
    { label: '待审核', value: String(summary.pending), hint: '' },
    { label: '近7天变更', value: String(recentChanged), hint: '' }
  ]
})

const urgentItems = computed(() => {
  const ranked = [...records.value].filter((item) => item.status === 'REJECTED' || item.status === 'PENDING_REVIEW')

  ranked.sort((left, right) => {
    const statusPriority = (status: ProductListItem['status']) => (status === 'REJECTED' ? 0 : 1)
    const statusDelta = statusPriority(left.status) - statusPriority(right.status)
    if (statusDelta !== 0) {
      return statusDelta
    }
    return new Date(right.updatedAt).getTime() - new Date(left.updatedAt).getTime()
  })

  return ranked.slice(0, 5)
})

const selectedIds = computed(() => selectedRows.value.map((item) => item.id))
const batchActionState = computed(() => getBatchActionState(selectedRows.value))

const reviewDialogTitle = computed(() => {
  if (!reviewTarget.value) {
    return '审核记录'
  }
  return `审核记录 - ${reviewTarget.value.name}`
})

const quickStatusOptions = computed(() => [
  { label: '全部', value: '' },
  { label: '草稿', value: 'DRAFT' },
  { label: '待审核', value: 'PENDING_REVIEW' },
  { label: '已驳回', value: 'REJECTED' },
  { label: '已上架', value: 'PUBLISHED' },
  { label: '已下架', value: 'OFFLINE' }
])

const loadData = async () => {
  loading.value = true
  try {
    const data = await getProductList({
      ...queryForm,
      status: queryForm.status || undefined,
      type: queryForm.type || undefined,
      riskLevel: queryForm.riskLevel || undefined,
      keyword: queryForm.keyword || undefined,
      pageNum: pager.pageNum,
      pageSize: pager.pageSize
    })
    records.value = data.records
    pager.total = data.total
    selectedRows.value = []
  } finally {
    loading.value = false
  }
}

const handleSearch = async () => {
  pager.pageNum = 1
  await loadData()
}

const handleReset = async () => {
  queryForm.status = ''
  queryForm.type = ''
  queryForm.riskLevel = ''
  queryForm.keyword = ''
  pager.pageNum = 1
  await loadData()
}

const handleSubmit = async (row: ProductListItem) => {
  try {
    await ElMessageBox.confirm('确认提交审核吗？', '提交审核', { type: 'warning' })
  } catch {
    return
  }
  await submitProduct(row.id)
  ElMessage.success('提交审核成功')
  await loadData()
}

const handleWithdraw = async (row: ProductListItem) => {
  try {
    await ElMessageBox.confirm('确认撤回审核吗？', '撤回审核', { type: 'warning' })
  } catch {
    return
  }
  await withdrawProduct(row.id)
  ElMessage.success('撤回审核成功')
  await loadData()
}

const handleOffline = async (row: ProductListItem) => {
  try {
    await ElMessageBox.confirm('确认下架当前产品吗？', '下架产品', { type: 'warning' })
  } catch {
    return
  }
  await offlineProduct(row.id)
  ElMessage.success('下架成功')
  await loadData()
}

const openReviews = async (row: ProductListItem) => {
  reviewTarget.value = row
  reviewLoading.value = true
  reviewDialogVisible.value = true
  try {
    reviewRecords.value = await getProductReviews(row.id)
  } finally {
    reviewLoading.value = false
  }
}

const handleQuickStatus = async (status: string) => {
  queryForm.status = status
  await handleSearch()
}

const handleTaskCardClick = async (status: ProductListItem['status']) => {
  await handleQuickStatus(status)
}

const handleSelectionChange = (rows: ProductListItem[]) => {
  selectedRows.value = rows
}

const handleCopyProductId = async (productId: number) => {
  const ok = await copyToClipboard(String(productId))
  if (!ok) {
    ElMessage.error('复制失败')
    return
  }
  ElMessage.success('已复制产品ID')
}

const handlePrimaryAction = async (row: ProductListItem) => {
  if (row.status === 'DRAFT' || row.status === 'REJECTED') {
    await router.push(`/admin/products/${row.id}/edit`)
    return
  }
  await router.push(`/admin/products/${row.id}`)
}

const handleBatchSubmit = async () => {
  if (!batchActionState.value.canBatchSubmit) {
    ElMessage.warning('当前选择不可批量提交审核')
    return
  }

  try {
    await ElMessageBox.confirm(`确认提交选中的 ${selectedIds.value.length} 个产品吗？`, '批量提交审核', {
      type: 'warning'
    })
  } catch {
    return
  }

  try {
    await Promise.all(selectedIds.value.map((id) => submitProduct(id)))
    ElMessage.success(`已提交 ${selectedIds.value.length} 个产品`)
    await loadData()
  } catch {
    ElMessage.error('批量提交审核失败')
  }
}

const handleBatchOffline = async () => {
  if (!batchActionState.value.canBatchOffline) {
    ElMessage.warning('当前选择不可批量下架')
    return
  }

  try {
    await ElMessageBox.confirm(`确认下架选中的 ${selectedIds.value.length} 个产品吗？`, '批量下架', {
      type: 'warning'
    })
  } catch {
    return
  }

  try {
    await Promise.all(selectedIds.value.map((id) => offlineProduct(id)))
    ElMessage.success(`已下架 ${selectedIds.value.length} 个产品`)
    await loadData()
  } catch {
    ElMessage.error('批量下架失败')
  }
}

onMounted(() => {
  const persisted = loadPersisted<{ query: typeof queryForm; pageSize: number }>(storageKey, {
    query: { status: '', type: '', riskLevel: '', keyword: '' },
    pageSize: 10
  })
  Object.assign(queryForm, persisted.query)
  pager.pageSize = persisted.pageSize || 10
  void loadData()
})

watch(
  () => ({
    query: { ...queryForm },
    pageSize: pager.pageSize
  }),
  (value) => {
    savePersisted(storageKey, value)
  },
  { deep: true }
)
</script>

<template>
  <PageContainer>
    <div class="app-page workbench-page">
      <PageHeader title="组合产品管理" />

      <div class="hero">
        <div>
          <div class="hero__kicker">投顾工作台</div>
          <div class="hero__title">组合产品管理</div>
        </div>
        <el-button type="primary" @click="router.push('/admin/products/create')">创建产品</el-button>
      </div>

      <div class="workbench-overview">
        <SectionCard title="待处理任务" class="task-panel">
          <div class="task-grid">
            <button
              v-for="item in taskCards"
              :key="item.status"
              type="button"
              class="task-card"
              :class="{ 'task-card--active': queryForm.status === item.status }"
              @click="handleTaskCardClick(item.status)"
            >
              <div class="task-card__label">{{ item.label }}</div>
              <div class="task-card__value">{{ item.value }}</div>
              <div class="task-card__status">{{ productStatusLabel(item.status) }}</div>
            </button>
          </div>

          <div class="urgent-block">
            <div class="urgent-block__header">
              <div class="urgent-block__title">优先处理</div>
              <el-button link @click="handleQuickStatus('')">查看全部</el-button>
            </div>

            <el-empty v-if="urgentItems.length === 0" description="当前页暂无待处理项" />
            <div v-else class="urgent-list">
              <button
                v-for="item in urgentItems"
                :key="item.id"
                type="button"
                class="urgent-item"
                @click="handlePrimaryAction(item)"
              >
                <div class="urgent-item__main">
                  <div class="urgent-item__title">{{ item.name }}</div>
                  <div class="urgent-item__meta">
                    <span>{{ productTypeLabel(item.type) }}</span>
                    <span>风险 {{ item.riskLevel }}</span>
                    <span>更新 {{ formatText(item.updatedAt) }}</span>
                  </div>
                  <div v-if="item.status === 'REJECTED' && item.lastRejectComment" class="urgent-item__hint">
                    {{ item.lastRejectComment }}
                  </div>
                </div>
                <div class="urgent-item__side">
                  <StatusTag kind="product" :value="item.status" />
                  <el-button link type="primary">
                    {{ item.status === 'REJECTED' ? '去修改' : '去查看' }}
                  </el-button>
                </div>
              </button>
            </div>
          </div>
        </SectionCard>

        <SectionCard title="经营概览" class="ops-panel">
          <div class="stat-grid">
            <StatCard
              v-for="item in opsCards"
              :key="item.label"
              :label="item.label"
              :value="item.value"
              :hint="item.hint"
            />
          </div>
        </SectionCard>
      </div>

      <SectionCard title="快捷筛选" class="workbench-section">
        <div class="quick-row">
          <el-space wrap>
            <el-button
              v-for="item in quickStatusOptions"
              :key="item.value"
              size="small"
              :type="queryForm.status === item.value ? 'primary' : undefined"
              :plain="queryForm.status !== item.value"
              @click="handleQuickStatus(item.value)"
            >
              {{ item.label }}
            </el-button>
          </el-space>
        </div>
      </SectionCard>

      <SectionCard title="筛选条件" class="workbench-section">
        <el-form :inline="true" :model="queryForm" class="filter-form">
          <el-form-item label="产品状态">
            <el-select v-model="queryForm.status" clearable placeholder="全部">
              <el-option v-for="item in statusOptions" :key="item" :label="productStatusLabel(item)" :value="item" />
            </el-select>
          </el-form-item>
          <el-form-item label="产品类型">
            <el-select v-model="queryForm.type" clearable placeholder="全部">
              <el-option v-for="item in typeOptions" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </el-form-item>
          <el-form-item label="风险等级">
            <el-select v-model="queryForm.riskLevel" clearable placeholder="全部">
              <el-option v-for="item in riskOptions" :key="item" :label="item" :value="item" />
            </el-select>
          </el-form-item>
          <el-form-item label="关键字">
            <el-input
              v-model="queryForm.keyword"
              placeholder="产品名称或策略编码"
              clearable
              @keyup.enter="handleSearch"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleSearch">查询</el-button>
            <el-button @click="handleReset">重置</el-button>
          </el-form-item>
        </el-form>
      </SectionCard>

      <el-card shadow="never" class="section-card table-card">
        <template #header>
          <div class="table-title">
            <div>
              <div class="table-title__main">产品列表</div>
              <div class="table-title__meta">当前页 {{ records.length }} 条，累计 {{ pager.total }} 条</div>
            </div>
            <el-button @click="handleReset">重置筛选</el-button>
          </div>
        </template>

        <div v-if="batchActionState.selectedCount > 0" class="batch-bar">
          <div class="batch-bar__summary">已选择 {{ batchActionState.selectedCount }} 项</div>
          <div class="batch-bar__actions">
            <el-button type="primary" :disabled="!batchActionState.canBatchSubmit" @click="handleBatchSubmit">
              批量提交审核
            </el-button>
            <el-button type="danger" plain :disabled="!batchActionState.canBatchOffline" @click="handleBatchOffline">
              批量下架
            </el-button>
          </div>
        </div>

        <el-empty v-if="!loading && records.length === 0" description="暂无符合条件的产品" />
        <el-table v-else v-loading="loading" :data="records" border @selection-change="handleSelectionChange">
          <el-table-column type="selection" width="46" />
          <el-table-column label="产品" min-width="280">
            <template #default="{ row }">
              <div class="name-cell">
                <div class="name-cell__top">
                  <div class="name-cell__name">{{ row.name }}</div>
                  <StatusTag kind="product" :value="row.status" />
                </div>
                <div class="name-cell__meta">
                  <span>{{ productTypeLabel(row.type) }}</span>
                  <span>风险 {{ row.riskLevel }}</span>
                  <span>更新 {{ formatText(row.updatedAt) }}</span>
                </div>
                <div v-if="row.featureTags?.length" class="name-cell__tags">
                  <el-tag v-for="tag in row.featureTags.slice(0, 3)" :key="tag" effect="plain" size="small">
                    {{ tag }}
                  </el-tag>
                  <el-popover v-if="row.featureTags.length > 3" placement="bottom-start" trigger="hover" width="260">
                    <div class="tag-popover">
                      <el-tag v-for="tag in row.featureTags" :key="tag" effect="plain" size="small">{{ tag }}</el-tag>
                    </div>
                    <template #reference>
                      <el-tag effect="plain" size="small" class="more-tag">+{{ row.featureTags.length - 3 }}</el-tag>
                    </template>
                  </el-popover>
                </div>
                <div v-if="row.status === 'REJECTED' && row.lastRejectComment" class="name-cell__hint">
                  驳回原因：{{ row.lastRejectComment }}
                </div>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="type" label="产品类型" width="120">
            <template #default="{ row }">
              <el-tag effect="plain">{{ productTypeLabel(row.type) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="riskLevel" label="风险等级" width="100" />
          <el-table-column prop="status" label="状态" width="120">
            <template #default="{ row }">
              <StatusTag kind="product" :value="row.status" />
            </template>
          </el-table-column>
          <el-table-column label="操作" min-width="320" fixed="right">
            <template #default="{ row }">
              <div class="action-column">
                <el-space wrap class="action-space">
                  <el-button link type="primary" class="action-link action-link--primary" @click="handlePrimaryAction(row)">
                    {{ row.status === 'DRAFT' || row.status === 'REJECTED' ? '编辑' : '查看' }}
                  </el-button>
                  <el-button
                    v-if="row.status === 'DRAFT' || row.status === 'REJECTED'"
                    link
                    class="action-link"
                    @click="handleSubmit(row)"
                  >
                    提交审核
                  </el-button>
                  <el-button
                    v-if="row.status === 'PENDING_REVIEW'"
                    link
                    class="action-link"
                    @click="handleWithdraw(row)"
                  >
                    撤回审核
                  </el-button>
                  <el-button
                    v-if="row.status === 'PUBLISHED'"
                    link
                    type="danger"
                    class="action-link"
                    @click="handleOffline(row)"
                  >
                    下架
                  </el-button>
                  <el-button link class="action-link" @click="openReviews(row)">审核记录</el-button>
                  <el-button link class="action-link" @click="handleCopyProductId(row.id)">复制ID</el-button>
                  <el-button
                    v-if="row.status === 'REJECTED' && row.lastRejectComment"
                    link
                    type="danger"
                    class="action-link"
                    @click="ElMessageBox.alert(row.lastRejectComment, '驳回意见')"
                  >
                    驳回意见
                  </el-button>
                </el-space>
              </div>
            </template>
          </el-table-column>
        </el-table>

        <div class="pagination-bar">
          <el-pagination
            background
            layout="total, sizes, prev, pager, next"
            :current-page="pager.pageNum"
            :page-size="pager.pageSize"
            :page-sizes="[10, 20, 50]"
            :total="pager.total"
            @current-change="
              (page: number) => {
                pager.pageNum = page
                loadData()
              }
            "
            @size-change="
              (size: number) => {
                pager.pageSize = size
                pager.pageNum = 1
                loadData()
              }
            "
          />
        </div>
      </el-card>

      <el-dialog v-model="reviewDialogVisible" :title="reviewDialogTitle" width="760px">
        <div v-loading="reviewLoading">
          <el-empty v-if="reviewRecords.length === 0" description="暂无审核记录" />
          <el-timeline v-else>
            <el-timeline-item
              v-for="(item, index) in reviewRecords"
              :key="index"
              :timestamp="item.reviewedAt"
            >
              <div class="review-title">{{ reviewResultLabel(item.result) }} / {{ item.reviewerName || '审核人' }}</div>
              <div class="review-comment">{{ item.comment || '无审核意见' }}</div>
            </el-timeline-item>
          </el-timeline>
        </div>
      </el-dialog>
    </div>
  </PageContainer>
</template>

<style scoped>
.workbench-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.hero {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  padding: 18px;
  border-radius: var(--radius-card);
  border: 1px solid var(--color-border);
  background:
    radial-gradient(640px 220px at 18% 18%, rgba(22, 59, 102, 0.12), transparent 60%),
    linear-gradient(180deg, var(--color-bg-card) 0%, #f8fafc 100%);
  box-shadow: var(--shadow-soft);
}

.hero__kicker {
  color: var(--color-text-2);
  font-size: 12px;
  line-height: 18px;
}

.hero__title {
  margin-top: 10px;
  font-size: 26px;
  line-height: 34px;
  font-weight: 900;
  color: var(--color-text-1);
}

.stat-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
}

.workbench-overview {
  display: grid;
  grid-template-columns: minmax(0, 1.4fr) minmax(320px, 1fr);
  gap: 16px;
}

.workbench-section {
  border-radius: 18px;
}

.task-panel,
.ops-panel {
  height: 100%;
}

.task-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
}

.task-card {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 8px;
  width: 100%;
  padding: 16px;
  border: 1px solid var(--color-border);
  border-radius: 16px;
  background: linear-gradient(180deg, var(--color-bg-card) 0%, #f8fafc 100%);
  text-align: left;
  cursor: pointer;
  transition: border-color 0.2s ease, transform 0.2s ease, box-shadow 0.2s ease;
}

.task-card:hover {
  border-color: rgba(22, 59, 102, 0.28);
  box-shadow: var(--shadow-soft);
  transform: translateY(-1px);
}

.task-card--active {
  border-color: var(--color-primary);
  box-shadow: 0 10px 24px rgba(22, 59, 102, 0.12);
  background:
    radial-gradient(480px 160px at 12% 10%, rgba(22, 59, 102, 0.12), transparent 55%),
    linear-gradient(180deg, var(--color-bg-card) 0%, #f5f8fc 100%);
}

.task-card__label {
  color: var(--color-text-2);
  font-size: 13px;
  line-height: 20px;
}

.task-card__value {
  color: var(--color-text-1);
  font-size: 28px;
  line-height: 34px;
  font-weight: 800;
}

.task-card__status {
  color: var(--color-text-2);
  font-size: 12px;
  line-height: 18px;
}

.urgent-block {
  margin-top: 18px;
  padding-top: 18px;
  border-top: 1px solid var(--color-border);
}

.urgent-block__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.urgent-block__title {
  font-size: 15px;
  font-weight: 700;
  color: var(--color-text-1);
}

.urgent-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 14px;
}

.urgent-item {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  width: 100%;
  padding: 14px 16px;
  border: 1px solid var(--color-border);
  border-radius: 14px;
  background: #fcfdff;
  text-align: left;
  cursor: pointer;
  transition: border-color 0.2s ease, background-color 0.2s ease;
}

.urgent-item:hover {
  border-color: rgba(22, 59, 102, 0.24);
  background: #f8fbff;
}

.urgent-item__main {
  display: flex;
  flex: 1;
  flex-direction: column;
  gap: 6px;
  min-width: 0;
}

.urgent-item__title {
  font-size: 15px;
  font-weight: 700;
  color: var(--color-text-1);
  line-height: 22px;
}

.urgent-item__meta {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  color: var(--color-text-2);
  font-size: 12px;
}

.urgent-item__hint {
  color: var(--color-danger);
  font-size: 12px;
  line-height: 18px;
}

.urgent-item__side {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 8px;
  flex-shrink: 0;
}

.quick-row {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.filter-form {
  margin-bottom: -18px;
}

.table-title {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.table-title__main {
  font-size: 16px;
  font-weight: 700;
  color: var(--color-text-1);
}

.table-title__meta {
  margin-top: 4px;
  color: var(--color-text-2);
  font-size: 12px;
  line-height: 18px;
}

.table-card {
  border-radius: var(--radius-card);
  box-shadow: var(--shadow-soft);
}

.batch-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 16px;
  padding: 14px 16px;
  border: 1px solid var(--color-border);
  border-radius: 14px;
  background: linear-gradient(180deg, #f8fbff 0%, var(--color-bg-card) 100%);
}

.batch-bar__summary {
  color: var(--color-text-1);
  font-size: 14px;
  font-weight: 700;
}

.batch-bar__actions {
  display: flex;
  flex-wrap: wrap;
  justify-content: flex-end;
  gap: 10px;
}

.name-cell {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.name-cell__top {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 10px;
}

.name-cell__name {
  font-weight: 700;
  color: var(--color-text-1);
  line-height: 20px;
}

.name-cell__meta {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  color: var(--color-text-2);
  font-size: 12px;
}

.name-cell__tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  align-items: center;
}

.tag-popover {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.more-tag {
  cursor: pointer;
}

.name-cell__hint {
  color: var(--color-danger);
  font-size: 12px;
  line-height: 18px;
}

.action-column {
  display: flex;
  align-items: center;
  min-height: 48px;
}

.action-space :deep(.el-button) {
  margin: 0;
}

.action-link {
  padding: 0;
  font-weight: 500;
}

.action-link--primary {
  font-weight: 700;
}

.pagination-bar {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
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

@media (max-width: 900px) {
  .hero,
  .table-title,
  .batch-bar {
    flex-direction: column;
    align-items: stretch;
  }

  .workbench-overview {
    grid-template-columns: 1fr;
  }

  .task-grid {
    grid-template-columns: 1fr;
  }

  .urgent-item {
    flex-direction: column;
  }

  .urgent-item__side {
    align-items: flex-start;
  }
}
</style>
