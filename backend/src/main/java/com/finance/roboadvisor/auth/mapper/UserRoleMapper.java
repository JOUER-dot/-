package com.finance.roboadvisor.auth.mapper;

import com.finance.roboadvisor.auth.entity.SysUserRole;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserRoleMapper {

    int insert(SysUserRole userRole);
}
