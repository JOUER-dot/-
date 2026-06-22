package com.finance.roboadvisor.auth.controller;

import com.finance.roboadvisor.auth.dto.LoginDTO;
import com.finance.roboadvisor.auth.dto.RegisterDTO;
import com.finance.roboadvisor.auth.service.AuthService;
import com.finance.roboadvisor.auth.vo.CurrentUserVO;
import com.finance.roboadvisor.auth.vo.LoginVO;
import com.finance.roboadvisor.common.api.ApiResult;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
}
