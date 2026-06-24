<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'

import PageHeader from '@/components/common/PageHeader.vue'
import { getPublishedProductList, type PublicProductListItem } from '@/api/public-product'
import { formatDecimal, formatPercent, formatText } from '@/utils/format'
import { loadPersisted, savePersisted } from '@/utils/persist'
import { productTypeLabel, productTypeOptions } from '@/utils/status'

const router = useRouter()

const loading = ref(false)
const records = ref<PublicProductListItem[]>([])

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

const storageKey = 'roboadvisor:public-zone:query'

const typeOptions = productTypeOptions()
const riskOptions = ['R1', 'R2', 'R3', 'R4', 'R5']

const quickTypeOptions = computed(() => [{ label: '全部', value: '' }, ...typeOptions])

const summaryCards = computed(() => {
  const productCount = records.value.length
  const highRiskCount = records.value.filter((item) => ['R4', 'R5'].includes(item.riskLevel)).length
  const navCount = records.value.filter((item) => item.latestNav !== undefined && item.latestNav !== null).length
  return [
    {
      label: '当前页产品数',
      value: String(productCount),
      hint: '仅展示已上架产品'
    },
    {
      label: '高风险产品数',
      value: String(highRiskCount),
      hint: '风险等级为 R4 / R5'
    },
    {
      label: '有净值数据产品',
      value: String(navCount),
      hint: '可查看收益曲线与净值表现'
    }
  ]
})

const loadData = async () => {
  loading.value = true
  try {
    const data = await getPublishedProductList({
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
    <PageHeader title="基金投顾产品专区" description="专区仅展示已上架产品，详情基于已发布版本数据。">
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

    <div v-loading="loading">
      <el-empty v-if="records.length === 0" description="暂无符合条件的已上架产品" />
      <el-row v-else :gutter="16">
        <el-col v-for="item in records" :key="item.id" :xs="24" :sm="12" :lg="8">
          <el-card shadow="hover" class="product-card" @click="router.push(`/advisor-zone/${item.id}`)">
            <div class="product-card__top">
              <div class="product-card__head">
                <h3>{{ item.name }}</h3>
                <p>面向已发布版本的公开展示与订阅入口</p>
              </div>
              <div class="product-card__tags">
                <el-tag effect="dark">{{ item.riskLevel }}</el-tag>
                <el-tag effect="plain">{{ productTypeLabel(item.type) }}</el-tag>
              </div>
            </div>

            <div class="product-meta">
              <div class="meta-item">
                <span class="meta-label">策略编码</span>
                <strong>{{ formatText(item.strategyCode) }}</strong>
              </div>
              <div class="meta-item">
                <span class="meta-label">产品定位</span>
                <strong>{{ item.riskLevel }} / {{ productTypeLabel(item.type) }}</strong>
              </div>
            </div>

            <div class="tag-list">
              <el-tag v-for="tag in item.featureTags" :key="tag" effect="plain" size="small">
                {{ tag }}
              </el-tag>
              <span v-if="item.featureTags.length === 0" class="empty-text">暂无标签</span>
            </div>

            <div class="nav-summary">
              <div class="nav-block">
                <span class="nav-label">最新净值</span>
                <strong>{{ formatDecimal(item.latestNav) }}</strong>
                <span class="nav-hint">用于展示最近一期组合净值</span>
              </div>
              <div class="nav-block">
                <span class="nav-label">累计收益</span>
                <strong>{{ formatPercent(item.latestCumReturn) }}</strong>
                <span class="nav-hint">基于产品净值序列计算</span>
              </div>
            </div>

            <div class="product-card__footer">
              <span class="footer-tip">支持查看收益、持仓和订阅信息</span>
              <el-button type="primary" link @click.stop="router.push(`/advisor-zone/${item.id}`)">
                查看详情
              </el-button>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <el-card shadow="never" class="pager-card">
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

.search-card,
.pager-card {
  margin-bottom: 16px;
}

.product-card {
  margin-bottom: 16px;
  cursor: pointer;
  border-radius: 18px;
}

.product-card__top {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 12px;
}

.product-card__head h3 {
  margin: 0;
  font-size: 20px;
  color: #111827;
}

.product-card__head h3 {
  margin: 0;
}

.product-card__head p {
  margin: 8px 0 0;
  color: #6b7280;
  line-height: 20px;
}

.product-card__tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.product-meta {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 12px;
  margin-bottom: 12px;
}

.meta-item {
  padding: 12px;
  background: #f8fafc;
  border-radius: 12px;
}

.meta-label {
  display: block;
  margin-bottom: 6px;
  color: #6b7280;
  font-size: 12px;
}

.meta-item strong {
  color: #111827;
}

.tag-list {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin-bottom: 16px;
}

.nav-summary {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  margin-bottom: 12px;
}

.nav-block {
  padding: 14px;
  background: linear-gradient(180deg, #eef6ff 0%, #f8fbff 100%);
  border-radius: 14px;
}

.nav-summary strong {
  display: block;
  margin-top: 6px;
  font-size: 18px;
  color: #303133;
}

.nav-label {
  color: #909399;
  font-size: 13px;
}

.nav-hint {
  display: block;
  margin-top: 6px;
  color: #6b7280;
  font-size: 12px;
}

.product-card__footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.footer-tip,
.empty-text {
  color: #6b7280;
  font-size: 13px;
}

.pagination-bar {
  display: flex;
  justify-content: flex-end;
}

@media (max-width: 768px) {
  .product-meta,
  .nav-summary {
    grid-template-columns: 1fr;
  }
}
</style>
