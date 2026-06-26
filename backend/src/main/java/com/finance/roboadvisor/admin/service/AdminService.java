package com.finance.roboadvisor.admin.service;

import com.finance.roboadvisor.admin.vo.AdminDashboardVO;
import com.finance.roboadvisor.admin.vo.AdminUserVO;

import java.util.List;

public interface AdminService {

    AdminDashboardVO getDashboard();

    AdminDashboardVO getAdvisorDashboard();

    List<AdminUserVO> listUsers();

    void toggleUserStatus(Long userId, boolean enabled);

    void assignRole(Long userId, String roleCode);
}
