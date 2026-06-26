<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import PageHeader from '@/components/common/PageHeader.vue'
import PageContainer from '@/components/ui/PageContainer.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import { getMyReviewHistory, type ReviewHistoryItem } from '@/api/review'
import { reviewResultLabel } from '@/utils/status'

const router = useRouter()
const loading = ref(false)
const records = ref<ReviewHistoryItem[]>([])

const pager = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const loadData = async () => {
  loading.value = true
  try {
    const data = await getMyReviewHistory(pager.pageNum, pager.pageSize)
    records.value = data
    pager.total = data.length
  } finally {
    loading.value = false
  }
}

const handleViewProduct = (productId: number) => {
  router.push(`/review/pending/${productId}`)
}

onMounted(() => {
  loadData()
})
</script>

<template>
  <PageContainer>
    <div class="app-page">
      <PageHeader title="我的审核记录" description="查看您历史上审核过的产品记录。" />

      <SectionCard title="审核历史">
        <el-table v-loading="loading" :data="records" border empty-text="暂无审核记录">
          <el-table-column label="产品名称" min-width="200">
            <template #default="{ row }">
              <el-button link type="primary" @click="handleViewProduct(row.productId)">
                {{ row.productName || `产品 #${row.productId}` }}
              </el-button>
            </template>
          </el-table-column>
          <el-table-column label="审核结果" width="120">
            <template #default="{ row }">
              <el-tag :type="row.result === 'APPROVED' ? 'success' : 'danger'" effect="plain">
                {{ reviewResultLabel(row.result) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="审核意见" min-width="200">
            <template #default="{ row }">
              <span class="comment-text">{{ row.comment || '-' }}</span>
            </template>
          </el-table-column>
          <el-table-column label="审核时间" width="180">
            <template #default="{ row }">{{ row.reviewedAt }}</template>
          </el-table-column>
          <el-table-column label="操作" width="120">
            <template #default="{ row }">
              <el-button link type="primary" @click="handleViewProduct(row.productId)">查看详情</el-button>
            </template>
          </el-table-column>
        </el-table>
      </SectionCard>
    </div>
  </PageContainer>
</template>

<style scoped>
.comment-text {
  color: var(--color-text-2);
  font-size: 13px;
}
</style>
