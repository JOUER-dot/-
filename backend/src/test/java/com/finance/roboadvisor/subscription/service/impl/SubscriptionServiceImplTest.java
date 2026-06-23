package com.finance.roboadvisor.subscription.service.impl;

import com.finance.roboadvisor.auth.entity.SysUser;
import com.finance.roboadvisor.auth.security.LoginUser;
import com.finance.roboadvisor.publicapi.mapper.PublicProductMapper;
import com.finance.roboadvisor.subscription.entity.AdvisorProductSubscription;
import com.finance.roboadvisor.subscription.mapper.SubscriptionMapper;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.List;

import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SubscriptionServiceImplTest {

    @Mock
    private SubscriptionMapper subscriptionMapper;

    @Mock
    private PublicProductMapper publicProductMapper;

    private SubscriptionServiceImpl subscriptionService;

    @BeforeEach
    void setUp() {
        subscriptionService = new SubscriptionServiceImpl(subscriptionMapper, publicProductMapper);

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
}
