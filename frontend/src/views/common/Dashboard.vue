<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

onMounted(() => {
  if (userStore.hasAnyRole(['ADVISOR'])) {
    router.replace('/admin/products')
  } else if (userStore.hasAnyRole(['REVIEWER'])) {
    router.replace('/review/pending')
  } else if (userStore.hasAnyRole(['ADMIN'])) {
    router.replace('/admin/dashboard')
  } else {
    router.replace('/my/dashboard')
  }
})
</script>

<template>
  <div class="redirecting">正在跳转...</div>
</template>

<style scoped>
.redirecting {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 200px;
  color: var(--color-text-3);
  font-size: 14px;
}
</style>
