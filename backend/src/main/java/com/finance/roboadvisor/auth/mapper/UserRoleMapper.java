package com.finance.roboadvisor.auth.mapper;

import com.finance.roboadvisor.auth.entity.SysUserRole;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface UserRoleMapper {

    int insert(SysUserRole userRole);

    int deleteByUserId(@Param("userId") Long userId);

    List<SysUserRole> selectByUserId(@Param("userId") Long userId);

    List<SysUserRole> selectByRoleId(@Param("roleId") Long roleId);
}
