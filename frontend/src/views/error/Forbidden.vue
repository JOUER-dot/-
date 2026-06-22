<script setup lang="ts">
import { useRouter } from 'vue-router'

import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()
</script>

<template>
  <div class="forbidden-page">
    <div class="forbidden-card">
      <div class="forbidden-code">403</div>
      <h1>无权限访问</h1>
      <p>当前角色没有访问该页面或功能的权限，请返回首页或切换账号后重试。</p>
      <div class="actions">
        <el-button type="primary" @click="router.push(userStore.isLoggedIn ? '/' : '/login')">
          {{ userStore.isLoggedIn ? '返回首页' : '去登录' }}
        </el-button>
        <el-button v-if="userStore.isLoggedIn" @click="userStore.logout().then(() => router.replace('/login'))">
          退出登录
        </el-button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.forbidden-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(180deg, #fafcff 0%, #f2f6fc 100%);
  padding: 24px;
}

.forbidden-card {
  width: 560px;
  max-width: 100%;
  padding: 48px 36px;
  text-align: center;
  border-radius: 18px;
  background: #ffffff;
  box-shadow: 0 16px 40px rgba(31, 35, 41, 0.12);
}

.forbidden-code {
  font-size: 72px;
  line-height: 1;
  font-weight: 700;
  color: #f56c6c;
}

h1 {
  margin: 16px 0 12px;
  color: #303133;
}

p {
  margin: 0;
  color: #606266;
  line-height: 1.8;
}

.actions {
  margin-top: 28px;
  display: flex;
  gap: 12px;
  justify-content: center;
}
</style>
