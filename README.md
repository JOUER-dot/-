# 智能投顾平台 (RoboAdvisor)

一站式基金投顾管理平台，支持投顾创建组合产品、审核流转、用户订阅、风险画像的全流程管理。本系统模拟了真实的基金投顾业务场景，包含投顾端、审核端、用户端和管理端四个角色视角。

---

## 技术栈

| 层级 | 技术 |
|------|------|
| **前端** | Vue 3 + TypeScript + Vite 5 + Element Plus + Pinia + ECharts + Vue Router |
| **后端** | Java 17 + Spring Boot 3.3 + MyBatis 3.5 + MySQL 8.0 + Spring Security 6 + JWT |
| **AI** | DeepSeek API（可选，未配置时自动使用本地 mock） |
| **构建** | Maven（后端）/ pnpm / npm（前端） |

---

## 项目结构

```
code/
├── backend/                          # Java Spring Boot 后端
│   └── src/main/java/com/finance/roboadvisor/
│       ├── RoboAdvisorApplication.java   # 启动入口
│       ├── auth/                         # 认证授权模块
│       │   ├── controller/AuthController.java      # 登录/注册/注销
│       │   ├── security/                           # JWT 过滤器 + Spring Security 配置
│       │   ├── service/                            # 认证业务逻辑
│       │   └── vo/                                 # 登录信息、当前用户等 VO
│       ├── admin/                        # 系统管理模块
│       │   ├── controller/AdminController.java     # 仪表盘、用户管理
│       │   └── vo/                                 # 管理后台 VO
│       ├── product/                      # 产品管理模块
│       │   ├── controller/                         # 产品 CRUD、策略规则、工作台
│       │   ├── dto/                                # 创建/保存/提交 DTO
│       │   ├── entity/                             # 产品、成份、版本、草稿、审核等实体
│       │   ├── mapper/                             # MyBatis 映射
│       │   ├── service/                            # 产品业务逻辑、净值生成、合规校验
│       │   └── vo/                                 # 产品详情、列表、版本等 VO
│       ├── review/                       # 审核流转模块
│       │   ├── controller/ReviewController.java    # 审核通过/驳回
│       │   ├── support/ReviewDiffBuilder.java      # 版本差异对比
│       │   └── vo/                                 # 审核详情、差异、历史等 VO
│       ├── subscription/                 # 用户订阅模块
│       │   ├── controller/SubscriptionController.java
│       │   ├── service/                            # 订阅业务
│       │   └── vo/                                 # 订阅列表 VO
│       ├── riskprofile/                  # 风险画像模块
│       │   ├── controller/RiskProfileController.java
│       │   ├── dto/RiskAssessmentSubmitDTO.java    # 测评提交 DTO
│       │   ├── entity/                             # 用户画像、测评记录、答案
│       │   ├── mapper/UserRiskProfileMapper.xml
│       │   ├── service/impl/RiskProfileServiceImpl.java  # 评分算法
│       │   └── vo/RiskProfileVO.java               # 画像 VO
│       ├── fund/                         # 基金数据模块
│       │   ├── controller/FundController.java
│       │   ├── entity/FundInfo.java / FundNav.java
│       │   └── vo/FundOptionVO.java
│       ├── notification/                 # 通知系统
│       ├── publicapi/                    # 公开 API（产品专区、对比等）
│       ├── aiassistant/                  # AI 智能助手
│       └── common/                       # 公共模块
│           ├── api/ApiResult.java        # 统一响应体
│           ├── api/ResultCode.java       # 状态码枚举
│           ├── exception/                # BusinessException + GlobalExceptionHandler
│           └── util/                     # JwtUtil, SecurityUtil
│
├── frontend/                          # Vue 3 前端
│   └── src/
│       ├── api/                          # API 接口层
│       │   ├── auth.ts                   # 登录/注册/个人资料
│       │   ├── product.ts                # 产品管理接口
│       │   ├── review.ts                 # 审核接口
│       │   ├── risk-profile.ts           # 风险画像接口
│       │   ├── subscription.ts           # 订阅接口
│       │   ├── fund.ts                   # 基金数据接口
│       │   ├── admin.ts                  # 管理后台接口
│       │   ├── notification.ts           # 通知接口
│       │   ├── workbench.ts              # 工作台接口
│       │   ├── public-product.ts         # 公开产品接口
│       │   └── ai.ts                     # AI 助手接口
│       ├── components/                   # 公共组件
│       │   ├── charts/                   # ECharts 图表
│       │   ├── common/                   # AI 助手面板、页头、导航
│       │   ├── nav/                      # 侧边栏、顶栏、通知铃铛
│       │   ├── product/                  # 产品表单、基金选择弹窗
│       │   └── ui/                       # 操作栏、页面容器、统计卡片等
│       ├── views/                        # 页面
│       │   ├── account/AccountCenter.vue        # 账号中心（含风险画像）
│       │   ├── auth/Login.vue / Register.vue    # 登录/注册
│       │   ├── advisor/                         # 投顾端
│       │   │   ├── ProductList.vue              # 产品列表
│       │   │   └── ProductEdit.vue              # 产品编辑/创建
│       │   ├── review/                          # 审核端
│       │   │   ├── ReviewPendingList.vue        # 待审列表
│       │   │   ├── ReviewDetail.vue             # 审核详情
│       │   │   └── ReviewHistory.vue            # 审核记录
│       │   ├── public/                          # 公开页面（无需登录）
│       │   │   ├── AdvisorZoneList.vue          # 产品专区
│       │   │   ├── AdvisorZoneDetail.vue        # 产品详情
│       │   │   ├── CompareProducts.vue          # 产品对比
│       │   │   ├── MySubscriptions.vue          # 我的订阅
│       │   │   └── PaymentPage.vue              # 支付页
│       │   ├── common/                          # 通用页面
│       │   │   ├── Dashboard.vue                # 工作台
│       │   │   ├── UserDashboard.vue            # 用户工作台
│       │   │   ├── AiChat.vue                   # AI 助手
│       │   │   ├── Notifications.vue            # 通知
│       │   │   └── TransactionHistory.vue       # 交易记录
│       │   ├── admin/                           # 管理端
│       │   │   ├── AdminDashboard.vue           # 运营概览
│       │   │   └── AdminUsers.vue               # 用户管理
│       │   └── error/Forbidden.vue              # 403 页面
│       ├── router/index.ts              # 路由配置 + 权限守卫
│       ├── stores/user.ts               # Pinia 用户状态
│       ├── utils/                       # 工具
│       │   ├── request.ts               # Axios 封装 + 拦截器
│       │   ├── format.ts                # 格式化工具
│       │   ├── api-base-url.ts          # API 基础路径
│       │   └── ...
│       └── styles/                      # 样式
│           ├── tokens.css               # 设计令牌
│           ├── theme.css                # 主题
│           └── app.css                  # 全局样式
│
├── harmoneyFrontend/                  # HarmonyOS 原生客户端（ArkTS）
│   └── entry/src/main/ets/
│       ├── api/                       # API 接口封装（与前端对齐）
│       ├── components/                # 导航、产品、审核、UI 组件
│       ├── pages/                     # 完整页面（登录、产品、审核、管理、订阅等）
│       │   ├── Auth/                  # 登录 / 注册
│       │   ├── Advisor/               # 投顾端（产品管理、编辑）
│       │   ├── Reviewer/              # 审核端（待审列表、详情、历史）
│       │   ├── User/                  # 用户端（订阅、交易、工作台）
│       │   ├── Public/                # 公开页（产品列表、详情、对比）
│       │   ├── Common/                # 通用页（账号中心、仪表盘、通知）
│       │   └── Admin/                 # 管理端（运营概览、用户管理）
│       ├── stores/                    # 状态管理（UserStore/ProductStore/NotificationStore）
│       ├── models/types.ets           # 全局类型定义
│       ├── utils/                     # 格式化、持久化、角色路由
│       └── theme/                     # 色彩、字体、阴影常量
│
└── kingbaseBackend/                   # 人大金仓 KingbaseES 版后端
```

---

## 业务模块

### 四种角色

| 角色 | 用户名 | 职责 |
|------|--------|------|
| **USER** | user01 | 浏览基金投顾产品、订阅产品、做风险测评、管理订阅 |
| **ADVISOR** | advisor01 | 创建和管理组合产品、提交审核 |
| **REVIEWER** | reviewer01 | 审核投顾提交的产品、通过或驳回 |
| **ADMIN** | admin | 系统管理、用户管理、查看运营仪表盘 |

### 核心业务流程

```
投顾创建产品 → 提交审核 → 审核员审核
                              ├── 通过 → 产品上架 → 用户订阅
                              └── 驳回 → 投顾修改后重新提交
```

### 风险画像（Risk Profile）

用户完成风险承受能力测评后，系统根据以下维度计算综合风险评分：

| 维度 | 权重 | 包含指标 |
|------|------|---------|
| 风险承受能力 (CAPACITY) | 35% | 年收入、金融资产、投资期限、流动性需求 |
| 风险偏好态度 (ATTITUDE) | 30% | 回撤容忍度、投资目标、回撤反应 |
| 投资知识经验 (KNOWLEDGE) | 20% | 投资经验、最高产品经验 |
| 流动性需求 (LIQUIDITY) | 15% | 流动性需求评分 |

风险等级：R1（保守型）→ R5（进取型），综合分越高风险承受能力越强。

---

## 数据库

### 建表脚本

| 脚本 | 说明 |
|------|------|
| `backend/src/main/resources/init.sql` | 主表 + 测试数据（产品、基金、用户等） |
| `backend/src/main/resources/risk_profile_migration.sql` | 风险画像相关表（需单独执行） |

### 核心表

| 表 | 说明 |
|----|------|
| `sys_user` / `sys_role` / `sys_user_role` | 用户、角色、关联 |
| `advisor_product` | 投顾组合产品主表 |
| `advisor_product_version` | 产品版本快照（每次提交审核生成新版本） |
| `advisor_product_component` | 产品成份（基金 + 权重） |
| `advisor_product_draft` / `advisor_product_draft_component` | 草稿及草稿成份 |
| `advisor_product_review` / `advisor_product_flow_log` | 审核记录 / 操作日志 |
| `advisor_product_nav` | 产品历史净值 |
| `advisor_product_holding_snapshot` | 持仓快照 |
| `advisor_strategy_rule` | 策略约束规则 |
| `advisor_product_rule_decision` | 投决会规则调整决议 |
| `advisor_product_subscription` | 用户订阅记录 |
| `fund_info` / `fund_nav` | 基金基础信息 / 基金净值 |
| `user_risk_profile` | 用户当前风险画像 |
| `user_risk_assessment` / `user_risk_assessment_answer` | 测评历史 / 答案明细 |
| `notification` | 系统通知 |

---

## API 概览

| 路径 | 方法 | 说明 | 权限 |
|------|------|------|------|
| `/api/auth/login` | POST | 登录 | 公开 |
| `/api/auth/register` | POST | 注册 | 公开 |
| `/api/auth/me` | GET | 获取当前用户信息 | 登录 |
| `/api/auth/logout` | POST | 注销 | 登录 |
| `/api/auth/risk-profile` | GET | 获取风险画像 | USER |
| `/api/auth/risk-profile/assessment` | POST | 提交风险测评 | USER |
| `/api/auth/my-subscriptions` | GET | 我的订阅列表 | USER |
| `/api/public/**` | GET | 产品专区、详情、对比 | 公开 |
| `/api/public/advisor-products/*/subscribe` | POST | 订阅产品 | USER |
| `/api/public/advisor-products/*/unsubscribe` | POST | 取消订阅 | USER |
| `/api/admin/products/**` | CRUD | 产品管理 | ADVISOR |
| `/api/admin/funds/**` | GET | 基金数据 | ADVISOR |
| `/api/admin/workbench/**` | GET | 投顾工作台 | ADVISOR |
| `/api/reviewer/**` | CRUD | 审核操作 | REVIEWER |
| `/api/notifications/**` | GET | 通知 | 登录 |
| `/api/ai/chat` | POST | AI 助手 | 登录 |
| `/api/ai/chat/stream` | POST | AI 流式对话 | 公开 |
| `/api/admin/system/**` | GET | 系统管理 | ADMIN |

### 统一响应格式

```json
{
  "code": 0,
  "message": "ok",
  "data": { }
}
```

| code | 说明 |
|------|------|
| 0 | 成功 |
| 40001 | 参数校验失败 |
| 40101 | 未登录或 token 无效 |
| 40301 | 无权限 |
| 50000 | 系统异常 |

---

## 快速启动

### 前置要求

- JDK 17+
- Maven 3.8+
- Node.js 20+
- MySQL 8.0+

### 1. 初始化数据库

```bash
# 创建 finance 库并导入所有主表和数据
mysql -u root -p < backend/src/main/resources/init.sql

# 导入风险画像表（必须单独执行）
mysql -u root -p < backend/src/main/resources/risk_profile_migration.sql
```

### 2. 修改数据库密码

编辑 `backend/src/main/resources/application-dev.yml`：

```yaml
spring:
  datasource:
    username: root
    password: 你的MySQL密码
```

### 3. 启动后端

```bash
cd backend
mvn spring-boot:run
```

后端默认运行在 `http://localhost:8081`

### 4. 启动前端

```bash
cd frontend
npm install
npm run dev
```

前端默认运行在 `http://localhost:8080`（Vite 自动代理 `/api` 到后端 8081）

### 5. 登录系统

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | admin123 | 系统管理员 |
| advisor01 | 123456 | 投顾 |
| reviewer01 | 123456 | 审核员 |
| user01 | 123456 | 普通用户 |

### 6. 使用 AI 助手（可选）

```powershell
# Windows PowerShell
$env:DEEPSEEK_API_KEY="你的 DeepSeek API Key"
```

未配置时 AI 助手会自动使用本地 mock 回复。

---

## 开发说明

### 前端环境变量

| 文件 | 用途 |
|------|------|
| `.env.development` | 开发环境：`VITE_APP_BASE_API=http://localhost:8081/api` |
| `.env.production` | 生产环境：`VITE_APP_BASE_API=/api` |

开发时前端通过 Vite proxy 转发 `/api` 请求到后端 8081 端口，因此不会遇到跨域问题。

### 后端配置

| 文件 | 用途 |
|------|------|
| `application.yml` | 公共配置（JWT、MyBatis、Jackson） |
| `application-dev.yml` | 开发配置（数据源、日志级别） |

### 常见问题

**Q: 提交风险测评显示"请求失败"？**
A: 检查是否执行了 `risk_profile_migration.sql` 创建风险画像表，以及数据库中的 `advisor_product_subscription` 表是否有数据。详见[#风险画像模块的 Bug 修复记录](#)。

**Q: 登录后页面空白？**
A: 检查前端是否运行在正确的端口（8080），以及后端是否已成功启动。

**Q: AI 助手不回复？**
A: 未配置 `DEEPSEEK_API_KEY` 时系统会使用 mock 回复，不影响正常使用。

---

## 鸿蒙客户端（harmoneyFrontend）

使用 HarmonyOS ArkTS 语言开发的移动端原生客户端，与 Web 前端功能对齐，运行在鸿蒙设备上。

### 技术栈

| 层级 | 技术 |
|------|------|
| 语言 | ArkTS（HarmonyOS 应用开发语言） |
| 框架 | HarmonyOS API + ArkUI |
| 构建 | Hvigor + ohpm |
| 状态管理 | 自定义 Store（UserStore / ProductStore / NotificationStore） |
| 网络 | `http` 模块，封装统一的 `request.ets` |

### 项目结构

```
harmoneyFrontend/entry/src/main/ets/
├── api/                          # 与 Web 前端对齐的 API 封装
│   ├── auth.ets                  # 登录/注册/用户信息
│   ├── product.ets               # 产品管理
│   ├── review.ets                # 审核
│   ├── subscription.ets          # 订阅
│   ├── admin.ets                 # 管理后台
│   ├── notification.ets          # 通知
│   ├── fund.ets                  # 基金数据
│   ├── workbench.ets             # 工作台
│   ├── transaction.ets           # 交易
│   └── request.ets               # HTTP 请求封装
├── components/                   # 可复用组件
│   ├── nav/                      # 底部 Tab 栏、顶部导航栏
│   ├── product/                  # 产品卡片、成份编辑器、基金选择弹窗
│   ├── review/                   # 差异对比组件
│   └── ui/                       # 空状态、分段卡片、骨架屏、统计卡片、状态标签
├── pages/                        # 页面
│   ├── Auth/                     # 登录 / 注册
│   ├── Advisor/                  # 投顾端：产品列表、产品编辑
│   ├── Reviewer/                 # 审核端：待审列表、审核详情、审核历史
│   ├── User/                     # 用户端：我的订阅、交易记录、用户工作台
│   ├── Public/                   # 公开页：产品专区、产品详情、产品对比
│   ├── Common/                   # 通用页：账号中心、仪表盘、通知列表
│   └── Admin/                    # 管理端：运营概览、用户管理
├── stores/                       # 状态管理
├── models/types.ets              # 全局类型定义（与 Web 端接口对齐）
├── utils/                        # 工具函数
└── theme/                        # 设计令牌（色彩、字体、阴影）
```

### API 基础地址

```
模拟器访问宿主机：http://10.0.2.2:8081/api
```

### 登录态

与 Web 前端兼容：本地存储 `finance_auth_state`，同步 `user_token`、`user_roles` 等。

---

## KingbaseES 后端（kingbaseBackend）

将 MySQL 版后端的数据库迁移到**人大金仓 KingbaseES（V8，PostgreSQL 兼容模式）**的独立版本。业务逻辑代码完全复用，仅修改数据源配置和建表 SQL。

### 技术栈差异

| 项目 | MySQL 版 | KingbaseES 版 |
|------|----------|---------------|
| 数据库 | MySQL 8.0 | KingbaseES V8 |
| JDBC 驱动 | `mysql-connector-j` | `kingbase8-8.6.0.jar` |
| 端口 | 3306 | 54321 |
| Schema | `finance` 库 | `finance` 库，`app` schema |
| 分页 | MySQL `LIMIT/OFFSET` | KingbaseES `LIMIT/OFFSET`（兼容） |

### 驱动安装

KingbaseES JDBC 驱动需要手动安装到本地 Maven 仓库：

```bash
mvn install:install-file -Dfile=kingbase8-8.6.0.jar ^
    -DgroupId=com.kingbase8 -DartifactId=kingbase8 ^
    -Dversion=8.6.0 -Dpackaging=jar
```

或在 `pom.xml` 中配置 `scope: system` 引用 `lib/kingbase8-9.0.0.jar`。

### 数据源配置

```yaml
spring:
  datasource:
    driver-class-name: com.kingbase8.Driver
    url: jdbc:kingbase8://localhost:54321/finance
    username: system
    password: 123456
    hikari:
      schema: app
      connection-init-sql: SET search_path TO app;
```

### 建表

```bash
# 在 KingbaseES 的 finance 数据库中执行
# 会自动在 app schema 下创建全部表并导入测试数据
mysql -u system -p < init_kingbase_app.sql
```

> 注意：`init_kingbase_app.sql` 使用 KingbaseES/PostgreSQL 兼容语法（`GENERATED BY DEFAULT AS IDENTITY`、`timestamp` 替代 `datetime`、双引号包裹标识符等），且所有表创建在 `app` schema 下以避免与 Kingbase 系统表冲突。

---

## 测试

```bash
# 前端测试
cd frontend && npm run test

# 后端测试（含覆盖率报告）
cd backend && mvn test
```

---

## 许可

仅供学习交流使用。
