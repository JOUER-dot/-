package com.finance.roboadvisor.product.service.impl;

import com.finance.roboadvisor.fund.entity.FundNav;
import com.finance.roboadvisor.fund.mapper.FundNavMapper;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.entity.AdvisorProductNav;
import com.finance.roboadvisor.product.entity.AdvisorProductVersion;
import com.finance.roboadvisor.product.mapper.ProductComponentMapper;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.product.mapper.ProductNavMapper;
import com.finance.roboadvisor.product.mapper.ProductVersionMapper;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ProductNavGenerationServiceImplTest {

    @Mock
    private ProductMapper productMapper;

    @Mock
    private ProductVersionMapper productVersionMapper;

    @Mock
    private ProductComponentMapper productComponentMapper;

    @Mock
    private FundNavMapper fundNavMapper;

    @Mock
    private ProductNavMapper productNavMapper;

    @Test
    void generatePublishedProductNav_shouldCalculateWeightedNormalizedNavSeries() {
        AdvisorProduct product = new AdvisorProduct();
        product.setId(1L);
        product.setStatus("PUBLISHED");
        product.setPublishedVersionNo(2);

        AdvisorProductVersion version = new AdvisorProductVersion();
        version.setId(11L);
        version.setProductId(1L);
        version.setVersionNo(2);

        DraftComponentVO fundA = new DraftComponentVO();
        fundA.setFundCode("110022");
        fundA.setFundName("易方达消费行业股票");
        fundA.setWeight(new BigDecimal("0.6000"));

        DraftComponentVO fundB = new DraftComponentVO();
        fundB.setFundCode("003095");
        fundB.setFundName("中欧医疗健康混合");
        fundB.setWeight(new BigDecimal("0.4000"));

        when(productMapper.selectById(1L)).thenReturn(product);
        when(productVersionMapper.selectByProductAndVersionNo(1L, 2)).thenReturn(version);
        when(productComponentMapper.selectByVersionId(11L)).thenReturn(List.of(fundA, fundB));
        when(fundNavMapper.selectByFundCodes(List.of("110022", "003095"))).thenReturn(List.of(
                nav("110022", "易方达消费行业股票", "2026-06-01", "1.00000000"),
                nav("110022", "易方达消费行业股票", "2026-06-02", "1.10000000"),
                nav("110022", "易方达消费行业股票", "2026-06-03", "1.20000000"),
                nav("003095", "中欧医疗健康混合", "2026-06-01", "2.00000000"),
                nav("003095", "中欧医疗健康混合", "2026-06-02", "2.10000000"),
                nav("003095", "中欧医疗健康混合", "2026-06-03", "2.20000000")
        ));

        ProductNavGenerationServiceImpl service = new ProductNavGenerationServiceImpl(
                productMapper,
                productVersionMapper,
                productComponentMapper,
                fundNavMapper,
                productNavMapper
        );

        service.generatePublishedProductNav(1L);

        verify(productNavMapper).deleteByProductId(1L);
        ArgumentCaptor<List<AdvisorProductNav>> captor = ArgumentCaptor.forClass(List.class);
        verify(productNavMapper).batchInsert(captor.capture());
        List<AdvisorProductNav> navList = captor.getValue();

        assertThat(navList).hasSize(3);
        assertThat(navList.get(0).getNavDate()).isEqualTo(LocalDate.parse("2026-06-01"));
        assertThat(navList.get(0).getNav()).isEqualByComparingTo("1.00000000");
        assertThat(navList.get(0).getCumReturn()).isEqualByComparingTo("0.00000000");
        assertThat(navList.get(1).getNav()).isEqualByComparingTo("1.08000000");
        assertThat(navList.get(1).getCumReturn()).isEqualByComparingTo("0.08000000");
        assertThat(navList.get(2).getNav()).isEqualByComparingTo("1.16000000");
        assertThat(navList.get(2).getCumReturn()).isEqualByComparingTo("0.16000000");
    }

    private FundNav nav(String fundCode, String fundName, String navDate, String navValue) {
        FundNav item = new FundNav();
        item.setFundCode(fundCode);
        item.setFundName(fundName);
        item.setNavDate(LocalDate.parse(navDate));
        item.setNav(new BigDecimal(navValue));
        return item;
    }
}
