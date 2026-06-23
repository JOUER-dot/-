package com.finance.roboadvisor.product.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.List;
import java.util.Map;

public class ProductSaveDTO {

    @NotBlank(message = "产品名称不能为空")
    private String name;

    @NotBlank(message = "产品类型不能为空")
    private String type;

    @NotBlank(message = "风险等级不能为空")
    private String riskLevel;

    private String strategyCode;

    private List<String> featureTags;

    @NotNull(message = "基础信息不能为空")
    private Map<String, Object> baseInfo;

    private Map<String, Object> params;

    @Valid
    private List<ComponentItemDTO> components;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getRiskLevel() {
        return riskLevel;
    }

    public void setRiskLevel(String riskLevel) {
        this.riskLevel = riskLevel;
    }

    public String getStrategyCode() {
        return strategyCode;
    }

    public void setStrategyCode(String strategyCode) {
        this.strategyCode = strategyCode;
    }

    public List<String> getFeatureTags() {
        return featureTags;
    }

    public void setFeatureTags(List<String> featureTags) {
        this.featureTags = featureTags;
    }

    public Map<String, Object> getBaseInfo() {
        return baseInfo;
    }

    public void setBaseInfo(Map<String, Object> baseInfo) {
        this.baseInfo = baseInfo;
    }

    public Map<String, Object> getParams() {
        return params;
    }

    public void setParams(Map<String, Object> params) {
        this.params = params;
    }

    public List<ComponentItemDTO> getComponents() {
        return components;
    }

    public void setComponents(List<ComponentItemDTO> components) {
        this.components = components;
    }
}
