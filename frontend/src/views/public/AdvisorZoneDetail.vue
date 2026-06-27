<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
import { getPublishedProductDetail, type PublicProductDetail } from '@/api/public-product'
import { subscribeProduct } from '@/api/subscription'
import { getMySubscriptions } from '@/api/subscription'
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
const subDialogVisible = ref(false)
const investAmount = ref(10000)
const subPin = ref('')
const fundDialogVisible = ref(false)
const selectedFund = ref<PublicProductDetail['components'][0] | null>(null)

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
    // Check if user already subscribed
    if (userStore.isLoggedIn) {
      try {
        const subData = await getMySubscriptions({ pageNum: 1, pageSize: 999 })
        subscribed.value = subData.records.some(s => s.productId === productId.value && s.status === 'ACTIVE')
      } catch { /* ignore */ }
    }
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
    await router.push({ path: '/login', query: { redirect: route.fullPath } })
    return
  }
  investAmount.value = 10000
  subPin.value = ''
  subDialogVisible.value = true
}

const confirmSubscribe = async () => {
  if (!investAmount.value || investAmount.value < 1000) {
    ElMessage.warning('投入金额不能少于 1,000 元')
    return
  }
  if (!/^\d{6}$/.test(subPin.value)) {
    ElMessage.warning('请输入6位数字交易密码')
    return
  }
  subDialogVisible.value = false
  router.push(`/payment/${productId.value}?amount=${investAmount.value}`)
}

const handleFundClick = (fund: PublicProductDetail['components'][0]) => {
  selectedFund.value = fund
  fundDialogVisible.value = true
}

void loadDetail()
</script>

<template>
  <PageContainer>
    <div v-loading="loading" class="detail-page">
      <!-- 标题栏 -->
      <div class="detail-bar">
        <el-button link class="bar-back" @click="router.push('/advisor-zone')">
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
            <path d="M10 12L6 8L10 4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          返回
        </el-button>
        <el-button type="primary" class="bar-subscribe" :loading="subscribing" @click="handleSubscribe">
          {{ subscribeButtonText }}
        </el-button>
      </div>

      <!-- 产品主卡片 -->
      <div class="product-masthead">
        <div class="masthead-bg" />
        <div class="masthead-content">
          <div class="masthead-tags">
            <span class="mh-tag mh-tag--risk" :class="`risk-${(detail.riskLevel || 'r3').toLowerCase()}`">{{ detail.riskLevel }}</span>
            <span class="mh-tag mh-tag--type">{{ productTypeLabel(detail.type) }}</span>
            <span v-if="detail.strategyCode" class="mh-tag mh-tag--code">{{ detail.strategyCode }}</span>
          </div>

          <h1 class="mh-title">{{ detail.name || '产品详情' }}</h1>

          <p class="mh-desc">{{ productSummary || '暂无产品简介' }}</p>

          <div class="mh-meta">
            <span v-if="targetCustomer && targetCustomer !== '-'">
              <svg width="14" height="14" viewBox="0 0 14 14" fill="none"><circle cx="7" cy="5" r="2.5" stroke="#8a94a3" stroke-width="1.2"/><path d="M2 12C2 10 4.24 8.5 7 8.5C9.76 8.5 12 10 12 12" stroke="#8a94a3" stroke-width="1.2" stroke-linecap="round"/></svg>
              {{ targetCustomer }}
            </span>
            <span v-if="investHorizonText && investHorizonText !== '-'">
              <svg width="14" height="14" viewBox="0 0 14 14" fill="none"><circle cx="7" cy="7" r="5.5" stroke="#8a94a3" stroke-width="1.2"/><path d="M7 4V7L9 9" stroke="#8a94a3" stroke-width="1.2" stroke-linecap="round"/></svg>
              建议持有 {{ investHorizonText }} 个月
            </span>
          </div>

          <div v-if="detail.featureTags?.length" class="mh-features">
            <el-tag v-for="tag in detail.featureTags" :key="tag" effect="plain" size="small" class="mh-feature-tag">{{ tag }}</el-tag>
          </div>
        </div>

        <!-- 数据面板 -->
        <div class="masthead-metrics">
          <div class="metric-item">
            <div class="metric-icon metric-icon--nav">
              <svg width="18" height="18" viewBox="0 0 18 18" fill="none"><path d="M2 16L7 10L11 13L16 5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>
            </div>
            <div class="metric-body">
              <span class="metric-label">最新净值</span>
              <span class="metric-value">{{ formatDecimal(latestNav) }}</span>
            </div>
          </div>
          <div class="metric-divider" />
          <div class="metric-item metric-item--highlight">
            <div class="metric-icon metric-icon--return">
              <svg width="18" height="18" viewBox="0 0 18 18" fill="none"><path d="M9 2V16" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/><path d="M5 7L9 3L13 7" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
            </div>
            <div class="metric-body">
              <span class="metric-label">累计收益</span>
              <span class="metric-value" :class="Number(latestCumReturn) >= 0 ? 'up' : 'down'">
                {{ formatPercent(latestCumReturn) }}
              </span>
            </div>
          </div>
          <div class="metric-divider" />
          <div class="metric-item">
            <div class="metric-icon metric-icon--fund">
              <svg width="18" height="18" viewBox="0 0 18 18" fill="none"><rect x="2" y="7" width="3" height="9" rx="1" stroke="currentColor" stroke-width="1.2"/><rect x="7.5" y="4" width="3" height="12" rx="1" stroke="currentColor" stroke-width="1.2"/><rect x="13" y="2" width="3" height="14" rx="1" stroke="currentColor" stroke-width="1.2"/></svg>
            </div>
            <div class="metric-body">
              <span class="metric-label">成份数量</span>
              <span class="metric-value">{{ componentCount }} <span class="metric-unit">只基金</span></span>
            </div>
          </div>
          <div class="metric-divider" />
          <div class="metric-item">
            <div class="metric-icon metric-icon--version">
              <svg width="18" height="18" viewBox="0 0 18 18" fill="none"><circle cx="9" cy="9" r="7" stroke="currentColor" stroke-width="1.2"/><path d="M9 5V9L12 12" stroke="currentColor" stroke-width="1.2" stroke-linecap="round"/></svg>
            </div>
            <div class="metric-body">
              <span class="metric-label">版本</span>
              <span class="metric-value">V{{ detail.versionNo || '-' }}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="detail-main">
        <SectionCard title="收益曲线">
          <el-empty v-if="detail.navList.length === 0" description="暂无净值数据" />
          <ProductNavChart v-else :data="detail.navList" title="组合净值走势" />

          <!-- 净值数据表格 -->
          <div v-if="detail.navList.length > 0" class="nav-table-wrap">
            <div class="nav-table-header">
              <span>历史净值</span>
              <el-button size="small" link @click="() => {}">展开全部</el-button>
            </div>
            <el-table :data="detail.navList.slice(-10)" border size="small" class="nav-table">
              <el-table-column label="日期" min-width="120">
                <template #default="{ row }">{{ row.navDate }}</template>
              </el-table-column>
              <el-table-column label="单位净值" min-width="140">
                <template #default="{ row }">{{ formatDecimal(row.nav) }}</template>
              </el-table-column>
              <el-table-column label="累计收益" min-width="120">
                <template #default="{ row }">
                  <span :class="Number(row.cumReturn) >= 0 ? 'text-up' : 'text-down'">
                    {{ formatPercent(row.cumReturn) }}
                  </span>
                </template>
              </el-table-column>
            </el-table>
          </div>
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
          <el-table :data="detail.components" border @row-click="handleFundClick" style="cursor:pointer">
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

      <!-- 基金详情对话框 -->
      <el-dialog v-model="fundDialogVisible" :title="selectedFund?.fundName || '基金详情'" width="520px">
        <template v-if="selectedFund">
          <el-descriptions :column="1" border>
            <el-descriptions-item label="基金名称">{{ selectedFund.fundName }}</el-descriptions-item>
            <el-descriptions-item label="基金代码">{{ formatText(selectedFund.fundCode) }}</el-descriptions-item>
            <el-descriptions-item label="基金类型">{{ formatText(selectedFund.fundType) }}</el-descriptions-item>
            <el-descriptions-item label="风险等级">{{ formatText(selectedFund.riskLevel) }}</el-descriptions-item>
            <el-descriptions-item label="基金公司">{{ formatText(selectedFund.companyName) }}</el-descriptions-item>
            <el-descriptions-item label="配置权重">{{ formatPercent(selectedFund.weight) }}</el-descriptions-item>
          </el-descriptions>
        </template>
      </el-dialog>

      <!-- 订阅金额对话框 -->
      <el-dialog v-model="subDialogVisible" title="确认订阅" width="420px">
        <div class="sub-dialog-body">
          <p style="margin:0 0 16px;color:var(--color-text-2);font-size:14px;">请输入投入金额和交易密码</p>
          <div style="margin-bottom:14px">
            <label style="font-size:12px;font-weight:600;color:var(--color-text-2);display:block;margin-bottom:6px;">投入金额</label>
            <el-input-number v-model="investAmount" :min="1000" :step="1000" :max="99999999" style="width:100%" size="large" />
          </div>
          <div style="margin-bottom:14px">
            <label style="font-size:12px;font-weight:600;color:var(--color-text-2);display:block;margin-bottom:6px;">交易密码（6位数字）</label>
            <el-input v-model="subPin" maxlength="6" placeholder="请输入6位数字交易密码" size="large" />
          </div>
        </div>
        <template #footer>
          <el-button @click="subDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="confirmSubscribe">确认订阅</el-button>
        </template>
      </el-dialog>
    </div>
  </PageContainer>
</template>

<style scoped>
.detail-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* 标题栏 */
.detail-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}
.bar-back {
  font-size: 13px;
  color: var(--color-text-3);
  display: flex;
  align-items: center;
  gap: 4px;
}
.bar-back:hover { color: var(--color-text-1); }
.bar-subscribe {
  border-radius: 10px;
  font-weight: 700;
  letter-spacing: 0.5px;
}

/* 产品主卡片 */
.product-masthead {
  position: relative;
  border-radius: var(--radius-card);
  overflow: hidden;
  background: #ffffff;
  border: 1px solid var(--color-border);
  box-shadow: var(--shadow-soft);
}

.masthead-bg {
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 180px;
  background: linear-gradient(135deg, rgba(14,46,85,0.03) 0%, rgba(200,164,93,0.04) 100%);
  pointer-events: none;
}

.masthead-content {
  position: relative;
  padding: 28px 32px 0;
  z-index: 1;
}

.masthead-tags {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}
.mh-tag {
  font-size: 12px;
  font-weight: 600;
  padding: 3px 12px;
  border-radius: 6px;
}
.mh-tag--risk {
  color: #fff;
}
.mh-tag--risk.risk-r1 { background: #1e9e62; }
.mh-tag--risk.risk-r2 { background: #2f6bde; }
.mh-tag--risk.risk-r3 { background: #d89b2b; }
.mh-tag--risk.risk-r4 { background: #e67e22; }
.mh-tag--risk.risk-r5 { background: #c53b32; }
.mh-tag--type {
  color: var(--color-text-2);
  background: var(--gray-100);
  border: 1px solid var(--color-border);
}
.mh-tag--code {
  color: var(--color-text-2);
  background: var(--gray-50);
  border: 1px solid var(--color-border);
}
.mh-tag--major {
  color: var(--danger-600);
  background: var(--danger-50);
  border: 1px solid var(--danger-600);
}

.mh-title {
  font-size: 30px;
  font-weight: 900;
  color: var(--color-text-1);
  margin: 0;
  line-height: 1.2;
  letter-spacing: -0.5px;
}

.mh-desc {
  margin: 10px 0 0;
  font-size: 15px;
  color: var(--color-text-2);
  line-height: 1.6;
}

.mh-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  margin-top: 14px;
  font-size: 13px;
  color: var(--color-text-3);
}
.mh-meta span {
  display: flex;
  align-items: center;
  gap: 6px;
}

.mh-features {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 16px;
  padding-bottom: 24px;
}
.mh-feature-tag {
  border-radius: 6px;
}

/* 数据面板 */
.masthead-metrics {
  display: flex;
  align-items: stretch;
  margin: 0 32px 24px;
  padding: 20px 0 0;
  border-top: 1px solid var(--color-border);
}

.metric-item {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 4px 8px;
}

.metric-item--highlight {
  background: var(--brand-50);
  border-radius: 12px;
  padding: 8px 14px;
  margin: -4px 0;
}

.metric-divider {
  width: 1px;
  align-self: stretch;
  background: var(--color-border);
  margin: 0 4px;
}

.metric-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.metric-icon--nav { background: rgba(31,92,153,0.08); color: #1f5c99; }
.metric-icon--return { background: rgba(30,158,98,0.08); color: #1e9e62; }
.metric-icon--fund { background: rgba(216,155,43,0.08); color: #d89b2b; }
.metric-icon--version { background: rgba(47,107,222,0.08); color: #2f6bde; }

.metric-body {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.metric-label {
  font-size: 11px;
  color: var(--color-text-3);
  letter-spacing: 0.3px;
}

.metric-value {
  font-size: 18px;
  font-weight: 800;
  color: var(--color-text-1);
  line-height: 1.2;
}

.metric-value.up { color: var(--danger-600); }
.metric-value.down { color: var(--success-600); }

.metric-unit {
  font-size: 12px;
  font-weight: 500;
  color: var(--color-text-3);
}

/* 其余区块 */
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

@media (max-width: 860px) {
  .masthead-metrics {
    flex-direction: column;
    gap: 12px;
  }
  .metric-divider { display: none; }
  .metric-item { padding: 8px; }
  .masthead-content { padding: 20px 20px 0; }
  .masthead-metrics { margin: 0 20px 20px; }
}
</style>
