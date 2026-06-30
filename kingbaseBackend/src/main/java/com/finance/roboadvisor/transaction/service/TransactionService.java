package com.finance.roboadvisor.transaction.service;

import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.transaction.entity.TransactionRecord;

public interface TransactionService {
    void record(Long userId, Long productId, String productName, String type, java.math.BigDecimal amount);
    PageResult<TransactionRecord> getMyTransactions(Integer pageNum, Integer pageSize);
}
