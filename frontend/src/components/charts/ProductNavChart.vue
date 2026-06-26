<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import * as echarts from 'echarts'

import type { PublicProductNavPoint } from '@/api/public-product'

const props = defineProps<{
  title?: string
  data: PublicProductNavPoint[]
}>()

const chartRef = ref<HTMLDivElement>()
let chartInstance: echarts.ECharts | null = null

const ranges = [
  { label: '近1月', days: 30 },
  { label: '近3月', days: 90 },
  { label: '近6月', days: 180 },
  { label: '近1年', days: 365 },
  { label: '全部', days: 0 }
]
const activeRange = ref(0)

const filteredData = computed(() => {
  const days = ranges[activeRange.value].days
  if (days === 0) return props.data
  const cutoff = new Date()
  cutoff.setDate(cutoff.getDate() - days)
  return props.data.filter((p) => new Date(p.navDate) >= cutoff)
})

const isPositive = computed(() => {
  const d = filteredData.value
  if (d.length < 2) return true
  return Number(d[d.length - 1].nav) >= Number(d[0].nav)
})

const renderChart = async () => {
  await nextTick()
  if (!chartRef.value || filteredData.value.length === 0) return

  if (!chartInstance) chartInstance = echarts.init(chartRef.value)

  const dates = filteredData.value.map((i) => i.navDate)
  const navs = filteredData.value.map((i) => Number(i.nav))
  const returns = filteredData.value.map((i) => Number(i.cumReturn || 0))
  const lineColor = isPositive.value ? '#1e9e62' : '#c53b32'
  const areaColor = isPositive.value ? 'rgba(30,158,98,' : 'rgba(197,59,50,'

  chartInstance.setOption({
    tooltip: {
      trigger: 'axis',
      backgroundColor: 'rgba(255,255,255,0.95)',
      borderColor: '#e6eaf0',
      borderWidth: 1,
      textStyle: { color: '#243041', fontSize: 12 },
      formatter: (params: Array<{ value: number; axisValue: string }>) => {
        const p = params[0]
        const idx = dates.indexOf(p.axisValue)
        const cumRet = idx >= 0 ? returns[idx] : null
        let html = `<div style="font-weight:600;margin-bottom:4px">${p.axisValue}</div>`
        html += `<div>净值：<strong>${p.value.toFixed(4)}</strong></div>`
        if (cumRet !== null) {
          const cls = cumRet >= 0 ? 'color:#1e9e62' : 'color:#c53b32'
          html += `<div>累计收益：<strong style="${cls}">${(cumRet * 100).toFixed(2)}%</strong></div>`
        }
        return html
      }
    },
    grid: { left: 56, right: 20, top: 16, bottom: 32 },
    xAxis: {
      type: 'category',
      data: dates,
      boundaryGap: false,
      axisLine: { lineStyle: { color: '#e6eaf0' } },
      axisLabel: { color: '#8a94a3', fontSize: 11 },
      splitLine: { show: false }
    },
    yAxis: {
      type: 'value',
      scale: true,
      splitLine: { lineStyle: { color: '#f0f2f5', type: 'dashed' } },
      axisLabel: { color: '#8a94a3', fontSize: 11 }
    },
    dataZoom: [
      { type: 'inside', start: 0, end: 100, height: 8 }
    ],
    series: [{
      name: '单位净值',
      type: 'line',
      smooth: true,
      showSymbol: false,
      lineStyle: { width: 2.5, color: lineColor },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: areaColor + '0.25)' },
          { offset: 0.5, color: areaColor + '0.08)' },
          { offset: 1, color: areaColor + '0)' }
        ])
      },
      markLine: {
        silent: true,
        data: navs.length > 0 ? [{ yAxis: navs[navs.length - 1], label: { formatter: navs[navs.length - 1].toFixed(4), position: 'insideEndTop', fontSize: 11, color: lineColor } }] : [],
        lineStyle: { color: lineColor, type: 'dashed', opacity: 0.4 }
      },
      data: navs
    }]
  })
}

const handleRangeChange = (idx: number) => {
  activeRange.value = idx
  void renderChart()
}

const handleResize = () => chartInstance?.resize()

watch(() => props.data, () => void renderChart(), { deep: true })

onMounted(() => {
  void renderChart()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  chartInstance?.dispose()
  chartInstance = null
})
</script>

<template>
  <div class="nav-chart-wrap">
    <div class="nav-chart-header">
      <span class="nav-chart-title">{{ title || '净值走势' }}</span>
      <div class="nav-chart-ranges">
        <button v-for="(r, i) in ranges" :key="r.label"
          class="range-btn" :class="{ active: activeRange === i }"
          @click="handleRangeChange(i)">{{ r.label }}</button>
      </div>
    </div>
    <div ref="chartRef" class="nav-chart-body" />
  </div>
</template>

<style scoped>
.nav-chart-wrap {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-card);
  padding: 16px 16px 8px;
  background: var(--color-bg-card);
}
.nav-chart-header {
  display: flex; align-items: center; justify-content: space-between; gap: 12px;
  margin-bottom: 12px;
}
.nav-chart-title {
  font-size: 15px; font-weight: 700; color: var(--color-text-1);
}
.nav-chart-ranges {
  display: flex; gap: 4px;
}
.range-btn {
  padding: 4px 12px; border: 1px solid var(--color-border); border-radius: 14px;
  background: transparent; color: var(--color-text-3); font-size: 12px;
  cursor: pointer; transition: all .2s;
}
.range-btn:hover { border-color: var(--color-primary); color: var(--color-primary); }
.range-btn.active { border-color: var(--color-primary); background: var(--brand-50); color: var(--color-primary); font-weight: 600; }
.nav-chart-body { width: 100%; height: 340px; }
</style>
