package com.finance.roboadvisor.review.service.impl;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.common.api.ResultCode;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.common.util.SecurityUtil;
import com.finance.roboadvisor.notification.service.NotificationService;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.entity.AdvisorProductFlowLog;
import com.finance.roboadvisor.product.entity.AdvisorProductFlowLog;
import com.finance.roboadvisor.product.entity.AdvisorProductRuleDecision;
import com.finance.roboadvisor.product.entity.AdvisorProductReview;
import com.finance.roboadvisor.product.entity.AdvisorStrategyRule;
import com.finance.roboadvisor.product.entity.AdvisorProductVersion;
import com.finance.roboadvisor.product.mapper.ProductComponentMapper;
import com.finance.roboadvisor.product.mapper.ProductFlowLogMapper;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.product.mapper.ProductRuleDecisionMapper;
import com.finance.roboadvisor.product.mapper.ProductReviewMapper;
import com.finance.roboadvisor.product.mapper.ProductVersionMapper;
import com.finance.roboadvisor.product.mapper.StrategyRuleMapper;
import com.finance.roboadvisor.product.service.ProductHoldingSnapshotGenerationService;
import com.finance.roboadvisor.product.service.ProductNavGenerationService;
import com.finance.roboadvisor.product.service.StrategyRuleValidationService;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import com.finance.roboadvisor.product.vo.ReviewRecordVO;
import com.finance.roboadvisor.review.dto.ReviewApproveDTO;
import com.finance.roboadvisor.review.dto.ReviewRejectDTO;
import com.finance.roboadvisor.review.mapper.ReviewMapper;
import com.finance.roboadvisor.review.support.ReviewDiffBuilder;
import com.finance.roboadvisor.review.service.ReviewService;
import com.finance.roboadvisor.review.vo.ReviewDetailVO;
import com.finance.roboadvisor.review.vo.ReviewHistoryItemVO;
import com.finance.roboadvisor.review.vo.ReviewPendingListItemVO;
import com.finance.roboadvisor.subscription.service.SubscriptionService;
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
    private static final String CHANGE_TYPE_MAJOR = "MAJOR";
    private static final String ACTION_TYPE_NOTICE = "NOTICE";
    private static final String ACTION_TYPE_CONFIRM_REQUIRED = "CONFIRM_REQUIRED";
    private static final String ACTION_STATUS_NOTIFIED = "NOTIFIED";
    private static final String ACTION_STATUS_PENDING = "PENDING";
    private static final int DEFAULT_PAGE_NUM = 1;
    private static final int DEFAULT_PAGE_SIZE = 10;

    private final ReviewMapper reviewMapper;
    private final ProductMapper productMapper;
    private final ProductVersionMapper productVersionMapper;
    private final ProductComponentMapper productComponentMapper;
    private final ProductReviewMapper productReviewMapper;
    private final ProductFlowLogMapper productFlowLogMapper;
    private final StrategyRuleMapper strategyRuleMapper;
    private final ProductRuleDecisionMapper productRuleDecisionMapper;
    private final StrategyRuleValidationService strategyRuleValidationService;
    private final ProductNavGenerationService productNavGenerationService;
    private final ProductHoldingSnapshotGenerationService productHoldingSnapshotGenerationService;
    private final SubscriptionService subscriptionService;
    private final ObjectMapper objectMapper;
    private final ReviewDiffBuilder reviewDiffBuilder;
    private final NotificationService notificationService;

    public ReviewServiceImpl(ReviewMapper reviewMapper,
                             ProductMapper productMapper,
                             ProductVersionMapper productVersionMapper,
                             ProductComponentMapper productComponentMapper,
                             ProductReviewMapper productReviewMapper,
                             ProductFlowLogMapper productFlowLogMapper,
                             StrategyRuleMapper strategyRuleMapper,
                             ProductRuleDecisionMapper productRuleDecisionMapper,
                             StrategyRuleValidationService strategyRuleValidationService,
                             ProductNavGenerationService productNavGenerationService,
                             ProductHoldingSnapshotGenerationService productHoldingSnapshotGenerationService,
                             SubscriptionService subscriptionService,
                             NotificationService notificationService,
                             ObjectMapper objectMapper) {
        this.reviewMapper = reviewMapper;
        this.productMapper = productMapper;
        this.productVersionMapper = productVersionMapper;
        this.productComponentMapper = productComponentMapper;
        this.productReviewMapper = productReviewMapper;
        this.productFlowLogMapper = productFlowLogMapper;
        this.strategyRuleMapper = strategyRuleMapper;
        this.productRuleDecisionMapper = productRuleDecisionMapper;
        this.strategyRuleValidationService = strategyRuleValidationService;
        this.productNavGenerationService = productNavGenerationService;
        this.productHoldingSnapshotGenerationService = productHoldingSnapshotGenerationService;
        this.subscriptionService = subscriptionService;
        this.notificationService = notificationService;
        this.objectMapper = objectMapper;
        this.reviewDiffBuilder = new ReviewDiffBuilder(objectMapper);
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
        AdvisorProductVersion currentVersion = productVersionMapper.selectById(detail.getVersionId());
        List<DraftComponentVO> currentComponents = productComponentMapper.selectByVersionId(detail.getVersionId());
        detail.setComponents(currentComponents);
        List<ReviewRecordVO> reviewRecords = productReviewMapper.selectByProductId(productId);
        detail.setReviewSummary(reviewRecords);
        AdvisorProductVersion baseVersion = currentVersion != null && currentVersion.getBaseVersionId() != null
                ? productVersionMapper.selectById(currentVersion.getBaseVersionId())
                : null;
        List<DraftComponentVO> baseComponents = baseVersion == null
                ? List.of()
                : productComponentMapper.selectByVersionId(baseVersion.getId());
        ReviewDiffBuilder.ReviewDiffResult diffResult = reviewDiffBuilder.build(
                currentVersion,
                baseVersion,
                detail,
                baseComponents,
                currentComponents
        );
        detail.setBaseVersionSummary(diffResult.getBaseVersionSummary());
        detail.setCurrentVersionSummary(diffResult.getCurrentVersionSummary());
        detail.setFieldDiffs(diffResult.getFieldDiffs());
        detail.setComponentDiffs(diffResult.getComponentDiffs());
        detail.setChangeType(currentVersion == null ? null : currentVersion.getChangeType());
        detail.setVersionNote(currentVersion == null ? null : currentVersion.getVersionNote());
        return detail;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void approveProduct(Long productId, ReviewApproveDTO dto) {
        Long reviewerId = SecurityUtil.getCurrentUserId();
        AdvisorProduct product = getPendingProduct(productId);
        AdvisorProductVersion version = getPendingSubmittedVersion(productId);
        StrategyRuleValidationService.StrategyRuleOverride override = buildOverride(dto);
        validateDecisionComment(dto, override);
        List<DraftComponentVO> components = productComponentMapper.selectByVersionId(version.getId());
        strategyRuleValidationService.validateOrThrow(product.getStrategyCode(), product.getType(), components, override);

        // Step 1: Update product status to PUBLISHED first
        productMapper.updateApprovedReviewOutcome(productId, STATUS_PUBLISHED, version.getVersionNo());
        productVersionMapper.updateVersionStatus(version.getId(), VERSION_APPROVED);
        insertReview(productId, version.getId(), reviewerId, VERSION_APPROVED, "审核通过");
        insertFlowLog(productId, version.getId(), reviewerId, FLOW_APPROVE, "审核通过");

        // Step 2: Handle subscription version actions
        if (CHANGE_TYPE_MAJOR.equals(version.getChangeType())) {
            subscriptionService.createVersionActions(productId, version.getId(), version.getChangeType(),
                    ACTION_TYPE_CONFIRM_REQUIRED, ACTION_STATUS_PENDING, version.getVersionNote());
        } else {
            subscriptionService.createVersionActions(productId, version.getId(), version.getChangeType(),
                    ACTION_TYPE_NOTICE, ACTION_STATUS_NOTIFIED, version.getVersionNote());
        }

        // Step 3: Insert rule decision if applicable
        AdvisorStrategyRule baseRule = strategyRuleMapper.selectEnabledByStrategyAndType(product.getStrategyCode(), product.getType());
        if (baseRule != null) {
            insertRuleDecision(productId, version.getId(), reviewerId, baseRule, dto, override);
        }

        // Step 4: Generate NAV and holding snapshot (product is now PUBLISHED)
        productNavGenerationService.generatePublishedProductNav(productId);
        productHoldingSnapshotGenerationService.generatePublishedHoldingSnapshot(productId);

        // Step 5: Notify the product creator
        notificationService.createNotification(product.getCreatorId(),
                "审核通过",
                "您的产品「" + product.getName() + "」已通过审核，现已发布。",
                "REVIEW_RESULT",
                "/admin/products/" + productId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void rejectProduct(Long productId, ReviewRejectDTO dto) {
        Long reviewerId = SecurityUtil.getCurrentUserId();
        String comment = dto.getComment().trim();
        AdvisorProduct product = getPendingProduct(productId);
        AdvisorProductVersion version = getPendingSubmittedVersion(productId);

        productMapper.updateRejectedReviewOutcome(productId, STATUS_REJECTED, comment);
        productVersionMapper.updateVersionStatus(version.getId(), VERSION_REJECTED);
        insertReview(productId, version.getId(), reviewerId, VERSION_REJECTED, comment);
        insertFlowLog(productId, version.getId(), reviewerId, FLOW_REJECT, comment);

        // Notify the product creator
        notificationService.createNotification(product.getCreatorId(),
                "审核驳回",
                "您的产品「" + product.getName() + "」已被驳回。驳回意见：" + comment,
                "REVIEW_RESULT",
                "/admin/products/" + productId + "/edit");
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void batchApprove(List<Long> productIds, ReviewApproveDTO dto) {
        Long reviewerId = SecurityUtil.getCurrentUserId();
        for (Long productId : productIds) {
            try {
                approveProduct(productId, dto);
            } catch (Exception ex) {
                throw new BusinessException(ResultCode.VALIDATE_FAILED,
                        "产品 " + productId + " 批量审核通过失败: " + ex.getMessage());
            }
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void batchReject(List<Long> productIds, ReviewRejectDTO dto) {
        Long reviewerId = SecurityUtil.getCurrentUserId();
        for (Long productId : productIds) {
            try {
                rejectProduct(productId, dto);
            } catch (Exception ex) {
                throw new BusinessException(ResultCode.VALIDATE_FAILED,
                        "产品 " + productId + " 批量审核驳回失败: " + ex.getMessage());
            }
        }
    }

    @Override
    public List<ReviewHistoryItemVO> getMyReviewHistory(Integer pageNum, Integer pageSize) {
        Long reviewerId = SecurityUtil.getCurrentUserId();
        if (pageNum == null || pageNum < 1) pageNum = DEFAULT_PAGE_NUM;
        if (pageSize == null || pageSize < 1) pageSize = DEFAULT_PAGE_SIZE;
        return reviewMapper.selectReviewHistoryByReviewer(reviewerId,
                (pageNum - 1) * pageSize, pageSize);
    }

    private AdvisorProduct getPendingProduct(Long productId) {
        AdvisorProduct product = productMapper.selectById(productId);
        if (product == null) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "产品不存在");
        }
        if (!STATUS_PENDING_REVIEW.equals(product.getStatus())) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "当前状态不允许审核");
        }
        return product;
    }

    private AdvisorProductVersion getPendingSubmittedVersion(Long productId) {
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

    private void insertRuleDecision(Long productId,
                                    Long versionId,
                                    Long reviewerId,
                                    AdvisorStrategyRule baseRule,
                                    ReviewApproveDTO dto,
                                    StrategyRuleValidationService.StrategyRuleOverride override) {
        AdvisorProductRuleDecision decision = new AdvisorProductRuleDecision();
        decision.setProductId(productId);
        decision.setProductVersionId(versionId);
        decision.setBaseRuleId(baseRule.getId());
        decision.setReviewerId(reviewerId);
        decision.setOverrideMinFundCount(dto == null ? null : dto.getOverrideMinFundCount());
        decision.setOverrideMaxFundCount(dto == null ? null : dto.getOverrideMaxFundCount());
        decision.setOverrideMaxSingleWeight(dto == null ? null : dto.getOverrideMaxSingleWeight());
        decision.setFinalRuleJson(writeJson(buildFinalRuleSnapshot(baseRule, override)));
        decision.setDecisionComment(trimToNull(dto == null ? null : dto.getDecisionComment()));
        productRuleDecisionMapper.insert(decision);
    }

    private StrategyRuleValidationService.StrategyRuleOverride buildOverride(ReviewApproveDTO dto) {
        if (dto == null) {
            return null;
        }
        StrategyRuleValidationService.StrategyRuleOverride override = new StrategyRuleValidationService.StrategyRuleOverride();
        override.setOverrideMinFundCount(dto.getOverrideMinFundCount());
        override.setOverrideMaxFundCount(dto.getOverrideMaxFundCount());
        override.setOverrideMaxSingleWeight(dto.getOverrideMaxSingleWeight());
        return hasOverride(override) ? override : null;
    }

    private void validateDecisionComment(ReviewApproveDTO dto,
                                         StrategyRuleValidationService.StrategyRuleOverride override) {
        if (override != null && !StringUtils.hasText(dto == null ? null : dto.getDecisionComment())) {
            throw new BusinessException(ResultCode.VALIDATE_FAILED, "覆盖原因必填");
        }
    }

    private boolean hasOverride(StrategyRuleValidationService.StrategyRuleOverride override) {
        return override != null
                && (override.getOverrideMinFundCount() != null
                || override.getOverrideMaxFundCount() != null
                || override.getOverrideMaxSingleWeight() != null);
    }

    private Map<String, Object> buildFinalRuleSnapshot(AdvisorStrategyRule baseRule,
                                                       StrategyRuleValidationService.StrategyRuleOverride override) {
        Map<String, Object> snapshot = new LinkedHashMap<>();
        snapshot.put("ruleId", baseRule.getId());
        snapshot.put("strategyCode", baseRule.getStrategyCode());
        snapshot.put("productType", baseRule.getProductType());
        snapshot.put("minFundCount", override != null && override.getOverrideMinFundCount() != null
                ? override.getOverrideMinFundCount()
                : baseRule.getMinFundCount());
        snapshot.put("maxFundCount", override != null && override.getOverrideMaxFundCount() != null
                ? override.getOverrideMaxFundCount()
                : baseRule.getMaxFundCount());
        snapshot.put("minSingleWeight", baseRule.getMinSingleWeight());
        snapshot.put("maxSingleWeight", override != null && override.getOverrideMaxSingleWeight() != null
                ? override.getOverrideMaxSingleWeight()
                : baseRule.getMaxSingleWeight());
        snapshot.put("allowFundTypes", baseRule.getAllowFundTypes());
        snapshot.put("riskRuleMode", baseRule.getRiskRuleMode());
        return snapshot;
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

    private String writeJson(Object value) {
        try {
            return objectMapper.writeValueAsString(value == null ? Map.of() : value);
        } catch (Exception ex) {
            throw new BusinessException(ResultCode.SYSTEM_ERROR, "JSON序列化失败");
        }
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
