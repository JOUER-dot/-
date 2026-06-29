# 智能投顾鸿蒙端开发记忆

后端接口来自 `后端openapi.json`，业务提示词来自 `给DevEco的完整提示词.md`。移动端使用 HarmonyOS ArkTS，在 `frontend/entry/src/main/ets` 下开发。

- 后端基础地址：模拟器访问宿主机用 `http://10.0.2.2:8081/api`。
- 统一响应：`{ code, message, data }`，`code !== 0` 视为业务失败。
- 登录态：`finance_auth_state` 保存 `{ token, tokenHead, userInfo, roles }`，同时同步 `user_token`、`user_token_head`、`user_info`、`user_roles`。
- 角色入口：`ADMIN -> 运营概览`，`ADVISOR -> 工作台/产品管理`，`REVIEWER -> 待审核`，`USER -> 产品专区`。
- 核心产品状态：`DRAFT -> PENDING_REVIEW -> PUBLISHED/OFFLINE/REJECTED`。
- 默认测试账号：`admin/admin123`、`advisor01/123456`、`reviewer01/123456`、`user01/123456`。

后续开发继续复用 `api/*` 的封装和 `models/types.ets` 的类型，页面只做状态、交互和展示。
