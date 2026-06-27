<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'

import { useUserStore } from '@/stores/user'
import { getDefaultHomeByRoles } from '@/utils/role-home'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const loading = ref(false)
const formRef = ref<FormInstance>()
const form = reactive({ username: '', password: '' })

const rules: FormRules<typeof form> = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const handleLogin = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      await userStore.login(form)
      ElMessage.success('登录成功')
      const redirect = typeof route.query.redirect === 'string'
        ? route.query.redirect
        : getDefaultHomeByRoles(userStore.roles)
      await router.replace(redirect)
    } finally { loading.value = false }
  })
}
</script>

<template>
  <div class="landing">
    <!-- 顶部导航 -->
    <header class="nav">
      <div class="nav-inner">
        <div class="nav-brand">
          <span class="nav-brand__dot" />
          <span class="nav-brand__text">智能投顾</span>
        </div>
        <div class="nav-links">
          <el-button text class="nav-link" @click="router.push('/advisor-zone')">产品专区</el-button>
          <el-button type="primary" class="nav-btn" @click="router.push('/login')">登录</el-button>
          <el-button text class="nav-link" @click="router.push('/register')">注册</el-button>
        </div>
      </div>
    </header>

    <!-- 主内容 -->
    <main class="main">
      <div class="main-glow main-glow--1" />
      <div class="main-glow main-glow--2" />
      <div class="main-grid" />

      <div class="main-content">
        <div class="hero">
          <div class="hero-badge">ROBO ADVISOR</div>
          <h1 class="hero-title">智能投顾平台</h1>
          <p class="hero-sub">专业基金投顾 · 智能资产配置 · 一站式管理</p>
          <div class="hero-actions">
            <el-button type="primary" size="large" class="hero-btn hero-btn--primary" @click="router.push('/advisor-zone')">
              浏览产品
            </el-button>
            <el-button size="large" class="hero-btn hero-btn--outline" @click="router.push('/register')">
              注册体验
            </el-button>
          </div>
        </div>

        <!-- 登录面板 -->
        <div class="login-panel">
          <h2 class="login-title">登录</h2>
          <p class="login-desc">登录后管理您的投资组合</p>
          <el-form ref="formRef" :model="form" :rules="rules" class="login-form" @keyup.enter="handleLogin">
            <div class="field">
              <label class="field-label">用户名</label>
              <el-input v-model="form.username" placeholder="请输入用户名" class="field-input" />
            </div>
            <div class="field">
              <label class="field-label">密码</label>
              <el-input v-model="form.password" type="password" show-password placeholder="请输入密码" class="field-input" />
            </div>
            <el-button type="primary" class="login-btn" :loading="loading" @click="handleLogin">
              登录
            </el-button>
          </el-form>
          <div class="login-footer">
            <el-button link @click="router.push('/register')">没有账号？去注册</el-button>
            <el-button link type="info" disabled>忘记密码？</el-button>
          </div>
        </div>
      </div>
    </main>

    <!-- 页脚 -->
    <footer class="footer">
      <div class="footer-inner">
        <div class="footer-roles">
          <span class="footer-role">用户端</span>
          <span class="footer-dot" />
          <span class="footer-role">投顾端</span>
          <span class="footer-dot" />
          <span class="footer-role">审核端</span>
          <span class="footer-dot" />
          <span class="footer-role">管理端</span>
        </div>
        <span class="footer-version">RoboAdvisor v1.0</span>
      </div>
    </footer>
  </div>
</template>

<style>
/* ========== 全局字体覆盖 ========== */
.landing {
  --font-display: 'Noto Serif SC', 'PingFang SC', 'Microsoft YaHei', serif;
  --font-sans: 'PingFang SC', 'Microsoft YaHei', 'Noto Serif SC', sans-serif;
}

.landing * {
  font-family: var(--font-sans);
}

.landing h1, .landing h2, .landing .hero-badge, .landing .nav-brand__text {
  font-family: var(--font-display);
}
</style>

<style scoped>
.landing {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  position: relative;
  background: linear-gradient(180deg, #f0f4fa 0%, #e8eef6 100%);
}

/* ===== 导航 ===== */
.nav {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
  background: rgba(255,255,255,0.85);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-bottom: 1px solid rgba(14,46,85,0.06);
}
.nav-inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 32px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.nav-brand {
  display: flex;
  align-items: center;
  gap: 10px;
}
.nav-brand__dot {
  width: 8px; height: 8px;
  border-radius: 50%;
  background: #c8a45d;
  box-shadow: 0 0 12px rgba(200,164,93,0.3);
}
.nav-brand__text {
  font-size: 18px;
  font-weight: 900;
  color: #0e2e55;
  letter-spacing: 2px;
}
.nav-links {
  display: flex;
  align-items: center;
  gap: 4px;
}
.nav-link {
  font-size: 13px;
  color: #5e6b7a;
  padding: 6px 14px;
}
.nav-link:hover {
  color: #0e2e55;
}
.nav-btn {
  margin-left: 8px;
}

/* ===== 主体 ===== */
.main {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 100px 24px 80px;
  position: relative;
  overflow: hidden;
}

.main-glow {
  position: absolute;
  border-radius: 50%;
  pointer-events: none;
  filter: blur(100px);
}
.main-glow--1 {
  width: 500px; height: 500px;
  top: -200px; left: 10%;
  background: rgba(31,92,153,0.06);
}
.main-glow--2 {
  width: 400px; height: 400px;
  bottom: -150px; right: 10%;
  background: rgba(200,164,93,0.05);
}

.main-grid {
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(rgba(14,46,85,0.02) 1px, transparent 1px),
    linear-gradient(90deg, rgba(14,46,85,0.02) 1px, transparent 1px);
  background-size: 80px 80px;
  pointer-events: none;
}

.main-content {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  gap: 80px;
  width: 100%;
  max-width: 1040px;
}

/* ===== Hero ===== */
.hero {
  flex: 1;
  min-width: 0;
}
.hero-badge {
  display: inline-flex;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 4px;
  color: #c8a45d;
  padding: 6px 16px;
  border: 1px solid rgba(200,164,93,0.2);
  border-radius: 20px;
  background: rgba(200,164,93,0.04);
  margin-bottom: 24px;
}
.hero-title {
  font-size: 56px;
  font-weight: 900;
  color: #0e2e55;
  margin: 0;
  line-height: 1.15;
  letter-spacing: 4px;
}
.hero-sub {
  font-size: 16px;
  color: #8a94a3;
  margin: 16px 0 0;
  line-height: 1.6;
  letter-spacing: 0.5px;
}
.hero-actions {
  display: flex;
  gap: 12px;
  margin-top: 32px;
}
.hero-btn {
  height: 48px;
  padding: 0 32px;
  border-radius: 8px;
  font-size: 15px;
  font-weight: 700;
  letter-spacing: 1px;
}
.hero-btn--primary {
  background: #0e2e55;
  border: none;
  color: #fff;
}
.hero-btn--primary:hover {
  background: #1a4070;
  transform: translateY(-1px);
  box-shadow: 0 8px 24px rgba(14,46,85,0.2);
}
.hero-btn--outline {
  background: transparent;
  border: 1px solid #cfd6df;
  color: #5e6b7a;
}
.hero-btn--outline:hover {
  border-color: #0e2e55;
  color: #0e2e55;
}

/* ===== 登录面板 ===== */
.login-panel {
  width: 360px;
  flex-shrink: 0;
  background: #ffffff;
  border-radius: 16px;
  padding: 36px 32px;
  box-shadow: 0 4px 24px rgba(14,46,85,0.06), 0 1px 4px rgba(14,46,85,0.03);
  border: 1px solid rgba(14,46,85,0.04);
}
.login-title {
  font-size: 22px;
  font-weight: 800;
  color: #0e2e55;
  margin: 0;
  letter-spacing: -0.3px;
}
.login-desc {
  font-size: 13px;
  color: #8a94a3;
  margin: 6px 0 24px;
}
.login-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.field { display: flex; flex-direction: column; gap: 6px; }
.field-label {
  font-size: 12px;
  font-weight: 700;
  color: #0e2e55;
  letter-spacing: 1px;
}
:deep(.field-input .el-input__wrapper) {
  border-radius: 8px;
  padding: 4px 16px;
  height: 46px;
  box-shadow: 0 0 0 1px #d6dce6 inset;
  transition: all .25s ease;
  background: #fafbfc;
}
:deep(.field-input .el-input__wrapper:hover) {
  box-shadow: 0 0 0 1px #1f5c99 inset;
  background: #fff;
}
:deep(.field-input .el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 2px #1f5c99 inset;
  background: #fff;
}
:deep(.field-input .el-input__inner) {
  height: 46px;
  font-size: 15px;
  color: #0e2e55;
  font-weight: 500;
}
:deep(.field-input .el-input__inner::placeholder) {
  color: #b0b8c4;
}
.login-btn {
  width: 100%;
  height: 46px;
  border-radius: 8px;
  font-size: 15px;
  font-weight: 700;
  letter-spacing: 1px;
  background: #0e2e55;
  border: none;
  color: #fff;
  margin-top: 4px;
  transition: all .3s ease;
}
.login-btn:hover {
  background: #1a4070;
  transform: translateY(-1px);
  box-shadow: 0 8px 20px rgba(14,46,85,0.2);
}
.login-footer {
  text-align: center;
  margin-top: 20px;
}
.login-footer :deep(.el-button) {
  font-size: 12px;
  color: #8a94a3;
  padding: 0;
  height: auto;
}
.login-footer :deep(.el-button:hover) {
  color: #1f5c99;
}

/* ===== 页脚 ===== */
.footer {
  border-top: 1px solid rgba(14,46,85,0.04);
  background: rgba(255,255,255,0.6);
}
.footer-inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 16px 32px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.footer-roles {
  display: flex;
  align-items: center;
  gap: 10px;
}
.footer-role {
  font-size: 12px;
  color: #8a94a3;
  letter-spacing: 0.5px;
}
.footer-dot {
  width: 3px; height: 3px;
  border-radius: 50%;
  background: #cfd6df;
}
.footer-version {
  font-size: 11px;
  color: #b0b8c4;
  letter-spacing: 0.5px;
}

/* ===== 响应式 ===== */
@media (max-width: 860px) {
  .main-content {
    flex-direction: column;
    gap: 48px;
  }
  .hero-title {
    font-size: 36px;
    letter-spacing: 2px;
  }
  .hero-actions {
    flex-direction: column;
  }
  .login-panel {
    width: 100%;
    max-width: 400px;
  }
}
</style>
