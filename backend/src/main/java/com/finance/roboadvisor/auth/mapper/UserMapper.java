package com.finance.roboadvisor.auth.mapper;

import com.finance.roboadvisor.auth.entity.SysUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserMapper {

    SysUser selectById(@Param("id") Long id);

    SysUser selectByUsername(@Param("username") String username);

    int countByUsername(@Param("username") String username);

    int countByPhone(@Param("phone") String phone);

    int insert(SysUser user);
}
