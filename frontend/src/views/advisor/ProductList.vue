<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import {
  getProductList,
  getProductReviews,
  submitProduct,
  withdrawProduct,
  type ProductListItem,
  type ReviewRecord
} from '@/api/product'

const router = useRouter()

const loading = ref(false)
const reviewLoading = ref(false)
const reviewDialogVisible = ref(false)
const reviewRecords = ref<ReviewRecord[]>([])

const queryForm = reactive({
  status: '',
  type: '',
  riskLevel: '',
  keyword: ''
})

const pager = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const records = ref<ProductListItem[]>([])

const statusOptions = ['DRAFT', 'PENDING_REVIEW', 'REJECTED', 'PUBLISHED', 'OFFLINE']
const typeOptions = ['稳健型', '平衡型', '进取型']
const riskOptions = ['R1', 'R2', 'R3', 'R4', 'R5']

const loadData = async () => {
  loading.value = true
  try {
    const data = await getProductList({
      ...queryForm,
      status: queryForm.status || undefined,
      type: queryForm.type || undefined,
      riskLevel: queryForm.riskLevel || undefined,
      keyword: queryForm.keyword || undefined,
      pageNum: pager.pageNum,
      pageSize: pager.pageSize
    })
    records.value = data.records
    pager.total = data.total
  } finally {
    loading.value = false
  }
}

const handleSearch = async () => {
  pager.pageNum = 1
  await loadData()
}

const handleReset = async () => {
  queryForm.status = ''
  queryForm.type = ''
  queryForm.riskLevel = ''
  queryForm.keyword = ''
  pager.pageNum = 1
  await loadData()
}

const handleSubmit = async (row: ProductListItem) => {
  try {
    await ElMessageBox.confirm('确认提交审核吗？', '提交审核', { type: 'warning' })
  } catch {
    return
  }
  await submitProduct(row.id)
  ElMessage.success('提交审核成功')
  await loadData()
}

const handleWithdraw = async (row: ProductListItem) => {
  try {
    await ElMessageBox.confirm('确认撤回审核吗？', '撤回审核', { type: 'warning' })
  } catch {
    return
  }
  await withdrawProduct(row.id)
  ElMessage.success('撤回审核成功')
  await loadData()
}

const openReviews = async (row: ProductListItem) => {
  reviewLoading.value = true
  reviewDialogVisible.value = true
  try {
    reviewRecords.value = await getProductReviews(row.id)
  } finally {
    reviewLoading.value = false
  }
}

onMounted(() => {
  void loadData()
})
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <div>
        <h1>组合产品管理</h1>
        <p>投顾仅可查看和操作自己创建的产品，草稿编辑、提交审核和撤回审核都从这里进入。</p>
      </div>
      <el-button type="primary" @click="router.push('/admin/products/create')">创建产品</el-button>
    </div>

    <el-card shadow="never" class="search-card">
      <el-form :inline="true" :model="queryForm">
        <el-form-item label="产品状态">
          <el-select v-model="queryForm.status" clearable placeholder="全部">
            <el-option v-for="item in statusOptions" :key="item" :label="item" :value="item" />
          </el-select>
        </el-form-item>
        <el-form-item label="产品类型">
          <el-select v-model="queryForm.type" clearable placeholder="全部">
            <el-option v-for="item in typeOptions" :key="item" :label="item" :value="item" />
          </el-select>
        </el-form-item>
        <el-form-item label="风险等级">
          <el-select v-model="queryForm.riskLevel" clearable placeholder="全部">
            <el-option v-for="item in riskOptions" :key="item" :label="item" :value="item" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键字">
          <el-input
            v-model="queryForm.keyword"
            placeholder="产品名称或策略编码"
            clearable
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card shadow="never">
      <el-table v-loading="loading" :data="records" border>
        <el-table-column prop="name" label="产品名称" min-width="180" />
        <el-table-column prop="type" label="产品类型" width="120" />
        <el-table-column prop="riskLevel" label="风险等级" width="100" />
        <el-table-column label="产品标签" min-width="180">
          <template #default="{ row }">
            <el-space wrap>
              <el-tag v-for="tag in row.featureTags" :key="tag" effect="plain">{{ tag }}</el-tag>
            </el-space>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="150">
          <template #default="{ row }">
            <el-tag :type="row.status === 'PUBLISHED' ? 'success' : row.status === 'REJECTED' ? 'danger' : 'info'">
              {{ row.status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="updatedAt" label="最后更新时间" min-width="180" />
        <el-table-column label="操作" min-width="320" fixed="right">
          <template #default="{ row }">
            <el-space wrap>
              <el-button
                v-if="row.status === 'DRAFT' || row.status === 'REJECTED'"
                link
                type="primary"
                @click="router.push(`/admin/products/${row.id}/edit`)"
              >
                编辑草稿
              </el-button>
              <el-button
                v-if="row.status === 'DRAFT' || row.status === 'REJECTED'"
                link
                type="success"
                @click="handleSubmit(row)"
              >
                提交审核
              </el-button>
              <el-button
                v-if="row.status === 'PENDING_REVIEW' || row.status === 'PUBLISHED' || row.status === 'OFFLINE'"
                link
                @click="router.push(`/admin/products/${row.id}`)"
              >
                查看详情
              </el-button>
              <el-button
                v-if="row.status === 'PENDING_REVIEW'"
                link
                type="warning"
                @click="handleWithdraw(row)"
              >
                撤回审核
              </el-button>
              <el-button link @click="openReviews(row)">审核记录</el-button>
              <el-button
                v-if="row.status === 'REJECTED' && row.lastRejectComment"
                link
                type="danger"
                @click="ElMessageBox.alert(row.lastRejectComment, '驳回意见')"
              >
                驳回意见
              </el-button>
            </el-space>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-bar">
        <el-pagination
          background
          layout="total, sizes, prev, pager, next"
          :current-page="pager.pageNum"
          :page-size="pager.pageSize"
          :page-sizes="[10, 20, 50]"
          :total="pager.total"
          @current-change="
            (page: number) => {
              pager.pageNum = page
              loadData()
            }
          "
          @size-change="
            (size: number) => {
              pager.pageSize = size
              pager.pageNum = 1
              loadData()
            }
          "
        />
      </div>
    </el-card>

    <el-dialog v-model="reviewDialogVisible" title="审核记录" width="720px">
      <div v-loading="reviewLoading">
        <el-empty v-if="reviewRecords.length === 0" description="暂无审核记录" />
        <el-timeline v-else>
          <el-timeline-item
            v-for="(item, index) in reviewRecords"
            :key="index"
            :timestamp="item.reviewedAt"
          >
            <div class="review-title">{{ item.result }} / {{ item.reviewerName || '审核人' }}</div>
            <div class="review-comment">{{ item.comment || '无审核意见' }}</div>
          </el-timeline-item>
        </el-timeline>
      </div>
    </el-dialog>
  </div>
</template>

<style scoped>
.page-container {
  min-height: calc(100vh - 48px);
  padding: 24px;
  background: #f5f7fa;
}

.page-header {
  margin-bottom: 16px;
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
}

.page-header h1 {
  margin: 0 0 8px;
  font-size: 28px;
  color: #303133;
}

.page-header p {
  margin: 0;
  color: #606266;
}

.search-card {
  margin-bottom: 16px;
}

.pagination-bar {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}

.review-title {
  margin-bottom: 6px;
  font-weight: 600;
  color: #303133;
}

.review-comment {
  color: #606266;
  line-height: 1.7;
}
</style>
