<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'

import PageHeader from '@/components/common/PageHeader.vue'
import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
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
    { label: '待审数', value: String(total), hint: '' },
    { label: '高风险', value: String(highRiskCount), hint: '' },
    { label: '策略组合', value: String(strategyCount), hint: '' }
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
        <el-table v-loading="loading" :data="records" border>
          <el-table-column label="产品" min-width="260">
            <template #default="{ row }">
              <div class="name-cell">
                <div class="name-cell__name">{{ row.name }}</div>
                <div class="name-cell__meta">
                  <span>{{ productTypeLabel(row.type) }}</span>
                  <span>风险 {{ row.riskLevel }}</span>
                  <span>版本 V{{ row.versionNo }}</span>
                  <span>提交 {{ formatText(row.submittedAt) }}</span>
                </div>
                <div v-if="row.featureTags?.length" class="name-cell__tags">
                  <el-tag v-for="tag in row.featureTags" :key="tag" effect="plain" size="small">{{ tag }}</el-tag>
                </div>
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
