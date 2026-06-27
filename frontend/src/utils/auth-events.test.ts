import { describe, it, expect, vi } from 'vitest'
import { onAuthEvent, emitAuthEvent } from './auth-events'

describe('auth-events', () => {
  it('should register and emit logout event', () => {
    const handler = vi.fn()
    onAuthEvent('logout', handler)

    emitAuthEvent('logout', { reason: 'manual' })

    expect(handler).toHaveBeenCalledTimes(1)
    expect(handler).toHaveBeenCalledWith({ reason: 'manual' })
  })

  it('should emit logout with unauthorized reason', () => {
    const handler = vi.fn()
    onAuthEvent('logout', handler)

    emitAuthEvent('logout', { reason: 'unauthorized' })

    expect(handler).toHaveBeenCalledWith({ reason: 'unauthorized' })
  })

  it('should emit logout with forbidden reason', () => {
    const handler = vi.fn()
    onAuthEvent('logout', handler)

    emitAuthEvent('logout', { reason: 'forbidden' })

    expect(handler).toHaveBeenCalledWith({ reason: 'forbidden' })
  })

  it('should support multiple handlers for same event', () => {
    const handler1 = vi.fn()
    const handler2 = vi.fn()

    onAuthEvent('logout', handler1)
    onAuthEvent('logout', handler2)

    emitAuthEvent('logout', { reason: 'manual' })

    expect(handler1).toHaveBeenCalledTimes(1)
    expect(handler2).toHaveBeenCalledTimes(1)
  })

  it('should return unsubscribe function', () => {
    const handler = vi.fn()
    const unsubscribe = onAuthEvent('logout', handler)

    unsubscribe()

    emitAuthEvent('logout', { reason: 'manual' })

    expect(handler).not.toHaveBeenCalled()
  })

  it('should do nothing when emitting event with no handlers', () => {
    // Should not throw
    expect(() => {
      emitAuthEvent('logout', { reason: 'manual' })
    }).not.toThrow()
  })

  it('should not call unsubscribed handlers', () => {
    const handler1 = vi.fn()
    const handler2 = vi.fn()

    const unsub = onAuthEvent('logout', handler1)
    onAuthEvent('logout', handler2)

    unsub()

    emitAuthEvent('logout', { reason: 'manual' })

    expect(handler1).not.toHaveBeenCalled()
    expect(handler2).toHaveBeenCalledTimes(1)
  })
})
