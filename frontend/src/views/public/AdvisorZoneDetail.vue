<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
import { getPublishedProductDetail, type PublicProductDetail } from '@/api/public-product'
import { subscribeProduct } from '@/api/subscription'
import HoldingSnapshotCharts from '@/components/charts/HoldingSnapshotCharts.vue'
import ProductNavChart from '@/components/charts/ProductNavChart.vue'
import { useUserStore } from '@/stores/user'
import { formatDecimal, formatPercent, formatText } from '@/utils/format'
import { productTypeLabel } from '@/utils/status'

interface HoldingSnapshotComponent {
  fundCode: string
  fundName: string
  weight: number
}

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const loading = ref(false)
const subscribing = ref(false)
const subscribed = ref(false)

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
const holdingSnapshotComponents = computed<HoldingSnapshotComponent[]>(() => {
  const raw = detail.holdingSnapshot?.components
  if (!Array.isArray(raw)) {
    return []
  }

  return raw
    .map((item) => {
      const value = item as Record<string, unknown>
      return {
        fundCode: String(value.fundCode || ''),
        fundName: String(value.fundName || '-'),
        weight: Number(value.weight || 0)
      }
    })
    .filter((item) => item.fundCode)
    .sort((left, right) => right.weight - left.weight)
})

const latestNav = computed(() => detail.navList[detail.navList.length - 1]?.nav)
const latestCumReturn = computed(() => detail.navList[detail.navList.length - 1]?.cumReturn)
const componentCount = computed(() => detail.components.length)
const investHorizonText = computed(() => formatText(detail.params.investHorizonMonths))
const productSummary = computed(() => formatText(detail.baseInfo.productSummary || detail.baseInfo.intro))
const targetCustomer = computed(() => formatText(detail.baseInfo.targetCustomer || detail.baseInfo.targetUser))
const riskTips = computed(() => formatText(detail.baseInfo.riskTips))

const summaryCards = computed(() => [
  { label: '版本', value: `V${detail.versionNo || '-'}`, hint: '' },
  { label: '最新净值', value: formatDecimal(latestNav.value), hint: '' },
  { label: '累计收益', value: formatPercent(latestCumReturn.value), hint: '' },
  { label: '基金成份数', value: String(componentCount.value), hint: '' }
])

const loadDetail = async () => {
  loading.value = true
  try {
    const data = await getPublishedProductDetail(productId.value)
    Object.assign(detail, data)
  } finally {
    loading.value = false
  }
}

const subscribeButtonText = computed(() => {
  if (subscribed.value) {
    return '查看我的订阅'
  }
  return '立即订阅'
})

const handleSubscribe = async () => {
  if (subscribed.value) {
    await router.push('/my-subscriptions')
    return
  }
  if (!userStore.isLoggedIn) {
    await router.push({
      path: '/login',
      query: { redirect: route.fullPath }
    })
    return
  }
  try {
    await ElMessageBox.confirm('确认订阅当前产品吗？', '确认订阅', {
      type: 'warning'
    })
  } catch {
    return
  }

  subscribing.value = true
  try {
    await subscribeProduct(productId.value)
    subscribed.value = true
    ElMessage.success('订阅成功')
  } finally {
    subscribing.value = false
  }
}

void loadDetail()
</script>

<template>
  <PageContainer>
    <div v-loading="loading" class="detail-page">
      <SectionCard class="hero-card">
        <div class="hero-top">
          <div class="hero-main">
            <div class="hero-tags">
              <el-tag effect="dark">{{ detail.riskLevel || '-' }}</el-tag>
              <el-tag effect="plain">{{ productTypeLabel(detail.type) }}</el-tag>
              <el-tag v-if="detail.strategyCode" effect="plain">策略：{{ detail.strategyCode }}</el-tag>
            </div>
            <h1 class="hero-title">{{ detail.name || '产品详情' }}</h1>
            <p class="hero-desc">{{ productSummary }}</p>
            <div class="tag-list">
              <el-tag v-for="tag in detail.featureTags" :key="tag" effect="plain">{{ tag }}</el-tag>
              <span v-if="detail.featureTags.length === 0" class="muted-text">暂无产品标签</span>
            </div>
          </div>

          <div class="hero-side">
            <div class="hero-side__label">目标客户</div>
            <div class="hero-side__value">{{ targetCustomer }}</div>
            <div class="hero-side__label">建议持有期（月）</div>
            <div class="hero-side__value">{{ investHorizonText }}</div>
          </div>
        </div>
      </SectionCard>

      <div class="stat-grid">
        <StatCard
          v-for="item in summaryCards"
          :key="item.label"
          :label="item.label"
          :value="item.value"
          :hint="item.hint"
        />
      </div>

      <div class="summary-panels">
        <SectionCard class="subscribe-card" title="立即订阅">
          <div class="subscribe-actions">
            <el-button type="primary" :loading="subscribing" @click="handleSubscribe">
              {{ subscribeButtonText }}
            </el-button>
            <el-button v-if="userStore.isLoggedIn" @click="router.push('/my-subscriptions')">查看我的订阅</el-button>
            <el-button v-else @click="router.push('/login')">先登录</el-button>
          </div>
        </SectionCard>

        <SectionCard title="产品概览">
          <el-descriptions :column="1" border>
            <el-descriptions-item label="产品类型">{{ productTypeLabel(detail.type) }}</el-descriptions-item>
            <el-descriptions-item label="风险等级">{{ detail.riskLevel || '-' }}</el-descriptions-item>
            <el-descriptions-item label="策略编码">{{ formatText(detail.strategyCode) }}</el-descriptions-item>
            <el-descriptions-item label="风险提示">{{ riskTips }}</el-descriptions-item>
          </el-descriptions>
        </SectionCard>

        <SectionCard title="策略参数">
          <el-descriptions :column="1" border>
            <el-descriptions-item label="调仓周期（天）">{{ formatText(detail.params.rebalanceCycleDays) }}</el-descriptions-item>
            <el-descriptions-item label="单基金最小权重">{{ formatPercent(detail.params.minSingleFundWeight) }}</el-descriptions-item>
            <el-descriptions-item label="单基金最大权重">{{ formatPercent(detail.params.maxSingleFundWeight) }}</el-descriptions-item>
            <el-descriptions-item label="建议持有期（月）">{{ investHorizonText }}</el-descriptions-item>
          </el-descriptions>
        </SectionCard>
      </div>

      <div class="detail-main">
        <SectionCard title="收益曲线">
          <el-empty v-if="detail.navList.length === 0" description="暂无净值数据" />
          <ProductNavChart v-else :data="detail.navList" title="组合净值走势" />
        </SectionCard>

        <SectionCard title="持仓快照">
          <el-empty v-if="!detail.holdingSnapshotDate" description="暂无持仓快照" />
          <div v-else class="snapshot-section">
            <div class="snapshot-date">快照日期：{{ detail.holdingSnapshotDate }}</div>
            <HoldingSnapshotCharts v-if="holdingSnapshotComponents.length > 0" :data="holdingSnapshotComponents" />
            <el-empty v-else description="暂无可展示的持仓明细" />
            <el-table v-if="holdingSnapshotComponents.length > 0" :data="holdingSnapshotComponents" border class="snapshot-table">
              <el-table-column type="index" label="#" width="60" />
              <el-table-column prop="fundCode" label="基金代码" min-width="120" />
              <el-table-column prop="fundName" label="基金名称" min-width="220" />
              <el-table-column label="权重" width="140">
                <template #default="{ row }">
                  {{ formatPercent(row.weight) }}
                </template>
              </el-table-column>
            </el-table>
          </div>
        </SectionCard>

        <SectionCard title="基金成份">
          <el-table :data="detail.components" border>
            <el-table-column prop="fundCode" label="基金代码" min-width="120" />
            <el-table-column prop="fundName" label="基金名称" min-width="180" />
            <el-table-column prop="fundType" label="基金类型" min-width="120" />
            <el-table-column prop="riskLevel" label="风险等级" width="100" />
            <el-table-column label="权重" width="120">
              <template #default="{ row }">
                {{ formatPercent(row.weight) }}
              </template>
            </el-table-column>
          </el-table>
        </SectionCard>
      </div>
    </div>
  </PageContainer>
</template>

<style scoped>
.detail-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.hero-card {
  border-radius: var(--radius-card);
}

.hero-top {
  display: grid;
  grid-template-columns: minmax(0, 2fr) minmax(240px, 1fr);
  gap: 16px;
}

.hero-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.hero-title {
  margin: 12px 0 8px;
  font-size: 28px;
  line-height: 36px;
  color: var(--color-text-1);
  font-weight: 900;
}

.hero-desc {
  margin: 0;
  color: var(--color-text-2);
  line-height: 24px;
}

.hero-side {
  padding: 16px;
  border-radius: 16px;
  border: 1px solid rgba(22, 59, 102, 0.12);
  background: linear-gradient(180deg, rgba(22, 59, 102, 0.08) 0%, rgba(255, 255, 255, 0.92) 100%);
}

.hero-side__label {
  color: var(--color-text-2);
  font-size: 12px;
}

.hero-side__value {
  margin: 6px 0 12px;
  color: var(--color-text-1);
  font-size: 18px;
  font-weight: 800;
}

.tag-list {
  margin-top: 14px;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.stat-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
}

.summary-panels {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
}

.detail-main {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.snapshot-date {
  margin-bottom: 12px;
  color: var(--color-text-2);
}

.snapshot-section {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.snapshot-table {
  margin-top: 4px;
}

.subscribe-card {
  border-radius: var(--radius-card);
}

.subscribe-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

@media (max-width: 960px) {
  .hero-top {
    grid-template-columns: 1fr;
  }

  .summary-panels {
    grid-template-columns: 1fr;
  }
}
</style>
