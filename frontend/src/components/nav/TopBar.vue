<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import { useUserStore } from '@/stores/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const title = computed(() => (typeof route.meta.title === 'string' ? route.meta.title : '智能投顾平台'))
const nickname = computed(() => userStore.userInfo?.nickname || userStore.userInfo?.username || '-')
const roleText = computed(() => (userStore.roles.length > 0 ? userStore.roles.join('、') : '-'))

const handleCommand = async (command: string) => {
  if (command === 'account') {
    await router.push('/account')
    return
  }
  if (command === 'logout') {
    await userStore.logout()
    await router.replace('/login')
  }
}
</script>

<template>
  <div class="topbar">
    <div class="title">{{ title }}</div>
    <div class="actions">
      <el-dropdown @command="handleCommand">
        <span class="user-entry">
          <el-avatar :size="28">{{ nickname.slice(0, 1) }}</el-avatar>
          <span class="user-name">{{ nickname }}</span>
          <el-tag size="small" effect="plain" class="user-role">{{ roleText }}</el-tag>
        </span>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item command="account">账号中心</el-dropdown-item>
            <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </div>
</template>

<style scoped>
.topbar {
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  border-bottom: 1px solid #ebeef5;
  background: #fff;
}

.title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.actions {
  display: flex;
  align-items: center;
}

.user-entry {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  color: #303133;
}

.user-name {
  font-weight: 600;
}

.user-role {
  border-color: #e5e7eb;
  color: #6b7280;
}
</style>
