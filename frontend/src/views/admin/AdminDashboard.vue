<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import PageHeader from '@/components/common/PageHeader.vue'
import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
import { getAdminDashboard, type AdminDashboard } from '@/api/admin'

const loading = ref(false)
const data = ref<AdminDashboard>({
  totalProducts: 0,
  publishedProducts: 0,
  pendingReviewProducts: 0,
  totalAdvisors: 0,
  totalUsers: 0,
  totalSubscriptions: 0,
  topSubscribedProducts: [],
  recentChanges: []
})

const summaryCards = computed(() => [
  { label: '产品总数', value: String(data.value.totalProducts), hint: '' },
  { label: '已上架', value: String(data.value.publishedProducts), hint: '' },
  { label: '待审核', value: String(data.value.pendingReviewProducts), hint: '' },
  { label: '投顾人数', value: String(data.value.totalAdvisors), hint: '' },
  { label: '用户总数', value: String(data.value.totalUsers), hint: '' },
  { label: '总订阅数', value: String(data.value.totalSubscriptions), hint: '' }
])

const actionTypeLabel = (type: string) => {
  const map: Record<string, string> = {
    SAVE_DRAFT: '保存草稿',
    SUBMIT: '提交审核',
    WITHDRAW: '撤回审核',
    APPROVE: '审核通过',
    REJECT: '审核驳回',
    DELETE: '删除',
    COPY: '复制'
  }
  return map[type] || type
}

const loadData = async () => {
  loading.value = true
  try {
    data.value = await getAdminDashboard()
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadData()
})
</script>

<template>
  <PageContainer>
    <div class="app-page">
      <PageHeader title="管理后台" description="系统运营概览" />

      <SectionCard title="运营概览">
        <div class="stat-grid">
          <StatCard v-for="item in summaryCards" :key="item.label" v-bind="item" />
        </div>
      </SectionCard>

      <div class="dashboard-grid">
        <SectionCard title="热门订阅产品">
          <el-table v-if="data.topSubscribedProducts.length > 0" :data="data.topSubscribedProducts" border size="small">
            <el-table-column label="产品名称" min-width="200">
              <template #default="{ row }">{{ row.productName }}</template>
            </el-table-column>
            <el-table-column label="订阅人数" width="120">
              <template #default="{ row }">{{ row.subscriberCount }}</template>
            </el-table-column>
          </el-table>
          <el-empty v-else description="暂无数据" />
        </SectionCard>

        <SectionCard title="最近操作">
          <el-table v-if="data.recentChanges.length > 0" :data="data.recentChanges" border size="small">
            <el-table-column label="产品" min-width="160">
              <template #default="{ row }">{{ row.productName }}</template>
            </el-table-column>
            <el-table-column label="操作" width="120">
              <template #default="{ row }">{{ actionTypeLabel(row.actionType) }}</template>
            </el-table-column>
            <el-table-column label="操作人" width="100">
              <template #default="{ row }">{{ row.operatorName }}</template>
            </el-table-column>
            <el-table-column label="时间" width="160">
              <template #default="{ row }">{{ row.createdAt }}</template>
            </el-table-column>
          </el-table>
          <el-empty v-else description="暂无数据" />
        </SectionCard>
      </div>
    </div>
  </PageContainer>
</template>

<style scoped>
.stat-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
  gap: 12px;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  margin-top: 16px;
}

@media (max-width: 768px) {
  .dashboard-grid {
    grid-template-columns: 1fr;
  }
}
</style>
