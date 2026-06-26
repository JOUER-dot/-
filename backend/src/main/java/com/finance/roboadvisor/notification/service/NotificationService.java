package com.finance.roboadvisor.notification.service;

import com.finance.roboadvisor.notification.entity.Notification;

import java.util.List;

public interface NotificationService {

    void createNotification(Long userId, String title, String content, String type, String relatedUrl);

    List<Notification> getMyNotifications(Integer pageNum, Integer pageSize);

    long getUnreadCount();

    void markAsRead(Long id);

    void markAllAsRead();
}
