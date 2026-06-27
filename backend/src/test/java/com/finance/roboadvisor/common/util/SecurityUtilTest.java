package com.finance.roboadvisor.common.util;

import com.finance.roboadvisor.auth.entity.SysUser;
import com.finance.roboadvisor.auth.security.LoginUser;
import com.finance.roboadvisor.common.exception.BusinessException;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

public class SecurityUtilTest {

    private static final SysUser TEST_USER = new SysUser();
    private static final Long TEST_USER_ID = 100L;

    @BeforeEach
    void setUp() {
        TEST_USER.setId(TEST_USER_ID);
        TEST_USER.setUsername("testuser");
        TEST_USER.setStatus(1);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void testGetCurrentUserIdSuccess() {
        LoginUser loginUser = new LoginUser(TEST_USER, List.of("USER"));
        Authentication auth = new UsernamePasswordAuthenticationToken(loginUser, null, loginUser.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(auth);

        assertEquals(TEST_USER_ID, SecurityUtil.getCurrentUserId());
    }

    @Test
    void testGetCurrentUserIdNotAuthenticated() {
        SecurityContextHolder.getContext().setAuthentication(null);
        assertThrows(BusinessException.class, SecurityUtil::getCurrentUserId);
    }

    @Test
    void testGetCurrentUserIdAnonymous() {
        Authentication anonymous = new AnonymousAuthenticationToken(
                "key", "anonymous", List.of(new SimpleGrantedAuthority("ROLE_ANONYMOUS"))
        );
        SecurityContextHolder.getContext().setAuthentication(anonymous);
        assertThrows(BusinessException.class, SecurityUtil::getCurrentUserId);
    }

    @Test
    void testGetCurrentUserIdWrongPrincipalType() {
        Authentication auth = new UsernamePasswordAuthenticationToken("notALoginUser", null, List.of());
        SecurityContextHolder.getContext().setAuthentication(auth);
        assertThrows(BusinessException.class, SecurityUtil::getCurrentUserId);
    }

    @Test
    void testGetLoginUserSuccess() {
        LoginUser loginUser = new LoginUser(TEST_USER, List.of("ADVISOR"));
        Authentication auth = new UsernamePasswordAuthenticationToken(loginUser, null, loginUser.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(auth);

        LoginUser result = SecurityUtil.getLoginUser();
        assertEquals(TEST_USER_ID, result.getId());
        assertTrue(result.getRoles().contains("ADVISOR"));
    }
}
