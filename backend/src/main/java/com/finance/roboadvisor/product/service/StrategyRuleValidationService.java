package com.finance.roboadvisor.product.service;

import com.finance.roboadvisor.product.vo.DraftComponentVO;

import java.math.BigDecimal;
import java.util.List;

public interface StrategyRuleValidationService {

    void validateOrThrow(String strategyCode,
                         String productType,
                         List<DraftComponentVO> components,
                         StrategyRuleOverride override);

    class StrategyRuleOverride {

        private Integer overrideMinFundCount;
        private Integer overrideMaxFundCount;
        private BigDecimal overrideMaxSingleWeight;

        public Integer getOverrideMinFundCount() {
            return overrideMinFundCount;
        }

        public void setOverrideMinFundCount(Integer overrideMinFundCount) {
            this.overrideMinFundCount = overrideMinFundCount;
        }

        public Integer getOverrideMaxFundCount() {
            return overrideMaxFundCount;
        }

        public void setOverrideMaxFundCount(Integer overrideMaxFundCount) {
            this.overrideMaxFundCount = overrideMaxFundCount;
        }

        public BigDecimal getOverrideMaxSingleWeight() {
            return overrideMaxSingleWeight;
        }

        public void setOverrideMaxSingleWeight(BigDecimal overrideMaxSingleWeight) {
            this.overrideMaxSingleWeight = overrideMaxSingleWeight;
        }
    }
}
