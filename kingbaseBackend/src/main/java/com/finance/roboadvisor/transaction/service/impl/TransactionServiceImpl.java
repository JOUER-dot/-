package com.finance.roboadvisor.transaction.service.impl;

import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.common.util.SecurityUtil;
import com.finance.roboadvisor.transaction.entity.TransactionRecord;
import com.finance.roboadvisor.transaction.mapper.TransactionMapper;
import com.finance.roboadvisor.transaction.service.TransactionService;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
public class TransactionServiceImpl implements TransactionService {
    private static final int DEFAULT_PAGE_SIZE = 20;

    private final TransactionMapper transactionMapper;

    public TransactionServiceImpl(TransactionMapper transactionMapper) {
        this.transactionMapper = transactionMapper;
    }

    @Override
    public void record(Long userId, Long productId, String productName, String type, BigDecimal amount) {
        TransactionRecord r = new TransactionRecord();
        r.setUserId(userId);
        r.setProductId(productId);
        r.setProductName(productName);
        r.setType(type);
        r.setAmount(amount);
        r.setStatus("COMPLETED");
        transactionMapper.insert(r);
    }

    @Override
    public PageResult<TransactionRecord> getMyTransactions(Integer pageNum, Integer pageSize) {
        Long userId = SecurityUtil.getCurrentUserId();
        if (pageNum == null || pageNum < 1) pageNum = 1;
        if (pageSize == null || pageSize < 1) pageSize = DEFAULT_PAGE_SIZE;
        int offset = (pageNum - 1) * pageSize;
        List<TransactionRecord> records = transactionMapper.selectByUserId(userId, offset, pageSize);
        long total = transactionMapper.countByUserId(userId);
        return new PageResult<>(records, total, pageNum, pageSize);
    }
}
