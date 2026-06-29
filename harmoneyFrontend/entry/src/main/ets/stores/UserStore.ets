// file: entry/src/main/ets/stores/UserStore.ets
import { AuthApi, LoginRequest, ProfileUpdateRequest } from '../api/auth';
import { AuthState, UserInfo } from '../models/types';
import { clearAuthState, loadAuthState, saveAuthState, USER_INFO_KEY, USER_ROLES_KEY, USER_TOKEN_HEAD_KEY, USER_TOKEN_KEY } from '../utils/persist';

export class UserStore {
  static get token(): string {
    return AppStorage.get<string>(USER_TOKEN_KEY) || '';
  }

  static get tokenHead(): string {
    return AppStorage.get<string>(USER_TOKEN_HEAD_KEY) || 'Bearer ';
  }

  static get userInfo(): UserInfo | null {
    return AppStorage.get<UserInfo | null>(USER_INFO_KEY) || null;
  }

  static get roles(): string[] {
    return AppStorage.get<string[]>(USER_ROLES_KEY) || [];
  }

  static async login(username: string, password: string): Promise<AuthState> {
    const body: LoginRequest = { username: username, password: password };
    const data = await AuthApi.login(body);
    const state: AuthState = {
      token: data.token,
      tokenHead: data.tokenHead || 'Bearer ',
      userInfo: data.userInfo,
      roles: data.roles || []
    };
    saveAuthState(state);
    return state;
  }

  static async getProfile(): Promise<UserInfo> {
    const profile = await AuthApi.me();
    const roles = profile.roles || UserStore.roles;
    const state: AuthState = {
      token: UserStore.token,
      tokenHead: UserStore.tokenHead,
      userInfo: profile,
      roles: roles
    };
    saveAuthState(state);
    return profile;
  }

  static async restoreSession(): Promise<AuthState> {
    const state = loadAuthState();
    saveAuthState(state);
    if (state.token.length > 0) {
      try {
        await UserStore.getProfile();
      } catch (error) {
        clearAuthState();
      }
    }
    return loadAuthState();
  }

  static async updateProfile(data: ProfileUpdateRequest): Promise<void> {
    await AuthApi.updateProfile(data);
    await UserStore.getProfile();
  }

  static async logout(callApi: boolean = true): Promise<void> {
    if (callApi && UserStore.token.length > 0) {
      try {
        await AuthApi.logout();
      } catch (error) {
      }
    }
    clearAuthState();
  }

  static hasAnyRole(roles: string[]): boolean {
    const current = UserStore.roles;
    return roles.some((role: string) => current.includes(role));
  }
}
