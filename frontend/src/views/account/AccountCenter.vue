<script setup lang="ts">
import { reactive, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import PageHeader from '@/components/common/PageHeader.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import { updateProfile } from '@/api/auth'

const router = useRouter()
const userStore = useUserStore()

const savingProfile = ref(false)
const loading = ref(true)

const profileForm = reactive({
  nickname: '',
  phone: '',
  email: ''
})

const initForm = () => {
  profileForm.nickname = userStore.userInfo?.nickname || ''
  profileForm.phone = userStore.userInfo?.phone || ''
  profileForm.email = userStore.userInfo?.email || ''
  loading.value = false
}

const handleSaveProfile = async () => {
  savingProfile.value = true
  try {
    await updateProfile(profileForm)
    ElMessage.success('个人信息更新成功')
    await userStore.restoreSession()
    initForm()
  } catch {
    ElMessage.error('更新失败')
  } finally {
    savingProfile.value = false
  }
}

const handleLogout = async () => {
  await userStore.logout()
  await router.replace('/login')
}

onMounted(() => {
  initForm()
})
</script>

<template>
  <PageContainer>
    <div class="app-page">
      <PageHeader title="账号中心">
        <template #actions>
          <el-button @click="handleLogout" type="danger" plain>退出登录</el-button>
        </template>
      </PageHeader>

      <!-- 个人信息概览 -->
      <div class="profile-hero">
        <div class="profile-hero__avatar">{{ (userStore.userInfo?.nickname || userStore.userInfo?.username || '?').slice(0, 1) }}</div>
        <div class="profile-hero__info">
          <div class="profile-hero__name">{{ userStore.userInfo?.nickname || userStore.userInfo?.username || '-' }}</div>
          <div class="profile-hero__meta">
            <span>@{{ userStore.userInfo?.username }}</span>
            <span class="profile-hero__divider">|</span>
            <span>{{ userStore.roles.join('、') || '-' }}</span>
          </div>
        </div>
      </div>

      <div class="account-grid">
        <!-- 个人信息 -->
        <SectionCard title="个人信息">
          <div v-loading="loading">
            <el-form :model="profileForm" label-position="top">
              <el-form-item label="用户名">
                <el-input :model-value="userStore.userInfo?.username" disabled />
              </el-form-item>
              <el-form-item label="昵称">
                <el-input v-model="profileForm.nickname" placeholder="请输入昵称" maxlength="64" />
              </el-form-item>
              <el-form-item label="手机号">
                <el-input v-model="profileForm.phone" placeholder="请输入手机号" maxlength="11" />
              </el-form-item>
              <el-form-item label="邮箱">
                <el-input v-model="profileForm.email" placeholder="请输入邮箱" maxlength="128" />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" :loading="savingProfile" @click="handleSaveProfile">保存修改</el-button>
              </el-form-item>
            </el-form>
          </div>
        </SectionCard>

        <!-- 账号信息 -->
        <SectionCard title="账号信息">
          <div v-loading="loading">
            <el-descriptions :column="1" border>
              <el-descriptions-item label="用户名">{{ userStore.userInfo?.username || '-' }}</el-descriptions-item>
              <el-descriptions-item label="昵称">{{ userStore.userInfo?.nickname || '-' }}</el-descriptions-item>
              <el-descriptions-item label="角色">{{ userStore.roles.join('、') || '-' }}</el-descriptions-item>
              <el-descriptions-item label="手机号">{{ userStore.userInfo?.phone || '未设置' }}</el-descriptions-item>
              <el-descriptions-item label="邮箱">{{ userStore.userInfo?.email || '未设置' }}</el-descriptions-item>
            </el-descriptions>
          </div>
        </SectionCard>
      </div>

      <!-- 快捷操作 -->
      <SectionCard title="快捷操作">
        <div class="quick-actions">
          <el-button @click="router.push('/my-subscriptions')" v-if="userStore.hasAnyRole(['USER'])">我的订阅</el-button>
          <el-button @click="router.push('/admin/products')" v-if="userStore.hasAnyRole(['ADVISOR'])">产品管理</el-button>
          <el-button @click="router.push('/review/pending')" v-if="userStore.hasAnyRole(['REVIEWER'])">待审列表</el-button>
          <el-button @click="handleLogout" type="danger" plain>退出登录</el-button>
        </div>
      </SectionCard>
    </div>
  </PageContainer>
</template>

<style scoped>
.app-page { display: flex; flex-direction: column; gap: 16px; }

.profile-hero {
  display: flex; align-items: center; gap: 20px;
  padding: 24px; border-radius: var(--radius-card);
  border: 1px solid var(--color-border);
  background: linear-gradient(180deg, var(--color-bg-card) 0%, #f8fafc 100%);
  box-shadow: var(--shadow-soft);
}

.profile-hero__avatar {
  width: 60px; height: 60px; border-radius: 50%;
  background: var(--brand-600); color: #fff;
  font-size: 26px; font-weight: 700;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}

.profile-hero__name {
  font-size: 22px; font-weight: 800; color: var(--color-text-1);
}

.profile-hero__meta {
  display: flex; align-items: center; gap: 8px;
  margin-top: 4px; font-size: 13px; color: var(--color-text-2);
}

.profile-hero__divider { color: var(--color-border-strong); }

.account-grid {
  display: grid; grid-template-columns: 1fr 1fr; gap: 16px;
}

@media (max-width: 768px) {
  .account-grid { grid-template-columns: 1fr; }
}

.security-info {
  display: flex; flex-direction: column; gap: 8px;
}

.security-info__item {
  display: flex; justify-content: space-between; align-items: center;
  padding: 8px 0;
}

.security-info__label { font-size: 13px; color: var(--color-text-2); }
.security-info__value { font-size: 14px; font-weight: 600; color: var(--color-text-1); }

.quick-actions {
  display: flex; flex-wrap: wrap; gap: 8px;
}
</style>
