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

    AdvisorProductSubscription selectById(@Param("id") Long id);

    int insert(AdvisorProductSubscription subscription);

    int updateStatusToActive(@Param("id") Long id);

    int updateStatusToCancelled(@Param("id") Long id);

    List<AdvisorProductSubscription> selectActiveSubscriptionsByProductId(@Param("productId") Long productId);

    List<MySubscriptionItemVO> selectSubscriptionsByUserId(@Param("userId") Long userId);

    List<MySubscriptionItemVO> selectSubscriptionsPageByUserId(@Param("userId") Long userId,
                                                               @Param("keyword") String keyword,
                                                               @Param("subscriptionStatus") String subscriptionStatus,
                                                               @Param("productStatus") String productStatus,
                                                               @Param("sortBy") String sortBy,
                                                               @Param("offset") Integer offset,
                                                               @Param("pageSize") Integer pageSize);

    Long countSubscriptionsByUserId(@Param("userId") Long userId,
                                    @Param("keyword") String keyword,
                                    @Param("subscriptionStatus") String subscriptionStatus,
                                    @Param("productStatus") String productStatus);

    Long countActiveByCreatorId(@Param("creatorId") Long creatorId);

    Long countRecentWeekByCreatorId(@Param("creatorId") Long creatorId);

    Long countByProductId(@Param("productId") Long productId);
}
