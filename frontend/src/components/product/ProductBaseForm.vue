<script setup lang="ts">
import { computed } from 'vue'

import { productTypeOptions } from '@/utils/status'

type ProductBaseModel = {
  name: string
  type: string
  riskLevel: string
  strategyCode: string
  featureTags: string[]
  baseInfo: {
    productSummary: string
    targetCustomer: string
    riskTips: string
  }
}

const props = defineProps<{
  modelValue: ProductBaseModel
  readOnly?: boolean
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: ProductBaseModel): void
}>()

const formModel = computed({
  get: () => props.modelValue,
  set: (value: ProductBaseModel) => emit('update:modelValue', value)
})

const typeOptions = productTypeOptions()
const riskOptions = ['R1', 'R2', 'R3', 'R4', 'R5']
const featureTagOptions = ['固收增强', '权益增强', '低波动', '长期持有', '养老规划', '现金管理']
</script>

<template>
  <el-card shadow="never" class="section-card">
    <template #header>
      <div class="section-title">基础信息</div>
    </template>

    <el-form label-position="top">
      <el-row :gutter="16">
        <el-col :span="12">
          <el-form-item label="产品名称" required>
            <el-input v-model="formModel.name" :disabled="readOnly" maxlength="100" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="产品类型" required>
            <el-select v-model="formModel.type" :disabled="readOnly" placeholder="请选择产品类型">
              <el-option v-for="item in typeOptions" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>

      <el-row :gutter="16">
        <el-col :span="8">
          <el-form-item label="风险等级" required>
            <el-select v-model="formModel.riskLevel" :disabled="readOnly" placeholder="请选择风险等级">
              <el-option v-for="item in riskOptions" :key="item" :label="item" :value="item" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="策略编码">
            <el-input v-model="formModel.strategyCode" :disabled="readOnly" maxlength="50" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="产品标签">
            <el-select
              v-model="formModel.featureTags"
              multiple
              collapse-tags
              :disabled="readOnly"
              placeholder="请选择产品标签"
            >
              <el-option
                v-for="item in featureTagOptions"
                :key="item"
                :label="item"
                :value="item"
              />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>

      <el-form-item label="产品简介">
        <el-input
          v-model="formModel.baseInfo.productSummary"
          :disabled="readOnly"
          type="textarea"
          :rows="3"
          maxlength="500"
          show-word-limit
        />
      </el-form-item>

      <el-row :gutter="16">
        <el-col :span="12">
          <el-form-item label="目标客户">
            <el-input
              v-model="formModel.baseInfo.targetCustomer"
              :disabled="readOnly"
              type="textarea"
              :rows="3"
              maxlength="300"
              show-word-limit
            />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="风险提示">
            <el-input
              v-model="formModel.baseInfo.riskTips"
              :disabled="readOnly"
              type="textarea"
              :rows="3"
              maxlength="300"
              show-word-limit
            />
          </el-form-item>
        </el-col>
      </el-row>
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
