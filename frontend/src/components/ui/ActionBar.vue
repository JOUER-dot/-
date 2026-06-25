<script setup lang="ts">
defineProps<{
  title?: string
  subtitle?: string
}>()
</script>

<template>
  <div class="action-bar">
    <div class="action-bar__inner">
      <div class="action-bar__title">
        <strong v-if="title">{{ title }}</strong>
        <span v-if="subtitle">{{ subtitle }}</span>
      </div>
      <div class="action-bar__actions">
        <slot />
      </div>
    </div>
  </div>
</template>

<style scoped>
.action-bar {
  position: sticky;
  bottom: 0;
  z-index: 20;
  padding: 12px;
  border: 1px solid var(--color-border);
  background: rgba(255, 255, 255, 0.92);
  backdrop-filter: blur(12px);
  border-radius: calc(var(--radius-card) + 2px);
}

.action-bar__inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.action-bar__title {
  min-width: 0;
}

.action-bar__title strong {
  display: block;
  color: var(--color-text-1);
  font-size: 16px;
  line-height: 22px;
}

.action-bar__title span {
  display: block;
  color: var(--color-text-2);
  font-size: 12px;
  line-height: 18px;
}

.action-bar__actions {
  display: flex;
  flex-wrap: wrap;
  justify-content: flex-end;
  gap: 8px;
}
</style>
