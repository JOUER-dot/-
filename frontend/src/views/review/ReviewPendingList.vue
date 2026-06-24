<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'

import PageHeader from '@/components/common/PageHeader.vue'
import { getPendingReviewList, type ReviewPendingItem } from '@/api/review'
import { formatText } from '@/utils/format'
import { loadPersisted, savePersisted } from '@/utils/persist'
import { productTypeLabel, productTypeOptions } from '@/utils/status'

const router = useRouter()

const loading = ref(false)
const records = ref<ReviewPendingItem[]>([])

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

const summaryCards = computed(() => {
  const total = records.value.length
  const highRiskCount = records.value.filter((item) => ['R4', 'R5'].includes(item.riskLevel)).length
  const strategyCount = records.value.filter((item) => item.type === 'STRATEGY').length
  return [
    { label: '当前页待审数', value: String(total), hint: '待审核员处理的产品版本' },
    { label: '高风险待审数', value: String(highRiskCount), hint: '风险等级为 R4 / R5' },
    { label: '策略组合待审数', value: String(strategyCount), hint: '产品类型为 STRATEGY' }
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
  <div class="app-page">
    <PageHeader title="待审列表" description="审核员在此查看待审产品，并进入审核详情页执行通过或驳回。">
      <template #actions>
        <el-button @click="handleReset">重置筛选</el-button>
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
        <div class="quick-label">产品类型</div>
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
    </el-card>

    <el-card shadow="never" class="search-card">
      <el-form :inline="true" :model="queryForm">
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
    </el-card>

    <el-card shadow="never">
      <el-table v-loading="loading" :data="records" border>
        <el-table-column prop="name" label="产品名称" min-width="180" />
        <el-table-column prop="type" label="产品类型" width="110">
          <template #default="{ row }">
            {{ productTypeLabel(row.type) }}
          </template>
        </el-table-column>
        <el-table-column prop="riskLevel" label="风险等级" width="100" />
        <el-table-column prop="creatorName" label="创建投顾" width="120" />
        <el-table-column prop="versionNo" label="待审版本" width="100">
          <template #default="{ row }">V{{ row.versionNo }}</template>
        </el-table-column>
        <el-table-column prop="submittedAt" label="提交时间" min-width="180" />
        <el-table-column label="策略编码" min-width="140">
          <template #default="{ row }">
            {{ formatText(row.strategyCode) }}
          </template>
        </el-table-column>
        <el-table-column label="标签" min-width="180">
          <template #default="{ row }">
            <el-space wrap>
              <el-tag v-for="tag in row.featureTags" :key="tag" effect="plain">{{ tag }}</el-tag>
            </el-space>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="router.push(`/review/pending/${row.id}`)">
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
    </el-card>
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

.pagination-bar {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}
</style>
