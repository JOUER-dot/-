# 智能投顾平台 (RoboAdvisor)

一站式基金投顾管理平台，支持投顾创建组合产品、审核流转、用户订阅的全流程管理。

## 技术栈

| 层级 | 技术 |
|---|---|
| 前端 | Vue 3 + TypeScript + Vite + Element Plus + Pinia + ECharts |
| 后端 | Java 17 + Spring Boot 3.3 + MyBatis + MySQL + Spring Security + JWT |
| 构建 | Maven (后端) / pnpm (前端) |

## 快速启动

### 前置要求

- JDK 17+
- Maven 3.8+
- Node.js 20+
- MySQL 8.0+

### 1. 启动数据库

```sql
CREATE DATABASE IF NOT EXISTS finance DEFAULT CHARSET utf8mb4;
-- 导入建表语句: backend/src/main/resources/init.sql
```

### 2. 修改数据库配置

编辑 `backend/src/main/resources/application-dev.yml`，修改数据库连接信息。

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

前端默认运行在 `http://localhost:5173`

### 5. 默认账号

| 用户名 | 密码 | 角色 |
|---|---|---|
| admin | admin123 | 系统管理员 |
| advisor01 | 123456 | 投顾 |
| reviewer01 | 123456 | 投资决策委员会 |
| user01 | 123456 | 普通用户 |

## 项目结构

```
├── backend/
│   └── src/main/java/com/finance/roboadvisor/
│       ├── auth/          # 认证授权
│       ├── admin/         # 管理后台
│       ├── notification/  # 通知系统
│       ├── product/       # 产品管理
│       ├── review/        # 审核流转
│       ├── subscription/  # 用户订阅
│       ├── fund/          # 基金数据
│       └── publicapi/     # 公开API
├── frontend/src/
│   ├── api/               # API 接口
│   ├── components/        # 公共组件
│   ├── views/             # 页面
│   ├── router/            # 路由
│   ├── stores/            # 状态管理
│   └── styles/            # 样式
└── docs/                  # 设计文档
```
