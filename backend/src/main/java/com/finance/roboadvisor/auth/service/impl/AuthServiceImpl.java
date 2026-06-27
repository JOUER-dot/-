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
import com.finance.roboadvisor.auth.service.AuthService;
import com.finance.roboadvisor.auth.vo.CurrentUserVO;
import com.finance.roboadvisor.auth.vo.LoginUserInfoVO;
import com.finance.roboadvisor.auth.vo.LoginVO;
import com.finance.roboadvisor.common.api.ResultCode;
import com.finance.roboadvisor.common.enums.RoleCodeEnum;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.common.util.JwtUtil;
import com.finance.roboadvisor.common.util.SecurityUtil;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.subscription.mapper.SubscriptionMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
public class AuthServiceImpl implements AuthService {

    private final UserMapper userMapper;
    private final RoleMapper roleMapper;
    private final UserRoleMapper userRoleMapper;
    private final UserDetailsServiceImpl userDetailsService;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final ProductMapper productMapper;
    private final SubscriptionMapper subscriptionMapper;

    @Value("${jwt.token-head}")
    private String tokenHead;

    public AuthServiceImpl(UserMapper userMapper,
                           RoleMapper roleMapper,
                           UserRoleMapper userRoleMapper,
                           UserDetailsServiceImpl userDetailsService,
                           PasswordEncoder passwordEncoder,
                           JwtUtil jwtUtil,
                           ProductMapper productMapper,
                           SubscriptionMapper subscriptionMapper) {
        this.userMapper = userMapper;
        this.roleMapper = roleMapper;
        this.userRoleMapper = userRoleMapper;
        this.userDetailsService = userDetailsService;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.productMapper = productMapper;
        this.subscriptionMapper = subscriptionMapper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void register(RegisterDTO registerDTO) {
        if (!registerDTO.getPassword().equals(registerDTO.getConfirmPassword())) {
            throw new BusinessException(ResultCode.PASSWORD_NOT_MATCH);
        }
        if (userMapper.countByUsername(registerDTO.getUsername()) > 0) {
            throw new BusinessException(ResultCode.USERNAME_EXISTS);
        }
        if (StringUtils.hasText(registerDTO.getPhone()) && userMapper.countByPhone(registerDTO.getPhone()) > 0) {
            throw new BusinessException(ResultCode.PHONE_EXISTS);
        }

        SysRole userRole = roleMapper.selectByRoleCode(RoleCodeEnum.USER.name());
        if (userRole == null || userRole.getStatus() == null || userRole.getStatus() != 1) {
            throw new BusinessException(ResultCode.SYSTEM_ERROR, "USER角色未初始化");
        }

        SysUser user = new SysUser();
        user.setUsername(registerDTO.getUsername());
        user.setPasswordHash(passwordEncoder.encode(registerDTO.getPassword()));
        user.setNickname(registerDTO.getNickname());
        user.setPhone(StringUtils.hasText(registerDTO.getPhone()) ? registerDTO.getPhone() : null);
        user.setStatus(1);
        userMapper.insert(user);

        SysUserRole userRoleRelation = new SysUserRole();
        userRoleRelation.setUserId(user.getId());
        userRoleRelation.setRoleId(userRole.getId());
        userRoleMapper.insert(userRoleRelation);
    }

    @Override
    public LoginVO login(LoginDTO loginDTO) {
        SysUser user = userMapper.selectByUsername(loginDTO.getUsername());
        if (user == null) {
            throw new BusinessException(ResultCode.USERNAME_OR_PASSWORD_ERROR);
        }
        if (user.getStatus() == null || user.getStatus() != 1) {
            throw new BusinessException(ResultCode.FORBIDDEN, "用户已被禁用");
        }
        if (!passwordEncoder.matches(loginDTO.getPassword(), user.getPasswordHash())) {
            throw new BusinessException(ResultCode.USERNAME_OR_PASSWORD_ERROR);
        }

        LoginUser loginUser = userDetailsService.loadUserById(user.getId());
        String token = jwtUtil.generateToken(loginUser);

        LoginUserInfoVO userInfo = new LoginUserInfoVO();
        userInfo.setId(user.getId());
        userInfo.setUsername(user.getUsername());
        userInfo.setNickname(user.getNickname());

        LoginVO loginVO = new LoginVO();
        loginVO.setToken(token);
        loginVO.setTokenHead(tokenHead);
        loginVO.setUserInfo(userInfo);
        loginVO.setRoles(loginUser.getRoles());
        return loginVO;
    }

    @Override
    public CurrentUserVO getCurrentUser() {
        Long userId = SecurityUtil.getCurrentUserId();
        SysUser user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }
        List<String> roles = roleMapper.selectRolesByUserId(userId)
                .stream()
                .map(SysRole::getRoleCode)
                .toList();
        CurrentUserVO currentUserVO = new CurrentUserVO();
        currentUserVO.setId(user.getId());
        currentUserVO.setUsername(user.getUsername());
        currentUserVO.setNickname(user.getNickname());
        currentUserVO.setPhone(user.getPhone());
        currentUserVO.setEmail(user.getEmail());
        currentUserVO.setRoles(roles);
        return currentUserVO;
    }

    @Override
    public void logout() {
        SecurityUtil.getCurrentUserId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void changePassword(ChangePasswordDTO dto) {
        Long userId = SecurityUtil.getCurrentUserId();
        SysUser user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }
        if (!passwordEncoder.matches(dto.getOldPassword(), user.getPasswordHash())) {
            throw new BusinessException(ResultCode.VALIDATE_FAILED, "旧密码不正确");
        }
        if (!dto.getNewPassword().equals(dto.getConfirmPassword())) {
            throw new BusinessException(ResultCode.PASSWORD_NOT_MATCH);
        }
        userMapper.updatePassword(userId, passwordEncoder.encode(dto.getNewPassword()));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateProfile(UpdateProfileDTO dto) {
        Long userId = SecurityUtil.getCurrentUserId();
        SysUser user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }
        if (StringUtils.hasText(dto.getNickname())) {
            user.setNickname(dto.getNickname());
        }
        if (StringUtils.hasText(dto.getPhone())) {
            user.setPhone(dto.getPhone());
        }
        if (dto.getEmail() != null) {
            user.setEmail(dto.getEmail());
        }
        userMapper.updateProfile(user);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteAccount() {
        Long userId = SecurityUtil.getCurrentUserId();
        List<String> roles = roleMapper.selectRolesByUserId(userId)
                .stream().map(SysRole::getRoleCode).toList();

        // 投顾有已上架产品不能注销
        if (roles.contains("ADVISOR")) {
            Long publishedCount = productMapper.countByCreator(userId, "PUBLISHED", null, null, null);
            if (publishedCount != null && publishedCount > 0) {
                throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "您有已上架产品，请先下架所有产品后再注销");
            }
        }
        // 管理员不能注销
        if (roles.contains("ADMIN")) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "管理员账号无法自行注销");
        }
        // 取消所有订阅
        subscriptionMapper.cancelByUserId(userId);
        // 禁用账号
        userMapper.updateStatus(userId, 0);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void setPin(String pin) {
        Long userId = SecurityUtil.getCurrentUserId();
        SysUser user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }
        if (user.getSubPin() != null && !user.getSubPin().isEmpty()) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "交易密码已设置，不可修改");
        }
        if (pin == null || !pin.matches("\\d{6}")) {
            throw new BusinessException(ResultCode.VALIDATE_FAILED, "交易密码必须为6位数字");
        }
        userMapper.updatePin(userId, passwordEncoder.encode(pin));
    }

    @Override
    public void verifyPassword(String password) {
        Long userId = SecurityUtil.getCurrentUserId();
        SysUser user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }
        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            throw new BusinessException(ResultCode.VALIDATE_FAILED, "密码错误");
        }
    }
}
