package com.finance.roboadvisor.product.service.impl;

import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.product.entity.AdvisorStrategyRule;
import com.finance.roboadvisor.product.mapper.StrategyRuleMapper;
import com.finance.roboadvisor.product.service.StrategyRuleValidationService;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class StrategyRuleValidationServiceImplTest {

    @Mock private StrategyRuleMapper strategyRuleMapper;

    @InjectMocks
    private StrategyRuleValidationServiceImpl validationService;

    private AdvisorStrategyRule createRule(Integer minCount, Integer maxCount,
                                           BigDecimal minWeight, BigDecimal maxWeight) {
        AdvisorStrategyRule rule = new AdvisorStrategyRule();
        rule.setId(1L);
        rule.setStrategyCode("SC_001");
        rule.setProductType("STRATEGY");
        rule.setMinFundCount(minCount);
        rule.setMaxFundCount(maxCount);
        rule.setMinSingleWeight(minWeight);
        rule.setMaxSingleWeight(maxWeight);
        rule.setAllowFundTypes("EQUITY,BOND");
        rule.setRiskRuleMode("NORMAL");
        return rule;
    }

    private DraftComponentVO createComponent(Long fundId, String code, String name, BigDecimal weight) {
        DraftComponentVO c = new DraftComponentVO();
        c.setFundId(fundId);
        c.setFundCode(code);
        c.setFundName(name);
        c.setWeight(weight);
        return c;
    }

    @Test
    void testValidateNoRuleFound() {
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_NONE", "STRATEGY")).thenReturn(null);

        assertDoesNotThrow(() ->
                validationService.validateOrThrow("SC_NONE", "STRATEGY", List.of(), null));
    }

    @Test
    void testValidateSuccess() {
        AdvisorStrategyRule rule = createRule(2, 10, new BigDecimal("0.05"), new BigDecimal("0.6"));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        List<DraftComponentVO> components = List.of(
                createComponent(1L, "000001", "基金A", new BigDecimal("0.6")),
                createComponent(2L, "000002", "基金B", new BigDecimal("0.4"))
        );

        assertDoesNotThrow(() ->
                validationService.validateOrThrow("SC_001", "STRATEGY", components, null));
    }

    @Test
    void testValidateMinCountFail() {
        AdvisorStrategyRule rule = createRule(3, 10, new BigDecimal("0.05"), new BigDecimal("0.6"));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        List<DraftComponentVO> components = List.of(
                createComponent(1L, "000001", "基金A", new BigDecimal("0.6"))
        );

        assertThrows(BusinessException.class, () ->
                validationService.validateOrThrow("SC_001", "STRATEGY", components, null));
    }

    @Test
    void testValidateMaxCountFail() {
        AdvisorStrategyRule rule = createRule(1, 2, new BigDecimal("0.05"), new BigDecimal("0.6"));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        List<DraftComponentVO> components = List.of(
                createComponent(1L, "000001", "基金A", new BigDecimal("0.3")),
                createComponent(2L, "000002", "基金B", new BigDecimal("0.3")),
                createComponent(3L, "000003", "基金C", new BigDecimal("0.4"))
        );

        assertThrows(BusinessException.class, () ->
                validationService.validateOrThrow("SC_001", "STRATEGY", components, null));
    }

    @Test
    void testValidateMinWeightFail() {
        AdvisorStrategyRule rule = createRule(1, 10, new BigDecimal("0.10"), new BigDecimal("0.9"));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        List<DraftComponentVO> components = List.of(
                createComponent(1L, "000001", "基金A", new BigDecimal("0.05"))
        );

        assertThrows(BusinessException.class, () ->
                validationService.validateOrThrow("SC_001", "STRATEGY", components, null));
    }

    @Test
    void testValidateMaxWeightFail() {
        AdvisorStrategyRule rule = createRule(1, 10, new BigDecimal("0.05"), new BigDecimal("0.5"));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        List<DraftComponentVO> components = List.of(
                createComponent(1L, "000001", "基金A", new BigDecimal("0.6"))
        );

        assertThrows(BusinessException.class, () ->
                validationService.validateOrThrow("SC_001", "STRATEGY", components, null));
    }

    @Test
    void testValidateWithOverride() {
        AdvisorStrategyRule rule = createRule(2, 10, new BigDecimal("0.05"), new BigDecimal("0.5"));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        StrategyRuleValidationService.StrategyRuleOverride override =
                new StrategyRuleValidationService.StrategyRuleOverride();
        override.setOverrideMaxSingleWeight(new BigDecimal("0.8"));
        override.setOverrideMinFundCount(1);

        List<DraftComponentVO> components = List.of(
                createComponent(1L, "000001", "基金A", new BigDecimal("0.8"))
        );

        assertDoesNotThrow(() ->
                validationService.validateOrThrow("SC_001", "STRATEGY", components, override));
    }

    @Test
    void testValidateNullWeight() {
        AdvisorStrategyRule rule = createRule(1, 10, new BigDecimal("0.05"), new BigDecimal("0.6"));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        List<DraftComponentVO> components = List.of(
                createComponent(1L, "000001", "基金A", null)
        );

        assertThrows(BusinessException.class, () ->
                validationService.validateOrThrow("SC_001", "STRATEGY", components, null));
    }

    @Test
    void testValidateEmptyComponents() {
        AdvisorStrategyRule rule = createRule(1, 10, new BigDecimal("0.05"), new BigDecimal("0.6"));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        assertThrows(BusinessException.class, () ->
                validationService.validateOrThrow("SC_001", "STRATEGY", List.of(), null));
    }

    @Test
    void testValidateNullComponents() {
        AdvisorStrategyRule rule = createRule(null, null, null, new BigDecimal("0.6"));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        assertDoesNotThrow(() ->
                validationService.validateOrThrow("SC_001", "STRATEGY", null, null));
    }

    @Test
    void testValidateEmptyComponentsWithNullMinAndMaxCount() {
        AdvisorStrategyRule rule = createRule(null, null, new BigDecimal("0.05"), new BigDecimal("0.6"));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        assertDoesNotThrow(() ->
                validationService.validateOrThrow("SC_001", "STRATEGY", List.of(), null));
    }

    @Test
    void testValidateWithOverrideMaxFundCount() {
        AdvisorStrategyRule rule = createRule(1, 5, new BigDecimal("0.05"), new BigDecimal("0.6"));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        StrategyRuleValidationService.StrategyRuleOverride override =
                new StrategyRuleValidationService.StrategyRuleOverride();
        override.setOverrideMaxFundCount(2);

        List<DraftComponentVO> components = List.of(
                createComponent(1L, "000001", "基金A", new BigDecimal("0.6")),
                createComponent(2L, "000002", "基金B", new BigDecimal("0.4"))
        );

        assertDoesNotThrow(() ->
                validationService.validateOrThrow("SC_001", "STRATEGY", components, override));
    }

    @Test
    void testValidateWithOverrideMaxFundCountExceeded() {
        AdvisorStrategyRule rule = createRule(1, 10, new BigDecimal("0.05"), new BigDecimal("0.6"));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        StrategyRuleValidationService.StrategyRuleOverride override =
                new StrategyRuleValidationService.StrategyRuleOverride();
        override.setOverrideMaxFundCount(2);

        List<DraftComponentVO> components = List.of(
                createComponent(1L, "000001", "基金A", new BigDecimal("0.4")),
                createComponent(2L, "000002", "基金B", new BigDecimal("0.3")),
                createComponent(3L, "000003", "基金C", new BigDecimal("0.3"))
        );

        assertThrows(BusinessException.class, () ->
                validationService.validateOrThrow("SC_001", "STRATEGY", components, override));
    }

    @Test
    void testValidateWithAllOverrides() {
        AdvisorStrategyRule rule = createRule(3, 10, new BigDecimal("0.10"), new BigDecimal("0.5"));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        StrategyRuleValidationService.StrategyRuleOverride override =
                new StrategyRuleValidationService.StrategyRuleOverride();
        override.setOverrideMinFundCount(1);
        override.setOverrideMaxFundCount(5);
        override.setOverrideMaxSingleWeight(new BigDecimal("0.8"));

        List<DraftComponentVO> components = List.of(
                createComponent(1L, "000001", "基金A", new BigDecimal("0.8"))
        );

        assertDoesNotThrow(() ->
                validationService.validateOrThrow("SC_001", "STRATEGY", components, override));
    }

    @Test
    void testValidateRuleWithNullMinSingleWeight() {
        AdvisorStrategyRule rule = createRule(1, 10, null, new BigDecimal("0.6"));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        List<DraftComponentVO> components = List.of(
                createComponent(1L, "000001", "基金A", new BigDecimal("0.01"))
        );

        assertDoesNotThrow(() ->
                validationService.validateOrThrow("SC_001", "STRATEGY", components, null));
    }

    @Test
    void testValidateRuleWithNullMaxSingleWeight() {
        AdvisorStrategyRule rule = createRule(1, 10, new BigDecimal("0.05"), null);
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        List<DraftComponentVO> components = List.of(
                createComponent(1L, "000001", "基金A", new BigDecimal("0.99"))
        );

        assertDoesNotThrow(() ->
                validationService.validateOrThrow("SC_001", "STRATEGY", components, null));
    }

    @Test
    void testValidateWithOverrideMinFundCountExceeded() {
        AdvisorStrategyRule rule = createRule(1, 10, new BigDecimal("0.05"), new BigDecimal("0.6"));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        StrategyRuleValidationService.StrategyRuleOverride override =
                new StrategyRuleValidationService.StrategyRuleOverride();
        override.setOverrideMinFundCount(3);

        List<DraftComponentVO> components = List.of(
                createComponent(1L, "000001", "基金A", new BigDecimal("0.6")),
                createComponent(2L, "000002", "基金B", new BigDecimal("0.4"))
        );

        assertThrows(BusinessException.class, () ->
                validationService.validateOrThrow("SC_001", "STRATEGY", components, override));
    }

    @Test
    void testValidateMultipleComponentsAllValid() {
        AdvisorStrategyRule rule = createRule(2, 5, new BigDecimal("0.10"), new BigDecimal("0.6"));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("SC_001", "STRATEGY")).thenReturn(rule);

        List<DraftComponentVO> components = List.of(
                createComponent(1L, "000001", "基金A", new BigDecimal("0.3")),
                createComponent(2L, "000002", "基金B", new BigDecimal("0.3")),
                createComponent(3L, "000003", "基金C", new BigDecimal("0.4"))
        );

        assertDoesNotThrow(() ->
                validationService.validateOrThrow("SC_001", "STRATEGY", components, null));
    }
}
