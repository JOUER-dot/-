package com.finance.roboadvisor.common.api;

public class ApiResult<T> {

    private Integer code;
    private String message;
    private T data;

    public ApiResult() {
    }

    public ApiResult(Integer code, String message, T data) {
        this.code = code;
        this.message = message;
        this.data = data;
    }

    public static <T> ApiResult<T> success(T data) {
        return new ApiResult<>(ResultCode.SUCCESS.getCode(), ResultCode.SUCCESS.getMessage(), data);
    }

    public static <T> ApiResult<T> success(String message, T data) {
        return new ApiResult<>(ResultCode.SUCCESS.getCode(), message, data);
    }

    public static <T> ApiResult<T> success(String message) {
        return new ApiResult<>(ResultCode.SUCCESS.getCode(), message, null);
    }

    public static <T> ApiResult<T> failed(ResultCode resultCode) {
        return new ApiResult<>(resultCode.getCode(), resultCode.getMessage(), null);
    }

    public static <T> ApiResult<T> failed(ResultCode resultCode, String message) {
        return new ApiResult<>(resultCode.getCode(), message, null);
    }

    public static <T> ApiResult<T> failed(Integer code, String message) {
        return new ApiResult<>(code, message, null);
    }

    public Integer getCode() {
        return code;
    }

    public void setCode(Integer code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }
}
