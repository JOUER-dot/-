package com.finance.roboadvisor.product.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.auth.entity.SysUser;
import com.finance.roboadvisor.auth.security.LoginUser;
import com.finance.roboadvisor.common.api.ResultCode;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.fund.mapper.FundMapper;
import com.finance.roboadvisor.fund.vo.FundOptionVO;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.entity.AdvisorProductDraft;
import com.finance.roboadvisor.product.mapper.ProductComponentMapper;
import com.finance.roboadvisor.product.mapper.ProductDraftComponentMapper;
import com.finance.roboadvisor.product.mapper.ProductDraftMapper;
import com.finance.roboadvisor.product.mapper.ProductFlowLogMapper;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.product.mapper.ProductReviewMapper;
import com.finance.roboadvisor.product.mapper.ProductVersionMapper;
import com.finance.roboadvisor.product.service.ProductHoldingSnapshotGenerationService;
import com.finance.roboadvisor.product.service.ProductNavGenerationService;
import com.finance.roboadvisor.product.service.StrategyRuleValidationService;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

import java.math.BigDecimal;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ProductServiceImplTest {

    @Mock
    private ProductMapper productMapper;

    @Mock
    private ProductDraftMapper productDraftMapper;

    @Mock
    private ProductDraftComponentMapper productDraftComponentMapper;

    @Mock
    private ProductVersionMapper productVersionMapper;

    @Mock
    private ProductComponentMapper productComponentMapper;

    @Mock
    private ProductReviewMapper productReviewMapper;

    @Mock
    private ProductFlowLogMapper productFlowLogMapper;

    @Mock
    private FundMapper fundMapper;

    @Mock
    private ProductNavGenerationService productNavGenerationService;

    @Mock
    private ProductHoldingSnapshotGenerationService productHoldingSnapshotGenerationService;

    @Mock
    private StrategyRuleValidationService strategyRuleValidationService;

    private ProductServiceImpl productService;

    @BeforeEach
    void setUp() {
        productService = new ProductServiceImpl(
                productMapper,
                productDraftMapper,
                productDraftComponentMapper,
                productVersionMapper,
                productComponentMapper,
                productReviewMapper,
                productFlowLogMapper,
                fundMapper,
                productNavGenerationService,
                productHoldingSnapshotGenerationService,
                strategyRuleValidationService,
                new ObjectMapper()
        );

        SysUser advisor = new SysUser();
        advisor.setId(2L);
        advisor.setUsername("advisor01");
        advisor.setPasswordHash("test");
        advisor.setStatus(1);
        LoginUser loginUser = new LoginUser(advisor, List.of("ADVISOR"));
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(loginUser, null, loginUser.getAuthorities())
        );
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void generateProductNav_shouldDelegateWhenAdvisorOwnsPublishedProduct() {
        AdvisorProduct product = new AdvisorProduct();
        product.setId(1L);
        product.setCreatorId(2L);
        product.setStatus("PUBLISHED");
        product.setPublishedVersionNo(3);
        when(productMapper.selectById(1L)).thenReturn(product);

        productService.generateProductNav(1L);

        verify(productNavGenerationService).generatePublishedProductNav(1L);
        verify(productHoldingSnapshotGenerationService).generatePublishedHoldingSnapshot(1L);
    }

    @Test
    void offlineProduct_shouldDelegateWhenAdvisorOwnsPublishedProduct() {
        AdvisorProduct product = new AdvisorProduct();
        product.setId(1L);
        product.setCreatorId(2L);
        product.setStatus("PUBLISHED");
        when(productMapper.selectById(1L)).thenReturn(product);

        productService.offlineProduct(1L);

        verify(productMapper).updateStatus(1L, "OFFLINE");
    }

    @Test
    void offlineProduct_shouldRejectWhenProductIsNotPublished() {
        AdvisorProduct product = new AdvisorProduct();
        product.setId(1L);
        product.setCreatorId(2L);
        product.setStatus("DRAFT");
        when(productMapper.selectById(1L)).thenReturn(product);

        assertThatThrownBy(() -> productService.offlineProduct(1L))
                .isInstanceOf(BusinessException.class)
                .hasMessage("当前产品不处于可下架状态");
    }

    @Test
    void generateProductNav_shouldRejectWhenProductIsNotPublished() {
        AdvisorProduct product = new AdvisorProduct();
        product.setId(1L);
        product.setCreatorId(2L);
        product.setStatus("DRAFT");
        product.setPublishedVersionNo(null);
        when(productMapper.selectById(1L)).thenReturn(product);

        assertThatThrownBy(() -> productService.generateProductNav(1L))
                .isInstanceOf(BusinessException.class)
                .hasMessage("当前产品还没有可重算的已发布版本");
    }

    @Test
    void submitProduct_shouldThrowOriginalMessageWhenStrategyRuleValidationFails() {
        AdvisorProduct product = new AdvisorProduct();
        product.setId(1L);
        product.setCreatorId(2L);
        product.setStatus("DRAFT");
        product.setName("稳健组合");
        product.setType("STRATEGY");
        product.setRiskLevel("MEDIUM");
        product.setStrategyCode("BALANCE_ALPHA");
        when(productMapper.selectById(1L)).thenReturn(product);

        AdvisorProductDraft draft = new AdvisorProductDraft();
        draft.setId(10L);
        draft.setProductId(1L);
        draft.setBaseInfoJson("{\"investmentHorizon\":\"LONG\"}");
        draft.setParamsJson("{}");
        when(productDraftMapper.selectByProductId(1L)).thenReturn(draft);

        DraftComponentVO component = new DraftComponentVO();
        component.setFundId(100L);
        component.setFundCode("110022");
        component.setFundName("易方达消费行业股票");
        component.setWeight(new BigDecimal("1.0000"));
        when(productDraftComponentMapper.selectByDraftId(10L)).thenReturn(List.of(component));

        FundOptionVO fund = new FundOptionVO();
        fund.setId(100L);
        fund.setFundCode("110022");
        fund.setFundName("易方达消费行业股票");
        when(fundMapper.selectEnabledFundsByIds(List.of(100L))).thenReturn(List.of(fund));

        doThrow(new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "策略规则校验失败：单基金权重超出限制"))
                .when(strategyRuleValidationService)
                .validateOrThrow(eq("BALANCE_ALPHA"), eq("STRATEGY"), anyList(), isNull());

        assertThatThrownBy(() -> productService.submitProduct(1L))
                .isInstanceOf(BusinessException.class)
                .hasMessage("策略规则校验失败：单基金权重超出限制");
    }
}
