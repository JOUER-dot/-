import request from '@/utils/request'

export interface RiskProductExposure {
  productId: number
  productName: string
  riskLevel: string
  matchResult: 'MATCH' | 'LOWER_THAN_PRODUCT' | 'UNKNOWN'
}

export interface RiskExposureSummary {
  activeSubscriptionCount: number
  highestProductRiskLevel?: string | null
  mismatchCount: number
  products: RiskProductExposure[]
}

export interface RiskProfile {
  assessed: boolean
  riskLevel: string
  riskLabel: string
  riskScore?: number
  capacityScore?: number
  attitudeScore?: number
  knowledgeScore?: number
  liquidityScore?: number
  investmentHorizonMonths?: number
  maxDrawdownTolerance?: number
  experienceLevel?: string
  investmentGoal?: string
  liquidityNeed?: string
  profileSummary: string
  profileTags: string[]
  assessedAt?: string
  expiresAt?: string
  exposureSummary: RiskExposureSummary
  suggestions: string[]
}

export interface RiskAssessmentAnswer {
  questionCode: string
  questionTitle: string
  optionCode?: string
  optionText?: string
  answerValue?: string
  score: number
  dimension: string
}

export interface RiskAssessmentPayload {
  incomeRange: string
  assetRange: string
  investmentGoal: string
  experienceLevel: string
  liquidityNeed: string
  investmentHorizonMonths: number
  maxDrawdownTolerance: number
  lossReaction: string
  productExperience: string
  answers: RiskAssessmentAnswer[]
}

export async function getRiskProfile() {
  try {
    return await request.get<RiskProfile>('/auth/risk-profile')
  } catch {
    return null
  }
}

export async function submitRiskAssessment(payload: RiskAssessmentPayload) {
  try {
    return await request.post<RiskProfile>('/auth/risk-profile/assessment', payload)
  } catch (e: any) {
    // 网络不通/后端未启动时弹友好的提示
    const msg = e?.response?.data?.message || e?.message
    if (msg === 'Network Error') {
      throw new Error('无法连接到后端服务，请确认后端已启动')
    }
    // 后端返回了非零 code 但无 message 时显示原始错误详情
    if (!msg && e?.response?.data) {
      throw new Error('服务器返回错误，code=' + e.response.data.code)
    }
    throw new Error(msg || '提交失败，请稍后重试')
  }
}
