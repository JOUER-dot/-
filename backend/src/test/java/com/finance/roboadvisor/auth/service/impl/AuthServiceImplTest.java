package com.finance.roboadvisor.auth.service.impl;

import com.finance.roboadvisor.auth.dto.ChangePasswordDTO;
import com.finance.roboadvisor.auth.dto.LoginDTO;
import com.finance.roboadvisor.auth.dto.RegisterDTO;
import com.finance.roboadvisor.auth.dto.UpdateProfileDTO;
import com.finance.roboadvisor.auth.entity.SysRole;
import com.finance.roboadvisor.auth.entity.SysUser;
import com.finance.roboadvisor.auth.entity.SysUserRole;
import com.finance.roboadvisor.auth.mapper.RoleMapper;
import com.finance.roboadvisor.auth.mapper.UserMapper;
import com.finance.roboadvisor.auth.mapper.UserRoleMapper;
import com.finance.roboadvisor.auth.security.LoginUser;
import com.finance.roboadvisor.auth.security.UserDetailsServiceImpl;
import com.finance.roboadvisor.auth.vo.CurrentUserVO;
import com.finance.roboadvisor.auth.vo.LoginVO;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.common.util.JwtUtil;
import com.finance.roboadvisor.common.util.SecurityUtil;
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
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class AuthServiceImplTest {

    @Mock private UserMapper userMapper;
    @Mock private RoleMapper roleMapper;
    @Mock private UserRoleMapper userRoleMapper;
    @Mock private UserDetailsServiceImpl userDetailsService;
    @Mock private PasswordEncoder passwordEncoder;
    @Mock private JwtUtil jwtUtil;
    @Mock private ProductMapper productMapper;
    @Mock private SubscriptionMapper subscriptionMapper;

    @InjectMocks
    private AuthServiceImpl authService;

    private static final SysUser TEST_USER = new SysUser();
    private static final SysRole USER_ROLE = new SysRole();

    @BeforeEach
    void setUp() {
        TEST_USER.setId(1L);
        TEST_USER.setUsername("testuser");
        TEST_USER.setNickname("TestUser");
        TEST_USER.setPasswordHash("encoded-password");
        TEST_USER.setPhone("13800138000");
        TEST_USER.setStatus(1);

        USER_ROLE.setId(10L);
        USER_ROLE.setRoleCode("USER");
        USER_ROLE.setRoleName("普通用户");
        USER_ROLE.setStatus(1);

        // Mock SecurityContext for methods that require authentication
        SysUser sysUser = new SysUser();
        sysUser.setId(1L);
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

    // ===================== register =====================

    @Test
    void testRegisterSuccess() {
        RegisterDTO dto = new RegisterDTO();
        dto.setUsername("newuser");
        dto.setPassword("password123");
        dto.setConfirmPassword("password123");
        dto.setNickname("NewUser");

        when(userMapper.countByUsername("newuser")).thenReturn(0);
        when(roleMapper.selectByRoleCode("USER")).thenReturn(USER_ROLE);
        when(passwordEncoder.encode("password123")).thenReturn("encoded-password");

        authService.register(dto);

        verify(userMapper).insert(any(SysUser.class));
        verify(userRoleMapper).insert(any(SysUserRole.class));
    }

    @Test
    void testRegisterPasswordNotMatch() {
        RegisterDTO dto = new RegisterDTO();
        dto.setUsername("user1");
        dto.setPassword("password123");
        dto.setConfirmPassword("different");

        BusinessException ex = assertThrows(BusinessException.class, () -> authService.register(dto));
        assertEquals(40003, ex.getCode().intValue());
    }

    @Test
    void testRegisterUsernameExists() {
        RegisterDTO dto = new RegisterDTO();
        dto.setUsername("existing");
        dto.setPassword("password123");
        dto.setConfirmPassword("password123");

        when(userMapper.countByUsername("existing")).thenReturn(1);

        BusinessException ex = assertThrows(BusinessException.class, () -> authService.register(dto));
        assertEquals(40903, ex.getCode().intValue());
    }

    @Test
    void testRegisterPhoneExists() {
        RegisterDTO dto = new RegisterDTO();
        dto.setUsername("newuser");
        dto.setPassword("password123");
        dto.setConfirmPassword("password123");
        dto.setPhone("13800138000");

        when(userMapper.countByUsername("newuser")).thenReturn(0);
        when(userMapper.countByPhone("13800138000")).thenReturn(1);

        BusinessException ex = assertThrows(BusinessException.class, () -> authService.register(dto));
        assertEquals(40904, ex.getCode().intValue());
    }

    @Test
    void testRegisterRoleNotFound() {
        RegisterDTO dto = new RegisterDTO();
        dto.setUsername("newuser");
        dto.setPassword("password123");
        dto.setConfirmPassword("password123");

        when(userMapper.countByUsername("newuser")).thenReturn(0);
        when(roleMapper.selectByRoleCode("USER")).thenReturn(null);

        BusinessException ex = assertThrows(BusinessException.class, () -> authService.register(dto));
        assertEquals(50000, ex.getCode().intValue());
    }

    // ===================== login =====================

    @Test
    void testLoginSuccess() {
        LoginDTO dto = new LoginDTO();
        dto.setUsername("testuser");
        dto.setPassword("password123");

        when(userMapper.selectByUsername("testuser")).thenReturn(TEST_USER);
        when(passwordEncoder.matches("password123", "encoded-password")).thenReturn(true);

        LoginUser loginUser = new LoginUser(TEST_USER, List.of("USER"));
        when(userDetailsService.loadUserById(1L)).thenReturn(loginUser);
        when(jwtUtil.generateToken(loginUser)).thenReturn("test-jwt-token");

        ReflectionTestUtils.setField(authService, "tokenHead", "Bearer ");

        LoginVO result = authService.login(dto);

        assertNotNull(result);
        assertEquals("test-jwt-token", result.getToken());
        assertEquals("Bearer ", result.getTokenHead());
        assertEquals("testuser", result.getUserInfo().getUsername());
        assertTrue(result.getRoles().contains("USER"));
    }

    @Test
    void testLoginUserNotFound() {
        LoginDTO dto = new LoginDTO();
        dto.setUsername("nonexistent");
        dto.setPassword("password123");

        when(userMapper.selectByUsername("nonexistent")).thenReturn(null);

        BusinessException ex = assertThrows(BusinessException.class, () -> authService.login(dto));
        assertEquals(40102, ex.getCode().intValue());
    }

    @Test
    void testLoginUserDisabled() {
        LoginDTO dto = new LoginDTO();
        dto.setUsername("disableduser");
        dto.setPassword("password123");

        SysUser disabledUser = new SysUser();
        disabledUser.setUsername("disableduser");
        disabledUser.setPasswordHash("encoded");
        disabledUser.setStatus(0);

        when(userMapper.selectByUsername("disableduser")).thenReturn(disabledUser);

        BusinessException ex = assertThrows(BusinessException.class, () -> authService.login(dto));
        assertEquals(40301, ex.getCode().intValue());
    }

    @Test
    void testLoginWrongPassword() {
        LoginDTO dto = new LoginDTO();
        dto.setUsername("testuser");
        dto.setPassword("wrongpassword");

        when(userMapper.selectByUsername("testuser")).thenReturn(TEST_USER);
        when(passwordEncoder.matches("wrongpassword", "encoded-password")).thenReturn(false);

        BusinessException ex = assertThrows(BusinessException.class, () -> authService.login(dto));
        assertEquals(40102, ex.getCode().intValue());
    }

    // ===================== getCurrentUser =====================

    @Test
    void testGetCurrentUserSuccess() {
        when(userMapper.selectById(1L)).thenReturn(TEST_USER);

        SysRole role = new SysRole();
        role.setRoleCode("USER");
        when(roleMapper.selectRolesByUserId(1L)).thenReturn(List.of(role));

        CurrentUserVO result = authService.getCurrentUser();

        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals("testuser", result.getUsername());
        assertEquals("13800138000", result.getPhone());
        assertTrue(result.getRoles().contains("USER"));
    }

    @Test
    void testGetCurrentUserNotFound() {
        when(userMapper.selectById(1L)).thenReturn(null);

        assertThrows(BusinessException.class, () -> authService.getCurrentUser());
    }

    // ===================== logout =====================

    @Test
    void testLogoutSuccess() {
        assertDoesNotThrow(() -> authService.logout());
    }

    // ===================== changePassword =====================

    @Test
    void testChangePasswordSuccess() {
        ChangePasswordDTO dto = new ChangePasswordDTO();
        dto.setOldPassword("oldPass");
        dto.setNewPassword("newPass123");
        dto.setConfirmPassword("newPass123");

        when(userMapper.selectById(1L)).thenReturn(TEST_USER);
        when(passwordEncoder.matches("oldPass", "encoded-password")).thenReturn(true);
        when(passwordEncoder.encode("newPass123")).thenReturn("new-encoded");

        authService.changePassword(dto);

        verify(userMapper).updatePassword(1L, "new-encoded");
    }

    @Test
    void testChangePasswordWrongOldPassword() {
        ChangePasswordDTO dto = new ChangePasswordDTO();
        dto.setOldPassword("wrongOld");
        dto.setNewPassword("newPass123");
        dto.setConfirmPassword("newPass123");

        when(userMapper.selectById(1L)).thenReturn(TEST_USER);
        when(passwordEncoder.matches("wrongOld", "encoded-password")).thenReturn(false);

        assertThrows(BusinessException.class, () -> authService.changePassword(dto));
    }

    @Test
    void testChangePasswordConfirmNotMatch() {
        ChangePasswordDTO dto = new ChangePasswordDTO();
        dto.setOldPassword("oldPass");
        dto.setNewPassword("newPass123");
        dto.setConfirmPassword("different");

        when(userMapper.selectById(1L)).thenReturn(TEST_USER);
        when(passwordEncoder.matches("oldPass", "encoded-password")).thenReturn(true);

        assertThrows(BusinessException.class, () -> authService.changePassword(dto));
    }

    // ===================== updateProfile =====================

    @Test
    void testUpdateProfileSuccess() {
        UpdateProfileDTO dto = new UpdateProfileDTO();
        dto.setNickname("NewNick");
        dto.setPhone("13900139000");
        dto.setEmail("new@email.com");

        when(userMapper.selectById(1L)).thenReturn(TEST_USER);

        authService.updateProfile(dto);

        verify(userMapper).updateProfile(argThat(user ->
                "NewNick".equals(user.getNickname()) &&
                "13900139000".equals(user.getPhone()) &&
                "new@email.com".equals(user.getEmail())
        ));
    }

    @Test
    void testUpdateProfileUserNotFound() {
        when(userMapper.selectById(1L)).thenReturn(null);

        assertThrows(BusinessException.class, () -> authService.updateProfile(new UpdateProfileDTO()));
    }

    // ===================== deleteAccount =====================

    @Test
    void testDeleteAccountSuccess() {
        SysRole role = new SysRole();
        role.setRoleCode("USER");
        when(roleMapper.selectRolesByUserId(1L)).thenReturn(List.of(role));

        authService.deleteAccount();

        verify(subscriptionMapper).cancelByUserId(1L);
        verify(userMapper).updateStatus(1L, 0);
    }

    @Test
    void testDeleteAccountAdvisorWithPublishedProducts() {
        SysRole role = new SysRole();
        role.setRoleCode("ADVISOR");
        when(roleMapper.selectRolesByUserId(1L)).thenReturn(List.of(role));
        when(productMapper.countByCreator(1L, "PUBLISHED", null, null, null)).thenReturn(1L);

        BusinessException ex = assertThrows(BusinessException.class, () -> authService.deleteAccount());
        assertTrue(ex.getMessage().contains("已上架产品"));
    }

    @Test
    void testDeleteAccountAdmin() {
        SysRole role = new SysRole();
        role.setRoleCode("ADMIN");
        when(roleMapper.selectRolesByUserId(1L)).thenReturn(List.of(role));

        BusinessException ex = assertThrows(BusinessException.class, () -> authService.deleteAccount());
        assertTrue(ex.getMessage().contains("管理员"));
    }

    // ===================== setPin =====================

    @Test
    void testSetPinSuccess() {
        TEST_USER.setSubPin(null);
        when(userMapper.selectById(1L)).thenReturn(TEST_USER);
        when(passwordEncoder.encode("123456")).thenReturn("encoded-pin");

        authService.setPin("123456");

        verify(userMapper).updatePin(1L, "encoded-pin");
    }

    @Test
    void testSetPinAlreadySet() {
        TEST_USER.setSubPin("existing-pin");
        when(userMapper.selectById(1L)).thenReturn(TEST_USER);

        assertThrows(BusinessException.class, () -> authService.setPin("123456"));
    }

    @Test
    void testSetPinInvalidFormat() {
        TEST_USER.setSubPin(null);
        when(userMapper.selectById(1L)).thenReturn(TEST_USER);

        assertThrows(BusinessException.class, () -> authService.setPin("abc"));
    }

    // ===================== verifyPassword =====================

    @Test
    void testVerifyPasswordSuccess() {
        when(userMapper.selectById(1L)).thenReturn(TEST_USER);
        when(passwordEncoder.matches("correctPass", "encoded-password")).thenReturn(true);

        assertDoesNotThrow(() -> authService.verifyPassword("correctPass"));
    }

    @Test
    void testVerifyPasswordWrong() {
        when(userMapper.selectById(1L)).thenReturn(TEST_USER);
        when(passwordEncoder.matches("wrongPass", "encoded-password")).thenReturn(false);

        assertThrows(BusinessException.class, () -> authService.verifyPassword("wrongPass"));
    }

    @Test
    void testVerifyPasswordUserNotFound() {
        when(userMapper.selectById(1L)).thenReturn(null);

        assertThrows(BusinessException.class, () -> authService.verifyPassword("pass"));
    }
}
