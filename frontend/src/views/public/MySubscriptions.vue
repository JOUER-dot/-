<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import PageHeader from '@/components/common/PageHeader.vue'
import { getMySubscriptions, type MySubscriptionItem, unsubscribeProduct } from '@/api/subscription'
import { formatDecimal, formatPercent } from '@/utils/format'
import { loadPersisted, savePersisted } from '@/utils/persist'
import {
  productStatusLabel,
  productStatusTagType,
  productTypeLabel,
  subscriptionStatusLabel,
  subscriptionStatusTagType
} from '@/utils/status'

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
    { label: '筛选后记录数', value: String(source.length), hint: '按当前筛选条件统计' },
    { label: '当前有效订阅', value: String(activeCount), hint: '仍处于 ACTIVE 的记录' },
    { label: '已取消订阅', value: String(cancelledCount), hint: '用户主动取消的记录' },
    { label: '产品已下架', value: String(offlineCount), hint: '产品状态为 OFFLINE' }
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
  <div class="app-page">
    <PageHeader title="我的订阅" description="这里展示当前用户的全部订阅记录，并区分产品状态与订阅状态。" />

    <div class="summary-grid">
      <div v-for="item in summaryCards" :key="item.label" class="summary-card">
        <div class="summary-card__label">{{ item.label }}</div>
        <div class="summary-card__value">{{ item.value }}</div>
        <div class="summary-card__hint">{{ item.hint }}</div>
      </div>
    </div>

    <el-card shadow="never" class="section-card">
      <template #header>
        <div class="table-header">
          <div class="section-title">订阅明细</div>
          <div class="filter-row">
            <el-input
              v-model="filterForm.keyword"
              clearable
              placeholder="按产品名称筛选"
              class="filter-input"
            />
            <el-select v-model="filterForm.subscriptionStatus" clearable placeholder="订阅状态" class="filter-select">
              <el-option label="已订阅" value="ACTIVE" />
              <el-option label="已取消" value="CANCELLED" />
            </el-select>
            <el-select v-model="filterForm.productStatus" clearable placeholder="产品状态" class="filter-select">
              <el-option label="已上架" value="PUBLISHED" />
              <el-option label="已下架" value="OFFLINE" />
            </el-select>
            <el-button @click="handleClearFilters">清空筛选</el-button>
          </div>
        </div>
      </template>
      <el-empty v-if="!loading && filteredRecords.length === 0" description="暂无符合条件的订阅记录" />
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
            <el-tag :type="productStatusTagType(row.productStatus)">
              {{ productStatusLabel(row.productStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="订阅状态" width="120">
          <template #default="{ row }">
            <el-tag :type="subscriptionStatusTagType(row.status)">
              {{ subscriptionStatusLabel(row.status) }}
            </el-tag>
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
              <el-button link type="primary" @click="router.push(`/advisor-zone/${row.productId}`)">
                查看详情
              </el-button>
              <el-button v-if="row.status === 'ACTIVE'" link type="danger" @click="handleUnsubscribe(row)">
                取消订阅
              </el-button>
            </el-space>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<style scoped>
.table-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
}

.filter-row {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  justify-content: flex-end;
}

.filter-input {
  width: 220px;
}

.filter-select {
  width: 140px;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}
</style>
