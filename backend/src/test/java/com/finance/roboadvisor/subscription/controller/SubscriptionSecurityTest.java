package com.finance.roboadvisor.subscription.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.auth.security.JwtAuthenticationFilter;
import com.finance.roboadvisor.auth.security.SecurityConfig;
import com.finance.roboadvisor.subscription.service.SubscriptionService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(controllers = SubscriptionController.class)
@Import(SecurityConfig.class)
class SubscriptionSecurityTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private SubscriptionService subscriptionService;

    @MockBean
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Autowired
    @SuppressWarnings("unused")
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() throws Exception {
        doAnswer(invocation -> {
            Object[] args = invocation.getArguments();
            jakarta.servlet.FilterChain chain = (jakarta.servlet.FilterChain) args[2];
            chain.doFilter((jakarta.servlet.ServletRequest) args[0], (jakarta.servlet.ServletResponse) args[1]);
            return null;
        }).when(jwtAuthenticationFilter).doFilter(any(), any(), any());
    }

    @Test
    void unsubscribe_shouldReturnUnauthorizedWhenNotLoggedIn() throws Exception {
        mockMvc.perform(post("/api/public/advisor-products/1/unsubscribe"))
                .andExpect(status().isUnauthorized());

        verify(subscriptionService, never()).unsubscribe(1L);
    }

    @Test
    void versionDecision_shouldReturnUnauthorizedWhenNotLoggedIn() throws Exception {
        mockMvc.perform(post("/api/auth/my-subscriptions/10/version-decision")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"decision\":\"CONFIRM\"}"))
                .andExpect(status().isUnauthorized());

        verify(subscriptionService, never()).decideVersionAction(10L, "CONFIRM");
    }
}
