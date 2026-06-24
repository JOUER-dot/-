<script setup lang="ts">
import SidebarMenu from '@/components/nav/SidebarMenu.vue'
import TopBar from '@/components/nav/TopBar.vue'
</script>

<template>
  <el-container class="app-shell">
    <el-aside width="220px" class="app-aside">
      <div class="brand">智能投顾</div>
      <SidebarMenu />
    </el-aside>
    <el-container>
      <el-header height="56px" class="app-header">
        <TopBar />
      </el-header>
      <el-main class="app-main">
        <router-view />
        <el-backtop :right="24" :bottom="24" />
      </el-main>
    </el-container>
  </el-container>
</template>

<style scoped>
.app-shell {
  min-height: 100vh;
  background: #f5f7fa;
}

.app-aside {
  background: #ffffff;
  border-right: 1px solid #ebeef5;
  display: flex;
  flex-direction: column;
  overflow: auto;
}

.brand {
  height: 56px;
  display: flex;
  align-items: center;
  padding: 0 16px;
  font-size: 18px;
  font-weight: 700;
  color: #303133;
  border-bottom: 1px solid #ebeef5;
}

.app-header {
  padding: 0;
}

.app-main {
  padding: 24px;
}
</style>
