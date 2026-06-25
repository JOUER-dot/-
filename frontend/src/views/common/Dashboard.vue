<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'

import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import StatCard from '@/components/ui/StatCard.vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

const dashboardTitle = computed(() => {
  if (userStore.hasAnyRole(['ADVISOR'])) return '产品工作台'
  if (userStore.hasAnyRole(['REVIEWER'])) return '审核工作台'
  return '我的工作台'
})

const statCards = computed(() => {
  if (userStore.hasAnyRole(['ADVISOR'])) {
    return [
      { label: '当前身份', value: '投顾', hint: '' },
      { label: '核心入口', value: '产品管理', hint: '' },
      { label: '快捷动作', value: '创建产品', hint: '' }
    ]
  }
  if (userStore.hasAnyRole(['REVIEWER'])) {
    return [
      { label: '当前身份', value: '审核员', hint: '' },
      { label: '核心入口', value: '待审列表', hint: '' },
      { label: '快捷动作', value: '处理审核', hint: '' }
    ]
  }
  return [
    { label: '当前身份', value: '用户', hint: '' },
    { label: '核心入口', value: '产品专区', hint: '' },
    { label: '快捷动作', value: '查看订阅', hint: '' }
  ]
})

const shortcuts = computed(() => {
  if (userStore.hasAnyRole(['ADVISOR'])) {
    return [
      { label: '组合产品管理', path: '/admin/products' },
      { label: '创建产品', path: '/admin/products/create' },
      { label: '账号中心', path: '/account' }
    ]
  }
  if (userStore.hasAnyRole(['REVIEWER'])) {
    return [
      { label: '待审列表', path: '/review/pending' },
      { label: '账号中心', path: '/account' }
    ]
  }
  return [
    { label: '产品专区', path: '/advisor-zone' },
    { label: '我的订阅', path: '/my-subscriptions' },
    { label: '账号中心', path: '/account' }
  ]
})

const go = async (path: string) => {
  await router.push(path)
}
</script>

<template>
  <PageContainer>
    <div class="dashboard-page">
      <div class="hero">
        <div>
          <div class="hero__kicker">工作台</div>
          <div class="hero__title">{{ dashboardTitle }}</div>
        </div>
      </div>

      <div class="stat-grid">
        <StatCard v-for="item in statCards" :key="item.label" :label="item.label" :value="item.value" :hint="item.hint" />
      </div>

      <SectionCard title="快捷入口">
        <div class="shortcut-grid">
          <button v-for="item in shortcuts" :key="item.path" class="shortcut-card" type="button" @click="go(item.path)">
            <span>{{ item.label }}</span>
          </button>
        </div>
      </SectionCard>
    </div>
  </PageContainer>
</template>

<style scoped>
.dashboard-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.hero {
  padding: 18px;
  border-radius: var(--radius-card);
  border: 1px solid var(--color-border);
  background:
    radial-gradient(640px 220px at 18% 18%, rgba(22, 59, 102, 0.12), transparent 60%),
    linear-gradient(180deg, var(--color-bg-card) 0%, #f8fafc 100%);
}

.hero__kicker {
  color: var(--color-text-2);
  font-size: 12px;
}

.hero__title {
  margin-top: 10px;
  font-size: 26px;
  line-height: 34px;
  font-weight: 900;
  color: var(--color-text-1);
}

.stat-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
}

.shortcut-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
}

.shortcut-card {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 88px;
  border: 1px solid var(--color-border);
  border-radius: 14px;
  background: linear-gradient(180deg, var(--color-bg-card) 0%, #f8fafc 100%);
  color: var(--color-text-1);
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  transition: transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease;
}

.shortcut-card:hover {
  transform: translateY(-1px);
  border-color: rgba(22, 59, 102, 0.24);
  box-shadow: var(--shadow-soft);
}
</style>
