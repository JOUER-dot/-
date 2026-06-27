<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import PageHeader from '@/components/common/PageHeader.vue'
import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import { listAdminUsers, toggleUserStatus, setUserRole, type AdminUser } from '@/api/admin'

const loading = ref(false)
const users = ref<AdminUser[]>([])
const roleDialogVisible = ref(false)
const editingUser = ref<AdminUser | null>(null)
const selectedRole = ref('')

const roleOptions = [
  { label: '用户端', value: 'USER', desc: '浏览产品、订阅产品' },
  { label: '投顾端', value: 'ADVISOR', desc: '创建和管理组合产品' },
  { label: '审核员', value: 'REVIEWER', desc: '审核产品、通过/驳回' },
  { label: '管理员', value: 'ADMIN', desc: '管理用户和系统配置' }
]

const loadData = async () => {
  loading.value = true
  try { users.value = await listAdminUsers() } finally { loading.value = false }
}

const handleEditRole = (row: AdminUser) => {
  editingUser.value = row
  selectedRole.value = row.roles[0] || ''
  roleDialogVisible.value = true
}

const handleSaveRole = async () => {
  if (!editingUser.value || !selectedRole.value) return
  try {
    await setUserRole(editingUser.value.id, selectedRole.value)
    ElMessage.success('角色分配成功')
    roleDialogVisible.value = false
    await loadData()
  } catch { ElMessage.error('角色分配失败') }
}

const handleToggleStatus = async (row: AdminUser) => {
  const action = row.status === 1 ? '禁用' : '启用'
  try { await ElMessageBox.confirm(`确认${action}用户「${row.username}」吗？`, '提示', { type: 'warning' }) } catch { return }
  try {
    await toggleUserStatus(row.id, row.status !== 1)
    ElMessage.success(`${action}成功`)
    await loadData()
  } catch { ElMessage.error(`${action}失败`) }
}

const roleTagType = (roleCode: string) => {
  const map: Record<string, string> = { ADMIN: 'danger', REVIEWER: 'warning', ADVISOR: 'primary', USER: 'info' }
  return map[roleCode] || 'info'
}

onMounted(() => { loadData() })
</script>

<template>
  <PageContainer>
    <div class="app-page">
      <PageHeader title="用户管理" description="管理系统用户、状态和角色分配。" />
      <SectionCard title="用户列表">
        <el-table v-loading="loading" :data="users" border>
          <el-table-column label="ID" prop="id" width="60" />
          <el-table-column label="用户名" prop="username" min-width="120" />
          <el-table-column label="昵称" prop="nickname" min-width="120" />
          <el-table-column label="手机号" prop="phone" width="130" />
          <el-table-column label="邮箱" prop="email" min-width="160" />
          <el-table-column label="角色" min-width="200">
            <template #default="{ row }">
              <el-space wrap>
                <el-tag v-for="role in row.roles" :key="role" :type="roleTagType(role)" effect="plain" size="small">{{ role }}</el-tag>
              </el-space>
            </template>
          </el-table-column>
          <el-table-column label="状态" width="70">
            <template #default="{ row }">
              <el-tag :type="row.status === 1 ? 'success' : 'danger'" effect="plain" size="small">{{ row.status === 1 ? '正常' : '禁用' }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="注册时间" width="170"><template #default="{ row }">{{ row.createdAt }}</template></el-table-column>
          <el-table-column label="操作" width="180" fixed="right">
            <template #default="{ row }">
              <el-space>
                <el-button link type="primary" @click="handleEditRole(row)">分配角色</el-button>
                <el-button link :type="row.status === 1 ? 'danger' : 'success'" @click="handleToggleStatus(row)">{{ row.status === 1 ? '禁用' : '启用' }}</el-button>
              </el-space>
            </template>
          </el-table-column>
        </el-table>
      </SectionCard>

      <el-dialog v-model="roleDialogVisible" :title="editingUser ? `分配角色 - ${editingUser.nickname || editingUser.username}` : '分配角色'" width="460px">
        <el-radio-group v-model="selectedRole" class="role-radio-group">
          <label v-for="opt in roleOptions" :key="opt.value" class="role-radio" :class="{ selected: selectedRole === opt.value }">
            <el-radio :value="opt.value" size="large">
              <div class="role-radio-body">
                <div class="role-radio-label">{{ opt.label }}</div>
                <div class="role-radio-desc">{{ opt.desc }}</div>
              </div>
            </el-radio>
          </label>
        </el-radio-group>
        <template #footer>
          <el-button @click="roleDialogVisible = false">取消</el-button>
          <el-button type="primary" :disabled="!selectedRole" @click="handleSaveRole">保存</el-button>
        </template>
      </el-dialog>
    </div>
  </PageContainer>
</template>

<style scoped>
.role-list { display: flex; flex-direction: column; gap: 8px; }
.role-item {
  display: flex; align-items: center; gap: 14px; padding: 14px 16px;
  border: 1px solid var(--color-border); border-radius: 10px;
  cursor: pointer; transition: all .2s;
}
.role-item:hover { border-color: var(--color-primary); }
.role-item.selected { border-color: var(--color-primary); background: var(--brand-50); }
.role-checkbox {
  width: 20px; height: 20px; border-radius: 4px;
  border: 2px solid var(--color-border-strong);
  display: flex; align-items: center; justify-content: center;
  transition: all .2s;
}
.role-checkbox.checked { background: var(--color-primary); border-color: var(--color-primary); }
.role-body { flex: 1; }
.role-label { font-weight: 600; font-size: 14px; color: var(--color-text-1); }
.role-desc { font-size: 12px; color: var(--color-text-3); margin-top: 2px; }
.role-radio-group {
  display: flex; flex-direction: column; gap: 8px; width: 100%;
}
.role-radio {
  display: flex; align-items: center; padding: 12px 16px;
  border: 1px solid var(--color-border); border-radius: 10px;
  cursor: pointer; transition: all .2s;
}
.role-radio:hover { border-color: var(--color-primary); }
.role-radio.selected { border-color: var(--color-primary); background: var(--brand-50); }
.role-radio :deep(.el-radio) { display: flex; align-items: center; width: 100%; }
.role-radio :deep(.el-radio__label) { width: 100%; padding-left: 10px; }
.role-radio-body { display: flex; flex-direction: column; gap: 2px; }
.role-radio-label { font-weight: 600; font-size: 14px; color: var(--color-text-1); }
.role-radio-desc { font-size: 12px; color: var(--color-text-3); }
</style>
