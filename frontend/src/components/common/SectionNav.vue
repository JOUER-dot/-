<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'

export type SectionNavItem = {
  id: string
  label: string
  hint?: string
}

const props = defineProps<{
  sections: SectionNavItem[]
  offsetTop?: number
}>()

const activeId = ref<string>('')
const observer = ref<IntersectionObserver | null>(null)

const resolvedOffsetTop = computed(() => (typeof props.offsetTop === 'number' ? props.offsetTop : 96))

const scrollTo = (id: string) => {
  const el = document.getElementById(id)
  if (!el) {
    return
  }
  const top = el.getBoundingClientRect().top + window.scrollY - resolvedOffsetTop.value
  window.scrollTo({ top, behavior: 'smooth' })
}

onMounted(() => {
  if (props.sections.length === 0) {
    return
  }
  const elList = props.sections
    .map((item) => document.getElementById(item.id))
    .filter((el): el is HTMLElement => Boolean(el))

  if (elList.length === 0) {
    return
  }

  observer.value = new IntersectionObserver(
    (entries) => {
      const visible = entries
        .filter((entry) => entry.isIntersecting)
        .sort((a, b) => (a.boundingClientRect.top ?? 0) - (b.boundingClientRect.top ?? 0))[0]
      if (visible?.target?.id) {
        activeId.value = visible.target.id
      }
    },
    {
      root: null,
      rootMargin: `-${resolvedOffsetTop.value}px 0px -70% 0px`,
      threshold: [0.01, 0.1, 0.2]
    }
  )

  elList.forEach((el) => observer.value?.observe(el))
  activeId.value = elList[0].id
})

onBeforeUnmount(() => {
  observer.value?.disconnect()
  observer.value = null
})
</script>

<template>
  <el-card shadow="never" class="nav-card">
    <div class="nav-title">页面目录</div>
    <div class="nav-list">
      <button
        v-for="item in sections"
        :key="item.id"
        type="button"
        class="nav-item"
        :class="{ active: activeId === item.id }"
        @click="scrollTo(item.id)"
      >
        <div class="nav-item__label">{{ item.label }}</div>
        <div v-if="item.hint" class="nav-item__hint">{{ item.hint }}</div>
      </button>
    </div>
  </el-card>
</template>

<style scoped>
.nav-card {
  position: sticky;
  top: 76px;
  border-radius: 18px;
}

.nav-title {
  font-weight: 700;
  color: #111827;
  margin-bottom: 12px;
}

.nav-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.nav-item {
  text-align: left;
  border: 1px solid #e5e7eb;
  background: #ffffff;
  border-radius: 14px;
  padding: 10px 12px;
  cursor: pointer;
}

.nav-item.active {
  border-color: #93c5fd;
  background: #eff6ff;
}

.nav-item__label {
  color: #111827;
  font-weight: 600;
  line-height: 20px;
}

.nav-item__hint {
  margin-top: 4px;
  color: #6b7280;
  font-size: 12px;
  line-height: 18px;
}
</style>

