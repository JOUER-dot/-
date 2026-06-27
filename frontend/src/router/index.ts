import { createRouter, createWebHistory } from 'vue-router'
import { setupRouterGuards } from '@/router/guards'

import AppLayout from '@/layouts/AppLayout.vue'
import PublicLayout from '@/layouts/PublicLayout.vue'
import Login from '@/views/auth/Login.vue'
import Register from '@/views/auth/Register.vue'
import Forbidden from '@/views/error/Forbidden.vue'
import Dashboard from '@/views/common/Dashboard.vue'
import AccountCenter from '@/views/account/AccountCenter.vue'
import ProductList from '@/views/advisor/ProductList.vue'
import ProductEdit from '@/views/advisor/ProductEdit.vue'
import ReviewPendingList from '@/views/review/ReviewPendingList.vue'
import ReviewDetail from '@/views/review/ReviewDetail.vue'
import ReviewHistory from '@/views/review/ReviewHistory.vue'
import AdvisorZoneList from '@/views/public/AdvisorZoneList.vue'
import AdvisorZoneDetail from '@/views/public/AdvisorZoneDetail.vue'
import CompareProducts from '@/views/public/CompareProducts.vue'
import PaymentPage from '@/views/public/PaymentPage.vue'
import MySubscriptions from '@/views/public/MySubscriptions.vue'
import UserDashboard from '@/views/common/UserDashboard.vue'
import Notifications from '@/views/common/Notifications.vue'
import TransactionHistory from '@/views/common/TransactionHistory.vue'
import AdminDashboard from '@/views/admin/AdminDashboard.vue'
import AdminUsers from '@/views/admin/AdminUsers.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      component: AppLayout,
      meta: { requiresAuth: true },
      children: [
        {
          path: '',
          redirect: '/dashboard'
        },
        {
          path: 'dashboard',
          name: 'Dashboard',
          component: Dashboard,
          meta: { requiresAuth: true, title: '工作台' }
        },
        {
          path: 'account',
          name: 'AccountCenter',
          component: AccountCenter,
          meta: { requiresAuth: true, title: '账号中心' }
        },
        {
          path: 'my-subscriptions',
          name: 'MySubscriptions',
          component: MySubscriptions,
          meta: {
            requiresAuth: true,
            roles: ['USER'],
            title: '我的订阅',
            description: '用户端我的订阅页'
          }
        },
        {
          path: 'notifications',
          name: 'Notifications',
          component: Notifications,
          meta: {
            requiresAuth: true,
            title: '消息通知',
            description: '系统通知'
          }
        },
        {
          path: 'transactions',
          name: 'TransactionHistory',
          component: TransactionHistory,
          meta: {
            requiresAuth: true,
            roles: ['USER'],
            title: '交易记录',
            description: '查看交易记录'
          }
        },
        {
          path: 'my/dashboard',
          name: 'UserDashboard',
          component: UserDashboard,
          meta: {
            requiresAuth: true,
            title: '我的工作台',
            description: '用户端个人工作台'
          }
        },
        {
          path: 'admin/products',
          name: 'AdminProducts',
          component: ProductList,
          meta: {
            requiresAuth: true,
            roles: ['ADVISOR'],
            title: '组合产品管理',
            description: '投顾产品列表页'
          }
        },
        {
          path: 'admin/products/create',
          name: 'AdvisorProductCreate',
          component: ProductEdit,
          meta: {
            requiresAuth: true,
            roles: ['ADVISOR'],
            title: '创建产品',
            description: '投顾创建产品草稿页'
          }
        },
        {
          path: 'admin/products/:id/edit',
          name: 'AdvisorProductEdit',
          component: ProductEdit,
          meta: {
            requiresAuth: true,
            roles: ['ADVISOR'],
            title: '编辑草稿',
            description: '投顾编辑产品草稿页'
          }
        },
        {
          path: 'admin/products/:id',
          name: 'AdvisorProductDetail',
          component: ProductEdit,
          meta: {
            requiresAuth: true,
            roles: ['ADVISOR'],
            title: '产品详情',
            description: '投顾查看产品详情页'
          }
        },
        {
          path: 'review/pending',
          name: 'ReviewPending',
          component: ReviewPendingList,
          meta: {
            requiresAuth: true,
            roles: ['REVIEWER'],
            title: '待审列表',
            description: '审核员待审列表页'
          }
        },
        {
          path: 'review/pending/:id',
          name: 'ReviewDetail',
          component: ReviewDetail,
          meta: {
            requiresAuth: true,
            roles: ['REVIEWER'],
            title: '审核详情',
            description: '审核员审核详情页'
          }
        },
        {
          path: 'review/my-history',
          name: 'ReviewHistory',
          component: ReviewHistory,
          meta: {
            requiresAuth: true,
            roles: ['REVIEWER'],
            title: '我的审核记录',
            description: '审核员历史记录页'
          }
        },
        {
          path: 'admin/dashboard',
          name: 'AdminDashboard',
          component: AdminDashboard,
          meta: {
            requiresAuth: true,
            roles: ['ADMIN'],
            title: '管理后台',
            description: '系统运营概览'
          }
        },
        {
          path: 'admin/users',
          name: 'AdminUsers',
          component: AdminUsers,
          meta: {
            requiresAuth: true,
            roles: ['ADMIN'],
            title: '用户管理',
            description: '用户管理与角色分配'
          }
        }
      ]
    },
    {
      path: '/advisor-zone',
      component: PublicLayout,
      children: [
        {
          path: '',
          name: 'AdvisorZone',
          component: AdvisorZoneList,
          meta: {
            title: '基金投顾产品专区',
            description: '用户端产品专区列表页'
          }
        },
        {
          path: ':id',
          name: 'AdvisorZoneDetail',
          component: AdvisorZoneDetail,
          meta: {
            title: '产品详情',
            description: '用户端产品详情页'
          }
        },
        {
          path: 'compare',
          name: 'CompareProducts',
          component: CompareProducts,
          meta: {
            title: '产品对比',
            description: '产品对比页'
          }
        }
      ]
    },
    {
      path: '/403',
      name: 'Forbidden',
      component: Forbidden,
      meta: { title: '无权限' }
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
      path: '/payment/:id',
      name: 'Payment',
      component: PaymentPage,
      meta: { title: '确认支付' }
    }
  ]
})

setupRouterGuards(router)

export default router
