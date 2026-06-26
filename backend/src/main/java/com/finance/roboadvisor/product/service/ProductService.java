package com.finance.roboadvisor.product.service;

import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.product.dto.ProductSaveDTO;
import com.finance.roboadvisor.product.dto.ProductSubmitDTO;
import com.finance.roboadvisor.product.entity.AdvisorProductFlowLog;
import com.finance.roboadvisor.product.vo.ProductCreateVO;
import com.finance.roboadvisor.product.vo.ProductDetailVO;
import com.finance.roboadvisor.product.vo.ProductListItemVO;
import com.finance.roboadvisor.product.vo.ReviewRecordVO;

import java.util.List;

public interface ProductService {

    ProductCreateVO createProduct(ProductSaveDTO dto);

    void updateProduct(Long productId, ProductSaveDTO dto);

    PageResult<ProductListItemVO> listProducts(String status,
                                               String type,
                                               String riskLevel,
                                               String keyword,
                                               Integer pageNum,
                                               Integer pageSize);

    ProductDetailVO getProductDetail(Long productId);

    void submitProduct(Long productId, ProductSubmitDTO dto);

    void withdrawProduct(Long productId);

    void offlineProduct(Long productId);

    void deleteProduct(Long productId);

    Long copyProduct(Long productId);

    void generateProductNav(Long productId);

    List<ReviewRecordVO> listReviews(Long productId);

    List<AdvisorProductFlowLog> listFlowLogs(Long productId);
}
