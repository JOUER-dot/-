package com.finance.roboadvisor.product.vo;

public class ProductCreateVO {

    private Long productId;

    public ProductCreateVO() {
    }

    public ProductCreateVO(Long productId) {
        this.productId = productId;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }
}
