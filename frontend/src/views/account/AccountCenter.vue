<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import PageHeader from '@/components/common/PageHeader.vue'

const router = useRouter()
const userStore = useUserStore()

const username = computed(() => userStore.userInfo?.username || '-')
const nickname = computed(() => userStore.userInfo?.nickname || '-')
const roles = computed(() => (userStore.roles.length > 0 ? userStore.roles.join('、') : '-'))

const summaryCards = computed(() => [
  { label: '用户名', value: username.value, hint: '登录凭证' },
  { label: '昵称', value: nickname.value, hint: '展示名称' },
  { label: '角色', value: roles.value, hint: '权限以后台为准' }
])

const handleLogout = async () => {
  await userStore.logout()
  await router.replace('/login')
}
</script>

<template>
  <div class="app-page">
    <PageHeader title="账号中心" description="查看当前登录账号信息，并提供快捷操作入口。">
      <template #actions>
        <el-button @click="router.push('/dashboard')">返回工作台</el-button>
        <el-button type="danger" @click="handleLogout">退出登录</el-button>
      </template>
    </PageHeader>

    <div class="summary-grid">
      <div v-for="item in summaryCards" :key="item.label" class="summary-card">
        <div class="summary-card__label">{{ item.label }}</div>
        <div class="summary-card__value">{{ item.value }}</div>
        <div class="summary-card__hint">{{ item.hint }}</div>
      </div>
    </div>

    <el-card shadow="never" class="section-card">
      <template #header>
        <div class="section-title">账号信息</div>
      </template>
      <el-descriptions :column="1" border>
        <el-descriptions-item label="用户名">{{ username }}</el-descriptions-item>
        <el-descriptions-item label="昵称">{{ nickname }}</el-descriptions-item>
        <el-descriptions-item label="角色">{{ roles }}</el-descriptions-item>
      </el-descriptions>
    </el-card>
  </div>
</template>

<style scoped>
.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}
</style>
