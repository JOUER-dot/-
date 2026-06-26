<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElNotification } from 'element-plus'
import { getUnreadCount, markAllAsRead } from '@/api/notification'

const router = useRouter()
const unreadCount = ref(0)
const prevCount = ref(0)
let pollTimer: ReturnType<typeof setInterval> | null = null

const displayCount = computed(() => (unreadCount.value > 99 ? '99+' : String(unreadCount.value)))

const fetchUnreadCount = async () => {
  try {
    const data = await getUnreadCount()
    prevCount.value = unreadCount.value
    unreadCount.value = data.count

    // New notification arrived: show toast
    if (data.count > prevCount.value && prevCount.value >= 0) {
      const newCount = data.count - prevCount.value
      ElNotification({
        title: '新消息',
        message: `您有 ${newCount} 条新通知`,
        type: 'info',
        duration: 4000,
        onClick: () => router.push('/notifications')
      })
    }
  } catch {
    // silent fail
  }
}

const handleClick = () => {
  router.push('/notifications')
}

onMounted(() => {
  prevCount.value = -1
  fetchUnreadCount()
  pollTimer = setInterval(fetchUnreadCount, 30000)
})

onUnmounted(() => {
  if (pollTimer) clearInterval(pollTimer)
})
</script>

<template>
  <div class="notification-bell" @click="handleClick">
    <el-badge :value="displayCount" :hidden="unreadCount === 0" :max="99">
      <el-button :icon="'Bell'" circle size="small" />
    </el-badge>
  </div>
</template>

<style scoped>
.notification-bell {
  cursor: pointer;
  display: flex;
  align-items: center;
}
</style>
