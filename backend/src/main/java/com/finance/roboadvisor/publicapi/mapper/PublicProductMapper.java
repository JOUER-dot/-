package com.finance.roboadvisor.publicapi.mapper;

import com.finance.roboadvisor.publicapi.vo.PublicAdvisorVO;
import com.finance.roboadvisor.publicapi.vo.PublicHoldingSnapshotVO;
import com.finance.roboadvisor.publicapi.vo.PublicProductDetailVO;
import com.finance.roboadvisor.publicapi.vo.PublicProductListItemVO;
import com.finance.roboadvisor.publicapi.vo.PublicProductNavPointVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PublicProductMapper {

    List<PublicProductListItemVO> selectPublishedProducts(@Param("keyword") String keyword,
                                                          @Param("type") String type,
                                                          @Param("riskLevel") String riskLevel,
                                                          @Param("creatorId") Long creatorId,
                                                          @Param("fundCompany") String fundCompany,
                                                          @Param("offset") Integer offset,
                                                          @Param("pageSize") Integer pageSize);

    Long countPublishedProducts(@Param("keyword") String keyword,
                                @Param("type") String type,
                                @Param("riskLevel") String riskLevel,
                                @Param("creatorId") Long creatorId,
                                @Param("fundCompany") String fundCompany);

    List<PublicAdvisorVO> selectAdvisorsWithProducts();

    PublicProductDetailVO selectPublishedProductDetail(@Param("productId") Long productId);

    List<PublicProductNavPointVO> selectNavList(@Param("productId") Long productId);

    PublicHoldingSnapshotVO selectLatestHoldingSnapshot(@Param("productId") Long productId);

    Long countPublishedProductById(@Param("productId") Long productId);
}
