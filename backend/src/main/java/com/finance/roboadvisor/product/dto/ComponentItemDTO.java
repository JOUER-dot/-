package com.finance.roboadvisor.product.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public class ComponentItemDTO {

    @NotNull(message = "基金ID不能为空")
    private Long fundId;

    @NotNull(message = "基金权重不能为空")
    @DecimalMin(value = "0", inclusive = true, message = "基金权重不能小于0")
    @DecimalMax(value = "1", inclusive = true, message = "基金权重不能大于1")
    private BigDecimal weight;

    public Long getFundId() {
        return fundId;
    }

    public void setFundId(Long fundId) {
        this.fundId = fundId;
    }

    public BigDecimal getWeight() {
        return weight;
    }

    public void setWeight(BigDecimal weight) {
        this.weight = weight;
    }
}
