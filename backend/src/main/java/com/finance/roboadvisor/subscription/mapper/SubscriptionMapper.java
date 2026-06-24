package com.finance.roboadvisor.subscription.mapper;

import com.finance.roboadvisor.subscription.entity.AdvisorProductSubscription;
import com.finance.roboadvisor.subscription.vo.MySubscriptionItemVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SubscriptionMapper {

    AdvisorProductSubscription selectByUserIdAndProductId(@Param("userId") Long userId,
                                                          @Param("productId") Long productId);

    int insert(AdvisorProductSubscription subscription);

    int updateStatusToActive(@Param("id") Long id);

    int updateStatusToCancelled(@Param("id") Long id);

    List<MySubscriptionItemVO> selectSubscriptionsByUserId(@Param("userId") Long userId);
}
