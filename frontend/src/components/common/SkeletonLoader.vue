<script setup lang="ts">
defineProps<{
  rows?: number
  type?: 'card' | 'table' | 'text'
}>()
</script>

<template>
  <div v-if="type === 'card'" class="skeleton-grid">
    <div v-for="i in (rows || 6)" :key="i" class="skeleton-card">
      <div class="sk-block sk-h-20 sk-w-60" />
      <div class="sk-block sk-h-14 sk-w-40" style="margin-top:12px" />
      <div class="sk-block sk-h-14 sk-w-80" style="margin-top:8px" />
      <div style="margin-top:16px;display:flex;gap:8px">
        <div class="sk-block sk-h-10 sk-w-24" />
        <div class="sk-block sk-h-10 sk-w-20" />
      </div>
    </div>
  </div>
  <div v-else-if="type === 'table'" class="skeleton-table">
    <div v-for="i in (rows || 5)" :key="i" class="sk-row">
      <div class="sk-block sk-h-16 sk-w-full" />
    </div>
  </div>
  <div v-else class="skeleton-text">
    <div v-for="i in (rows || 3)" :key="i" class="sk-block sk-h-14 sk-w-full" style="margin-bottom:12px" />
  </div>
</template>

<style scoped>
.skeleton-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 14px;
}
.skeleton-card {
  padding: 20px;
  border: 1px solid var(--color-border);
  border-radius: 14px;
  background: var(--color-bg-card);
}
.skeleton-table {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.sk-row {
  padding: 12px 16px;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  background: var(--color-bg-card);
}
.sk-block {
  background: linear-gradient(90deg, var(--gray-100) 25%, var(--gray-200) 50%, var(--gray-100) 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 6px;
}
.sk-h-10 { height: 10px; }
.sk-h-14 { height: 14px; }
.sk-h-16 { height: 16px; }
.sk-h-20 { height: 20px; }
.sk-w-20 { width: 20%; }
.sk-w-24 { width: 24%; }
.sk-w-40 { width: 40%; }
.sk-w-60 { width: 60%; }
.sk-w-80 { width: 80%; }
.sk-w-full { width: 100%; }
@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
</style>
