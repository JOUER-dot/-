// file: entry/src/main/ets/utils/persist.ets
import { AuthState, UserInfo } from '../models/types';

export const AUTH_STATE_KEY: string = 'finance_auth_state';
export const USER_TOKEN_KEY: string = 'user_token';
export const USER_TOKEN_HEAD_KEY: string = 'user_token_head';
export const USER_INFO_KEY: string = 'user_info';
export const USER_ROLES_KEY: string = 'user_roles';
export const UNREAD_COUNT_KEY: string = 'unread_count';

export function saveAuthState(state: AuthState): void {
  AppStorage.setOrCreate<string>(AUTH_STATE_KEY, JSON.stringify(state));
  AppStorage.setOrCreate<string>(USER_TOKEN_KEY, state.token);
  AppStorage.setOrCreate<string>(USER_TOKEN_HEAD_KEY, state.tokenHead);
  AppStorage.setOrCreate<UserInfo | null>(USER_INFO_KEY, state.userInfo);
  AppStorage.setOrCreate<string[]>(USER_ROLES_KEY, state.roles);
}

export function loadAuthState(): AuthState {
  const raw = AppStorage.get<string>(AUTH_STATE_KEY) || '';
  if (raw.length === 0) {
    const emptyState: AuthState = { token: '', tokenHead: 'Bearer ', userInfo: null, roles: [] };
    return emptyState;
  }
  const parsed = JSON.parse(raw) as AuthState;
  const state: AuthState = {
    token: parsed.token || '',
    tokenHead: parsed.tokenHead || 'Bearer ',
    userInfo: parsed.userInfo || null,
    roles: parsed.roles || []
  };
  return state;
}

export function clearAuthState(): void {
  AppStorage.setOrCreate<string>(AUTH_STATE_KEY, '');
  AppStorage.setOrCreate<string>(USER_TOKEN_KEY, '');
  AppStorage.setOrCreate<string>(USER_TOKEN_HEAD_KEY, 'Bearer ');
  AppStorage.setOrCreate<UserInfo | null>(USER_INFO_KEY, null);
  AppStorage.setOrCreate<string[]>(USER_ROLES_KEY, []);
}
