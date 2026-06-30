package com.finance.roboadvisor.review.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.auth.entity.SysUser;
import com.finance.roboadvisor.auth.security.LoginUser;
import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.notification.service.NotificationService;
import com.finance.roboadvisor.product.entity.*;
import com.finance.roboadvisor.product.mapper.*;
import com.finance.roboadvisor.product.service.ProductHoldingSnapshotGenerationService;
import com.finance.roboadvisor.product.service.ProductNavGenerationService;
import com.finance.roboadvisor.product.service.StrategyRuleValidationService;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import com.finance.roboadvisor.product.vo.ReviewRecordVO;
import com.finance.roboadvisor.review.dto.ReviewApproveDTO;
import com.finance.roboadvisor.review.dto.ReviewRejectDTO;
import com.finance.roboadvisor.review.mapper.ReviewMapper;
import com.finance.roboadvisor.review.support.ReviewDiffBuilder;
import com.finance.roboadvisor.review.vo.ReviewDetailVO;
import com.finance.roboadvisor.review.vo.ReviewHistoryItemVO;
import com.finance.roboadvisor.review.vo.ReviewPendingListItemVO;
import com.finance.roboadvisor.subscription.service.SubscriptionService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class ReviewServiceImplTest {

    @Mock private ReviewMapper reviewMapper;
    @Mock private ProductMapper productMapper;
    @Mock private ProductVersionMapper productVersionMapper;
    @Mock private ProductComponentMapper productComponentMapper;
    @Mock private ProductReviewMapper productReviewMapper;
    @Mock private ProductFlowLogMapper productFlowLogMapper;
    @Mock private StrategyRuleMapper strategyRuleMapper;
    @Mock private ProductRuleDecisionMapper productRuleDecisionMapper;
    @Mock private StrategyRuleValidationService strategyRuleValidationService;
    @Mock private ProductNavGenerationService productNavGenerationService;
    @Mock private ProductHoldingSnapshotGenerationService productHoldingSnapshotGenerationService;
    @Mock private SubscriptionService subscriptionService;
    @Mock private NotificationService notificationService;

    private ReviewServiceImpl reviewService;

    @BeforeEach
    void setUp() {
        SysUser sysUser = new SysUser();
        sysUser.setId(2L);
        sysUser.setUsername("reviewer");
        sysUser.setStatus(1);
        LoginUser loginUser = new LoginUser(sysUser, List.of("REVIEWER"));
        Authentication auth = new UsernamePasswordAuthenticationToken(loginUser, null, loginUser.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(auth);

        reviewService = new ReviewServiceImpl(
                reviewMapper, productMapper, productVersionMapper,
                productComponentMapper, productReviewMapper, productFlowLogMapper,
                strategyRuleMapper, productRuleDecisionMapper,
                strategyRuleValidationService, productNavGenerationService,
                productHoldingSnapshotGenerationService, subscriptionService,
                notificationService, new ObjectMapper()
        );
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    private AdvisorProduct createPendingProduct(Long id, String name, Long creatorId) {
        AdvisorProduct p = new AdvisorProduct();
        p.setId(id);
        p.setName(name);
        p.setType("STRATEGY");
        p.setRiskLevel("R3");
        p.setStrategyCode("STRATEGY");
        p.setStatus("PENDING_REVIEW");
        p.setCreatorId(creatorId);
        p.setCurrentVersionNo(1);
        p.setUpdatedAt(LocalDateTime.now());
        return p;
    }

    private AdvisorProductVersion createSubmittedVersion(Long productId, Long versionId, Integer versionNo, String changeType) {
        AdvisorProductVersion v = new AdvisorProductVersion();
        v.setId(versionId);
        v.setProductId(productId);
        v.setVersionNo(versionNo);
        v.setVersionStatus("SUBMITTED");
        v.setChangeType(changeType);
        v.setStatusAtSubmit("PUBLISHED");
        v.setSubmittedAt(LocalDateTime.now());
        v.setBaseInfoJson("{\"name\":\"产品名称\",\"type\":\"STRATEGY\",\"riskLevel\":\"R3\"}");
        v.setParamsJson("{}");
        return v;
    }

    // ===================== listPendingProducts =====================

    @Test
    void testListPendingProductsSuccess() {
        ReviewPendingListItemVO item = new ReviewPendingListItemVO();
        item.setId(1L);
        item.setName("待审产品");
        item.setType("STRATEGY");
        item.setRiskLevel("R3");
        item.setCreatorName("投顾A");
        when(reviewMapper.selectPendingProducts(any(), any(), any(), anyInt(), anyInt())).thenReturn(List.of(item));
        when(reviewMapper.countPendingProducts(any(), any(), any())).thenReturn(1L);

        PageResult<ReviewPendingListItemVO> result = reviewService.listPendingProducts(null, null, null, 1, 10);

        assertEquals(1, result.getRecords().size());
        assertEquals(1L, result.getTotal());
    }

    @Test
    void testListPendingProductsWithFilter() {
        when(reviewMapper.selectPendingProducts(eq("keyword"), eq("FOF"), eq("R4"), eq(0), eq(10))).thenReturn(List.of());
        when(reviewMapper.countPendingProducts(eq("keyword"), eq("FOF"), eq("R4"))).thenReturn(0L);

        PageResult<ReviewPendingListItemVO> result = reviewService.listPendingProducts("keyword", "FOF", "R4", 1, 10);

        assertTrue(result.getRecords().isEmpty());
        assertEquals(0L, result.getTotal());
    }

    @Test
    void testListPendingProductsDefaultPagination() {
        when(reviewMapper.selectPendingProducts(any(), any(), any(), eq(0), eq(10))).thenReturn(List.of());
        when(reviewMapper.countPendingProducts(any(), any(), any())).thenReturn(0L);

        PageResult<ReviewPendingListItemVO> result = reviewService.listPendingProducts(null, null, null, null, null);

        assertEquals(1, result.getPageNum());
        assertEquals(10, result.getPageSize());
    }

    // ===================== approveProduct =====================

    @Test
    void testApproveProductWithNewProduct() {
        Long productId = 1L;
        AdvisorProduct product = createPendingProduct(productId, "新产品", 1L);
        when(productMapper.selectById(productId)).thenReturn(product);

        AdvisorProductVersion version = createSubmittedVersion(productId, 10L, 1, "NORMAL");
        when(productVersionMapper.selectLatestSubmittedByProductId(productId)).thenReturn(version);

        List<DraftComponentVO> components = List.of();
        when(productComponentMapper.selectByVersionId(10L)).thenReturn(components);

        when(strategyRuleMapper.selectEnabledByStrategyAndType(any(), anyString())).thenReturn(null);

        reviewService.approveProduct(productId, null);

        verify(productMapper).updateApprovedReviewOutcome(productId, "PUBLISHED", 1);
        verify(productVersionMapper).updateVersionStatus(10L, "APPROVED");
        verify(subscriptionService).createVersionActions(eq(productId), eq(10L), eq("NORMAL"),
                eq("NOTICE"), eq("NOTIFIED"), isNull());
        verify(productNavGenerationService).generatePublishedProductNav(productId);
        verify(productHoldingSnapshotGenerationService).generatePublishedHoldingSnapshot(productId);
        verify(notificationService).createNotification(eq(1L), eq("审核通过"), anyString(), eq("REVIEW_RESULT"), anyString());
    }

    @Test
    void testApproveProductWithMajorChange() {
        Long productId = 1L;
        AdvisorProduct product = createPendingProduct(productId, "重大变更产品", 1L);
        when(productMapper.selectById(productId)).thenReturn(product);

        AdvisorProductVersion version = createSubmittedVersion(productId, 10L, 2, "MAJOR");
        when(productVersionMapper.selectLatestSubmittedByProductId(productId)).thenReturn(version);

        when(productComponentMapper.selectByVersionId(10L)).thenReturn(List.of());

        AdvisorStrategyRule rule = new AdvisorStrategyRule();
        rule.setId(100L);
        rule.setStrategyCode("STRATEGY");
        rule.setProductType("STRATEGY");
        rule.setMinFundCount(2);
        rule.setMaxFundCount(10);
        rule.setMinSingleWeight(new BigDecimal("0.05"));
        rule.setMaxSingleWeight(new BigDecimal("0.6"));
        rule.setAllowFundTypes("EQUITY,BOND");
        rule.setRiskRuleMode("NORMAL");
        when(strategyRuleMapper.selectEnabledByStrategyAndType("STRATEGY", "STRATEGY")).thenReturn(rule);

        ReviewApproveDTO dto = new ReviewApproveDTO();
        dto.setOverrideMaxSingleWeight(new BigDecimal("0.8"));
        dto.setDecisionComment("允许超过60%权重");

        reviewService.approveProduct(productId, dto);

        verify(subscriptionService).createVersionActions(eq(productId), eq(10L), eq("MAJOR"),
                eq("CONFIRM_REQUIRED"), eq("PENDING"), isNull());
        verify(productRuleDecisionMapper).insert(any(AdvisorProductRuleDecision.class));
    }

    @Test
    void testApproveProductNotPending() {
        Long productId = 1L;
        AdvisorProduct product = createPendingProduct(productId, "产品", 1L);
        product.setStatus("PUBLISHED");
        when(productMapper.selectById(productId)).thenReturn(product);

        assertThrows(BusinessException.class, () -> reviewService.approveProduct(productId, null));
    }

    @Test
    void testApproveProductNoSubmittedVersion() {
        Long productId = 1L;
        AdvisorProduct product = createPendingProduct(productId, "产品", 1L);
        when(productMapper.selectById(productId)).thenReturn(product);
        when(productVersionMapper.selectLatestSubmittedByProductId(productId)).thenReturn(null);

        assertThrows(BusinessException.class, () -> reviewService.approveProduct(productId, null));
    }

    // ===================== rejectProduct =====================

    @Test
    void testRejectProductSuccess() {
        Long productId = 1L;
        AdvisorProduct product = createPendingProduct(productId, "驳回产品", 1L);
        when(productMapper.selectById(productId)).thenReturn(product);

        AdvisorProductVersion version = createSubmittedVersion(productId, 10L, 1, "NORMAL");
        when(productVersionMapper.selectLatestSubmittedByProductId(productId)).thenReturn(version);

        ReviewRejectDTO dto = new ReviewRejectDTO();
        dto.setComment("成份基金风险过高");

        reviewService.rejectProduct(productId, dto);

        verify(productMapper).updateRejectedReviewOutcome(productId, "REJECTED", "成份基金风险过高");
        verify(productVersionMapper).updateVersionStatus(10L, "REJECTED");
        verify(productReviewMapper).insert(any(AdvisorProductReview.class));
        verify(productFlowLogMapper).insert(any(AdvisorProductFlowLog.class));
        verify(notificationService).createNotification(eq(1L), eq("审核驳回"), anyString(), eq("REVIEW_RESULT"), anyString());
    }

    @Test
    void testRejectProductNotPending() {
        Long productId = 1L;
        AdvisorProduct product = createPendingProduct(productId, "产品", 1L);
        product.setStatus("DRAFT");
        when(productMapper.selectById(productId)).thenReturn(product);

        ReviewRejectDTO dto = new ReviewRejectDTO();
        dto.setComment("原因");

        assertThrows(BusinessException.class, () -> reviewService.rejectProduct(productId, dto));
    }

    // ===================== batch operations =====================

    @Test
    void testBatchApproveSuccess() {
        Long productId1 = 1L;
        Long productId2 = 2L;

        // We need to test batchApprove calls approveProduct internally
        // Mock the internal calls by letting them succeed
        AdvisorProduct p1 = createPendingProduct(productId1, "产品1", 1L);
        AdvisorProduct p2 = createPendingProduct(productId2, "产品2", 2L);
        when(productMapper.selectById(productId1)).thenReturn(p1);
        when(productMapper.selectById(productId2)).thenReturn(p2);

        AdvisorProductVersion v1 = createSubmittedVersion(productId1, 10L, 1, "NORMAL");
        AdvisorProductVersion v2 = createSubmittedVersion(productId2, 20L, 1, "NORMAL");
        when(productVersionMapper.selectLatestSubmittedByProductId(productId1)).thenReturn(v1);
        when(productVersionMapper.selectLatestSubmittedByProductId(productId2)).thenReturn(v2);

        when(productComponentMapper.selectByVersionId(10L)).thenReturn(List.of());
        when(productComponentMapper.selectByVersionId(20L)).thenReturn(List.of());
        when(strategyRuleMapper.selectEnabledByStrategyAndType(any(), any())).thenReturn(null);

        reviewService.batchApprove(List.of(productId1, productId2), null);

        verify(productVersionMapper).updateVersionStatus(10L, "APPROVED");
        verify(productVersionMapper).updateVersionStatus(20L, "APPROVED");
    }

    @Test
    void testBatchRejectSuccess() {
        Long productId1 = 1L;
        Long productId2 = 2L;

        AdvisorProduct p1 = createPendingProduct(productId1, "产品A", 1L);
        AdvisorProduct p2 = createPendingProduct(productId2, "产品B", 1L);
        when(productMapper.selectById(productId1)).thenReturn(p1);
        when(productMapper.selectById(productId2)).thenReturn(p2);

        AdvisorProductVersion v1 = createSubmittedVersion(productId1, 10L, 1, "NORMAL");
        AdvisorProductVersion v2 = createSubmittedVersion(productId2, 20L, 1, "NORMAL");
        when(productVersionMapper.selectLatestSubmittedByProductId(productId1)).thenReturn(v1);
        when(productVersionMapper.selectLatestSubmittedByProductId(productId2)).thenReturn(v2);

        ReviewRejectDTO dto = new ReviewRejectDTO();
        dto.setComment("批量驳回原因");

        reviewService.batchReject(List.of(productId1, productId2), dto);

        verify(productMapper, times(2)).updateRejectedReviewOutcome(anyLong(), eq("REJECTED"), anyString());
    }

    // ===================== getMyReviewHistory =====================

    @Test
    void testGetMyReviewHistorySuccess() {
        ReviewHistoryItemVO item = new ReviewHistoryItemVO();
        item.setProductId(1L);
        item.setProductName("已审产品");
        when(reviewMapper.selectReviewHistoryByReviewer(eq(2L), eq(0), eq(10))).thenReturn(List.of(item));

        List<ReviewHistoryItemVO> result = reviewService.getMyReviewHistory(1, 10);

        assertEquals(1, result.size());
        assertEquals("已审产品", result.get(0).getProductName());
    }

    @Test
    void testGetMyReviewHistoryDefaultPagination() {
        when(reviewMapper.selectReviewHistoryByReviewer(eq(2L), eq(0), eq(10))).thenReturn(List.of());

        List<ReviewHistoryItemVO> result = reviewService.getMyReviewHistory(null, null);

        assertTrue(result.isEmpty());
    }

    // ===================== Additional tests for coverage =====================

    @Test
    void testGetPendingProductDetailSuccess() {
        Long productId = 1L;
        ReviewDetailVO detail = new ReviewDetailVO();
        detail.setId(productId);
        detail.setName("待审产品详情");
        detail.setVersionId(10L);
        detail.setFeatureTagsText("稳健,成长");
        detail.setBaseInfoJson("{\"name\":\"产品\"}");
        detail.setParamsJson("{\"rate\":\"0.05\"}");

        when(reviewMapper.selectPendingProductDetail(productId)).thenReturn(detail);

        AdvisorProductVersion currentVersion = createSubmittedVersion(productId, 10L, 1, "NORMAL");
        when(productVersionMapper.selectById(10L)).thenReturn(currentVersion);

        when(productComponentMapper.selectByVersionId(10L)).thenReturn(List.of());
        when(productReviewMapper.selectByProductId(productId)).thenReturn(List.of());

        ReviewDetailVO result = reviewService.getPendingProductDetail(productId);

        assertNotNull(result);
        assertEquals("待审产品详情", result.getName());
        assertEquals(2, result.getFeatureTags().size());
        assertNotNull(result.getBaseInfo());
        assertNotNull(result.getParams());
    }

    @Test
    void testGetPendingProductDetailNotFound() {
        when(reviewMapper.selectPendingProductDetail(999L)).thenReturn(null);

        assertThrows(BusinessException.class,
                () -> reviewService.getPendingProductDetail(999L));
    }

    @Test
    void testGetPendingProductDetailWithBaseVersion() {
        Long productId = 1L;
        ReviewDetailVO detail = new ReviewDetailVO();
        detail.setId(productId);
        detail.setName("变更产品");
        detail.setVersionId(20L);
        detail.setFeatureTagsText(null);
        detail.setBaseInfoJson("{}");
        detail.setParamsJson("{}");

        when(reviewMapper.selectPendingProductDetail(productId)).thenReturn(detail);

        AdvisorProductVersion currentVersion = createSubmittedVersion(productId, 20L, 2, "MAJOR");
        currentVersion.setBaseVersionId(15L);
        when(productVersionMapper.selectById(20L)).thenReturn(currentVersion);

        AdvisorProductVersion baseVersion = createSubmittedVersion(productId, 15L, 1, "NORMAL");
        baseVersion.setVersionStatus("APPROVED");
        when(productVersionMapper.selectById(15L)).thenReturn(baseVersion);

        when(productComponentMapper.selectByVersionId(20L)).thenReturn(List.of());
        when(productComponentMapper.selectByVersionId(15L)).thenReturn(List.of());
        when(productReviewMapper.selectByProductId(productId)).thenReturn(List.of());

        ReviewDetailVO result = reviewService.getPendingProductDetail(productId);

        assertNotNull(result);
        assertEquals("MAJOR", result.getChangeType());
    }

    @Test
    void testApproveProductWithOverrideNoComment() {
        Long productId = 1L;
        AdvisorProduct product = createPendingProduct(productId, "产品", 1L);
        when(productMapper.selectById(productId)).thenReturn(product);

        AdvisorProductVersion version = createSubmittedVersion(productId, 10L, 1, "NORMAL");
        when(productVersionMapper.selectLatestSubmittedByProductId(productId)).thenReturn(version);

        ReviewApproveDTO dto = new ReviewApproveDTO();
        dto.setOverrideMaxSingleWeight(new BigDecimal("0.8"));
        // No decision comment set

        assertThrows(BusinessException.class, () -> reviewService.approveProduct(productId, dto));
    }

    @Test
    void testRejectProductNoSubmittedVersion() {
        Long productId = 1L;
        AdvisorProduct product = createPendingProduct(productId, "产品", 1L);
        when(productMapper.selectById(productId)).thenReturn(product);
        when(productVersionMapper.selectLatestSubmittedByProductId(productId)).thenReturn(null);

        ReviewRejectDTO dto = new ReviewRejectDTO();
        dto.setComment("原因");

        assertThrows(BusinessException.class, () -> reviewService.rejectProduct(productId, dto));
    }

    @Test
    void testBatchApproveWithFailure() {
        Long productId = 1L;

        when(productMapper.selectById(productId)).thenReturn(null);

        ReviewApproveDTO dto = null;

        assertThrows(BusinessException.class,
                () -> reviewService.batchApprove(List.of(productId), dto));
    }

    @Test
    void testBatchRejectWithFailure() {
        Long productId = 1L;

        AdvisorProduct product = createPendingProduct(productId, "产品", 1L);
        when(productMapper.selectById(productId)).thenReturn(product);
        when(productVersionMapper.selectLatestSubmittedByProductId(productId)).thenReturn(null);

        ReviewRejectDTO dto = new ReviewRejectDTO();
        dto.setComment("原因");

        assertThrows(BusinessException.class,
                () -> reviewService.batchReject(List.of(productId), dto));
    }

    @Test
    void testListPendingProductsTrimKeyword() {
        when(reviewMapper.selectPendingProducts(eq("keyword"), isNull(), isNull(), eq(0), eq(10)))
                .thenReturn(List.of());
        when(reviewMapper.countPendingProducts(eq("keyword"), isNull(), isNull())).thenReturn(0L);

        PageResult<ReviewPendingListItemVO> result = reviewService.listPendingProducts("  keyword  ", "  ", "  ", 1, 10);

        assertTrue(result.getRecords().isEmpty());
    }

    @Test
    void testListPendingProductsWithFeatureTags() {
        ReviewPendingListItemVO item = new ReviewPendingListItemVO();
        item.setId(1L);
        item.setName("产品A");
        item.setFeatureTagsText("稳健,成长,高收益");

        when(reviewMapper.selectPendingProducts(any(), any(), any(), anyInt(), anyInt())).thenReturn(List.of(item));
        when(reviewMapper.countPendingProducts(any(), any(), any())).thenReturn(1L);

        PageResult<ReviewPendingListItemVO> result = reviewService.listPendingProducts(null, null, null, 1, 10);

        assertEquals(3, result.getRecords().get(0).getFeatureTags().size());
    }

    @Test
    void testGetMyReviewHistoryWithInvalidPagination() {
        when(reviewMapper.selectReviewHistoryByReviewer(eq(2L), eq(0), eq(10))).thenReturn(List.of());

        List<ReviewHistoryItemVO> result = reviewService.getMyReviewHistory(0, 0);

        assertTrue(result.isEmpty());
    }

    @Test
    void testGetMyReviewHistoryWithNegativePagination() {
        when(reviewMapper.selectReviewHistoryByReviewer(eq(2L), eq(0), eq(10))).thenReturn(List.of());

        List<ReviewHistoryItemVO> result = reviewService.getMyReviewHistory(-1, -5);

        assertTrue(result.isEmpty());
    }

    @Test
    void testApproveProductProductNotFound() {
        when(productMapper.selectById(999L)).thenReturn(null);

        assertThrows(BusinessException.class, () -> reviewService.approveProduct(999L, null));
    }
}
