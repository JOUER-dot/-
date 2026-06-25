<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'

import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
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
    { label: '当前页产品数', value: String(productCount), hint: '' },
    { label: '高风险产品数', value: String(highRiskCount), hint: '' },
    { label: '有净值数据产品', value: String(navCount), hint: '' }
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
  () => ({ query: { ...queryForm }, pageSize: pager.pageSize }),
  (value) => savePersisted(storageKey, value),
  { deep: true }
)
</script>

<template>
  <PageContainer>
    <div class="hero">
      <div class="hero__left">
        <div class="hero__kicker">产品专区</div>
        <div class="hero__title">只展示已上架版本，浏览无需登录</div>
      </div>
      <div class="hero__right">
        <el-button @click="handleReset">重置筛选</el-button>
      </div>
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

    <SectionCard title="快捷筛选" subtitle="按产品类型快速过滤">
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
    </SectionCard>

    <SectionCard title="筛选条件">
      <el-form :inline="true" :model="queryForm">
        <el-form-item label="关键字">
          <el-input v-model="queryForm.keyword" clearable placeholder="产品名称或策略编码" @keyup.enter="handleSearch" />
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

    <div v-loading="loading" class="list-wrap">
      <el-empty v-if="records.length === 0" description="暂无产品" />
      <el-row v-else :gutter="16">
        <el-col v-for="item in records" :key="item.id" :xs="24" :sm="12" :lg="8">
          <el-card shadow="hover" class="product-card" @click="router.push(`/advisor-zone/${item.id}`)">
            <div class="product-card__top">
              <div class="product-card__head">
                <h3>{{ item.name }}</h3>
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
              <span v-if="item.featureTags.length === 0" class="muted-text">暂无标签</span>
            </div>

            <div class="nav-summary">
              <div class="nav-block">
                <span class="nav-label">最新净值</span>
                <strong>{{ formatDecimal(item.latestNav) }}</strong>
              </div>
              <div class="nav-block nav-block--positive">
                <span class="nav-label">累计收益</span>
                <strong>{{ formatPercent(item.latestCumReturn) }}</strong>
              </div>
            </div>

            <div class="product-card__footer">
              <span class="muted-text">{{ item.strategyCode ? formatText(item.strategyCode) : '' }}</span>
              <el-button type="primary" link @click.stop="router.push(`/advisor-zone/${item.id}`)">查看详情</el-button>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <SectionCard>
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
  </PageContainer>
</template>

<style scoped>
.hero {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  padding: 18px;
  border-radius: var(--radius-card);
  border: 1px solid var(--color-border);
  background:
    radial-gradient(680px 220px at 20% 20%, rgba(22, 59, 102, 0.12), transparent 60%),
    radial-gradient(520px 240px at 90% 10%, rgba(15, 157, 138, 0.09), transparent 56%),
    linear-gradient(180deg, var(--color-bg-card) 0%, #f8fafc 100%);
  margin-bottom: 16px;
}

.hero__kicker {
  font-size: 12px;
  letter-spacing: 0.4px;
  color: var(--color-text-2);
}

.hero__title {
  margin-top: 10px;
  font-size: 24px;
  line-height: 32px;
  font-weight: 900;
  color: var(--color-text-1);
}

.stat-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
  margin-bottom: 16px;
}

.quick-row {
  display: flex;
  align-items: center;
  gap: 12px;
}

.quick-label {
  font-weight: 700;
  color: var(--color-text-1);
  white-space: nowrap;
}

.list-wrap {
  margin: 16px 0;
}

.product-card {
  margin-bottom: 16px;
  cursor: pointer;
  border-radius: var(--radius-card);
  border: 1px solid var(--color-border);
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
  font-size: 18px;
  color: var(--color-text-1);
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
  border: 1px solid rgba(15, 23, 42, 0.06);
  border-radius: 12px;
}

.meta-label {
  display: block;
  margin-bottom: 6px;
  color: var(--color-text-2);
  font-size: 12px;
}

.meta-item strong {
  color: var(--color-text-1);
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
  border-radius: 14px;
  border: 1px solid rgba(22, 59, 102, 0.12);
  background: linear-gradient(180deg, rgba(22, 59, 102, 0.08) 0%, rgba(255, 255, 255, 0.9) 100%);
}

.nav-block--positive {
  border-color: rgba(15, 157, 138, 0.16);
  background: linear-gradient(180deg, rgba(15, 157, 138, 0.1) 0%, rgba(255, 255, 255, 0.92) 100%);
}

.nav-label {
  color: var(--color-text-2);
  font-size: 13px;
}

.nav-summary strong {
  display: block;
  margin-top: 6px;
  font-size: 18px;
  color: var(--color-text-1);
}

.product-card__footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
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
