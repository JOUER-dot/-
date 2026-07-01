<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, ref } from 'vue'
import * as echarts from 'echarts'

import PageHeader from '@/components/common/PageHeader.vue'
import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
import { getAdminDashboard, type AdminDashboard } from '@/api/admin'

const loading = ref(false)
const statusChartRef = ref<HTMLDivElement>()
const topChartRef = ref<HTMLDivElement>()
let statusChart: echarts.ECharts | null = null
let topChart: echarts.ECharts | null = null

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

const draftProducts = computed(() => Math.max(
  data.value.totalProducts - data.value.publishedProducts - data.value.pendingReviewProducts,
  0
))

const subscriptionRate = computed(() => {
  if (!data.value.totalUsers) return '0.0%'
  return `${((data.value.totalSubscriptions / data.value.totalUsers) * 100).toFixed(1)}%`
})

const avgSubscriptions = computed(() => {
  if (!data.value.publishedProducts) return '0.0'
  return (data.value.totalSubscriptions / data.value.publishedProducts).toFixed(1)
})

const summaryCards = computed(() => [
  { label: '产品总数', value: String(data.value.totalProducts), hint: '覆盖草稿、待审、已上架' },
  { label: '已上架', value: String(data.value.publishedProducts), hint: '当前可被用户订阅' },
  { label: '待审核', value: String(data.value.pendingReviewProducts), hint: data.value.pendingReviewProducts > 0 ? '需要审核员处理' : '审核队列清爽' },
  { label: '投顾人数', value: String(data.value.totalAdvisors), hint: '可创建产品的顾问' },
  { label: '用户总数', value: String(data.value.totalUsers), hint: `订阅渗透率 ${subscriptionRate.value}` },
  { label: '总订阅数', value: String(data.value.totalSubscriptions), hint: `单产品均值 ${avgSubscriptions.value}` }
])

const statusData = computed(() => [
  { name: '已上架', value: data.value.publishedProducts, itemStyle: { color: '#2563eb' } },
  { name: '待审核', value: data.value.pendingReviewProducts, itemStyle: { color: '#f59e0b' } },
  { name: '草稿/其他', value: draftProducts.value, itemStyle: { color: '#64748b' } }
])

const hottestProduct = computed(() => data.value.topSubscribedProducts[0])
const reviewPressure = computed(() => {
  if (!data.value.totalProducts) return 0
  return Math.round((data.value.pendingReviewProducts / data.value.totalProducts) * 100)
})

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

const renderCharts = async () => {
  await nextTick()
  if (statusChartRef.value) {
    if (!statusChart) statusChart = echarts.init(statusChartRef.value)
    statusChart.setOption({
      tooltip: { trigger: 'item' },
      legend: { bottom: 0, icon: 'circle', textStyle: { color: '#64748b' } },
      series: [{
        name: '产品状态',
        type: 'pie',
        radius: ['54%', '76%'],
        center: ['50%', '44%'],
        avoidLabelOverlap: true,
        label: { formatter: '{b}\n{c}', color: '#334155', fontWeight: 600 },
        data: statusData.value
      }]
    })
  }

  if (topChartRef.value) {
    if (!topChart) topChart = echarts.init(topChartRef.value)
    const products = data.value.topSubscribedProducts.slice(0, 6).reverse()
    topChart.setOption({
      tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
      grid: { left: 12, right: 24, top: 16, bottom: 12, containLabel: true },
      xAxis: {
        type: 'value',
        splitLine: { lineStyle: { color: '#edf2f7', type: 'dashed' } },
        axisLabel: { color: '#64748b' }
      },
      yAxis: {
        type: 'category',
        data: products.map((item) => item.productName),
        axisLabel: { color: '#334155', width: 120, overflow: 'truncate' }
      },
      series: [{
        name: '订阅人数',
        type: 'bar',
        barWidth: 14,
        itemStyle: {
          borderRadius: [0, 8, 8, 0],
          color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
            { offset: 0, color: '#38bdf8' },
            { offset: 1, color: '#2563eb' }
          ])
        },
        label: { show: true, position: 'right', color: '#1e293b', fontWeight: 700 },
        data: products.map((item) => item.subscriberCount)
      }]
    })
  }
}

const loadData = async () => {
  loading.value = true
  try {
    data.value = await getAdminDashboard()
    await renderCharts()
  } finally {
    loading.value = false
  }
}

const handleResize = () => {
  statusChart?.resize()
  topChart?.resize()
}

onMounted(() => {
  void loadData()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  statusChart?.dispose()
  topChart?.dispose()
  statusChart = null
  topChart = null
})
</script>

<template>
  <PageContainer>
    <div v-loading="loading" class="app-page admin-dashboard">
      <PageHeader title="管理后台" description="系统运营概览">
        <template #actions>
          <el-button plain :loading="loading" @click="loadData">刷新数据</el-button>
        </template>
      </PageHeader>

      <SectionCard title="运营概览">
        <div class="stat-grid">
          <StatCard v-for="item in summaryCards" :key="item.label" v-bind="item" />
        </div>
      </SectionCard>

      <div class="insight-grid">
        <div class="insight-panel insight-panel--blue">
          <div class="insight-panel__label">热门产品</div>
          <div class="insight-panel__value">{{ hottestProduct?.productName || '暂无订阅' }}</div>
          <div class="insight-panel__hint">
            {{ hottestProduct ? `${hottestProduct.subscriberCount} 人订阅，适合重点运营` : '等待用户产生订阅数据' }}
          </div>
        </div>
        <div class="insight-panel insight-panel--amber">
          <div class="insight-panel__label">审核压力</div>
          <div class="insight-panel__value">{{ reviewPressure }}%</div>
          <div class="insight-panel__hint">待审产品占全部产品比例</div>
        </div>
        <div class="insight-panel insight-panel--green">
          <div class="insight-panel__label">订阅效率</div>
          <div class="insight-panel__value">{{ avgSubscriptions }}</div>
          <div class="insight-panel__hint">平均每个已上架产品的订阅数</div>
        </div>
      </div>

      <div class="dashboard-grid">
        <SectionCard title="产品状态分布">
          <div ref="statusChartRef" class="chart-box" />
        </SectionCard>

        <SectionCard title="热门订阅排行">
          <div v-show="data.topSubscribedProducts.length > 0" ref="topChartRef" class="chart-box" />
          <el-empty v-if="data.topSubscribedProducts.length === 0" description="暂无订阅数据" />
        </SectionCard>
      </div>

      <SectionCard title="最近操作">
        <div v-if="data.recentChanges.length > 0" class="activity-list">
          <div v-for="item in data.recentChanges" :key="`${item.productId}-${item.actionType}-${item.createdAt}`" class="activity-item">
            <div class="activity-item__dot" />
            <div class="activity-item__body">
              <div class="activity-item__title">
                <span>{{ actionTypeLabel(item.actionType) }}</span>
                <strong>{{ item.productName }}</strong>
              </div>
              <div class="activity-item__meta">{{ item.operatorName }} · {{ item.createdAt }}</div>
            </div>
          </div>
        </div>
        <el-empty v-else description="暂无操作记录" />
      </SectionCard>
    </div>
  </PageContainer>
</template>

<style scoped>
.admin-dashboard {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.stat-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
  gap: 12px;
}

.insight-grid {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr;
  gap: 16px;
}

.insight-panel {
  min-height: 120px;
  padding: 18px 20px;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  background: var(--color-bg-card);
}

.insight-panel--blue {
  background: linear-gradient(135deg, rgba(37, 99, 235, 0.12), rgba(56, 189, 248, 0.1));
}

.insight-panel--amber {
  background: linear-gradient(135deg, rgba(245, 158, 11, 0.14), rgba(251, 191, 36, 0.08));
}

.insight-panel--green {
  background: linear-gradient(135deg, rgba(22, 163, 74, 0.12), rgba(45, 212, 191, 0.08));
}

.insight-panel__label {
  font-size: 12px;
  font-weight: 700;
  color: var(--color-text-2);
}

.insight-panel__value {
  margin-top: 10px;
  font-size: 26px;
  font-weight: 800;
  color: var(--color-text-1);
}

.insight-panel__hint {
  margin-top: 8px;
  font-size: 13px;
  line-height: 1.5;
  color: var(--color-text-2);
}

.dashboard-grid {
  display: grid;
  grid-template-columns: minmax(0, 0.9fr) minmax(0, 1.1fr);
  gap: 16px;
}

.chart-box {
  width: 100%;
  height: 340px;
}

.activity-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 12px;
}

.activity-item {
  display: flex;
  gap: 12px;
  min-height: 76px;
  padding: 14px 16px;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  background: var(--color-bg-card);
}

.activity-item__dot {
  width: 10px;
  height: 10px;
  margin-top: 5px;
  border-radius: 50%;
  background: var(--color-primary);
  box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.12);
}

.activity-item__body {
  min-width: 0;
}

.activity-item__title {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  font-size: 14px;
  color: var(--color-text-1);
}

.activity-item__title strong {
  font-weight: 700;
}

.activity-item__meta {
  margin-top: 6px;
  font-size: 12px;
  color: var(--color-text-3);
}

@media (max-width: 960px) {
  .insight-grid,
  .dashboard-grid {
    grid-template-columns: 1fr;
  }
}
</style>
