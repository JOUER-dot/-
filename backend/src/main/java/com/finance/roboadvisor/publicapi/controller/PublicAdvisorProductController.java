package com.finance.roboadvisor.publicapi.controller;

import com.finance.roboadvisor.common.api.ApiResult;
import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.publicapi.service.PublicAdvisorProductService;
import com.finance.roboadvisor.publicapi.vo.PublicProductDetailVO;
import com.finance.roboadvisor.publicapi.vo.PublicProductListItemVO;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/public/advisor-products")
public class PublicAdvisorProductController {

    private final PublicAdvisorProductService publicAdvisorProductService;

    public PublicAdvisorProductController(PublicAdvisorProductService publicAdvisorProductService) {
        this.publicAdvisorProductService = publicAdvisorProductService;
    }

    @GetMapping
    public ApiResult<PageResult<PublicProductListItemVO>> listPublishedProducts(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String riskLevel,
            @RequestParam(required = false) Integer pageNum,
            @RequestParam(required = false) Integer pageSize) {
        return ApiResult.success(publicAdvisorProductService.listPublishedProducts(
                keyword,
                type,
                riskLevel,
                pageNum,
                pageSize
        ));
    }

    @GetMapping("/{id}")
    public ApiResult<PublicProductDetailVO> getPublishedProductDetail(@PathVariable("id") Long productId) {
        return ApiResult.success(publicAdvisorProductService.getPublishedProductDetail(productId));
    }
}
