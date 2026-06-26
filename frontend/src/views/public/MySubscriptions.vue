<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import StatusTag from '@/components/ui/StatusTag.vue'
import {
  decideMySubscriptionVersionAction,
  getMySubscriptions,
  type MySubscriptionItem,
  type SubscriptionVersionDecision,
  unsubscribeProduct
} from '@/api/subscription'
import {
  getMySubscriptionsFocusState,
  isAffectedSubscription,
  type MySubscriptionsFocusKey
} from '@/views/public/my-subscriptions-focus'
import { buildMySubscriptionsQueryParams } from '@/views/public/my-subscriptions-query'
import { getMySubscriptionsFilterSummary } from '@/views/public/my-subscriptions-summary'
import { getMySubscriptionVersionActionState } from '@/views/public/my-subscriptions-version-actions'
import { formatDecimal, formatPercent } from '@/utils/format'
import { loadPersisted, savePersisted } from '@/utils/persist'
import { productTypeLabel } from '@/utils/status'

const router = useRouter()
const loading = ref(false)
const records = ref<MySubscriptionItem[]>([])
const total = ref(0)

const storageKey = 'roboadvisor:my-subscriptions:filter'

const filterForm = reactive({
  focusKey: 'all' as MySubscriptionsFocusKey,
  keyword: '',
  productStatus: '',
  subscriptionStatus: '',
  sortBy: 'subscribedAtDesc',
  pageSize: 10
})

const pager = reactive({
  pageNum: 1
})

const versionDecisionLoading = reactive<Record<number, SubscriptionVersionDecision | null>>({})

const focusCards = [
  { key: 'all', label: '全部订阅' },
  { key: 'active', label: '有效订阅' },
  { key: 'cancelled', label: '已取消' },
  { key: 'affected', label: '受影响订阅' }
] as Array<{ key: MySubscriptionsFocusKey; label: string }>

const currentFocus = computed(() => getMySubscriptionsFocusState(filterForm.focusKey))

const hasFilters = computed(
  () =>
    currentFocus.value.hasFilters ||
    Boolean(filterForm.keyword.trim()) ||
    Boolean(filterForm.subscriptionStatus) ||
    Boolean(filterForm.productStatus) ||
    filterForm.sortBy !== 'subscribedAtDesc'
)

const filterSummary = computed(() =>
  getMySubscriptionsFilterSummary({
    keyword: filterForm.keyword,
    productStatus: filterForm.productStatus,
    subscriptionStatus: filterForm.subscriptionStatus,
    sortBy: filterForm.sortBy
  })
)

const sortOptions = [
  { label: '最近订阅', value: 'subscribedAtDesc' },
  { label: '最早订阅', value: 'subscribedAtAsc' },
  { label: '产品名称', value: 'productNameAsc' },
  { label: '产品状态优先', value: 'productStatusFirst' }
]

const emptyDescription = computed(() => {
  if (!hasFilters.value && total.value === 0) {
    return '暂无订阅记录'
  }
  return '当前筛选条件下暂无结果'
})

const getVersionActionState = (row: MySubscriptionItem) => getMySubscriptionVersionActionState(row)

const getVersionActionSummary = (row: MySubscriptionItem) => {
  const state = getVersionActionState(row)
  if (state.summary) {
    return state.summary
  }
  if (state.requiresDecision) {
    return '产品版本发生重大调整，请决定继续订阅或取消订阅。'
  }
  return '产品已有新的版本变更，请查看详情了解最新信息。'
}

const getVersionActionTagType = (row: MySubscriptionItem) =>
  getVersionActionState(row).tone === 'warning' ? 'warning' : 'info'

const isVersionDecisionLoading = (subscriptionId: number, decision?: SubscriptionVersionDecision) => {
  const currentDecision = versionDecisionLoading[subscriptionId]
  return decision ? currentDecision === decision : Boolean(currentDecision)
}

const loadData = async () => {
  loading.value = true
  try {
    const page = await getMySubscriptions(
      buildMySubscriptionsQueryParams({
        focusKey: filterForm.focusKey,
        keyword: filterForm.keyword,
        productStatus: filterForm.productStatus,
        subscriptionStatus: filterForm.subscriptionStatus,
        sortBy: filterForm.sortBy,
        pageNum: pager.pageNum,
        pageSize: filterForm.pageSize
      })
    )
    records.value = page.records
    total.value = page.total
  } finally {
    loading.value = false
  }
}

const handleSearch = async () => {
  pager.pageNum = 1
  await loadData()
}

const handleClearFilters = async () => {
  filterForm.focusKey = 'all'
  filterForm.keyword = ''
  filterForm.productStatus = ''
  filterForm.subscriptionStatus = ''
  filterForm.sortBy = 'subscribedAtDesc'
  pager.pageNum = 1
  await loadData()
}

const handleFocusChange = async (focusKey: MySubscriptionsFocusKey) => {
  filterForm.focusKey = focusKey
  filterForm.subscriptionStatus = ''
  filterForm.productStatus = ''

  if (focusKey === 'affected') {
    filterForm.productStatus = 'OFFLINE'
  }

  pager.pageNum = 1
  await loadData()
}

onMounted(() => {
  const persisted = loadPersisted<typeof filterForm>(storageKey, {
    focusKey: 'all',
    keyword: '',
    productStatus: '',
    subscriptionStatus: '',
    sortBy: 'subscribedAtDesc',
    pageSize: 10
  })
  Object.assign(filterForm, persisted)
  void loadData()
})

watch(
  () => ({ ...filterForm }),
  (value) => savePersisted(storageKey, value),
  { deep: true }
)

const handleUnsubscribe = async (row: MySubscriptionItem) => {
  try {
    await ElMessageBox.confirm('确认取消当前产品的签约订阅吗？', '提示', { type: 'warning' })
  } catch {
    return
  }
  await unsubscribeProduct(row.productId)
  ElMessage.success('取消订阅成功')
  if (records.value.length === 1 && pager.pageNum > 1) {
    pager.pageNum -= 1
  }
  await loadData()
}

const handleVersionDecision = async (row: MySubscriptionItem, decision: SubscriptionVersionDecision) => {
  const isConfirm = decision === 'CONFIRM'
  const confirmMessage = isConfirm
    ? '确认继续订阅并承接该产品的最新版本吗？'
    : '确认取消该产品订阅，并不再承接本次重大版本变更吗？'

  try {
    await ElMessageBox.confirm(confirmMessage, isConfirm ? '继续订阅' : '取消订阅', {
      type: isConfirm ? 'info' : 'warning'
    })
  } catch {
    return
  }

  versionDecisionLoading[row.subscriptionId] = decision
  try {
    await decideMySubscriptionVersionAction(row.subscriptionId, { decision })
    ElMessage.success(isConfirm ? '已确认继续订阅' : '已取消订阅')
    if (!isConfirm && records.value.length === 1 && pager.pageNum > 1) {
      pager.pageNum -= 1
    }
    await loadData()
  } finally {
    versionDecisionLoading[row.subscriptionId] = null
  }
}
</script>

<template>
  <PageContainer>
    <div class="subscription-page">
      <div class="page-header">
        <div>
          <div class="page-header__kicker">订阅管理</div>
          <div class="page-header__title">我的订阅</div>
        </div>
      </div>

      <SectionCard title="订阅焦点">
        <div class="focus-summary" :class="{ 'focus-summary--active': hasFilters }">
          <div>
            <div class="focus-summary__title">{{ currentFocus.title }}</div>
            <div class="focus-summary__subtitle">{{ currentFocus.subtitle }}</div>
          </div>
          <el-button v-if="hasFilters" link type="primary" @click="handleClearFilters">恢复默认</el-button>
        </div>

        <div class="focus-grid">
          <button
            v-for="item in focusCards"
            :key="item.key"
            type="button"
            class="focus-card"
            :class="{ 'focus-card--active': filterForm.focusKey === item.key }"
            @click="handleFocusChange(item.key)"
          >
            {{ item.label }}
          </button>
        </div>
      </SectionCard>

      <SectionCard title="筛选条件">
        <div class="query-summary" :class="{ 'query-summary--active': filterSummary.hasFilters }">
          {{ filterSummary.summary }}
        </div>

        <div class="filter-row">
          <el-input
            v-model="filterForm.keyword"
            clearable
            placeholder="产品名称"
            class="filter-input"
            @keyup.enter="handleSearch"
          />
          <el-select v-model="filterForm.subscriptionStatus" clearable placeholder="订阅状态" class="filter-select">
            <el-option label="已订阅" value="ACTIVE" />
            <el-option label="已取消" value="CANCELLED" />
          </el-select>
          <el-select v-model="filterForm.productStatus" clearable placeholder="产品状态" class="filter-select">
            <el-option label="已上架" value="PUBLISHED" />
            <el-option label="已下架" value="OFFLINE" />
          </el-select>
          <el-select v-model="filterForm.sortBy" placeholder="排序方式" class="filter-select">
            <el-option v-for="item in sortOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleClearFilters">清空</el-button>
        </div>
      </SectionCard>

      <SectionCard title="订阅列表">
        <template #extra>
          <div class="table-meta">共 {{ total }} 条</div>
        </template>

        <el-empty v-if="!loading && records.length === 0" :description="emptyDescription" />
        <el-table v-else v-loading="loading" :data="records" border>
          <el-table-column label="产品名称" min-width="220">
            <template #default="{ row }">
              <div class="name-cell">
                <div class="name-cell__title">
                  <span>{{ row.productName }}</span>
                  <el-tag v-if="isAffectedSubscription(row)" effect="plain" type="danger" size="small">受影响</el-tag>
                </div>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="type" label="产品类型" width="110">
            <template #default="{ row }">
              {{ productTypeLabel(row.type) }}
            </template>
          </el-table-column>
          <el-table-column prop="riskLevel" label="风险等级" width="100" />
          <el-table-column label="产品状态" width="120">
            <template #default="{ row }">
              <StatusTag kind="product" :value="row.productStatus" />
            </template>
          </el-table-column>
          <el-table-column label="订阅状态" width="120">
            <template #default="{ row }">
              <StatusTag kind="subscription" :value="row.status" />
            </template>
          </el-table-column>
          <el-table-column label="版本动作" min-width="260">
            <template #default="{ row }">
              <div v-if="getVersionActionState(row).visible" class="version-action-cell">
                <el-tag :type="getVersionActionTagType(row)" effect="plain" size="small">
                  {{ getVersionActionState(row).actionLabel }}
                </el-tag>
                <div class="version-action-cell__summary">
                  {{ getVersionActionSummary(row) }}
                </div>
              </div>
              <span v-else class="version-action-cell__empty">无待处理版本动作</span>
            </template>
          </el-table-column>
          <el-table-column label="最新净值" width="120">
            <template #default="{ row }">
              {{ formatDecimal(row.latestNav) }}
            </template>
          </el-table-column>
          <el-table-column label="累计收益" width="120">
            <template #default="{ row }">
              {{ formatPercent(row.latestCumReturn) }}
            </template>
          </el-table-column>
          <el-table-column prop="subscribedAt" label="订阅时间" min-width="180" />
          <el-table-column label="操作" width="260" fixed="right">
            <template #default="{ row }">
              <el-space wrap>
                <el-button link type="primary" @click="router.push(`/advisor-zone/${row.productId}`)">查看详情</el-button>
                <template v-if="getVersionActionState(row).requiresDecision">
                  <el-button
                    link
                    type="primary"
                    :loading="isVersionDecisionLoading(row.subscriptionId, 'CONFIRM')"
                    :disabled="
                      isVersionDecisionLoading(row.subscriptionId) &&
                      !isVersionDecisionLoading(row.subscriptionId, 'CONFIRM')
                    "
                    @click="handleVersionDecision(row, 'CONFIRM')"
                  >
                    继续订阅
                  </el-button>
                  <el-button
                    link
                    type="danger"
                    :loading="isVersionDecisionLoading(row.subscriptionId, 'CANCEL')"
                    :disabled="
                      isVersionDecisionLoading(row.subscriptionId) &&
                      !isVersionDecisionLoading(row.subscriptionId, 'CANCEL')
                    "
                    @click="handleVersionDecision(row, 'CANCEL')"
                  >
                    取消订阅
                  </el-button>
                </template>
                <el-button v-else-if="row.status === 'ACTIVE'" link type="danger" @click="handleUnsubscribe(row)">
                  取消订阅
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
            :page-size="filterForm.pageSize"
            :page-sizes="[10, 20, 50]"
            :total="total"
            @current-change="
              async (page: number) => {
                pager.pageNum = page
                await loadData()
              }
            "
            @size-change="
              async (size: number) => {
                filterForm.pageSize = size
                pager.pageNum = 1
                await loadData()
              }
            "
          />
        </div>
      </SectionCard>
    </div>
  </PageContainer>
</template>

<style scoped>
.subscription-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.page-header {
  padding: 18px;
  border-radius: var(--radius-card);
  border: 1px solid var(--color-border);
  background:
    radial-gradient(640px 220px at 18% 18%, rgba(22, 59, 102, 0.12), transparent 60%),
    linear-gradient(180deg, var(--color-bg-card) 0%, #f8fafc 100%);
}

.page-header__kicker {
  color: var(--color-text-2);
  font-size: 12px;
}

.page-header__title {
  margin-top: 10px;
  font-size: 26px;
  line-height: 34px;
  font-weight: 900;
  color: var(--color-text-1);
}

.focus-summary {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 14px 16px;
  border: 1px solid var(--color-border);
  border-radius: 16px;
  background: rgba(248, 250, 252, 0.8);
}

.focus-summary--active {
  border-color: rgba(22, 59, 102, 0.24);
  background:
    radial-gradient(420px 120px at 10% 10%, rgba(22, 59, 102, 0.08), transparent 60%),
    linear-gradient(180deg, #f8fbff 0%, var(--color-bg-card) 100%);
}

.focus-summary__title {
  color: var(--color-text-1);
  font-size: 16px;
  font-weight: 700;
}

.focus-summary__subtitle {
  margin-top: 4px;
  color: var(--color-text-2);
  font-size: 12px;
  line-height: 18px;
}

.focus-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
  margin-top: 14px;
}

.focus-card {
  width: 100%;
  padding: 15px 16px;
  border: 1px solid var(--color-border);
  border-radius: 16px;
  background: linear-gradient(180deg, var(--color-bg-card) 0%, #f8fafc 100%);
  color: var(--color-text-1);
  font-size: 14px;
  font-weight: 700;
  text-align: left;
  cursor: pointer;
  transition: border-color 0.2s ease, transform 0.2s ease, box-shadow 0.2s ease;
}

.focus-card:hover {
  border-color: rgba(22, 59, 102, 0.28);
  box-shadow: var(--shadow-soft);
  transform: translateY(-1px);
}

.focus-card--active {
  border-color: var(--color-primary);
  box-shadow: 0 10px 24px rgba(22, 59, 102, 0.12);
  background:
    radial-gradient(420px 120px at 10% 10%, rgba(22, 59, 102, 0.12), transparent 60%),
    linear-gradient(180deg, var(--color-bg-card) 0%, #f5f8fc 100%);
}

.filter-row {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.query-summary {
  margin-bottom: 14px;
  padding: 12px 14px;
  border-radius: 14px;
  border: 1px solid var(--color-border);
  background: rgba(248, 250, 252, 0.72);
  color: var(--color-text-2);
  font-size: 13px;
  line-height: 20px;
}

.query-summary--active {
  border-color: rgba(22, 59, 102, 0.24);
  background:
    radial-gradient(420px 120px at 10% 10%, rgba(22, 59, 102, 0.06), transparent 60%),
    linear-gradient(180deg, #f8fbff 0%, var(--color-bg-card) 100%);
}

.filter-input {
  width: 220px;
}

.filter-select {
  width: 140px;
}

.table-meta {
  color: var(--color-text-2);
  font-size: 12px;
}

.name-cell__title {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
  font-weight: 700;
  color: var(--color-text-1);
}

.pagination-bar {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}

.version-action-cell {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.version-action-cell__summary {
  color: var(--color-text-2);
  font-size: 12px;
  line-height: 18px;
}

.version-action-cell__empty {
  color: var(--color-text-2);
  font-size: 12px;
}

@media (max-width: 900px) {
  .focus-summary {
    flex-direction: column;
    align-items: stretch;
  }
}

</style>
