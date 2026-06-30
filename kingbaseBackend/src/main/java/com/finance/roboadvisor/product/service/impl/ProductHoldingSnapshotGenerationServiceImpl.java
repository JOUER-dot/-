package com.finance.roboadvisor.product.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.common.api.ResultCode;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.entity.AdvisorProductHoldingSnapshot;
import com.finance.roboadvisor.product.entity.AdvisorProductVersion;
import com.finance.roboadvisor.product.mapper.ProductComponentMapper;
import com.finance.roboadvisor.product.mapper.ProductHoldingSnapshotMapper;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.product.mapper.ProductVersionMapper;
import com.finance.roboadvisor.product.service.ProductHoldingSnapshotGenerationService;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class ProductHoldingSnapshotGenerationServiceImpl implements ProductHoldingSnapshotGenerationService {

    private static final String STATUS_PUBLISHED = "PUBLISHED";

    private final ProductMapper productMapper;
    private final ProductVersionMapper productVersionMapper;
    private final ProductComponentMapper productComponentMapper;
    private final ProductHoldingSnapshotMapper productHoldingSnapshotMapper;
    private final ObjectMapper objectMapper;

    public ProductHoldingSnapshotGenerationServiceImpl(ProductMapper productMapper,
                                                       ProductVersionMapper productVersionMapper,
                                                       ProductComponentMapper productComponentMapper,
                                                       ProductHoldingSnapshotMapper productHoldingSnapshotMapper,
                                                       ObjectMapper objectMapper) {
        this.productMapper = productMapper;
        this.productVersionMapper = productVersionMapper;
        this.productComponentMapper = productComponentMapper;
        this.productHoldingSnapshotMapper = productHoldingSnapshotMapper;
        this.objectMapper = objectMapper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void generatePublishedHoldingSnapshot(Long productId) {
        AdvisorProduct product = productMapper.selectById(productId);
        if (product == null) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "产品不存在");
        }
        if (!STATUS_PUBLISHED.equals(product.getStatus()) || product.getPublishedVersionNo() == null) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "当前产品还没有可生成快照的已发布版本");
        }

        AdvisorProductVersion version = productVersionMapper.selectByProductAndVersionNo(
                productId,
                product.getPublishedVersionNo()
        );
        if (version == null) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "已发布版本不存在，不能生成持仓快照");
        }

        List<DraftComponentVO> components = productComponentMapper.selectByVersionId(version.getId());
        if (components == null || components.isEmpty()) {
            throw new BusinessException(ResultCode.VALIDATE_FAILED, "已发布版本缺少产品成份，不能生成持仓快照");
        }

        AdvisorProductHoldingSnapshot snapshot = new AdvisorProductHoldingSnapshot();
        snapshot.setProductId(productId);
        snapshot.setSnapshotDate(LocalDate.now());
        snapshot.setHoldingJson(writeHoldingJson(components));
        productHoldingSnapshotMapper.upsert(snapshot);
    }

    private String writeHoldingJson(List<DraftComponentVO> components) {
        Map<String, Object> root = new LinkedHashMap<>();
        List<Map<String, Object>> componentList = components.stream().map(component -> {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("fundCode", component.getFundCode());
            item.put("fundName", component.getFundName());
            item.put("weight", component.getWeight());
            return item;
        }).toList();
        root.put("components", componentList);
        try {
            return objectMapper.writeValueAsString(root);
        } catch (Exception ex) {
            throw new BusinessException(ResultCode.SYSTEM_ERROR, "持仓快照序列化失败");
        }
    }
}
