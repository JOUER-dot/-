<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'

import { getMySubscriptions, type MySubscriptionItem } from '@/api/subscription'

const router = useRouter()
const loading = ref(false)
const records = ref<MySubscriptionItem[]>([])

const loadData = async () => {
  loading.value = true
  try {
    records.value = await getMySubscriptions()
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  void loadData()
})
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <div>
        <h1>我的订阅</h1>
        <p>这里只展示当前用户已订阅且仍处于上架状态的投顾产品。</p>
      </div>
    </div>

    <el-card shadow="never">
      <el-table v-loading="loading" :data="records" border>
        <el-table-column prop="productName" label="产品名称" min-width="180" />
        <el-table-column prop="type" label="产品类型" width="110" />
        <el-table-column prop="riskLevel" label="风险等级" width="100" />
        <el-table-column prop="latestNav" label="最新净值" width="120" />
        <el-table-column prop="latestCumReturn" label="累计收益" width="120" />
        <el-table-column prop="subscribedAt" label="订阅时间" min-width="180" />
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="router.push(`/advisor-zone/${row.productId}`)">
              查看详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<style scoped>
.page-container {
  min-height: calc(100vh - 48px);
  padding: 24px;
  background: #f5f7fa;
}

.page-header {
  margin-bottom: 16px;
}

.page-header h1 {
  margin: 0 0 8px;
  font-size: 28px;
  color: #303133;
}

.page-header p {
  margin: 0;
  color: #606266;
}
</style>
