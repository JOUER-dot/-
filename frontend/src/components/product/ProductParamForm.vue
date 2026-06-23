<script setup lang="ts">
import { computed } from 'vue'

type ProductParamModel = {
  rebalanceCycleDays: number | null
  minSingleFundWeight: number | null
  maxSingleFundWeight: number | null
  investHorizonMonths: number | null
  strategyNotes: string
}

const props = defineProps<{
  modelValue: ProductParamModel
  readOnly?: boolean
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: ProductParamModel): void
}>()

const formModel = computed({
  get: () => props.modelValue,
  set: (value: ProductParamModel) => emit('update:modelValue', value)
})
</script>

<template>
  <el-card shadow="never" class="section-card">
    <template #header>
      <div class="section-title">策略参数</div>
    </template>

    <el-form label-position="top">
      <el-row :gutter="16">
        <el-col :span="6">
          <el-form-item label="调仓周期（天）">
            <el-input-number
              v-model="formModel.rebalanceCycleDays"
              :disabled="readOnly"
              :min="1"
              :max="365"
              controls-position="right"
            />
          </el-form-item>
        </el-col>
        <el-col :span="6">
          <el-form-item label="单基金最小权重">
            <el-input-number
              v-model="formModel.minSingleFundWeight"
              :disabled="readOnly"
              :min="0"
              :max="1"
              :precision="4"
              :step="0.01"
              controls-position="right"
            />
          </el-form-item>
        </el-col>
        <el-col :span="6">
          <el-form-item label="单基金最大权重">
            <el-input-number
              v-model="formModel.maxSingleFundWeight"
              :disabled="readOnly"
              :min="0"
              :max="1"
              :precision="4"
              :step="0.01"
              controls-position="right"
            />
          </el-form-item>
        </el-col>
        <el-col :span="6">
          <el-form-item label="建议持有期（月）">
            <el-input-number
              v-model="formModel.investHorizonMonths"
              :disabled="readOnly"
              :min="1"
              :max="120"
              controls-position="right"
            />
          </el-form-item>
        </el-col>
      </el-row>

      <el-form-item label="策略说明">
        <el-input
          v-model="formModel.strategyNotes"
          :disabled="readOnly"
          type="textarea"
          :rows="3"
          maxlength="500"
          show-word-limit
        />
      </el-form-item>
    </el-form>
  </el-card>
</template>

<style scoped>
.section-card {
  margin-bottom: 16px;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}
</style>
