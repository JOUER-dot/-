// file: entry/src/main/ets/models/types.ets
export interface ApiResult<T> {
  code: number;
  message: string;
  data: T;
}

export interface PageResult<T> {
  records: T[];
  total: number;
  pageNum: number;
  pageSize: number;
}

export class MapObject {
}

export interface UserInfo {
  id: number;
  username: string;
  nickname: string;
  phone?: string;
  email?: string;
  roles?: string[];
}

export interface AuthState {
  token: string;
  tokenHead: string;
  userInfo: UserInfo | null;
  roles: string[];
}

export interface LoginResponse {
  token: string;
  tokenHead: string;
  userInfo: UserInfo;
  roles: string[];
}

export interface PinRequest {
  pin: string;
}

export interface PublicAdvisor {
  id: number;
  name: string;
}

export interface ProductListItem {
  id: number;
  name: string;
  type: string;
  riskLevel: string;
  strategyCode?: string;
  creatorName?: string;
  latestCumReturn?: number;
  featureTags?: string[];
  fundCompanies?: string[];
  status?: string;
  updatedAt?: string;
  lastRejectComment?: string;
  versionNo?: number;
  submittedAt?: string;
  changeType?: string;
  versionNote?: string;
}

export interface ProductComponentItem {
  fundId: number;
  fundCode?: string;
  fundName?: string;
  fundType?: string;
  riskLevel?: string;
  companyName?: string;
  weight: number;
}

export interface NavPoint {
  navDate: string;
  nav: number;
  cumReturn?: number;
}

export interface ProductDetail {
  id: number;
  name: string;
  type: string;
  riskLevel: string;
  strategyCode: string;
  status?: string;
  creatorName?: string;
  versionId?: number;
  versionNo?: number;
  versionStatus?: string;
  submittedAt?: string;
  featureTags?: string[];
  baseInfo?: MapObject;
  params?: MapObject;
  components?: ProductComponentItem[];
  navList?: NavPoint[];
  lastRejectComment?: string;
  reviewSummary?: ReviewRecord[];
  changeType?: string;
  versionNote?: string;
}

export interface ProductSaveComponent {
  fundId: number;
  weight: number;
}

export interface ProductSaveRequest {
  name: string;
  type: string;
  riskLevel: string;
  strategyCode: string;
  featureTags: string[];
  baseInfo: MapObject;
  params: MapObject;
  components: ProductSaveComponent[];
}

export interface ProductCreateResult {
  productId: number;
}

export interface ProductSubmitRequest {
  changeType: string;
  versionNote: string;
}

export interface ReviewRecord {
  id?: number;
  productId?: number;
  productName?: string;
  result: string;
  comment?: string;
  reviewerName?: string;
  reviewedAt?: string;
}

export interface ReviewApproveRequest {
  decisionComment: string;
}

export interface ReviewRejectRequest {
  comment: string;
}

export interface ReviewDiffField {
  fieldKey: string;
  fieldLabel: string;
  beforeValue?: object | string | number | boolean;
  afterValue?: object | string | number | boolean;
  majorSignal: boolean;
}

export interface ReviewDiffComponent {
  diffType: string;
  fundId: number;
  fundCode?: string;
  fundName?: string;
  beforeWeight?: number;
  afterWeight?: number;
  deltaWeight?: number;
}

export interface ReviewDetail extends ProductDetail {
  versionStatus?: string;
  baseVersionSummary?: object;
  currentVersionSummary?: object;
  fieldDiffs?: ReviewDiffField[];
  componentDiffs?: ReviewDiffComponent[];
}

export interface SubscriptionAction {
  id: number;
  productVersionId: number;
  actionType: string;
  actionStatus: string;
  changeType?: string;
  versionNote?: string;
  createdAt: string;
}

export interface SubscriptionItem {
  subscriptionId: number;
  productId: number;
  productName: string;
  type: string;
  riskLevel: string;
  status: string;
  productStatus: string;
  latestNav?: number;
  latestCumReturn?: number;
  subscribedAt: string;
  pendingVersionActions?: SubscriptionAction[];
}

export interface SubscribeRequest {
  amount: number;
}

export interface SubscriptionDecisionRequest {
  decision: string;
}

export interface TransactionRecord {
  id: number;
  productId: number;
  productName: string;
  type: string;
  amount: number;
  status: string;
  createdAt: string;
}

export interface NotificationItem {
  id: number;
  userId: number;
  title: string;
  content: string;
  type: string;
  read: boolean;
  relatedUrl?: string;
  createdAt: string;
}

export interface NotificationUnreadCount {
  count: number;
}

export interface FundOption {
  id: number;
  fundCode: string;
  fundName: string;
  fundType: string;
  riskLevel: string;
  companyName: string;
  status: number;
}

export interface WorkbenchOverview {
  totalProducts: number;
  publishedProducts: number;
  pendingReviewProducts: number;
  rejectedProducts: number;
  draftProducts: number;
  totalSubscriptions: number;
  recentWeekSubscriptions: number;
}

export interface WorkbenchData {
  overview: WorkbenchOverview;
  urgentProducts: ProductListItem[];
  productRankings: ProductListItem[];
}

export interface AdminDashboardData {
  totalProducts: number;
  publishedProducts: number;
  pendingReviewProducts: number;
  totalAdvisors: number;
  totalUsers: number;
  totalSubscriptions: number;
  topSubscribedProducts: ProductSubscription[];
  recentChanges: RecentChange[];
}

export interface ProductSubscription {
  productId: number;
  productName: string;
  subscriberCount: number;
}

export interface RecentChange {
  productId: number;
  productName: string;
  actionType: string;
  operatorName: string;
  createdAt: string;
}

export interface AdminUser {
  id: number;
  username: string;
  nickname: string;
  phone?: string;
  email?: string;
  status: number;
  roles: string[];
  createdAt: string;
}

export interface AdminRoleRequest {
  roleCode: string;
}
