import request from '@/utils/request'

export interface ChangePasswordPayload {
  oldPassword: string
  newPassword: string
  confirmPassword: string
}

export interface UpdateProfilePayload {
  nickname?: string
  phone?: string
  email?: string
}

export function changePassword(payload: ChangePasswordPayload) {
  return request.put<void>('/auth/password', payload)
}

export function updateProfile(payload: UpdateProfilePayload) {
  return request.put<void>('/auth/profile', payload)
}
