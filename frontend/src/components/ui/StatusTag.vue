<script setup lang="ts">
import { computed } from 'vue'

import {
  productStatusLabel,
  productStatusTagType,
  subscriptionStatusLabel,
  subscriptionStatusTagType
} from '@/utils/status'

const props = defineProps<{
  kind: 'product' | 'subscription'
  value: string
}>()

const tagType = computed(() => {
  if (props.kind === 'product') {
    return productStatusTagType(props.value)
  }
  return subscriptionStatusTagType(props.value)
})

const label = computed(() => {
  if (props.kind === 'product') {
    return productStatusLabel(props.value)
  }
  return subscriptionStatusLabel(props.value)
})
</script>

<template>
  <el-tag :type="tagType" effect="plain">
    {{ label }}
  </el-tag>
</template>
