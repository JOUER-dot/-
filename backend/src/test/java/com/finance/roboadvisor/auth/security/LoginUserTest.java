package com.finance.roboadvisor.auth.security;

import com.finance.roboadvisor.auth.entity.SysUser;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

public class LoginUserTest {

    private SysUser sysUser;
    private LoginUser loginUser;

    @BeforeEach
    void setUp() {
        sysUser = new SysUser();
        sysUser.setId(1L);
        sysUser.setUsername("testuser");
        sysUser.setPasswordHash("hashedpassword");
        sysUser.setStatus(1);
        loginUser = new LoginUser(sysUser, List.of("USER", "ADVISOR"));
    }

    @Test
    void testGetId() {
        assertEquals(1L, loginUser.getId());
    }

    @Test
    void testGetRoles() {
        List<String> roles = loginUser.getRoles();
        assertEquals(2, roles.size());
        assertTrue(roles.contains("USER"));
        assertTrue(roles.contains("ADVISOR"));
    }

    @Test
    void testGetUser() {
        assertSame(sysUser, loginUser.getUser());
    }

    @Test
    void testGetAuthorities() {
        var authorities = loginUser.getAuthorities();
        assertEquals(2, authorities.size());
        assertTrue(authorities.stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_USER")));
        assertTrue(authorities.stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADVISOR")));
    }

    @Test
    void testGetAuthoritiesEmptyRoles() {
        LoginUser emptyRolesUser = new LoginUser(sysUser, List.of());
        assertTrue(emptyRolesUser.getAuthorities().isEmpty());
    }

    @Test
    void testGetPassword() {
        assertEquals("hashedpassword", loginUser.getPassword());
    }

    @Test
    void testGetUsername() {
        assertEquals("testuser", loginUser.getUsername());
    }

    @Test
    void testIsAccountNonExpired() {
        assertTrue(loginUser.isAccountNonExpired());
    }

    @Test
    void testIsAccountNonLocked() {
        assertTrue(loginUser.isAccountNonLocked());
    }

    @Test
    void testIsCredentialsNonExpired() {
        assertTrue(loginUser.isCredentialsNonExpired());
    }

    @Test
    void testIsEnabledWhenStatusIsOne() {
        assertTrue(loginUser.isEnabled());
    }

    @Test
    void testIsDisabledWhenStatusIsZero() {
        sysUser.setStatus(0);
        assertFalse(loginUser.isEnabled());
    }

    @Test
    void testIsDisabledWhenStatusIsNull() {
        sysUser.setStatus(null);
        assertFalse(loginUser.isEnabled());
    }

    @Test
    void testIsEnabledWhenStatusIsTwo() {
        sysUser.setStatus(2);
        assertFalse(loginUser.isEnabled());
    }
}
