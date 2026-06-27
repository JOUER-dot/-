<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
import SkeletonLoader from '@/components/common/SkeletonLoader.vue'
import { useUserStore } from '@/stores/user'
import { getPublishedProductList, type PublicProductListItem } from '@/api/public-product'
import { getMySubscriptions, type MySubscriptionItem } from '@/api/subscription'
import { formatPercent, formatText } from '@/utils/format'
import { productTypeLabel } from '@/utils/status'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const products = ref<PublicProductListItem[]>([])
const subscriptions = ref<MySubscriptionItem[]>([])

const nickname = computed(() => userStore.userInfo?.nickname || userStore.userInfo?.username || '用户')
const username = computed(() => userStore.userInfo?.username || '-')
const roles = computed(() => userStore.roles.join('、') || '-')
const activeSubs = computed(() => subscriptions.value.filter((s) => s.status === 'ACTIVE'))
const posReturns = computed(() => activeSubs.value.filter((s) => Number(s.latestCumReturn || 0) > 0).length)
const negReturns = computed(() => activeSubs.value.filter((s) => Number(s.latestCumReturn || 0) < 0).length)

const overviewCards = computed(() => [
  { label: '已订阅', value: String(activeSubs.value.length), hint: '活跃订阅' },
  { label: '盈利产品', value: String(posReturns.value), hint: posReturns.value > 0 ? '收益为正' : '暂无' },
  { label: '亏损产品', value: String(negReturns.value), hint: negReturns.value > 0 ? '收益为负' : '暂无' }
])

onMounted(async () => {
  try { await userStore.restoreSession() } catch { /* ignore */ }
  loading.value = true
  try {
    const [pData, sData] = await Promise.all([
      getPublishedProductList({ pageNum: 1, pageSize: 6 }),
      getMySubscriptions({ pageNum: 1, pageSize: 100 })
    ])
    products.value = pData.records
    subscriptions.value = sData.records
  } finally { loading.value = false }
})
</script>

<template>
  <PageContainer>
    <div class="app-page user-dashboard">
      <div class="welcome-hero">
        <div class="welcome-hero__avatar">{{ nickname.slice(0, 1) }}</div>
        <div class="welcome-hero__info">
          <div class="welcome-hero__greeting">欢迎回来，{{ nickname }}</div>
          <div class="welcome-hero__meta">
            <span>@{{ username }}</span>
            <span class="hero-divider">|</span>
            <span>{{ roles }}</span>
          </div>
        </div>
        <el-button type="primary" @click="router.push('/advisor-zone')">浏览全部产品</el-button>
      </div>

      <!-- 账户概览 -->
      <div class="overview-grid">
        <StatCard v-for="card in overviewCards" :key="card.label" :label="card.label" :value="card.value" :hint="card.hint" />
      </div>

      <div class="dashboard-grid">
        <SectionCard title="我的订阅">
          <template #actions>
            <el-button v-if="activeSubs.length > 0" link type="primary" @click="router.push('/my-subscriptions')">管理 →</el-button>
          </template>
          <div v-if="activeSubs.length === 0" class="empty-card">
            <div>暂无订阅</div>
            <el-button size="small" @click="router.push('/advisor-zone')">去浏览产品</el-button>
          </div>
          <div v-else class="subs-list">
            <div v-for="s in activeSubs.slice(0, 5)" :key="s.subscriptionId" class="subs-item" @click="router.push(`/advisor-zone/${s.productId}`)">
              <div class="subs-left">
                <div class="subs-name">{{ s.productName }}</div>
                <div class="subs-meta">净值 {{ formatText(s.latestNav) }}</div>
              </div>
              <div class="subs-right">
                <span class="subs-ret" :class="Number(s.latestCumReturn) >= 0 ? 'up' : 'down'">
                  {{ formatPercent(s.latestCumReturn) }}
                </span>
              </div>
            </div>
          </div>
        </SectionCard>

        <SectionCard title="推荐产品">
          <template #actions>
            <el-button link type="primary" @click="router.push('/advisor-zone')">查看全部 →</el-button>
          </template>
          <SkeletonLoader v-if="loading && products.length === 0" type="card" :rows="3" />
          <div v-else class="product-mini-grid">
            <div v-for="item in products" :key="item.id" class="product-mini-card" @click="router.push(`/advisor-zone/${item.id}`)">
              <div class="pm-top">
                <span class="pm-risk" :class="`risk-${item.riskLevel.toLowerCase()}`">{{ item.riskLevel }}</span>
                <span class="pm-type">{{ productTypeLabel(item.type) }}</span>
              </div>
              <div class="pm-name">{{ item.name }}</div>
              <div class="pm-meta">{{ formatText(item.creatorName) }} · {{ formatText(item.strategyCode) }}</div>
              <div class="pm-bottom">
                <span class="pm-nav">{{ formatText(item.latestNav) }}</span>
                <span class="pm-ret" :class="Number(item.latestCumReturn) >= 0 ? 'up' : 'down'">{{ formatPercent(item.latestCumReturn) }}</span>
              </div>
            </div>
          </div>
        </SectionCard>
      </div>
    </div>
  </PageContainer>
</template>

<style scoped>
.user-dashboard { display: flex; flex-direction: column; gap: 16px; }
.welcome-hero { display: flex; align-items: center; gap: 20px; padding: 24px; border-radius: var(--radius-card); border: 1px solid var(--color-border); background: linear-gradient(180deg, var(--color-bg-card) 0%, #f8fafc 100%); box-shadow: var(--shadow-soft); }
.welcome-hero__avatar { width: 56px; height: 56px; border-radius: 50%; background: var(--brand-600); color: #fff; font-size: 24px; font-weight: 700; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.welcome-hero__info { flex: 1; min-width: 0; }
.welcome-hero__greeting { font-size: 22px; font-weight: 800; color: var(--color-text-1); line-height: 1.4; }
.welcome-hero__meta { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 6px; font-size: 13px; color: var(--color-text-2); }
.hero-divider { color: var(--color-border-strong); }
.overview-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
.dashboard-grid { display: grid; grid-template-columns: 0.8fr 1.2fr; gap: 16px; }
.empty-card { display: flex; flex-direction: column; align-items: center; gap: 12px; padding: 32px; color: var(--color-text-3); font-size: 14px; }

.subs-list { display: flex; flex-direction: column; gap: 2px; }
.subs-item { display: flex; align-items: center; justify-content: space-between; padding: 10px 12px; border-radius: 10px; cursor: pointer; transition: background .15s; }
.subs-item:hover { background: var(--color-bg-muted); }
.subs-left { min-width: 0; }
.subs-name { font-size: 14px; font-weight: 600; color: var(--color-text-1); }
.subs-meta { font-size: 12px; color: var(--color-text-3); margin-top: 2px; }
.subs-ret { font-size: 16px; font-weight: 800; }
.subs-ret.up { color: var(--danger-600); }
.subs-ret.down { color: var(--success-600); }

.product-mini-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 12px; }
.product-mini-card { padding: 16px; border: 1px solid var(--color-border); border-radius: 12px; cursor: pointer; transition: all .2s; background: var(--color-bg-card); display: flex; flex-direction: column; gap: 8px; }
.product-mini-card:hover { border-color: var(--color-primary); box-shadow: var(--shadow-soft); transform: translateY(-1px); }
.pm-top { display: flex; gap: 6px; }
.pm-risk { font-size: 10px; font-weight: 700; color: #fff; padding: 1px 8px; border-radius: 8px; }
.pm-risk.risk-r1 { background: #1e9e62; }
.pm-risk.risk-r2 { background: #2f6bde; }
.pm-risk.risk-r3 { background: #d89b2b; }
.pm-risk.risk-r4 { background: #e67e22; }
.pm-risk.risk-r5 { background: #c53b32; }
.pm-type { font-size: 10px; color: var(--color-text-3); padding: 1px 8px; border: 1px solid var(--color-border); border-radius: 8px; }
.pm-name { font-size: 15px; font-weight: 700; color: var(--color-text-1); }
.pm-meta { font-size: 12px; color: var(--color-text-3); }
.pm-bottom { display: flex; justify-content: space-between; align-items: center; padding-top: 4px; border-top: 1px solid var(--color-border); }
.pm-nav { font-size: 13px; font-weight: 700; color: var(--color-text-1); }
.pm-ret { font-size: 13px; font-weight: 700; }
.pm-ret.up { color: var(--danger-600); }
.pm-ret.down { color: var(--success-600); }

@media (max-width: 768px) { .dashboard-grid, .overview-grid { grid-template-columns: 1fr; } }
</style>
