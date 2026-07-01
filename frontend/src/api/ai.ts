import request, { AUTH_STORAGE_KEY } from '@/utils/request'
import { normalizeApiBaseUrl } from '@/utils/api-base-url'

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

export interface ProductAnalysisResponse {
  overview: string
  suitability: string
  allocationSummary: string
  riskBadge: string
  highlights: string[]
  risks: string[]
  checklist: string[]
}

export interface ReviewAdviceResponse {
  decisionHint: string
  riskLevel: string
  summary: string
  concerns: string[]
  evidence: string[]
  followUpQuestions: string[]
}

export interface StreamChatHandlers {
  onDelta: (content: string) => void
  onDone?: (suggestions: string[]) => void
  onError?: (message: string) => void
  signal?: AbortSignal
}

export function sendChatMessage(payload: ChatRequest) {
  return request.post<ChatResponse>('/ai/chat', payload)
}

export function getProductAiAnalysis(productId: number) {
  return request.post<ProductAnalysisResponse>(`/ai/products/${productId}/analysis`)
}

export function getReviewAiAdvice(productId: number) {
  return request.post<ReviewAdviceResponse>(`/ai/review/products/${productId}/advice`)
}

function getStoredAuthorization() {
  const raw = localStorage.getItem(AUTH_STORAGE_KEY)
  if (!raw) {
    return ''
  }
  try {
    const parsed = JSON.parse(raw) as { token?: string; tokenHead?: string }
    return parsed.token ? `${parsed.tokenHead || 'Bearer '}${parsed.token}` : ''
  } catch {
    return ''
  }
}

function getStreamUrl(path: string) {
  return `${normalizeApiBaseUrl(import.meta.env.VITE_APP_BASE_API)}${path}`
}

function parseSseBlock(block: string) {
  let eventName = 'message'
  const dataLines: string[] = []
  for (const line of block.split(/\r?\n/)) {
    if (line.startsWith('event:')) {
      eventName = line.slice('event:'.length).trim()
    } else if (line.startsWith('data:')) {
      dataLines.push(line.slice('data:'.length).trim())
    }
  }
  return {
    eventName,
    data: dataLines.join('\n')
  }
}

function handleSseBlock(block: string, handlers: StreamChatHandlers) {
  const { eventName, data } = parseSseBlock(block)
  if (!data) {
    return
  }
  const payload = JSON.parse(data) as { content?: string; suggestions?: string[]; message?: string }
  if (eventName === 'delta') {
    handlers.onDelta(payload.content || '')
  } else if (eventName === 'done') {
    handlers.onDone?.(payload.suggestions || [])
  } else if (eventName === 'error') {
    handlers.onError?.(payload.message || 'AI 助手暂时不可用')
  }
}

export async function streamChatMessage(payload: ChatRequest, handlers: StreamChatHandlers) {
  const authorization = getStoredAuthorization()
  const response = await fetch(getStreamUrl('/ai/chat/stream'), {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(authorization ? { Authorization: authorization } : {})
    },
    body: JSON.stringify(payload),
    signal: handlers.signal
  })

  if (!response.ok || !response.body) {
    throw new Error(`AI stream request failed: ${response.status}`)
  }

  const reader = response.body.getReader()
  const decoder = new TextDecoder('utf-8')
  let buffer = ''

  while (true) {
    const { done, value } = await reader.read()
    if (done) {
      break
    }
    buffer += decoder.decode(value, { stream: true })
    const blocks = buffer.split(/\r?\n\r?\n/)
    buffer = blocks.pop() || ''
    for (const block of blocks) {
      handleSseBlock(block, handlers)
    }
  }

  buffer += decoder.decode()
  if (buffer.trim()) {
    handleSseBlock(buffer, handlers)
  }
}
