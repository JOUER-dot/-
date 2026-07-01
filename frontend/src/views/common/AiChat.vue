<script setup lang="ts">
import PageContainer from '@/components/ui/PageContainer.vue'
import AiAssistantPanel from '@/components/common/AiAssistantPanel.vue'
</script>

<template>
  <PageContainer>
    <div class="ai-chat-page">
      <AiAssistantPanel />
    </div>
  </PageContainer>
</template>

<style scoped>
.ai-chat-page {
  height: calc(100vh - 120px);
  max-width: 840px;
  margin: 0 auto;
  overflow: hidden;
  border-radius: 16px;
  box-shadow: 0 10px 30px rgba(17, 31, 49, .08);
}
</style>
