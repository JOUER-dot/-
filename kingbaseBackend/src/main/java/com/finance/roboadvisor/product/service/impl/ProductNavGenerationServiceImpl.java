package com.finance.roboadvisor.product.service.impl;

import com.finance.roboadvisor.common.api.ResultCode;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.fund.entity.FundNav;
import com.finance.roboadvisor.fund.mapper.FundNavMapper;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.entity.AdvisorProductNav;
import com.finance.roboadvisor.product.entity.AdvisorProductVersion;
import com.finance.roboadvisor.product.mapper.ProductComponentMapper;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.product.mapper.ProductNavMapper;
import com.finance.roboadvisor.product.mapper.ProductVersionMapper;
import com.finance.roboadvisor.product.service.ProductNavGenerationService;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.stream.Collectors;

@Service
public class ProductNavGenerationServiceImpl implements ProductNavGenerationService {

    private static final String STATUS_PUBLISHED = "PUBLISHED";
    private static final int NAV_SCALE = 8;

    private final ProductMapper productMapper;
    private final ProductVersionMapper productVersionMapper;
    private final ProductComponentMapper productComponentMapper;
    private final FundNavMapper fundNavMapper;
    private final ProductNavMapper productNavMapper;

    public ProductNavGenerationServiceImpl(ProductMapper productMapper,
                                           ProductVersionMapper productVersionMapper,
                                           ProductComponentMapper productComponentMapper,
                                           FundNavMapper fundNavMapper,
                                           ProductNavMapper productNavMapper) {
        this.productMapper = productMapper;
        this.productVersionMapper = productVersionMapper;
        this.productComponentMapper = productComponentMapper;
        this.fundNavMapper = fundNavMapper;
        this.productNavMapper = productNavMapper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void generatePublishedProductNav(Long productId) {
        AdvisorProduct product = productMapper.selectById(productId);
        if (product == null) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "产品不存在");
        }
        if (!STATUS_PUBLISHED.equals(product.getStatus()) || product.getPublishedVersionNo() == null) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "当前产品还没有可生成净值的已发布版本");
        }

        AdvisorProductVersion version = productVersionMapper.selectByProductAndVersionNo(
                productId,
                product.getPublishedVersionNo()
        );
        if (version == null) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "已发布版本不存在，不能生成净值");
        }

        List<DraftComponentVO> components = productComponentMapper.selectByVersionId(version.getId());
        if (components == null || components.isEmpty()) {
            throw new BusinessException(ResultCode.VALIDATE_FAILED, "已发布版本缺少产品成份，不能生成净值");
        }
        validateWeightSum(components);

        List<String> fundCodes = components.stream()
                .map(DraftComponentVO::getFundCode)
                .collect(Collectors.toCollection(LinkedHashSet::new))
                .stream()
                .toList();
        List<FundNav> fundNavList = fundNavMapper.selectByFundCodes(fundCodes);
        if (fundNavList == null || fundNavList.isEmpty()) {
            throw new BusinessException(ResultCode.FUND_NOT_FOUND, "基金历史净值不存在，不能生成组合净值");
        }

        Map<String, Map<LocalDate, BigDecimal>> navMapByFundCode = buildNavMap(fundNavList);
        ensureEveryFundHasNav(components, navMapByFundCode);

        List<LocalDate> commonDates = resolveCommonDates(components, navMapByFundCode);
        if (commonDates.isEmpty()) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "基金历史净值日期没有交集，不能生成组合净值");
        }

        LocalDate baseDate = commonDates.get(0);
        List<AdvisorProductNav> productNavList = new ArrayList<>();
        for (LocalDate navDate : commonDates) {
            BigDecimal nav = BigDecimal.ZERO;
            for (DraftComponentVO component : components) {
                Map<LocalDate, BigDecimal> navByDate = navMapByFundCode.get(component.getFundCode());
                BigDecimal baseNav = navByDate.get(baseDate);
                BigDecimal currentNav = navByDate.get(navDate);
                BigDecimal normalizedNav = currentNav.divide(baseNav, NAV_SCALE, RoundingMode.HALF_UP);
                nav = nav.add(component.getWeight().multiply(normalizedNav));
            }

            AdvisorProductNav productNav = new AdvisorProductNav();
            productNav.setProductId(productId);
            productNav.setNavDate(navDate);
            productNav.setNav(nav.setScale(NAV_SCALE, RoundingMode.HALF_UP));
            productNav.setCumReturn(productNav.getNav()
                    .subtract(BigDecimal.ONE)
                    .setScale(NAV_SCALE, RoundingMode.HALF_UP));
            productNavList.add(productNav);
        }

        productNavMapper.deleteByProductId(productId);
        if (!productNavList.isEmpty()) {
            productNavMapper.batchInsert(productNavList);
        }
    }

    private Map<String, Map<LocalDate, BigDecimal>> buildNavMap(List<FundNav> fundNavList) {
        Map<String, Map<LocalDate, BigDecimal>> navMapByFundCode = new LinkedHashMap<>();
        for (FundNav fundNav : fundNavList) {
            navMapByFundCode
                    .computeIfAbsent(fundNav.getFundCode(), key -> new LinkedHashMap<>())
                    .put(fundNav.getNavDate(), fundNav.getNav());
        }
        return navMapByFundCode;
    }

    private void ensureEveryFundHasNav(List<DraftComponentVO> components,
                                       Map<String, Map<LocalDate, BigDecimal>> navMapByFundCode) {
        for (DraftComponentVO component : components) {
            Map<LocalDate, BigDecimal> navByDate = navMapByFundCode.get(component.getFundCode());
            if (navByDate == null || navByDate.isEmpty()) {
                throw new BusinessException(
                        ResultCode.FUND_NOT_FOUND,
                        "基金[" + component.getFundCode() + "-" + component.getFundName() + "]缺少历史净值数据"
                );
            }
        }
    }

    private List<LocalDate> resolveCommonDates(List<DraftComponentVO> components,
                                               Map<String, Map<LocalDate, BigDecimal>> navMapByFundCode) {
        Set<LocalDate> commonDates = null;
        for (DraftComponentVO component : components) {
            Set<LocalDate> navDates = new TreeSet<>(navMapByFundCode.get(component.getFundCode()).keySet());
            if (commonDates == null) {
                commonDates = new TreeSet<>(navDates);
                continue;
            }
            commonDates.retainAll(navDates);
        }
        if (commonDates == null) {
            return List.of();
        }
        return commonDates.stream()
                .sorted(Comparator.naturalOrder())
                .toList();
    }

    private void validateWeightSum(List<DraftComponentVO> components) {
        BigDecimal total = components.stream()
                .map(DraftComponentVO::getWeight)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        if (total.compareTo(BigDecimal.ONE) != 0) {
            throw new BusinessException(ResultCode.WEIGHT_INVALID, "已发布版本权重合计必须等于1");
        }
    }
}
