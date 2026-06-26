package com.finance.roboadvisor.review.support;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.product.entity.AdvisorProductVersion;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import com.finance.roboadvisor.review.vo.ReviewDetailVO;
import com.finance.roboadvisor.review.vo.ReviewDiffComponentVO;
import com.finance.roboadvisor.review.vo.ReviewDiffFieldVO;
import com.finance.roboadvisor.review.vo.ReviewVersionSummaryVO;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

public class ReviewDiffBuilder {

    private static final Set<String> MAJOR_SIGNAL_FIELDS = Set.of(
            "type",
            "riskLevel",
            "featureTags",
            "maxSingleFundWeight",
            "strategyNotes"
    );

    private final ObjectMapper objectMapper;

    public ReviewDiffBuilder(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public ReviewDiffResult build(AdvisorProductVersion currentVersion,
                                  AdvisorProductVersion baseVersion,
                                  ReviewDetailVO currentDetail,
                                  List<DraftComponentVO> baseComponents,
                                  List<DraftComponentVO> currentComponents) {
        ReviewVersionSummaryVO baseVersionSummary = toSummary(baseVersion);
        ReviewVersionSummaryVO currentVersionSummary = toSummary(currentVersion, currentDetail);
        List<ReviewDiffFieldVO> fieldDiffs = baseVersion == null
                ? List.of()
                : buildFieldDiffs(baseVersion, currentDetail);
        List<ReviewDiffComponentVO> componentDiffs = baseVersion == null
                ? List.of()
                : buildComponentDiffs(baseComponents, currentComponents);
        return new ReviewDiffResult(baseVersionSummary, currentVersionSummary, fieldDiffs, componentDiffs);
    }

    private List<ReviewDiffFieldVO> buildFieldDiffs(AdvisorProductVersion baseVersion, ReviewDetailVO currentDetail) {
        Map<String, Object> baseInfo = readMap(baseVersion.getBaseInfoJson());
        Map<String, Object> baseParams = readMap(baseVersion.getParamsJson());
        Map<String, Object> currentBaseInfo = currentDetail.getBaseInfo() == null ? Map.of() : currentDetail.getBaseInfo();
        Map<String, Object> currentParams = currentDetail.getParams() == null ? Map.of() : currentDetail.getParams();

        List<ReviewDiffFieldVO> diffs = new ArrayList<>();
        addFieldDiff(diffs, "name", "产品名称",
                valueFrom(baseInfo, "name"),
                firstNonNull(valueFrom(currentBaseInfo, "name"), nullToEmpty(currentDetail.getName())));
        addFieldDiff(diffs, "type", "产品类型",
                valueFrom(baseInfo, "type"),
                firstNonNull(valueFrom(currentBaseInfo, "type"), nullToEmpty(currentDetail.getType())));
        addFieldDiff(diffs, "riskLevel", "风险等级",
                valueFrom(baseInfo, "riskLevel"),
                firstNonNull(valueFrom(currentBaseInfo, "riskLevel"), nullToEmpty(currentDetail.getRiskLevel())));
        addFieldDiff(diffs, "featureTags", "产品标签",
                normalizeCollection(valueFrom(baseInfo, "featureTags")),
                normalizeCollection(currentDetail.getFeatureTags()));
        addFieldDiff(diffs, "productSummary", "产品简介",
                firstNonNull(valueFrom(baseInfo, "productSummary"), valueFrom(baseInfo, "intro")),
                firstNonNull(valueFrom(currentBaseInfo, "productSummary"), valueFrom(currentBaseInfo, "intro")));
        addFieldDiff(diffs, "targetCustomer", "目标客户",
                firstNonNull(valueFrom(baseInfo, "targetCustomer"), valueFrom(baseInfo, "targetUser")),
                firstNonNull(valueFrom(currentBaseInfo, "targetCustomer"), valueFrom(currentBaseInfo, "targetUser")));
        addFieldDiff(diffs, "riskTips", "风险提示",
                valueFrom(baseInfo, "riskTips"),
                valueFrom(currentBaseInfo, "riskTips"));
        addFieldDiff(diffs, "rebalanceCycleDays", "调仓周期（天）",
                valueFrom(baseParams, "rebalanceCycleDays"),
                valueFrom(currentParams, "rebalanceCycleDays"));
        addFieldDiff(diffs, "minSingleFundWeight", "单基金最小权重",
                toBigDecimal(valueFrom(baseParams, "minSingleFundWeight")),
                toBigDecimal(valueFrom(currentParams, "minSingleFundWeight")));
        addFieldDiff(diffs, "maxSingleFundWeight", "单基金最大权重",
                toBigDecimal(valueFrom(baseParams, "maxSingleFundWeight")),
                toBigDecimal(valueFrom(currentParams, "maxSingleFundWeight")));
        addFieldDiff(diffs, "investHorizonMonths", "建议持有期（月）",
                valueFrom(baseParams, "investHorizonMonths"),
                valueFrom(currentParams, "investHorizonMonths"));
        addFieldDiff(diffs, "strategyNotes", "策略说明",
                valueFrom(baseParams, "strategyNotes"),
                valueFrom(currentParams, "strategyNotes"));
        return diffs;
    }

    private void addFieldDiff(List<ReviewDiffFieldVO> diffs,
                              String fieldKey,
                              String fieldLabel,
                              Object beforeValue,
                              Object afterValue) {
        if (sameValue(beforeValue, afterValue)) {
            return;
        }
        ReviewDiffFieldVO diff = new ReviewDiffFieldVO();
        diff.setFieldKey(fieldKey);
        diff.setFieldLabel(fieldLabel);
        diff.setBeforeValue(beforeValue);
        diff.setAfterValue(afterValue);
        diff.setMajorSignal(MAJOR_SIGNAL_FIELDS.contains(fieldKey));
        diffs.add(diff);
    }

    private List<ReviewDiffComponentVO> buildComponentDiffs(List<DraftComponentVO> baseComponents,
                                                            List<DraftComponentVO> currentComponents) {
        Map<String, DraftComponentVO> baseMap = indexComponents(baseComponents);
        Map<String, DraftComponentVO> currentMap = indexComponents(currentComponents);
        LinkedHashSet<String> orderedKeys = new LinkedHashSet<>();
        orderedKeys.addAll(baseMap.keySet());
        orderedKeys.addAll(currentMap.keySet());

        List<ReviewDiffComponentVO> diffs = new ArrayList<>();
        for (String key : orderedKeys) {
            DraftComponentVO before = baseMap.get(key);
            DraftComponentVO after = currentMap.get(key);
            if (before == null && after != null) {
                diffs.add(buildComponentDiff("ADDED", null, after));
                continue;
            }
            if (before != null && after == null) {
                diffs.add(buildComponentDiff("REMOVED", before, null));
                continue;
            }
            BigDecimal beforeWeight = before == null ? null : before.getWeight();
            BigDecimal afterWeight = after == null ? null : after.getWeight();
            if (sameValue(beforeWeight, afterWeight)) {
                continue;
            }
            diffs.add(buildComponentDiff("UPDATED", before, after));
        }
        return diffs;
    }

    private ReviewDiffComponentVO buildComponentDiff(String diffType,
                                                     DraftComponentVO before,
                                                     DraftComponentVO after) {
        ReviewDiffComponentVO diff = new ReviewDiffComponentVO();
        diff.setDiffType(diffType);
        DraftComponentVO sample = after != null ? after : before;
        if (sample != null) {
            diff.setFundId(sample.getFundId());
            diff.setFundCode(sample.getFundCode());
            diff.setFundName(sample.getFundName());
        }
        BigDecimal beforeWeight = before == null ? null : before.getWeight();
        BigDecimal afterWeight = after == null ? null : after.getWeight();
        diff.setBeforeWeight(beforeWeight);
        diff.setAfterWeight(afterWeight);
        if (beforeWeight != null || afterWeight != null) {
            BigDecimal safeBefore = beforeWeight == null ? BigDecimal.ZERO : beforeWeight;
            BigDecimal safeAfter = afterWeight == null ? BigDecimal.ZERO : afterWeight;
            diff.setDeltaWeight(safeAfter.subtract(safeBefore));
        }
        return diff;
    }

    private Map<String, DraftComponentVO> indexComponents(List<DraftComponentVO> components) {
        Map<String, DraftComponentVO> map = new LinkedHashMap<>();
        if (components == null) {
            return map;
        }
        for (DraftComponentVO component : components) {
            map.put(resolveComponentKey(component), component);
        }
        return map;
    }

    private String resolveComponentKey(DraftComponentVO component) {
        if (component == null) {
            return "";
        }
        if (component.getFundId() != null) {
            return "ID:" + component.getFundId();
        }
        if (StringUtils.hasText(component.getFundCode())) {
            return "CODE:" + component.getFundCode().trim();
        }
        return "NAME:" + nullToEmpty(component.getFundName());
    }

    private ReviewVersionSummaryVO toSummary(AdvisorProductVersion version) {
        if (version == null) {
            return null;
        }
        ReviewVersionSummaryVO summary = new ReviewVersionSummaryVO();
        summary.setVersionId(version.getId());
        summary.setVersionNo(version.getVersionNo());
        summary.setVersionStatus(version.getVersionStatus());
        summary.setSubmittedAt(version.getSubmittedAt());
        return summary;
    }

    private ReviewVersionSummaryVO toSummary(AdvisorProductVersion currentVersion, ReviewDetailVO currentDetail) {
        ReviewVersionSummaryVO summary = new ReviewVersionSummaryVO();
        if (currentVersion != null) {
            summary.setVersionId(currentVersion.getId());
            summary.setVersionNo(currentVersion.getVersionNo());
            summary.setVersionStatus(currentVersion.getVersionStatus());
            summary.setSubmittedAt(currentVersion.getSubmittedAt());
            return summary;
        }
        summary.setVersionId(currentDetail.getVersionId());
        summary.setVersionNo(currentDetail.getVersionNo());
        summary.setVersionStatus(currentDetail.getVersionStatus());
        summary.setSubmittedAt(currentDetail.getSubmittedAt());
        return summary;
    }

    private Map<String, Object> readMap(String json) {
        if (!StringUtils.hasText(json)) {
            return Map.of();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<Map<String, Object>>() {
            });
        } catch (Exception ex) {
            throw new IllegalStateException("Failed to parse version snapshot json", ex);
        }
    }

    private Object valueFrom(Map<String, Object> map, String key) {
        return map == null ? null : map.get(key);
    }

    private Object firstNonNull(Object primary, Object secondary) {
        return primary != null ? primary : secondary;
    }

    private Object normalizeCollection(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Collection<?> collection) {
            return collection.stream()
                    .filter(Objects::nonNull)
                    .map(String::valueOf)
                    .map(String::trim)
                    .filter(StringUtils::hasText)
                    .toList();
        }
        return value;
    }

    private BigDecimal toBigDecimal(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof BigDecimal decimal) {
            return decimal;
        }
        if (value instanceof Number number) {
            return BigDecimal.valueOf(number.doubleValue());
        }
        String text = String.valueOf(value).trim();
        return text.isEmpty() ? null : new BigDecimal(text);
    }

    private String nullToEmpty(String value) {
        return value == null ? "" : value;
    }

    private boolean sameValue(Object beforeValue, Object afterValue) {
        if (beforeValue instanceof BigDecimal || afterValue instanceof BigDecimal
                || beforeValue instanceof Number || afterValue instanceof Number) {
            BigDecimal before = toBigDecimal(beforeValue);
            BigDecimal after = toBigDecimal(afterValue);
            if (before == null && after == null) {
                return true;
            }
            if (before == null || after == null) {
                return false;
            }
            return before.compareTo(after) == 0;
        }
        if (beforeValue instanceof Collection<?> || afterValue instanceof Collection<?>) {
            return Objects.equals(normalizeCollection(beforeValue), normalizeCollection(afterValue));
        }
        return Objects.equals(beforeValue, afterValue);
    }

    public static class ReviewDiffResult {

        private final ReviewVersionSummaryVO baseVersionSummary;
        private final ReviewVersionSummaryVO currentVersionSummary;
        private final List<ReviewDiffFieldVO> fieldDiffs;
        private final List<ReviewDiffComponentVO> componentDiffs;

        public ReviewDiffResult(ReviewVersionSummaryVO baseVersionSummary,
                                ReviewVersionSummaryVO currentVersionSummary,
                                List<ReviewDiffFieldVO> fieldDiffs,
                                List<ReviewDiffComponentVO> componentDiffs) {
            this.baseVersionSummary = baseVersionSummary;
            this.currentVersionSummary = currentVersionSummary;
            this.fieldDiffs = fieldDiffs;
            this.componentDiffs = componentDiffs;
        }

        public ReviewVersionSummaryVO getBaseVersionSummary() {
            return baseVersionSummary;
        }

        public ReviewVersionSummaryVO getCurrentVersionSummary() {
            return currentVersionSummary;
        }

        public List<ReviewDiffFieldVO> getFieldDiffs() {
            return fieldDiffs;
        }

        public List<ReviewDiffComponentVO> getComponentDiffs() {
            return componentDiffs;
        }
    }
}
