<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

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
  <el-card shadow="never">
    <template #header>
      <div style="font-weight: 600;">工作台</div>
    </template>
    <el-space wrap>
      <el-button v-for="item in shortcuts" :key="item.path" type="primary" plain @click="go(item.path)">
        {{ item.label }}
      </el-button>
    </el-space>
  </el-card>
</template>
