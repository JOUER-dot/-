// file: entry/src/main/ets/utils/format.ets
export function textOrDash(value?: string): string {
  if (value === undefined || value === null || value.length === 0) {
    return '-';
  }
  return value;
}

export function percent(value?: number): string {
  if (value === undefined || value === null) {
    return '-';
  }
  const display = (value * 100).toFixed(2);
  return `${display}%`;
}

export function weightPercent(value?: number): string {
  if (value === undefined || value === null) {
    return '0%';
  }
  return `${value.toFixed(2)}%`;
}

export function money(value?: number): string {
  if (value === undefined || value === null) {
    return '-';
  }
  return `¥${value.toFixed(2)}`;
}

export function shortDate(value?: string): string {
  if (!value) {
    return '-';
  }
  return value.length > 10 ? value.substring(0, 10) : value;
}

export function firstChar(value?: string): string {
  if (!value || value.length === 0) {
    return 'U';
  }
  return value.substring(0, 1).toUpperCase();
}

export function jsonText(value?: object): string {
  if (value === undefined || value === null) {
    return '{}';
  }
  return JSON.stringify(value);
}
