package com.finance.roboadvisor.fund.controller;

import com.finance.roboadvisor.common.api.ApiResult;
import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.fund.service.FundService;
import com.finance.roboadvisor.fund.vo.FundOptionVO;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/funds")
public class FundController {

    private final FundService fundService;

    public FundController(FundService fundService) {
        this.fundService = fundService;
    }

    @GetMapping
    public ApiResult<PageResult<FundOptionVO>> searchFunds(@RequestParam(required = false) String keyword,
                                                           @RequestParam(required = false) String fundType,
                                                           @RequestParam(required = false) Integer pageNum,
                                                           @RequestParam(required = false) Integer pageSize) {
        return ApiResult.success(fundService.searchFunds(keyword, fundType, pageNum, pageSize));
    }
}
