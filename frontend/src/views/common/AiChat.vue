<script setup lang="ts">
import { ref, nextTick } from 'vue'
import PageContainer from '@/components/ui/PageContainer.vue'
import { sendChatMessage, type ChatMessage, type ChatResponse } from '@/api/ai'

interface Message {
  role: 'user' | 'assistant'
  content: string
  suggestions?: string[]
}

const inputText = ref('')
const messages = ref<Message[]>([])
const loading = ref(false)
const chatBody = ref<HTMLElement | null>(null)

// 初始欢迎消息
messages.value.push({
  role: 'assistant',
  content: '你好！我是小顾 🤖，你的智能投资助手。我可以帮你解答关于基金产品、风险等级、订阅流程等问题，请问你想了解什么？',
  suggestions: ['如何选择适合我的产品？', 'R1和R5风险等级有什么区别？', '如何订阅产品？', '什么是FOF组合？']
})

const scrollToBottom = async () => {
  await nextTick()
  if (chatBody.value) {
    chatBody.value.scrollTop = chatBody.value.scrollHeight
  }
}

const handleSend = async () => {
  const text = inputText.value.trim()
  if (!text || loading.value) return

  inputText.value = ''
  messages.value.push({ role: 'user', content: text })
  await scrollToBottom()

  // 构建对话历史（排除最后一条刚添加的用户消息）
  const history: ChatMessage[] = messages.value
    .slice(0, -1)
    .filter(m => m.role !== 'assistant' || m.content)
    .map(m => ({ role: m.role, content: m.content }))

  loading.value = true
  try {
    const data = await sendChatMessage({
      question: text,
      history
    })
    messages.value.push({
      role: 'assistant',
      content: data.answer,
      suggestions: data.suggestions
    })
  } catch {
    messages.value.push({
      role: 'assistant',
      content: '抱歉，我遇到了一些问题，请稍后再试试。'
    })
  } finally {
    loading.value = false
    await scrollToBottom()
  }
}

const handleSuggestionClick = (suggestion: string) => {
  inputText.value = suggestion
  handleSend()
}

const handleKeydown = (e: KeyboardEvent) => {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault()
    handleSend()
  }
}
</script>

<template>
  <PageContainer>
    <div class="ai-chat">
      <!-- 顶部 -->
      <div class="chat-header">
        <div class="chat-header__avatar">🤖</div>
        <div class="chat-header__info">
          <div class="chat-header__name">小顾 AI 助手</div>
          <div class="chat-header__status">在线 · 智能投顾问答</div>
        </div>
      </div>

      <!-- 消息列表 -->
      <div ref="chatBody" class="chat-body">
        <div v-for="(msg, i) in messages" :key="i" class="chat-message" :class="msg.role">
          <div class="msg-avatar">{{ msg.role === 'assistant' ? '🤖' : '👤' }}</div>
          <div class="msg-content">
            <div class="msg-bubble">{{ msg.content }}</div>
            <div v-if="msg.suggestions && msg.suggestions.length" class="msg-suggestions">
              <el-tag
                v-for="(sug, j) in msg.suggestions"
                :key="j"
                effect="plain"
                class="suggestion-tag"
                @click="handleSuggestionClick(sug)"
              >
                {{ sug }}
              </el-tag>
            </div>
          </div>
        </div>

        <!-- 加载中 -->
        <div v-if="loading" class="chat-message assistant">
          <div class="msg-avatar">🤖</div>
          <div class="msg-content">
            <div class="msg-bubble msg-bubble--loading">
              <span class="dot-pulse">.</span><span class="dot-pulse">.</span><span class="dot-pulse">.</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 输入区 -->
      <div class="chat-input-area">
        <el-input
          v-model="inputText"
          type="textarea"
          :rows="2"
          placeholder="输入你的问题..."
          :disabled="loading"
          @keydown="handleKeydown"
        />
        <el-button type="primary" :loading="loading" @click="handleSend" class="send-btn">
          发送
        </el-button>
      </div>
    </div>
  </PageContainer>
</template>

<style scoped>
.ai-chat {
  display: flex;
  flex-direction: column;
  height: calc(100vh - 120px);
  max-width: 800px;
  margin: 0 auto;
}

.chat-header {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 20px;
  background: linear-gradient(135deg, #123b6d, #1f5c99);
  border-radius: 16px 16px 0 0;
  color: #fff;
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
}

.chat-message {
  display: flex;
  gap: 10px;
  max-width: 85%;
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

.msg-bubble {
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

.dot-pulse {
  animation: pulse 1.4s infinite;
  font-size: 24px;
  line-height: 0;
}
.dot-pulse:nth-child(2) { animation-delay: .2s; }
.dot-pulse:nth-child(3) { animation-delay: .4s; }
@keyframes pulse {
  0%, 80%, 100% { opacity: 0; }
  40% { opacity: 1; }
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
  border-radius: 0 0 16px 16px;
  align-items: flex-end;
}
.chat-input-area :deep(.el-textarea__inner) {
  border-radius: 10px;
}
.send-btn {
  height: 56px;
  flex-shrink: 0;
}
</style>
