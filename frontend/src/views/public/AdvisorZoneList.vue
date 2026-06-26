<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'

import PageContainer from '@/components/ui/PageContainer.vue'
import SkeletonLoader from '@/components/common/SkeletonLoader.vue'
import { getPublishedProductList, getAdvisorList, type PublicProductListItem, type PublicAdvisorOption } from '@/api/public-product'
import { formatPercent, formatText } from '@/utils/format'
import { loadPersisted, savePersisted } from '@/utils/persist'
import { productTypeLabel } from '@/utils/status'

const router = useRouter()

const loading = ref(false)
const records = ref<PublicProductListItem[]>([])
const advisors = ref<PublicAdvisorOption[]>([])
const activeTypeTab = ref('')
const activeAdvisorId = ref<number | null>(null)
const sortBy = ref('recommend')

const queryForm = reactive({ keyword: '', type: '', riskLevel: '', creatorId: undefined as number | undefined, fundCompany: '' })
const pager = reactive({ pageNum: 1, pageSize: 12, total: 0 })
const storageKey = 'roboadvisor:public-zone:query'

const typeOptions = [
  { label: '全部产品', value: '' },
  { label: '策略组合', value: 'STRATEGY' },
  { label: 'FOF组合', value: 'FOF' }
]
const riskOptions = ['R1', 'R2', 'R3', 'R4', 'R5']
const sortOptions = [
  { label: '推荐排序', value: 'recommend' },
  { label: '风险从低到高', value: 'risk_asc' },
  { label: '风险从高到低', value: 'risk_desc' }
]

const advisorOptions = computed(() => {
  return [{ id: 0, name: '全部投顾' } as PublicAdvisorOption, ...advisors.value]
})

const sortedRecords = computed(() => {
  const list = [...records.value]
  if (sortBy.value === 'risk_asc') list.sort((a, b) => a.riskLevel.localeCompare(b.riskLevel))
  else if (sortBy.value === 'risk_desc') list.sort((a, b) => b.riskLevel.localeCompare(a.riskLevel))
  return list
})

const handleTypeTabChange = (type: string) => {
  activeTypeTab.value = type
  queryForm.type = type
  handleSearch()
}

const handleAdvisorChange = (id: number) => {
  activeAdvisorId.value = id
  queryForm.creatorId = id || undefined
  handleSearch()
}

const handleSearch = async () => {
  pager.pageNum = 1
  loading.value = true
  try {
    const data = await getPublishedProductList({
      keyword: queryForm.keyword || undefined,
      type: queryForm.type || undefined,
      riskLevel: queryForm.riskLevel || undefined,
      creatorId: queryForm.creatorId || undefined,
      fundCompany: queryForm.fundCompany || undefined,
      pageNum: pager.pageNum,
      pageSize: pager.pageSize
    })
    records.value = data.records
    pager.total = data.total
  } finally { loading.value = false }
}

const handleReset = async () => {
  queryForm.keyword = ''; queryForm.type = ''; queryForm.riskLevel = ''
  queryForm.creatorId = undefined; queryForm.fundCompany = ''
  activeTypeTab.value = ''; activeAdvisorId.value = null
  pager.pageNum = 1; await loadData()
}

const loadData = async () => {
  loading.value = true
  try {
    const data = await getPublishedProductList({
      keyword: queryForm.keyword || undefined,
      type: queryForm.type || undefined,
      riskLevel: queryForm.riskLevel || undefined,
      creatorId: queryForm.creatorId || undefined,
      fundCompany: queryForm.fundCompany || undefined,
      pageNum: pager.pageNum,
      pageSize: pager.pageSize
    })
    records.value = data.records
    pager.total = data.total
  } finally { loading.value = false }
}

onMounted(async () => {
  const persisted = loadPersisted<{ query: typeof queryForm; pageSize: number }>(storageKey, {
    query: { keyword: '', type: '', riskLevel: '', creatorId: undefined, fundCompany: '' }, pageSize: 12
  })
  Object.assign(queryForm, persisted.query)
  if (queryForm.type) activeTypeTab.value = queryForm.type
  if (queryForm.creatorId) activeAdvisorId.value = queryForm.creatorId
  pager.pageSize = persisted.pageSize || 12
  await Promise.all([getAdvisorList().then(d => advisors.value = d).catch(() => {}), loadData()])
})

watch(() => ({ query: { ...queryForm }, pageSize: pager.pageSize }), (v) => savePersisted(storageKey, v), { deep: true })
</script>

<template>
  <PageContainer>
    <div class="product-zone">
      <!-- Hero -->
      <div class="zone-hero">
        <div class="zone-hero__text">
          <div class="zone-hero__kicker">基金投顾</div>
          <div class="zone-hero__title">产品中心</div>
          <div class="zone-hero__desc">浏览投顾精选产品，查看详情后即可订阅</div>
        </div>
        <div class="zone-hero__search">
          <el-input v-model="queryForm.keyword" clearable placeholder="搜索产品名称或策略编码..." style="width:300px" @keyup.enter="handleSearch">
            <template #prefix><el-icon><search /></el-icon></template>
          </el-input>
        </div>
      </div>

      <!-- 统一工具条 -->
      <div class="zone-toolbar">
        <div class="toolbar-left">
          <el-select v-model="activeTypeTab" size="small" style="width:110px" @change="handleTypeTabChange">
            <el-option v-for="tab in typeOptions" :key="tab.value" :label="tab.label" :value="tab.value" />
          </el-select>
          <el-select v-model="activeAdvisorId" size="small" style="width:120px" placeholder="全部投顾" clearable @change="handleAdvisorChange">
            <el-option v-for="adv in advisors" :key="adv.id" :label="adv.name" :value="adv.id" />
          </el-select>
          <el-select v-model="queryForm.riskLevel" size="small" style="width:105px" clearable placeholder="风险等级">
            <el-option v-for="r in riskOptions" :key="r" :label="r" :value="r" />
          </el-select>
          <el-select v-model="sortBy" size="small" style="width:110px">
            <el-option v-for="opt in sortOptions" :key="opt.value" :label="opt.label" :value="opt.value" />
          </el-select>
        </div>
        <div class="toolbar-right">
          <el-button size="small" type="primary" @click="handleSearch">查询</el-button>
          <el-button size="small" @click="handleReset">重置</el-button>
          <span class="filter-count">共 {{ pager.total }} 个产品</span>
        </div>
      </div>

      <!-- 产品列表 -->
      <SkeletonLoader v-if="loading && records.length === 0" type="card" :rows="6" />
      <div v-else class="product-grid">
        <el-empty v-if="!loading && records.length === 0" description="暂无产品" />
        <div v-for="item in sortedRecords" :key="item.id" class="product-card" @click="router.push(`/advisor-zone/${item.id}`)">
          <div class="card-header">
            <div class="card-title">{{ item.name }}</div>
            <div class="card-badges">
              <span class="badge-risk" :class="`risk-${item.riskLevel.toLowerCase()}`">{{ item.riskLevel }}</span>
              <span class="badge-type">{{ productTypeLabel(item.type) }}</span>
            </div>
          </div>

          <div class="card-meta">
            <div class="card-meta__item">
              <span class="card-meta__label">投顾</span>
              <span class="card-meta__value">{{ formatText(item.creatorName) || '-' }}</span>
            </div>
            <div class="card-meta__item">
              <span class="card-meta__label">策略</span>
              <span class="card-meta__value">{{ formatText(item.strategyCode) || '-' }}</span>
            </div>
            <div class="card-meta__item card-meta__item--highlight">
              <span class="card-meta__label">累计收益</span>
              <span class="card-meta__value" :class="Number(item.latestCumReturn) >= 0 ? 'positive' : 'negative'">
                {{ formatPercent(item.latestCumReturn) }}
              </span>
            </div>
          </div>

          <div class="card-funds" v-if="item.fundCompanies?.length">
            基金公司：<span v-for="(fc, i) in item.fundCompanies" :key="fc">{{ i > 0 ? ' · ' : '' }}{{ fc }}</span>
          </div>

          <div class="card-tags" v-if="item.featureTags?.length">
            <el-tag v-for="tag in item.featureTags.slice(0, 3)" :key="tag" effect="plain" size="small">{{ tag }}</el-tag>
          </div>

          <div class="card-footer">
            <span class="card-footer__hint">点击查看详情 →</span>
          </div>
        </div>
      </div>

      <!-- 分页 -->
      <div class="pagination-bar">
        <el-pagination background layout="total, prev, pager, next"
          :current-page="pager.pageNum" :page-size="pager.pageSize" :total="pager.total"
          @current-change="(p: number) => { pager.pageNum = p; loadData() }" />
      </div>
    </div>
  </PageContainer>
</template>

<style scoped>
.product-zone { display: flex; flex-direction: column; gap: 16px; }

.zone-hero {
  display: flex; align-items: center; justify-content: space-between; gap: 20px;
  padding: 24px; border-radius: var(--radius-card);
  border: 1px solid var(--color-border);
  background: radial-gradient(640px 180px at 18% 18%, rgba(22,59,102,.1), transparent 60%),
              linear-gradient(180deg, var(--color-bg-card) 0%, #f8fafc 100%);
  box-shadow: var(--shadow-soft);
}
.zone-hero__kicker { font-size: 12px; color: var(--color-text-2); letter-spacing: .4px; }
.zone-hero__title { margin-top: 6px; font-size: 26px; font-weight: 900; color: var(--color-text-1); }
.zone-hero__desc { margin-top: 4px; font-size: 13px; color: var(--color-text-2); }

.zone-toolbar {
  display: flex; align-items: center; justify-content: space-between; gap: 12px;
  flex-wrap: wrap;
  padding: 10px 14px;
  border: 1px solid var(--color-border);
  border-radius: 12px;
  background: var(--color-bg-card);
}
.toolbar-left {
  display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
}
.toolbar-right {
  display: flex; align-items: center; gap: 8px;
}
.filter-count { font-size: 12px; color: var(--color-text-3); white-space: nowrap; }

.card-funds {
  font-size: 12px; color: var(--color-text-3);
  padding: 4px 0;
}

.zone-filter {
  display: flex; align-items: center; gap: 8px;
}
.filter-count { margin-left: auto; font-size: 12px; color: var(--color-text-3); }

.product-grid {
  display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 14px;
}

.product-card {
  display: flex; flex-direction: column; gap: 12px;
  padding: 20px; border: 1px solid var(--color-border); border-radius: var(--radius-card);
  background: var(--color-bg-card); cursor: pointer;
  transition: all .25s;
}
.product-card:hover {
  border-color: var(--color-primary); box-shadow: 0 8px 24px rgba(22,59,102,.1);
  transform: translateY(-2px);
}

.card-header { display: flex; align-items: flex-start; justify-content: space-between; gap: 12px; }
.card-title { font-size: 17px; font-weight: 700; color: var(--color-text-1); line-height: 1.3; }
.card-badges { display: flex; gap: 6px; flex-shrink: 0; }
.badge-risk {
  padding: 2px 10px; border-radius: 10px; font-size: 11px; font-weight: 700;
  color: #fff;
}
.badge-risk.risk-r1 { background: #1e9e62; }
.badge-risk.risk-r2 { background: #2f6bde; }
.badge-risk.risk-r3 { background: #d89b2b; }
.badge-risk.risk-r4 { background: #e67e22; }
.badge-risk.risk-r5 { background: #c53b32; }
.badge-type {
  padding: 2px 10px; border-radius: 10px; font-size: 11px;
  border: 1px solid var(--color-border-strong); color: var(--color-text-2);
}

.card-meta { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px; }
.card-meta__item {
  padding: 10px; border-radius: 10px; background: var(--color-bg-muted);
  display: flex; flex-direction: column; gap: 4px;
}
.card-meta__item--highlight { background: var(--brand-50); }
.card-meta__label { font-size: 11px; color: var(--color-text-3); }
.card-meta__value { font-size: 14px; font-weight: 700; color: var(--color-text-1); }
.card-meta__value.positive { color: var(--success-600); }
.card-meta__value.negative { color: var(--danger-600); }

.card-tags { display: flex; flex-wrap: wrap; gap: 4px; }

.card-footer { display: flex; justify-content: flex-end; }
.card-footer__hint { font-size: 12px; color: var(--color-text-3); }

.pagination-bar { display: flex; justify-content: center; margin-top: 8px; }

@media (max-width: 768px) {
  .zone-hero { flex-direction: column; align-items: stretch; }
  .zone-hero__search :deep(.el-input) { width: 100% !important; }
  .zone-toolbar { flex-direction: column; align-items: stretch; }
  .product-grid { grid-template-columns: 1fr; }
  .card-meta { grid-template-columns: 1fr; }
}
</style>
