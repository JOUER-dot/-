<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
import StatusTag from '@/components/ui/StatusTag.vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)

const nickname = computed(() => userStore.userInfo?.nickname || userStore.userInfo?.username || '用户')
const username = computed(() => userStore.userInfo?.username || '-')
const roles = computed(() => userStore.roles.join('、') || '-')

const quickLinks = [
  { label: '浏览产品', path: '/advisor-zone', desc: '查看所有已上架产品', color: '#1f5c99' },
  { label: '我的订阅', path: '/my-subscriptions', desc: '管理已订阅的产品', color: '#1e9e62' },
  { label: '账号中心', path: '/account', desc: '个人信息与安全设置', color: '#b7791f' }
]

onMounted(async () => {
  // 页面加载时刷新用户信息
  try { await userStore.restoreSession() } catch { /* ignore */ }
})
</script>

<template>
  <PageContainer>
    <div class="app-page user-dashboard">
      <!-- 用户欢迎区 -->
      <div class="welcome-hero">
        <div class="welcome-hero__avatar">{{ nickname.slice(0, 1) }}</div>
        <div class="welcome-hero__info">
          <div class="welcome-hero__greeting">欢迎回来，{{ nickname }}</div>
          <div class="welcome-hero__meta">
            <span>用户名：{{ username }}</span>
            <span>角色：{{ roles }}</span>
          </div>
        </div>
        <el-button type="primary" @click="router.push('/advisor-zone')">浏览产品</el-button>
      </div>

      <!-- 快捷入口 -->
      <SectionCard title="快捷入口">
        <div class="quick-grid">
          <div v-for="item in quickLinks" :key="item.path" class="quick-card" @click="router.push(item.path)">
            <div class="quick-card__icon" :style="{ background: item.color }">{{ item.label.slice(0, 1) }}</div>
            <div class="quick-card__body">
              <div class="quick-card__title">{{ item.label }}</div>
              <div class="quick-card__desc">{{ item.desc }}</div>
            </div>
          </div>
        </div>
      </SectionCard>

      <!-- 操作引导 -->
      <SectionCard title="使用指引">
        <div class="guide-list">
          <div class="guide-item">
            <el-tag type="primary" effect="plain" size="small" round>1</el-tag>
            <span>在<b>产品专区</b>浏览投顾发布的产品，查看详情和净值走势</span>
          </div>
          <div class="guide-item">
            <el-tag type="success" effect="plain" size="small" round>2</el-tag>
            <span>找到感兴趣的产品后，点击<b>订阅</b>即可关注该产品的动态</span>
          </div>
          <div class="guide-item">
            <el-tag type="warning" effect="plain" size="small" round>3</el-tag>
            <span>在<b>我的订阅</b>中管理已订阅产品，处理版本更新决策</span>
          </div>
          <div class="guide-item">
            <el-tag type="info" effect="plain" size="small" round>4</el-tag>
            <span>在<b>账号中心</b>修改个人信息和密码</span>
          </div>
        </div>
      </SectionCard>
    </div>
  </PageContainer>
</template>

<style scoped>
.user-dashboard {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.welcome-hero {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 24px;
  border-radius: var(--radius-card);
  border: 1px solid var(--color-border);
  background: linear-gradient(180deg, var(--color-bg-card) 0%, #f8fafc 100%);
  box-shadow: var(--shadow-soft);
}

.welcome-hero__avatar {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  background: var(--brand-600);
  color: #fff;
  font-size: 24px;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.welcome-hero__info {
  flex: 1;
  min-width: 0;
}

.welcome-hero__greeting {
  font-size: 22px;
  font-weight: 800;
  color: var(--color-text-1);
  line-height: 1.4;
}

.welcome-hero__meta {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  margin-top: 6px;
  font-size: 13px;
  color: var(--color-text-2);
}

.quick-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 12px;
}

.quick-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 18px;
  border: 1px solid var(--color-border);
  border-radius: 14px;
  cursor: pointer;
  transition: border-color 0.2s, box-shadow 0.2s;
  background: var(--color-bg-card);
}

.quick-card:hover {
  border-color: var(--color-primary);
  box-shadow: var(--shadow-focus);
}

.quick-card__icon {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-weight: 700;
  font-size: 18px;
  flex-shrink: 0;
}

.quick-card__body {
  flex: 1;
  min-width: 0;
}

.quick-card__title {
  font-weight: 700;
  font-size: 15px;
  color: var(--color-text-1);
}

.quick-card__desc {
  margin-top: 2px;
  font-size: 12px;
  color: var(--color-text-3);
}

.guide-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.guide-item {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 14px;
  color: var(--color-text-2);
  line-height: 1.6;
}

.guide-item b {
  color: var(--color-text-1);
}
</style>
