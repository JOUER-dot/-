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

const formatWeight = (value: number) => `${(value * 100).toFixed(2)}%`

const renderCharts = async () => {
  await nextTick()
  if (!donutChartRef.value || !barChartRef.value || sortedData.value.length === 0) {
    return
  }

  if (!donutChartInstance) {
    donutChartInstance = echarts.init(donutChartRef.value)
  }
  if (!barChartInstance) {
    barChartInstance = echarts.init(barChartRef.value)
  }

  const names = sortedData.value.map((item) => item.fundName)
  const weights = sortedData.value.map((item) => Number((item.weight * 100).toFixed(2)))

  donutChartInstance.setOption({
    title: {
      text: '权重分布',
      left: 'center',
      top: 8,
      textStyle: {
        fontSize: 16,
        fontWeight: 600,
        color: '#303133'
      }
    },
    tooltip: {
      trigger: 'item',
      formatter: (params: { name: string; value: number }) => `${params.name}<br/>权重：${params.value.toFixed(2)}%`
    },
    legend: {
      bottom: 0,
      left: 'center',
      icon: 'circle'
    },
    series: [
      {
        name: '持仓权重',
        type: 'pie',
        radius: ['45%', '70%'],
        center: ['50%', '48%'],
        avoidLabelOverlap: true,
        itemStyle: {
          borderRadius: 8,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          formatter: '{d}%'
        },
        data: sortedData.value.map((item) => ({
          name: item.fundName,
          value: Number((item.weight * 100).toFixed(2))
        }))
      }
    ]
  })

  barChartInstance.setOption({
    title: {
      text: '持仓排序',
      left: 'center',
      top: 8,
      textStyle: {
        fontSize: 16,
        fontWeight: 600,
        color: '#303133'
      }
    },
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      },
      formatter: (params: Array<{ name: string; value: number }>) => {
        const item = params[0]
        return `${item.name}<br/>权重：${item.value.toFixed(2)}%`
      }
    },
    grid: {
      left: 24,
      right: 32,
      top: 56,
      bottom: 24,
      containLabel: true
    },
    xAxis: {
      type: 'value',
      axisLabel: {
        formatter: '{value}%'
      }
    },
    yAxis: {
      type: 'category',
      data: names
    },
    series: [
      {
        name: '持仓权重',
        type: 'bar',
        data: weights,
        barWidth: 18,
        label: {
          show: true,
          position: 'right',
          formatter: ({ value }: { value: number }) => `${value.toFixed(2)}%`
        },
        itemStyle: {
          borderRadius: [0, 8, 8, 0],
          color: new echarts.graphic.LinearGradient(1, 0, 0, 0, [
            { offset: 0, color: '#67C23A' },
            { offset: 1, color: '#95D475' }
          ])
        }
      }
    ]
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
