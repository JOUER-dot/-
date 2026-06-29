// file: entry/src/main/ets/api/request.ets
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { ApiResult } from '../models/types';
import { clearAuthState, loadAuthState } from '../utils/persist';

export class QueryParam {
  key: string;
  value: string;

  constructor(key: string, value: string | number | boolean | undefined) {
    this.key = key;
    if (value === undefined || value === null) {
      this.value = '';
    } else {
      this.value = `${value}`;
    }
  }

  isValid(): boolean {
    return this.value.length > 0;
  }
}

export type QueryParams = QueryParam[];

export interface RequestHeaders {
  'Content-Type': string;
  Authorization?: string;
}

export class Request {
  static readonly baseURL: string = 'http://localhost:8081/api';
  static readonly fallbackBaseURLs: string[] = [
    'http://localhost:8081/api',
    'http://127.0.0.1:8081/api',
    'http://10.0.2.2:8081/api'
  ];
  static readonly timeout: number = 15000;

  static async get<T>(url: string, params?: QueryParams): Promise<T> {
    return Request.request<T>('GET', url, undefined, params);
  }

  static async post<T>(url: string, data?: object, params?: QueryParams): Promise<T> {
    return Request.request<T>('POST', url, data, params);
  }

  static async put<T>(url: string, data?: object, params?: QueryParams): Promise<T> {
    return Request.request<T>('PUT', url, data, params);
  }

  static async delete<T>(url: string, params?: QueryParams): Promise<T> {
    return Request.request<T>('DELETE', url, undefined, params);
  }

  private static buildUrl(baseURL: string, url: string, params?: QueryParams): string {
    let fullUrl = `${baseURL}${url}`;
    if (!params) {
      return fullUrl;
    }
    const queries: string[] = [];
    params.forEach((param: QueryParam) => {
      if (param.isValid()) {
        queries.push(`${encodeURIComponent(param.key)}=${encodeURIComponent(param.value)}`);
      }
    });
    if (queries.length > 0) {
      fullUrl = `${fullUrl}?${queries.join('&')}`;
    }
    return fullUrl;
  }

  private static headers(): RequestHeaders {
    const state = loadAuthState();
    const headers: RequestHeaders = {
      'Content-Type': 'application/json'
    };
    if (state.token.length > 0) {
      const tokenHead = state.tokenHead && state.tokenHead.length > 0 ? state.tokenHead : 'Bearer ';
      headers.Authorization = `${tokenHead}${state.token}`.trim().startsWith('Bearer')
        ? `${tokenHead}${state.token}`
        : `Bearer ${state.token}`;
    }
    return headers;
  }

  private static async request<T>(method: string, url: string, data?: object, params?: QueryParams): Promise<T> {
    let lastError: string = '网络异常，请检查后端服务';
    for (let index = 0; index < Request.fallbackBaseURLs.length; index++) {
      const baseURL = Request.fallbackBaseURLs[index];
      try {
        return await Request.requestWithBase<T>(baseURL, method, url, data, params);
      } catch (error) {
        lastError = `${error}`;
        if (!lastError.startsWith('NETWORK_ERROR')) {
          return Promise.reject<T>(lastError);
        }
      }
    }
    promptAction.showToast({ message: '无法连接后端服务，请确认 8081 已启动' });
    return Promise.reject<T>(lastError);
  }

  private static async requestWithBase<T>(baseURL: string, method: string, url: string, data?: object, params?: QueryParams): Promise<T> {
    const client = http.createHttp();
    const targetUrl = Request.buildUrl(baseURL, url, params);
    try {
      const options: http.HttpRequestOptions = {
        method: Request.toHttpMethod(method),
        header: Request.headers(),
        extraData: data ? JSON.stringify(data) : '',
        connectTimeout: Request.timeout,
        readTimeout: Request.timeout
      };
      const response = await client.request(targetUrl, options);
      const status = response.responseCode;
      if (status === 401) {
        clearAuthState();
        promptAction.showToast({ message: '登录已过期，请重新登录' });
        router.replaceUrl({ url: 'pages/Auth/LoginPage' });
        return Promise.reject<T>('BUSINESS_ERROR: 登录已过期，请重新登录');
      }
      if (status < 200 || status >= 300) {
        return Promise.reject<T>(`NETWORK_ERROR: HTTP ${status}`);
      }
      const raw = `${response.result}`;
      const apiResult = JSON.parse(raw) as ApiResult<T>;
      if (apiResult.code !== 0) {
        const message = apiResult.message || `后端返回业务错误：${apiResult.code}`;
        promptAction.showToast({ message: message });
        return Promise.reject<T>(`BUSINESS_ERROR: ${message}`);
      }
      return apiResult.data;
    } catch (error) {
      const message = `${error}`;
      if (message.startsWith('BUSINESS_ERROR')) {
        return Promise.reject<T>(message);
      }
      return Promise.reject<T>(`NETWORK_ERROR: ${message}`);
    } finally {
      client.destroy();
    }
  }

  private static toHttpMethod(method: string): http.RequestMethod {
    switch (method) {
      case 'POST':
        return http.RequestMethod.POST;
      case 'PUT':
        return http.RequestMethod.PUT;
      case 'DELETE':
        return http.RequestMethod.DELETE;
      default:
        return http.RequestMethod.GET;
    }
  }
}
