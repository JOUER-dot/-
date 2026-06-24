<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import { useUserStore } from '@/stores/user'

type MenuItem = {
  label: string
  path: string
  group: 'COMMON' | 'USER' | 'ADVISOR' | 'REVIEWER'
  roles?: string[]
}

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const allMenus: MenuItem[] = [
  { label: '工作台', path: '/dashboard', group: 'COMMON', roles: ['USER', 'ADVISOR', 'REVIEWER'] },
  { label: '账号中心', path: '/account', group: 'COMMON', roles: ['USER', 'ADVISOR', 'REVIEWER'] },
  { label: '产品专区', path: '/advisor-zone', group: 'USER', roles: ['USER'] },
  { label: '我的订阅', path: '/my-subscriptions', group: 'USER', roles: ['USER'] },
  { label: '组合产品', path: '/admin/products', group: 'ADVISOR', roles: ['ADVISOR'] },
  { label: '新建产品', path: '/admin/products/create', group: 'ADVISOR', roles: ['ADVISOR'] },
  { label: '待审列表', path: '/review/pending', group: 'REVIEWER', roles: ['REVIEWER'] }
]

const menus = computed(() => allMenus.filter((item) => !item.roles || userStore.hasAnyRole(item.roles)))

const groupTitle = (group: MenuItem['group']) => {
  if (group === 'COMMON') return '通用'
  if (group === 'USER') return '用户端'
  if (group === 'ADVISOR') return '投顾端'
  if (group === 'REVIEWER') return '审核端'
  return group
}

const groupedMenus = computed(() => {
  const groupOrder: MenuItem['group'][] = ['COMMON', 'ADVISOR', 'REVIEWER', 'USER']
  const map = new Map<MenuItem['group'], MenuItem[]>()
  for (const item of menus.value) {
    const list = map.get(item.group) || []
    list.push(item)
    map.set(item.group, list)
  }
  return groupOrder
    .map((group) => ({
      group,
      title: groupTitle(group),
      items: map.get(group) || []
    }))
    .filter((g) => g.items.length > 0)
})

const activeMenu = computed(() => {
  const matched = menus.value
    .filter((item) => route.path.startsWith(item.path))
    .sort((a, b) => b.path.length - a.path.length)[0]
  return matched?.path || route.path
})

const handleSelect = (index: string) => {
  void router.push(index)
}
</script>

<template>
  <el-menu :default-active="activeMenu" class="side-menu" @select="handleSelect">
    <el-menu-item-group v-for="group in groupedMenus" :key="group.group" :title="group.title">
      <el-menu-item v-for="item in group.items" :key="item.path" :index="item.path">
        {{ item.label }}
      </el-menu-item>
    </el-menu-item-group>
  </el-menu>
</template>

<style scoped>
.side-menu {
  height: 100%;
  border-right: none;
}
</style>
