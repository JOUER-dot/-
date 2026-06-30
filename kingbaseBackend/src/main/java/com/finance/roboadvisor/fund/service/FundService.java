package com.finance.roboadvisor.fund.service;

import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.fund.vo.FundOptionVO;

public interface FundService {

    PageResult<FundOptionVO> searchFunds(String keyword, String fundType, Integer pageNum, Integer pageSize);
}
