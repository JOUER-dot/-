package com.finance.roboadvisor.common.util;

import com.finance.roboadvisor.auth.entity.SysUser;
import com.finance.roboadvisor.auth.security.LoginUser;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

public class JwtUtilTest {

    private JwtUtil jwtUtil;

    private static final LoginUser TEST_LOGIN_USER;

    static {
        SysUser user = new SysUser();
        user.setId(1L);
        user.setUsername("testuser");
        user.setStatus(1);
        TEST_LOGIN_USER = new LoginUser(user, List.of("USER", "ADVISOR"));
    }

    @BeforeEach
    void setUp() {
        jwtUtil = new JwtUtil();
        ReflectionTestUtils.setField(jwtUtil, "secret", "test-secret-key-for-jwt-unit-testing-which-is-at-least-256-bits!");
        ReflectionTestUtils.setField(jwtUtil, "expiration", 7200000L);
    }

    @Test
    void testGenerateAndValidateToken() {
        String token = jwtUtil.generateToken(TEST_LOGIN_USER);
        assertNotNull(token);
        assertTrue(token.split("\\.").length == 3);
        assertTrue(jwtUtil.validateToken(token));
    }

    @Test
    void testGetUserIdFromToken() {
        String token = jwtUtil.generateToken(TEST_LOGIN_USER);
        Long userId = jwtUtil.getUserId(token);
        assertEquals(1L, userId);
    }

    @Test
    void testGetRolesFromToken() {
        String token = jwtUtil.generateToken(TEST_LOGIN_USER);
        List<String> roles = jwtUtil.getRoles(token);
        assertTrue(roles.contains("USER"));
        assertTrue(roles.contains("ADVISOR"));
    }

    @Test
    void testValidateExpiredToken() {
        ReflectionTestUtils.setField(jwtUtil, "expiration", -1000L);
        String token = jwtUtil.generateToken(TEST_LOGIN_USER);
        assertFalse(jwtUtil.validateToken(token));
    }

    @Test
    void testValidateMalformedToken() {
        assertFalse(jwtUtil.validateToken("this.is.not.a.valid.jwt"));
    }

    @Test
    void testValidateEmptyToken() {
        assertFalse(jwtUtil.validateToken(""));
    }

    @Test
    void testValidateNullToken() {
        assertFalse(jwtUtil.validateToken(null));
    }

    @Test
    void testValidateTamperedToken() {
        String token = jwtUtil.generateToken(TEST_LOGIN_USER);
        String tampered = token.substring(0, token.lastIndexOf('.')) + ".InVaSiGnAtUrE";
        assertFalse(jwtUtil.validateToken(tampered));
    }
}
