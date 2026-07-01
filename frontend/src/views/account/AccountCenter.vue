<script setup lang="ts">
import { computed, reactive, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import PageHeader from '@/components/common/PageHeader.vue'
import SectionCard from '@/components/ui/SectionCard.vue'
import { updateProfile, changePassword, deleteAccount, setPin, verifyPassword } from '@/api/auth'
import { getRiskProfile, submitRiskAssessment, type RiskAssessmentPayload, type RiskProfile } from '@/api/risk-profile'
import { formatPercent } from '@/utils/format'

const router = useRouter()
const userStore = useUserStore()

const savingProfile = ref(false)
const savingPassword = ref(false)
const savingPin = ref(false)
const showPinSetup = ref(false)
const showRiskAssessment = ref(false)
const pinLoginPass = ref('')
const newPin = ref('')
const confirmPin = ref('')
const loading = ref(true)
const riskProfileLoading = ref(false)
const savingRiskAssessment = ref(false)
const riskProfile = ref<RiskProfile | null>(null)

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

const riskForm = reactive({
  incomeRange: 'MID',
  assetRange: 'MID',
  investmentGoal: 'GROWTH',
  experienceLevel: 'BEGINNER',
  liquidityNeed: 'MEDIUM',
  investmentHorizonMonths: 24,
  maxDrawdownTolerance: 0.08,
  lossReaction: 'HOLD',
  productExperience: 'FUND'
})

const riskOptions = {
  incomeRange: [
    { label: '10万以下', value: 'LOW', score: 20 },
    { label: '10万-30万', value: 'MID', score: 45 },
    { label: '30万-80万', value: 'HIGH', score: 70 },
    { label: '80万以上', value: 'VERY_HIGH', score: 90 }
  ],
  assetRange: [
    { label: '5万以下', value: 'LOW', score: 20 },
    { label: '5万-30万', value: 'MID', score: 45 },
    { label: '30万-100万', value: 'HIGH', score: 70 },
    { label: '100万以上', value: 'VERY_HIGH', score: 90 }
  ],
  investmentGoal: [
    { label: '现金管理', value: 'LIQUIDITY', score: 20 },
    { label: '稳健增值', value: 'STABLE', score: 35 },
    { label: '长期成长', value: 'GROWTH', score: 65 },
    { label: '积极进取', value: 'AGGRESSIVE', score: 88 },
    { label: '养老规划', value: 'RETIREMENT', score: 45 }
  ],
  experienceLevel: [
    { label: '几乎没有经验', value: 'NEW', score: 20 },
    { label: '买过货币/债券基金', value: 'BEGINNER', score: 40 },
    { label: '熟悉基金和权益波动', value: 'EXPERIENCED', score: 70 },
    { label: '有专业投资经验', value: 'PROFESSIONAL', score: 90 }
  ],
  liquidityNeed: [
    { label: '随时可能用钱', value: 'HIGH', score: 25 },
    { label: '保留部分备用金', value: 'MEDIUM', score: 55 },
    { label: '长期闲置资金', value: 'LOW', score: 85 }
  ],
  lossReaction: [
    { label: '马上全部赎回', value: 'SELL_ALL', score: 15 },
    { label: '降低持仓观察', value: 'REDUCE', score: 35 },
    { label: '继续持有观察', value: 'HOLD', score: 65 },
    { label: '认可波动并可能加仓', value: 'ADD', score: 85 }
  ],
  productExperience: [
    { label: '只接触存款/理财', value: 'DEPOSIT', score: 20 },
    { label: '买过公募基金', value: 'FUND', score: 45 },
    { label: '买过股票/ETF', value: 'STOCK', score: 70 },
    { label: '了解衍生品或复杂策略', value: 'DERIVATIVE', score: 90 }
  ]
}

const dimensionItems = computed(() => [
  { label: '承受能力', value: riskProfile.value?.capacityScore || 0 },
  { label: '风险偏好', value: riskProfile.value?.attitudeScore || 0 },
  { label: '投资经验', value: riskProfile.value?.knowledgeScore || 0 },
  { label: '流动性余量', value: riskProfile.value?.liquidityScore || 0 }
])

const riskLevelClass = computed(() => `risk-${(riskProfile.value?.riskLevel || 'unknown').toLowerCase()}`)

const formatDrawdownTooltip = (value: number) => formatPercent(value)

const initForm = () => {
  profileForm.nickname = userStore.userInfo?.nickname || ''
  profileForm.phone = userStore.userInfo?.phone || ''
  profileForm.email = userStore.userInfo?.email || ''
  loading.value = false
}

const getOption = (group: keyof typeof riskOptions, value: string) => {
  return riskOptions[group].find((item) => item.value === value)
}

const riskOptionLabel = (group: keyof typeof riskOptions, value?: string) => {
  if (!value) return '-'
  return getOption(group, value)?.label || value
}

const loadRiskProfile = async () => {
  if (!userStore.hasAnyRole(['USER'])) return
  riskProfileLoading.value = true
  try {
    riskProfile.value = await getRiskProfile()
  } catch {
    // 后端未实现风险画像接口时静默处理
    riskProfile.value = null
  } finally {
    riskProfileLoading.value = false
  }
}

const openRiskAssessment = () => {
  showRiskAssessment.value = true
}

const buildRiskAnswers = () => [
  {
    questionCode: 'income_range',
    questionTitle: '你的年收入大致处于哪个区间？',
    optionCode: riskForm.incomeRange,
    optionText: riskOptionLabel('incomeRange', riskForm.incomeRange),
    answerValue: riskForm.incomeRange,
    score: getOption('incomeRange', riskForm.incomeRange)?.score || 0,
    dimension: 'CAPACITY'
  },
  {
    questionCode: 'asset_range',
    questionTitle: '你的可投资金融资产规模大致是多少？',
    optionCode: riskForm.assetRange,
    optionText: riskOptionLabel('assetRange', riskForm.assetRange),
    answerValue: riskForm.assetRange,
    score: getOption('assetRange', riskForm.assetRange)?.score || 0,
    dimension: 'CAPACITY'
  },
  {
    questionCode: 'investment_goal',
    questionTitle: '你这笔资金的主要投资目标是什么？',
    optionCode: riskForm.investmentGoal,
    optionText: riskOptionLabel('investmentGoal', riskForm.investmentGoal),
    answerValue: riskForm.investmentGoal,
    score: getOption('investmentGoal', riskForm.investmentGoal)?.score || 0,
    dimension: 'ATTITUDE'
  },
  {
    questionCode: 'experience_level',
    questionTitle: '你的投资经验更接近哪一种？',
    optionCode: riskForm.experienceLevel,
    optionText: riskOptionLabel('experienceLevel', riskForm.experienceLevel),
    answerValue: riskForm.experienceLevel,
    score: getOption('experienceLevel', riskForm.experienceLevel)?.score || 0,
    dimension: 'KNOWLEDGE'
  },
  {
    questionCode: 'liquidity_need',
    questionTitle: '这笔资金对流动性的要求如何？',
    optionCode: riskForm.liquidityNeed,
    optionText: riskOptionLabel('liquidityNeed', riskForm.liquidityNeed),
    answerValue: riskForm.liquidityNeed,
    score: getOption('liquidityNeed', riskForm.liquidityNeed)?.score || 0,
    dimension: 'LIQUIDITY'
  },
  {
    questionCode: 'loss_reaction',
    questionTitle: '如果产品短期回撤，你更可能怎么做？',
    optionCode: riskForm.lossReaction,
    optionText: riskOptionLabel('lossReaction', riskForm.lossReaction),
    answerValue: riskForm.lossReaction,
    score: getOption('lossReaction', riskForm.lossReaction)?.score || 0,
    dimension: 'ATTITUDE'
  },
  {
    questionCode: 'product_experience',
    questionTitle: '你接触过的最高风险投资品类是什么？',
    optionCode: riskForm.productExperience,
    optionText: riskOptionLabel('productExperience', riskForm.productExperience),
    answerValue: riskForm.productExperience,
    score: getOption('productExperience', riskForm.productExperience)?.score || 0,
    dimension: 'KNOWLEDGE'
  }
]

const submitRiskProfile = async () => {
  if (!riskForm.investmentHorizonMonths || riskForm.investmentHorizonMonths < 1) {
    ElMessage.warning('投资期限不能小于1个月')
    return
  }
  const payload: RiskAssessmentPayload = {
    ...riskForm,
    answers: buildRiskAnswers()
  }
  savingRiskAssessment.value = true
  try {
    riskProfile.value = await submitRiskAssessment(payload)
    ElMessage.success('风险画像已更新')
    showRiskAssessment.value = false
  } catch (e: any) {
    console.error('Risk assessment submission failed:', e)
    // submitRiskAssessment 已经在内部处理了错误消息，这里不再重复弹窗
  } finally {
    savingRiskAssessment.value = false
  }
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
  void loadRiskProfile()
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

      <SectionCard v-if="userStore.hasAnyRole(['USER'])" title="风险画像">
        <template #actions>
          <el-button type="primary" plain :loading="riskProfileLoading" @click="openRiskAssessment">
            {{ riskProfile?.assessed ? '重新测评' : '开始测评' }}
          </el-button>
        </template>
        <div v-loading="riskProfileLoading" class="risk-profile">
          <div class="risk-profile__hero" :class="riskLevelClass">
            <div>
              <div class="risk-profile__kicker">当前风险等级</div>
              <div class="risk-profile__level">
                <span>{{ riskProfile?.riskLevel || 'UNKNOWN' }}</span>
                <strong>{{ riskProfile?.riskLabel || '未测评' }}</strong>
              </div>
              <div class="risk-profile__summary">{{ riskProfile?.profileSummary || '完成风险测评后，系统会生成你的风险承受能力、投资偏好和产品匹配建议。' }}</div>
              <div class="risk-tags">
                <el-tag v-for="tag in riskProfile?.profileTags || ['待测评']" :key="tag" effect="plain">{{ tag }}</el-tag>
              </div>
              <div class="risk-profile__actions">
                <el-button type="primary" size="large" :loading="riskProfileLoading" @click="openRiskAssessment">
                  {{ riskProfile?.assessed ? '重新测评风险画像' : '开始风险测评' }}
                </el-button>
              </div>
            </div>
            <div class="risk-score">
              <div class="risk-score__value">{{ riskProfile?.riskScore ?? '--' }}</div>
              <div class="risk-score__label">综合分</div>
            </div>
          </div>

          <div class="risk-dimension-grid">
            <div v-for="item in dimensionItems" :key="item.label" class="risk-dimension">
              <div class="risk-dimension__top">
                <span>{{ item.label }}</span>
                <strong>{{ item.value }}</strong>
              </div>
              <el-progress :percentage="item.value" :stroke-width="8" :show-text="false" />
            </div>
          </div>

          <div class="risk-insight-grid">
            <div class="risk-insight">
              <div class="risk-insight__label">投资期限</div>
              <div class="risk-insight__value">{{ riskProfile?.investmentHorizonMonths ? `${riskProfile.investmentHorizonMonths}个月` : '-' }}</div>
            </div>
            <div class="risk-insight">
              <div class="risk-insight__label">最大回撤容忍</div>
              <div class="risk-insight__value">{{ riskProfile?.maxDrawdownTolerance !== undefined ? formatPercent(riskProfile.maxDrawdownTolerance) : '-' }}</div>
            </div>
            <div class="risk-insight">
              <div class="risk-insight__label">最高订阅风险</div>
              <div class="risk-insight__value">{{ riskProfile?.exposureSummary?.highestProductRiskLevel || '-' }}</div>
            </div>
            <div class="risk-insight" :class="{ 'is-warning': (riskProfile?.exposureSummary?.mismatchCount || 0) > 0 }">
              <div class="risk-insight__label">风险不匹配</div>
              <div class="risk-insight__value">{{ riskProfile?.exposureSummary?.mismatchCount || 0 }} 个</div>
            </div>
          </div>

          <div class="risk-suggestions">
            <div v-for="item in riskProfile?.suggestions || ['完成风险测评后再订阅产品']" :key="item" class="risk-suggestion">{{ item }}</div>
          </div>
        </div>
      </SectionCard>

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

      <el-dialog v-model="showRiskAssessment" title="风险承受能力测评" width="760px" class="risk-dialog">
        <el-alert title="测评结果仅用于产品适当性匹配，不代表收益承诺。请按真实情况填写。" type="warning" :closable="false" show-icon style="margin-bottom:16px" />
        <el-form label-position="top" class="risk-form">
          <div class="risk-form-grid">
            <el-form-item label="年收入区间">
              <el-select v-model="riskForm.incomeRange">
                <el-option v-for="item in riskOptions.incomeRange" :key="item.value" :label="item.label" :value="item.value" />
              </el-select>
            </el-form-item>
            <el-form-item label="可投资金融资产">
              <el-select v-model="riskForm.assetRange">
                <el-option v-for="item in riskOptions.assetRange" :key="item.value" :label="item.label" :value="item.value" />
              </el-select>
            </el-form-item>
            <el-form-item label="主要投资目标">
              <el-select v-model="riskForm.investmentGoal">
                <el-option v-for="item in riskOptions.investmentGoal" :key="item.value" :label="item.label" :value="item.value" />
              </el-select>
            </el-form-item>
            <el-form-item label="投资经验">
              <el-select v-model="riskForm.experienceLevel">
                <el-option v-for="item in riskOptions.experienceLevel" :key="item.value" :label="item.label" :value="item.value" />
              </el-select>
            </el-form-item>
            <el-form-item label="流动性需求">
              <el-select v-model="riskForm.liquidityNeed">
                <el-option v-for="item in riskOptions.liquidityNeed" :key="item.value" :label="item.label" :value="item.value" />
              </el-select>
            </el-form-item>
            <el-form-item label="短期回撤反应">
              <el-select v-model="riskForm.lossReaction">
                <el-option v-for="item in riskOptions.lossReaction" :key="item.value" :label="item.label" :value="item.value" />
              </el-select>
            </el-form-item>
            <el-form-item label="最高风险产品经验">
              <el-select v-model="riskForm.productExperience">
                <el-option v-for="item in riskOptions.productExperience" :key="item.value" :label="item.label" :value="item.value" />
              </el-select>
            </el-form-item>
            <el-form-item label="计划投资期限（月）">
              <el-input-number v-model="riskForm.investmentHorizonMonths" :min="1" :max="240" controls-position="right" />
            </el-form-item>
          </div>
          <el-form-item label="最大可接受回撤">
            <el-slider v-model="riskForm.maxDrawdownTolerance" :min="0.01" :max="0.4" :step="0.01" :format-tooltip="formatDrawdownTooltip" />
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="showRiskAssessment = false">取消</el-button>
          <el-button type="primary" :loading="savingRiskAssessment" @click="submitRiskProfile">提交测评</el-button>
        </template>
      </el-dialog>
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

.risk-profile {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.risk-profile__hero {
  display: flex;
  justify-content: space-between;
  gap: 20px;
  padding: 22px;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  background: linear-gradient(135deg, rgba(37, 99, 235, 0.1), rgba(45, 212, 191, 0.08));
}

.risk-profile__hero.risk-r1,
.risk-profile__hero.risk-r2 {
  background: linear-gradient(135deg, rgba(22, 163, 74, 0.12), rgba(56, 189, 248, 0.08));
}

.risk-profile__hero.risk-r4,
.risk-profile__hero.risk-r5 {
  background: linear-gradient(135deg, rgba(220, 38, 38, 0.11), rgba(245, 158, 11, 0.1));
}

.risk-profile__kicker {
  font-size: 12px;
  font-weight: 700;
  color: var(--color-primary);
}

.risk-profile__level {
  display: flex;
  align-items: baseline;
  gap: 10px;
  margin-top: 8px;
}

.risk-profile__level span {
  font-size: 32px;
  font-weight: 900;
  color: var(--color-text-1);
}

.risk-profile__level strong {
  font-size: 18px;
  color: var(--color-text-1);
}

.risk-profile__summary {
  max-width: 760px;
  margin-top: 10px;
  color: var(--color-text-2);
  line-height: 1.7;
}

.risk-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 12px;
}

.risk-profile__actions {
  margin-top: 16px;
}

.risk-score {
  width: 104px;
  height: 104px;
  flex: 0 0 auto;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.78);
  border: 1px solid rgba(255, 255, 255, 0.85);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  box-shadow: var(--shadow-soft);
}

.risk-score__value {
  font-size: 30px;
  font-weight: 900;
  color: var(--color-text-1);
}

.risk-score__label {
  font-size: 12px;
  color: var(--color-text-3);
}

.risk-dimension-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px;
}

.risk-dimension,
.risk-insight {
  padding: 14px 16px;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  background: var(--color-bg-card);
}

.risk-dimension__top {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
  font-size: 13px;
  color: var(--color-text-2);
}

.risk-dimension__top strong {
  color: var(--color-text-1);
}

.risk-insight-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px;
}

.risk-insight__label {
  font-size: 12px;
  color: var(--color-text-3);
}

.risk-insight__value {
  margin-top: 6px;
  font-size: 18px;
  font-weight: 800;
  color: var(--color-text-1);
}

.risk-insight.is-warning {
  border-color: rgba(220, 38, 38, 0.28);
  background: var(--danger-50);
}

.risk-suggestions {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 10px;
}

.risk-suggestion {
  position: relative;
  padding: 12px 14px 12px 28px;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  color: var(--color-text-2);
  background: var(--color-bg-card);
  line-height: 1.6;
}

.risk-suggestion::before {
  content: "";
  position: absolute;
  left: 14px;
  top: 21px;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--color-primary);
}

.risk-form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0 16px;
}

.risk-form :deep(.el-select),
.risk-form :deep(.el-input-number) {
  width: 100%;
}

@media (max-width: 960px) {
  .risk-dimension-grid,
  .risk-insight-grid,
  .risk-form-grid {
    grid-template-columns: 1fr 1fr;
  }
}

@media (max-width: 768px) {
  .risk-profile__hero {
    flex-direction: column;
  }

  .risk-score {
    width: 92px;
    height: 92px;
  }

  .risk-dimension-grid,
  .risk-insight-grid,
  .risk-form-grid {
    grid-template-columns: 1fr;
  }
}
</style>
