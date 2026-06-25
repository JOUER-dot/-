<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
import StatusTag from '@/components/ui/StatusTag.vue'
import { getMySubscriptions, type MySubscriptionItem, unsubscribeProduct } from '@/api/subscription'
import { formatDecimal, formatPercent } from '@/utils/format'
import { loadPersisted, savePersisted } from '@/utils/persist'
import { productTypeLabel } from '@/utils/status'

const router = useRouter()
const loading = ref(false)
const records = ref<MySubscriptionItem[]>([])

const storageKey = 'roboadvisor:my-subscriptions:filter'

const filterForm = reactive({
  keyword: '',
  productStatus: '',
  subscriptionStatus: ''
})

const filteredRecords = computed(() => {
  const keyword = filterForm.keyword.trim()
  return records.value.filter((item) => {
    if (filterForm.productStatus && item.productStatus !== filterForm.productStatus) {
      return false
    }
    if (filterForm.subscriptionStatus && item.status !== filterForm.subscriptionStatus) {
      return false
    }
    if (keyword) {
      return item.productName?.includes(keyword)
    }
    return true
  })
})

const summaryCards = computed(() => {
  const source = filteredRecords.value
  const activeCount = source.filter((item) => item.status === 'ACTIVE').length
  const cancelledCount = source.filter((item) => item.status === 'CANCELLED').length
  const offlineCount = source.filter((item) => item.productStatus === 'OFFLINE').length
  return [
    { label: '订阅记录', value: String(source.length), hint: '' },
    { label: '有效订阅', value: String(activeCount), hint: '' },
    { label: '已取消', value: String(cancelledCount), hint: '' },
    { label: '已下架产品', value: String(offlineCount), hint: '' }
  ]
})

const loadData = async () => {
  loading.value = true
  try {
    records.value = await getMySubscriptions()
  } finally {
    loading.value = false
  }
}

const handleClearFilters = () => {
  filterForm.keyword = ''
  filterForm.productStatus = ''
  filterForm.subscriptionStatus = ''
}

onMounted(() => {
  const persisted = loadPersisted<typeof filterForm>(storageKey, { keyword: '', productStatus: '', subscriptionStatus: '' })
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
  await loadData()
}
</script>

<template>
  <PageContainer>
    <div class="subscription-page">
      <div class="hero">
        <div>
          <div class="hero__kicker">我的订阅</div>
          <div class="hero__title">跟踪已订阅产品</div>
        </div>
      </div>

      <div class="stat-grid">
        <StatCard v-for="item in summaryCards" :key="item.label" :label="item.label" :value="item.value" :hint="item.hint" />
      </div>

      <SectionCard title="筛选">
        <div class="filter-row">
          <el-input v-model="filterForm.keyword" clearable placeholder="产品名称" class="filter-input" />
          <el-select v-model="filterForm.subscriptionStatus" clearable placeholder="订阅状态" class="filter-select">
            <el-option label="已订阅" value="ACTIVE" />
            <el-option label="已取消" value="CANCELLED" />
          </el-select>
          <el-select v-model="filterForm.productStatus" clearable placeholder="产品状态" class="filter-select">
            <el-option label="已上架" value="PUBLISHED" />
            <el-option label="已下架" value="OFFLINE" />
          </el-select>
          <el-button @click="handleClearFilters">清空</el-button>
        </div>
      </SectionCard>

      <SectionCard title="订阅列表">
        <el-empty v-if="!loading && filteredRecords.length === 0" description="暂无订阅记录" />
        <el-table v-else v-loading="loading" :data="filteredRecords" border>
          <el-table-column prop="productName" label="产品名称" min-width="180" />
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
          <el-table-column label="操作" width="180" fixed="right">
            <template #default="{ row }">
              <el-space>
                <el-button link type="primary" @click="router.push(`/advisor-zone/${row.productId}`)">查看详情</el-button>
                <el-button v-if="row.status === 'ACTIVE'" link type="danger" @click="handleUnsubscribe(row)">取消订阅</el-button>
              </el-space>
            </template>
          </el-table-column>
        </el-table>
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

.hero {
  padding: 18px;
  border-radius: var(--radius-card);
  border: 1px solid var(--color-border);
  background:
    radial-gradient(640px 220px at 18% 18%, rgba(22, 59, 102, 0.12), transparent 60%),
    linear-gradient(180deg, var(--color-bg-card) 0%, #f8fafc 100%);
}

.hero__kicker {
  color: var(--color-text-2);
  font-size: 12px;
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

.filter-row {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.filter-input {
  width: 220px;
}

.filter-select {
  width: 140px;
}

</style>
