<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'

import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

const isLoggedIn = computed(() => userStore.isLoggedIn)
const nickname = computed(() => userStore.userInfo?.nickname || userStore.userInfo?.username || '-')

const handleGoLogin = async () => {
  await router.push('/login')
}

const handleGoRegister = async () => {
  await router.push('/register')
}

const handleGoZone = async () => {
  await router.push('/advisor-zone')
}

const handleGoDashboard = async () => {
  await router.push('/dashboard')
}

const handleLogout = async () => {
  await userStore.logout()
  await router.replace('/login')
}
</script>

<template>
  <div class="public-shell">
    <header class="public-header">
      <div class="brand" @click="handleGoZone">
        <span class="brand__mark" />
        <span class="brand__text">智能投顾</span>
      </div>
      <div class="nav">
        <el-button link @click="handleGoZone">产品专区</el-button>
        <template v-if="!isLoggedIn">
          <el-button @click="handleGoLogin">登录</el-button>
          <el-button type="primary" @click="handleGoRegister">注册</el-button>
        </template>
        <template v-else>
          <el-dropdown>
            <span class="user-entry">
              <el-avatar :size="28">{{ nickname.slice(0, 1) }}</el-avatar>
              <span class="user-name">{{ nickname }}</span>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="handleGoDashboard">进入工作台</el-dropdown-item>
                <el-dropdown-item divided @click="handleLogout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </template>
      </div>
    </header>
    <main class="public-main">
      <router-view />
    </main>
  </div>
</template>

<style scoped>
.public-shell {
  min-height: 100vh;
  background: var(--color-bg-page);
}

.public-header {
  position: sticky;
  top: 0;
  z-index: 30;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 0 18px;
  height: 64px;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(14px);
  border-bottom: 1px solid var(--color-border);
}

.brand {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  user-select: none;
}

.brand__mark {
  width: 12px;
  height: 12px;
  border-radius: 6px;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-hover) 100%);
}

.brand__text {
  font-weight: 800;
  color: var(--color-text-1);
  letter-spacing: 0.4px;
}

.nav {
  display: inline-flex;
  align-items: center;
  gap: 10px;
}

.user-entry {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  color: var(--color-text-1);
}

.user-name {
  font-weight: 700;
}

.public-main {
  padding: 24px 16px;
}
</style>
