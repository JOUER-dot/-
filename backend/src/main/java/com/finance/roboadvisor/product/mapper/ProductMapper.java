package com.finance.roboadvisor.product.mapper;

import com.finance.roboadvisor.product.entity.AdvisorProduct;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProductMapper {

    int insert(AdvisorProduct product);

    int updateBasicInfo(AdvisorProduct product);

    int updateStatusAndVersion(@Param("id") Long id,
                               @Param("status") String status,
                               @Param("currentVersionNo") Integer currentVersionNo);

    int updateStatus(@Param("id") Long id, @Param("status") String status);

    int updateApprovedReviewOutcome(@Param("id") Long id,
                                    @Param("status") String status,
                                    @Param("publishedVersionNo") Integer publishedVersionNo);

    int updateRejectedReviewOutcome(@Param("id") Long id,
                                    @Param("status") String status,
                                    @Param("lastRejectComment") String lastRejectComment);

    AdvisorProduct selectById(@Param("id") Long id);

    List<AdvisorProduct> selectByCreator(@Param("creatorId") Long creatorId,
                                         @Param("status") String status,
                                         @Param("type") String type,
                                         @Param("riskLevel") String riskLevel,
                                         @Param("keyword") String keyword,
                                         @Param("offset") Integer offset,
                                         @Param("pageSize") Integer pageSize);

    Long countByCreator(@Param("creatorId") Long creatorId,
                        @Param("status") String status,
                        @Param("type") String type,
                        @Param("riskLevel") String riskLevel,
                        @Param("keyword") String keyword);
}
