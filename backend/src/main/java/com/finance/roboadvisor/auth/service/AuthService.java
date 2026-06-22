package com.finance.roboadvisor.auth.service;

import com.finance.roboadvisor.auth.dto.LoginDTO;
import com.finance.roboadvisor.auth.dto.RegisterDTO;
import com.finance.roboadvisor.auth.vo.CurrentUserVO;
import com.finance.roboadvisor.auth.vo.LoginVO;

public interface AuthService {

    void register(RegisterDTO registerDTO);

    LoginVO login(LoginDTO loginDTO);

    CurrentUserVO getCurrentUser();

    void logout();
}
