package com.finance.roboadvisor.publicapi.service;

import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.publicapi.vo.PublicProductDetailVO;
import com.finance.roboadvisor.publicapi.vo.PublicProductListItemVO;

public interface PublicAdvisorProductService {

    PageResult<PublicProductListItemVO> listPublishedProducts(String keyword,
                                                              String type,
                                                              String riskLevel,
                                                              Integer pageNum,
                                                              Integer pageSize);

    PublicProductDetailVO getPublishedProductDetail(Long productId);
}
