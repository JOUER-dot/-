package com.finance.roboadvisor.product.mapper;

import com.finance.roboadvisor.product.entity.AdvisorProductVersion;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ProductVersionMapper {

    int insert(AdvisorProductVersion version);

    AdvisorProductVersion selectById(@Param("id") Long id);

    AdvisorProductVersion selectLatestSubmittedByProductId(@Param("productId") Long productId);

    AdvisorProductVersion selectByProductAndVersionNo(@Param("productId") Long productId,
                                                      @Param("versionNo") Integer versionNo);

    int updateVersionStatus(@Param("id") Long id,
                            @Param("versionStatus") String versionStatus);
}
