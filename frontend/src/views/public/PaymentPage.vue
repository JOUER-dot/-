<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import PageContainer from '@/components/ui/PageContainer.vue'
import { getPublishedProductDetail, type PublicProductDetail } from '@/api/public-product'
import { subscribeProduct } from '@/api/subscription'
import { formatText } from '@/utils/format'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const paying = ref(false)
const done = ref(false)
const product = ref<PublicProductDetail | null>(null)

const productId = computed(() => Number(route.params.id))
const amount = computed(() => Number(route.query.amount || 0))
const productName = computed(() => product.value?.name || '产品')

onMounted(async () => {
  loading.value = true
  try {
    product.value = await getPublishedProductDetail(productId.value)
  } finally { loading.value = false }
})

const handlePay = async () => {
  paying.value = true
  // 模拟支付过程
  await new Promise((r) => setTimeout(r, 1000))
  try {
    await subscribeProduct(productId.value, amount.value)
    done.value = true
    ElMessage.success('订阅成功')
  } catch {
    ElMessage.error('订阅失败')
  } finally { paying.value = false }
}
</script>

<template>
  <PageContainer>
    <div class="pay-page">
      <div class="pay-card">
        <div v-if="loading" class="pay-loading">加载中...</div>
        <div v-else-if="done" class="pay-done">
          <div class="pay-icon">✓</div>
          <h2>订阅成功</h2>
          <p>您已成功订阅「{{ productName }}」</p>
          <div class="pay-actions">
            <el-button type="primary" @click="router.push('/my-subscriptions')">查看我的订阅</el-button>
            <el-button @click="router.push('/advisor-zone')">返回产品中心</el-button>
          </div>
        </div>
        <div v-else>
          <h2 class="pay-title">确认支付</h2>
          <div class="pay-product">
            <div class="pay-label">产品名称</div>
            <div class="pay-value">{{ productName }}</div>
          </div>
          <div class="pay-product">
            <div class="pay-label">投入金额</div>
            <div class="pay-value pay-amount">{{ amount.toLocaleString() }} 元</div>
          </div>
          <div class="pay-note">本次为模拟支付，不会产生实际扣款</div>
          <div class="pay-actions">
            <el-button type="primary" size="large" :loading="paying" @click="handlePay" class="pay-btn">确认支付</el-button>
            <el-button size="large" @click="router.back()">返回</el-button>
          </div>
        </div>
      </div>
    </div>
  </PageContainer>
</template>

<style scoped>
.pay-page { display: flex; justify-content: center; padding: 40px 0; }
.pay-card { width: 440px; max-width: 100%; }
.pay-loading { text-align: center; padding: 60px; color: var(--color-text-3); }
.pay-title { font-size: 24px; font-weight: 800; color: var(--color-text-1); margin-bottom: 24px; text-align: center; }
.pay-product { display: flex; justify-content: space-between; padding: 14px 16px; border: 1px solid var(--color-border); border-radius: 10px; margin-bottom: 10px; }
.pay-label { color: var(--color-text-3); font-size: 14px; }
.pay-value { font-weight: 700; color: var(--color-text-1); }
.pay-amount { font-size: 20px; color: var(--danger-600); }
.pay-note { text-align: center; color: var(--color-text-3); font-size: 12px; margin: 16px 0; }
.pay-actions { display: flex; flex-direction: column; gap: 10px; margin-top: 20px; }
.pay-btn { height: 48px; font-size: 16px; }
.pay-done { text-align: center; padding: 40px 0; }
.pay-icon { width: 64px; height: 64px; border-radius: 50%; background: var(--success-600); color: #fff; font-size: 32px; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px; }
.pay-done h2 { font-size: 22px; font-weight: 800; color: var(--color-text-1); margin: 0 0 8px; }
.pay-done p { color: var(--color-text-2); margin: 0 0 24px; }
</style>
