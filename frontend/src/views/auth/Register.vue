<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'

import request from '@/utils/request'

const router = useRouter()
const loading = ref(false)
const formRef = ref<FormInstance>()

const form = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  nickname: '',
  phone: ''
})

const rules: FormRules<typeof form> = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 4, max: 20, message: '用户名长度必须为4~20位', trigger: 'blur' },
    { pattern: /^[A-Za-z0-9_]+$/, message: '用户名只能包含字母、数字和下划线', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度必须为6~20位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请输入确认密码', trigger: 'blur' },
    {
      validator: (_rule, value, callback) => {
        if (value !== form.password) {
          callback(new Error('两次密码输入不一致'))
          return
        }
        callback()
      },
      trigger: 'blur'
    }
  ],
  phone: [
    {
      pattern: /^$|^1\d{10}$/,
      message: '手机号格式不正确',
      trigger: 'blur'
    }
  ]
}

const handleRegister = async () => {
  if (!formRef.value) {
    return
  }
  await formRef.value.validate(async (valid) => {
    if (!valid) {
      return
    }
    loading.value = true
    try {
      await request.post('/auth/register', form)
      ElMessage.success('注册成功，请登录')
      await router.replace('/login')
    } finally {
      loading.value = false
    }
  })
}
</script>

<template>
  <div class="auth-page">
    <div class="register-card">
      <div class="register-header">
        <h1>用户注册</h1>
        <p>普通用户注册后默认分配 USER 角色。</p>
      </div>

      <el-form ref="formRef" :model="form" :rules="rules" label-position="top">
        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="用户名" prop="username">
              <el-input v-model="form.username" placeholder="4~20位字母数字下划线" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="昵称" prop="nickname">
              <el-input v-model="form.nickname" placeholder="请输入昵称" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="16">
          <el-col :span="12">
            <el-form-item label="密码" prop="password">
              <el-input v-model="form.password" type="password" show-password placeholder="请输入密码" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="确认密码" prop="confirmPassword">
              <el-input
                v-model="form.confirmPassword"
                type="password"
                show-password
                placeholder="请再次输入密码"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="手机号" prop="phone">
          <el-input v-model="form.phone" placeholder="可选，11位手机号" />
        </el-form-item>

        <div class="button-row">
          <el-button type="primary" :loading="loading" @click="handleRegister">注册</el-button>
          <el-button @click="router.push('/login')">返回登录</el-button>
        </div>
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
  background: #f5f7fa;
}

.register-card {
  width: 760px;
  max-width: 100%;
  padding: 36px;
  border-radius: 18px;
  background: #ffffff;
  box-shadow: 0 16px 40px rgba(31, 35, 41, 0.1);
}

.register-header {
  margin-bottom: 12px;
}

.register-header h1 {
  margin: 0 0 8px;
  color: #303133;
}

.register-header p {
  margin: 0 0 20px;
  color: #606266;
}

.button-row {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}

@media (max-width: 768px) {
  .button-row {
    flex-direction: column;
  }
}
</style>
