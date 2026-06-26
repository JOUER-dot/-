package com.finance.roboadvisor.subscription.service.impl;

import com.finance.roboadvisor.auth.entity.SysUser;
import com.finance.roboadvisor.auth.security.LoginUser;
import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.publicapi.mapper.PublicProductMapper;
import com.finance.roboadvisor.subscription.dto.MySubscriptionQueryDTO;
import com.finance.roboadvisor.subscription.entity.AdvisorProductSubscription;
import com.finance.roboadvisor.subscription.entity.SubscriptionVersionAction;
import com.finance.roboadvisor.subscription.mapper.SubscriptionMapper;
import com.finance.roboadvisor.subscription.mapper.SubscriptionVersionActionMapper;
import com.finance.roboadvisor.subscription.vo.MySubscriptionItemVO;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SubscriptionServiceImplTest {

    @Mock
    private SubscriptionMapper subscriptionMapper;

    @Mock
    private PublicProductMapper publicProductMapper;

    @Mock
    private SubscriptionVersionActionMapper subscriptionVersionActionMapper;

    private SubscriptionServiceImpl subscriptionService;

    @BeforeEach
    void setUp() {
        subscriptionService = new SubscriptionServiceImpl(subscriptionMapper, publicProductMapper, subscriptionVersionActionMapper);

        SysUser user = new SysUser();
        user.setId(1L);
        user.setUsername("user01");
        user.setPasswordHash("test");
        user.setStatus(1);
        LoginUser loginUser = new LoginUser(user, List.of("USER"));
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(loginUser, null, loginUser.getAuthorities())
        );
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void subscribe_shouldBeIdempotentWhenActiveSubscriptionExists() {
        AdvisorProductSubscription subscription = new AdvisorProductSubscription();
        subscription.setId(100L);
        subscription.setProductId(1L);
        subscription.setUserId(1L);
        subscription.setStatus("ACTIVE");

        when(publicProductMapper.countPublishedProductById(1L)).thenReturn(1L);
        when(subscriptionMapper.selectByUserIdAndProductId(1L, 1L)).thenReturn(subscription);

        subscriptionService.subscribe(1L);

        verify(subscriptionMapper, never()).insert(org.mockito.ArgumentMatchers.any(AdvisorProductSubscription.class));
        verify(subscriptionMapper, never()).updateStatusToActive(100L);
    }

    @Test
    void unsubscribe_shouldUpdateStatusToCancelledWhenActive() {
        AdvisorProductSubscription subscription = new AdvisorProductSubscription();
        subscription.setId(100L);
        subscription.setProductId(1L);
        subscription.setUserId(1L);
        subscription.setStatus("ACTIVE");

        when(subscriptionMapper.selectByUserIdAndProductId(1L, 1L)).thenReturn(subscription);

        subscriptionService.unsubscribe(1L);

        verify(subscriptionMapper).updateStatusToCancelled(100L);
    }

    @Test
    void unsubscribe_shouldBeIdempotentWhenAlreadyCancelled() {
        AdvisorProductSubscription subscription = new AdvisorProductSubscription();
        subscription.setId(100L);
        subscription.setProductId(1L);
        subscription.setUserId(1L);
        subscription.setStatus("CANCELLED");

        when(subscriptionMapper.selectByUserIdAndProductId(1L, 1L)).thenReturn(subscription);

        subscriptionService.unsubscribe(1L);

        verify(subscriptionMapper, never()).updateStatusToCancelled(100L);
    }

    @Test
    void unsubscribe_shouldBeIdempotentWhenSubscriptionNotExists() {
        when(subscriptionMapper.selectByUserIdAndProductId(1L, 1L)).thenReturn(null);

        subscriptionService.unsubscribe(1L);

        verify(subscriptionMapper, never()).updateStatusToCancelled(org.mockito.ArgumentMatchers.anyLong());
    }

    @Test
    void listMySubscriptions_shouldQueryAllSubscriptionsByUserId() {
        subscriptionService.listMySubscriptions();

        verify(subscriptionMapper).selectSubscriptionsByUserId(1L);
    }

    @Test
    void listMySubscriptions_shouldReturnPagedResultWithDefaultSortWhenQueryMissing() {
        MySubscriptionQueryDTO queryDTO = new MySubscriptionQueryDTO();
        MySubscriptionItemVO item = new MySubscriptionItemVO();
        item.setSubscriptionId(10L);

        when(subscriptionMapper.countSubscriptionsByUserId(1L, null, null, null)).thenReturn(1L);
        when(subscriptionMapper.selectSubscriptionsPageByUserId(1L, null, null, null, "subscribedAtDesc", 0, 10))
                .thenReturn(List.of(item));

        PageResult<MySubscriptionItemVO> result = subscriptionService.listMySubscriptions(queryDTO);

        assertEquals(1L, result.getTotal());
        assertEquals(1, result.getPageNum());
        assertEquals(10, result.getPageSize());
        assertEquals(1, result.getRecords().size());
        verify(subscriptionMapper).countSubscriptionsByUserId(1L, null, null, null);
        verify(subscriptionMapper).selectSubscriptionsPageByUserId(1L, null, null, null, "subscribedAtDesc", 0, 10);
    }

    @Test
    void listMySubscriptions_shouldBackfillPendingVersionActionsOnPagedItems() {
        MySubscriptionQueryDTO queryDTO = new MySubscriptionQueryDTO();
        MySubscriptionItemVO item = new MySubscriptionItemVO();
        item.setSubscriptionId(10L);
        SubscriptionVersionAction action = new SubscriptionVersionAction();
        action.setId(99L);
        action.setSubscriptionId(10L);
        action.setActionType("CONFIRM_REQUIRED");
        action.setActionStatus("PENDING");

        when(subscriptionMapper.countSubscriptionsByUserId(1L, null, null, null)).thenReturn(1L);
        when(subscriptionMapper.selectSubscriptionsPageByUserId(1L, null, null, null, "subscribedAtDesc", 0, 10))
                .thenReturn(List.of(item));
        when(subscriptionVersionActionMapper.selectPendingBySubscriptionIds(List.of(10L)))
                .thenReturn(List.of(action));

        PageResult<MySubscriptionItemVO> result = subscriptionService.listMySubscriptions(queryDTO);

        List<SubscriptionVersionAction> pendingVersionActions = result.getRecords().get(0).getPendingVersionActions();
        assertNotNull(pendingVersionActions);
        assertEquals(1, pendingVersionActions.size());
        assertEquals(99L, pendingVersionActions.get(0).getId());
    }

    @Test
    void createVersionActions_shouldInsertActionsForActiveSubscriptionsOnly() {
        AdvisorProductSubscription active = new AdvisorProductSubscription();
        active.setId(10L);
        active.setProductId(8L);
        active.setUserId(1L);
        active.setStatus("ACTIVE");

        AdvisorProductSubscription cancelled = new AdvisorProductSubscription();
        cancelled.setId(11L);
        cancelled.setProductId(8L);
        cancelled.setUserId(2L);
        cancelled.setStatus("CANCELLED");

        when(subscriptionMapper.selectActiveSubscriptionsByProductId(8L)).thenReturn(List.of(active));

        subscriptionService.createVersionActions(8L, 101L, "MAJOR", "CONFIRM_REQUIRED", "PENDING", "调仓并提升风险等级");

        ArgumentCaptor<SubscriptionVersionAction> actionCaptor = ArgumentCaptor.forClass(SubscriptionVersionAction.class);
        verify(subscriptionVersionActionMapper).insert(actionCaptor.capture());
        assertEquals(10L, actionCaptor.getValue().getSubscriptionId());
        assertEquals("CONFIRM_REQUIRED", actionCaptor.getValue().getActionType());
        assertEquals("PENDING", actionCaptor.getValue().getActionStatus());
        assertEquals("MAJOR", actionCaptor.getValue().getChangeType());
    }

    @Test
    void decideVersionAction_shouldConfirmPendingActionWhenDecisionIsConfirm() {
        AdvisorProductSubscription subscription = new AdvisorProductSubscription();
        subscription.setId(10L);
        subscription.setProductId(8L);
        subscription.setUserId(1L);
        subscription.setStatus("ACTIVE");

        SubscriptionVersionAction action = new SubscriptionVersionAction();
        action.setId(99L);
        action.setSubscriptionId(10L);
        action.setActionType("CONFIRM_REQUIRED");
        action.setActionStatus("PENDING");

        when(subscriptionMapper.selectById(10L)).thenReturn(subscription);
        when(subscriptionVersionActionMapper.selectLatestPendingBySubscriptionId(10L)).thenReturn(action);

        subscriptionService.decideVersionAction(10L, "CONFIRM");

        verify(subscriptionVersionActionMapper).updateStatus(99L, "CONFIRMED");
        verify(subscriptionMapper, never()).updateStatusToCancelled(10L);
    }

    @Test
    void decideVersionAction_shouldCancelSubscriptionWhenDecisionIsCancel() {
        AdvisorProductSubscription subscription = new AdvisorProductSubscription();
        subscription.setId(10L);
        subscription.setProductId(8L);
        subscription.setUserId(1L);
        subscription.setStatus("ACTIVE");

        SubscriptionVersionAction action = new SubscriptionVersionAction();
        action.setId(99L);
        action.setSubscriptionId(10L);
        action.setActionType("CONFIRM_REQUIRED");
        action.setActionStatus("PENDING");

        when(subscriptionMapper.selectById(10L)).thenReturn(subscription);
        when(subscriptionVersionActionMapper.selectLatestPendingBySubscriptionId(10L)).thenReturn(action);

        subscriptionService.decideVersionAction(10L, "CANCEL");

        verify(subscriptionMapper).updateStatusToCancelled(10L);
        verify(subscriptionVersionActionMapper).updateStatus(99L, "CANCELLED");
    }
}
