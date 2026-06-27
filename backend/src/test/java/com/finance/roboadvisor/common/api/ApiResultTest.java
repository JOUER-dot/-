package com.finance.roboadvisor.common.api;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class ApiResultTest {

    @Test
    void testSuccessWithData() {
        ApiResult<Object> result = ApiResult.success((Object) "hello");
        assertEquals(ResultCode.SUCCESS.getCode(), result.getCode());
        assertEquals(ResultCode.SUCCESS.getMessage(), result.getMessage());
        assertEquals("hello", result.getData());
    }

    @Test
    void testSuccessWithMessageAndData() {
        ApiResult<Integer> result = ApiResult.success("自定义消息", 42);
        assertEquals(ResultCode.SUCCESS.getCode(), result.getCode());
        assertEquals("自定义消息", result.getMessage());
        assertEquals(42, result.getData());
    }

    @Test
    void testSuccessWithMessageOnly() {
        ApiResult<Void> result = ApiResult.success("仅消息");
        assertEquals(ResultCode.SUCCESS.getCode(), result.getCode());
        assertEquals("仅消息", result.getMessage());
        assertNull(result.getData());
    }

    @Test
    void testFailedWithResultCode() {
        ApiResult<Void> result = ApiResult.failed(ResultCode.UNAUTHORIZED);
        assertEquals(ResultCode.UNAUTHORIZED.getCode(), result.getCode());
        assertEquals(ResultCode.UNAUTHORIZED.getMessage(), result.getMessage());
        assertNull(result.getData());
    }

    @Test
    void testFailedWithResultCodeAndMessage() {
        ApiResult<Void> result = ApiResult.failed(ResultCode.FORBIDDEN, "自定义无权限");
        assertEquals(ResultCode.FORBIDDEN.getCode(), result.getCode());
        assertEquals("自定义无权限", result.getMessage());
        assertNull(result.getData());
    }

    @Test
    void testFailedWithCodeAndMessage() {
        ApiResult<Void> result = ApiResult.failed(99999, "自定义错误");
        assertEquals(99999, result.getCode());
        assertEquals("自定义错误", result.getMessage());
        assertNull(result.getData());
    }

    @Test
    void testGettersAndSetters() {
        ApiResult<String> result = new ApiResult<>();
        result.setCode(200);
        result.setMessage("msg");
        result.setData("data");
        assertEquals(200, result.getCode());
        assertEquals("msg", result.getMessage());
        assertEquals("data", result.getData());
    }

    @Test
    void testConstructor() {
        ApiResult<Integer> result = new ApiResult<>(1, "test", 100);
        assertEquals(1, result.getCode());
        assertEquals("test", result.getMessage());
        assertEquals(100, result.getData());
    }

    @Test
    void testPageResult() {
        PageResult<String> page = new PageResult<>(java.util.List.of("a", "b"), 100L, 1, 10);
        assertEquals(2, page.getRecords().size());
        assertEquals(100L, page.getTotal());
        assertEquals(1, page.getPageNum());
        assertEquals(10, page.getPageSize());
    }

    @Test
    void testPageResultEmptyConstructor() {
        PageResult<String> page = new PageResult<>();
        assertNull(page.getRecords());
        assertNull(page.getTotal());

        page.setRecords(java.util.List.of("x"));
        page.setTotal(1L);
        page.setPageNum(2);
        page.setPageSize(20);
        assertEquals(1, page.getRecords().size());
        assertEquals(1L, page.getTotal());
        assertEquals(2, page.getPageNum());
        assertEquals(20, page.getPageSize());
    }

    @Test
    void testResultCodeValues() {
        assertEquals(0, ResultCode.SUCCESS.getCode());
        assertEquals(40001, ResultCode.VALIDATE_FAILED.getCode());
        assertEquals(40101, ResultCode.UNAUTHORIZED.getCode());
        assertEquals(40301, ResultCode.FORBIDDEN.getCode());
        assertEquals(40901, ResultCode.STATUS_NOT_ALLOWED.getCode());
        assertEquals(50000, ResultCode.SYSTEM_ERROR.getCode());
    }
}
