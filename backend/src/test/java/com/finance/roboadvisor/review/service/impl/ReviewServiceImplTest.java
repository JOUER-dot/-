package com.finance.roboadvisor.review.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.auth.entity.SysUser;
import com.finance.roboadvisor.auth.security.LoginUser;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.entity.AdvisorProductFlowLog;
import com.finance.roboadvisor.product.entity.AdvisorProductRuleDecision;
import com.finance.roboadvisor.product.entity.AdvisorProductReview;
import com.finance.roboadvisor.product.entity.AdvisorStrategyRule;
import com.finance.roboadvisor.product.entity.AdvisorProductVersion;
import com.finance.roboadvisor.product.mapper.ProductComponentMapper;
import com.finance.roboadvisor.product.mapper.ProductFlowLogMapper;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.product.mapper.ProductRuleDecisionMapper;
import com.finance.roboadvisor.product.mapper.ProductReviewMapper;
import com.finance.roboadvisor.product.mapper.ProductVersionMapper;
import com.finance.roboadvisor.product.mapper.StrategyRuleMapper;
import com.finance.roboadvisor.product.service.ProductHoldingSnapshotGenerationService;
import com.finance.roboadvisor.product.service.ProductNavGenerationService;
import com.finance.roboadvisor.product.service.StrategyRuleValidationService;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import com.finance.roboadvisor.review.dto.ReviewApproveDTO;
import com.finance.roboadvisor.review.dto.ReviewRejectDTO;
import com.finance.roboadvisor.review.mapper.ReviewMapper;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

import java.math.BigDecimal;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ReviewServiceImplTest {

    @Mock
    private ReviewMapper reviewMapper;

    @Mock
    private ProductMapper productMapper;

    @Mock
    private ProductVersionMapper productVersionMapper;

    @Mock
    private ProductComponentMapper productComponentMapper;

    @Mock
    private ProductReviewMapper productReviewMapper;

    @Mock
    private ProductFlowLogMapper productFlowLogMapper;

    @Mock
    private StrategyRuleMapper strategyRuleMapper;

    @Mock
    private ProductRuleDecisionMapper productRuleDecisionMapper;

    @Mock
    private StrategyRuleValidationService strategyRuleValidationService;

    @Mock
    private ProductNavGenerationService productNavGenerationService;

    @Mock
    private ProductHoldingSnapshotGenerationService productHoldingSnapshotGenerationService;

    private ReviewServiceImpl reviewService;

    @BeforeEach
    void setUp() {
        reviewService = new ReviewServiceImpl(
                reviewMapper,
                productMapper,
                productVersionMapper,
                productComponentMapper,
                productReviewMapper,
                productFlowLogMapper,
                strategyRuleMapper,
                productRuleDecisionMapper,
                strategyRuleValidationService,
                productNavGenerationService,
                productHoldingSnapshotGenerationService,
                new ObjectMapper()
        );

        SysUser reviewer = new SysUser();
        reviewer.setId(3L);
        reviewer.setUsername("reviewer01");
        reviewer.setPasswordHash("test");
        reviewer.setStatus(1);
        LoginUser loginUser = new LoginUser(reviewer, List.of("REVIEWER"));
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(loginUser, null, loginUser.getAuthorities())
        );
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void approveProduct_shouldPublishProductAndWriteReviewRecords() {
        AdvisorProduct product = new AdvisorProduct();
        product.setId(1L);
        product.setStatus("PENDING_REVIEW");
        product.setType("STRATEGY");
        product.setStrategyCode("BALANCE_ALPHA");
        product.setCurrentVersionNo(2);

        AdvisorProductVersion version = new AdvisorProductVersion();
        version.setId(11L);
        version.setProductId(1L);
        version.setVersionNo(2);
        version.setVersionStatus("SUBMITTED");

        DraftComponentVO component = new DraftComponentVO();
        component.setFundId(101L);
        component.setFundCode("110022");
        component.setFundName("易方达消费行业股票");
        component.setWeight(new BigDecimal("0.6000"));

        AdvisorStrategyRule rule = new AdvisorStrategyRule();
        rule.setId(9L);
        rule.setStrategyCode("BALANCE_ALPHA");
        rule.setProductType("STRATEGY");
        rule.setMinFundCount(1);
        rule.setMaxFundCount(10);
        rule.setMinSingleWeight(new BigDecimal("0.0500"));
        rule.setMaxSingleWeight(new BigDecimal("0.5000"));

        ReviewApproveDTO dto = new ReviewApproveDTO();
        dto.setOverrideMaxSingleWeight(new BigDecimal("0.7000"));
        dto.setDecisionComment("允许本次超过默认单基金权重上限");

        when(productMapper.selectById(1L)).thenReturn(product);
        when(productVersionMapper.selectLatestSubmittedByProductId(1L)).thenReturn(version);
        when(productComponentMapper.selectByVersionId(11L)).thenReturn(List.of(component));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("BALANCE_ALPHA", "STRATEGY")).thenReturn(rule);

        reviewService.approveProduct(1L, dto);

        verify(productMapper).updateApprovedReviewOutcome(1L, "PUBLISHED", 2);
        verify(productVersionMapper).updateVersionStatus(11L, "APPROVED");
        ArgumentCaptor<AdvisorProductRuleDecision> decisionCaptor = ArgumentCaptor.forClass(AdvisorProductRuleDecision.class);
        verify(productRuleDecisionMapper).insert(decisionCaptor.capture());
        assertThat(decisionCaptor.getValue().getProductId()).isEqualTo(1L);
        assertThat(decisionCaptor.getValue().getProductVersionId()).isEqualTo(11L);
        assertThat(decisionCaptor.getValue().getBaseRuleId()).isEqualTo(9L);
        assertThat(decisionCaptor.getValue().getReviewerId()).isEqualTo(3L);
        assertThat(decisionCaptor.getValue().getOverrideMaxSingleWeight()).isEqualByComparingTo("0.7000");
        assertThat(decisionCaptor.getValue().getDecisionComment()).isEqualTo("允许本次超过默认单基金权重上限");
        assertThat(decisionCaptor.getValue().getFinalRuleJson()).contains("\"ruleId\":9");
        assertThat(decisionCaptor.getValue().getFinalRuleJson()).contains("\"maxSingleWeight\":0.7000");

        verify(productReviewMapper).insert(any(AdvisorProductReview.class));
        verify(productFlowLogMapper).insert(any(AdvisorProductFlowLog.class));
        verify(productNavGenerationService).generatePublishedProductNav(1L);
        verify(productHoldingSnapshotGenerationService).generatePublishedHoldingSnapshot(1L);
    }

    @Test
    void rejectProduct_shouldMarkRejectedAndPersistRejectComment() {
        AdvisorProduct product = new AdvisorProduct();
        product.setId(2L);
        product.setStatus("PENDING_REVIEW");
        product.setCurrentVersionNo(3);

        AdvisorProductVersion version = new AdvisorProductVersion();
        version.setId(21L);
        version.setProductId(2L);
        version.setVersionNo(3);
        version.setVersionStatus("SUBMITTED");

        ReviewRejectDTO dto = new ReviewRejectDTO();
        dto.setComment("单一行业集中度过高，请调整权重");

        when(productMapper.selectById(2L)).thenReturn(product);
        when(productVersionMapper.selectLatestSubmittedByProductId(2L)).thenReturn(version);

        reviewService.rejectProduct(2L, dto);

        verify(productMapper).updateRejectedReviewOutcome(2L, "REJECTED", "单一行业集中度过高，请调整权重");
        verify(productVersionMapper).updateVersionStatus(21L, "REJECTED");

        verify(productReviewMapper).insert(any(AdvisorProductReview.class));
        verify(productFlowLogMapper).insert(any(AdvisorProductFlowLog.class));
    }
}
