<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'

import { getPublishedProductDetail, type PublicProductDetail } from '@/api/public-product'
import { subscribeProduct } from '@/api/subscription'
import ProductNavChart from '@/components/charts/ProductNavChart.vue'
import { useUserStore } from '@/stores/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const loading = ref(false)
const subscribing = ref(false)

const detail = reactive<PublicProductDetail>({
  id: 0,
  name: '',
  type: '',
  riskLevel: '',
  strategyCode: '',
  versionId: 0,
  versionNo: 0,
  featureTags: [],
  baseInfo: {},
  params: {},
  components: [],
  navList: [],
  holdingSnapshot: {},
  holdingSnapshotDate: ''
})

const productId = computed(() => Number(route.params.id))
const holdingSnapshotText = computed(() => JSON.stringify(detail.holdingSnapshot, null, 2))

const loadDetail = async () => {
  loading.value = true
  try {
    const data = await getPublishedProductDetail(productId.value)
    Object.assign(detail, data)
  } finally {
    loading.value = false
  }
}

const handleSubscribe = async () => {
  if (!userStore.isLoggedIn) {
    await router.push({
      path: '/login',
      query: { redirect: route.fullPath }
    })
    return
  }

  subscribing.value = true
  try {
    await subscribeProduct(productId.value)
    ElMessage.success('订阅成功')
  } finally {
    subscribing.value = false
  }
}

void loadDetail()
</script>

<template>
  <div v-loading="loading" class="page-container">
    <div class="page-header">
      <div>
        <h1>{{ detail.name || '产品详情' }}</h1>
        <p>详情只读取已发布版本数据，订阅为签约登记，不代表真实交易。</p>
      </div>
      <div class="header-actions">
        <el-button @click="router.push('/advisor-zone')">返回专区</el-button>
        <el-button type="primary" :loading="subscribing" @click="handleSubscribe">立即订阅</el-button>
      </div>
    </div>

    <el-card shadow="never" class="section-card">
      <template #header>
        <div class="section-title">产品概览</div>
      </template>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="产品名称">{{ detail.name }}</el-descriptions-item>
        <el-descriptions-item label="已发布版本">V{{ detail.versionNo }}</el-descriptions-item>
        <el-descriptions-item label="产品类型">{{ detail.type }}</el-descriptions-item>
        <el-descriptions-item label="风险等级">{{ detail.riskLevel }}</el-descriptions-item>
        <el-descriptions-item label="策略编码">{{ detail.strategyCode || '-' }}</el-descriptions-item>
        <el-descriptions-item label="产品标签">
          <el-space wrap>
            <el-tag v-for="tag in detail.featureTags" :key="tag" effect="plain">{{ tag }}</el-tag>
          </el-space>
        </el-descriptions-item>
      </el-descriptions>
    </el-card>

    <el-card shadow="never" class="section-card">
      <template #header>
        <div class="section-title">产品介绍</div>
      </template>
      <el-descriptions :column="1" border>
        <el-descriptions-item label="产品简介">
          {{ String(detail.baseInfo.productSummary || detail.baseInfo.intro || '-') }}
        </el-descriptions-item>
        <el-descriptions-item label="目标客户">
          {{ String(detail.baseInfo.targetCustomer || detail.baseInfo.targetUser || '-') }}
        </el-descriptions-item>
        <el-descriptions-item label="风险提示">
          {{ String(detail.baseInfo.riskTips || '-') }}
        </el-descriptions-item>
      </el-descriptions>
    </el-card>

    <el-card shadow="never" class="section-card">
      <template #header>
        <div class="section-title">策略参数</div>
      </template>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="调仓周期（天）">
          {{ String(detail.params.rebalanceCycleDays || '-') }}
        </el-descriptions-item>
        <el-descriptions-item label="单基金最小权重">
          {{ String(detail.params.minSingleFundWeight || '-') }}
        </el-descriptions-item>
        <el-descriptions-item label="单基金最大权重">
          {{ String(detail.params.maxSingleFundWeight || '-') }}
        </el-descriptions-item>
        <el-descriptions-item label="建议持有期（月）">
          {{ String(detail.params.investHorizonMonths || '-') }}
        </el-descriptions-item>
      </el-descriptions>
    </el-card>

    <el-card shadow="never" class="section-card">
      <template #header>
        <div class="section-title">收益曲线</div>
      </template>
      <el-empty v-if="detail.navList.length === 0" description="暂无净值数据" />
      <ProductNavChart v-else :data="detail.navList" title="组合净值走势" />
    </el-card>

    <el-card shadow="never" class="section-card">
      <template #header>
        <div class="section-title">基金成份</div>
      </template>
      <el-table :data="detail.components" border>
        <el-table-column prop="fundCode" label="基金代码" min-width="120" />
        <el-table-column prop="fundName" label="基金名称" min-width="180" />
        <el-table-column prop="fundType" label="基金类型" min-width="120" />
        <el-table-column prop="riskLevel" label="风险等级" width="100" />
        <el-table-column prop="weight" label="权重" width="120" />
      </el-table>
    </el-card>

    <el-card shadow="never" class="section-card">
      <template #header>
        <div class="section-title">持仓快照</div>
      </template>
      <el-empty v-if="!detail.holdingSnapshotDate" description="暂无持仓快照" />
      <div v-else>
        <div class="snapshot-date">快照日期：{{ detail.holdingSnapshotDate }}</div>
        <pre class="snapshot-content">{{ holdingSnapshotText }}</pre>
      </div>
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
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
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

.header-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.section-card {
  margin-bottom: 16px;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.snapshot-date {
  margin-bottom: 12px;
  color: #606266;
}

.snapshot-content {
  margin: 0;
  padding: 16px;
  background: #f7f8fa;
  border-radius: 12px;
  overflow: auto;
  line-height: 1.7;
  color: #303133;
}
</style>
