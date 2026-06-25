const ABSOLUTE_URL_PATTERN = /^https?:\/\//i

export function normalizeApiBaseUrl(rawBaseUrl?: string) {
  const baseUrl = rawBaseUrl?.trim()

  if (!baseUrl) {
    return '/api'
  }

  if (ABSOLUTE_URL_PATTERN.test(baseUrl)) {
    return baseUrl.replace(/\/+$/, '')
  }

  const normalizedPath = baseUrl.replace(/^\/+/, '').replace(/\/+$/, '')
  return `/${normalizedPath}`
}
