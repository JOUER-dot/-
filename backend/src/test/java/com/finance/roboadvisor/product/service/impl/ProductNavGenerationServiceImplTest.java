package com.finance.roboadvisor.product.service.impl;

import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.fund.entity.FundNav;
import com.finance.roboadvisor.fund.mapper.FundNavMapper;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.entity.AdvisorProductNav;
import com.finance.roboadvisor.product.entity.AdvisorProductVersion;
import com.finance.roboadvisor.product.mapper.*;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class ProductNavGenerationServiceImplTest {

    @Mock private ProductMapper productMapper;
    @Mock private ProductVersionMapper productVersionMapper;
    @Mock private ProductComponentMapper productComponentMapper;
    @Mock private FundNavMapper fundNavMapper;
    @Mock private ProductNavMapper productNavMapper;

    @InjectMocks
    private ProductNavGenerationServiceImpl navGenerationService;

    private AdvisorProduct createPublishedProduct(Long id, Integer publishedVersionNo) {
        AdvisorProduct p = new AdvisorProduct();
        p.setId(id);
        p.setName("测试产品");
        p.setType("STRATEGY");
        p.setStatus("PUBLISHED");
        p.setPublishedVersionNo(publishedVersionNo);
        return p;
    }

    private AdvisorProductVersion createVersion(Long id, Long productId, Integer versionNo) {
        AdvisorProductVersion v = new AdvisorProductVersion();
        v.setId(id);
        v.setProductId(productId);
        v.setVersionNo(versionNo);
        return v;
    }

    private DraftComponentVO createComponent(String code, String name, BigDecimal weight) {
        DraftComponentVO c = new DraftComponentVO();
        c.setFundCode(code);
        c.setFundName(name);
        c.setWeight(weight);
        return c;
    }

    private FundNav createFundNav(String code, String name, LocalDate date, BigDecimal nav) {
        FundNav fn = new FundNav();
        fn.setFundCode(code);
        fn.setFundName(name);
        fn.setNavDate(date);
        fn.setNav(nav);
        return fn;
    }

    @Test
    void testGenerateNavSuccess() {
        Long productId = 1L;
        AdvisorProduct product = createPublishedProduct(productId, 1);
        when(productMapper.selectById(productId)).thenReturn(product);

        AdvisorProductVersion version = createVersion(10L, productId, 1);
        when(productVersionMapper.selectByProductAndVersionNo(productId, 1)).thenReturn(version);

        DraftComponentVO comp = createComponent("000001", "测试基金", BigDecimal.ONE);
        when(productComponentMapper.selectByVersionId(10L)).thenReturn(List.of(comp));

        FundNav nav1 = createFundNav("000001", "测试基金", LocalDate.of(2026, 6, 1), new BigDecimal("1.00000000"));
        FundNav nav2 = createFundNav("000001", "测试基金", LocalDate.of(2026, 6, 2), new BigDecimal("1.01000000"));
        when(fundNavMapper.selectByFundCodes(List.of("000001"))).thenReturn(List.of(nav1, nav2));

        navGenerationService.generatePublishedProductNav(productId);

        verify(productNavMapper).deleteByProductId(productId);
        verify(productNavMapper).batchInsert(argThat(list -> {
            List<AdvisorProductNav> navList = (List<AdvisorProductNav>) list;
            return navList.size() == 2 &&
                    navList.get(0).getNavDate().equals(LocalDate.of(2026, 6, 1)) &&
                    navList.get(0).getNav().compareTo(BigDecimal.ONE) == 0;
        }));
    }

    @Test
    void testGenerateNavProductNotFound() {
        when(productMapper.selectById(999L)).thenReturn(null);
        assertThrows(BusinessException.class,
                () -> navGenerationService.generatePublishedProductNav(999L));
    }

    @Test
    void testGenerateNavNotPublished() {
        AdvisorProduct product = createPublishedProduct(1L, null);
        product.setStatus("DRAFT");
        when(productMapper.selectById(1L)).thenReturn(product);

        assertThrows(BusinessException.class,
                () -> navGenerationService.generatePublishedProductNav(1L));
    }

    @Test
    void testGenerateNavVersionNotFound() {
        Long productId = 1L;
        AdvisorProduct product = createPublishedProduct(productId, 1);
        when(productMapper.selectById(productId)).thenReturn(product);
        when(productVersionMapper.selectByProductAndVersionNo(productId, 1)).thenReturn(null);

        assertThrows(BusinessException.class,
                () -> navGenerationService.generatePublishedProductNav(productId));
    }

    @Test
    void testGenerateNavEmptyComponents() {
        Long productId = 1L;
        AdvisorProduct product = createPublishedProduct(productId, 1);
        when(productMapper.selectById(productId)).thenReturn(product);

        AdvisorProductVersion version = createVersion(10L, productId, 1);
        when(productVersionMapper.selectByProductAndVersionNo(productId, 1)).thenReturn(version);
        when(productComponentMapper.selectByVersionId(10L)).thenReturn(List.of());

        assertThrows(BusinessException.class,
                () -> navGenerationService.generatePublishedProductNav(productId));
    }

    @Test
    void testGenerateNavFundNavNotFound() {
        Long productId = 1L;
        AdvisorProduct product = createPublishedProduct(productId, 1);
        when(productMapper.selectById(productId)).thenReturn(product);

        AdvisorProductVersion version = createVersion(10L, productId, 1);
        when(productVersionMapper.selectByProductAndVersionNo(productId, 1)).thenReturn(version);

        DraftComponentVO comp = createComponent("000001", "测试基金", BigDecimal.ONE);
        when(productComponentMapper.selectByVersionId(10L)).thenReturn(List.of(comp));
        when(fundNavMapper.selectByFundCodes(List.of("000001"))).thenReturn(List.of());

        assertThrows(BusinessException.class,
                () -> navGenerationService.generatePublishedProductNav(productId));
    }

    @Test
    void testGenerateNavWeightSumInvalid() {
        Long productId = 1L;
        AdvisorProduct product = createPublishedProduct(productId, 1);
        when(productMapper.selectById(productId)).thenReturn(product);

        AdvisorProductVersion version = createVersion(10L, productId, 1);
        when(productVersionMapper.selectByProductAndVersionNo(productId, 1)).thenReturn(version);

        DraftComponentVO comp = createComponent("000001", "测试基金", new BigDecimal("0.5"));
        when(productComponentMapper.selectByVersionId(10L)).thenReturn(List.of(comp));

        assertThrows(BusinessException.class,
                () -> navGenerationService.generatePublishedProductNav(productId));
    }
}
