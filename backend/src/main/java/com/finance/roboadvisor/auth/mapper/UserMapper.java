package com.finance.roboadvisor.auth.mapper;

import com.finance.roboadvisor.auth.entity.SysUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface UserMapper {

    SysUser selectById(@Param("id") Long id);

    SysUser selectByUsername(@Param("username") String username);

    int countByUsername(@Param("username") String username);

    int countByPhone(@Param("phone") String phone);

    int insert(SysUser user);

    int updatePassword(@Param("id") Long id, @Param("passwordHash") String passwordHash);

    int updateProfile(SysUser user);

    int updateStatus(@Param("id") Long id, @Param("status") Integer status);

    int updatePin(@Param("id") Long id, @Param("subPin") String subPin);

    List<SysUser> selectAll();
}
