import { createRouter, createWebHistory } from 'vue-router'
import { defineComponent, h } from 'vue'

import { useUserStore } from '@/stores/user'
import { setupRouterGuards } from '@/router/guards'

import Login from '@/views/auth/Login.vue'
import Register from '@/views/auth/Register.vue'
import Forbidden from '@/views/error/Forbidden.vue'

const HomeView = defineComponent({
  name: 'HomeView',
  setup() {
    const userStore = useUserStore()

    return () =>
      h('div', { style: 'min-height: 100vh; background: #f5f7fa; padding: 48px 24px;' }, [
        h('div', {
          style:
            'max-width: 760px; margin: 0 auto; background: #fff; border-radius: 16px; padding: 32px; box-shadow: 0 10px 30px rgba(31, 35, 41, 0.08);'
        }, [
          h('h1', { style: 'margin: 0 0 12px; font-size: 28px; color: #303133;' }, '智能投顾平台'),
          h(
            'p',
            { style: 'margin: 0 0 24px; color: #606266; line-height: 1.8;' },
            '模块一已完成认证与权限链路。当前页面用于验证登录态恢复、角色返回与退出登录；后续业务模块将继续复用这一统一路由和用户状态体系。'
          ),
          h('div', { style: 'display: grid; gap: 12px; color: #303133;' }, [
            h('div', `当前用户：${userStore.userInfo?.nickname || userStore.userInfo?.username || '-'}`),
            h('div', `用户名：${userStore.userInfo?.username || '-'}`),
            h('div', `角色：${userStore.roles.join('、') || '-'}`)
          ])
        ])
      ])
  }
})

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'Home',
      component: HomeView,
      meta: { requiresAuth: true }
    },
    {
      path: '/login',
      name: 'Login',
      component: Login,
      meta: { guestOnly: true }
    },
    {
      path: '/register',
      name: 'Register',
      component: Register,
      meta: { guestOnly: true }
    },
    {
      path: '/403',
      name: 'Forbidden',
      component: Forbidden
    }
  ]
})

setupRouterGuards(router)

export default router
