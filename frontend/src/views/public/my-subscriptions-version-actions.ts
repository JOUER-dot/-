import type {
  MySubscriptionItem,
  SubscriptionVersionActionItem,
  SubscriptionVersionDecision
} from '@/api/subscription'

export interface MySubscriptionVersionActionState {
  visible: boolean
  requiresDecision: boolean
  tone: 'default' | 'info' | 'warning'
  summary: string
  actionLabel: string
  decisionOptions: SubscriptionVersionDecision[]
}

function getPendingAction(actions: SubscriptionVersionActionItem[]) {
  const pendingActions = actions.filter((item) => item.actionStatus === 'PENDING')
  if (pendingActions.length === 0) {
    return null
  }
  return pendingActions.find((item) => item.actionType === 'CONFIRM_REQUIRED') || pendingActions[0]
}

export function getMySubscriptionVersionActionState(
  item: Pick<MySubscriptionItem, 'pendingVersionActions'>
): MySubscriptionVersionActionState {
  const pendingAction = getPendingAction(item.pendingVersionActions || [])

  if (!pendingAction) {
    return {
      visible: false,
      requiresDecision: false,
      tone: 'default',
      summary: '',
      actionLabel: '',
      decisionOptions: []
    }
  }

  if (pendingAction.actionType === 'CONFIRM_REQUIRED') {
    return {
      visible: true,
      requiresDecision: true,
      tone: 'warning',
      summary: pendingAction.versionNote || '',
      actionLabel: '待确认继续订阅',
      decisionOptions: ['CONFIRM', 'CANCEL']
    }
  }

  return {
    visible: true,
    requiresDecision: false,
    tone: 'info',
    summary: pendingAction.versionNote || '',
    actionLabel: '版本变更通知',
    decisionOptions: []
  }
}
