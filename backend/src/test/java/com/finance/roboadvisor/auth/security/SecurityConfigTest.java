package com.finance.roboadvisor.auth.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.context.support.StaticApplicationContext;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.security.config.annotation.ObjectPostProcessor;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.cors.CorsConfigurationSource;

import java.util.HashMap;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.mock;

public class SecurityConfigTest {

    private SecurityConfig securityConfig;

    @BeforeEach
    void setUp() {
        JwtAuthenticationFilter mockFilter = mock(JwtAuthenticationFilter.class);
        ObjectMapper objectMapper = new ObjectMapper();
        securityConfig = new SecurityConfig(mockFilter, objectMapper);
        ReflectionTestUtils.setField(securityConfig, "allowedOrigins", "http://localhost:8080");
    }

    @Test
    void testPasswordEncoder() {
        PasswordEncoder encoder = securityConfig.passwordEncoder();
        assertNotNull(encoder);
        assertTrue(encoder instanceof BCryptPasswordEncoder);
        String encoded = encoder.encode("password");
        assertTrue(encoder.matches("password", encoded));
        assertFalse(encoder.matches("wrong", encoded));
    }

    @Test
    void testPasswordEncoderIsBCrypt() {
        PasswordEncoder encoder = securityConfig.passwordEncoder();
        String raw = "test123";
        String encoded = encoder.encode(raw);
        assertNotEquals(raw, encoded);
        assertTrue(encoded.startsWith("$2a$"));
    }

    @Test
    void testCorsConfigurationSource() {
        CorsConfigurationSource source = securityConfig.corsConfigurationSource();
        assertNotNull(source);

        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setMethod("GET");
        request.setRequestURI("/api/test");
        var corsConfig = source.getCorsConfiguration(request);
        assertNotNull(corsConfig);
        assertTrue(corsConfig.getAllowedOrigins().contains("http://localhost:8080"));
        assertTrue(corsConfig.getAllowedMethods().contains("GET"));
        assertTrue(corsConfig.getAllowedMethods().contains("POST"));
        assertTrue(corsConfig.getAllowedMethods().contains("PUT"));
        assertTrue(corsConfig.getAllowedMethods().contains("DELETE"));
        assertTrue(corsConfig.getAllowedMethods().contains("OPTIONS"));
        assertTrue(corsConfig.getAllowedHeaders().contains("Authorization"));
        assertTrue(corsConfig.getAllowedHeaders().contains("Content-Type"));
        assertTrue(corsConfig.getAllowCredentials());
    }

    @Test
    void testCorsConfigurationWithMultipleOrigins() {
        ReflectionTestUtils.setField(securityConfig, "allowedOrigins", "http://localhost:8080,http://localhost:3000");
        CorsConfigurationSource source = securityConfig.corsConfigurationSource();
        assertNotNull(source);

        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setMethod("POST");
        request.setRequestURI("/api/test");
        var corsConfig = source.getCorsConfiguration(request);
        assertNotNull(corsConfig);
        assertEquals(2, corsConfig.getAllowedOrigins().size());
        assertTrue(corsConfig.getAllowedOrigins().contains("http://localhost:8080"));
        assertTrue(corsConfig.getAllowedOrigins().contains("http://localhost:3000"));
    }

    private HttpSecurity createHttpSecurity() {
        ObjectPostProcessor<Object> opp = new ObjectPostProcessor<>() {
            @Override
            public <O> O postProcess(O o) { return o; }
        };
        AuthenticationManagerBuilder authBuilder = new AuthenticationManagerBuilder(opp);
        HttpSecurity http = new HttpSecurity(opp, authBuilder, new HashMap<>());
        StaticApplicationContext ctx = new StaticApplicationContext();
        http.setSharedObject(org.springframework.context.ApplicationContext.class, ctx);
        return http;
    }

    @Test
    void testSecurityFilterChain() throws Exception {
        HttpSecurity http = createHttpSecurity();
        SecurityFilterChain filterChain = securityConfig.securityFilterChain(http);
        assertNotNull(filterChain);
    }

    @Test
    void testSecurityFilterChainMatchesRequests() throws Exception {
        HttpSecurity http = createHttpSecurity();
        SecurityFilterChain filterChain = securityConfig.securityFilterChain(http);
        assertNotNull(filterChain);
        assertNotNull(filterChain.getFilters());
    }
}
