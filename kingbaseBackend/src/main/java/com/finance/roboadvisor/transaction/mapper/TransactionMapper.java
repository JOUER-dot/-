package com.finance.roboadvisor.transaction.mapper;

import com.finance.roboadvisor.transaction.entity.TransactionRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface TransactionMapper {
    int insert(TransactionRecord record);
    List<TransactionRecord> selectByUserId(@Param("userId") Long userId,
                                           @Param("offset") Integer offset,
                                           @Param("pageSize") Integer pageSize);
    long countByUserId(@Param("userId") Long userId);
}
