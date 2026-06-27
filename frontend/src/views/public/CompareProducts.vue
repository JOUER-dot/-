<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import * as echarts from 'echarts'

import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import { getPublishedProductDetail, type PublicProductDetail } from '@/api/public-product'
import { formatDecimal, formatPercent, formatText } from '@/utils/format'
import { productTypeLabel } from '@/utils/status'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const products = ref<PublicProductDetail[]>([])
const chartRef = ref<HTMLDivElement>()
let chartInstance: echarts.ECharts | null = null

const productIds = (route.query.ids as string || '').split(',').filter(Boolean).map(Number)

const loadAll = async () => {
  loading.value = true
  try {
    const results = await Promise.all(productIds.map((id) => getPublishedProductDetail(id)))
    products.value = results
  } finally { loading.value = false }
}

const latestNav = (p: PublicProductDetail) => {
  const last = p.navList?.[p.navList.length - 1]
  return last ? formatDecimal(last.nav) : '-'
}

const latestReturn = (p: PublicProductDetail) => {
  const last = p.navList?.[p.navList.length - 1]
  return last && last.cumReturn ? formatPercent(last.cumReturn) : '-'
}

onMounted(() => {
  if (productIds.length < 2) { router.replace('/advisor-zone'); return }
  loadAll()
})
</script>

<template>
  <PageContainer>
    <div class="compare-page">
      <div class="compare-nav">
        <el-button link @click="router.push('/advisor-zone')">← 返回产品列表</el-button>
        <span class="compare-title">产品对比（{{ products.length }} 个）</span>
      </div>

      <!-- 基本信息对比 -->
      <SectionCard title="基本信息">
        <el-table :data="products" border>
          <el-table-column label="属性" width="120">
            <template #default>名称</template>
          </el-table-column>
          <el-table-column v-for="p in products" :key="p.id" :label="p.name">
            <template #default>
              <div>
                <div class="ci-name">{{ p.name }}</div>
                <div class="ci-meta">
                  <span>{{ productTypeLabel(p.type) }} / {{ p.riskLevel }}</span>
                  <span v-if="p.strategyCode"> / {{ p.strategyCode }}</span>
                </div>
                <div class="ci-meta">V{{ p.versionNo }}</div>
              </div>
            </template>
          </el-table-column>
        </el-table>
      </SectionCard>

      <!-- 关键指标 -->
      <SectionCard title="关键指标">
        <el-table :data="['最新净值', '累计收益', '基金成份']" border>
          <el-table-column label="指标" width="120">
            <template #default="{ row }">{{ row }}</template>
          </el-table-column>
          <el-table-column v-for="p in products" :key="p.id">
            <template #default="{ row }">
              <span v-if="row === '最新净值'">{{ latestNav(p) }}</span>
              <span v-else-if="row === '累计收益'" :class="Number(p.navList?.[p.navList.length - 1]?.cumReturn) >= 0 ? 'up' : 'down'">{{ latestReturn(p) }}</span>
              <span v-else>{{ p.components?.length || 0 }} 只</span>
            </template>
          </el-table-column>
        </el-table>
      </SectionCard>

      <!-- 基金成份 -->
      <SectionCard title="基金成份">
        <el-table :data="products" border>
          <el-table-column label="产品" width="120">
            <template #default="{ row }">{{ row.name }}</template>
          </el-table-column>
          <el-table-column v-for="p in products" :key="p.id" :label="p.name">
            <template #default>
              <div v-for="c in p.components" :key="c.fundId" class="ci-comp">
                <span class="ci-comp-name">{{ c.fundName }}</span>
                <span class="ci-comp-wt">{{ formatPercent(c.weight) }}</span>
              </div>
              <span v-if="!p.components?.length" class="text-dim">无数据</span>
            </template>
          </el-table-column>
        </el-table>
      </SectionCard>
    </div>
  </PageContainer>
</template>

<style scoped>
.compare-page { display: flex; flex-direction: column; gap: 16px; }
.compare-nav { display: flex; align-items: center; gap: 16px; }
.compare-title { font-size: 18px; font-weight: 700; color: var(--color-text-1); }
.ci-name { font-weight: 700; font-size: 15px; color: var(--color-text-1); }
.ci-meta { font-size: 12px; color: var(--color-text-3); margin-top: 2px; }
.ci-comp { display: flex; justify-content: space-between; gap: 8px; padding: 3px 0; border-bottom: 1px solid var(--color-border); font-size: 13px; }
.ci-comp:last-child { border-bottom: none; }
.ci-comp-name { color: var(--color-text-1); }
.ci-comp-wt { color: var(--color-text-2); font-weight: 600; }
.up { color: var(--danger-600); font-weight: 700; }
.down { color: var(--success-600); font-weight: 700; }
.text-dim { color: var(--color-text-3); }
</style>
