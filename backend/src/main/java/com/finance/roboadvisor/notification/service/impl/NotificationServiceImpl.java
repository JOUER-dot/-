package com.finance.roboadvisor.notification.service.impl;

import com.finance.roboadvisor.common.api.ResultCode;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.common.util.SecurityUtil;
import com.finance.roboadvisor.notification.entity.Notification;
import com.finance.roboadvisor.notification.mapper.NotificationMapper;
import com.finance.roboadvisor.notification.service.NotificationService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class NotificationServiceImpl implements NotificationService {

    private static final int DEFAULT_PAGE_SIZE = 20;

    private final NotificationMapper notificationMapper;

    public NotificationServiceImpl(NotificationMapper notificationMapper) {
        this.notificationMapper = notificationMapper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createNotification(Long userId, String title, String content, String type, String relatedUrl) {
        Notification notification = new Notification();
        notification.setUserId(userId);
        notification.setTitle(title);
        notification.setContent(content);
        notification.setType(type);
        notification.setRead(false);
        notification.setRelatedUrl(relatedUrl);
        notificationMapper.insert(notification);
    }

    @Override
    public List<Notification> getMyNotifications(Integer pageNum, Integer pageSize) {
        Long userId = SecurityUtil.getCurrentUserId();
        if (pageNum == null || pageNum < 1) pageNum = 1;
        if (pageSize == null || pageSize < 1) pageSize = DEFAULT_PAGE_SIZE;
        return notificationMapper.selectByUserId(userId, (pageNum - 1) * pageSize, pageSize);
    }

    @Override
    public long getUnreadCount() {
        Long userId = SecurityUtil.getCurrentUserId();
        return notificationMapper.countUnreadByUserId(userId);
    }

    @Override
    public void markAsRead(Long id) {
        notificationMapper.markAsRead(id);
    }

    @Override
    public void markAllAsRead() {
        Long userId = SecurityUtil.getCurrentUserId();
        notificationMapper.markAllAsReadByUserId(userId);
    }
}
