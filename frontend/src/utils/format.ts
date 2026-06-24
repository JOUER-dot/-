export function formatDecimal(value: unknown, digits = 4): string {
  const num = Number(value)
  if (!Number.isFinite(num)) {
    return '-'
  }
  return num.toFixed(digits)
}

export function formatPercent(value: unknown, digits = 2): string {
  const num = Number(value)
  if (!Number.isFinite(num)) {
    return '-'
  }
  return `${(num * 100).toFixed(digits)}%`
}

export function formatText(value: unknown): string {
  if (value === null || value === undefined || value === '') {
    return '-'
  }
  return String(value)
}

