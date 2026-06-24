package com.finance.roboadvisor.product.service.impl;

import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.product.entity.AdvisorStrategyRule;
import com.finance.roboadvisor.product.mapper.StrategyRuleMapper;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class StrategyRuleValidationServiceImplTest {

    @Mock
    private StrategyRuleMapper strategyRuleMapper;

    @Test
    void validate_shouldRejectWhenComponentCountBelowMin() {
        AdvisorStrategyRule rule = new AdvisorStrategyRule();
        rule.setId(1L);
        rule.setStrategyCode("BALANCE_ALPHA");
        rule.setProductType("STRATEGY");
        rule.setMinFundCount(3);
        rule.setMaxFundCount(10);
        rule.setMinSingleWeight(new BigDecimal("0.0500"));
        rule.setMaxSingleWeight(new BigDecimal("0.6000"));
        rule.setStatus(1);

        when(strategyRuleMapper.selectEnabledByStrategyAndType("BALANCE_ALPHA", "STRATEGY")).thenReturn(rule);

        DraftComponentVO item = new DraftComponentVO();
        item.setFundCode("110022");
        item.setFundName("易方达消费行业股票");
        item.setWeight(new BigDecimal("1.0000"));

        StrategyRuleValidationServiceImpl service = new StrategyRuleValidationServiceImpl(strategyRuleMapper);

        assertThatThrownBy(() -> service.validateOrThrow("BALANCE_ALPHA", "STRATEGY", List.of(item), null))
                .isInstanceOf(BusinessException.class)
                .hasMessage("策略规则校验失败：成份数量不符合要求");
    }
}
