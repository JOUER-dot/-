<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'

import { getPublishedProductList, type PublicProductListItem } from '@/api/public-product'

const router = useRouter()

const loading = ref(false)
const records = ref<PublicProductListItem[]>([])

const queryForm = reactive({
  keyword: '',
  type: '',
  riskLevel: ''
})

const pager = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const typeOptions = ['FOF', 'STRATEGY']
const riskOptions = ['R1', 'R2', 'R3', 'R4', 'R5']

const loadData = async () => {
  loading.value = true
  try {
    const data = await getPublishedProductList({
      keyword: queryForm.keyword || undefined,
      type: queryForm.type || undefined,
      riskLevel: queryForm.riskLevel || undefined,
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
  queryForm.keyword = ''
  queryForm.type = ''
  queryForm.riskLevel = ''
  pager.pageNum = 1
  await loadData()
}

onMounted(() => {
  void loadData()
})
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <div>
        <h1>基金投顾产品专区</h1>
        <p>专区仅展示已上架产品，详情基于已发布版本数据。</p>
      </div>
    </div>

    <el-card shadow="never" class="search-card">
      <el-form :inline="true" :model="queryForm">
        <el-form-item label="关键字">
          <el-input
            v-model="queryForm.keyword"
            clearable
            placeholder="产品名称或策略编码"
            @keyup.enter="handleSearch"
          />
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
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-row v-loading="loading" :gutter="16">
      <el-col v-for="item in records" :key="item.id" :xs="24" :sm="12" :lg="8">
        <el-card shadow="hover" class="product-card" @click="router.push(`/advisor-zone/${item.id}`)">
          <div class="product-card__head">
            <h3>{{ item.name }}</h3>
            <el-tag>{{ item.riskLevel }}</el-tag>
          </div>
          <div class="product-meta">
            <span>类型：{{ item.type }}</span>
            <span>策略：{{ item.strategyCode || '-' }}</span>
          </div>
          <div class="tag-list">
            <el-tag v-for="tag in item.featureTags" :key="tag" effect="plain" size="small">
              {{ tag }}
            </el-tag>
          </div>
          <div class="nav-summary">
            <div>
              <span class="nav-label">最新净值</span>
              <strong>{{ item.latestNav ?? '-' }}</strong>
            </div>
            <div>
              <span class="nav-label">累计收益</span>
              <strong>{{ item.latestCumReturn ?? '-' }}</strong>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="never" class="pager-card">
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

.search-card,
.pager-card {
  margin-bottom: 16px;
}

.product-card {
  margin-bottom: 16px;
  cursor: pointer;
}

.product-card__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 12px;
}

.product-card__head h3 {
  margin: 0;
  font-size: 18px;
  color: #303133;
}

.product-meta {
  display: grid;
  gap: 8px;
  margin-bottom: 12px;
  color: #606266;
}

.tag-list {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin-bottom: 16px;
}

.nav-summary {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.nav-summary strong {
  display: block;
  margin-top: 6px;
  font-size: 18px;
  color: #303133;
}

.nav-label {
  color: #909399;
  font-size: 13px;
}

.pagination-bar {
  display: flex;
  justify-content: flex-end;
}
</style>
