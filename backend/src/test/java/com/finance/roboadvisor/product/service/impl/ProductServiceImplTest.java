package com.finance.roboadvisor.product.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.auth.entity.SysRole;
import com.finance.roboadvisor.auth.entity.SysUserRole;
import com.finance.roboadvisor.auth.mapper.RoleMapper;
import com.finance.roboadvisor.auth.mapper.UserRoleMapper;
import com.finance.roboadvisor.auth.security.LoginUser;
import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.common.util.SecurityUtil;
import com.finance.roboadvisor.fund.mapper.FundMapper;
import com.finance.roboadvisor.fund.vo.FundOptionVO;
import com.finance.roboadvisor.notification.service.NotificationService;
import com.finance.roboadvisor.product.dto.ComponentItemDTO;
import com.finance.roboadvisor.product.dto.ProductSaveDTO;
import com.finance.roboadvisor.product.dto.ProductSubmitDTO;
import com.finance.roboadvisor.product.entity.*;
import com.finance.roboadvisor.product.mapper.*;
import com.finance.roboadvisor.product.service.*;
import com.finance.roboadvisor.product.vo.*;
import com.finance.roboadvisor.subscription.mapper.SubscriptionMapper;
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
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class ProductServiceImplTest {

    @Mock private ProductMapper productMapper;
    @Mock private ProductDraftMapper productDraftMapper;
    @Mock private ProductDraftComponentMapper productDraftComponentMapper;
    @Mock private ProductComponentMapper productComponentMapper;
    @Mock private ProductVersionMapper productVersionMapper;
    @Mock private ProductReviewMapper productReviewMapper;
    @Mock private ProductFlowLogMapper productFlowLogMapper;
    @Mock private ProductNavMapper productNavMapper;
    @Mock private FundMapper fundMapper;
    @Mock private RoleMapper roleMapper;
    @Mock private UserRoleMapper userRoleMapper;
    @Mock private NotificationService notificationService;
    @Mock private StrategyRuleValidationService strategyRuleValidationService;
    @Mock private ProductNavGenerationService productNavGenerationService;
    @Mock private ProductHoldingSnapshotGenerationService productHoldingSnapshotGenerationService;
    @Mock private SubscriptionMapper subscriptionMapper;

    private ProductServiceImpl productService;

    @BeforeEach
    void setUp() {
        LoginUser loginUser = createLoginUser(1L, "advisor", "ADVISOR");
        Authentication auth = new UsernamePasswordAuthenticationToken(loginUser, null, loginUser.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(auth);

        productService = new ProductServiceImpl(
                productMapper, productDraftMapper, productDraftComponentMapper,
                productVersionMapper, productComponentMapper, productReviewMapper,
                productFlowLogMapper, productNavMapper, fundMapper,
                productNavGenerationService, productHoldingSnapshotGenerationService,
                strategyRuleValidationService, subscriptionMapper,
                notificationService, userRoleMapper, roleMapper,
                new ObjectMapper()
        );
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    private LoginUser createLoginUser(Long id, String username, String role) {
        com.finance.roboadvisor.auth.entity.SysUser user = new com.finance.roboadvisor.auth.entity.SysUser();
        user.setId(id);
        user.setUsername(username);
        user.setStatus(1);
        return new LoginUser(user, List.of(role));
    }

    private AdvisorProduct createProduct(Long id, String name, String status, Long creatorId, Integer versionNo) {
        AdvisorProduct p = new AdvisorProduct();
        p.setId(id);
        p.setName(name);
        p.setType("STRATEGY");
        p.setRiskLevel("R3");
        p.setStrategyCode("SC_001");
        p.setFeatureTags("稳健,成长");
        p.setStatus(status);
        p.setCreatorId(creatorId);
        p.setCurrentVersionNo(versionNo);
        p.setPublishedVersionNo(status.equals("PUBLISHED") ? versionNo : null);
        p.setCreatedAt(LocalDateTime.now().minusDays(1));
        p.setUpdatedAt(LocalDateTime.now());
        return p;
    }

    private ProductSaveDTO createSaveDTO() {
        ProductSaveDTO dto = new ProductSaveDTO();
        dto.setName("测试产品");
        dto.setType("STRATEGY");
        dto.setRiskLevel("R3");
        dto.setStrategyCode("SC_001");
        dto.setFeatureTags(List.of("稳健"));
        dto.setBaseInfo(Map.of("description", "测试描述"));
        dto.setParams(Map.of("param1", "value1"));

        ComponentItemDTO component = new ComponentItemDTO();
        component.setFundId(1L);
        component.setWeight(new BigDecimal("0.6"));
        ComponentItemDTO component2 = new ComponentItemDTO();
        component2.setFundId(2L);
        component2.setWeight(new BigDecimal("0.4"));
        dto.setComponents(List.of(component, component2));

        return dto;
    }

    // ===================== createProduct =====================

    @Test
    void testCreateProductSuccess() {
        ProductSaveDTO dto = createSaveDTO();

        FundOptionVO fund1 = new FundOptionVO();
        fund1.setId(1L);
        fund1.setFundCode("000001");
        fund1.setFundName("基金A");
        FundOptionVO fund2 = new FundOptionVO();
        fund2.setId(2L);
        fund2.setFundCode("000002");
        fund2.setFundName("基金B");
        when(fundMapper.selectEnabledFundsByIds(anyList())).thenReturn(List.of(fund1, fund2));

        when(productMapper.insert(any(AdvisorProduct.class))).thenAnswer(inv -> {
            AdvisorProduct p = inv.getArgument(0);
            p.setId(100L);
            return 1;
        });
        when(productDraftMapper.insert(any(AdvisorProductDraft.class))).thenAnswer(inv -> {
            AdvisorProductDraft d = inv.getArgument(0);
            d.setId(10L);
            return 1;
        });

        ProductCreateVO result = productService.createProduct(dto);

        assertEquals(100L, result.getProductId());
        verify(productMapper).insert(any(AdvisorProduct.class));
        verify(productDraftMapper).insert(any(AdvisorProductDraft.class));
        verify(productDraftComponentMapper).deleteByDraftId(anyLong());
        verify(productDraftComponentMapper).batchInsert(anyList());
    }

    @Test
    void testCreateProductDuplicateFunds() {
        ProductSaveDTO dto = new ProductSaveDTO();
        dto.setName("测试");
        dto.setType("STRATEGY");
        dto.setRiskLevel("R3");
        dto.setFeatureTags(List.of());
        dto.setBaseInfo(new LinkedHashMap<>());
        ComponentItemDTO c1 = new ComponentItemDTO();
        c1.setFundId(1L);
        c1.setWeight(new BigDecimal("0.5"));
        ComponentItemDTO c2 = new ComponentItemDTO();
        c2.setFundId(1L);
        c2.setWeight(new BigDecimal("0.5"));
        dto.setComponents(List.of(c1, c2));

        assertThrows(BusinessException.class, () -> productService.createProduct(dto));
    }

    @Test
    void testCreateProductWithNullComponents() {
        ProductSaveDTO dto = new ProductSaveDTO();
        dto.setName("测试");
        dto.setType("FOF");
        dto.setRiskLevel("R4");
        dto.setFeatureTags(List.of());
        dto.setBaseInfo(new LinkedHashMap<>());
        dto.setComponents(null);

        when(productMapper.insert(any(AdvisorProduct.class))).thenAnswer(inv -> {
            AdvisorProduct p = inv.getArgument(0);
            p.setId(101L);
            return 1;
        });
        when(productDraftMapper.insert(any(AdvisorProductDraft.class))).thenAnswer(inv -> {
            AdvisorProductDraft d = inv.getArgument(0);
            d.setId(10L);
            return 1;
        });

        ProductCreateVO result = productService.createProduct(dto);

        assertEquals(101L, result.getProductId());
    }

    // ===================== updateProduct =====================

    @Test
    void testUpdateProductSuccess() {
        Long productId = 1L;
        ProductSaveDTO dto = createSaveDTO();
        AdvisorProduct product = createProduct(1L, "测试产品", "DRAFT", 1L, 0);
        when(productMapper.selectById(productId)).thenReturn(product);

        FundOptionVO fund1 = new FundOptionVO();
        fund1.setId(1L); fund1.setFundCode("001"); fund1.setFundName("A");
        FundOptionVO fund2 = new FundOptionVO();
        fund2.setId(2L); fund2.setFundCode("002"); fund2.setFundName("B");
        when(fundMapper.selectEnabledFundsByIds(anyList())).thenReturn(List.of(fund1, fund2));

        AdvisorProductDraft draft = new AdvisorProductDraft();
        draft.setId(10L);
        draft.setProductId(productId);
        when(productDraftMapper.selectByProductId(productId)).thenReturn(draft);

        productService.updateProduct(productId, dto);

        verify(productMapper).updateBasicInfo(any(AdvisorProduct.class));
        verify(productDraftMapper).updateByProductId(any(AdvisorProductDraft.class));
    }

    @Test
    void testUpdateProductNotOwned() {
        Long productId = 1L;
        AdvisorProduct product = createProduct(1L, "测试", "DRAFT", 99L, 0);
        when(productMapper.selectById(productId)).thenReturn(product);

        assertThrows(BusinessException.class, () -> productService.updateProduct(productId, createSaveDTO()));
    }

    @Test
    void testUpdateProductWhenPendingReview() {
        Long productId = 1L;
        AdvisorProduct product = createProduct(1L, "测试", "PENDING_REVIEW", 1L, 1);
        when(productMapper.selectById(productId)).thenReturn(product);

        assertThrows(BusinessException.class, () -> productService.updateProduct(productId, createSaveDTO()));
    }

    // ===================== listProducts =====================

    @Test
    void testListProductsSuccess() {
        when(productMapper.selectByCreator(eq(1L), any(), any(), any(), any(), anyInt(), anyInt()))
                .thenReturn(List.of(createProduct(1L, "产品", "DRAFT", 1L, 0)));
        when(productMapper.countByCreator(anyLong(), any(), any(), any(), any())).thenReturn(1L);

        PageResult<ProductListItemVO> result = productService.listProducts(null, null, null, null, 1, 10);

        assertEquals(1, result.getRecords().size());
        assertEquals(1L, result.getTotal());
    }

    @Test
    void testListProductsDefaultPagination() {
        when(productMapper.selectByCreator(anyLong(), any(), any(), any(), any(), eq(0), eq(10)))
                .thenReturn(List.of());
        when(productMapper.countByCreator(anyLong(), any(), any(), any(), any())).thenReturn(0L);

        PageResult<ProductListItemVO> result = productService.listProducts(null, null, null, null, null, null);

        assertEquals(1, result.getPageNum());
        assertEquals(10, result.getPageSize());
    }

    // ===================== getProductDetail =====================

    @Test
    void testGetProductDetailSuccess() {
        Long productId = 1L;
        AdvisorProduct product = createProduct(productId, "产品详情", "PUBLISHED", 1L, 2);
        product.setPublishedVersionNo(2);
        when(productMapper.selectById(productId)).thenReturn(product);

        AdvisorProductDraft draft = new AdvisorProductDraft();
        draft.setId(10L);
        draft.setProductId(productId);
        draft.setBaseInfoJson("{\"description\":\"desc\"}");
        draft.setParamsJson("{\"rate\":\"0.05\"}");
        when(productDraftMapper.selectByProductId(productId)).thenReturn(draft);

        when(productDraftComponentMapper.selectByDraftId(10L)).thenReturn(List.of());
        when(productReviewMapper.selectByProductId(productId)).thenReturn(List.of());

        AdvisorProductVersion publishedVersion = new AdvisorProductVersion();
        publishedVersion.setId(20L);
        publishedVersion.setVersionNo(2);
        publishedVersion.setVersionStatus("APPROVED");
        publishedVersion.setBaseInfoJson("{\"name\":\"产品详情\"}");
        publishedVersion.setParamsJson("{}");
        when(productVersionMapper.selectByProductAndVersionNo(productId, 2)).thenReturn(publishedVersion);
        when(productComponentMapper.selectByVersionId(20L)).thenReturn(List.of());

        ProductDetailVO result = productService.getProductDetail(productId);

        assertEquals("产品详情", result.getName());
        assertEquals("PUBLISHED", result.getStatus());
        assertNotNull(result.getPublishedVersion());
        assertEquals(2, result.getPublishedVersion().getVersionNo());
    }

    @Test
    void testGetProductDetailNotFound() {
        when(productMapper.selectById(999L)).thenReturn(null);
        assertThrows(BusinessException.class, () -> productService.getProductDetail(999L));
    }

    // ===================== submitProduct =====================

    @Test
    void testSubmitProductSuccess() {
        Long productId = 1L;
        AdvisorProduct product = createProduct(productId, "提交产品", "DRAFT", 1L, 0);
        when(productMapper.selectById(productId)).thenReturn(product);

        AdvisorProductDraft draft = new AdvisorProductDraft();
        draft.setId(10L);
        draft.setProductId(productId);
        draft.setBaseInfoJson("{\"description\":\"desc\"}");
        draft.setParamsJson("{}");
        when(productDraftMapper.selectByProductId(productId)).thenReturn(draft);

        DraftComponentVO dc1 = new DraftComponentVO();
        dc1.setFundId(1L);
        dc1.setWeight(new BigDecimal("1.0"));
        when(productDraftComponentMapper.selectByDraftId(10L)).thenReturn(List.of(dc1));

        FundOptionVO fund = new FundOptionVO();
        fund.setId(1L);
        fund.setFundCode("000001");
        fund.setFundName("测试基金");
        when(fundMapper.selectEnabledFundsByIds(anyList())).thenReturn(List.of(fund));

        when(productVersionMapper.selectLatestPublishedByProductId(productId)).thenReturn(null);

        SysRole reviewerRole = new SysRole();
        reviewerRole.setId(100L);
        reviewerRole.setRoleCode("REVIEWER");
        when(roleMapper.selectByRoleCode("REVIEWER")).thenReturn(reviewerRole);
        when(userRoleMapper.selectByRoleId(100L)).thenReturn(List.of());

        productService.submitProduct(productId, null);

        verify(productVersionMapper).insert(any(AdvisorProductVersion.class));
        verify(productComponentMapper).batchInsert(anyList());
        verify(productMapper).updateStatusAndVersion(eq(productId), eq("PENDING_REVIEW"), eq(1));
    }

    @Test
    void testSubmitProductEmptyComponents() {
        Long productId = 1L;
        AdvisorProduct product = createProduct(productId, "产品", "DRAFT", 1L, 0);
        when(productMapper.selectById(productId)).thenReturn(product);

        AdvisorProductDraft draft = new AdvisorProductDraft();
        draft.setId(10L);
        draft.setBaseInfoJson("{}");
        when(productDraftMapper.selectByProductId(productId)).thenReturn(draft);
        when(productDraftComponentMapper.selectByDraftId(10L)).thenReturn(List.of());

        assertThrows(BusinessException.class, () -> productService.submitProduct(productId, null));
    }

    @Test
    void testSubmitProductWrongStatus() {
        Long productId = 1L;
        AdvisorProduct product = createProduct(productId, "产品", "PUBLISHED", 1L, 2);
        when(productMapper.selectById(productId)).thenReturn(product);

        assertThrows(BusinessException.class, () -> productService.submitProduct(productId, null));
    }

    // ===================== withdrawProduct =====================

    @Test
    void testWithdrawProductSuccess() {
        Long productId = 1L;
        AdvisorProduct product = createProduct(productId, "产品", "PENDING_REVIEW", 1L, 1);
        when(productMapper.selectById(productId)).thenReturn(product);

        AdvisorProductVersion version = new AdvisorProductVersion();
        version.setId(20L);
        version.setVersionStatus("SUBMITTED");
        when(productVersionMapper.selectLatestSubmittedByProductId(productId)).thenReturn(version);

        productService.withdrawProduct(productId);

        verify(productMapper).updateStatus(productId, "DRAFT");
        verify(productVersionMapper).updateVersionStatus(20L, "WITHDRAWN");
    }

    @Test
    void testWithdrawProductNotPendingReview() {
        Long productId = 1L;
        AdvisorProduct product = createProduct(productId, "产品", "DRAFT", 1L, 0);
        when(productMapper.selectById(productId)).thenReturn(product);

        assertThrows(BusinessException.class, () -> productService.withdrawProduct(productId));
    }

    // ===================== offlineProduct =====================

    @Test
    void testOfflineProductSuccess() {
        Long productId = 1L;
        AdvisorProduct product = createProduct(productId, "产品", "PUBLISHED", 1L, 1);
        when(productMapper.selectById(productId)).thenReturn(product);

        productService.offlineProduct(productId);

        verify(productMapper).updateStatus(productId, "OFFLINE");
    }

    @Test
    void testOfflineProductNotPublished() {
        Long productId = 1L;
        AdvisorProduct product = createProduct(productId, "产品", "DRAFT", 1L, 0);
        when(productMapper.selectById(productId)).thenReturn(product);

        assertThrows(BusinessException.class, () -> productService.offlineProduct(productId));
    }

    // ===================== deleteProduct =====================

    @Test
    void testDeleteProductSuccess() {
        Long productId = 1L;
        AdvisorProduct product = createProduct(productId, "产品", "DRAFT", 1L, 0);
        when(productMapper.selectById(productId)).thenReturn(product);

        when(productVersionMapper.selectByProductId(productId)).thenReturn(new ArrayList<>());
        when(productDraftMapper.selectByProductId(productId)).thenReturn(null);

        productService.deleteProduct(productId);

        verify(productVersionMapper).deleteByProductId(productId);
        verify(productReviewMapper).deleteByProductId(productId);
        verify(productFlowLogMapper).deleteByProductId(productId);
        verify(productMapper).deleteById(productId);
    }

    @Test
    void testDeleteProductPendingReview() {
        Long productId = 1L;
        AdvisorProduct product = createProduct(productId, "产品", "PENDING_REVIEW", 1L, 1);
        when(productMapper.selectById(productId)).thenReturn(product);

        assertThrows(BusinessException.class, () -> productService.deleteProduct(productId));
    }

    // ===================== copyProduct =====================

    @Test
    void testCopyProductSuccess() {
        Long productId = 1L;
        AdvisorProduct source = createProduct(productId, "源产品", "PUBLISHED", 1L, 2);
        when(productMapper.selectById(productId)).thenReturn(source);

        when(productMapper.insert(any(AdvisorProduct.class))).thenAnswer(inv -> {
            AdvisorProduct p = inv.getArgument(0);
            p.setId(200L);
            return 1;
        });

        AdvisorProductDraft sourceDraft = new AdvisorProductDraft();
        sourceDraft.setId(10L);
        sourceDraft.setBaseInfoJson("{\"description\":\"desc\"}");
        sourceDraft.setParamsJson("{}");
        when(productDraftMapper.selectByProductId(productId)).thenReturn(sourceDraft);

        List<DraftComponentVO> components = List.of();
        when(productDraftComponentMapper.selectByDraftId(10L)).thenReturn(components);

        Long newId = productService.copyProduct(productId);

        assertEquals(200L, newId);
        verify(productDraftMapper).insert(any(AdvisorProductDraft.class));
    }

    // ===================== generateProductNav =====================

    @Test
    void testGenerateProductNavSuccess() {
        Long productId = 1L;
        AdvisorProduct product = createProduct(productId, "产品", "PUBLISHED", 1L, 1);
        product.setPublishedVersionNo(1);
        when(productMapper.selectById(productId)).thenReturn(product);

        productService.generateProductNav(productId);

        verify(productNavGenerationService).generatePublishedProductNav(productId);
        verify(productHoldingSnapshotGenerationService).generatePublishedHoldingSnapshot(productId);
    }

    @Test
    void testGenerateProductNavNotPublished() {
        Long productId = 1L;
        AdvisorProduct product = createProduct(productId, "产品", "DRAFT", 1L, 0);
        when(productMapper.selectById(productId)).thenReturn(product);

        assertThrows(BusinessException.class, () -> productService.generateProductNav(productId));
    }

    // ===================== listReviews & listFlowLogs =====================

    @Test
    void testListReviewsSuccess() {
        Long productId = 1L;
        AdvisorProduct product = createProduct(productId, "产品", "PUBLISHED", 1L, 1);
        when(productMapper.selectById(productId)).thenReturn(product);
        when(productReviewMapper.selectByProductId(productId)).thenReturn(List.of());

        List<ReviewRecordVO> result = productService.listReviews(productId);
        assertNotNull(result);
    }

    @Test
    void testListFlowLogsSuccess() {
        Long productId = 1L;
        AdvisorProduct product = createProduct(productId, "产品", "PUBLISHED", 1L, 1);
        when(productMapper.selectById(productId)).thenReturn(product);
        when(productFlowLogMapper.selectByProductId(productId)).thenReturn(List.of());

        List<AdvisorProductFlowLog> result = productService.listFlowLogs(productId);
        assertNotNull(result);
    }
}
