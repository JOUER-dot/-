package com.finance.roboadvisor.product.mapper;

import com.finance.roboadvisor.product.entity.AdvisorProductVersion;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProductVersionMapper {

    int insert(AdvisorProductVersion version);

    AdvisorProductVersion selectById(@Param("id") Long id);

    AdvisorProductVersion selectLatestSubmittedByProductId(@Param("productId") Long productId);

    AdvisorProductVersion selectLatestPublishedByProductId(@Param("productId") Long productId);

    AdvisorProductVersion selectLatestDraftOrSubmittedByProductId(@Param("productId") Long productId);

    AdvisorProductVersion selectByProductAndVersionNo(@Param("productId") Long productId,
                                                      @Param("versionNo") Integer versionNo);

    int updateVersionStatus(@Param("id") Long id,
                            @Param("versionStatus") String versionStatus);

    List<AdvisorProductVersion> selectByProductId(@Param("productId") Long productId);

    int deleteByProductId(@Param("productId") Long productId);
}
