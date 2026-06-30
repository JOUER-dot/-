package com.finance.roboadvisor.fund.mapper;

import com.finance.roboadvisor.fund.entity.FundNav;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FundNavMapper {

    List<FundNav> selectByFundCodes(@Param("fundCodes") List<String> fundCodes);
}
