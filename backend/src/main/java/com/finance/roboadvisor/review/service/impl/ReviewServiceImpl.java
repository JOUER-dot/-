package com.finance.roboadvisor.review.service.impl;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.common.api.ResultCode;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.common.util.SecurityUtil;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.entity.AdvisorProductFlowLog;
import com.finance.roboadvisor.product.entity.AdvisorProductReview;
import com.finance.roboadvisor.product.entity.AdvisorProductVersion;
import com.finance.roboadvisor.product.mapper.ProductComponentMapper;
import com.finance.roboadvisor.product.mapper.ProductFlowLogMapper;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.product.mapper.ProductReviewMapper;
import com.finance.roboadvisor.product.mapper.ProductVersionMapper;
import com.finance.roboadvisor.product.vo.ReviewRecordVO;
import com.finance.roboadvisor.review.dto.ReviewRejectDTO;
import com.finance.roboadvisor.review.mapper.ReviewMapper;
import com.finance.roboadvisor.review.service.ReviewService;
import com.finance.roboadvisor.review.vo.ReviewDetailVO;
import com.finance.roboadvisor.review.vo.ReviewPendingListItemVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class ReviewServiceImpl implements ReviewService {

    private static final String STATUS_PENDING_REVIEW = "PENDING_REVIEW";
    private static final String STATUS_PUBLISHED = "PUBLISHED";
    private static final String STATUS_REJECTED = "REJECTED";
    private static final String VERSION_SUBMITTED = "SUBMITTED";
    private static final String VERSION_APPROVED = "APPROVED";
    private static final String VERSION_REJECTED = "REJECTED";
    private static final String FLOW_APPROVE = "APPROVE";
    private static final String FLOW_REJECT = "REJECT";
    private static final int DEFAULT_PAGE_NUM = 1;
    private static final int DEFAULT_PAGE_SIZE = 10;

    private final ReviewMapper reviewMapper;
    private final ProductMapper productMapper;
    private final ProductVersionMapper productVersionMapper;
    private final ProductComponentMapper productComponentMapper;
    private final ProductReviewMapper productReviewMapper;
    private final ProductFlowLogMapper productFlowLogMapper;
    private final ObjectMapper objectMapper;

    public ReviewServiceImpl(ReviewMapper reviewMapper,
                             ProductMapper productMapper,
                             ProductVersionMapper productVersionMapper,
                             ProductComponentMapper productComponentMapper,
                             ProductReviewMapper productReviewMapper,
                             ProductFlowLogMapper productFlowLogMapper,
                             ObjectMapper objectMapper) {
        this.reviewMapper = reviewMapper;
        this.productMapper = productMapper;
        this.productVersionMapper = productVersionMapper;
        this.productComponentMapper = productComponentMapper;
        this.productReviewMapper = productReviewMapper;
        this.productFlowLogMapper = productFlowLogMapper;
        this.objectMapper = objectMapper;
    }

    @Override
    public PageResult<ReviewPendingListItemVO> listPendingProducts(String keyword,
                                                                   String type,
                                                                   String riskLevel,
                                                                   Integer pageNum,
                                                                   Integer pageSize) {
        int safePageNum = pageNum == null || pageNum < 1 ? DEFAULT_PAGE_NUM : pageNum;
        int safePageSize = pageSize == null || pageSize < 1 ? DEFAULT_PAGE_SIZE : pageSize;
        int offset = (safePageNum - 1) * safePageSize;

        List<ReviewPendingListItemVO> records = reviewMapper.selectPendingProducts(
                trimToNull(keyword),
                trimToNull(type),
                trimToNull(riskLevel),
                offset,
                safePageSize
        );
        records.forEach(item -> item.setFeatureTags(splitFeatureTags(item.getFeatureTagsText())));
        Long total = reviewMapper.countPendingProducts(
                trimToNull(keyword),
                trimToNull(type),
                trimToNull(riskLevel)
        );
        return new PageResult<>(records, total, safePageNum, safePageSize);
    }

    @Override
    public ReviewDetailVO getPendingProductDetail(Long productId) {
        ReviewDetailVO detail = reviewMapper.selectPendingProductDetail(productId);
        if (detail == null) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "待审产品不存在");
        }
        detail.setFeatureTags(splitFeatureTags(detail.getFeatureTagsText()));
        detail.setBaseInfo(readMap(detail.getBaseInfoJson()));
        detail.setParams(readMap(detail.getParamsJson()));
        detail.setComponents(productComponentMapper.selectByVersionId(detail.getVersionId()));
        List<ReviewRecordVO> reviewRecords = productReviewMapper.selectByProductId(productId);
        detail.setReviewSummary(reviewRecords);
        return detail;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void approveProduct(Long productId) {
        Long reviewerId = SecurityUtil.getCurrentUserId();
        AdvisorProductVersion version = getPendingSubmittedVersion(productId);

        productMapper.updateApprovedReviewOutcome(productId, STATUS_PUBLISHED, version.getVersionNo());
        productVersionMapper.updateVersionStatus(version.getId(), VERSION_APPROVED);
        insertReview(productId, version.getId(), reviewerId, VERSION_APPROVED, "审核通过");
        insertFlowLog(productId, version.getId(), reviewerId, FLOW_APPROVE, "审核通过");
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void rejectProduct(Long productId, ReviewRejectDTO dto) {
        Long reviewerId = SecurityUtil.getCurrentUserId();
        String comment = dto.getComment().trim();
        AdvisorProductVersion version = getPendingSubmittedVersion(productId);

        productMapper.updateRejectedReviewOutcome(productId, STATUS_REJECTED, comment);
        productVersionMapper.updateVersionStatus(version.getId(), VERSION_REJECTED);
        insertReview(productId, version.getId(), reviewerId, VERSION_REJECTED, comment);
        insertFlowLog(productId, version.getId(), reviewerId, FLOW_REJECT, comment);
    }

    private AdvisorProductVersion getPendingSubmittedVersion(Long productId) {
        AdvisorProduct product = productMapper.selectById(productId);
        if (product == null) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "产品不存在");
        }
        if (!STATUS_PENDING_REVIEW.equals(product.getStatus())) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "当前状态不允许审核");
        }
        AdvisorProductVersion version = productVersionMapper.selectLatestSubmittedByProductId(productId);
        if (version == null || !VERSION_SUBMITTED.equals(version.getVersionStatus())) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "不存在可审核的待审版本");
        }
        return version;
    }

    private void insertReview(Long productId, Long versionId, Long reviewerId, String result, String comment) {
        AdvisorProductReview review = new AdvisorProductReview();
        review.setProductId(productId);
        review.setProductVersionId(versionId);
        review.setReviewerId(reviewerId);
        review.setResult(result);
        review.setComment(comment);
        productReviewMapper.insert(review);
    }

    private void insertFlowLog(Long productId, Long versionId, Long reviewerId, String actionType, String comment) {
        AdvisorProductFlowLog flowLog = new AdvisorProductFlowLog();
        flowLog.setProductId(productId);
        flowLog.setProductVersionId(versionId);
        flowLog.setOperatorId(reviewerId);
        flowLog.setActionType(actionType);
        flowLog.setComment(comment);
        productFlowLogMapper.insert(flowLog);
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
