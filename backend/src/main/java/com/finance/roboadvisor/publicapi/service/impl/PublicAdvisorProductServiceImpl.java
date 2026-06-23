package com.finance.roboadvisor.publicapi.service.impl;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.common.api.ResultCode;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.product.mapper.ProductComponentMapper;
import com.finance.roboadvisor.publicapi.mapper.PublicProductMapper;
import com.finance.roboadvisor.publicapi.service.PublicAdvisorProductService;
import com.finance.roboadvisor.publicapi.vo.PublicHoldingSnapshotVO;
import com.finance.roboadvisor.publicapi.vo.PublicProductDetailVO;
import com.finance.roboadvisor.publicapi.vo.PublicProductListItemVO;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class PublicAdvisorProductServiceImpl implements PublicAdvisorProductService {

    private static final int DEFAULT_PAGE_NUM = 1;
    private static final int DEFAULT_PAGE_SIZE = 10;

    private final PublicProductMapper publicProductMapper;
    private final ProductComponentMapper productComponentMapper;
    private final ObjectMapper objectMapper;

    public PublicAdvisorProductServiceImpl(PublicProductMapper publicProductMapper,
                                           ProductComponentMapper productComponentMapper,
                                           ObjectMapper objectMapper) {
        this.publicProductMapper = publicProductMapper;
        this.productComponentMapper = productComponentMapper;
        this.objectMapper = objectMapper;
    }

    @Override
    public PageResult<PublicProductListItemVO> listPublishedProducts(String keyword,
                                                                     String type,
                                                                     String riskLevel,
                                                                     Integer pageNum,
                                                                     Integer pageSize) {
        int safePageNum = pageNum == null || pageNum < 1 ? DEFAULT_PAGE_NUM : pageNum;
        int safePageSize = pageSize == null || pageSize < 1 ? DEFAULT_PAGE_SIZE : pageSize;
        int offset = (safePageNum - 1) * safePageSize;

        List<PublicProductListItemVO> records = publicProductMapper.selectPublishedProducts(
                trimToNull(keyword),
                trimToNull(type),
                trimToNull(riskLevel),
                offset,
                safePageSize
        );
        records.forEach(item -> item.setFeatureTags(splitFeatureTags(item.getFeatureTagsText())));
        Long total = publicProductMapper.countPublishedProducts(
                trimToNull(keyword),
                trimToNull(type),
                trimToNull(riskLevel)
        );
        return new PageResult<>(records, total, safePageNum, safePageSize);
    }

    @Override
    public PublicProductDetailVO getPublishedProductDetail(Long productId) {
        PublicProductDetailVO detail = publicProductMapper.selectPublishedProductDetail(productId);
        if (detail == null) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "产品不存在或未上架");
        }
        detail.setFeatureTags(splitFeatureTags(detail.getFeatureTagsText()));
        detail.setBaseInfo(readMap(detail.getBaseInfoJson()));
        detail.setParams(readMap(detail.getParamsJson()));
        detail.setComponents(productComponentMapper.selectByVersionId(detail.getVersionId()));
        detail.setNavList(publicProductMapper.selectNavList(productId));

        PublicHoldingSnapshotVO holdingSnapshot = publicProductMapper.selectLatestHoldingSnapshot(productId);
        if (holdingSnapshot != null) {
            detail.setHoldingSnapshotDate(holdingSnapshot.getSnapshotDate());
            detail.setHoldingSnapshot(readMap(holdingSnapshot.getHoldingJson()));
        } else {
            detail.setHoldingSnapshot(new LinkedHashMap<>());
        }
        return detail;
    }

    private List<String> splitFeatureTags(String raw) {
        if (!StringUtils.hasText(raw)) {
            return List.of();
        }
        return List.of(raw.split(",")).stream()
                .map(String::trim)
                .filter(StringUtils::hasText)
                .toList();
    }

    private Map<String, Object> readMap(String json) {
        if (!StringUtils.hasText(json)) {
            return new LinkedHashMap<>();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<Map<String, Object>>() {
            });
        } catch (Exception ex) {
            throw new BusinessException(ResultCode.SYSTEM_ERROR, "JSON解析失败");
        }
    }

    private String trimToNull(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }
}
