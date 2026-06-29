// file: entry/src/main/ets/utils/status.ets
import { ColorConstants } from '../theme/ColorConstants';

export function productStatusText(status: string): string {
  const values: Map<string, string> = new Map([
    ['DRAFT', '草稿'],
    ['PENDING_REVIEW', '待审核'],
    ['PUBLISHED', '已发布'],
    ['REJECTED', '已驳回'],
    ['OFFLINE', '已下架']
  ]);
  return values.get(status) || status || '未知';
}

export function reviewStatusText(status: string): string {
  if (status === 'APPROVED') {
    return '通过';
  }
  if (status === 'REJECTED') {
    return '驳回';
  }
  return status || '待处理';
}

export function roleText(role: string): string {
  const values: Map<string, string> = new Map([
    ['USER', '普通用户'],
    ['ADVISOR', '投顾'],
    ['REVIEWER', '审核员'],
    ['ADMIN', '管理员']
  ]);
  return values.get(role) || role;
}

export function riskColor(riskLevel: string): string {
  switch (riskLevel) {
    case 'R1':
      return ColorConstants.RISK_R1;
    case 'R2':
      return ColorConstants.RISK_R2;
    case 'R3':
      return ColorConstants.RISK_R3;
    case 'R4':
      return ColorConstants.RISK_R4;
    case 'R5':
      return ColorConstants.RISK_R5;
    default:
      return ColorConstants.TEXT_HINT;
  }
}

export function productStatusColor(status: string): string {
  switch (status) {
    case 'PUBLISHED':
    case 'APPROVED':
    case 'ACTIVE':
      return ColorConstants.SUCCESS;
    case 'PENDING_REVIEW':
      return ColorConstants.WARNING;
    case 'REJECTED':
    case 'CANCELLED':
      return ColorConstants.DANGER;
    default:
      return ColorConstants.TEXT_HINT;
  }
}
