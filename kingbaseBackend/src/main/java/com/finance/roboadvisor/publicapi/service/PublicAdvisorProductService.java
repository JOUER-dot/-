package com.finance.roboadvisor.publicapi.service;

import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.publicapi.vo.PublicAdvisorVO;
import com.finance.roboadvisor.publicapi.vo.PublicProductDetailVO;
import com.finance.roboadvisor.publicapi.vo.PublicProductListItemVO;

import java.util.List;

public interface PublicAdvisorProductService {

    PageResult<PublicProductListItemVO> listPublishedProducts(String keyword,
                                                              String type,
                                                              String riskLevel,
                                                              Long creatorId,
                                                              String fundCompany,
                                                              Integer pageNum,
                                                              Integer pageSize);

    PublicProductDetailVO getPublishedProductDetail(Long productId);

    List<PublicAdvisorVO> listAdvisors();
}
