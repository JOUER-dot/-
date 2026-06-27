package com.finance.roboadvisor.subscription.service.impl;

import com.finance.roboadvisor.auth.entity.SysUser;
import com.finance.roboadvisor.auth.security.LoginUser;
import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.notification.service.NotificationService;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.publicapi.mapper.PublicProductMapper;
import com.finance.roboadvisor.subscription.dto.MySubscriptionQueryDTO;
import com.finance.roboadvisor.subscription.entity.AdvisorProductSubscription;
import com.finance.roboadvisor.subscription.entity.SubscriptionVersionAction;
import com.finance.roboadvisor.subscription.mapper.SubscriptionMapper;
import com.finance.roboadvisor.subscription.mapper.SubscriptionVersionActionMapper;
import com.finance.roboadvisor.subscription.vo.MySubscriptionItemVO;
import com.finance.roboadvisor.transaction.service.TransactionService;
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

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class SubscriptionServiceImplTest {

    @Mock private SubscriptionMapper subscriptionMapper;
    @Mock private PublicProductMapper publicProductMapper;
    @Mock private SubscriptionVersionActionMapper subscriptionVersionActionMapper;
    @Mock private NotificationService notificationService;
    @Mock private ProductMapper productMapper;
    @Mock private TransactionService transactionService;

    @InjectMocks
    private SubscriptionServiceImpl subscriptionService;

    @BeforeEach
    void setUp() {
        SysUser sysUser = new SysUser();
        sysUser.setId(3L);
        sysUser.setUsername("testuser");
        sysUser.setStatus(1);
        LoginUser loginUser = new LoginUser(sysUser, List.of("USER"));
        Authentication auth = new UsernamePasswordAuthenticationToken(loginUser, null, loginUser.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(auth);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    private AdvisorProduct createProduct(Long id, String name, Long creatorId) {
        AdvisorProduct p = new AdvisorProduct();
        p.setId(id);
        p.setName(name);
        p.setType("STRATEGY");
        p.setRiskLevel("R3");
        p.setStatus("PUBLISHED");
        p.setCreatorId(creatorId);
        return p;
    }

    // ===================== subscribe =====================

    @Test
    void testSubscribeNew() {
        Long productId = 1L;
        BigDecimal amount = new BigDecimal("10000");

        when(publicProductMapper.countPublishedProductById(productId)).thenReturn(1L);
        when(subscriptionMapper.selectByUserIdAndProductId(3L, productId)).thenReturn(null);

        AdvisorProduct product = createProduct(productId, "优选组合", 5L);
        when(productMapper.selectById(productId)).thenReturn(product);

        subscriptionService.subscribe(productId, amount);

        verify(subscriptionMapper).insert(any(AdvisorProductSubscription.class));
        verify(notificationService, times(2)).createNotification(anyLong(), anyString(), anyString(), anyString(), anyString());
        verify(transactionService).record(eq(3L), eq(productId), eq("优选组合"), eq("SUBSCRIBE"), eq(amount));
    }

    @Test
    void testSubscribeProductNotPublished() {
        Long productId = 1L;
        when(publicProductMapper.countPublishedProductById(productId)).thenReturn(0L);

        assertThrows(BusinessException.class, () -> subscriptionService.subscribe(productId, null));
    }

    @Test
    void testSubscribeAlreadyActive() {
        Long productId = 1L;
        when(publicProductMapper.countPublishedProductById(productId)).thenReturn(1L);

        AdvisorProductSubscription existing = new AdvisorProductSubscription();
        existing.setId(10L);
        existing.setStatus("ACTIVE");
        when(subscriptionMapper.selectByUserIdAndProductId(3L, productId)).thenReturn(existing);

        subscriptionService.subscribe(productId, null);

        verify(subscriptionMapper, never()).insert(any());
    }

    @Test
    void testSubscribeResumeCancelled() {
        Long productId = 1L;
        when(publicProductMapper.countPublishedProductById(productId)).thenReturn(1L);

        AdvisorProductSubscription existing = new AdvisorProductSubscription();
        existing.setId(10L);
        existing.setStatus("CANCELLED");
        when(subscriptionMapper.selectByUserIdAndProductId(3L, productId)).thenReturn(existing);

        subscriptionService.subscribe(productId, null);

        verify(subscriptionMapper).updateStatusToActive(10L);
    }

    // ===================== unsubscribe =====================

    @Test
    void testUnsubscribeSuccess() {
        Long productId = 1L;
        AdvisorProductSubscription existing = new AdvisorProductSubscription();
        existing.setId(10L);
        existing.setStatus("ACTIVE");
        when(subscriptionMapper.selectByUserIdAndProductId(3L, productId)).thenReturn(existing);

        AdvisorProduct product = createProduct(productId, "测试产品", 5L);
        when(productMapper.selectById(productId)).thenReturn(product);

        subscriptionService.unsubscribe(productId);

        verify(subscriptionMapper).updateStatusToCancelled(10L);
    }

    @Test
    void testUnsubscribeAlreadyCancelled() {
        Long productId = 1L;
        AdvisorProductSubscription existing = new AdvisorProductSubscription();
        existing.setId(10L);
        existing.setStatus("CANCELLED");
        when(subscriptionMapper.selectByUserIdAndProductId(3L, productId)).thenReturn(existing);

        subscriptionService.unsubscribe(productId);

        verify(subscriptionMapper, never()).updateStatusToCancelled(anyLong());
    }

    @Test
    void testUnsubscribeNotExists() {
        Long productId = 1L;
        when(subscriptionMapper.selectByUserIdAndProductId(3L, productId)).thenReturn(null);

        subscriptionService.unsubscribe(productId);

        verify(subscriptionMapper, never()).updateStatusToCancelled(anyLong());
    }

    // ===================== listMySubscriptions =====================

    @Test
    void testListMySubscriptionsWithQuery() {
        MySubscriptionQueryDTO query = new MySubscriptionQueryDTO();
        query.setPageNum(1);
        query.setPageSize(10);

        MySubscriptionItemVO item = new MySubscriptionItemVO();
        item.setSubscriptionId(100L);
        item.setProductId(1L);
        item.setProductName("已订阅产品");
        item.setStatus("ACTIVE");

        when(subscriptionMapper.selectSubscriptionsPageByUserId(eq(3L), isNull(), isNull(), isNull(), anyString(), eq(0), eq(10)))
                .thenReturn(List.of(item));
        when(subscriptionMapper.countSubscriptionsByUserId(eq(3L), isNull(), isNull(), isNull())).thenReturn(1L);
        when(subscriptionVersionActionMapper.selectPendingBySubscriptionIds(anyList())).thenReturn(List.of());

        PageResult<MySubscriptionItemVO> result = subscriptionService.listMySubscriptions(query);

        assertEquals(1, result.getRecords().size());
        assertEquals("已订阅产品", result.getRecords().get(0).getProductName());
    }

    @Test
    void testListMySubscriptionsWithFilter() {
        MySubscriptionQueryDTO query = new MySubscriptionQueryDTO();
        query.setKeyword("产品");
        query.setSubscriptionStatus("ACTIVE");
        query.setProductStatus("PUBLISHED");
        query.setSortBy("productNameAsc");

        when(subscriptionMapper.selectSubscriptionsPageByUserId(eq(3L), eq("产品"), eq("ACTIVE"), eq("PUBLISHED"), eq("productNameAsc"), eq(0), eq(10)))
                .thenReturn(List.of());
        when(subscriptionMapper.countSubscriptionsByUserId(eq(3L), eq("产品"), eq("ACTIVE"), eq("PUBLISHED"))).thenReturn(0L);

        PageResult<MySubscriptionItemVO> result = subscriptionService.listMySubscriptions(query);

        assertTrue(result.getRecords().isEmpty());
    }

    @Test
    void testListMySubscriptionsDefaultPagination() {
        when(subscriptionMapper.selectSubscriptionsPageByUserId(anyLong(), any(), any(), any(), anyString(), eq(0), eq(10)))
                .thenReturn(List.of());

        PageResult<MySubscriptionItemVO> result = subscriptionService.listMySubscriptions(null);

        assertEquals(1, result.getPageNum());
        assertEquals(10, result.getPageSize());
    }

    // ===================== createVersionActions =====================

    @Test
    void testCreateVersionActions() {
        Long productId = 1L;
        Long productVersionId = 10L;

        AdvisorProductSubscription sub1 = new AdvisorProductSubscription();
        sub1.setId(100L);
        AdvisorProductSubscription sub2 = new AdvisorProductSubscription();
        sub2.setId(101L);
        when(subscriptionMapper.selectActiveSubscriptionsByProductId(productId))
                .thenReturn(List.of(sub1, sub2));

        subscriptionService.createVersionActions(productId, productVersionId, "NORMAL", "NOTICE", "NOTIFIED", "版本更新");

        verify(subscriptionVersionActionMapper, times(2)).insert(any(SubscriptionVersionAction.class));
    }

    @Test
    void testCreateVersionActionsNoSubscribers() {
        when(subscriptionMapper.selectActiveSubscriptionsByProductId(1L)).thenReturn(List.of());

        subscriptionService.createVersionActions(1L, 10L, "NORMAL", "NOTICE", "NOTIFIED", null);

        verify(subscriptionVersionActionMapper, never()).insert(any());
    }

    // ===================== decideVersionAction =====================

    @Test
    void testDecideVersionActionConfirm() {
        Long subscriptionId = 100L;

        AdvisorProductSubscription subscription = new AdvisorProductSubscription();
        subscription.setId(subscriptionId);
        subscription.setUserId(3L);
        subscription.setStatus("ACTIVE");
        when(subscriptionMapper.selectById(subscriptionId)).thenReturn(subscription);

        SubscriptionVersionAction action = new SubscriptionVersionAction();
        action.setId(200L);
        action.setActionType("CONFIRM_REQUIRED");
        action.setActionStatus("PENDING");
        when(subscriptionVersionActionMapper.selectLatestPendingBySubscriptionId(subscriptionId)).thenReturn(action);

        subscriptionService.decideVersionAction(subscriptionId, "CONFIRM");

        verify(subscriptionVersionActionMapper).updateStatus(200L, "CONFIRMED");
    }

    @Test
    void testDecideVersionActionCancel() {
        Long subscriptionId = 100L;

        AdvisorProductSubscription subscription = new AdvisorProductSubscription();
        subscription.setId(subscriptionId);
        subscription.setUserId(3L);
        subscription.setStatus("ACTIVE");
        when(subscriptionMapper.selectById(subscriptionId)).thenReturn(subscription);

        SubscriptionVersionAction action = new SubscriptionVersionAction();
        action.setId(200L);
        action.setActionType("CONFIRM_REQUIRED");
        action.setActionStatus("PENDING");
        when(subscriptionVersionActionMapper.selectLatestPendingBySubscriptionId(subscriptionId)).thenReturn(action);

        subscriptionService.decideVersionAction(subscriptionId, "CANCEL");

        verify(subscriptionMapper).updateStatusToCancelled(subscriptionId);
        verify(subscriptionVersionActionMapper).updateStatus(200L, "CANCELLED");
    }

    @Test
    void testDecideVersionActionNotOwned() {
        Long subscriptionId = 100L;

        AdvisorProductSubscription subscription = new AdvisorProductSubscription();
        subscription.setId(subscriptionId);
        subscription.setUserId(99L); // different user
        when(subscriptionMapper.selectById(subscriptionId)).thenReturn(subscription);

        assertThrows(BusinessException.class, () -> subscriptionService.decideVersionAction(subscriptionId, "CONFIRM"));
    }

    @Test
    void testDecideVersionActionEmptyDecision() {
        Long subscriptionId = 100L;

        assertThrows(BusinessException.class, () -> subscriptionService.decideVersionAction(subscriptionId, null));
    }

    @Test
    void testDecideVersionActionInvalidDecision() {
        Long subscriptionId = 100L;

        assertThrows(BusinessException.class, () -> subscriptionService.decideVersionAction(subscriptionId, "INVALID"));
    }
}
