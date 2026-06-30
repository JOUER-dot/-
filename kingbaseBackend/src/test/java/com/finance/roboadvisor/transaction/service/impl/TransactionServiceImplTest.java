package com.finance.roboadvisor.transaction.service.impl;

import com.finance.roboadvisor.auth.entity.SysUser;
import com.finance.roboadvisor.auth.security.LoginUser;
import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.transaction.entity.TransactionRecord;
import com.finance.roboadvisor.transaction.mapper.TransactionMapper;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class TransactionServiceImplTest {

    @Mock private TransactionMapper transactionMapper;

    @InjectMocks
    private TransactionServiceImpl transactionService;

    @BeforeEach
    void setUp() {
        SysUser user = new SysUser();
        user.setId(1L);
        user.setUsername("testuser");
        user.setStatus(1);
        LoginUser loginUser = new LoginUser(user, List.of("USER"));
        Authentication auth = new UsernamePasswordAuthenticationToken(loginUser, null, loginUser.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(auth);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void testRecord() {
        transactionService.record(1L, 100L, "测试产品", "SUBSCRIBE", new BigDecimal("10000"));

        verify(transactionMapper).insert(argThat(r ->
                r.getUserId() == 1L &&
                r.getProductId() == 100L &&
                "测试产品".equals(r.getProductName()) &&
                "SUBSCRIBE".equals(r.getType()) &&
                new BigDecimal("10000").compareTo(r.getAmount()) == 0 &&
                "COMPLETED".equals(r.getStatus())
        ));
    }

    @Test
    void testRecordWithZeroAmount() {
        transactionService.record(1L, 100L, "测试产品", "SUBSCRIBE", BigDecimal.ZERO);

        verify(transactionMapper).insert(argThat(r ->
                BigDecimal.ZERO.compareTo(r.getAmount()) == 0
        ));
    }

    @Test
    void testGetMyTransactions() {
        TransactionRecord record = new TransactionRecord();
        record.setId(1L);
        record.setUserId(1L);
        record.setProductId(100L);
        record.setType("SUBSCRIBE");
        record.setAmount(new BigDecimal("5000"));

        when(transactionMapper.selectByUserId(eq(1L), eq(0), eq(20))).thenReturn(List.of(record));
        when(transactionMapper.countByUserId(1L)).thenReturn(1L);

        PageResult<TransactionRecord> result = transactionService.getMyTransactions(1, 20);

        assertEquals(1, result.getRecords().size());
        assertEquals(1L, result.getTotal());
    }

    @Test
    void testGetMyTransactionsEmpty() {
        when(transactionMapper.selectByUserId(eq(1L), eq(0), eq(20))).thenReturn(List.of());
        when(transactionMapper.countByUserId(1L)).thenReturn(0L);

        PageResult<TransactionRecord> result = transactionService.getMyTransactions(1, 20);

        assertTrue(result.getRecords().isEmpty());
        assertEquals(0L, result.getTotal());
    }

    @Test
    void testGetMyTransactionsDefaultPagination() {
        when(transactionMapper.selectByUserId(eq(1L), eq(0), eq(20))).thenReturn(List.of());
        when(transactionMapper.countByUserId(1L)).thenReturn(0L);

        PageResult<TransactionRecord> result = transactionService.getMyTransactions(null, null);

        assertEquals(1, result.getPageNum());
        assertEquals(20, result.getPageSize());
    }
}
