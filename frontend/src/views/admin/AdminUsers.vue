<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import PageHeader from '@/components/common/PageHeader.vue'
import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import { listAdminUsers, toggleUserStatus, assignUserRole, type AdminUser } from '@/api/admin'

const loading = ref(false)
const users = ref<AdminUser[]>([])

const roleOptions = [
  { label: '用户', value: 'USER' },
  { label: '投顾', value: 'ADVISOR' },
  { label: '审核员', value: 'REVIEWER' },
  { label: '管理员', value: 'ADMIN' }
]

const loadData = async () => {
  loading.value = true
  try {
    users.value = await listAdminUsers()
  } finally {
    loading.value = false
  }
}

const handleToggleStatus = async (row: AdminUser) => {
  const action = row.status === 1 ? '禁用' : '启用'
  try {
    await ElMessageBox.confirm(`确认${action}用户「${row.username}」吗？`, '提示', { type: 'warning' })
  } catch {
    return
  }
  try {
    await toggleUserStatus(row.id, row.status !== 1)
    ElMessage.success(`${action}成功`)
    await loadData()
  } catch {
    ElMessage.error(`${action}失败`)
  }
}

const handleAssignRole = async (row: AdminUser, roleCode: string) => {
  try {
    await assignUserRole(row.id, roleCode)
    ElMessage.success('角色分配成功')
    await loadData()
  } catch {
    ElMessage.error('角色分配失败')
  }
}

const roleTagType = (roleCode: string) => {
  const map: Record<string, string> = {
    ADMIN: 'danger',
    REVIEWER: 'warning',
    ADVISOR: 'primary',
    USER: 'info'
  }
  return map[roleCode] || 'info'
}

onMounted(() => {
  loadData()
})
</script>

<template>
  <PageContainer>
    <div class="app-page">
      <PageHeader title="用户管理" description="管理系统用户、角色和状态。" />

      <SectionCard title="用户列表">
        <el-table v-loading="loading" :data="users" border>
          <el-table-column label="ID" prop="id" width="80" />
          <el-table-column label="用户名" prop="username" min-width="120" />
          <el-table-column label="昵称" prop="nickname" min-width="120" />
          <el-table-column label="手机号" prop="phone" width="130" />
          <el-table-column label="邮箱" prop="email" min-width="160" />
          <el-table-column label="角色" min-width="200">
            <template #default="{ row }">
              <el-space wrap>
                <el-tag v-for="role in row.roles" :key="role" :type="roleTagType(role)" effect="plain" size="small">
                  {{ role }}
                </el-tag>
              </el-space>
            </template>
          </el-table-column>
          <el-table-column label="状态" width="80">
            <template #default="{ row }">
              <el-tag :type="row.status === 1 ? 'success' : 'danger'" effect="plain" size="small">
                {{ row.status === 1 ? '正常' : '禁用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="注册时间" width="180">
            <template #default="{ row }">{{ row.createdAt }}</template>
          </el-table-column>
          <el-table-column label="操作" width="240" fixed="right">
            <template #default="{ row }">
              <el-space>
                <el-button link :type="row.status === 1 ? 'danger' : 'success'" @click="handleToggleStatus(row)">
                  {{ row.status === 1 ? '禁用' : '启用' }}
                </el-button>
                <el-dropdown @command="(cmd: string) => handleAssignRole(row, cmd)">
                  <el-button link type="primary">分配角色 <el-icon><arrow-down /></el-icon></el-button>
                  <template #dropdown>
                    <el-dropdown-menu>
                      <el-dropdown-item v-for="opt in roleOptions" :key="opt.value" :command="opt.value">
                        {{ opt.label }}
                      </el-dropdown-item>
                    </el-dropdown-menu>
                  </template>
                </el-dropdown>
              </el-space>
            </template>
          </el-table-column>
        </el-table>
      </SectionCard>
    </div>
  </PageContainer>
</template>

<style scoped>
/* inherits global styles */
</style>
