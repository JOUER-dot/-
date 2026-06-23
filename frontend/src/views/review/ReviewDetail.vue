<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'

import { approveReview, getReviewDetail, rejectReview, type ReviewDetail } from '@/api/review'

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const approving = ref(false)
const rejecting = ref(false)
const rejectDialogVisible = ref(false)

const rejectForm = reactive({
  comment: ''
})

const detail = reactive<ReviewDetail>({
  id: 0,
  name: '',
  type: '',
  riskLevel: '',
  strategyCode: '',
  status: '',
  creatorName: '',
  versionId: 0,
  versionNo: 0,
  versionStatus: '',
  submittedAt: '',
  featureTags: [],
  baseInfo: {},
  params: {},
  components: [],
  reviewSummary: []
})

const productId = computed(() => Number(route.params.id))

const loadDetail = async () => {
  loading.value = true
  try {
    const data = await getReviewDetail(productId.value)
    Object.assign(detail, data)
  } finally {
    loading.value = false
  }
}

const handleApprove = async () => {
  try {
    await ElMessageBox.confirm('确认审核通过吗？通过后产品将上架为 PUBLISHED。', '审核通过', {
      type: 'warning'
    })
  } catch {
    return
  }

  approving.value = true
  try {
    await approveReview(productId.value)
    ElMessage.success('审核通过成功')
    await router.replace('/review/pending')
  } finally {
    approving.value = false
  }
}

const submitReject = async () => {
  if (!rejectForm.comment.trim()) {
    ElMessage.error('驳回意见不能为空')
    return
  }

  rejecting.value = true
  try {
    await rejectReview(productId.value, { comment: rejectForm.comment.trim() })
    ElMessage.success('审核驳回成功')
    rejectDialogVisible.value = false
    await router.replace('/review/pending')
  } finally {
    rejecting.value = false
  }
}

void loadDetail()
</script>

<template>
  <div v-loading="loading" class="page-container">
    <div class="page-header">
      <div>
        <h1>审核详情</h1>
        <p>当前页面展示待审版本快照，审核动作直接作用于提交审核时生成的版本。</p>
      </div>
      <div class="header-actions">
        <el-button @click="router.push('/review/pending')">返回待审列表</el-button>
        <el-button type="success" :loading="approving" @click="handleApprove">审核通过</el-button>
        <el-button type="danger" :loading="rejecting" @click="rejectDialogVisible = true">审核驳回</el-button>
      </div>
    </div>

    <el-card shadow="never" class="section-card">
      <template #header>
        <div class="section-title">基本信息</div>
      </template>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="产品名称">{{ detail.name }}</el-descriptions-item>
        <el-descriptions-item label="策略编码">{{ detail.strategyCode || '-' }}</el-descriptions-item>
        <el-descriptions-item label="产品类型">{{ detail.type }}</el-descriptions-item>
        <el-descriptions-item label="风险等级">{{ detail.riskLevel }}</el-descriptions-item>
        <el-descriptions-item label="创建投顾">{{ detail.creatorName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="产品状态">{{ detail.status }}</el-descriptions-item>
        <el-descriptions-item label="待审版本">V{{ detail.versionNo }}</el-descriptions-item>
        <el-descriptions-item label="版本状态">{{ detail.versionStatus }}</el-descriptions-item>
        <el-descriptions-item label="提交时间">{{ detail.submittedAt || '-' }}</el-descriptions-item>
        <el-descriptions-item label="产品标签">
          <el-space wrap>
            <el-tag v-for="tag in detail.featureTags" :key="tag" effect="plain">{{ tag }}</el-tag>
          </el-space>
        </el-descriptions-item>
      </el-descriptions>
    </el-card>

    <el-card shadow="never" class="section-card">
      <template #header>
        <div class="section-title">基础信息快照</div>
      </template>
      <el-descriptions :column="1" border>
        <el-descriptions-item label="产品简介">
          {{ String(detail.baseInfo.productSummary || detail.baseInfo.intro || '-') }}
        </el-descriptions-item>
        <el-descriptions-item label="目标客户">
          {{ String(detail.baseInfo.targetCustomer || detail.baseInfo.targetUser || '-') }}
        </el-descriptions-item>
        <el-descriptions-item label="风险提示">
          {{ String(detail.baseInfo.riskTips || '-') }}
        </el-descriptions-item>
      </el-descriptions>
    </el-card>

    <el-card shadow="never" class="section-card">
      <template #header>
        <div class="section-title">策略参数快照</div>
      </template>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="调仓周期（天）">
          {{ String(detail.params.rebalanceCycleDays || '-') }}
        </el-descriptions-item>
        <el-descriptions-item label="单基金最小权重">
          {{ String(detail.params.minSingleFundWeight || '-') }}
        </el-descriptions-item>
        <el-descriptions-item label="单基金最大权重">
          {{ String(detail.params.maxSingleFundWeight || '-') }}
        </el-descriptions-item>
        <el-descriptions-item label="建议持有期（月）">
          {{ String(detail.params.investHorizonMonths || '-') }}
        </el-descriptions-item>
      </el-descriptions>
    </el-card>

    <el-card shadow="never" class="section-card">
      <template #header>
        <div class="section-title">基金成份快照</div>
      </template>
      <el-table :data="detail.components" border>
        <el-table-column prop="fundCode" label="基金代码" min-width="120" />
        <el-table-column prop="fundName" label="基金名称" min-width="180" />
        <el-table-column prop="fundType" label="基金类型" min-width="120" />
        <el-table-column prop="riskLevel" label="风险等级" width="100" />
        <el-table-column prop="weight" label="权重" width="120" />
      </el-table>
    </el-card>

    <el-card shadow="never" class="section-card">
      <template #header>
        <div class="section-title">历史审核记录</div>
      </template>
      <el-empty v-if="detail.reviewSummary.length === 0" description="暂无审核记录" />
      <el-timeline v-else>
        <el-timeline-item
          v-for="(item, index) in detail.reviewSummary"
          :key="index"
          :timestamp="item.reviewedAt"
        >
          <div class="review-title">{{ item.result }} / {{ item.reviewerName || '审核人' }}</div>
          <div class="review-comment">{{ item.comment || '无审核意见' }}</div>
        </el-timeline-item>
      </el-timeline>
    </el-card>

    <el-dialog v-model="rejectDialogVisible" title="审核驳回" width="560px">
      <el-form label-position="top">
        <el-form-item label="驳回意见" required>
          <el-input
            v-model="rejectForm.comment"
            type="textarea"
            :rows="4"
            maxlength="500"
            show-word-limit
            placeholder="请输入驳回原因"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="rejectDialogVisible = false">取消</el-button>
        <el-button type="danger" :loading="rejecting" @click="submitReject">确认驳回</el-button>
      </template>
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

.header-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.section-card {
  margin-bottom: 16px;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
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
