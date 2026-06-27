import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { copyToClipboard } from './clipboard'

describe('copyToClipboard', () => {
  const originalClipboard = navigator.clipboard
  const originalExecCommand = document.execCommand

  beforeEach(() => {
    Object.defineProperty(navigator, 'clipboard', {
      value: { writeText: vi.fn().mockResolvedValue(undefined) },
      writable: true,
      configurable: true
    })
    document.execCommand = vi.fn().mockReturnValue(true)
  })

  afterEach(() => {
    Object.defineProperty(navigator, 'clipboard', { value: originalClipboard, configurable: true })
    document.execCommand = originalExecCommand
  })

  it('should use clipboard API when available', async () => {
    const result = await copyToClipboard('test text')
    expect(result).toBe(true)
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith('test text')
  })

  it('should fall back to execCommand when clipboard API fails', async () => {
    Object.defineProperty(navigator, 'clipboard', {
      value: {
        writeText: vi.fn().mockRejectedValue(new Error('permission denied'))
      },
      configurable: true
    })

    const result = await copyToClipboard('fallback text')
    expect(result).toBe(true)
    expect(document.execCommand).toHaveBeenCalledWith('copy')
  })

  it('should return false for empty string', async () => {
    const result = await copyToClipboard('')
    expect(result).toBe(false)
  })

  it('should return false for null', async () => {
    const result = await copyToClipboard(null as unknown as string)
    expect(result).toBe(false)
  })

  it('should return false for undefined', async () => {
    const result = await copyToClipboard(undefined as unknown as string)
    expect(result).toBe(false)
  })

  it('should handle clipboard API not being available', async () => {
    Object.defineProperty(navigator, 'clipboard', {
      value: undefined,
      configurable: true
    })

    const result = await copyToClipboard('no clipboard API')
    expect(result).toBe(true)
    expect(document.execCommand).toHaveBeenCalledWith('copy')
  })
})
