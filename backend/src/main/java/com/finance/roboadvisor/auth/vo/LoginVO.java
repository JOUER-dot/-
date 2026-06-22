package com.finance.roboadvisor.auth.vo;

import java.util.List;

public class LoginVO {

    private String token;
    private String tokenHead;
    private LoginUserInfoVO userInfo;
    private List<String> roles;

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getTokenHead() {
        return tokenHead;
    }

    public void setTokenHead(String tokenHead) {
        this.tokenHead = tokenHead;
    }

    public LoginUserInfoVO getUserInfo() {
        return userInfo;
    }

    public void setUserInfo(LoginUserInfoVO userInfo) {
        this.userInfo = userInfo;
    }

    public List<String> getRoles() {
        return roles;
    }

    public void setRoles(List<String> roles) {
        this.roles = roles;
    }
}
