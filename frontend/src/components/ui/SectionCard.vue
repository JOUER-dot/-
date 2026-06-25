<script setup lang="ts">
defineProps<{
  title?: string
  subtitle?: string
}>()
</script>

<template>
  <el-card shadow="never" class="section-card">
    <template v-if="title" #header>
      <div class="header">
        <div class="header__title">{{ title }}</div>
        <div v-if="subtitle" class="header__subtitle">{{ subtitle }}</div>
      </div>
    </template>
    <slot />
  </el-card>
</template>

<style scoped>
.header {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.header__title {
  font-size: 16px;
  font-weight: 700;
  color: var(--color-text-1);
}

.header__subtitle {
  font-size: 12px;
  color: var(--color-text-2);
}
</style>
