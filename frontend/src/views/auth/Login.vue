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
        <h1>智能投顾平台</h1>
        <p>组合产品管理子系统</p>
        <span>统一登录入口，支持 USER、ADVISOR、REVIEWER 三类角色。</span>
      </div>

      <el-form ref="formRef" :model="form" :rules="rules" label-position="top" class="auth-form">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="form.password" type="password" show-password placeholder="请输入密码" />
        </el-form-item>
        <el-button type="primary" class="auth-button" :loading="loading" @click="handleLogin">
          登录
        </el-button>
        <el-button class="auth-button auth-button-secondary" @click="router.push('/register')">
          去注册
        </el-button>
      </el-form>
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
  background: linear-gradient(135deg, #eef5ff 0%, #f7fbff 100%);
}

.auth-card {
  width: 960px;
  max-width: 100%;
  display: grid;
  grid-template-columns: 1.1fr 0.9fr;
  overflow: hidden;
  border-radius: 20px;
  background: #ffffff;
  box-shadow: 0 18px 48px rgba(31, 35, 41, 0.12);
}

.auth-intro {
  padding: 48px;
  color: #ffffff;
  background: linear-gradient(135deg, #2d6cff 0%, #5a8cff 100%);
}

.auth-intro h1 {
  margin: 0 0 16px;
  font-size: 34px;
}

.auth-intro p {
  margin: 0 0 12px;
  font-size: 20px;
}

.auth-intro span {
  line-height: 1.8;
  opacity: 0.92;
}

.auth-form {
  padding: 48px;
}

.auth-button {
  width: 100%;
  margin-top: 8px;
}

.auth-button-secondary {
  margin-left: 0;
}

@media (max-width: 860px) {
  .auth-card {
    grid-template-columns: 1fr;
  }
}
</style>
