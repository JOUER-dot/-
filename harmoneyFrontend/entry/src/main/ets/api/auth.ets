// file: entry/src/main/ets/api/auth.ets
import { LoginResponse, PinRequest, UserInfo } from '../models/types';
import { Request } from './request';

export interface LoginRequest {
  username: string;
  password: string;
}

export interface RegisterRequest {
  username: string;
  password: string;
  confirmPassword: string;
  nickname: string;
  phone?: string;
  email?: string;
}

export interface ProfileUpdateRequest {
  nickname?: string;
  phone?: string;
  email?: string;
}

export interface PasswordRequest {
  oldPassword: string;
  newPassword: string;
  confirmPassword: string;
}

export class AuthApi {
  static login(data: LoginRequest): Promise<LoginResponse> {
    return Request.post<LoginResponse>('/auth/login', data);
  }

  static register(data: RegisterRequest): Promise<void> {
    return Request.post<void>('/auth/register', data);
  }

  static me(): Promise<UserInfo> {
    return Request.get<UserInfo>('/auth/me');
  }

  static logout(): Promise<void> {
    return Request.post<void>('/auth/logout');
  }

  static updateProfile(data: ProfileUpdateRequest): Promise<void> {
    return Request.put<void>('/auth/profile', data);
  }

  static changePassword(data: PasswordRequest): Promise<void> {
    return Request.put<void>('/auth/password', data);
  }

  static setPin(pin: string): Promise<void> {
    const body: PinRequest = { pin: pin };
    return Request.post<void>('/auth/pin', body);
  }

  static deleteAccount(): Promise<void> {
    return Request.delete<void>('/auth/account');
  }
}
