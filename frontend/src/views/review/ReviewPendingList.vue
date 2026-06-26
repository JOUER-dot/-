<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import PageHeader from '@/components/common/PageHeader.vue'
import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
import { getPendingReviewList, batchApproveReviews, batchRejectReviews, type ReviewPendingItem } from '@/api/review'
import { formatText } from '@/utils/format'
import { loadPersisted, savePersisted } from '@/utils/persist'
import { productTypeLabel, productTypeOptions } from '@/utils/status'

const router = useRouter()

const loading = ref(false)
const records = ref<ReviewPendingItem[]>([])
const selectedRows = ref<ReviewPendingItem[]>([])
const rejectDialogVisible = ref(false)
const rejectBatchComment = ref('')

const queryForm = reactive({
  keyword: '',
  type: '',
  riskLevel: ''
})

const pager = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const storageKey = 'roboadvisor:review-pending:query'

const typeOptions = productTypeOptions()
const riskOptions = ['R1', 'R2', 'R3', 'R4', 'R5']

const quickTypeOptions = computed(() => [{ label: '全部', value: '' }, ...typeOptions])

const selectedIds = computed(() => selectedRows.value.map((item) => item.id))
const hasSelection = computed(() => selectedRows.value.length > 0)

const isVersionIteration = (item: ReviewPendingItem) => item.baseVersionNo !== null && item.baseVersionNo !== undefined

const changeTypeTag = (item: ReviewPendingItem) => {
  if (item.changeType === 'MAJOR') {
    return { type: 'danger' as const, label: '重大变更' }
  }
  if (item.changeType === 'NORMAL') {
    return { type: 'info' as const, label: '普通变更' }
  }
  return null
}

const summaryCards = computed(() => {
  const total = records.value.length
  const iterationCount = records.value.filter((item) => isVersionIteration(item)).length
  const majorChangeCount = records.value.filter((item) => item.changeType === 'MAJOR').length
  return [
    { label: '待审数', value: String(total), hint: '' },
    { label: '版本迭代', value: String(iterationCount), hint: '' },
    { label: '重大变更', value: String(majorChangeCount), hint: '' }
  ]
})

const loadData = async () => {
  loading.value = true
  try {
    const data = await getPendingReviewList({
      keyword: queryForm.keyword || undefined,
      type: queryForm.type || undefined,
      riskLevel: queryForm.riskLevel || undefined,
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
  queryForm.keyword = ''
  queryForm.type = ''
  queryForm.riskLevel = ''
  pager.pageNum = 1
  await loadData()
}

const handleQuickType = async (value: string) => {
  queryForm.type = value
  await handleSearch()
}

const handleBatchApprove = async () => {
  if (selectedIds.value.length === 0) {
    ElMessage.warning('请先选择产品')
    return
  }
  try {
    await ElMessageBox.confirm(`确认通过选中的 ${selectedIds.value.length} 个产品吗？`, '批量审核通过', { type: 'warning' })
  } catch {
    return
  }
  try {
    await batchApproveReviews(selectedIds.value)
    ElMessage.success(`已通过 ${selectedIds.value.length} 个产品`)
    await loadData()
  } catch {
    ElMessage.error('批量通过失败')
  }
}

const handleBatchReject = async () => {
  if (selectedIds.value.length === 0) {
    ElMessage.warning('请先选择产品')
    return
  }
  rejectBatchComment.value = ''
  rejectDialogVisible.value = true
}

const confirmBatchReject = async () => {
  if (!rejectBatchComment.value.trim()) {
    ElMessage.warning('请填写驳回意见')
    return
  }
  rejectDialogVisible.value = false
  try {
    await batchRejectReviews(selectedIds.value, { comment: rejectBatchComment.value })
    ElMessage.success(`已驳回 ${selectedIds.value.length} 个产品`)
    await loadData()
  } catch {
    ElMessage.error('批量驳回失败')
  }
}

const handleSelectionChange = (rows: ReviewPendingItem[]) => {
  selectedRows.value = rows
}

onMounted(() => {
  const persisted = loadPersisted<{ query: typeof queryForm; pageSize: number }>(storageKey, {
    query: { keyword: '', type: '', riskLevel: '' },
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
  (value) => savePersisted(storageKey, value),
  { deep: true }
)
</script>

<template>
  <PageContainer>
    <div class="app-page review-workbench">
      <PageHeader title="待审列表" />

      <div class="hero">
        <div>
          <div class="hero__kicker">审核工作台</div>
          <div class="hero__title">待审列表</div>
        </div>
        <el-button @click="handleReset">重置筛选</el-button>
      </div>

      <div class="stat-grid">
        <StatCard
          v-for="item in summaryCards"
          :key="item.label"
          :label="item.label"
          :value="item.value"
          :hint="item.hint"
        />
      </div>

      <SectionCard title="快捷筛选" class="workbench-section">
        <div class="quick-row">
          <el-space wrap>
            <el-button
              v-for="item in quickTypeOptions"
              :key="item.value"
              size="small"
              :type="queryForm.type === item.value ? 'primary' : undefined"
              :plain="queryForm.type !== item.value"
              @click="handleQuickType(item.value)"
            >
              {{ item.label }}
            </el-button>
          </el-space>
        </div>
      </SectionCard>

      <SectionCard title="筛选条件" class="workbench-section">
        <el-form :inline="true" :model="queryForm" class="filter-form">
          <el-form-item label="关键字">
            <el-input
              v-model="queryForm.keyword"
              clearable
              placeholder="产品名称或策略编码"
              @keyup.enter="handleSearch"
            />
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
          <el-form-item>
            <el-button type="primary" @click="handleSearch">查询</el-button>
            <el-button @click="handleReset">重置</el-button>
          </el-form-item>
        </el-form>
      </SectionCard>

      <SectionCard title="待审产品" class="table-section">
        <div v-if="hasSelection" class="batch-bar">
          <div class="batch-bar__summary">已选择 {{ selectedIds.length }} 项</div>
          <div class="batch-bar__actions">
            <el-button type="success" @click="handleBatchApprove">批量通过</el-button>
            <el-button type="danger" plain @click="handleBatchReject">批量驳回</el-button>
          </div>
        </div>

        <el-table v-loading="loading" :data="records" border @selection-change="handleSelectionChange">
          <el-table-column type="selection" width="46" />
          <el-table-column label="产品" min-width="260">
            <template #default="{ row }">
              <div class="name-cell">
                <div class="name-cell__name">{{ row.name }}</div>
                <div class="name-cell__meta">
                  <span>{{ productTypeLabel(row.type) }}</span>
                  <span>风险 {{ row.riskLevel }}</span>
                  <span>版本 V{{ row.versionNo }}</span>
                  <span v-if="isVersionIteration(row)">基线 V{{ row.baseVersionNo }}</span>
                  <span>提交 {{ formatText(row.submittedAt) }}</span>
                </div>
                <div v-if="row.featureTags?.length || isVersionIteration(row) || changeTypeTag(row)" class="name-cell__tags">
                  <el-tag v-if="isVersionIteration(row)" effect="plain" size="small">版本迭代</el-tag>
                  <el-tag v-if="changeTypeTag(row)" :type="changeTypeTag(row)?.type" effect="plain" size="small">
                    {{ changeTypeTag(row)?.label }}
                  </el-tag>
                  <el-tag v-for="tag in row.featureTags" :key="tag" effect="plain" size="small">{{ tag }}</el-tag>
                </div>
                <div v-if="row.versionNote" class="name-cell__note">版本摘要：{{ row.versionNote }}</div>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="creatorName" label="创建人" width="120" />
          <el-table-column label="策略编码" min-width="140">
            <template #default="{ row }">
              {{ formatText(row.strategyCode) }}
            </template>
          </el-table-column>
          <el-table-column prop="submittedAt" label="提交时间" min-width="180">
            <template #default="{ row }">
              {{ formatText(row.submittedAt) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="120" fixed="right">
            <template #default="{ row }">
              <el-button link type="primary" class="action-link" @click="router.push(`/review/pending/${row.id}`)">
                去审核
              </el-button>
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
      </SectionCard>

      <el-dialog v-model="rejectDialogVisible" title="批量驳回" width="480px">
        <el-form>
          <el-form-item label="驳回意见">
            <el-input
              v-model="rejectBatchComment"
              type="textarea"
              :rows="4"
              placeholder="请输入统一的驳回意见，将应用到所有选中的产品"
            />
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="rejectDialogVisible = false">取消</el-button>
          <el-button type="danger" @click="confirmBatchReject">确认驳回</el-button>
        </template>
      </el-dialog>
    </div>
  </PageContainer>
</template>

<style scoped>
.review-workbench {
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

.workbench-section,
.table-section {
  border-radius: 18px;
}

.quick-row {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.filter-form {
  margin-bottom: -18px;
}

.batch-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 16px;
  padding: 14px 16px;
  border: 1px solid var(--color-primary);
  border-radius: 14px;
  background: linear-gradient(180deg, #f0f5ff 0%, var(--color-bg-card) 100%);
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

.name-cell__note {
  color: var(--color-text-2);
  font-size: 12px;
  line-height: 18px;
}

.action-link {
  font-weight: 700;
}

.pagination-bar {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}

@media (max-width: 900px) {
  .hero {
    flex-direction: column;
    align-items: stretch;
  }
}
</style>
