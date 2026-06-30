import request from '@/utils/request'

export interface ChatMessage {
  role: 'user' | 'assistant'
  content: string
}

export interface ChatRequest {
  question: string
  productId?: number
  riskLevel?: string
  history?: ChatMessage[]
}

export interface ChatResponse {
  answer: string
  suggestions: string[]
}

export function sendChatMessage(payload: ChatRequest) {
  return request.post<ChatResponse>('/ai/chat', payload)
}
