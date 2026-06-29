package com.finance.roboadvisor.common.exception;

import com.finance.roboadvisor.common.api.ResultCode;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class BusinessExceptionTest {

    @Test
    void testConstructorWithResultCode() {
        BusinessException ex = new BusinessException(ResultCode.USER_NOT_FOUND);
        assertEquals(ResultCode.USER_NOT_FOUND.getCode(), ex.getCode());
        assertEquals(ResultCode.USER_NOT_FOUND.getMessage(), ex.getMessage());
    }

    @Test
    void testConstructorWithResultCodeAndCustomMessage() {
        BusinessException ex = new BusinessException(ResultCode.VALIDATE_FAILED, "custom error message");
        assertEquals(ResultCode.VALIDATE_FAILED.getCode(), ex.getCode());
        assertEquals("custom error message", ex.getMessage());
    }

    @Test
    void testIsRuntimeException() {
        BusinessException ex = new BusinessException(ResultCode.SYSTEM_ERROR);
        assertInstanceOf(RuntimeException.class, ex);
    }

    @Test
    void testGetCodeForDifferentResultCodes() {
        assertEquals(ResultCode.UNAUTHORIZED.getCode(),
                new BusinessException(ResultCode.UNAUTHORIZED).getCode());
        assertEquals(ResultCode.FORBIDDEN.getCode(),
                new BusinessException(ResultCode.FORBIDDEN).getCode());
        assertEquals(ResultCode.SYSTEM_ERROR.getCode(),
                new BusinessException(ResultCode.SYSTEM_ERROR).getCode());
    }

    @Test
    void testCustomMessageDiffersFromResultCodeMessage() {
        String customMsg = "this is a custom message";
        BusinessException ex = new BusinessException(ResultCode.VALIDATE_FAILED, customMsg);
        assertNotEquals(ResultCode.VALIDATE_FAILED.getMessage(), ex.getMessage());
        assertEquals(customMsg, ex.getMessage());
    }

    @Test
    void testCanThrowAndCatch() {
        assertThrows(BusinessException.class, () -> {
            throw new BusinessException(ResultCode.FUND_NOT_FOUND);
        });
    }
}
