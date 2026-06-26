package com.finance.roboadvisor.product.controller;

import com.finance.roboadvisor.common.api.ApiResult;
import com.finance.roboadvisor.product.vo.StrategyRuleOptionVO;
import com.finance.roboadvisor.product.mapper.StrategyRuleMapper;
import com.finance.roboadvisor.product.entity.AdvisorStrategyRule;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/strategy-rules")
public class StrategyRuleController {

    private final StrategyRuleMapper strategyRuleMapper;

    public StrategyRuleController(StrategyRuleMapper strategyRuleMapper) {
        this.strategyRuleMapper = strategyRuleMapper;
    }

    @GetMapping
    public ApiResult<List<StrategyRuleOptionVO>> listStrategyRules() {
        List<AdvisorStrategyRule> rules = strategyRuleMapper.selectAllEnabled();
        List<StrategyRuleOptionVO> options = rules.stream().map(r -> {
            StrategyRuleOptionVO vo = new StrategyRuleOptionVO();
            vo.setStrategyCode(r.getStrategyCode());
            vo.setProductType(r.getProductType());
            vo.setLabel(r.getStrategyCode() + " (" + r.getProductType() + ")");
            return vo;
        }).toList();
        return ApiResult.success(options);
    }
}
