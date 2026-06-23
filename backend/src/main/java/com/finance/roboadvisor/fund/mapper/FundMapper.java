package com.finance.roboadvisor.fund.mapper;

import com.finance.roboadvisor.fund.vo.FundOptionVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FundMapper {

    List<FundOptionVO> selectEnabledFunds(@Param("keyword") String keyword,
                                          @Param("fundType") String fundType,
                                          @Param("offset") Integer offset,
                                          @Param("pageSize") Integer pageSize);

    Long countEnabledFunds(@Param("keyword") String keyword,
                           @Param("fundType") String fundType);
}
