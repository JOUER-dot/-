import type {
  ProductChangeType,
  ProductDetail,
  ProductSubmitPayload
} from '../../api/product.ts'

export interface ProductVersionContext {
  isIteration: boolean
  currentPublishedVersionNo: number | null
}

export interface ProductSubmitDialogState {
  changeType: ProductChangeType
  versionNote: string
}

export function getProductVersionContext(
  detail: Pick<ProductDetail, 'publishedVersion'> | null | undefined
): ProductVersionContext {
  return {
    isIteration: Boolean(detail?.publishedVersion),
    currentPublishedVersionNo: detail?.publishedVersion?.versionNo ?? null
  }
}

export function buildProductSubmitPayload(
  versionContext: ProductVersionContext,
  submitState: ProductSubmitDialogState
): ProductSubmitPayload {
  if (!versionContext.isIteration) {
    return {}
  }

  const versionNote = submitState.versionNote.trim()

  return {
    changeType: submitState.changeType,
    versionNote: versionNote || undefined
  }
}
