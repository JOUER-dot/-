package com.finance.roboadvisor.product.service.impl;

import com.finance.roboadvisor.common.api.ResultCode;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.product.entity.AdvisorStrategyRule;
import com.finance.roboadvisor.product.mapper.StrategyRuleMapper;
import com.finance.roboadvisor.product.service.StrategyRuleValidationService;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
public class StrategyRuleValidationServiceImpl implements StrategyRuleValidationService {

    private final StrategyRuleMapper strategyRuleMapper;

    public StrategyRuleValidationServiceImpl(StrategyRuleMapper strategyRuleMapper) {
        this.strategyRuleMapper = strategyRuleMapper;
    }

    @Override
    public void validateOrThrow(String strategyCode,
                                String productType,
                                List<DraftComponentVO> components,
                                StrategyRuleOverride override) {
        AdvisorStrategyRule rule = strategyRuleMapper.selectEnabledByStrategyAndType(strategyCode, productType);
        if (rule == null) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "未配置策略规则，不能提交审核");
        }

        int componentCount = components == null ? 0 : components.size();
        Integer minFundCount = override != null && override.getOverrideMinFundCount() != null
                ? override.getOverrideMinFundCount()
                : rule.getMinFundCount();
        Integer maxFundCount = override != null && override.getOverrideMaxFundCount() != null
                ? override.getOverrideMaxFundCount()
                : rule.getMaxFundCount();

        if (minFundCount != null && componentCount < minFundCount) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "策略规则校验失败：成份数量不符合要求");
        }
        if (maxFundCount != null && componentCount > maxFundCount) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "策略规则校验失败：成份数量不符合要求");
        }

        BigDecimal minSingleWeight = rule.getMinSingleWeight();
        BigDecimal maxSingleWeight = override != null && override.getOverrideMaxSingleWeight() != null
                ? override.getOverrideMaxSingleWeight()
                : rule.getMaxSingleWeight();

        if (components == null || components.isEmpty()) {
            return;
        }

        for (DraftComponentVO component : components) {
            BigDecimal weight = component.getWeight();
            if (weight == null) {
                throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "策略规则校验失败：单基金权重超出限制");
            }
            if (minSingleWeight != null && weight.compareTo(minSingleWeight) < 0) {
                throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "策略规则校验失败：单基金权重超出限制");
            }
            if (maxSingleWeight != null && weight.compareTo(maxSingleWeight) > 0) {
                throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "策略规则校验失败：单基金权重超出限制");
            }
        }
    }
}
