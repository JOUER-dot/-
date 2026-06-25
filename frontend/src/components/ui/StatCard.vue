<script setup lang="ts">
defineProps<{
  label: string
  value: string
  hint?: string
}>()
</script>

<template>
  <div class="stat-card">
    <div class="stat-card__label">{{ label }}</div>
    <div class="stat-card__value">{{ value }}</div>
    <div v-if="hint" class="stat-card__hint">{{ hint }}</div>
  </div>
</template>

<style scoped>
.stat-card {
  background: linear-gradient(180deg, var(--color-bg-card) 0%, #f8fafc 100%);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-card);
  padding: 18px 20px;
}

.stat-card__label {
  color: var(--color-text-2);
  font-size: 13px;
  line-height: 20px;
}

.stat-card__value {
  margin-top: 10px;
  color: var(--color-text-1);
  font-size: 26px;
  line-height: 32px;
  font-weight: 700;
}

.stat-card__hint {
  margin-top: 8px;
  color: var(--color-text-2);
  font-size: 12px;
  line-height: 18px;
}
</style>
