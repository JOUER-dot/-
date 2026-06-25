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
const form = reactive({
  username: '',
  password: ''
})

const rules: FormRules<typeof form> = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const handleLogin = async () => {
  if (!formRef.value) {
    return
  }
  await formRef.value.validate(async (valid) => {
    if (!valid) {
      return
    }
    loading.value = true
    try {
      await userStore.login(form)
      ElMessage.success('登录成功')
      const redirect =
        typeof route.query.redirect === 'string'
          ? route.query.redirect
          : getDefaultHomeByRoles(userStore.roles)
      await router.replace(redirect)
    } finally {
      loading.value = false
    }
  })
}
</script>

<template>
  <div class="auth-page">
    <div class="auth-card">
      <div class="auth-intro">
        <div class="brand">
          <span class="brand__mark" />
          <div class="brand__text">
            <div class="brand__name">智能投顾平台</div>
            <div class="brand__sub">组合产品管理子系统</div>
          </div>
        </div>

        <div class="role-row">
          <el-tag effect="dark" class="role-tag">USER</el-tag>
          <el-tag effect="plain" class="role-tag role-tag--plain">ADVISOR</el-tag>
          <el-tag effect="plain" class="role-tag role-tag--plain">REVIEWER</el-tag>
        </div>
      </div>

      <div class="auth-form-wrap">
        <el-form ref="formRef" :model="form" :rules="rules" label-position="top" class="auth-form">
          <div class="form-title">欢迎登录</div>
          <div class="form-subtitle">请输入账号与密码继续</div>
          <el-form-item label="用户名" prop="username">
            <el-input v-model="form.username" placeholder="请输入用户名" />
          </el-form-item>
          <el-form-item label="密码" prop="password">
            <el-input v-model="form.password" type="password" show-password placeholder="请输入密码" />
          </el-form-item>
          <div class="form-actions">
            <el-button type="primary" class="form-button" :loading="loading" @click="handleLogin">
              登录
            </el-button>
            <el-button class="form-button form-button--ghost" @click="router.push('/register')">
              去注册
            </el-button>
          </div>
        </el-form>
      </div>
    </div>
  </div>
</template>

<style scoped>
.auth-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  background:
    radial-gradient(900px 420px at 12% 16%, rgba(22, 59, 102, 0.22), transparent 55%),
    radial-gradient(700px 380px at 88% 20%, rgba(15, 157, 138, 0.16), transparent 55%),
    linear-gradient(180deg, #ffffff 0%, var(--color-bg-page) 100%);
}

.auth-card {
  width: 1000px;
  max-width: 100%;
  display: grid;
  grid-template-columns: 1.15fr 0.85fr;
  overflow: hidden;
  border-radius: 22px;
  background: var(--color-bg-card);
  border: 1px solid var(--color-border);
  box-shadow: var(--shadow-card);
}

.auth-intro {
  position: relative;
  padding: 46px;
  color: #ffffff;
  background: linear-gradient(135deg, var(--color-primary) 0%, #0f2a45 60%, #0b1f33 100%);
}

.auth-intro::after {
  content: '';
  position: absolute;
  right: -120px;
  top: -120px;
  width: 260px;
  height: 260px;
  border-radius: 130px;
  background: radial-gradient(circle at 30% 30%, rgba(201, 169, 110, 0.55), transparent 58%);
  pointer-events: none;
}

.brand {
  display: flex;
  align-items: center;
  gap: 12px;
}

.brand__mark {
  width: 12px;
  height: 12px;
  border-radius: 6px;
  background: var(--color-gold);
}

.brand__name {
  font-size: 28px;
  font-weight: 900;
  letter-spacing: 0.6px;
}

.brand__sub {
  margin-top: 8px;
  opacity: 0.88;
}

.role-row {
  margin-top: 28px;
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.role-tag {
  border: none;
}

.role-tag--plain {
  color: #ffffff;
  border-color: rgba(255, 255, 255, 0.18);
}

.auth-form-wrap {
  padding: 46px;
}

.form-title {
  font-size: 22px;
  font-weight: 900;
  color: var(--color-text-1);
  margin-bottom: 8px;
}

.form-subtitle {
  color: var(--color-text-2);
  margin-bottom: 18px;
}

.form-actions {
  margin-top: 8px;
  display: grid;
  grid-template-columns: 1fr;
  gap: 10px;
}

.form-button {
  width: 100%;
}

.form-button--ghost {
  margin-left: 0;
}

@media (max-width: 900px) {
  .auth-card {
    grid-template-columns: 1fr;
  }

  .auth-intro,
  .auth-form-wrap {
    padding: 28px;
  }
}
</style>
