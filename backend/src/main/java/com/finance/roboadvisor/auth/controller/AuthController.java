package com.finance.roboadvisor.auth.controller;

import com.finance.roboadvisor.auth.dto.ChangePasswordDTO;
import com.finance.roboadvisor.auth.dto.LoginDTO;
import com.finance.roboadvisor.auth.dto.RegisterDTO;
import com.finance.roboadvisor.auth.dto.UpdateProfileDTO;
import com.finance.roboadvisor.auth.service.AuthService;
import com.finance.roboadvisor.auth.vo.CurrentUserVO;
import com.finance.roboadvisor.auth.vo.LoginVO;
import com.finance.roboadvisor.common.api.ApiResult;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ApiResult<Void> register(@Valid @RequestBody RegisterDTO registerDTO) {
        authService.register(registerDTO);
        return ApiResult.success("注册成功");
    }

    @PostMapping("/login")
    public ApiResult<LoginVO> login(@Valid @RequestBody LoginDTO loginDTO) {
        return ApiResult.success("登录成功", authService.login(loginDTO));
    }

    @GetMapping("/me")
    public ApiResult<CurrentUserVO> getCurrentUser() {
        return ApiResult.success(authService.getCurrentUser());
    }

    @PostMapping("/logout")
    public ApiResult<Void> logout() {
        authService.logout();
        return ApiResult.success("退出成功");
    }

    @PutMapping("/password")
    public ApiResult<Void> changePassword(@Valid @RequestBody ChangePasswordDTO dto) {
        authService.changePassword(dto);
        return ApiResult.success("密码修改成功");
    }

    @PutMapping("/profile")
    public ApiResult<Void> updateProfile(@Valid @RequestBody UpdateProfileDTO dto) {
        authService.updateProfile(dto);
        return ApiResult.success("个人信息更新成功");
    }

    @DeleteMapping("/account")
    public ApiResult<Void> deleteAccount() {
        authService.deleteAccount();
        return ApiResult.success("账号已注销");
    }

    @PostMapping("/pin")
    public ApiResult<Void> setPin(@RequestBody Map<String, String> body) {
        authService.setPin(body.get("pin"));
        return ApiResult.success("交易密码设置成功");
    }

    @PostMapping("/verify-password")
    public ApiResult<Void> verifyPassword(@RequestBody Map<String, String> body) {
        authService.verifyPassword(body.get("password"));
        return ApiResult.success("密码验证通过");
    }
}
