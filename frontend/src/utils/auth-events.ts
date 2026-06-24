type AuthEventType = 'logout'

type AuthEventPayloadMap = {
  logout: { reason: 'manual' | 'unauthorized' | 'forbidden' }
}

type AuthEventHandler<T extends AuthEventType> = (payload: AuthEventPayloadMap[T]) => void

const handlers: Partial<{ [K in AuthEventType]: Set<AuthEventHandler<K>> }> = {}

export function onAuthEvent<T extends AuthEventType>(type: T, handler: AuthEventHandler<T>) {
  const set = (handlers[type] as Set<AuthEventHandler<T>> | undefined) ?? new Set()
  set.add(handler)
  handlers[type] = set as never
  return () => set.delete(handler)
}

export function emitAuthEvent<T extends AuthEventType>(type: T, payload: AuthEventPayloadMap[T]) {
  const set = handlers[type] as Set<AuthEventHandler<T>> | undefined
  if (!set) {
    return
  }
  for (const handler of set.values()) {
    handler(payload)
  }
}
