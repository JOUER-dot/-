package com.finance.roboadvisor.common.api;

public enum ResultCode {

    SUCCESS(0, "ok"),
    VALIDATE_FAILED(40001, "参数校验失败"),
    REGISTER_INVALID(40002, "注册信息不合法"),
    PASSWORD_NOT_MATCH(40003, "两次密码不一致"),
    UNAUTHORIZED(40101, "未登录或 token 无效"),
    USERNAME_OR_PASSWORD_ERROR(40102, "用户名或密码错误"),
    FORBIDDEN(40301, "无权限"),
    USER_NOT_FOUND(40401, "用户不存在"),
    FUND_NOT_FOUND(40402, "基金不存在"),
    STATUS_NOT_ALLOWED(40901, "当前状态不允许该操作"),
    WEIGHT_INVALID(40902, "权重校验失败"),
    USERNAME_EXISTS(40903, "用户名已存在"),
    PHONE_EXISTS(40904, "手机号已存在"),
    FUND_DISABLED(40905, "基金已停用，不能加入新组合"),
    SYSTEM_ERROR(50000, "系统异常");

    private final int code;
    private final String message;

    ResultCode(int code, String message) {
        this.code = code;
        this.message = message;
    }

    public int getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }
}
