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
import com.finance.roboadvisor.subscription.service.SubscriptionService;
import com.finance.roboadvisor.review.vo.ReviewDetailVO;
import com.finance.roboadvisor.review.vo.ReviewDiffComponentVO;
import com.finance.roboadvisor.review.vo.ReviewDiffFieldVO;
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
import java.time.LocalDateTime;
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

    @Mock
    private SubscriptionService subscriptionService;

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
                subscriptionService,
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

    @Test
    void approveProduct_shouldCreateConfirmRequiredActionsForMajorChange() {
        AdvisorProduct product = new AdvisorProduct();
        product.setId(12L);
        product.setStatus("PENDING_REVIEW");
        product.setType("STRATEGY");
        product.setStrategyCode("BALANCE_ALPHA");
        product.setCurrentVersionNo(4);

        AdvisorProductVersion version = new AdvisorProductVersion();
        version.setId(31L);
        version.setProductId(12L);
        version.setVersionNo(4);
        version.setVersionStatus("SUBMITTED");
        version.setChangeType("MAJOR");
        version.setVersionNote("调仓并提升风险等级");

        DraftComponentVO component = new DraftComponentVO();
        component.setFundId(201L);
        component.setFundCode("110023");
        component.setFundName("中欧医疗健康混合");
        component.setWeight(new BigDecimal("0.4000"));

        AdvisorStrategyRule rule = new AdvisorStrategyRule();
        rule.setId(19L);
        rule.setStrategyCode("BALANCE_ALPHA");
        rule.setProductType("STRATEGY");
        rule.setMinFundCount(1);
        rule.setMaxFundCount(10);
        rule.setMinSingleWeight(new BigDecimal("0.0500"));
        rule.setMaxSingleWeight(new BigDecimal("0.6000"));

        when(productMapper.selectById(12L)).thenReturn(product);
        when(productVersionMapper.selectLatestSubmittedByProductId(12L)).thenReturn(version);
        when(productComponentMapper.selectByVersionId(31L)).thenReturn(List.of(component));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("BALANCE_ALPHA", "STRATEGY")).thenReturn(rule);

        reviewService.approveProduct(12L, new ReviewApproveDTO());

        verify(subscriptionService).createVersionActions(
                12L,
                31L,
                "MAJOR",
                "CONFIRM_REQUIRED",
                "PENDING",
                "调仓并提升风险等级"
        );
    }

    @Test
    void approveProduct_shouldCreateNoticeActionsForNormalChange() {
        AdvisorProduct product = new AdvisorProduct();
        product.setId(13L);
        product.setStatus("PENDING_REVIEW");
        product.setType("STRATEGY");
        product.setStrategyCode("BALANCE_ALPHA");
        product.setCurrentVersionNo(5);

        AdvisorProductVersion version = new AdvisorProductVersion();
        version.setId(41L);
        version.setProductId(13L);
        version.setVersionNo(5);
        version.setVersionStatus("SUBMITTED");
        version.setChangeType("NORMAL");
        version.setVersionNote("优化文案描述");

        DraftComponentVO component = new DraftComponentVO();
        component.setFundId(202L);
        component.setFundCode("110024");
        component.setFundName("富国天惠成长混合");
        component.setWeight(new BigDecimal("0.3500"));

        AdvisorStrategyRule rule = new AdvisorStrategyRule();
        rule.setId(20L);
        rule.setStrategyCode("BALANCE_ALPHA");
        rule.setProductType("STRATEGY");
        rule.setMinFundCount(1);
        rule.setMaxFundCount(10);
        rule.setMinSingleWeight(new BigDecimal("0.0500"));
        rule.setMaxSingleWeight(new BigDecimal("0.6000"));

        when(productMapper.selectById(13L)).thenReturn(product);
        when(productVersionMapper.selectLatestSubmittedByProductId(13L)).thenReturn(version);
        when(productComponentMapper.selectByVersionId(41L)).thenReturn(List.of(component));
        when(strategyRuleMapper.selectEnabledByStrategyAndType("BALANCE_ALPHA", "STRATEGY")).thenReturn(rule);

        reviewService.approveProduct(13L, new ReviewApproveDTO());

        verify(subscriptionService).createVersionActions(
                13L,
                41L,
                "NORMAL",
                "NOTICE",
                "NOTIFIED",
                "优化文案描述"
        );
    }

    @Test
    void getPendingProductDetailShouldReturnFieldAndComponentDiffs() {
        ReviewDetailVO pendingDetail = new ReviewDetailVO();
        pendingDetail.setId(9L);
        pendingDetail.setName("进取成长组合C升级版");
        pendingDetail.setType("STRATEGY");
        pendingDetail.setRiskLevel("R4");
        pendingDetail.setVersionId(19L);
        pendingDetail.setVersionNo(3);
        pendingDetail.setVersionStatus("SUBMITTED");
        pendingDetail.setSubmittedAt(LocalDateTime.of(2026, 6, 26, 10, 0));
        pendingDetail.setFeatureTagsText("进取,成长");
        pendingDetail.setBaseInfoJson("""
                {"name":"进取成长组合C升级版","type":"STRATEGY","riskLevel":"R4","productSummary":"升级后的成长策略","targetCustomer":"进取型投资者","riskTips":"净值波动较大"}
                """);
        pendingDetail.setParamsJson("""
                {"rebalanceCycleDays":14,"minSingleFundWeight":0.10,"maxSingleFundWeight":0.55,"investHorizonMonths":18,"strategyNotes":"成长风格更聚焦"}
                """);

        AdvisorProductVersion currentVersion = new AdvisorProductVersion();
        currentVersion.setId(19L);
        currentVersion.setProductId(9L);
        currentVersion.setVersionNo(3);
        currentVersion.setVersionStatus("SUBMITTED");
        currentVersion.setBaseVersionId(11L);
        currentVersion.setChangeType("MAJOR");
        currentVersion.setVersionNote("调仓并提升风险等级");
        currentVersion.setSubmittedAt(LocalDateTime.of(2026, 6, 26, 10, 0));

        AdvisorProductVersion baseVersion = new AdvisorProductVersion();
        baseVersion.setId(11L);
        baseVersion.setProductId(9L);
        baseVersion.setVersionNo(2);
        baseVersion.setVersionStatus("APPROVED");
        baseVersion.setSubmittedAt(LocalDateTime.of(2026, 6, 20, 9, 0));
        baseVersion.setBaseInfoJson("""
                {"name":"进取成长组合C","type":"STRATEGY","riskLevel":"R3","productSummary":"成长策略","targetCustomer":"成长型投资者","riskTips":"净值存在波动"}
                """);
        baseVersion.setParamsJson("""
                {"rebalanceCycleDays":30,"minSingleFundWeight":0.10,"maxSingleFundWeight":0.40,"investHorizonMonths":12,"strategyNotes":"均衡成长"}
                """);

        DraftComponentVO removedComponent = new DraftComponentVO();
        removedComponent.setFundId(101L);
        removedComponent.setFundCode("000001");
        removedComponent.setFundName("沪深300ETF");
        removedComponent.setWeight(new BigDecimal("0.40"));

        DraftComponentVO updatedBaseComponent = new DraftComponentVO();
        updatedBaseComponent.setFundId(102L);
        updatedBaseComponent.setFundCode("000002");
        updatedBaseComponent.setFundName("纳指ETF");
        updatedBaseComponent.setWeight(new BigDecimal("0.30"));

        DraftComponentVO updatedCurrentComponent = new DraftComponentVO();
        updatedCurrentComponent.setFundId(102L);
        updatedCurrentComponent.setFundCode("000002");
        updatedCurrentComponent.setFundName("纳指ETF");
        updatedCurrentComponent.setWeight(new BigDecimal("0.45"));

        DraftComponentVO addedComponent = new DraftComponentVO();
        addedComponent.setFundId(103L);
        addedComponent.setFundCode("000003");
        addedComponent.setFundName("中证1000ETF");
        addedComponent.setWeight(new BigDecimal("0.15"));

        when(reviewMapper.selectPendingProductDetail(9L)).thenReturn(pendingDetail);
        when(productVersionMapper.selectById(19L)).thenReturn(currentVersion);
        when(productVersionMapper.selectById(11L)).thenReturn(baseVersion);
        when(productComponentMapper.selectByVersionId(19L)).thenReturn(List.of(updatedCurrentComponent, addedComponent));
        when(productComponentMapper.selectByVersionId(11L)).thenReturn(List.of(removedComponent, updatedBaseComponent));
        when(productReviewMapper.selectByProductId(9L)).thenReturn(List.of());

        ReviewDetailVO detail = reviewService.getPendingProductDetail(9L);

        assertThat(detail.getChangeType()).isEqualTo("MAJOR");
        assertThat(detail.getVersionNote()).isEqualTo("调仓并提升风险等级");
        assertThat(detail.getBaseVersionSummary()).isNotNull();
        assertThat(detail.getBaseVersionSummary().getVersionNo()).isEqualTo(2);
        assertThat(detail.getCurrentVersionSummary()).isNotNull();
        assertThat(detail.getCurrentVersionSummary().getVersionNo()).isEqualTo(3);
        assertThat(detail.getFieldDiffs()).extracting(ReviewDiffFieldVO::getFieldKey)
                .contains("riskLevel", "productSummary", "targetCustomer", "riskTips",
                        "rebalanceCycleDays", "maxSingleFundWeight", "investHorizonMonths", "strategyNotes");
        assertThat(detail.getComponentDiffs()).extracting(ReviewDiffComponentVO::getDiffType)
                .contains("ADDED", "REMOVED", "UPDATED");
    }
}
