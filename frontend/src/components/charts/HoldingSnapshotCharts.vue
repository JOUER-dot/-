<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import * as echarts from 'echarts'

interface HoldingComponentItem {
  fundCode: string
  fundName: string
  weight: number
}

const props = defineProps<{
  data: HoldingComponentItem[]
}>()

const donutChartRef = ref<HTMLDivElement>()
const barChartRef = ref<HTMLDivElement>()

let donutChartInstance: echarts.ECharts | null = null
let barChartInstance: echarts.ECharts | null = null

const sortedData = computed(() =>
  [...props.data]
    .filter((item) => Number.isFinite(Number(item.weight)))
    .sort((left, right) => Number(right.weight) - Number(left.weight))
)

const palette = ['#1f5c99', '#2f6bde', '#4d7fb3', '#67a5d6', '#8bbde5',
                 '#1e9e62', '#34b779', '#5cc995', '#d89b2b', '#e6b64a',
                 '#c53b32', '#e05a52', '#ad8846', '#8a94a3', '#5e6b7a']

const formatWeight = (value: number) => `${(value * 100).toFixed(2)}%`

const renderCharts = async () => {
  await nextTick()
  if (!donutChartRef.value || !barChartRef.value || sortedData.value.length === 0) return

  if (!donutChartInstance) donutChartInstance = echarts.init(donutChartRef.value)
  if (!barChartInstance) barChartInstance = echarts.init(barChartRef.value)

  const names = sortedData.value.map((item) => item.fundName)
  const weights = sortedData.value.map((item) => Number((item.weight * 100).toFixed(2)))

  donutChartInstance.setOption({
    tooltip: {
      trigger: 'item',
      backgroundColor: 'rgba(255,255,255,0.95)',
      borderColor: '#e6eaf0',
      borderWidth: 1,
      textStyle: { color: '#243041', fontSize: 12 },
      formatter: (params: { name: string; value: number; percent: number }) =>
        `${params.name}<br/>权重：<strong>${params.value.toFixed(2)}%</strong><br/>占比：${params.percent.toFixed(1)}%`
    },
    series: [{
      name: '持仓权重',
      type: 'pie',
      radius: ['42%', '68%'],
      center: ['50%', '48%'],
      avoidLabelOverlap: true,
      padAngle: 2,
      itemStyle: { borderRadius: 6, borderColor: '#fff', borderWidth: 2 },
      label: {
        show: true,
        formatter: '{b|{b}}\n{d|{d}%}',
        rich: {
          b: { fontSize: 11, color: '#243041', fontWeight: 600, lineHeight: 18 },
          d: { fontSize: 10, color: '#8a94a3', lineHeight: 16 }
        }
      },
      emphasis: {
        itemStyle: { shadowBlur: 10, shadowOffsetX: 0, shadowColor: 'rgba(0,0,0,0.2)' }
      },
      data: sortedData.value.map((item, idx) => ({
        name: item.fundName,
        value: Number((item.weight * 100).toFixed(2)),
        itemStyle: { color: palette[idx % palette.length] }
      }))
    }]
  })

  barChartInstance.setOption({
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'shadow' },
      backgroundColor: 'rgba(255,255,255,0.95)',
      borderColor: '#e6eaf0',
      borderWidth: 1,
      textStyle: { color: '#243041', fontSize: 12 },
      formatter: (params: Array<{ name: string; value: number }>) => {
        const item = params[0]
        return `${item.name}<br/>权重：<strong>${item.value.toFixed(2)}%</strong>`
      }
    },
    grid: { left: 24, right: 40, top: 12, bottom: 8, containLabel: true },
    xAxis: {
      type: 'value',
      axisLabel: { formatter: '{value}%', color: '#8a94a3', fontSize: 11 },
      splitLine: { lineStyle: { color: '#f0f2f5', type: 'dashed' } }
    },
    yAxis: {
      type: 'category',
      data: names,
      axisLine: { show: false },
      axisTick: { show: false },
      axisLabel: { color: '#243041', fontSize: 12, fontWeight: 600 }
    },
    series: [{
      name: '持仓权重',
      type: 'bar',
      data: weights.map((v, i) => ({
        value: v,
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
            { offset: 0, color: palette[i % palette.length] },
            { offset: 1, color: palette[i % palette.length] + '99' }
          ]),
          borderRadius: [0, 6, 6, 0]
        }
      })),
      barWidth: 20,
      label: {
        show: true,
        position: 'right',
        formatter: ({ value }: { value: number }) => `${value.toFixed(2)}%`,
        fontSize: 11,
        color: '#5e6b7a',
        fontWeight: 600
      }
    }]
  })
}

const handleResize = () => {
  donutChartInstance?.resize()
  barChartInstance?.resize()
}

watch(
  () => props.data,
  () => {
    if (sortedData.value.length === 0) {
      donutChartInstance?.clear()
      barChartInstance?.clear()
      return
    }
    void renderCharts()
  },
  { deep: true }
)

onMounted(() => {
  void renderCharts()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  donutChartInstance?.dispose()
  barChartInstance?.dispose()
  donutChartInstance = null
  barChartInstance = null
})

defineExpose({
  sortedData,
  formatWeight
})
</script>

<template>
  <div class="snapshot-layout">
    <div ref="donutChartRef" class="chart-panel donut-chart" />
    <div ref="barChartRef" class="chart-panel bar-chart" />
  </div>
</template>

<style scoped>
.snapshot-layout {
  display: grid;
  grid-template-columns: minmax(280px, 420px) minmax(360px, 1fr);
  gap: 16px;
}

.chart-panel {
  width: 100%;
  min-height: 360px;
  border-radius: 12px;
  background: #f7f8fa;
}

.donut-chart {
  height: 360px;
}

.bar-chart {
  height: 360px;
}

@media (max-width: 992px) {
  .snapshot-layout {
    grid-template-columns: 1fr;
  }
}
</style>
