package com.finance.roboadvisor.admin.service.impl;

import com.finance.roboadvisor.admin.service.AdminService;
import com.finance.roboadvisor.admin.vo.AdminDashboardVO;
import com.finance.roboadvisor.admin.vo.AdminUserVO;
import com.finance.roboadvisor.auth.entity.SysRole;
import com.finance.roboadvisor.auth.entity.SysUser;
import com.finance.roboadvisor.auth.entity.SysUserRole;
import com.finance.roboadvisor.auth.mapper.RoleMapper;
import com.finance.roboadvisor.auth.mapper.UserMapper;
import com.finance.roboadvisor.auth.mapper.UserRoleMapper;
import com.finance.roboadvisor.common.api.ResultCode;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.common.util.SecurityUtil;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.product.mapper.ProductFlowLogMapper;
import com.finance.roboadvisor.subscription.mapper.SubscriptionMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class AdminServiceImpl implements AdminService {

    private final UserMapper userMapper;
    private final RoleMapper roleMapper;
    private final UserRoleMapper userRoleMapper;
    private final ProductMapper productMapper;
    private final ProductFlowLogMapper productFlowLogMapper;
    private final SubscriptionMapper subscriptionMapper;

    public AdminServiceImpl(UserMapper userMapper,
                            RoleMapper roleMapper,
                            UserRoleMapper userRoleMapper,
                            ProductMapper productMapper,
                            ProductFlowLogMapper productFlowLogMapper,
                            SubscriptionMapper subscriptionMapper) {
        this.userMapper = userMapper;
        this.roleMapper = roleMapper;
        this.userRoleMapper = userRoleMapper;
        this.productMapper = productMapper;
        this.productFlowLogMapper = productFlowLogMapper;
        this.subscriptionMapper = subscriptionMapper;
    }

    @Override
    public AdminDashboardVO getDashboard() {
        AdminDashboardVO vo = new AdminDashboardVO();
        vo.setTotalProducts(productMapper.countAll());
        vo.setPublishedProducts(productMapper.countByStatus("PUBLISHED"));
        vo.setPendingReviewProducts(productMapper.countByStatus("PENDING_REVIEW"));
        vo.setTotalAdvisors(roleMapper.countUsersByRoleCode("ADVISOR"));
        vo.setTotalUsers(roleMapper.countUsersByRoleCode("USER"));
        vo.setTotalSubscriptions(subscriptionMapper.countAll());
        List<AdminDashboardVO.RecentChangeVO> changes = productFlowLogMapper.selectRecent(10);
        vo.setRecentChanges(changes != null ? changes : new ArrayList<>());
        List<AdminDashboardVO.ProductSubscriptionVO> topSubscribed = subscriptionMapper.selectTopSubscribed(10);
        vo.setTopSubscribedProducts(topSubscribed != null ? topSubscribed : new ArrayList<>());
        return vo;
    }

    @Override
    public AdminDashboardVO getAdvisorDashboard() {
        Long currentUserId = SecurityUtil.getCurrentUserId();
        AdminDashboardVO vo = new AdminDashboardVO();
        vo.setTotalProducts(productMapper.countByCreator(currentUserId, null, null, null, null));
        vo.setPublishedProducts(productMapper.countByCreator(currentUserId, "PUBLISHED", null, null, null));
        vo.setPendingReviewProducts(productMapper.countByCreator(currentUserId, "PENDING_REVIEW", null, null, null));
        List<AdminDashboardVO.RecentChangeVO> changes = productFlowLogMapper.selectRecentByOperator(currentUserId, 10);
        vo.setRecentChanges(changes != null ? changes : new ArrayList<>());
        vo.setTopSubscribedProducts(new ArrayList<>());
        return vo;
    }

    @Override
    public List<AdminUserVO> listUsers() {
        List<SysUser> users = userMapper.selectAll();
        return users.stream().map(user -> {
            AdminUserVO vo = new AdminUserVO();
            vo.setId(user.getId());
            vo.setUsername(user.getUsername());
            vo.setNickname(user.getNickname());
            vo.setPhone(user.getPhone());
            vo.setEmail(user.getEmail());
            vo.setStatus(user.getStatus());
            vo.setCreatedAt(user.getCreatedAt() != null ? user.getCreatedAt().toString() : null);
            List<SysRole> userRoles = roleMapper.selectRolesByUserId(user.getId());
            vo.setRoles(userRoles.stream().map(SysRole::getRoleCode).toList());
            return vo;
        }).toList();
    }

    @Override
    public void toggleUserStatus(Long userId, boolean enabled) {
        userMapper.updateStatus(userId, enabled ? 1 : 0);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void assignRole(Long userId, String roleCode) {
        SysUser user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.USER_NOT_FOUND);
        }
        SysRole role = roleMapper.selectByRoleCode(roleCode);
        if (role == null) {
            throw new BusinessException(ResultCode.VALIDATE_FAILED, "角色不存在: " + roleCode);
        }

        userRoleMapper.deleteByUserId(userId);
        SysUserRole userRole = new SysUserRole();
        userRole.setUserId(userId);
        userRole.setRoleId(role.getId());
        userRoleMapper.insert(userRole);
    }
}
