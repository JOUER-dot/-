<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import PageHeader from '@/components/common/PageHeader.vue'
import {
  getProductList,
  getProductReviews,
  offlineProduct,
  submitProduct,
  withdrawProduct,
  type ProductListItem,
  type ReviewRecord
} from '@/api/product'
import { copyToClipboard } from '@/utils/clipboard'
import { formatText } from '@/utils/format'
import { loadPersisted, savePersisted } from '@/utils/persist'
import { productStatusLabel, productStatusTagType, productTypeLabel, reviewResultLabel } from '@/utils/status'

const router = useRouter()

const loading = ref(false)
const reviewLoading = ref(false)
const reviewDialogVisible = ref(false)
const reviewRecords = ref<ReviewRecord[]>([])
const reviewTarget = ref<ProductListItem | null>(null)

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

const summaryCards = computed(() => {
  const total = pager.total
  const current = records.value
  const countOf = (status: ProductListItem['status']) => current.filter((item) => item.status === status).length
  const draft = countOf('DRAFT')
  const pending = countOf('PENDING_REVIEW')
  const rejected = countOf('REJECTED')
  const published = countOf('PUBLISHED')
  const offline = countOf('OFFLINE')

  return [
    { label: '查询结果总数', value: String(total), hint: '符合筛选条件的产品总数' },
    { label: '当前页草稿', value: String(draft), hint: '可编辑并提交审核' },
    { label: '当前页待审核', value: String(pending), hint: '可撤回或查看详情' },
    { label: '当前页已上架', value: String(published), hint: '可下架或查看详情' },
    { label: '当前页已驳回/已下架', value: `${rejected}/${offline}`, hint: '驳回可继续编辑，下架仅查看' }
  ]
})

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

const handleCopyProductId = async (productId: number) => {
  const ok = await copyToClipboard(String(productId))
  if (!ok) {
    ElMessage.error('复制失败')
    return
  }
  ElMessage.success('已复制产品ID')
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
  <div class="app-page">
    <PageHeader
      title="组合产品管理"
      description="投顾仅可查看和操作自己创建的产品，草稿编辑、提交审核和撤回审核都从这里进入。"
    >
      <template #actions>
        <el-button type="primary" @click="router.push('/admin/products/create')">创建产品</el-button>
      </template>
    </PageHeader>

    <div class="summary-grid">
      <div v-for="item in summaryCards" :key="item.label" class="summary-card">
        <div class="summary-card__label">{{ item.label }}</div>
        <div class="summary-card__value">{{ item.value }}</div>
        <div class="summary-card__hint">{{ item.hint }}</div>
      </div>
    </div>

    <el-card shadow="never" class="quick-card">
      <div class="quick-row">
        <div class="quick-label">快捷筛选</div>
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
    </el-card>

    <el-card shadow="never" class="search-card">
      <el-form :inline="true" :model="queryForm">
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
    </el-card>

    <el-card shadow="never" class="section-card">
      <template #header>
        <div class="table-title">
          <div>
            <div class="table-title__main">产品列表</div>
            <div class="table-title__sub">点击“编辑草稿/查看详情”进入产品详情页</div>
          </div>
          <el-button @click="handleReset">重置筛选</el-button>
        </div>
      </template>

      <el-empty v-if="!loading && records.length === 0" description="暂无符合条件的产品" />
      <el-table v-else v-loading="loading" :data="records" border>
        <el-table-column label="产品" min-width="260">
          <template #default="{ row }">
            <div class="name-cell">
              <div class="name-cell__top">
                <div class="name-cell__name">{{ row.name }}</div>
                <el-tag :type="productStatusTagType(row.status)">{{ productStatusLabel(row.status) }}</el-tag>
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
            <el-tag :type="productStatusTagType(row.status)">{{ productStatusLabel(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" min-width="320" fixed="right">
          <template #default="{ row }">
            <el-space wrap class="action-space">
              <el-button plain @click="handleCopyProductId(row.id)">复制ID</el-button>
              <el-button
                v-if="row.status === 'DRAFT' || row.status === 'REJECTED'"
                type="primary"
                plain
                @click="router.push(`/admin/products/${row.id}/edit`)"
              >
                编辑草稿
              </el-button>
              <el-button
                v-if="row.status === 'DRAFT' || row.status === 'REJECTED'"
                type="success"
                plain
                @click="handleSubmit(row)"
              >
                提交审核
              </el-button>
              <el-button
                v-if="row.status === 'PENDING_REVIEW' || row.status === 'PUBLISHED' || row.status === 'OFFLINE'"
                plain
                @click="router.push(`/admin/products/${row.id}`)"
              >
                查看详情
              </el-button>
              <el-button
                v-if="row.status === 'PENDING_REVIEW'"
                type="warning"
                plain
                @click="handleWithdraw(row)"
              >
                撤回审核
              </el-button>
              <el-button
                v-if="row.status === 'PUBLISHED'"
                type="danger"
                plain
                @click="handleOffline(row)"
              >
                下架
              </el-button>
              <el-button plain @click="openReviews(row)">审核记录</el-button>
              <el-button
                v-if="row.status === 'REJECTED' && row.lastRejectComment"
                type="danger"
                plain
                @click="ElMessageBox.alert(row.lastRejectComment, '驳回意见')"
              >
                驳回意见
              </el-button>
            </el-space>
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
</template>

<style scoped>
.quick-card {
  margin-bottom: 16px;
  border-radius: 18px;
}

.quick-row {
  display: flex;
  align-items: center;
  gap: 12px;
}

.quick-label {
  font-weight: 600;
  color: #111827;
  white-space: nowrap;
}

.search-card {
  margin-bottom: 16px;
}

.table-title {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
}

.table-title__main {
  font-weight: 700;
  color: #111827;
}

.table-title__sub {
  margin-top: 6px;
  color: #6b7280;
  font-size: 12px;
  line-height: 18px;
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
  color: #111827;
  line-height: 20px;
}

.name-cell__meta {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  color: #6b7280;
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
  color: #b91c1c;
  font-size: 12px;
  line-height: 18px;
}

.muted {
  color: #6b7280;
  font-size: 12px;
}

.action-space :deep(.el-button) {
  margin: 0;
}

.pagination-bar {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}

.review-title {
  margin-bottom: 6px;
  font-weight: 600;
  color: #303133;
}

.review-comment {
  color: #606266;
  line-height: 1.7;
}
</style>
