package com.finance.roboadvisor.subscription.mapper;

import com.finance.roboadvisor.subscription.entity.SubscriptionVersionAction;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface SubscriptionVersionActionMapper {

    int insert(SubscriptionVersionAction action);

    int updateStatus(@Param("id") Long id,
                     @Param("actionStatus") String actionStatus);

    List<SubscriptionVersionAction> selectPendingByUserId(@Param("userId") Long userId);

    List<SubscriptionVersionAction> selectPendingBySubscriptionIds(@Param("subscriptionIds") List<Long> subscriptionIds);

    SubscriptionVersionAction selectLatestPendingBySubscriptionId(@Param("subscriptionId") Long subscriptionId);
}
