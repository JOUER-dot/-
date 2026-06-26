package com.finance.roboadvisor.notification.mapper;

import com.finance.roboadvisor.notification.entity.Notification;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface NotificationMapper {

    int insert(Notification notification);

    List<Notification> selectByUserId(@Param("userId") Long userId,
                                      @Param("offset") Integer offset,
                                      @Param("pageSize") Integer pageSize);

    long countUnreadByUserId(@Param("userId") Long userId);

    int markAsRead(@Param("id") Long id);

    int markAllAsReadByUserId(@Param("userId") Long userId);
}
