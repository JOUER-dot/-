<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  maxWidth?: number
}>()

const maxWidthCss = computed(() => (props.maxWidth ? `${props.maxWidth}px` : 'var(--container-max)'))
</script>

<template>
  <div class="page-container">
    <slot />
  </div>
</template>

<style scoped>
.page-container {
  max-width: v-bind(maxWidthCss);
  margin: 0 auto;
}
</style>
