package com.finance.roboadvisor.common.exception;

import com.finance.roboadvisor.common.api.ApiResult;
import com.finance.roboadvisor.common.api.ResultCode;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.validation.BindException;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;

import java.util.Collections;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

public class GlobalExceptionHandlerTest {

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    // ===== BusinessException =====

    @Test
    void testHandleBusinessException() {
        BusinessException ex = new BusinessException(ResultCode.USER_NOT_FOUND);
        ApiResult<Void> result = handler.handleBusinessException(ex);
        assertEquals(ResultCode.USER_NOT_FOUND.getCode(), result.getCode());
        assertEquals(ResultCode.USER_NOT_FOUND.getMessage(), result.getMessage());
        assertNull(result.getData());
    }

    @Test
    void testHandleBusinessExceptionWithCustomMessage() {
        BusinessException ex = new BusinessException(ResultCode.VALIDATE_FAILED, "custom error");
        ApiResult<Void> result = handler.handleBusinessException(ex);
        assertEquals(ResultCode.VALIDATE_FAILED.getCode(), result.getCode());
        assertEquals("custom error", result.getMessage());
    }

    // ===== MethodArgumentNotValidException =====

    @Test
    void testHandleMethodArgumentNotValidWithFieldError() {
        MethodArgumentNotValidException ex = mock(MethodArgumentNotValidException.class);
        BindingResult bindingResult = mock(BindingResult.class);
        FieldError fieldError = mock(FieldError.class);

        when(ex.getBindingResult()).thenReturn(bindingResult);
        when(bindingResult.getFieldError()).thenReturn(fieldError);
        when(fieldError.getDefaultMessage()).thenReturn("field cannot be empty");

        ApiResult<Void> result = handler.handleMethodArgumentNotValidException(ex);
        assertEquals(ResultCode.VALIDATE_FAILED.getCode(), result.getCode());
        assertEquals("field cannot be empty", result.getMessage());
    }

    @Test
    void testHandleMethodArgumentNotValidWithoutFieldError() {
        MethodArgumentNotValidException ex = mock(MethodArgumentNotValidException.class);
        BindingResult bindingResult = mock(BindingResult.class);

        when(ex.getBindingResult()).thenReturn(bindingResult);
        when(bindingResult.getFieldError()).thenReturn(null);

        ApiResult<Void> result = handler.handleMethodArgumentNotValidException(ex);
        assertEquals(ResultCode.VALIDATE_FAILED.getCode(), result.getCode());
        assertEquals(ResultCode.VALIDATE_FAILED.getMessage(), result.getMessage());
    }

    // ===== BindException =====

    @Test
    void testHandleBindExceptionWithFieldError() {
        BindException ex = mock(BindException.class);
        BindingResult bindingResult = mock(BindingResult.class);
        FieldError fieldError = mock(FieldError.class);

        when(ex.getBindingResult()).thenReturn(bindingResult);
        when(bindingResult.getFieldError()).thenReturn(fieldError);
        when(fieldError.getDefaultMessage()).thenReturn("bind error");

        ApiResult<Void> result = handler.handleBindException(ex);
        assertEquals(ResultCode.VALIDATE_FAILED.getCode(), result.getCode());
        assertEquals("bind error", result.getMessage());
    }

    @Test
    void testHandleBindExceptionWithoutFieldError() {
        BindException ex = mock(BindException.class);
        BindingResult bindingResult = mock(BindingResult.class);

        when(ex.getBindingResult()).thenReturn(bindingResult);
        when(bindingResult.getFieldError()).thenReturn(null);

        ApiResult<Void> result = handler.handleBindException(ex);
        assertEquals(ResultCode.VALIDATE_FAILED.getCode(), result.getCode());
        assertEquals(ResultCode.VALIDATE_FAILED.getMessage(), result.getMessage());
    }

    // ===== ConstraintViolationException =====

    @Test
    void testHandleConstraintViolationException() {
        Set<ConstraintViolation<?>> violations = Collections.emptySet();
        ConstraintViolationException ex = new ConstraintViolationException("constraint violated", violations);

        ApiResult<Void> result = handler.handleConstraintViolationException(ex);
        assertEquals(ResultCode.VALIDATE_FAILED.getCode(), result.getCode());
        assertEquals("constraint violated", result.getMessage());
    }

    // ===== DataIntegrityViolationException =====

    @Test
    void testHandleDataIntegrityViolationWithDuplicateEntry() {
        DataIntegrityViolationException ex =
                new DataIntegrityViolationException("Duplicate entry 'test' for key 'uk_name'");

        ApiResult<Void> result = handler.handleDataIntegrityViolationException(ex);
        assertEquals(ResultCode.VALIDATE_FAILED.getCode(), result.getCode());
        assertEquals("名称已存在，请使用其他名称", result.getMessage());
    }

    @Test
    void testHandleDataIntegrityViolationWithoutDuplicateEntry() {
        DataIntegrityViolationException ex =
                new DataIntegrityViolationException("Foreign key constraint fails");

        ApiResult<Void> result = handler.handleDataIntegrityViolationException(ex);
        assertEquals(ResultCode.VALIDATE_FAILED.getCode(), result.getCode());
        assertEquals("数据冲突，请检查输入", result.getMessage());
    }

    @Test
    void testHandleDataIntegrityViolationWithNullMessage() {
        DataIntegrityViolationException ex =
                new DataIntegrityViolationException((String) null);

        ApiResult<Void> result = handler.handleDataIntegrityViolationException(ex);
        assertEquals(ResultCode.VALIDATE_FAILED.getCode(), result.getCode());
        assertEquals("数据冲突，请检查输入", result.getMessage());
    }

    // ===== Exception =====

    @Test
    void testHandleGenericException() {
        Exception ex = new RuntimeException("unexpected error");

        ApiResult<Void> result = handler.handleException(ex);
        assertEquals(ResultCode.SYSTEM_ERROR.getCode(), result.getCode());
        assertEquals("unexpected error", result.getMessage());
    }

    @Test
    void testHandleGenericExceptionWithNullMessage() {
        Exception ex = new RuntimeException();

        ApiResult<Void> result = handler.handleException(ex);
        assertEquals(ResultCode.SYSTEM_ERROR.getCode(), result.getCode());
        assertNull(result.getMessage());
    }
}
