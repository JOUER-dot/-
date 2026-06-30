package com.finance.roboadvisor.auth.security;

import com.finance.roboadvisor.auth.entity.SysRole;
import com.finance.roboadvisor.auth.entity.SysUser;
import com.finance.roboadvisor.auth.mapper.RoleMapper;
import com.finance.roboadvisor.auth.mapper.UserMapper;
import com.finance.roboadvisor.common.exception.BusinessException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class UserDetailsServiceImplTest {

    @Mock private UserMapper userMapper;
    @Mock private RoleMapper roleMapper;

    @InjectMocks
    private UserDetailsServiceImpl userDetailsService;

    @Test
    void testLoadUserByUsernameSuccess() {
        SysUser user = new SysUser();
        user.setId(1L);
        user.setUsername("testuser");
        user.setNickname("Test");
        user.setPasswordHash("encoded");
        user.setStatus(1);
        when(userMapper.selectByUsername("testuser")).thenReturn(user);

        SysRole role = new SysRole();
        role.setRoleCode("USER");
        when(roleMapper.selectRolesByUserId(1L)).thenReturn(List.of(role));

        LoginUser loginUser = (LoginUser) userDetailsService.loadUserByUsername("testuser");

        assertEquals(1L, loginUser.getId());
        assertEquals("testuser", loginUser.getUsername());
        assertTrue(loginUser.getRoles().contains("USER"));
        assertTrue(loginUser.isEnabled());
    }

    @Test
    void testLoadUserByUsernameNotFound() {
        when(userMapper.selectByUsername("nonexistent")).thenReturn(null);

        assertThrows(UsernameNotFoundException.class,
                () -> userDetailsService.loadUserByUsername("nonexistent"));
    }

    @Test
    void testLoadUserByIdSuccess() {
        SysUser user = new SysUser();
        user.setId(2L);
        user.setUsername("user2");
        user.setNickname("User2");
        user.setPasswordHash("pwd");
        user.setStatus(1);
        when(userMapper.selectById(2L)).thenReturn(user);

        SysRole role = new SysRole();
        role.setRoleCode("ADVISOR");
        when(roleMapper.selectRolesByUserId(2L)).thenReturn(List.of(role));

        LoginUser loginUser = userDetailsService.loadUserById(2L);

        assertEquals(2L, loginUser.getId());
        assertTrue(loginUser.getRoles().contains("ADVISOR"));
    }

    @Test
    void testLoadUserByIdNotFound() {
        when(userMapper.selectById(999L)).thenReturn(null);

        assertThrows(BusinessException.class,
                () -> userDetailsService.loadUserById(999L));
    }

    @Test
    void testUserWithDisabledStatus() {
        SysUser user = new SysUser();
        user.setId(3L);
        user.setUsername("disabled");
        user.setPasswordHash("pwd");
        user.setStatus(0);
        when(userMapper.selectByUsername("disabled")).thenReturn(user);

        SysRole role = new SysRole();
        role.setRoleCode("USER");
        when(roleMapper.selectRolesByUserId(3L)).thenReturn(List.of(role));

        LoginUser loginUser = (LoginUser) userDetailsService.loadUserByUsername("disabled");

        assertFalse(loginUser.isEnabled());
    }

    @Test
    void testUserWithMultipleRoles() {
        SysUser user = new SysUser();
        user.setId(4L);
        user.setUsername("multi");
        user.setPasswordHash("pwd");
        user.setStatus(1);
        when(userMapper.selectById(4L)).thenReturn(user);

        SysRole role1 = new SysRole();
        role1.setRoleCode("USER");
        SysRole role2 = new SysRole();
        role2.setRoleCode("ADVISOR");
        when(roleMapper.selectRolesByUserId(4L)).thenReturn(List.of(role1, role2));

        LoginUser loginUser = userDetailsService.loadUserById(4L);

        assertEquals(2, loginUser.getRoles().size());
        assertTrue(loginUser.getRoles().contains("USER"));
        assertTrue(loginUser.getRoles().contains("ADVISOR"));
    }
}
