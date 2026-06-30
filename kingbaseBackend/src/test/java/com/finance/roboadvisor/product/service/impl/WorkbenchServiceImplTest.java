package com.finance.roboadvisor.product.service.impl;

import com.finance.roboadvisor.auth.entity.SysUser;
import com.finance.roboadvisor.auth.security.LoginUser;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.product.mapper.ProductNavMapper;
import com.finance.roboadvisor.product.service.WorkbenchService;
import com.finance.roboadvisor.product.vo.WorkbenchVO;
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

import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class WorkbenchServiceImplTest {

    @Mock private ProductMapper productMapper;
    @Mock private SubscriptionMapper subscriptionMapper;

    @InjectMocks
    private WorkbenchServiceImpl workbenchService;

    @BeforeEach
    void setUp() {
        SysUser sysUser = new SysUser();
        sysUser.setId(1L);
        sysUser.setUsername("advisor");
        sysUser.setStatus(1);
        LoginUser loginUser = new LoginUser(sysUser, List.of("ADVISOR"));
        Authentication auth = new UsernamePasswordAuthenticationToken(loginUser, null, loginUser.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(auth);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    private AdvisorProduct createProduct(Long id, String name, String status) {
        AdvisorProduct p = new AdvisorProduct();
        p.setId(id);
        p.setName(name);
        p.setType("STRATEGY");
        p.setRiskLevel("R3");
        p.setStatus(status);
        p.setCreatorId(1L);
        p.setUpdatedAt(LocalDateTime.now().minusDays(status.equals("REJECTED") ? 2 : 1));
        return p;
    }

    @Test
    void testGetAdvisorWorkbench() {
        when(productMapper.countByCreator(1L, null, null, null, null)).thenReturn(10L);
        when(productMapper.countByCreator(1L, "PUBLISHED", null, null, null)).thenReturn(5L);
        when(productMapper.countByCreator(1L, "PENDING_REVIEW", null, null, null)).thenReturn(2L);
        when(productMapper.countByCreator(1L, "REJECTED", null, null, null)).thenReturn(1L);
        when(productMapper.countByCreator(1L, "DRAFT", null, null, null)).thenReturn(2L);
        when(subscriptionMapper.countActiveByCreatorId(1L)).thenReturn(50L);
        when(subscriptionMapper.countRecentWeekByCreatorId(1L)).thenReturn(5L);

        AdvisorProduct rejectedProduct = createProduct(3L, "被驳回产品", "REJECTED");
        AdvisorProduct pendingProduct = createProduct(2L, "待审核产品", "PENDING_REVIEW");
        AdvisorProduct publishedProduct = createProduct(1L, "已上架产品", "PUBLISHED");
        when(productMapper.selectByCreator(eq(1L), isNull(), isNull(), isNull(), isNull(), eq(0), eq(9999)))
                .thenReturn(List.of(publishedProduct, pendingProduct, rejectedProduct));

        when(subscriptionMapper.countByProductId(1L)).thenReturn(30L);

        WorkbenchVO result = workbenchService.getAdvisorWorkbench();

        // Verify overview
        assertEquals(10L, result.getOverview().getTotalProducts());
        assertEquals(5L, result.getOverview().getPublishedProducts());
        assertEquals(2L, result.getOverview().getPendingReviewProducts());
        assertEquals(1L, result.getOverview().getRejectedProducts());
        assertEquals(2L, result.getOverview().getDraftProducts());
        assertEquals(50L, result.getOverview().getTotalSubscriptions());
        assertEquals(5L, result.getOverview().getRecentWeekSubscriptions());

        // Verify urgent products (rejected first, max 5)
        assertEquals(2, result.getUrgentProducts().size());
        assertEquals("REJECTED", result.getUrgentProducts().get(0).getStatus());
        assertEquals("PENDING_REVIEW", result.getUrgentProducts().get(1).getStatus());

        // Verify rankings
        assertEquals(1, result.getProductRankings().size());
        assertEquals(30L, result.getProductRankings().get(0).getSubscriberCount());
    }

    @Test
    void testGetAdvisorWorkbenchEmpty() {
        when(productMapper.countByCreator(1L, null, null, null, null)).thenReturn(0L);
        when(productMapper.countByCreator(1L, "PUBLISHED", null, null, null)).thenReturn(0L);
        when(productMapper.countByCreator(1L, "PENDING_REVIEW", null, null, null)).thenReturn(0L);
        when(productMapper.countByCreator(1L, "REJECTED", null, null, null)).thenReturn(0L);
        when(productMapper.countByCreator(1L, "DRAFT", null, null, null)).thenReturn(0L);
        when(subscriptionMapper.countActiveByCreatorId(1L)).thenReturn(0L);
        when(subscriptionMapper.countRecentWeekByCreatorId(1L)).thenReturn(0L);

        when(productMapper.selectByCreator(eq(1L), isNull(), isNull(), isNull(), isNull(), eq(0), eq(9999)))
                .thenReturn(List.of());

        WorkbenchVO result = workbenchService.getAdvisorWorkbench();

        assertEquals(0L, result.getOverview().getTotalProducts());
        assertTrue(result.getUrgentProducts().isEmpty());
        assertTrue(result.getProductRankings().isEmpty());
    }
}
