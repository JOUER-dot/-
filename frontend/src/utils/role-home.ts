const ROLE_HOME_MAP: Record<string, string> = {
  USER: '/advisor-zone',
  ADVISOR: '/admin/products',
  REVIEWER: '/review/pending'
}

export function getDefaultHomeByRoles(roles: string[]): string {
  for (const role of roles) {
    if (ROLE_HOME_MAP[role]) {
      return ROLE_HOME_MAP[role]
    }
  }
  return '/'
}
