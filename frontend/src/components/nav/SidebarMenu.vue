<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import { useUserStore } from '@/stores/user'
import { deleteAccount } from '@/api/auth'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const settingsVisible = ref(false)
const activeTab = ref('profile')
const showMore = ref(false)
const passwordDialogVisible = ref(false)

const nickname = computed(() => userStore.userInfo?.nickname || userStore.userInfo?.username || '?')
const username = computed(() => userStore.userInfo?.username || '')
const avatarChar = computed(() => nickname.value.slice(0, 1))

const profileForm = reactive({
  nickname: userStore.userInfo?.nickname || '',
  phone: userStore.userInfo?.phone || '',
  email: userStore.userInfo?.email || ''
})

const nav = (path: string) => { settingsVisible.value = false; void router.push(path) }

// ── 菜单 ──
type MenuItem = { label: string; path: string; group: string; roles?: string[] }
const allMenus: MenuItem[] = [
  { label: '工作台', path: '/admin/products', group: '投顾端', roles: ['ADVISOR'] },
  { label: '创建产品', path: '/admin/products/create', group: '投顾端', roles: ['ADVISOR'] },
  { label: '工作台', path: '/review/pending', group: '审核端', roles: ['REVIEWER'] },
  { label: '我的审核记录', path: '/review/my-history', group: '审核端', roles: ['REVIEWER'] },
  { label: '工作台', path: '/my/dashboard', group: '用户端', roles: ['USER'] },
  { label: '浏览产品', path: '/advisor-zone', group: '用户端', roles: ['USER'] },
  { label: 'AI 助手', path: '/ai', group: '用户端', roles: ['USER'] },
  { label: '我的订阅', path: '/my-subscriptions', group: '用户端', roles: ['USER'] },
  { label: '管理后台', path: '/admin/dashboard', group: '系统管理', roles: ['ADMIN'] },
  { label: '用户管理', path: '/admin/users', group: '系统管理', roles: ['ADMIN'] },
  { label: '账号中心', path: '/account', group: '通用' },
  { label: '通知中心', path: '/notifications', group: '通用', roles: ['USER', 'ADVISOR', 'REVIEWER', 'ADMIN'] },
  { label: '交易记录', path: '/transactions', group: '通用', roles: ['USER'] }
]
const menus = computed(() => allMenus.filter((m) => !m.roles || userStore.hasAnyRole(m.roles)))
const groupedMenus = computed(() => {
  const order = ['通用', '投顾端', '审核端', '用户端', '系统管理']
  const map = new Map<string, MenuItem[]>()
  for (const item of menus.value) { const list = map.get(item.group) || []; list.push(item); map.set(item.group, list) }
  return order.map((g) => ({ group: g, items: map.get(g) || [] })).filter((g) => g.items.length > 0)
})
const activePath = computed(() => {
  const m = menus.value.filter((i) => route.path.startsWith(i.path)).sort((a, b) => b.path.length - a.path.length)
  return m.length > 0 ? m[0].path : ''
})
const handleClick = (path: string) => void router.push(path)

const initProfile = () => {
  profileForm.nickname = userStore.userInfo?.nickname || ''
  profileForm.phone = userStore.userInfo?.phone || ''
  profileForm.email = userStore.userInfo?.email || ''
}

const openSettings = () => {
  initProfile()
  activeTab.value = 'profile'
  showMore.value = false
  settingsVisible.value = true
}

const logout = async () => {
  settingsVisible.value = false
  await userStore.logout()
  await router.replace('/login')
}

const handleDelete = async () => {
  settingsVisible.value = false
  try { await ElMessageBox.confirm('确认注销账号吗？若有已上架产品请先下架后再注销。', '注销账号', { type: 'warning' }) } catch { return }
  try {
    await deleteAccount()
    ElMessage.success('账号已注销')
    await userStore.logout(false)
    await router.replace('/login')
  } catch (e: any) { ElMessage.error(e?.message || '注销失败') }
}
</script>

<template>
  <div class="sidebar-wrap">
    <div class="sidebar-menu">
      <div v-for="g in groupedMenus" :key="g.group" class="menu-group">
        <div class="menu-group-title">{{ g.group }}</div>
        <div v-for="item in g.items" :key="item.path" class="menu-item" :class="{ active: activePath === item.path }" @click="handleClick(item.path)">{{ item.label }}</div>
      </div>
    </div>

    <!-- 用户信息 -->
    <div class="sidebar-user" @click="openSettings">
      <div class="su-avatar">{{ avatarChar }}</div>
      <div class="su-info">
        <div class="su-name">{{ nickname }}</div>
        <div class="su-alias">@{{ username }}</div>
      </div>
    </div>
  </div>

  <el-dialog v-model="settingsVisible" title="" width="420px" :close-on-click-modal="true" class="settings-dialog">
    <div class="sd-header">
      <div class="sd-avatar">{{ avatarChar }}</div>
      <div class="sd-name">{{ nickname }}</div>
      <div class="sd-meta">@{{ username }} · {{ userStore.roles.join('、') }}</div>
    </div>

    <div class="sd-tabs">
      <button class="sd-tab" :class="{ active: activeTab === 'profile' }" @click="activeTab = 'profile'">个人信息</button>
      <button class="sd-tab" :class="{ active: activeTab === 'security' }" @click="activeTab = 'security'">安全</button>
      <button class="sd-tab" :class="{ active: activeTab === 'about' }" @click="activeTab = 'about'">关于</button>
    </div>

    <!-- 个人信息 -->
    <div v-if="activeTab === 'profile'" class="sd-body">
      <el-descriptions :column="1" border>
        <el-descriptions-item label="用户名">{{ username }}</el-descriptions-item>
        <el-descriptions-item label="昵称">{{ profileForm.nickname || '-' }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ profileForm.phone || '未设置' }}</el-descriptions-item>
        <el-descriptions-item label="邮箱">{{ profileForm.email || '未设置' }}</el-descriptions-item>
        <el-descriptions-item label="角色">{{ userStore.roles.join('、') || '-' }}</el-descriptions-item>
        <el-descriptions-item label="账号状态">{{ userStore.isLoggedIn ? '正常' : '离线' }}</el-descriptions-item>
      </el-descriptions>
    </div>

    <!-- 安全 -->
    <div v-if="activeTab === 'security'" class="sd-body">
      <div class="sd-security-hint">
        <div class="sd-security-icon">🔒</div>
        <div>密码修改、安全验证等操作请在账号中心完成。</div>
      </div>
      <el-button size="large" class="sd-btn" @click="nav('/account')">前往账号中心</el-button>

      <div class="sd-danger">
        <div class="sd-danger-toggle" @click="showMore = !showMore">
          <span>更多操作</span>
          <span class="sd-more-arrow" :class="{ open: showMore }">▾</span>
        </div>
        <div v-if="showMore" class="sd-more-body">
          <el-button type="danger" plain size="large" class="sd-btn" @click="handleDelete">注销账号</el-button>
        </div>
      </div>
    </div>

    <!-- 关于 -->
    <div v-if="activeTab === 'about'" class="sd-body">
      <el-descriptions :column="1" border>
        <el-descriptions-item label="用户名">{{ username }}</el-descriptions-item>
        <el-descriptions-item label="角色">{{ userStore.roles.join('、') || '-' }}</el-descriptions-item>
        <el-descriptions-item label="账号状态">{{ userStore.isLoggedIn ? '在线' : '离线' }}</el-descriptions-item>
        <el-descriptions-item label="平台版本">RoboAdvisor v1.0</el-descriptions-item>
      </el-descriptions>
      <div style="margin-top:16px">
        <el-button size="large" class="sd-btn" @click="logout">退出登录</el-button>
      </div>
    </div>
  </el-dialog>
</template>

<style scoped>
.sidebar-wrap { display: flex; flex-direction: column; min-height: 0; flex: 1; }
.sidebar-menu { flex: 1; overflow-y: auto; padding: 8px 12px; }
.menu-group-title { font-size: 11px; font-weight: 600; letter-spacing: 1px; color: rgba(255,255,255,.35); padding: 12px 8px 6px; text-transform: uppercase; }
.menu-item { font-size: 14px; color: rgba(255,255,255,.72); padding: 10px 12px; border-radius: 8px; cursor: pointer; transition: all .15s; user-select: none; }
.menu-item:hover { background: rgba(255,255,255,.08); color: rgba(255,255,255,.9); }
.menu-item.active { background: rgba(255,255,255,.12); color: #fff; font-weight: 600; }
.sidebar-user { display: flex; align-items: center; gap: 10px; padding: 14px 12px; border-top: 1px solid rgba(255,255,255,.08); cursor: pointer; transition: background .15s; flex-shrink: 0; }
.sidebar-user:hover { background: rgba(255,255,255,.08); }
.su-avatar { width: 36px; height: 36px; border-radius: 50%; background: linear-gradient(135deg,#1f5c99,#c8a45d); color: #fff; font-size: 16px; font-weight: 700; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.su-info { min-width: 0; }
.su-name { font-size: 13px; font-weight: 600; color: #ffffff; }
.su-alias { font-size: 11px; color: rgba(255,255,255,.5); margin-top: 1px; }

/* 设置弹窗 */
.sd-header { display: flex; flex-direction: column; align-items: center; gap: 6px; padding: 8px 0 16px; border-bottom: 1px solid var(--color-border); margin-bottom: 16px; }
.sd-avatar { width: 56px; height: 56px; border-radius: 50%; background: linear-gradient(135deg,#1f5c99,#c8a45d); color: #fff; font-size: 24px; font-weight: 700; display: flex; align-items: center; justify-content: center; }
.sd-name { font-size: 18px; font-weight: 700; color: var(--color-text-1); }
.sd-meta { font-size: 12px; color: var(--color-text-3); }
.sd-tabs { display: flex; gap: 4px; margin-bottom: 16px; background: var(--color-bg-muted); border-radius: 10px; padding: 3px; }
.sd-tab { flex: 1; padding: 8px; border: none; border-radius: 8px; background: transparent; color: var(--color-text-2); font-size: 13px; font-weight: 500; cursor: pointer; transition: all .2s; }
.sd-tab.active { background: #fff; color: var(--color-text-1); font-weight: 600; box-shadow: 0 1px 4px rgba(0,0,0,.06); }
.sd-body { display: flex; flex-direction: column; gap: 14px; }
.sd-field { display: flex; flex-direction: column; gap: 6px; }
.sd-label { font-size: 12px; font-weight: 600; color: var(--color-text-2); letter-spacing: .3px; }
.sd-btn { width: 100%; }
.sd-danger { margin-top: 8px; border-top: 1px solid var(--color-border); padding-top: 12px; }
.sd-danger-toggle { display: flex; align-items: center; justify-content: center; gap: 6px; padding: 10px; font-size: 12px; color: var(--color-text-3); cursor: pointer; border-radius: 8px; transition: background .15s; }
.sd-danger-toggle:hover { background: var(--color-bg-muted); }
.sd-more-arrow { transition: transform .2s; font-size: 10px; }
.sd-more-arrow.open { transform: rotate(180deg); }
.sd-more-body { padding-top: 8px; }
</style>
