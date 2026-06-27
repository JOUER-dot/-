package com.finance.roboadvisor.product.mapper;

import com.finance.roboadvisor.admin.vo.AdminDashboardVO;
import com.finance.roboadvisor.product.entity.AdvisorProductFlowLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProductFlowLogMapper {

    int insert(AdvisorProductFlowLog flowLog);

    List<AdvisorProductFlowLog> selectByProductId(@Param("productId") Long productId);

    int deleteByProductId(@Param("productId") Long productId);

    List<AdminDashboardVO.RecentChangeVO> selectRecent(@Param("limit") int limit);

    List<AdminDashboardVO.RecentChangeVO> selectRecentByOperator(@Param("operatorId") Long operatorId,
                                                                  @Param("limit") int limit);
}
