const fs = require('fs');
const path = 'C:\\Users\\LHB\\Desktop\\金融开发实训\\code\\frontend\\src\\views\\advisor\\ProductList.vue';

let content = fs.readFileSync(path, 'utf8');

// 1. Add imports
content = content.replace(
  "import {\n  getProductList,\n  getProductReviews,\n  offlineProduct,\n  submitProduct,\n  withdrawProduct,\n  type ProductListItem,\n  type ReviewRecord\n} from '@/api/product'",
  "import {\n  getProductList,\n  getProductReviews,\n  offlineProduct,\n  submitProduct,\n  withdrawProduct,\n  deleteProduct,\n  copyProduct,\n  exportProductList,\n  getProductFlowLogs,\n  type ProductListItem,\n  type ReviewRecord\n} from '@/api/product'"
);

// 2. Add flowLogDialog state after reviewTarget
content = content.replace(
  "const reviewTarget = ref<ProductListItem | null>(null)",
  "const reviewTarget = ref<ProductListItem | null>(null)\nconst flowLogDialogVisible = ref(false)\nconst flowLogs = ref<Array<{ id: number; actionType: string; comment: string; createdAt: string }>>([])\nconst flowLoading = ref(false)"
);

// 3. Add handleDelete after handleOffline
content = content.replace(
  "const handleOffline = async (row: ProductListItem) => {\n  try {\n    await ElMessageBox.confirm('确认下架当前产品吗？', '下架产品', { type: 'warning' })\n  } catch {\n    return\n  }\n  await offlineProduct(row.id)\n  ElMessage.success('下架成功')\n  await loadData()\n}",
  "const handleOffline = async (row: ProductListItem) => {\n  try {\n    await ElMessageBox.confirm('确认下架当前产品吗？', '下架产品', { type: 'warning' })\n  } catch {\n    return\n  }\n  await offlineProduct(row.id)\n  ElMessage.success('下架成功')\n  await loadData()\n}\n\nconst handleDelete = async (row: ProductListItem) => {\n  try {\n    await ElMessageBox.confirm(`确认删除产品「${row.name}」吗？此操作不可恢复。`, '删除产品', { type: 'warning', confirmButtonText: '确认删除', confirmButtonClass: 'el-button--danger' })\n  } catch {\n    return\n  }\n  try {\n    await deleteProduct(row.id)\n    ElMessage.success('删除成功')\n    await loadData()\n  } catch {\n    ElMessage.error('删除失败')\n  }\n}\n\nconst handleCopy = async (row: ProductListItem) => {\n  try {\n    const newId = await copyProduct(row.id)\n    ElMessage.success('复制成功，即将跳转到新产品')\n    await router.push(`/admin/products/${newId}/edit`)\n  } catch {\n    ElMessage.error('复制失败')\n  }\n}\n\nconst handleExport = () => {\n  const url = exportProductList({ ...queryForm })\n  window.open(url, '_blank')\n}\n\nconst openFlowLogs = async (row: ProductListItem) => {\n  flowLoading.value = true\n  flowLogDialogVisible.value = true\n  try {\n    flowLogs.value = await getProductFlowLogs(row.id)\n  } finally {\n    flowLoading.value = false\n  }\n}"
);

// 4. Improve batch submit with detailed feedback
content = content.replace(
  "const handleBatchSubmit = async () => {\n  if (!batchActionState.value.canBatchSubmit) {\n    ElMessage.warning('当前选择不可批量提交审核')\n    return\n  }\n\n  try {\n    await ElMessageBox.confirm(`确认提交选中的 ${selectedIds.value.length} 个产品吗？`, '批量提交审核', {\n      type: 'warning'\n    })\n  } catch {\n    return\n  }\n\n  try {\n    await Promise.all(selectedIds.value.map((id) => submitProduct(id)))\n    ElMessage.success(`已提交 ${selectedIds.value.length} 个产品`)\n    await loadData()\n  } catch {\n    ElMessage.error('批量提交审核失败')\n  }\n}",
  "const handleBatchSubmit = async () => {\n  if (!batchActionState.value.canBatchSubmit) {\n    ElMessage.warning('当前选择不可批量提交审核')\n    return\n  }\n\n  const count = selectedIds.value.length\n  try {\n    await ElMessageBox.confirm(`确认提交选中的 ${count} 个产品吗？`, '批量提交审核', { type: 'warning' })\n  } catch {\n    return\n  }\n\n  let successCount = 0\n  let failCount = 0\n  for (let i = 0; i < selectedIds.value.length; i++) {\n    try {\n      await submitProduct(selectedIds.value[i])\n      successCount++\n    } catch {\n      failCount++\n    }\n  }\n  if (successCount > 0) {\n    ElMessage.success(`成功提交 ${successCount} 个产品${failCount > 0 ? `，${failCount} 个失败` : ''}`)\n  }\n  if (failCount > 0 && successCount === 0) {\n    ElMessage.error('批量提交审核失败')\n  }\n  await loadData()\n}"
);

// 5. Improve batch offline with detailed feedback
content = content.replace(
  "const handleBatchOffline = async () => {\n  if (!batchActionState.value.canBatchOffline) {\n    ElMessage.warning('当前选择不可批量下架')\n    return\n  }\n\n  try {\n    await ElMessageBox.confirm(`确认下架选中的 ${selectedIds.value.length} 个产品吗？`, '批量下架', {\n      type: 'warning'\n    })\n  } catch {\n    return\n  }\n\n  try {\n    await Promise.all(selectedIds.value.map((id) => offlineProduct(id)))\n    ElMessage.success(`已下架 ${selectedIds.value.length} 个产品`)\n    await loadData()\n  } catch {\n    ElMessage.error('批量下架失败')\n  }\n}",
  "const handleBatchOffline = async () => {\n  if (!batchActionState.value.canBatchOffline) {\n    ElMessage.warning('当前选择不可批量下架')\n    return\n  }\n\n  const count = selectedIds.value.length\n  try {\n    await ElMessageBox.confirm(`确认下架选中的 ${count} 个产品吗？`, '批量下架', { type: 'warning' })\n  } catch {\n    return\n  }\n\n  let successCount = 0\n  let failCount = 0\n  for (let i = 0; i < selectedIds.value.length; i++) {\n    try {\n      await offlineProduct(selectedIds.value[i])\n      successCount++\n    } catch {\n      failCount++\n    }\n  }\n  if (successCount > 0) {\n    ElMessage.success(`成功下架 ${successCount} 个产品${failCount > 0 ? `，${failCount} 个失败` : ''}`)\n  }\n  if (failCount > 0 && successCount === 0) {\n    ElMessage.error('批量下架失败')\n  }\n  await loadData()\n}"
);

// 6. Add export button to hero
content = content.replace(
  "        <el-button type=\"primary\" @click=\"router.push('/admin/products/create')\">创建产品</el-button>",
  "        <div style=\"display:flex;gap:8px\">\n          <el-button @click=\"handleExport\">导出列表</el-button>\n          <el-button type=\"primary\" @click=\"router.push('/admin/products/create')\">创建产品</el-button>\n        </div>"
);

// 7. Add delete/copy to action column
content = content.replace(
  "                  <el-button\n                    v-if=\"row.status === 'PUBLISHED'\"\n                    link\n                    type=\"danger\"\n                    class=\"action-link\"\n                    @click=\"handleOffline(row)\"\n                  >\n                    下架\n                  </el-button>",
  "                  <el-button\n                    v-if=\"row.status === 'PUBLISHED'\"\n                    link\n                    type=\"danger\"\n                    class=\"action-link\"\n                    @click=\"handleOffline(row)\"\n                  >\n                    下架\n                  </el-button>\n                  <el-button link class=\"action-link\" @click=\"handleCopy(row)\">复制</el-button>\n                  <el-button link class=\"action-link\" @click=\"openFlowLogs(row)\">操作日志</el-button>\n                  <el-button\n                    v-if=\"row.status === 'DRAFT' || row.status === 'REJECTED' || row.status === 'OFFLINE'\"\n                    link\n                    type=\"danger\"\n                    class=\"action-link\"\n                    @click=\"handleDelete(row)\"\n                  >\n                    删除\n                  </el-button>"
);

// 8. Add flow log dialog before the closing div
content = content.replace(
  "      <el-dialog v-model=\"reviewDialogVisible\"",
  "      <el-dialog v-model=\"flowLogDialogVisible\" title=\"操作日志\" width=\"640px\">\n        <div v-loading=\"flowLoading\">\n          <el-empty v-if=\"flowLogs.length === 0\" description=\"暂无操作日志\" />\n          <el-timeline v-else>\n            <el-timeline-item v-for=\"(log, index) in flowLogs\" :key=\"index\" :timestamp=\"log.createdAt\">\n              <div>{{ log.actionType }}{{ log.comment ? ' - ' + log.comment : '' }}</div>\n            </el-timeline-item>\n          </el-timeline>\n        </div>\n      </el-dialog>\n\n      <el-dialog v-model=\"reviewDialogVisible\""
);

// 9. Update batch bar text to show unavailability reasons
content = content.replace(
  "        <div v-if=\"batchActionState.selectedCount > 0\" class=\"batch-bar\">\n          <div class=\"batch-bar__summary\">已选择 {{ batchActionState.selectedCount }} 项</div>\n          <div class=\"batch-bar__actions\">\n            <el-button type=\"primary\" :disabled=\"!batchActionState.canBatchSubmit\" @click=\"handleBatchSubmit\">\n              批量提交审核\n            </el-button>\n            <el-button type=\"danger\" plain :disabled=\"!batchActionState.canBatchOffline\" @click=\"handleBatchOffline\">\n              批量下架\n            </el-button>\n          </div>\n        </div>",
  "        <div v-if=\"batchActionState.selectedCount > 0\" class=\"batch-bar\">\n          <div class=\"batch-bar__summary\">\n            已选择 {{ batchActionState.selectedCount }} 项\n            <span v-if=\"!batchActionState.canBatchSubmit && !batchActionState.canBatchOffline\" class=\"batch-bar__note\">\n              （当前选择包含不同状态的产品，请统一筛选后再操作）\n            </span>\n          </div>\n          <div class=\"batch-bar__actions\">\n            <el-popover v-if=\"!batchActionState.canBatchSubmit\" placement=\"top\" trigger=\"hover\">\n              <div>仅草稿和已驳回状态可批量提交审核</div>\n              <template #reference>\n                <el-button type=\"primary\" disabled>批量提交审核</el-button>\n              </template>\n            </el-popover>\n            <el-button v-else type=\"primary\" @click=\"handleBatchSubmit\">批量提交审核</el-button>\n\n            <el-popover v-if=\"!batchActionState.canBatchOffline\" placement=\"top\" trigger=\"hover\">\n              <div>仅已上架状态可批量下架</div>\n              <template #reference>\n                <el-button type=\"danger\" plain disabled>批量下架</el-button>\n              </template>\n            </el-popover>\n            <el-button v-else type=\"danger\" plain @click=\"handleBatchOffline\">批量下架</el-button>\n          </div>\n        </div>"
);

fs.writeFileSync(path, content, 'utf8');
console.log('Done - ProductList.vue updated successfully');
