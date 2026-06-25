<script setup lang="ts">
import { computed, nextTick, reactive, ref, watch } from 'vue'
import { ElMessage, type TableInstance } from 'element-plus'

import { getFundList, type FundOption } from '@/api/fund'

const props = withDefaults(
  defineProps<{
    modelValue: boolean
    selectedFunds?: FundOption[]
  }>(),
  {
    selectedFunds: () => []
  }
)

const emit = defineEmits<{
  (e: 'update:modelValue', value: boolean): void
  (e: 'confirm', value: FundOption[]): void
}>()

const tableRef = ref<TableInstance>()
const loading = ref(false)
const records = ref<FundOption[]>([])
const total = ref(0)

const queryForm = reactive({
  keyword: '',
  fundType: ''
})

const pager = reactive({
  pageNum: 1,
  pageSize: 10
})

const selectedFundMap = ref<Record<number, FundOption>>({})

const dialogVisible = computed({
  get: () => props.modelValue,
  set: (value: boolean) => emit('update:modelValue', value)
})

const syncSelectedFunds = (funds: FundOption[]) => {
  const map: Record<number, FundOption> = {}
  funds.forEach((item) => {
    map[item.id] = item
  })
  selectedFundMap.value = map
}

const selectedFunds = computed(() => Object.values(selectedFundMap.value))

const fetchFunds = async () => {
  loading.value = true
  try {
    const data = await getFundList({
      keyword: queryForm.keyword || undefined,
      fundType: queryForm.fundType || undefined,
      pageNum: pager.pageNum,
      pageSize: pager.pageSize
    })
    records.value = data.records
    total.value = data.total

    await nextTick()
    records.value.forEach((row) => {
      if (selectedFundMap.value[row.id]) {
        tableRef.value?.toggleRowSelection(row, true)
      }
    })
  } finally {
    loading.value = false
  }
}

const handleSearch = async () => {
  pager.pageNum = 1
  await fetchFunds()
}

const handleReset = async () => {
  queryForm.keyword = ''
  queryForm.fundType = ''
  pager.pageNum = 1
  await fetchFunds()
}

const handleSelectionChange = (rows: FundOption[]) => {
  const currentPageIds = new Set(records.value.map((item) => item.id))
  const nextMap = { ...selectedFundMap.value }

  currentPageIds.forEach((id) => {
    delete nextMap[id]
  })

  rows.forEach((row) => {
    nextMap[row.id] = row
  })

  selectedFundMap.value = nextMap
}

const handlePageChange = async (pageNum: number) => {
  pager.pageNum = pageNum
  await fetchFunds()
}

const handleSizeChange = async (pageSize: number) => {
  pager.pageSize = pageSize
  pager.pageNum = 1
  await fetchFunds()
}

const handleClose = () => {
  dialogVisible.value = false
}

const handleConfirm = () => {
  if (selectedFunds.value.length === 0) {
    ElMessage.warning('请至少选择一只基金')
    return
  }
  emit('confirm', selectedFunds.value)
  dialogVisible.value = false
}

const handleRemoveSelected = (fundId: number) => {
  const nextMap = { ...selectedFundMap.value }
  delete nextMap[fundId]
  selectedFundMap.value = nextMap

  const targetRow = records.value.find((item) => item.id === fundId)
  if (targetRow) {
    tableRef.value?.toggleRowSelection(targetRow, false)
  }
}

watch(
  () => props.modelValue,
  async (visible) => {
    if (!visible) {
      return
    }
    syncSelectedFunds(props.selectedFunds)
    await fetchFunds()
  }
)

watch(
  () => props.selectedFunds,
  (funds) => {
    syncSelectedFunds(funds)
  },
  { deep: true }
)
</script>

<template>
  <el-dialog
    v-model="dialogVisible"
    title="选择基金"
    width="1000px"
    destroy-on-close
    @closed="handleClose"
  >
    <div class="search-panel">
      <el-form :inline="true" :model="queryForm">
        <el-form-item label="关键字">
          <el-input
            v-model="queryForm.keyword"
            placeholder="请输入基金代码或名称"
            clearable
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="基金类型">
          <el-input
            v-model="queryForm.fundType"
            placeholder="请输入基金类型"
            clearable
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="selected-panel" v-if="selectedFunds.length > 0">
      <div class="selected-title">已选基金</div>
      <div class="selected-tags">
        <el-tag
          v-for="fund in selectedFunds"
          :key="fund.id"
          closable
          type="primary"
          effect="plain"
          @close="handleRemoveSelected(fund.id)"
        >
          {{ fund.fundCode }} {{ fund.fundName }}
        </el-tag>
      </div>
    </div>

    <el-table
      ref="tableRef"
      v-loading="loading"
      :data="records"
      row-key="id"
      border
      height="420"
      @selection-change="handleSelectionChange"
    >
      <el-table-column type="selection" width="55" reserve-selection />
      <el-table-column prop="fundCode" label="基金代码" min-width="120" />
      <el-table-column prop="fundName" label="基金名称" min-width="200" />
      <el-table-column prop="fundType" label="基金类型" min-width="120" />
      <el-table-column prop="riskLevel" label="风险等级" min-width="100" />
      <el-table-column prop="companyName" label="基金公司" min-width="180" />
    </el-table>

    <div class="footer-bar">
      <el-pagination
        background
        layout="total, sizes, prev, pager, next"
        :current-page="pager.pageNum"
        :page-size="pager.pageSize"
        :page-sizes="[10, 20, 50]"
        :total="total"
        @current-change="handlePageChange"
        @size-change="handleSizeChange"
      />
    </div>

    <template #footer>
      <div class="dialog-footer">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleConfirm">
          确认选择（{{ selectedFunds.length }}）
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>

<style scoped>
.search-panel {
  margin-bottom: 12px;
  padding: 16px 16px 4px;
  border-radius: 12px;
  background: #f7f9fc;
}

.selected-panel {
  margin-bottom: 12px;
  padding: 12px 16px;
  border-radius: 12px;
  background: #f8fbff;
  border: 1px solid #e6f0ff;
}

.selected-title {
  margin-bottom: 10px;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.selected-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.footer-bar {
  margin-top: 16px;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 16px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
}

@media (max-width: 960px) {
  .footer-bar {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
