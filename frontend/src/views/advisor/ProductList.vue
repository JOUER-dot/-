<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import PageHeader from '@/components/common/PageHeader.vue'
import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
import StatusTag from '@/components/ui/StatusTag.vue'
import SkeletonLoader from '@/components/common/SkeletonLoader.vue'
import { getWorkbench, type WorkbenchData } from '@/api/workbench'
import {
  getProductList,
  getProductReviews,
  offlineProduct,
  submitProduct,
  withdrawProduct,
  deleteProduct,
  copyProduct,
  getProductFlowLogs,
  type ProductListItem,
  type ReviewRecord
} from '@/api/product'
import { getBatchActionState } from '@/views/advisor/product-list-batch-actions'
import { getWorkbenchFocusState } from '@/views/advisor/product-list-workbench-focus'
import { copyToClipboard } from '@/utils/clipboard'
import { formatText, formatPercent } from '@/utils/format'
import { loadPersisted, savePersisted } from '@/utils/persist'
import { productStatusLabel, productTypeLabel, reviewResultLabel } from '@/utils/status'

const router = useRouter()

// ── 数据状态 ──
const loading = ref(false)
const wbLoading = ref(false)
const reviewLoading = ref(false)
const reviewDialogVisible = ref(false)
const reviewRecords = ref<ReviewRecord[]>([])
const reviewTarget = ref<ProductListItem | null>(null)
const flowLogDialogVisible = ref(false)
const flowLogs = ref<Array<{ id: number; actionType: string; comment: string; createdAt: string }>>([])
const flowLoading = ref(false)
const selectedRows = ref<ProductListItem[]>([])
const workbench = ref<WorkbenchData | null>(null)

const queryForm = reactive({ status: '', type: '', riskLevel: '', keyword: '' })
const pager = reactive({ pageNum: 1, pageSize: 10, total: 0 })
const records = ref<ProductListItem[]>([])
const storageKey = 'roboadvisor:advisor-product-list:query'

const statusOptions = ['DRAFT', 'PENDING_REVIEW', 'REJECTED', 'PUBLISHED', 'OFFLINE']
const typeOptions = [
  { label: '策略组合', value: 'STRATEGY' },
  { label: 'FOF组合', value: 'FOF' }
]
const riskOptions = ['R1', 'R2', 'R3', 'R4', 'R5']

// ── 计算属性 ──
const selectedIds = computed(() => selectedRows.value.map((i) => i.id))
const batchActionState = computed(() => getBatchActionState(selectedRows.value))
const workbenchFocus = computed(() => getWorkbenchFocusState({ ...queryForm }))

const quickStatusOptions = computed(() => [
  { label: '全部', value: '' },
  { label: '草稿', value: 'DRAFT' },
  { label: '待审核', value: 'PENDING_REVIEW' },
  { label: '已驳回', value: 'REJECTED' },
  { label: '已上架', value: 'PUBLISHED' },
  { label: '已下架', value: 'OFFLINE' }
])

const flowActionTypeLabel = (type: string) => {
  const m: Record<string, string> = { SAVE_DRAFT: '保存草稿', SUBMIT: '提交审核', WITHDRAW: '撤回审核', APPROVE: '审核通过', REJECT: '审核驳回', DELETE: '删除', COPY: '复制' }
  return m[type] || type
}

const statusBadge = (status: string) => {
  const m: Record<string, string> = { DRAFT: 'info', PENDING_REVIEW: 'warning', REJECTED: 'danger', PUBLISHED: 'success', OFFLINE: 'info' }
  return m[status] || 'info'
}

const urgentLabel = (item: WorkbenchData['urgentProducts'][0]) => {
  if (item.status === 'REJECTED') return item.waitingDays > 3 ? `已逾期 ${item.waitingDays} 天` : `驳回 ${item.waitingDays} 天`
  return `待审核 ${item.waitingDays} 天`
}

const urgentTagType = (status: string) => status === 'REJECTED' ? 'danger' : 'warning'

// ── 数据加载 ──
const loadWorkbench = async () => {
  wbLoading.value = true
  try { workbench.value = await getWorkbench() } finally { wbLoading.value = false }
}

const loadProductList = async () => {
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
  } finally { loading.value = false }
}

const handleSearch = async () => { pager.pageNum = 1; await loadProductList() }
const handleReset = async () => {
  queryForm.status = ''; queryForm.type = ''; queryForm.riskLevel = ''; queryForm.keyword = ''
  pager.pageNum = 1; await loadProductList()
}

// ── 操作处理 ──
const handleQuickStatus = async (s: string) => { queryForm.status = s; await handleSearch() }
const handleTaskCardClick = async (s: string) => { await handleQuickStatus(s) }

const handleSubmit = async (row: ProductListItem) => {
  try { await ElMessageBox.confirm('确认提交审核吗？', '提交审核', { type: 'warning' }) } catch { return }
  await submitProduct(row.id); ElMessage.success('提交审核成功'); await loadProductList()
}

const handleWithdraw = async (row: ProductListItem) => {
  try { await ElMessageBox.confirm('确认撤回审核吗？', '撤回审核', { type: 'warning' }) } catch { return }
  await withdrawProduct(row.id); ElMessage.success('撤回审核成功'); await loadProductList()
}

const handleOffline = async (row: ProductListItem) => {
  try { await ElMessageBox.confirm('确认下架当前产品吗？', '下架产品', { type: 'warning' }) } catch { return }
  await offlineProduct(row.id); ElMessage.success('下架成功'); await loadProductList()
}

const handleDelete = async (row: ProductListItem) => {
  try { await ElMessageBox.confirm(`确认删除「${row.name}」？不可恢复。`, '删除产品', { type: 'warning' }) } catch { return }
  try { await deleteProduct(row.id); ElMessage.success('删除成功'); await loadProductList() } catch { ElMessage.error('删除失败') }
}

const handleCopy = async (row: ProductListItem) => {
  try { const id = await copyProduct(row.id); ElMessage.success('复制成功'); await router.push(`/admin/products/${id}/edit`) }
  catch { ElMessage.error('复制失败') }
}

const openReviews = async (row: ProductListItem) => {
  reviewTarget.value = row; reviewLoading.value = true; reviewDialogVisible.value = true
  try { reviewRecords.value = await getProductReviews(row.id) } finally { reviewLoading.value = false }
}

const openFlowLogs = async (row: ProductListItem) => {
  flowLoading.value = true; flowLogDialogVisible.value = true
  try { flowLogs.value = await getProductFlowLogs(row.id) } finally { flowLoading.value = false }
}

const handleSelectionChange = (rows: ProductListItem[]) => { selectedRows.value = rows }

const handleCopyProductId = async (id: number) => {
  const ok = await copyToClipboard(String(id))
  if (!ok) { ElMessage.error('复制失败'); return }
  ElMessage.success('已复制产品ID')
}

const handlePrimaryAction = async (row: ProductListItem) => {
  await router.push(row.status === 'DRAFT' || row.status === 'REJECTED' ? `/admin/products/${row.id}/edit` : `/admin/products/${row.id}`)
}

const handleBatchSubmit = async () => {
  if (!batchActionState.value.canBatchSubmit) { ElMessage.warning('当前选择不可批量提交审核'); return }
  try { await ElMessageBox.confirm(`确认提交选中的 ${selectedIds.value.length} 个产品？`, '批量提交审核', { type: 'warning' }) } catch { return }
  let ok = 0, fail = 0
  for (const id of selectedIds.value) { try { await submitProduct(id); ok++ } catch { fail++ } }
  if (ok > 0) ElMessage.success(`成功提交 ${ok} 个${fail > 0 ? `，${fail} 个失败` : ''}`)
  if (fail > 0 && ok === 0) ElMessage.error('批量提交审核失败')
  await loadProductList()
}

const handleBatchOffline = async () => {
  if (!batchActionState.value.canBatchOffline) { ElMessage.warning('当前选择不可批量下架'); return }
  try { await ElMessageBox.confirm(`确认下架选中的 ${selectedIds.value.length} 个产品？`, '批量下架', { type: 'warning' }) } catch { return }
  let ok = 0, fail = 0
  for (const id of selectedIds.value) { try { await offlineProduct(id); ok++ } catch { fail++ } }
  if (ok > 0) ElMessage.success(`成功下架 ${ok} 个${fail > 0 ? `，${fail} 个失败` : ''}`)
  if (fail > 0 && ok === 0) ElMessage.error('批量下架失败')
  await loadProductList()
}

const statusSummary = computed(() => {
  const c = (s: string) => records.value.filter((i) => i.status === s).length
  return { draft: c('DRAFT'), pending: c('PENDING_REVIEW'), rejected: c('REJECTED'), published: c('PUBLISHED'), offline: c('OFFLINE') }
})

const taskCards = computed(() => [
  { label: '待提交审核', value: String(statusSummary.value.draft + statusSummary.value.rejected), status: 'DRAFT', desc: '草稿和已驳回产品可提交审核' },
  { label: '审核中', value: String(statusSummary.value.pending), status: 'PENDING_REVIEW', desc: '等待审核员处理' },
  { label: '已上架', value: String(statusSummary.value.published), status: 'PUBLISHED', desc: '已发布，用户可订阅' },
  { label: '可下架', value: String(statusSummary.value.offline), status: 'OFFLINE', desc: '已下架产品' }
])

onMounted(async () => {
  const persisted = loadPersisted<{ query: typeof queryForm; pageSize: number }>(storageKey, { query: { status: '', type: '', riskLevel: '', keyword: '' }, pageSize: 10 })
  Object.assign(queryForm, persisted.query)
  pager.pageSize = persisted.pageSize || 10
  await Promise.all([loadWorkbench(), loadProductList()])
})

watch(() => ({ query: { ...queryForm }, pageSize: pager.pageSize }), (v) => savePersisted(storageKey, v), { deep: true })
</script>

<template>
  <PageContainer>
    <div class="app-page workbench-page">
      <!-- 顶部 -->
      <PageHeader title="投顾工作台">
        <template #actions>
          <el-button type="primary" @click="router.push('/admin/products/create')">+ 创建产品</el-button>
        </template>
      </PageHeader>

      <!-- 经营概览 -->
      <div v-loading="wbLoading" class="overview-grid">
        <StatCard label="产品总数" :value="String(workbench?.overview.totalProducts ?? 0)" hint="全部产品" />
        <StatCard label="已上架" :value="String(workbench?.overview.publishedProducts ?? 0)" hint="可被用户订阅" />
        <StatCard label="待审核" :value="String(workbench?.overview.pendingReviewProducts ?? 0)" hint="等待审核员处理" />
        <StatCard label="驳回待改" :value="String(workbench?.overview.rejectedProducts ?? 0)" hint="需修改后重新提交" />
        <StatCard label="草稿" :value="String(workbench?.overview.draftProducts ?? 0)" hint="尚未提交" />
        <StatCard label="总订阅人数" :value="String(workbench?.overview.totalSubscriptions ?? 0)" hint="全部产品累计订阅" />
        <StatCard label="近7日新增订阅" :value="String(workbench?.overview.recentWeekSubscriptions ?? 0)" hint="趋势指标" />
      </div>

      <!-- 待办任务 + 优先处理 + 排行 -->
      <div class="workbench-grid">
        <!-- 待办任务 -->
        <SectionCard title="待办任务">
          <div class="task-grid-4">
            <button v-for="item in taskCards" :key="item.status" type="button"
              class="task-card" :class="{ 'task-card--active': queryForm.status === item.status }"
              @click="handleTaskCardClick(item.status)">
              <div class="task-card__value">{{ item.value }}</div>
              <div class="task-card__label">{{ item.label }}</div>
              <div class="task-card__desc">{{ item.desc }}</div>
            </button>
          </div>
        </SectionCard>

        <!-- 优先处理 -->
        <SectionCard title="优先处理">
          <div v-if="!workbench?.urgentProducts?.length" class="empty-hint">暂无待处理项 通过</div>
          <div v-else class="urgent-list">
            <div v-for="item in workbench.urgentProducts" :key="item.id" class="urgent-item"
              @click="router.push(`/admin/products/${item.id}/edit`)">
              <div class="urgent-item__main">
                <div class="urgent-item__top">
                  <span class="urgent-item__name">{{ item.name }}</span>
                  <el-tag :type="urgentTagType(item.status)" size="small" effect="dark">{{ urgentLabel(item) }}</el-tag>
                </div>
                <div class="urgent-item__meta">
                  {{ productTypeLabel(item.type) }} · 风险 {{ item.riskLevel }}
                  <span v-if="item.lastRejectComment"> · 驳回：{{ item.lastRejectComment }}</span>
                </div>
              </div>
              <el-button link type="primary" size="small">{{ item.status === 'REJECTED' ? '去修改' : '查看' }}</el-button>
            </div>
          </div>
        </SectionCard>

        <!-- 产品排行 -->
        <SectionCard title="产品排行">
          <div v-if="!workbench?.productRankings?.length" class="empty-hint">暂无已上架产品</div>
          <div v-else class="rank-list">
            <div v-for="(item, idx) in workbench.productRankings" :key="item.id" class="rank-item"
              @click="router.push(`/admin/products/${item.id}`)">
              <div class="rank-item__pos">{{ idx + 1 }}</div>
              <div class="rank-item__body">
                <div class="rank-item__name">{{ item.name }}</div>
                <div class="rank-item__meta">{{ productTypeLabel(item.type) }} · 风险 {{ item.riskLevel }}</div>
              </div>
              <div class="rank-item__stats">
                <div class="rank-item__subs">{{ item.subscriberCount }} 人订阅</div>
                <div class="rank-item__nav">净值 {{ item.latestNav }}</div>
              </div>
            </div>
          </div>
        </SectionCard>
      </div>

      <!-- 筛选工具带 -->
      <SectionCard title="筛选" class="filter-section">
        <div class="quick-row">
          <el-button v-for="opt in quickStatusOptions" :key="opt.value" size="small"
            :type="queryForm.status === opt.value ? 'primary' : 'default'"
            :plain="queryForm.status !== opt.value"
            @click="handleQuickStatus(opt.value)">{{ opt.label }}</el-button>
        </div>
        <div class="filter-row">
          <el-select v-model="queryForm.type" clearable placeholder="产品类型" size="default" style="width:140px">
            <el-option v-for="t in typeOptions" :key="t.value" :label="t.label" :value="t.value" />
          </el-select>
          <el-select v-model="queryForm.riskLevel" clearable placeholder="风险等级" size="default" style="width:120px">
            <el-option v-for="r in riskOptions" :key="r" :label="r" :value="r" />
          </el-select>
          <el-input v-model="queryForm.keyword" clearable placeholder="产品名称或策略编码" size="default" style="width:240px" @keyup.enter="handleSearch" />
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </div>
      </SectionCard>

      <!-- 产品列表 -->
      <el-card shadow="never" class="table-card">
        <template #header>
          <div class="table-title">
            <div>
              <div class="table-title__main">产品列表</div>
              <div class="table-title__meta">当前页 {{ records.length }} 条，累计 {{ pager.total }} 条</div>
            </div>
            <div class="table-title__badge" v-if="workbenchFocus.hasFilters">
              <el-tag closable size="small" @close="handleReset">{{ workbenchFocus.title }}</el-tag>
            </div>
          </div>
        </template>

        <!-- 批量操作 -->
        <div v-if="batchActionState.selectedCount > 0" class="batch-bar">
          <span class="batch-bar__summary">已选 {{ batchActionState.selectedCount }} 项</span>
          <div class="batch-bar__actions">
            <el-popover v-if="!batchActionState.canBatchSubmit" placement="top" trigger="hover">
              <div>仅草稿和已驳回可批量提交</div>
              <template #reference><el-button type="primary" disabled>批量提交审核</el-button></template>
            </el-popover>
            <el-button v-else type="primary" @click="handleBatchSubmit">批量提交审核</el-button>
            <el-popover v-if="!batchActionState.canBatchOffline" placement="top" trigger="hover">
              <div>仅已上架可批量下架</div>
              <template #reference><el-button type="danger" plain disabled>批量下架</el-button></template>
            </el-popover>
            <el-button v-else type="danger" plain @click="handleBatchOffline">批量下架</el-button>
          </div>
        </div>

        <el-empty v-if="!loading && records.length === 0" description="暂无符合条件的产品" />
        <SkeletonLoader v-else-if="loading && records.length === 0" type="table" :rows="5" />
        <el-table v-else v-loading="loading" :data="records" border @selection-change="handleSelectionChange">
          <el-table-column type="selection" width="46" />
          <el-table-column label="产品" min-width="280">
            <template #default="{ row }">
              <div class="name-cell">
                <div class="name-cell__top">
                  <span class="name-cell__name">{{ row.name }}</span>
                  <StatusTag kind="product" :value="row.status" />
                </div>
                <div class="name-cell__meta">
                  <span>{{ productTypeLabel(row.type) }}</span>
                  <span>风险 {{ row.riskLevel }}</span>
                  <span>更新 {{ formatText(row.updatedAt) }}</span>
                </div>
                <div v-if="row.featureTags?.length" class="name-cell__tags">
                  <el-tag v-for="t in row.featureTags.slice(0, 3)" :key="t" effect="plain" size="small">{{ t }}</el-tag>
                  <el-popover v-if="row.featureTags.length > 3" placement="bottom" trigger="hover" width="260">
                    <div class="tag-popover"><el-tag v-for="t in row.featureTags" :key="t" effect="plain" size="small">{{ t }}</el-tag></div>
                    <template #reference><el-tag effect="plain" size="small" class="more-tag">+{{ row.featureTags.length - 3 }}</el-tag></template>
                  </el-popover>
                </div>
                <div v-if="row.status === 'REJECTED' && row.lastRejectComment" class="name-cell__hint">驳回：{{ row.lastRejectComment }}</div>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="类型" width="100">
            <template #default="{ row }"><el-tag effect="plain">{{ productTypeLabel(row.type) }}</el-tag></template>
          </el-table-column>
          <el-table-column label="风险" width="80">
            <template #default="{ row }">{{ row.riskLevel }}</template>
          </el-table-column>
          <el-table-column label="状态" width="100">
            <template #default="{ row }"><StatusTag kind="product" :value="row.status" /></template>
          </el-table-column>
          <el-table-column label="操作" min-width="320" fixed="right">
            <template #default="{ row }">
              <div class="action-column">
                <el-button link type="primary" class="action-link--primary" @click="handlePrimaryAction(row)">
                  {{ row.status === 'DRAFT' || row.status === 'REJECTED' ? '编辑' : '查看' }}
                </el-button>
                <el-button v-if="row.status === 'DRAFT' || row.status === 'REJECTED'" link @click="handleSubmit(row)">提交审核</el-button>
                <el-button v-if="row.status === 'PENDING_REVIEW'" link @click="handleWithdraw(row)">撤回</el-button>
                <el-button v-if="row.status === 'PUBLISHED'" link @click="router.push(`/admin/products/${row.id}/edit?newVersion=1`)">新版本</el-button>
                <el-button v-if="row.status === 'PUBLISHED'" link type="danger" @click="handleOffline(row)">下架</el-button>
                <el-dropdown trigger="click" size="small">
                  <el-button link type="info">更多<el-icon><arrow-down /></el-icon></el-button>
                  <template #dropdown>
                    <el-dropdown-menu>
                      <el-dropdown-item @click="handleCopy(row)">复制产品</el-dropdown-item>
                      <el-dropdown-item @click="openReviews(row)">审核记录</el-dropdown-item>
                      <el-dropdown-item @click="openFlowLogs(row)">操作日志</el-dropdown-item>
                      <el-dropdown-item @click="handleCopyProductId(row.id)">复制 ID</el-dropdown-item>
                      <el-dropdown-item v-if="row.status === 'REJECTED' && row.lastRejectComment"
                        @click="ElMessageBox.alert(row.lastRejectComment, '驳回意见')">驳回意见</el-dropdown-item>
                      <el-dropdown-item v-if="row.status === 'DRAFT' || row.status === 'REJECTED' || row.status === 'OFFLINE'"
                        divided @click="handleDelete(row)" style="color:var(--color-danger)">删除</el-dropdown-item>
                    </el-dropdown-menu>
                  </template>
                </el-dropdown>
              </div>
            </template>
          </el-table-column>
        </el-table>

        <div class="pagination-bar">
          <el-pagination background layout="total, sizes, prev, pager, next"
            :current-page="pager.pageNum" :page-size="pager.pageSize" :page-sizes="[10, 20, 50]" :total="pager.total"
            @current-change="(p: number) => { pager.pageNum = p; loadProductList() }"
            @size-change="(s: number) => { pager.pageSize = s; pager.pageNum = 1; loadProductList() }" />
        </div>
      </el-card>

      <!-- 操作日志 -->
      <el-dialog v-model="flowLogDialogVisible" title="操作日志" width="640px">
        <div v-loading="flowLoading">
          <el-empty v-if="!flowLogs.length" description="暂无操作日志" />
          <el-timeline v-else>
            <el-timeline-item v-for="(log, i) in flowLogs" :key="i" :timestamp="log.createdAt">
              <div>{{ flowActionTypeLabel(log.actionType) }}{{ log.comment ? ' - ' + log.comment : '' }}</div>
            </el-timeline-item>
          </el-timeline>
        </div>
      </el-dialog>

      <!-- 审核记录 -->
      <el-dialog v-model="reviewDialogVisible" :title="reviewTarget ? `审核记录 - ${reviewTarget.name}` : '审核记录'" width="760px">
        <div v-loading="reviewLoading">
          <el-empty v-if="!reviewRecords.length" description="暂无审核记录" />
          <el-timeline v-else>
            <el-timeline-item v-for="(item, i) in reviewRecords" :key="i" :timestamp="item.reviewedAt">
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
.workbench-page { display: flex; flex-direction: column; gap: 16px; }
.overview-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 12px; }
.workbench-grid { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 16px; }
@media (max-width: 1200px) { .workbench-grid { grid-template-columns: 1fr 1fr; } }
@media (max-width: 768px) { .workbench-grid { grid-template-columns: 1fr; } .overview-grid { grid-template-columns: repeat(2, 1fr); } }

.task-grid-4 { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; }
.task-card { display: flex; flex-direction: column; gap: 4px; padding: 16px; border: 1px solid var(--color-border); border-radius: 14px;
  background: var(--color-bg-card); cursor: pointer; transition: all .2s; text-align: left; }
.task-card:hover { border-color: var(--color-primary); box-shadow: var(--shadow-soft); }
.task-card--active { border-color: var(--color-primary); background: var(--brand-50); box-shadow: 0 4px 12px rgba(22,59,102,.1); }
.task-card__value { font-size: 28px; font-weight: 800; color: var(--color-text-1); line-height: 1.2; }
.task-card__label { font-size: 14px; font-weight: 600; color: var(--color-text-1); }
.task-card__desc { font-size: 11px; color: var(--color-text-3); line-height: 1.4; }

.empty-hint { padding: 24px; text-align: center; color: var(--color-text-3); font-size: 14px; }

.urgent-list { display: flex; flex-direction: column; gap: 8px; }
.urgent-item { display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 12px 14px;
  border: 1px solid var(--color-border); border-radius: 12px; cursor: pointer; transition: all .2s; }
.urgent-item:hover { border-color: var(--color-primary); box-shadow: var(--shadow-focus); }
.urgent-item__main { flex: 1; min-width: 0; }
.urgent-item__top { display: flex; align-items: center; gap: 8px; margin-bottom: 4px; }
.urgent-item__name { font-weight: 600; font-size: 14px; color: var(--color-text-1); }
.urgent-item__meta { font-size: 12px; color: var(--color-text-2); }

.rank-list { display: flex; flex-direction: column; gap: 6px; }
.rank-item { display: flex; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 10px; cursor: pointer; transition: background .2s; }
.rank-item:hover { background: var(--color-bg-muted); }
.rank-item__pos { width: 24px; height: 24px; border-radius: 50%; background: var(--brand-100); color: var(--brand-600);
  font-weight: 700; font-size: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.rank-item__body { flex: 1; min-width: 0; }
.rank-item__name { font-weight: 600; font-size: 13px; color: var(--color-text-1); }
.rank-item__meta { font-size: 11px; color: var(--color-text-3); }
.rank-item__stats { text-align: right; flex-shrink: 0; }
.rank-item__subs { font-weight: 600; font-size: 13px; color: var(--color-primary); }
.rank-item__nav { font-size: 11px; color: var(--color-text-3); }

.filter-section :deep(.el-card__body) { padding: 12px 20px; }
.quick-row { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 10px; }
.filter-row { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }

.table-title { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
.table-title__main { font-size: 16px; font-weight: 700; }
.table-title__meta { margin-top: 2px; font-size: 12px; color: var(--color-text-3); }
.table-card { border-radius: var(--radius-card); box-shadow: var(--shadow-soft); }

.batch-bar { display: flex; align-items: center; justify-content: space-between; gap: 16px; margin-bottom: 16px;
  padding: 12px 16px; border: 1px solid var(--color-primary); border-radius: 12px; background: linear-gradient(180deg,#f0f5ff,#fff); }
.batch-bar__summary { font-weight: 700; font-size: 14px; }
.batch-bar__actions { display: flex; gap: 8px; }

.name-cell { display: flex; flex-direction: column; gap: 6px; }
.name-cell__top { display: flex; align-items: flex-start; justify-content: space-between; gap: 8px; }
.name-cell__name { font-weight: 700; color: var(--color-text-1); }
.name-cell__meta { display: flex; flex-wrap: wrap; gap: 8px; font-size: 12px; color: var(--color-text-2); }
.name-cell__tags { display: flex; flex-wrap: wrap; gap: 4px; align-items: center; }
.tag-popover { display: flex; flex-wrap: wrap; gap: 4px; }
.more-tag { cursor: pointer; }
.name-cell__hint { font-size: 12px; color: var(--color-danger); }

.action-column { display: flex; align-items: center; gap: 6px; }
.action-link--primary { font-weight: 700; }
.pagination-bar { margin-top: 16px; display: flex; justify-content: flex-end; }
.review-title { margin-bottom: 4px; font-weight: 600; }
.review-comment { font-size: 13px; color: var(--color-text-2); }
</style>
