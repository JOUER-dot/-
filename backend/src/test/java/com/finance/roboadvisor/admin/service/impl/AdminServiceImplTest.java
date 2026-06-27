package com.finance.roboadvisor.admin.service.impl;

import com.finance.roboadvisor.admin.vo.AdminDashboardVO;
import com.finance.roboadvisor.admin.vo.AdminUserVO;
import com.finance.roboadvisor.auth.entity.SysRole;
import com.finance.roboadvisor.auth.entity.SysUser;
import com.finance.roboadvisor.auth.entity.SysUserRole;
import com.finance.roboadvisor.auth.mapper.RoleMapper;
import com.finance.roboadvisor.auth.mapper.UserMapper;
import com.finance.roboadvisor.auth.mapper.UserRoleMapper;
import com.finance.roboadvisor.auth.security.LoginUser;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.product.entity.AdvisorProductFlowLog;
import com.finance.roboadvisor.product.mapper.ProductFlowLogMapper;
import com.finance.roboadvisor.product.mapper.ProductMapper;
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
public class AdminServiceImplTest {

    @Mock private UserMapper userMapper;
    @Mock private RoleMapper roleMapper;
    @Mock private UserRoleMapper userRoleMapper;
    @Mock private ProductMapper productMapper;
    @Mock private ProductFlowLogMapper productFlowLogMapper;
    @Mock private SubscriptionMapper subscriptionMapper;

    @InjectMocks
    private AdminServiceImpl adminService;

    @BeforeEach
    void setUp() {
        SysUser sysUser = new SysUser();
        sysUser.setId(1L);
        sysUser.setUsername("admin");
        sysUser.setStatus(1);
        LoginUser loginUser = new LoginUser(sysUser, List.of("ADMIN"));
        Authentication auth = new UsernamePasswordAuthenticationToken(loginUser, null, loginUser.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(auth);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    // ===================== getDashboard =====================

    @Test
    void testGetDashboard() {
        when(productMapper.countAll()).thenReturn(50L);
        when(productMapper.countByStatus("PUBLISHED")).thenReturn(20L);
        when(productMapper.countByStatus("PENDING_REVIEW")).thenReturn(5L);
        when(roleMapper.countUsersByRoleCode("ADVISOR")).thenReturn(8L);
        when(roleMapper.countUsersByRoleCode("USER")).thenReturn(100L);
        when(subscriptionMapper.countAll()).thenReturn(200L);
        when(productFlowLogMapper.selectRecent(10)).thenReturn(List.of());
        when(subscriptionMapper.selectTopSubscribed(10)).thenReturn(List.of());

        AdminDashboardVO result = adminService.getDashboard();

        assertEquals(50L, result.getTotalProducts());
        assertEquals(20L, result.getPublishedProducts());
        assertEquals(5L, result.getPendingReviewProducts());
        assertEquals(8L, result.getTotalAdvisors());
        assertEquals(100L, result.getTotalUsers());
        assertEquals(200L, result.getTotalSubscriptions());
        assertTrue(result.getRecentChanges().isEmpty());
        assertTrue(result.getTopSubscribedProducts().isEmpty());
    }

    @Test
    void testGetDashboardWithNullLists() {
        when(productMapper.countAll()).thenReturn(0L);
        when(productMapper.countByStatus("PUBLISHED")).thenReturn(0L);
        when(productMapper.countByStatus("PENDING_REVIEW")).thenReturn(0L);
        when(roleMapper.countUsersByRoleCode("ADVISOR")).thenReturn(0L);
        when(roleMapper.countUsersByRoleCode("USER")).thenReturn(0L);
        when(subscriptionMapper.countAll()).thenReturn(0L);
        when(productFlowLogMapper.selectRecent(10)).thenReturn(null);
        when(subscriptionMapper.selectTopSubscribed(10)).thenReturn(null);

        AdminDashboardVO result = adminService.getDashboard();

        assertTrue(result.getRecentChanges().isEmpty());
        assertTrue(result.getTopSubscribedProducts().isEmpty());
    }

    // ===================== getAdvisorDashboard =====================

    @Test
    void testGetAdvisorDashboard() {
        when(productMapper.countByCreator(1L, null, null, null, null)).thenReturn(10L);
        when(productMapper.countByCreator(1L, "PUBLISHED", null, null, null)).thenReturn(5L);
        when(productMapper.countByCreator(1L, "PENDING_REVIEW", null, null, null)).thenReturn(2L);
        when(productFlowLogMapper.selectRecentByOperator(1L, 10)).thenReturn(List.of());

        AdminDashboardVO result = adminService.getAdvisorDashboard();

        assertEquals(10L, result.getTotalProducts());
        assertEquals(5L, result.getPublishedProducts());
        assertEquals(2L, result.getPendingReviewProducts());
    }

    // ===================== listUsers =====================

    @Test
    void testListUsers() {
        SysUser user1 = new SysUser();
        user1.setId(1L);
        user1.setUsername("user1");
        user1.setNickname("用户一");
        user1.setPhone("13800000001");
        user1.setStatus(1);
        user1.setCreatedAt(LocalDateTime.now());

        SysUser user2 = new SysUser();
        user2.setId(2L);
        user2.setUsername("user2");
        user2.setNickname("用户二");
        user2.setStatus(1);

        when(userMapper.selectAll()).thenReturn(List.of(user1, user2));

        SysRole role1 = new SysRole();
        role1.setRoleCode("USER");
        SysRole role2 = new SysRole();
        role2.setRoleCode("ADVISOR");
        when(roleMapper.selectRolesByUserId(1L)).thenReturn(List.of(role1));
        when(roleMapper.selectRolesByUserId(2L)).thenReturn(List.of(role1, role2));

        List<AdminUserVO> result = adminService.listUsers();

        assertEquals(2, result.size());
        assertEquals("user1", result.get(0).getUsername());
        assertEquals(1, result.get(0).getRoles().size());
        assertEquals(2, result.get(1).getRoles().size());
    }

    // ===================== toggleUserStatus =====================

    @Test
    void testToggleUserStatusEnabled() {
        adminService.toggleUserStatus(1L, true);
        verify(userMapper).updateStatus(1L, 1);
    }

    @Test
    void testToggleUserStatusDisabled() {
        adminService.toggleUserStatus(2L, false);
        verify(userMapper).updateStatus(2L, 0);
    }

    // ===================== assignRole =====================

    @Test
    void testAssignRoleSuccess() {
        SysUser user = new SysUser();
        user.setId(1L);
        user.setUsername("target");
        when(userMapper.selectById(1L)).thenReturn(user);

        SysRole role = new SysRole();
        role.setId(10L);
        role.setRoleCode("REVIEWER");
        when(roleMapper.selectByRoleCode("REVIEWER")).thenReturn(role);

        adminService.assignRole(1L, "REVIEWER");

        verify(userRoleMapper).deleteByUserId(1L);
        verify(userRoleMapper).insert(any(SysUserRole.class));
    }

    @Test
    void testAssignRoleUserNotFound() {
        when(userMapper.selectById(999L)).thenReturn(null);

        assertThrows(BusinessException.class, () -> adminService.assignRole(999L, "USER"));
    }

    @Test
    void testAssignRoleNotFound() {
        SysUser user = new SysUser();
        user.setId(1L);
        when(userMapper.selectById(1L)).thenReturn(user);
        when(roleMapper.selectByRoleCode("NONEXIST")).thenReturn(null);

        assertThrows(BusinessException.class, () -> adminService.assignRole(1L, "NONEXIST"));
    }
}
