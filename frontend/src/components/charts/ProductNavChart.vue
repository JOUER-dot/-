<script setup lang="ts">
import { nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import * as echarts from 'echarts'

import type { PublicProductNavPoint } from '@/api/public-product'

const props = defineProps<{
  title?: string
  data: PublicProductNavPoint[]
}>()

const chartRef = ref<HTMLDivElement>()
let chartInstance: echarts.ECharts | null = null

const renderChart = async () => {
  await nextTick()
  if (!chartRef.value) {
    return
  }

  if (!chartInstance) {
    chartInstance = echarts.init(chartRef.value)
  }

  chartInstance.setOption({
    title: {
      text: props.title || '净值走势',
      left: 'center',
      textStyle: {
        fontSize: 16,
        fontWeight: 600,
        color: '#303133'
      }
    },
    tooltip: {
      trigger: 'axis'
    },
    grid: {
      left: 48,
      right: 24,
      top: 56,
      bottom: 40
    },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: props.data.map((item) => item.navDate)
    },
    yAxis: {
      type: 'value',
      scale: true
    },
    series: [
      {
        name: '单位净值',
        type: 'line',
        smooth: true,
        showSymbol: false,
        lineStyle: {
          width: 3,
          color: '#409eff'
        },
        areaStyle: {
          color: 'rgba(64, 158, 255, 0.15)'
        },
        data: props.data.map((item) => item.nav)
      }
    ]
  })
}

const handleResize = () => {
  chartInstance?.resize()
}

watch(
  () => props.data,
  () => {
    void renderChart()
  },
  { deep: true }
)

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
  <div ref="chartRef" class="chart-container" />
</template>

<style scoped>
.chart-container {
  width: 100%;
  height: 360px;
}
</style>
