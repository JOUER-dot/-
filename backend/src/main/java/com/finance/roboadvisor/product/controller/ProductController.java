package com.finance.roboadvisor.product.controller;

import com.finance.roboadvisor.common.api.ApiResult;
import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.product.dto.ProductSaveDTO;
import com.finance.roboadvisor.product.dto.ProductSubmitDTO;
import com.finance.roboadvisor.product.entity.AdvisorProductFlowLog;
import com.finance.roboadvisor.product.service.ProductService;
import com.finance.roboadvisor.product.vo.ProductCreateVO;
import com.finance.roboadvisor.product.vo.ProductDetailVO;
import com.finance.roboadvisor.product.vo.ProductListItemVO;
import com.finance.roboadvisor.product.vo.ReviewRecordVO;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/products")
public class ProductController {

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @PostMapping
    public ApiResult<ProductCreateVO> createProduct(@Valid @RequestBody ProductSaveDTO dto) {
        return ApiResult.success("创建成功", productService.createProduct(dto));
    }

    @PutMapping("/{id}")
    public ApiResult<Void> updateProduct(@PathVariable("id") Long productId,
                                         @Valid @RequestBody ProductSaveDTO dto) {
        productService.updateProduct(productId, dto);
        return ApiResult.success("保存成功");
    }

    @GetMapping
    public ApiResult<PageResult<ProductListItemVO>> listProducts(@RequestParam(required = false) String status,
                                                                 @RequestParam(required = false) String type,
                                                                 @RequestParam(required = false) String riskLevel,
                                                                 @RequestParam(required = false) String keyword,
                                                                 @RequestParam(required = false) Integer pageNum,
                                                                 @RequestParam(required = false) Integer pageSize) {
        return ApiResult.success(productService.listProducts(status, type, riskLevel, keyword, pageNum, pageSize));
    }

    @GetMapping("/{id}")
    public ApiResult<ProductDetailVO> getProductDetail(@PathVariable("id") Long productId) {
        return ApiResult.success(productService.getProductDetail(productId));
    }

    @PostMapping("/{id}/submit")
    public ApiResult<Void> submitProduct(@PathVariable("id") Long productId,
                                         @RequestBody(required = false) ProductSubmitDTO dto) {
        productService.submitProduct(productId, dto);
        return ApiResult.success("提交审核成功");
    }

    @PostMapping("/{id}/withdraw")
    public ApiResult<Void> withdrawProduct(@PathVariable("id") Long productId) {
        productService.withdrawProduct(productId);
        return ApiResult.success("撤回审核成功");
    }

    @PostMapping("/{id}/offline")
    public ApiResult<Void> offlineProduct(@PathVariable("id") Long productId) {
        productService.offlineProduct(productId);
        return ApiResult.success("下架成功");
    }

    @PostMapping("/{id}/nav/generate")
    public ApiResult<Void> generateProductNav(@PathVariable("id") Long productId) {
        productService.generateProductNav(productId);
        return ApiResult.success("净值与持仓快照重算成功");
    }

    @DeleteMapping("/{id}")
    public ApiResult<Void> deleteProduct(@PathVariable("id") Long productId) {
        productService.deleteProduct(productId);
        return ApiResult.success("删除成功");
    }

    @PostMapping("/{id}/copy")
    public ApiResult<Long> copyProduct(@PathVariable("id") Long productId) {
        Long newProductId = productService.copyProduct(productId);
        return ApiResult.success("复制成功", newProductId);
    }

    @GetMapping("/{id}/reviews")
    public ApiResult<List<ReviewRecordVO>> listReviews(@PathVariable("id") Long productId) {
        return ApiResult.success(productService.listReviews(productId));
    }

    @GetMapping("/{id}/flow-logs")
    public ApiResult<List<AdvisorProductFlowLog>> listFlowLogs(@PathVariable("id") Long productId) {
        return ApiResult.success(productService.listFlowLogs(productId));
    }
}
