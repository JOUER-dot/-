<script setup lang="ts">
import { reactive, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import PageHeader from '@/components/common/PageHeader.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import { updateProfile, changePassword, deleteAccount, setPin, verifyPassword } from '@/api/auth'

const router = useRouter()
const userStore = useUserStore()

const savingProfile = ref(false)
const savingPassword = ref(false)
const savingPin = ref(false)
const showPinSetup = ref(false)
const pinLoginPass = ref('')
const newPin = ref('')
const confirmPin = ref('')
const loading = ref(true)

const profileForm = reactive({
  nickname: '',
  phone: '',
  email: ''
})

const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
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

const handleChangePassword = async () => {
  if (!passwordForm.oldPassword) { ElMessage.warning('请输入当前密码'); return }
  if (passwordForm.newPassword.length < 6) { ElMessage.warning('新密码长度不能小于6位'); return }
  if (passwordForm.newPassword !== passwordForm.confirmPassword) { ElMessage.warning('两次密码输入不一致'); return }
  savingPassword.value = true
  try {
    await changePassword(passwordForm)
    ElMessage.success('密码修改成功')
    passwordForm.oldPassword = ''
    passwordForm.newPassword = ''
    passwordForm.confirmPassword = ''
  } catch {
    ElMessage.error('密码修改失败')
  } finally {
    savingPassword.value = false
  }
}

const openPinSetup = () => {
  pinLoginPass.value = ''
  newPin.value = ''
  confirmPin.value = ''
  showPinSetup.value = true
}

const savePin = async () => {
  if (!pinLoginPass.value) { ElMessage.warning('请输入登录密码验证'); return }
  if (!/^\d{6}$/.test(newPin.value)) { ElMessage.warning('交易密码必须为6位数字'); return }
  if (newPin.value !== confirmPin.value) { ElMessage.warning('两次交易密码输入不一致'); return }
  try {
    await verifyPassword(pinLoginPass.value)
    await setPin(newPin.value)
    ElMessage.success('交易密码设置成功')
    showPinSetup.value = false
  } catch (e: any) {
    ElMessage.error(e?.message || '设置失败')
  }
}

const handleLogout = async () => {
  await userStore.logout()
  await router.replace('/login')
}

const handleDeleteAccount = async () => {
  try {
    await ElMessageBox.confirm(
      '确认注销账号吗？注销后账号将无法恢复。\n若有已上架产品，请先下架后再注销。',
      '注销账号',
      { confirmButtonText: '确认注销', confirmButtonClass: 'el-button--danger', type: 'warning' }
    )
  } catch { return }
  try {
    await deleteAccount()
    ElMessage.success('账号已注销')
    await userStore.logout(false)
    await router.replace('/login')
  } catch (e: any) {
    ElMessage.error(e?.message || '注销失败')
  }
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

      <!-- 安全设置 -->
      <SectionCard title="安全设置">
        <el-form :model="passwordForm" label-position="top">
          <el-form-item label="当前密码">
            <el-input v-model="passwordForm.oldPassword" type="password" show-password placeholder="请输入当前密码" />
          </el-form-item>
          <el-form-item label="新密码">
            <el-input v-model="passwordForm.newPassword" type="password" show-password placeholder="6~20位，区分大小写" />
          </el-form-item>
          <el-form-item label="确认新密码">
            <el-input v-model="passwordForm.confirmPassword" type="password" show-password placeholder="请再次输入新密码" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="savingPassword" @click="handleChangePassword">修改密码</el-button>
          </el-form-item>
        </el-form>
        <el-divider />
        <div v-if="userStore.hasAnyRole(['USER'])" style="display:flex;justify-content:space-between;align-items:center">
          <div>
            <div style="font-weight:600;font-size:14px;">交易密码</div>
            <div style="font-size:12px;color:var(--color-text-3);margin-top:2px;">用于订阅产品时的安全验证</div>
          </div>
          <el-button size="small" @click="openPinSetup">设置交易密码</el-button>
        </div>
      </SectionCard>

      <!-- 危险操作 -->
      <SectionCard title="危险操作">
        <el-alert title="注销账号后数据将无法恢复，请谨慎操作" type="warning" :closable="false" show-icon />
        <div style="margin-top:12px">
          <el-button type="danger" plain @click="handleDeleteAccount">注销账号</el-button>
        </div>
      </SectionCard>

      <!-- 交易密码设置弹窗 -->
      <el-dialog v-model="showPinSetup" title="设置交易密码" width="400px">
        <el-alert title="交易密码设置后不可修改，请牢记" type="warning" :closable="false" show-icon style="margin-bottom:16px" />
        <p style="margin:0 0 16px;color:var(--color-text-2);font-size:13px;">请先验证登录密码，然后设置6位数字交易密码</p>
        <el-form label-position="top">
          <el-form-item label="登录密码">
            <el-input v-model="pinLoginPass" type="password" show-password placeholder="请输入登录密码验证身份" size="large" />
          </el-form-item>
          <el-form-item label="交易密码（6位数字）">
            <el-input v-model="newPin" maxlength="6" placeholder="请设置6位数字" size="large" />
          </el-form-item>
          <el-form-item label="确认交易密码">
            <el-input v-model="confirmPin" maxlength="6" placeholder="请再次输入6位数字" size="large" />
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="showPinSetup = false">取消</el-button>
          <el-button type="primary" @click="savePin">保存</el-button>
        </template>
      </el-dialog>

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
