package com.finance.roboadvisor.riskprofile.service.impl;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.common.api.ResultCode;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.common.util.SecurityUtil;
import com.finance.roboadvisor.riskprofile.dto.RiskAssessmentSubmitDTO;
import com.finance.roboadvisor.riskprofile.entity.UserRiskAssessment;
import com.finance.roboadvisor.riskprofile.entity.UserRiskAssessmentAnswer;
import com.finance.roboadvisor.riskprofile.entity.UserRiskProfile;
import com.finance.roboadvisor.riskprofile.mapper.UserRiskProfileMapper;
import com.finance.roboadvisor.riskprofile.service.RiskProfileService;
import com.finance.roboadvisor.riskprofile.vo.RiskProfileVO;
import com.finance.roboadvisor.subscription.mapper.SubscriptionMapper;
import com.finance.roboadvisor.subscription.vo.MySubscriptionItemVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class RiskProfileServiceImpl implements RiskProfileService {

    private static final Logger log = LoggerFactory.getLogger(RiskProfileServiceImpl.class);

    private final UserRiskProfileMapper riskProfileMapper;
    private final SubscriptionMapper subscriptionMapper;
    private final ObjectMapper objectMapper;

    public RiskProfileServiceImpl(UserRiskProfileMapper riskProfileMapper,
                                  SubscriptionMapper subscriptionMapper,
                                  ObjectMapper objectMapper) {
        this.riskProfileMapper = riskProfileMapper;
        this.subscriptionMapper = subscriptionMapper;
        this.objectMapper = objectMapper;
    }

    @Override
    public RiskProfileVO getCurrentProfile() {
        try {
            Long userId = SecurityUtil.getCurrentUserId();
            UserRiskProfile profile = riskProfileMapper.selectProfileByUserId(userId);
            return toVO(profile, userId);
        } catch (Exception e) {
            log.warn("Failed to get risk profile, returning unassessed", e);
            RiskProfileVO vo = new RiskProfileVO();
            vo.setAssessed(false);
            vo.setRiskLevel("UNKNOWN");
            vo.setRiskLabel("未测评");
            vo.setProfileSummary("完成风险测评后，系统会生成你的风险承受能力、投资偏好和产品匹配建议。");
            vo.setProfileTags(List.of("待测评"));
            vo.setSuggestions(List.of("先完成风险测评", "订阅前确认产品风险等级", "不要只看历史收益"));
            vo.setExposureSummary(new RiskProfileVO.ExposureSummary());
            return vo;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public RiskProfileVO submitAssessment(RiskAssessmentSubmitDTO dto) {
        Long userId = SecurityUtil.getCurrentUserId();
        if (dto == null) {
            throw new BusinessException(ResultCode.VALIDATE_FAILED, "风险测评不能为空");
        }

        RiskScore score = calculateScore(dto);
        List<String> tags = buildTags(dto, score);
        String summary = buildSummary(dto, score);
        LocalDateTime now = LocalDateTime.now();

        UserRiskAssessment assessment = new UserRiskAssessment();
        assessment.setUserId(userId);
        assessment.setAssessmentNo("RA" + now.format(DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS")) + userId + UUID.randomUUID().toString().substring(0, 6));
        assessment.setQuestionnaireVersion("v1");
        assessment.setRiskLevel(score.riskLevel());
        assessment.setRiskScore(score.totalScore());
        assessment.setCapacityScore(score.capacityScore());
        assessment.setAttitudeScore(score.attitudeScore());
        assessment.setKnowledgeScore(score.knowledgeScore());
        assessment.setLiquidityScore(score.liquidityScore());
        assessment.setInvestmentHorizonMonths(dto.getInvestmentHorizonMonths());
        assessment.setMaxDrawdownTolerance(dto.getMaxDrawdownTolerance());
        assessment.setResultSummary(summary);
        assessment.setSource("QUESTIONNAIRE");
        assessment.setRawResultJson(writeJson(Map.of(
                "incomeRange", value(dto.getIncomeRange()),
                "assetRange", value(dto.getAssetRange()),
                "investmentGoal", value(dto.getInvestmentGoal()),
                "experienceLevel", value(dto.getExperienceLevel()),
                "liquidityNeed", value(dto.getLiquidityNeed()),
                "lossReaction", value(dto.getLossReaction()),
                "productExperience", value(dto.getProductExperience()),
                "tags", tags,
                "score", score
        )));
        riskProfileMapper.insertAssessment(assessment);

        if (dto.getAnswers() != null) {
            for (RiskAssessmentSubmitDTO.AnswerItem item : dto.getAnswers()) {
                UserRiskAssessmentAnswer answer = new UserRiskAssessmentAnswer();
                answer.setAssessmentId(assessment.getId());
                answer.setQuestionCode(defaultString(item.getQuestionCode(), "UNKNOWN"));
                answer.setQuestionTitle(defaultString(item.getQuestionTitle(), "未命名题目"));
                answer.setOptionCode(item.getOptionCode());
                answer.setOptionText(item.getOptionText());
                answer.setAnswerValue(item.getAnswerValue());
                answer.setScore(item.getScore() == null ? 0 : item.getScore());
                answer.setDimension(defaultString(item.getDimension(), "OTHER"));
                riskProfileMapper.insertAssessmentAnswer(answer);
            }
        }

        UserRiskProfile profile = new UserRiskProfile();
        profile.setUserId(userId);
        profile.setRiskLevel(score.riskLevel());
        profile.setRiskScore(score.totalScore());
        profile.setCapacityScore(score.capacityScore());
        profile.setAttitudeScore(score.attitudeScore());
        profile.setKnowledgeScore(score.knowledgeScore());
        profile.setLiquidityScore(score.liquidityScore());
        profile.setInvestmentHorizonMonths(dto.getInvestmentHorizonMonths());
        profile.setMaxDrawdownTolerance(dto.getMaxDrawdownTolerance());
        profile.setExperienceLevel(dto.getExperienceLevel());
        profile.setInvestmentGoal(dto.getInvestmentGoal());
        profile.setLiquidityNeed(dto.getLiquidityNeed());
        profile.setIncomeRange(dto.getIncomeRange());
        profile.setAssetRange(dto.getAssetRange());
        profile.setProfileTags(writeJson(tags));
        profile.setProfileSummary(summary);
        profile.setSource("QUESTIONNAIRE");
        profile.setStatus("ACTIVE");
        profile.setAssessedAt(now);
        profile.setExpiresAt(now.plusYears(1));

        UserRiskProfile existing = riskProfileMapper.selectProfileByUserId(userId);
        if (existing == null) {
            riskProfileMapper.insertProfile(profile);
        } else {
            profile.setId(existing.getId());
            riskProfileMapper.updateProfile(profile);
        }
        return toVO(riskProfileMapper.selectProfileByUserId(userId), userId);
    }

    private RiskScore calculateScore(RiskAssessmentSubmitDTO dto) {
        int capacity = average(
                scoreByMap(dto.getIncomeRange(), Map.of("LOW", 20, "MID", 45, "HIGH", 70, "VERY_HIGH", 90), 40),
                scoreByMap(dto.getAssetRange(), Map.of("LOW", 20, "MID", 45, "HIGH", 70, "VERY_HIGH", 90), 40),
                scoreByHorizon(dto.getInvestmentHorizonMonths()),
                scoreByMap(dto.getLiquidityNeed(), Map.of("HIGH", 25, "MEDIUM", 55, "LOW", 85), 50)
        );
        int attitude = average(
                scoreByDrawdown(dto.getMaxDrawdownTolerance()),
                scoreByMap(dto.getInvestmentGoal(), Map.of("LIQUIDITY", 20, "STABLE", 35, "GROWTH", 65, "AGGRESSIVE", 88, "RETIREMENT", 45), 45),
                scoreByMap(dto.getLossReaction(), Map.of("SELL_ALL", 15, "REDUCE", 35, "HOLD", 65, "ADD", 85), 45)
        );
        int knowledge = average(
                scoreByMap(dto.getExperienceLevel(), Map.of("NEW", 20, "BEGINNER", 40, "EXPERIENCED", 70, "PROFESSIONAL", 90), 35),
                scoreByMap(dto.getProductExperience(), Map.of("DEPOSIT", 20, "FUND", 45, "STOCK", 70, "DERIVATIVE", 90), 35)
        );
        int liquidity = scoreByMap(dto.getLiquidityNeed(), Map.of("HIGH", 25, "MEDIUM", 55, "LOW", 85), 50);
        int total = clamp(Math.round(capacity * 0.35F + attitude * 0.30F + knowledge * 0.20F + liquidity * 0.15F));
        return new RiskScore(capacity, attitude, knowledge, liquidity, total, riskLevel(total));
    }

    private RiskProfileVO toVO(UserRiskProfile profile, Long userId) {
        RiskProfileVO vo = new RiskProfileVO();
        if (profile == null) {
            vo.setAssessed(false);
            vo.setRiskLevel("UNKNOWN");
            vo.setRiskLabel("未测评");
            vo.setProfileSummary("完成风险测评后，系统会生成你的风险承受能力、投资偏好和产品匹配建议。");
            vo.setProfileTags(List.of("待测评"));
            vo.setSuggestions(List.of("先完成风险测评", "订阅前确认产品风险等级", "不要只看历史收益"));
            vo.setExposureSummary(buildExposure(userId, null));
            return vo;
        }
        vo.setAssessed(true);
        vo.setRiskLevel(profile.getRiskLevel());
        vo.setRiskLabel(riskLabel(profile.getRiskLevel()));
        vo.setRiskScore(profile.getRiskScore());
        vo.setCapacityScore(profile.getCapacityScore());
        vo.setAttitudeScore(profile.getAttitudeScore());
        vo.setKnowledgeScore(profile.getKnowledgeScore());
        vo.setLiquidityScore(profile.getLiquidityScore());
        vo.setInvestmentHorizonMonths(profile.getInvestmentHorizonMonths());
        vo.setMaxDrawdownTolerance(profile.getMaxDrawdownTolerance());
        vo.setExperienceLevel(profile.getExperienceLevel());
        vo.setInvestmentGoal(profile.getInvestmentGoal());
        vo.setLiquidityNeed(profile.getLiquidityNeed());
        vo.setProfileSummary(profile.getProfileSummary());
        vo.setProfileTags(readTags(profile.getProfileTags()));
        vo.setAssessedAt(profile.getAssessedAt());
        vo.setExpiresAt(profile.getExpiresAt());
        vo.setExposureSummary(buildExposure(userId, profile.getRiskLevel()));
        vo.setSuggestions(buildSuggestions(profile, vo.getExposureSummary()));
        return vo;
    }

    private RiskProfileVO.ExposureSummary buildExposure(Long userId, String userRiskLevel) {
        RiskProfileVO.ExposureSummary exposure = new RiskProfileVO.ExposureSummary();
        List<MySubscriptionItemVO> subscriptions = subscriptionMapper.selectSubscriptionsByUserId(userId);
        List<RiskProfileVO.ProductExposure> products = new ArrayList<>();
        int maxRisk = 0;
        int mismatchCount = 0;
        for (MySubscriptionItemVO item : subscriptions) {
            if (!"ACTIVE".equals(item.getStatus())) {
                continue;
            }
            int productRisk = riskRank(item.getRiskLevel());
            maxRisk = Math.max(maxRisk, productRisk);
            boolean mismatch = userRiskLevel != null && productRisk > riskRank(userRiskLevel);
            if (mismatch) mismatchCount++;
            RiskProfileVO.ProductExposure product = new RiskProfileVO.ProductExposure();
            product.setProductId(item.getProductId());
            product.setProductName(item.getProductName());
            product.setRiskLevel(item.getRiskLevel());
            product.setMatchResult(userRiskLevel == null ? "UNKNOWN" : (mismatch ? "LOWER_THAN_PRODUCT" : "MATCH"));
            products.add(product);
        }
        exposure.setActiveSubscriptionCount(products.size());
        exposure.setHighestProductRiskLevel(maxRisk == 0 ? null : "R" + maxRisk);
        exposure.setMismatchCount(mismatchCount);
        exposure.setProducts(products);
        return exposure;
    }

    private List<String> buildTags(RiskAssessmentSubmitDTO dto, RiskScore score) {
        List<String> tags = new ArrayList<>();
        tags.add(riskLabel(score.riskLevel()));
        if (dto.getInvestmentHorizonMonths() != null && dto.getInvestmentHorizonMonths() >= 36) tags.add("长期资金");
        if ("LOW".equals(dto.getLiquidityNeed())) tags.add("流动性压力低");
        if ("HIGH".equals(dto.getLiquidityNeed())) tags.add("高流动性需求");
        if (score.knowledgeScore() >= 70) tags.add("经验较丰富");
        if (score.attitudeScore() <= 35) tags.add("波动敏感");
        if ("RETIREMENT".equals(dto.getInvestmentGoal())) tags.add("养老规划");
        return tags;
    }

    private String buildSummary(RiskAssessmentSubmitDTO dto, RiskScore score) {
        String horizon = dto.getInvestmentHorizonMonths() == null ? "未明确期限" : dto.getInvestmentHorizonMonths() + "个月";
        return "你的风险画像为" + riskLabel(score.riskLevel()) + "，综合分 " + score.totalScore()
                + "，计划投资期限 " + horizon + "。建议优先关注风险等级不高于 " + score.riskLevel()
                + " 的产品，并结合资金用途确认流动性安排。";
    }

    private List<String> buildSuggestions(UserRiskProfile profile, RiskProfileVO.ExposureSummary exposure) {
        List<String> suggestions = new ArrayList<>();
        suggestions.add("优先选择风险等级不高于 " + profile.getRiskLevel() + " 的产品");
        if (exposure.getMismatchCount() != null && exposure.getMismatchCount() > 0) {
            suggestions.add("当前有 " + exposure.getMismatchCount() + " 个订阅产品风险高于你的画像，建议重点复核");
        }
        if (profile.getLiquidityScore() != null && profile.getLiquidityScore() < 45) {
            suggestions.add("你对流动性要求较高，避免把短期资金投入波动较大的组合");
        }
        suggestions.add("风险测评每年至少更新一次，收入、资产或投资目标变化后应重新测评");
        return suggestions;
    }

    private int scoreByMap(String key, Map<String, Integer> map, int fallback) {
        if (!StringUtils.hasText(key)) return fallback;
        return map.getOrDefault(key, fallback);
    }

    private int scoreByHorizon(Integer months) {
        if (months == null) return 45;
        if (months < 6) return 20;
        if (months < 12) return 35;
        if (months < 36) return 55;
        if (months < 60) return 75;
        return 90;
    }

    private int scoreByDrawdown(BigDecimal drawdown) {
        if (drawdown == null) return 40;
        double value = drawdown.doubleValue();
        if (value <= 0.03D) return 20;
        if (value <= 0.08D) return 40;
        if (value <= 0.15D) return 60;
        if (value <= 0.25D) return 78;
        return 90;
    }

    private int average(int... values) {
        int sum = 0;
        for (int value : values) sum += value;
        return clamp(Math.round((float) sum / values.length));
    }

    private int clamp(int value) {
        return Math.max(0, Math.min(100, value));
    }

    private String riskLevel(int score) {
        if (score <= 25) return "R1";
        if (score <= 40) return "R2";
        if (score <= 60) return "R3";
        if (score <= 78) return "R4";
        return "R5";
    }

    private int riskRank(String riskLevel) {
        if (!StringUtils.hasText(riskLevel)) return 0;
        try {
            return Integer.parseInt(riskLevel.replace("R", "").trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String riskLabel(String riskLevel) {
        return switch (riskLevel == null ? "" : riskLevel) {
            case "R1" -> "保守型";
            case "R2" -> "稳健型";
            case "R3" -> "平衡型";
            case "R4" -> "成长型";
            case "R5" -> "进取型";
            default -> "未测评";
        };
    }

    private List<String> readTags(String tagsJson) {
        if (!StringUtils.hasText(tagsJson)) return List.of();
        try {
            return objectMapper.readValue(tagsJson, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            return List.of();
        }
    }

    private String writeJson(Object value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (Exception e) {
            return "[]";
        }
    }

    private String value(String value) {
        return value == null ? "" : value;
    }

    private String defaultString(String value, String fallback) {
        return StringUtils.hasText(value) ? value : fallback;
    }

    private record RiskScore(
            int capacityScore,
            int attitudeScore,
            int knowledgeScore,
            int liquidityScore,
            int totalScore,
            String riskLevel
    ) {}
}
