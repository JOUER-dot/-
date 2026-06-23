<script setup lang="ts">
import { computed, ref } from 'vue'
import { ElMessage } from 'element-plus'

import FundSelectDialog from '@/components/product/FundSelectDialog.vue'
import { mapFundToComponent, type ProductComponentItem } from '@/api/product'
import type { FundOption } from '@/api/fund'

const props = defineProps<{
  modelValue: ProductComponentItem[]
  readOnly?: boolean
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: ProductComponentItem[]): void
}>()

const dialogVisible = ref(false)

const components = computed({
  get: () => props.modelValue,
  set: (value: ProductComponentItem[]) => emit('update:modelValue', value)
})

const selectedFunds = computed<FundOption[]>(() =>
  components.value.map((item) => ({
    id: item.fundId,
    fundCode: item.fundCode || '',
    fundName: item.fundName || '',
    fundType: item.fundType || '',
    riskLevel: item.riskLevel || '',
    companyName: item.companyName || '',
    status: 1
  }))
)

const totalWeight = computed(() =>
  components.value.reduce((sum, item) => sum + Number(item.weight || 0), 0)
)

const weightClass = computed(() =>
  Math.abs(totalWeight.value - 1) < 0.000001 ? 'weight-ok' : 'weight-error'
)

const handleSelectFunds = (funds: FundOption[]) => {
  const currentMap = new Map(components.value.map((item) => [item.fundId, item]))
  const next = funds.map((fund) => {
    const current = currentMap.get(fund.id)
    if (current) {
      return {
        ...current,
        fundCode: fund.fundCode,
        fundName: fund.fundName,
        fundType: fund.fundType,
        riskLevel: fund.riskLevel,
        companyName: fund.companyName
      }
    }
    return mapFundToComponent(fund)
  })
  components.value = next
}

const handleDelete = (fundId: number) => {
  components.value = components.value.filter((item) => item.fundId !== fundId)
}

const handleNormalizeWeights = () => {
  if (components.value.length === 0) {
    ElMessage.warning('请先选择基金')
    return
  }
  const evenWeight = Number((1 / components.value.length).toFixed(4))
  const next = components.value.map((item, index) => {
    if (index === components.value.length - 1) {
      const subtotal = components.value
        .slice(0, index)
        .reduce((sum, current) => sum + Number((current.weight ?? evenWeight).toFixed(4)), 0)
      return { ...item, weight: Number((1 - subtotal).toFixed(4)) }
    }
    return { ...item, weight: evenWeight }
  })
  components.value = next
}
</script>

<template>
  <el-card shadow="never" class="section-card">
    <template #header>
      <div class="section-header">
        <div class="section-title">基金成份</div>
        <div class="section-actions" v-if="!readOnly">
          <el-button @click="dialogVisible = true">选择基金</el-button>
          <el-button @click="handleNormalizeWeights">平均分配权重</el-button>
        </div>
      </div>
    </template>

    <div class="weight-summary">
      权重合计：
      <span :class="weightClass">{{ totalWeight.toFixed(4) }}</span>
      <span class="summary-tip">提交审核前必须等于 1.0000</span>
    </div>

    <el-empty v-if="components.length === 0" description="暂未添加基金成份" />

    <el-table v-else :data="components" border>
      <el-table-column prop="fundCode" label="基金代码" min-width="120" />
      <el-table-column prop="fundName" label="基金名称" min-width="180" />
      <el-table-column prop="fundType" label="基金类型" min-width="120" />
      <el-table-column prop="riskLevel" label="风险等级" min-width="100" />
      <el-table-column label="权重" min-width="160">
        <template #default="{ row }">
          <el-input-number
            v-model="row.weight"
            :disabled="readOnly"
            :min="0"
            :max="1"
            :step="0.01"
            :precision="4"
            controls-position="right"
          />
        </template>
      </el-table-column>
      <el-table-column v-if="!readOnly" label="操作" width="100" fixed="right">
        <template #default="{ row }">
          <el-button type="danger" link @click="handleDelete(row.fundId)">移除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <FundSelectDialog
      v-model="dialogVisible"
      :selected-funds="selectedFunds"
      @confirm="handleSelectFunds"
    />
  </el-card>
</template>

<style scoped>
.section-card {
  margin-bottom: 16px;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.section-actions {
  display: flex;
  gap: 8px;
}

.weight-summary {
  margin-bottom: 12px;
  color: #606266;
}

.summary-tip {
  margin-left: 8px;
  color: #909399;
}

.weight-ok {
  color: #67c23a;
  font-weight: 600;
}

.weight-error {
  color: #f56c6c;
  font-weight: 600;
}
</style>
