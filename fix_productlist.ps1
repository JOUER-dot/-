$path = "C:\Users\LHB\Desktop\金融开发实训\code\frontend\src\views\advisor\ProductList.vue"
$content = Get-Content $path -Raw

$old = 'import {
  getProductList,
  getProductReviews,
  offlineProduct,
  submitProduct,
  withdrawProduct,
  type ProductListItem,
  type ReviewRecord
} from ''@/api/product'''

$new = 'import {
  getProductList,
  getProductReviews,
  offlineProduct,
  submitProduct,
  withdrawProduct,
  deleteProduct,
  copyProduct,
  exportProductList,
  getProductFlowLogs,
  type ProductListItem,
  type ReviewRecord
} from ''@/api/product'''

$content = $content -replace [regex]::Escape($old), $new
Set-Content $path $content -Encoding UTF8
Write-Host "OK"
