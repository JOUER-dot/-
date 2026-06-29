// file: entry/src/main/ets/utils/role-home.ets
export function primaryRole(roles: string[]): string {
  if (roles.includes('ADMIN')) {
    return 'ADMIN';
  }
  if (roles.includes('ADVISOR')) {
    return 'ADVISOR';
  }
  if (roles.includes('REVIEWER')) {
    return 'REVIEWER';
  }
  return 'USER';
}

export function homeTitleByRole(role: string): string {
  switch (role) {
    case 'ADMIN':
      return '运营概览';
    case 'ADVISOR':
      return '工作台';
    case 'REVIEWER':
      return '待审核';
    default:
      return '产品专区';
  }
}
