import { computed, ref } from 'vue'
import { defineStore } from 'pinia'

import request, { AUTH_STORAGE_KEY } from '@/utils/request'

export interface UserInfo {
  id: number
  username: string
  nickname: string
}

export interface LoginResponse {
  token: string
  tokenHead: string
  userInfo: UserInfo
  roles: string[]
}

export interface CurrentUserResponse {
  id: number
  username: string
  nickname: string
  roles: string[]
}

type PersistState = {
  token: string
  tokenHead: string
  userInfo: UserInfo | null
  roles: string[]
}

function readPersistedState(): PersistState {
  const raw = localStorage.getItem(AUTH_STORAGE_KEY)
  if (!raw) {
    return {
      token: '',
      tokenHead: 'Bearer ',
      userInfo: null,
      roles: []
    }
  }
  try {
    const parsed = JSON.parse(raw) as PersistState
    return {
      token: parsed.token || '',
      tokenHead: parsed.tokenHead || 'Bearer ',
      userInfo: parsed.userInfo || null,
      roles: parsed.roles || []
    }
  } catch {
    return {
      token: '',
      tokenHead: 'Bearer ',
      userInfo: null,
      roles: []
    }
  }
}

export const useUserStore = defineStore('user', () => {
  const persisted = readPersistedState()

  const token = ref(persisted.token)
  const tokenHead = ref(persisted.tokenHead)
  const userInfo = ref<UserInfo | null>(persisted.userInfo)
  const roles = ref<string[]>(persisted.roles)

  const isLoggedIn = computed(() => !!token.value)

  const persist = () => {
    localStorage.setItem(
      AUTH_STORAGE_KEY,
      JSON.stringify({
        token: token.value,
        tokenHead: tokenHead.value,
        userInfo: userInfo.value,
        roles: roles.value
      })
    )
  }

  const reset = () => {
    token.value = ''
    tokenHead.value = 'Bearer '
    userInfo.value = null
    roles.value = []
    localStorage.removeItem(AUTH_STORAGE_KEY)
  }

  const login = async (payload: { username: string; password: string }) => {
    const data = await request.post<LoginResponse>('/auth/login', payload)
    token.value = data.token
    tokenHead.value = data.tokenHead || 'Bearer '
    userInfo.value = data.userInfo
    roles.value = data.roles || []
    persist()
    return data
  }

  const getProfile = async () => {
    const data = await request.get<CurrentUserResponse>('/auth/me')
    userInfo.value = {
      id: data.id,
      username: data.username,
      nickname: data.nickname
    }
    roles.value = data.roles || []
    persist()
    return data
  }

  const restoreSession = async () => {
    if (!token.value) {
      return null
    }
    return getProfile()
  }

  const logout = async (callApi = true) => {
    try {
      if (callApi && token.value) {
        await request.post('/auth/logout')
      }
    } finally {
      reset()
    }
  }

  const hasAnyRole = (requiredRoles: string[]) => {
    if (requiredRoles.length === 0) {
      return true
    }
    return requiredRoles.some((role) => roles.value.includes(role))
  }

  return {
    token,
    tokenHead,
    userInfo,
    roles,
    isLoggedIn,
    login,
    getProfile,
    restoreSession,
    logout,
    hasAnyRole
  }
})
