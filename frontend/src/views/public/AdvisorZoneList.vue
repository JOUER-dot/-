<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'

import PageContainer from '@/components/ui/PageContainer.vue'
import SkeletonLoader from '@/components/common/SkeletonLoader.vue'
import { getPublishedProductList, getAdvisorList, type PublicProductListItem, type PublicAdvisorOption } from '@/api/public-product'
import { getMySubscriptions } from '@/api/subscription'
import { useUserStore } from '@/stores/user'
import { formatPercent, formatText } from '@/utils/format'
import { loadPersisted, savePersisted } from '@/utils/persist'
import { productTypeLabel } from '@/utils/status'

const router = useRouter()
const userStore = useUserStore()

const loading = ref(false)
const records = ref<PublicProductListItem[]>([])
const advisors = ref<PublicAdvisorOption[]>([])
const activeTypeTab = ref('')
const activeAdvisorId = ref<number | null>(null)
const sortBy = ref('recommend')
const filterSub = ref('all')
const compareMode = ref(false)
const compareIds = ref<Set<number>>(new Set())
const subscribedIds = ref<Set<number>>(new Set())

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
  let list = [...records.value]
  // Subscribed products first
  if (userStore.isLoggedIn) {
    list.sort((a, b) => {
      const aSub = subscribedIds.value.has(a.id) ? 0 : 1
      const bSub = subscribedIds.value.has(b.id) ? 0 : 1
      return aSub - bSub
    })
  }
  if (filterSub.value === 'unsubscribed') {
    list = list.filter((item) => !subscribedIds.value.has(item.id))
  }
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

const toggleCompare = (id: number) => {
  const s = new Set(compareIds.value)
  if (s.has(id)) s.delete(id); else s.add(id)
  compareIds.value = s
}

const goCompare = () => {
  const ids = Array.from(compareIds.value).join(',')
  router.push(`/advisor-zone/compare?ids=${ids}`)
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
  // Load subscribed product IDs
  if (userStore.isLoggedIn) {
    try {
      const subData = await getMySubscriptions({ pageNum: 1, pageSize: 999 })
      subscribedIds.value = new Set(subData.records.filter(s => s.status === 'ACTIVE').map(s => s.productId))
    } catch { /* ignore */ }
  }
  await Promise.all([getAdvisorList().then(d => advisors.value = d).catch(() => {}), loadData()])
})

watch(() => ({ query: { ...queryForm }, pageSize: pager.pageSize }), (v) => savePersisted(storageKey, v), { deep: true })
</script>

<template>
  <PageContainer>
    <div class="product-zone">
      <!-- 顶部栏 -->
      <div class="page-header-bar">
        <div class="ph-left">
          <el-button v-if="userStore.isLoggedIn" link class="ph-back" @click="router.push('/my/dashboard')">← 返回</el-button>
          <h1 class="ph-title">产品中心</h1>
        </div>
        <div class="ph-right">
          <el-input v-model="queryForm.keyword" clearable placeholder="搜索产品名称或策略编码..." class="ph-search" @keyup.enter="handleSearch">
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
          <el-button v-if="compareMode" size="small" type="warning" @click="compareMode = false; compareIds = new Set()">取消对比</el-button>
          <el-button v-else size="small" type="default" @click="compareMode = true">对比</el-button>
          <el-button v-if="userStore.isLoggedIn" size="small" :type="filterSub === 'unsubscribed' ? 'primary' : 'default'" @click="filterSub = filterSub === 'unsubscribed' ? 'all' : 'unsubscribed'">
            {{ filterSub === 'unsubscribed' ? '全部' : '未订阅' }}
          </el-button>
          <el-button size="small" type="primary" @click="handleSearch">查询</el-button>
          <el-button size="small" @click="handleReset">重置</el-button>
          <span class="filter-count">共 {{ pager.total }} 个产品</span>
        </div>
      </div>

      <!-- 产品列表 -->
      <SkeletonLoader v-if="loading && records.length === 0" type="card" :rows="6" />
      <div v-else class="product-grid">
        <el-empty v-if="!loading && records.length === 0" description="暂无产品" />
        <div v-for="item in sortedRecords" :key="item.id" class="product-card" :class="{ 'compare-active': compareIds.has(item.id) }" @click="compareMode ? toggleCompare(item.id) : router.push(`/advisor-zone/${item.id}`)">
          <div v-if="compareMode" class="card-check" @click.stop="toggleCompare(item.id)">
            <span class="check-box" :class="{ checked: compareIds.has(item.id) }">
              <svg v-if="compareIds.has(item.id)" width="10" height="10" viewBox="0 0 10 10" fill="none"><path d="M2 5L4 7L8 3" stroke="#fff" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
            </span>
          </div>
          <div v-if="subscribedIds.has(item.id)" class="card-sub-badge">已订阅</div>
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

      <!-- 对比操作栏 -->
      <div v-if="compareMode && compareIds.size >= 2" class="compare-bar">
        <span>已选 {{ compareIds.size }} 个产品</span>
        <el-button type="primary" size="small" @click="goCompare">开始对比</el-button>
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
  display: flex; flex-direction: column; gap: 8px;
  padding: 24px; border-radius: var(--radius-card);
  border: 1px solid var(--color-border);
  background: radial-gradient(640px 180px at 18% 18%, rgba(22,59,102,.1), transparent 60%),
              linear-gradient(180deg, var(--color-bg-card) 0%, #f8fafc 100%);
  box-shadow: var(--shadow-soft);
}
.zone-hero__top { display: flex; }
.back-top { font-size: 12px; color: var(--color-text-3); padding: 0; }
.back-top:hover { color: var(--color-text-1); }
.zone-hero__content { display: flex; align-items: center; justify-content: space-between; gap: 20px; }
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

.product-card.compare-active { border-color: var(--color-primary); background: var(--brand-50); }
.card-check { position: absolute; top: 12px; left: 12px; z-index: 2; }
.check-box { display: flex; align-items: center; justify-content: center; width: 20px; height: 20px; border-radius: 4px; border: 2px solid var(--color-border-strong); background: #fff; cursor: pointer; transition: all .2s; }
.check-box.checked { background: var(--color-primary); border-color: var(--color-primary); }
.compare-bar { display: flex; align-items: center; justify-content: space-between; padding: 12px 20px; background: linear-gradient(135deg, var(--brand-50), var(--color-bg-card)); border: 1px solid var(--color-primary); border-radius: 12px; font-size: 14px; font-weight: 600; color: var(--color-text-1); }

.card-sub-badge {
  position: absolute; top: 12px; right: 12px; z-index: 2;
  background: var(--success-600); color: #fff; font-size: 10px; font-weight: 700;
  padding: 2px 8px; border-radius: 8px; letter-spacing: 0.5px;
}

.product-card { position: relative; }

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
