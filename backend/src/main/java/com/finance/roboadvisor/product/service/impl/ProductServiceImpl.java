package com.finance.roboadvisor.product.service.impl;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.common.api.ResultCode;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.common.util.SecurityUtil;
import com.finance.roboadvisor.fund.mapper.FundMapper;
import com.finance.roboadvisor.fund.vo.FundOptionVO;
import com.finance.roboadvisor.product.dto.ComponentItemDTO;
import com.finance.roboadvisor.product.dto.ProductSaveDTO;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.entity.AdvisorProductComponent;
import com.finance.roboadvisor.product.entity.AdvisorProductDraft;
import com.finance.roboadvisor.product.entity.AdvisorProductDraftComponent;
import com.finance.roboadvisor.product.entity.AdvisorProductFlowLog;
import com.finance.roboadvisor.product.entity.AdvisorProductVersion;
import com.finance.roboadvisor.product.mapper.ProductComponentMapper;
import com.finance.roboadvisor.product.mapper.ProductDraftComponentMapper;
import com.finance.roboadvisor.product.mapper.ProductDraftMapper;
import com.finance.roboadvisor.product.mapper.ProductFlowLogMapper;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.product.mapper.ProductReviewMapper;
import com.finance.roboadvisor.product.mapper.ProductVersionMapper;
import com.finance.roboadvisor.product.service.ProductHoldingSnapshotGenerationService;
import com.finance.roboadvisor.product.service.ProductNavGenerationService;
import com.finance.roboadvisor.product.service.ProductService;
import com.finance.roboadvisor.product.service.StrategyRuleValidationService;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import com.finance.roboadvisor.product.vo.ProductCreateVO;
import com.finance.roboadvisor.product.vo.ProductDetailVO;
import com.finance.roboadvisor.product.vo.ProductListItemVO;
import com.finance.roboadvisor.product.vo.PublishedVersionVO;
import com.finance.roboadvisor.product.vo.ReviewRecordVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class ProductServiceImpl implements ProductService {

    private static final String STATUS_DRAFT = "DRAFT";
    private static final String STATUS_PENDING_REVIEW = "PENDING_REVIEW";
    private static final String STATUS_PUBLISHED = "PUBLISHED";
    private static final String STATUS_OFFLINE = "OFFLINE";
    private static final String STATUS_REJECTED = "REJECTED";
    private static final String VERSION_SUBMITTED = "SUBMITTED";
    private static final String VERSION_WITHDRAWN = "WITHDRAWN";
    private static final String FLOW_SAVE_DRAFT = "SAVE_DRAFT";
    private static final String FLOW_SUBMIT = "SUBMIT";
    private static final String FLOW_WITHDRAW = "WITHDRAW";
    private static final int DEFAULT_PAGE_NUM = 1;
    private static final int DEFAULT_PAGE_SIZE = 10;

    private final ProductMapper productMapper;
    private final ProductDraftMapper productDraftMapper;
    private final ProductDraftComponentMapper productDraftComponentMapper;
    private final ProductVersionMapper productVersionMapper;
    private final ProductComponentMapper productComponentMapper;
    private final ProductReviewMapper productReviewMapper;
    private final ProductFlowLogMapper productFlowLogMapper;
    private final FundMapper fundMapper;
    private final ProductNavGenerationService productNavGenerationService;
    private final ProductHoldingSnapshotGenerationService productHoldingSnapshotGenerationService;
    private final StrategyRuleValidationService strategyRuleValidationService;
    private final ObjectMapper objectMapper;

    public ProductServiceImpl(ProductMapper productMapper,
                              ProductDraftMapper productDraftMapper,
                              ProductDraftComponentMapper productDraftComponentMapper,
                              ProductVersionMapper productVersionMapper,
                              ProductComponentMapper productComponentMapper,
                              ProductReviewMapper productReviewMapper,
                              ProductFlowLogMapper productFlowLogMapper,
                              FundMapper fundMapper,
                              ProductNavGenerationService productNavGenerationService,
                              ProductHoldingSnapshotGenerationService productHoldingSnapshotGenerationService,
                              StrategyRuleValidationService strategyRuleValidationService,
                              ObjectMapper objectMapper) {
        this.productMapper = productMapper;
        this.productDraftMapper = productDraftMapper;
        this.productDraftComponentMapper = productDraftComponentMapper;
        this.productVersionMapper = productVersionMapper;
        this.productComponentMapper = productComponentMapper;
        this.productReviewMapper = productReviewMapper;
        this.productFlowLogMapper = productFlowLogMapper;
        this.fundMapper = fundMapper;
        this.productNavGenerationService = productNavGenerationService;
        this.productHoldingSnapshotGenerationService = productHoldingSnapshotGenerationService;
        this.strategyRuleValidationService = strategyRuleValidationService;
        this.objectMapper = objectMapper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ProductCreateVO createProduct(ProductSaveDTO dto) {
        Long currentUserId = SecurityUtil.getCurrentUserId();
        List<ComponentItemDTO> components = normalizeComponents(dto.getComponents());
        validateDraftComponents(components);

        AdvisorProduct product = new AdvisorProduct();
        product.setName(dto.getName().trim());
        product.setType(dto.getType().trim());
        product.setRiskLevel(dto.getRiskLevel().trim());
        product.setStrategyCode(trimToNull(dto.getStrategyCode()));
        product.setFeatureTags(joinFeatureTags(dto.getFeatureTags()));
        product.setStatus(STATUS_DRAFT);
        product.setCreatorId(currentUserId);
        product.setCurrentVersionNo(0);
        productMapper.insert(product);

        AdvisorProductDraft draft = new AdvisorProductDraft();
        draft.setProductId(product.getId());
        draft.setBaseInfoJson(writeJson(dto.getBaseInfo()));
        draft.setParamsJson(writeJson(dto.getParams()));
        draft.setUpdatedBy(currentUserId);
        productDraftMapper.insert(draft);

        replaceDraftComponents(draft.getId(), components);
        insertFlowLog(product.getId(), null, currentUserId, FLOW_SAVE_DRAFT, "创建草稿");
        return new ProductCreateVO(product.getId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateProduct(Long productId, ProductSaveDTO dto) {
        Long currentUserId = SecurityUtil.getCurrentUserId();
        AdvisorProduct product = getOwnedProduct(productId, currentUserId);
        if (!STATUS_DRAFT.equals(product.getStatus()) && !STATUS_REJECTED.equals(product.getStatus())) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "当前状态不允许编辑草稿");
        }

        List<ComponentItemDTO> components = normalizeComponents(dto.getComponents());
        validateDraftComponents(components);

        product.setName(dto.getName().trim());
        product.setType(dto.getType().trim());
        product.setRiskLevel(dto.getRiskLevel().trim());
        product.setStrategyCode(trimToNull(dto.getStrategyCode()));
        product.setFeatureTags(joinFeatureTags(dto.getFeatureTags()));
        productMapper.updateBasicInfo(product);

        AdvisorProductDraft draft = productDraftMapper.selectByProductId(productId);
        if (draft == null) {
            throw new BusinessException(ResultCode.SYSTEM_ERROR, "产品草稿不存在");
        }
        draft.setBaseInfoJson(writeJson(dto.getBaseInfo()));
        draft.setParamsJson(writeJson(dto.getParams()));
        draft.setUpdatedBy(currentUserId);
        productDraftMapper.updateByProductId(draft);

        replaceDraftComponents(draft.getId(), components);
        insertFlowLog(productId, null, currentUserId, FLOW_SAVE_DRAFT, "更新草稿");
    }

    @Override
    public PageResult<ProductListItemVO> listProducts(String status,
                                                      String type,
                                                      String riskLevel,
                                                      String keyword,
                                                      Integer pageNum,
                                                      Integer pageSize) {
        Long currentUserId = SecurityUtil.getCurrentUserId();
        int safePageNum = pageNum == null || pageNum < 1 ? DEFAULT_PAGE_NUM : pageNum;
        int safePageSize = pageSize == null || pageSize < 1 ? DEFAULT_PAGE_SIZE : pageSize;
        int offset = (safePageNum - 1) * safePageSize;

        List<AdvisorProduct> products = productMapper.selectByCreator(
                currentUserId,
                trimToNull(status),
                trimToNull(type),
                trimToNull(riskLevel),
                trimToNull(keyword),
                offset,
                safePageSize
        );
        Long total = productMapper.countByCreator(
                currentUserId,
                trimToNull(status),
                trimToNull(type),
                trimToNull(riskLevel),
                trimToNull(keyword)
        );

        List<ProductListItemVO> records = products.stream().map(this::toListItem).toList();
        return new PageResult<>(records, total, safePageNum, safePageSize);
    }

    @Override
    public ProductDetailVO getProductDetail(Long productId) {
        Long currentUserId = SecurityUtil.getCurrentUserId();
        AdvisorProduct product = getOwnedProduct(productId, currentUserId);
        AdvisorProductDraft draft = productDraftMapper.selectByProductId(productId);
        if (draft == null) {
            throw new BusinessException(ResultCode.SYSTEM_ERROR, "产品草稿不存在");
        }

        ProductDetailVO detailVO = new ProductDetailVO();
        detailVO.setId(product.getId());
        detailVO.setName(product.getName());
        detailVO.setType(product.getType());
        detailVO.setRiskLevel(product.getRiskLevel());
        detailVO.setStrategyCode(product.getStrategyCode());
        detailVO.setFeatureTags(splitFeatureTags(product.getFeatureTags()));
        detailVO.setStatus(product.getStatus());
        detailVO.setLastRejectComment(product.getLastRejectComment());
        detailVO.setBaseInfo(readMap(draft.getBaseInfoJson()));
        detailVO.setParams(readMap(draft.getParamsJson()));
        detailVO.setComponents(productDraftComponentMapper.selectByDraftId(draft.getId()));
        detailVO.setReviewSummary(productReviewMapper.selectByProductId(productId));

        if (product.getPublishedVersionNo() != null) {
            AdvisorProductVersion publishedVersion = productVersionMapper.selectByProductAndVersionNo(
                    productId,
                    product.getPublishedVersionNo()
            );
            if (publishedVersion != null) {
                PublishedVersionVO publishedVersionVO = new PublishedVersionVO();
                publishedVersionVO.setVersionId(publishedVersion.getId());
                publishedVersionVO.setVersionNo(publishedVersion.getVersionNo());
                publishedVersionVO.setVersionStatus(publishedVersion.getVersionStatus());
                publishedVersionVO.setSubmittedAt(publishedVersion.getSubmittedAt());
                publishedVersionVO.setBaseInfo(readMap(publishedVersion.getBaseInfoJson()));
                publishedVersionVO.setParams(readMap(publishedVersion.getParamsJson()));
                publishedVersionVO.setComponents(productComponentMapper.selectByVersionId(publishedVersion.getId()));
                detailVO.setPublishedVersion(publishedVersionVO);
            }
        }

        return detailVO;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void submitProduct(Long productId) {
        Long currentUserId = SecurityUtil.getCurrentUserId();
        AdvisorProduct product = getOwnedProduct(productId, currentUserId);
        if (!STATUS_DRAFT.equals(product.getStatus()) && !STATUS_REJECTED.equals(product.getStatus())) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "当前状态不允许提交审核");
        }

        AdvisorProductDraft draft = productDraftMapper.selectByProductId(productId);
        if (draft == null) {
            throw new BusinessException(ResultCode.SYSTEM_ERROR, "产品草稿不存在");
        }
        List<DraftComponentVO> draftComponents = productDraftComponentMapper.selectByDraftId(draft.getId());
        if (draftComponents == null || draftComponents.isEmpty()) {
            throw new BusinessException(ResultCode.VALIDATE_FAILED, "产品成份不能为空");
        }

        validateDraftCompleteness(product, draft);
        validateWeightSum(draftComponents.stream().map(DraftComponentVO::getWeight).toList());

        List<Long> fundIds = draftComponents.stream().map(DraftComponentVO::getFundId).toList();
        List<FundOptionVO> enabledFunds = fundMapper.selectEnabledFundsByIds(fundIds);
        if (enabledFunds.size() != new LinkedHashSet<>(fundIds).size()) {
            throw new BusinessException(ResultCode.FUND_DISABLED, "存在不存在或已停用基金，不能提交审核");
        }
        strategyRuleValidationService.validateOrThrow(
                product.getStrategyCode(),
                product.getType(),
                draftComponents,
                null
        );
        Map<Long, FundOptionVO> fundMap = enabledFunds.stream()
                .collect(Collectors.toMap(FundOptionVO::getId, item -> item));

        AdvisorProductVersion version = new AdvisorProductVersion();
        version.setProductId(productId);
        version.setVersionNo(product.getCurrentVersionNo() + 1);
        version.setBaseInfoJson(writeJson(buildVersionBaseInfo(product, readMap(draft.getBaseInfoJson()))));
        version.setParamsJson(draft.getParamsJson());
        version.setVersionStatus(VERSION_SUBMITTED);
        version.setStatusAtSubmit(product.getStatus());
        version.setSubmittedAt(java.time.LocalDateTime.now());
        productVersionMapper.insert(version);

        List<AdvisorProductComponent> versionComponents = new ArrayList<>();
        for (DraftComponentVO item : draftComponents) {
            FundOptionVO fund = fundMap.get(item.getFundId());
            AdvisorProductComponent component = new AdvisorProductComponent();
            component.setProductVersionId(version.getId());
            component.setFundCode(fund.getFundCode());
            component.setFundName(fund.getFundName());
            component.setWeight(item.getWeight());
            versionComponents.add(component);
        }
        productComponentMapper.batchInsert(versionComponents);
        productMapper.updateStatusAndVersion(productId, STATUS_PENDING_REVIEW, version.getVersionNo());
        insertFlowLog(productId, version.getId(), currentUserId, FLOW_SUBMIT, "提交审核");
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void withdrawProduct(Long productId) {
        Long currentUserId = SecurityUtil.getCurrentUserId();
        AdvisorProduct product = getOwnedProduct(productId, currentUserId);
        if (!STATUS_PENDING_REVIEW.equals(product.getStatus())) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "当前状态不允许撤回审核");
        }

        AdvisorProductVersion submittedVersion = productVersionMapper.selectLatestSubmittedByProductId(productId);
        if (submittedVersion == null) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "不存在可撤回的待审版本");
        }

        productMapper.updateStatus(productId, STATUS_DRAFT);
        productVersionMapper.updateVersionStatus(submittedVersion.getId(), VERSION_WITHDRAWN);
        insertFlowLog(productId, submittedVersion.getId(), currentUserId, FLOW_WITHDRAW, "撤回审核");
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void offlineProduct(Long productId) {
        Long currentUserId = SecurityUtil.getCurrentUserId();
        AdvisorProduct product = getOwnedProduct(productId, currentUserId);
        if (!STATUS_PUBLISHED.equals(product.getStatus())) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "当前产品不处于可下架状态");
        }
        productMapper.updateStatus(productId, STATUS_OFFLINE);
    }

    @Override
    public void generateProductNav(Long productId) {
        Long currentUserId = SecurityUtil.getCurrentUserId();
        AdvisorProduct product = getOwnedProduct(productId, currentUserId);
        if (!STATUS_PUBLISHED.equals(product.getStatus()) || product.getPublishedVersionNo() == null) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "当前产品还没有可重算的已发布版本");
        }
        productNavGenerationService.generatePublishedProductNav(productId);
        productHoldingSnapshotGenerationService.generatePublishedHoldingSnapshot(productId);
    }

    @Override
    public List<ReviewRecordVO> listReviews(Long productId) {
        Long currentUserId = SecurityUtil.getCurrentUserId();
        getOwnedProduct(productId, currentUserId);
        return productReviewMapper.selectByProductId(productId);
    }

    private AdvisorProduct getOwnedProduct(Long productId, Long currentUserId) {
        AdvisorProduct product = productMapper.selectById(productId);
        if (product == null) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "产品不存在");
        }
        if (!Objects.equals(product.getCreatorId(), currentUserId)) {
            throw new BusinessException(ResultCode.FORBIDDEN);
        }
        return product;
    }

    private void validateDraftCompleteness(AdvisorProduct product, AdvisorProductDraft draft) {
        if (!StringUtils.hasText(product.getName())
                || !StringUtils.hasText(product.getType())
                || !StringUtils.hasText(product.getRiskLevel())) {
            throw new BusinessException(ResultCode.VALIDATE_FAILED, "产品基础信息不完整");
        }
        Map<String, Object> baseInfo = readMap(draft.getBaseInfoJson());
        if (baseInfo.isEmpty()) {
            throw new BusinessException(ResultCode.VALIDATE_FAILED, "草稿基础信息不能为空");
        }
    }

    private void validateDraftComponents(List<ComponentItemDTO> components) {
        if (components == null || components.isEmpty()) {
            return;
        }
        List<Long> fundIds = components.stream()
                .map(ComponentItemDTO::getFundId)
                .collect(Collectors.toList());
        Set<Long> distinctIds = new LinkedHashSet<>(fundIds);
        if (distinctIds.size() != fundIds.size()) {
            throw new BusinessException(ResultCode.VALIDATE_FAILED, "基金成份不能重复");
        }
        List<FundOptionVO> funds = fundMapper.selectEnabledFundsByIds(new ArrayList<>(distinctIds));
        if (funds.size() != distinctIds.size()) {
            throw new BusinessException(ResultCode.FUND_DISABLED, "存在不存在或已停用基金，不能保存草稿");
        }
    }

    private void validateWeightSum(List<BigDecimal> weights) {
        BigDecimal total = weights.stream().reduce(BigDecimal.ZERO, BigDecimal::add);
        if (total.compareTo(BigDecimal.ONE) != 0) {
            throw new BusinessException(ResultCode.WEIGHT_INVALID, "组合权重合计必须等于1");
        }
    }

    private void replaceDraftComponents(Long draftId, List<ComponentItemDTO> components) {
        productDraftComponentMapper.deleteByDraftId(draftId);
        if (components == null || components.isEmpty()) {
            return;
        }
        List<AdvisorProductDraftComponent> items = new ArrayList<>();
        for (ComponentItemDTO component : components) {
            AdvisorProductDraftComponent entity = new AdvisorProductDraftComponent();
            entity.setDraftId(draftId);
            entity.setFundId(component.getFundId());
            entity.setWeight(component.getWeight());
            items.add(entity);
        }
        productDraftComponentMapper.batchInsert(items);
    }

    private List<ComponentItemDTO> normalizeComponents(List<ComponentItemDTO> components) {
        return components == null ? List.of() : components;
    }

    private void insertFlowLog(Long productId, Long versionId, Long operatorId, String actionType, String comment) {
        AdvisorProductFlowLog flowLog = new AdvisorProductFlowLog();
        flowLog.setProductId(productId);
        flowLog.setProductVersionId(versionId);
        flowLog.setOperatorId(operatorId);
        flowLog.setActionType(actionType);
        flowLog.setComment(comment);
        productFlowLogMapper.insert(flowLog);
    }

    private ProductListItemVO toListItem(AdvisorProduct product) {
        ProductListItemVO vo = new ProductListItemVO();
        vo.setId(product.getId());
        vo.setName(product.getName());
        vo.setType(product.getType());
        vo.setRiskLevel(product.getRiskLevel());
        vo.setStatus(product.getStatus());
        vo.setFeatureTags(splitFeatureTags(product.getFeatureTags()));
        vo.setUpdatedAt(product.getUpdatedAt());
        vo.setLastRejectComment(product.getLastRejectComment());
        return vo;
    }

    private String joinFeatureTags(List<String> featureTags) {
        if (featureTags == null || featureTags.isEmpty()) {
            return null;
        }
        return featureTags.stream()
                .filter(StringUtils::hasText)
                .map(String::trim)
                .collect(Collectors.joining(","));
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

    private Map<String, Object> buildVersionBaseInfo(AdvisorProduct product, Map<String, Object> draftBaseInfo) {
        Map<String, Object> snapshot = new LinkedHashMap<>();
        snapshot.put("name", product.getName());
        snapshot.put("type", product.getType());
        snapshot.put("riskLevel", product.getRiskLevel());
        snapshot.put("strategyCode", product.getStrategyCode());
        snapshot.put("featureTags", splitFeatureTags(product.getFeatureTags()));
        snapshot.putAll(draftBaseInfo);
        return snapshot;
    }

    private String trimToNull(String value) {
        return StringUtils.hasText(value) ? value.trim() : null;
    }
}
