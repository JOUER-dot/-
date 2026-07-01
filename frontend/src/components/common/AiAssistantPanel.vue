<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, ref } from 'vue'
import { streamChatMessage, type ChatMessage } from '@/api/ai'

interface Message {
  role: 'user' | 'assistant'
  content: string
  suggestions?: string[]
}

const props = withDefaults(defineProps<{
  productId?: number
  riskLevel?: string
  title?: string
  subtitle?: string
  compact?: boolean
  showHeader?: boolean
}>(), {
  title: '小顾 AI 助手',
  subtitle: '在线 · 智能投顾问答',
  compact: false,
  showHeader: true
})

const inputText = ref('')
const loading = ref(false)
const chatBody = ref<HTMLElement | null>(null)
const abortController = ref<AbortController | null>(null)

const initialSuggestions = computed(() => {
  if (props.productId) {
    return ['帮我分析这个产品', '这只产品适合我吗？', '主要风险点有哪些？', '订阅前要看什么？']
  }
  return ['如何选择适合我的产品？', 'R1和R5风险等级有什么区别？', '如何订阅产品？', '什么是FOF组合？']
})

const welcomeText = computed(() => {
  if (props.productId) {
    return '你好！我是小顾。我已经识别到当前产品，可以帮你分析产品定位、风险等级、基金成份和订阅前注意事项。'
  }
  return '你好！我是小顾，你的智能投资助手。我可以帮你解答关于基金产品、风险等级、订阅流程等问题，请问你想了解什么？'
})

const messages = ref<Message[]>([
  {
    role: 'assistant',
    content: welcomeText.value,
    suggestions: initialSuggestions.value
  }
])

const scrollToBottom = async () => {
  await nextTick()
  if (chatBody.value) {
    chatBody.value.scrollTop = chatBody.value.scrollHeight
  }
}

const buildHistory = () => {
  return messages.value
    .slice(0, -1)
    .filter((message) => message.content)
    .map<ChatMessage>((message) => ({
      role: message.role,
      content: message.content
    }))
}

const handleSend = async (presetQuestion?: string) => {
  const text = (presetQuestion || inputText.value).trim()
  if (!text || loading.value) return

  const history = buildHistory()
  inputText.value = ''
  messages.value.push({ role: 'user', content: text })
  const assistantMessage: Message = { role: 'assistant', content: '' }
  messages.value.push(assistantMessage)
  await scrollToBottom()

  abortController.value = new AbortController()
  loading.value = true
  try {
    await streamChatMessage(
      {
        question: text,
        productId: props.productId,
        riskLevel: props.riskLevel,
        history
      },
      {
        signal: abortController.value.signal,
        onDelta: async (content) => {
          assistantMessage.content += content
          await scrollToBottom()
        },
        onDone: async (suggestions) => {
          assistantMessage.suggestions = suggestions
          await scrollToBottom()
        },
        onError: (message) => {
          assistantMessage.content = message
        }
      }
    )
  } catch (error) {
    if ((error as Error).name !== 'AbortError') {
      assistantMessage.content = '抱歉，我遇到了一些问题，请稍后再试试。'
    }
  } finally {
    loading.value = false
    abortController.value = null
    if (!assistantMessage.content) {
      assistantMessage.content = '抱歉，我暂时没有生成有效回复。'
    }
    await scrollToBottom()
  }
}

const handleSuggestionClick = (suggestion: string) => {
  void handleSend(suggestion)
}

const handleKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault()
    void handleSend()
  }
}

onBeforeUnmount(() => {
  abortController.value?.abort()
})
</script>

<template>
  <div class="ai-panel" :class="{ 'ai-panel--compact': compact }">
    <div v-if="showHeader" class="chat-header">
      <div class="chat-header__avatar">🤖</div>
      <div class="chat-header__info">
        <div class="chat-header__name">{{ title }}</div>
        <div class="chat-header__status">{{ subtitle }}</div>
      </div>
    </div>

    <div ref="chatBody" class="chat-body">
      <div v-for="(message, index) in messages" :key="index" class="chat-message" :class="message.role">
        <div class="msg-avatar">{{ message.role === 'assistant' ? '🤖' : '👤' }}</div>
        <div class="msg-content">
          <div class="msg-bubble" :class="{ 'msg-bubble--loading': loading && !message.content && index === messages.length - 1 }">
            <span v-if="message.content">{{ message.content }}</span>
            <span v-else class="typing-cursor">正在分析...</span>
          </div>
          <div v-if="message.suggestions?.length" class="msg-suggestions">
            <el-tag
              v-for="suggestion in message.suggestions"
              :key="suggestion"
              effect="plain"
              class="suggestion-tag"
              @click="handleSuggestionClick(suggestion)"
            >
              {{ suggestion }}
            </el-tag>
          </div>
        </div>
      </div>
    </div>

    <div class="chat-input-area">
      <el-input
        v-model="inputText"
        type="textarea"
        :rows="compact ? 1 : 2"
        placeholder="输入你的问题..."
        :disabled="loading"
        @keydown="handleKeydown"
      />
      <el-button type="primary" :loading="loading" class="send-btn" @click="handleSend()">
        发送
      </el-button>
    </div>
  </div>
</template>

<style scoped>
.ai-panel {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 0;
  background: #ffffff;
}

.chat-header {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 20px;
  background: linear-gradient(135deg, #123b6d, #1f5c99);
  color: #fff;
  flex-shrink: 0;
}

.chat-header__avatar {
  font-size: 32px;
}

.chat-header__name {
  font-size: 16px;
  font-weight: 700;
}

.chat-header__status {
  font-size: 12px;
  opacity: .7;
  margin-top: 2px;
}

.chat-body {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  background: #f5f7fa;
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-height: 0;
}

.chat-message {
  display: flex;
  gap: 10px;
  max-width: 88%;
}

.chat-message.user {
  align-self: flex-end;
  flex-direction: row-reverse;
}

.msg-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  background: #e6eaf0;
  flex-shrink: 0;
}

.chat-message.user .msg-avatar {
  background: #123b6d;
}

.msg-content {
  min-width: 0;
}

.msg-bubble {
  white-space: pre-wrap;
  word-break: break-word;
  padding: 12px 16px;
  border-radius: 12px;
  font-size: 14px;
  line-height: 1.6;
  background: #fff;
  color: #17202d;
  box-shadow: 0 2px 8px rgba(0,0,0,.06);
}

.chat-message.user .msg-bubble {
  background: #123b6d;
  color: #fff;
}

.msg-bubble--loading {
  background: #e6eaf0;
  color: #5e6b7a;
}

.typing-cursor {
  color: #5e6b7a;
}

.msg-suggestions {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 8px;
}

.suggestion-tag {
  cursor: pointer;
  border-radius: 8px;
  font-size: 12px;
  transition: all .15s;
  max-width: 100%;
  white-space: normal;
  height: auto;
  line-height: 1.35;
  padding: 5px 9px;
}

.suggestion-tag:hover {
  border-color: #123b6d;
  color: #123b6d;
}

.chat-input-area {
  display: flex;
  gap: 10px;
  padding: 12px 16px;
  background: #fff;
  border-top: 1px solid #e6eaf0;
  align-items: flex-end;
  flex-shrink: 0;
}

.chat-input-area :deep(.el-textarea__inner) {
  border-radius: 10px;
}

.send-btn {
  height: 56px;
  flex-shrink: 0;
}

.ai-panel--compact .chat-header {
  padding: 14px 16px;
}

.ai-panel--compact .chat-body {
  padding: 14px;
}

.ai-panel--compact .chat-message {
  max-width: 94%;
}

.ai-panel--compact .send-btn {
  height: 40px;
}
</style>
