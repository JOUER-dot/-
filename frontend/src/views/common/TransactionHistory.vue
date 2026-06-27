<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import PageHeader from '@/components/common/PageHeader.vue'
import PageContainer from '@/components/ui/PageContainer.vue'
import { getMyTransactions, type TransactionItem } from '@/api/transaction'
import { formatText } from '@/utils/format'

const router = useRouter()
const loading = ref(false)
const records = ref<TransactionItem[]>([])
const pager = reactive({ pageNum: 1, pageSize: 20, total: 0 })

const loadData = async () => {
  loading.value = true
  try {
    const data = await getMyTransactions(pager.pageNum, pager.pageSize)
    records.value = data.records
    pager.total = data.total
  } finally { loading.value = false }
}

const typeLabel = (t: string) => t === 'SUBSCRIBE' ? '订阅' : t === 'UNSUBSCRIBE' ? '取消订阅' : t
const fmtAmount = (v: number) => v ? '¥' + v.toLocaleString() : '-'

onMounted(() => loadData())
</script>

<template>
  <PageContainer>
    <div class="app-page">
      <PageHeader title="交易记录" description="查看您的订阅和购买记录" />
      <el-table v-loading="loading" :data="records" border empty-text="暂无交易记录">
        <el-table-column label="产品名称" min-width="180">
          <template #default="{ row }">
            <el-button link type="primary" @click="router.push(`/advisor-zone/${row.productId}`)">{{ row.productName }}</el-button>
          </template>
        </el-table-column>
        <el-table-column label="类型" width="120"><template #default="{ row }">{{ typeLabel(row.type) }}</template></el-table-column>
        <el-table-column label="金额" width="160"><template #default="{ row }">{{ fmtAmount(row.amount) }}</template></el-table-column>
        <el-table-column label="时间" width="180"><template #default="{ row }">{{ formatText(row.createdAt) }}</template></el-table-column>
      </el-table>
      <div class="pagination-bar">
        <el-pagination background layout="prev, pager, next" :total="pager.total" :page-size="pager.pageSize"
          @current-change="(p: number) => { pager.pageNum = p; loadData() }" />
      </div>
    </div>
  </PageContainer>
</template>
<style scoped>
.pagination-bar { display: flex; justify-content: center; margin-top: 16px; }
</style>
