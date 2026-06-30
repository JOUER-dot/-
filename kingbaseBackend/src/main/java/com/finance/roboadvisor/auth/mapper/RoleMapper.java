package com.finance.roboadvisor.auth.mapper;

import com.finance.roboadvisor.auth.entity.SysRole;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface RoleMapper {

    SysRole selectByRoleCode(@Param("roleCode") String roleCode);

    List<SysRole> selectRolesByUserId(@Param("userId") Long userId);

    Long countUsersByRoleCode(@Param("roleCode") String roleCode);
}
