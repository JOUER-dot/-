package com.finance.roboadvisor.admin.controller;

import com.finance.roboadvisor.admin.service.AdminService;
import com.finance.roboadvisor.admin.vo.AdminDashboardVO;
import com.finance.roboadvisor.admin.vo.AdminUserVO;
import com.finance.roboadvisor.common.api.ApiResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/system")
public class AdminController {

    private final AdminService adminService;

    public AdminController(AdminService adminService) {
        this.adminService = adminService;
    }

    @GetMapping("/dashboard")
    public ApiResult<AdminDashboardVO> getDashboard() {
        return ApiResult.success(adminService.getDashboard());
    }

    @GetMapping("/users")
    public ApiResult<List<AdminUserVO>> listUsers() {
        return ApiResult.success(adminService.listUsers());
    }

    @PutMapping("/users/{id}/status")
    public ApiResult<Void> toggleUserStatus(@PathVariable("id") Long userId,
                                            @RequestParam("enabled") boolean enabled) {
        adminService.toggleUserStatus(userId, enabled);
        return ApiResult.success(enabled ? "用户已启用" : "用户已禁用");
    }

    @PostMapping("/users/{id}/assign-role")
    public ApiResult<Void> assignRole(@PathVariable("id") Long userId,
                                      @RequestParam("roleCode") String roleCode) {
        adminService.assignRole(userId, roleCode);
        return ApiResult.success("角色分配成功");
    }

    @PutMapping("/users/{id}/role")
    public ApiResult<Void> assignRole(@PathVariable("id") Long userId,
                                      @RequestBody Map<String, String> body) {
        String roleCode = body.get("roleCode");
        adminService.assignRole(userId, roleCode);
        return ApiResult.success("角色分配成功");
    }

    @GetMapping("/advisor/dashboard")
    public ApiResult<AdminDashboardVO> getAdvisorDashboard() {
        return ApiResult.success(adminService.getAdvisorDashboard());
    }
}
