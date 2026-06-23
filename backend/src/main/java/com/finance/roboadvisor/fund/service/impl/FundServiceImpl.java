package com.finance.roboadvisor.fund.service.impl;

import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.fund.mapper.FundMapper;
import com.finance.roboadvisor.fund.service.FundService;
import com.finance.roboadvisor.fund.vo.FundOptionVO;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
public class FundServiceImpl implements FundService {

    private static final int DEFAULT_PAGE_NUM = 1;
    private static final int DEFAULT_PAGE_SIZE = 10;

    private final FundMapper fundMapper;

    public FundServiceImpl(FundMapper fundMapper) {
        this.fundMapper = fundMapper;
    }

    @Override
    public PageResult<FundOptionVO> searchFunds(String keyword, String fundType, Integer pageNum, Integer pageSize) {
        int safePageNum = pageNum == null || pageNum < 1 ? DEFAULT_PAGE_NUM : pageNum;
        int safePageSize = pageSize == null || pageSize < 1 ? DEFAULT_PAGE_SIZE : pageSize;
        int offset = (safePageNum - 1) * safePageSize;

        String normalizedKeyword = StringUtils.hasText(keyword) ? keyword.trim() : null;
        String normalizedFundType = StringUtils.hasText(fundType) ? fundType.trim() : null;

        List<FundOptionVO> records = fundMapper.selectEnabledFunds(normalizedKeyword, normalizedFundType, offset, safePageSize);
        Long total = fundMapper.countEnabledFunds(normalizedKeyword, normalizedFundType);
        return new PageResult<>(records, total, safePageNum, safePageSize);
    }
}
