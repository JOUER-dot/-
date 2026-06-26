package com.finance.roboadvisor.notification.controller;

import com.finance.roboadvisor.common.api.ApiResult;
import com.finance.roboadvisor.notification.entity.Notification;
import com.finance.roboadvisor.notification.service.NotificationService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping
    public ApiResult<List<Notification>> listNotifications(@RequestParam(required = false) Integer pageNum,
                                                           @RequestParam(required = false) Integer pageSize) {
        return ApiResult.success(notificationService.getMyNotifications(pageNum, pageSize));
    }

    @GetMapping("/unread-count")
    public ApiResult<Map<String, Long>> getUnreadCount() {
        return ApiResult.success(Map.of("count", notificationService.getUnreadCount()));
    }

    @PostMapping("/{id}/read")
    public ApiResult<Void> markAsRead(@PathVariable("id") Long id) {
        notificationService.markAsRead(id);
        return ApiResult.success("已标记为已读");
    }

    @PostMapping("/read-all")
    public ApiResult<Void> markAllAsRead() {
        notificationService.markAllAsRead();
        return ApiResult.success("全部标记为已读");
    }
}
