<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'

import PageHeader from '@/components/common/PageHeader.vue'
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
  {
    label: '已发布版本',
    value: `V${detail.versionNo || '-'}`,
    hint: '详情只基于已发布版本展示'
  },
  {
    label: '最新净值',
    value: formatDecimal(latestNav.value),
    hint: '来自组合净值序列'
  },
  {
    label: '累计收益',
    value: formatPercent(latestCumReturn.value),
    hint: '用于展示阶段表现'
  },
  {
    label: '基金成份数',
    value: String(componentCount.value),
    hint: '展示当前版本成份结构'
  }
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
  <div v-loading="loading" class="app-page">
    <PageHeader :title="detail.name || '产品详情'" description="详情只读取已发布版本数据，订阅为签约登记，不代表真实交易。">
      <template #actions>
        <el-button @click="router.push('/advisor-zone')">返回专区</el-button>
        <el-button type="primary" :loading="subscribing" @click="handleSubscribe">立即订阅</el-button>
      </template>
    </PageHeader>

    <div class="summary-grid">
      <div v-for="item in summaryCards" :key="item.label" class="summary-card">
        <div class="summary-card__label">{{ item.label }}</div>
        <div class="summary-card__value">{{ item.value }}</div>
        <div class="summary-card__hint">{{ item.hint }}</div>
      </div>
    </div>

    <div class="content-grid">
      <div class="content-grid__main">
        <el-card shadow="never" class="section-card hero-card">
          <div class="hero-top">
            <div class="hero-main">
              <div class="hero-tags">
                <el-tag effect="dark">{{ detail.riskLevel || '-' }}</el-tag>
                <el-tag effect="plain">{{ productTypeLabel(detail.type) }}</el-tag>
                <el-tag v-if="detail.strategyCode" effect="plain">策略：{{ detail.strategyCode }}</el-tag>
              </div>
              <h2>{{ detail.name || '产品详情' }}</h2>
              <p>{{ productSummary }}</p>
            </div>
            <div class="hero-side">
              <div class="hero-side__label">目标客户</div>
              <div class="hero-side__value">{{ targetCustomer }}</div>
              <div class="hero-side__label">建议持有期（月）</div>
              <div class="hero-side__value">{{ investHorizonText }}</div>
            </div>
          </div>
          <div class="tag-list">
            <el-tag v-for="tag in detail.featureTags" :key="tag" effect="plain">{{ tag }}</el-tag>
            <span v-if="detail.featureTags.length === 0" class="muted-text">暂无产品标签</span>
          </div>
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
            <div class="section-title">持仓快照</div>
          </template>
          <el-empty v-if="!detail.holdingSnapshotDate" description="暂无持仓快照" />
          <div v-else class="snapshot-section">
            <div class="snapshot-date">快照日期：{{ detail.holdingSnapshotDate }}</div>
            <HoldingSnapshotCharts
              v-if="holdingSnapshotComponents.length > 0"
              :data="holdingSnapshotComponents"
            />
            <el-empty v-else description="暂无可展示的持仓明细" />
            <el-table
              v-if="holdingSnapshotComponents.length > 0"
              :data="holdingSnapshotComponents"
              border
              class="snapshot-table"
            >
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
            <el-table-column label="权重" width="120">
              <template #default="{ row }">
                {{ formatPercent(row.weight) }}
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </div>

      <div class="content-grid__side">
        <el-card shadow="never" class="section-card subscribe-card">
          <div class="subscribe-card__title">立即订阅</div>
          <div class="subscribe-card__text">
            订阅为签约登记，便于后续在“我的订阅”中持续跟踪产品状态、净值与收益。
          </div>
          <el-button type="primary" :loading="subscribing" @click="handleSubscribe">立即订阅</el-button>
          <el-button @click="router.push('/my-subscriptions')">查看我的订阅</el-button>
        </el-card>

        <el-card shadow="never" class="section-card">
          <template #header>
            <div class="section-title">产品概览</div>
          </template>
          <el-descriptions :column="1" border>
            <el-descriptions-item label="产品类型">{{ productTypeLabel(detail.type) }}</el-descriptions-item>
            <el-descriptions-item label="风险等级">{{ detail.riskLevel || '-' }}</el-descriptions-item>
            <el-descriptions-item label="策略编码">{{ formatText(detail.strategyCode) }}</el-descriptions-item>
            <el-descriptions-item label="风险提示">{{ riskTips }}</el-descriptions-item>
          </el-descriptions>
        </el-card>

        <el-card shadow="never" class="section-card">
          <template #header>
            <div class="section-title">策略参数</div>
          </template>
          <el-descriptions :column="1" border>
            <el-descriptions-item label="调仓周期（天）">
              {{ formatText(detail.params.rebalanceCycleDays) }}
            </el-descriptions-item>
            <el-descriptions-item label="单基金最小权重">
              {{ formatPercent(detail.params.minSingleFundWeight) }}
            </el-descriptions-item>
            <el-descriptions-item label="单基金最大权重">
              {{ formatPercent(detail.params.maxSingleFundWeight) }}
            </el-descriptions-item>
            <el-descriptions-item label="建议持有期（月）">
              {{ investHorizonText }}
            </el-descriptions-item>
          </el-descriptions>
        </el-card>
      </div>
    </div>
  </div>
</template>

<style scoped>
.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.hero-card {
  border-radius: 18px;
}

.hero-top {
  display: grid;
  grid-template-columns: minmax(0, 2fr) minmax(220px, 1fr);
  gap: 16px;
  margin-bottom: 16px;
}

.hero-main h2 {
  margin: 12px 0 8px;
  font-size: 28px;
  color: #111827;
}

.hero-main p {
  margin: 0;
  color: #6b7280;
  line-height: 24px;
}

.hero-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.hero-side {
  padding: 16px;
  background: linear-gradient(180deg, #f8fbff 0%, #eff6ff 100%);
  border-radius: 16px;
}

.hero-side__label {
  color: #6b7280;
  font-size: 12px;
}

.hero-side__value {
  margin: 6px 0 12px;
  color: #111827;
  font-size: 18px;
  font-weight: 600;
}

.tag-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.snapshot-date {
  margin-bottom: 12px;
  color: #606266;
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
  display: flex;
  flex-direction: column;
  gap: 12px;
  border-radius: 18px;
  background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%);
}

.subscribe-card__title {
  font-size: 20px;
  font-weight: 700;
  color: #111827;
}

.subscribe-card__text,
.muted-text {
  color: #6b7280;
  line-height: 22px;
}

@media (max-width: 768px) {
  .hero-top {
    grid-template-columns: 1fr;
  }
}
</style>
