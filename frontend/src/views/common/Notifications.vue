<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import PageHeader from '@/components/common/PageHeader.vue'
import PageContainer from '@/components/ui/PageContainer.vue'
import { getNotifications, markAsRead, markAllAsRead, type NotificationItem } from '@/api/notification'

const router = useRouter()
const loading = ref(false)
const records = ref<NotificationItem[]>([])

const pager = reactive({
  pageNum: 1,
  pageSize: 20,
  total: 0
})

const loadData = async () => {
  loading.value = true
  try {
    const data = await getNotifications(pager.pageNum, pager.pageSize)
    records.value = data
    pager.total = data.length
  } finally {
    loading.value = false
  }
}

const handleRead = async (item: NotificationItem) => {
  if (!item.read) {
    try {
      await markAsRead(item.id)
      item.read = true
    } catch {
      // silent
    }
  }
  if (item.relatedUrl) {
    router.push(item.relatedUrl)
  }
}

const handleMarkAllRead = async () => {
  try {
    await markAllAsRead()
    records.value.forEach((item) => (item.read = true))
    ElMessage.success('全部标记为已读')
  } catch {
    ElMessage.error('操作失败')
  }
}

const typeLabel = (type: string) => {
  const map: Record<string, string> = {
    REVIEW_RESULT: '审核结果',
    SUBSCRIPTION: '订阅通知',
    SYSTEM: '系统消息'
  }
  return map[type] || type
}

onMounted(() => {
  loadData()
})
</script>

<template>
  <PageContainer>
    <div class="app-page">
      <PageHeader title="消息通知" description="查看系统通知和提醒。">
        <template #actions>
          <el-button v-if="records.some((n) => !n.read)" @click="handleMarkAllRead">全部标为已读</el-button>
        </template>
      </PageHeader>

      <div class="notification-list">
        <el-empty v-if="!loading && records.length === 0" description="暂无通知" />
        <div v-for="item in records" :key="item.id" class="notification-item" :class="{ 'notification-item--unread': !item.read }" @click="handleRead(item)">
          <div class="notification-item__dot" v-if="!item.read" />
          <div class="notification-item__body">
            <div class="notification-item__header">
              <span class="notification-item__title">{{ item.title }}</span>
              <el-tag size="small" effect="plain">{{ typeLabel(item.type) }}</el-tag>
            </div>
            <div class="notification-item__content">{{ item.content }}</div>
            <div class="notification-item__time">{{ item.createdAt }}</div>
          </div>
        </div>
      </div>
    </div>
  </PageContainer>
</template>

<style scoped>
.notification-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.notification-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 16px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-card);
  background: var(--color-bg-card);
  cursor: pointer;
  transition: background-color 0.2s;
}

.notification-item:hover {
  background: var(--color-bg-muted);
}

.notification-item--unread {
  border-left: 3px solid var(--color-primary);
  background: var(--brand-50);
}

.notification-item__dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--color-primary);
  flex-shrink: 0;
  margin-top: 6px;
}

.notification-item__body {
  flex: 1;
  min-width: 0;
}

.notification-item__header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 6px;
}

.notification-item__title {
  font-weight: 600;
  color: var(--color-text-1);
}

.notification-item__content {
  color: var(--color-text-2);
  font-size: 13px;
  line-height: 1.6;
}

.notification-item__time {
  margin-top: 8px;
  color: var(--color-text-3);
  font-size: 12px;
}
</style>
