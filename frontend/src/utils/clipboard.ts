export async function copyToClipboard(text: string): Promise<boolean> {
  const content = String(text || '')
  if (!content) {
    return false
  }

  try {
    if (navigator.clipboard?.writeText) {
      await navigator.clipboard.writeText(content)
      return true
    }
  } catch {
    void 0
  }

  try {
    const textarea = document.createElement('textarea')
    textarea.value = content
    textarea.setAttribute('readonly', 'true')
    textarea.style.position = 'fixed'
    textarea.style.top = '-1000px'
    textarea.style.left = '-1000px'
    document.body.appendChild(textarea)
    textarea.select()
    textarea.setSelectionRange(0, textarea.value.length)
    const ok = document.execCommand('copy')
    document.body.removeChild(textarea)
    return ok
  } catch {
    return false
  }
}
