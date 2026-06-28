package com.finance.roboadvisor.notification.service.impl;

import com.finance.roboadvisor.auth.entity.SysUser;
import com.finance.roboadvisor.auth.security.LoginUser;
import com.finance.roboadvisor.notification.entity.Notification;
import com.finance.roboadvisor.notification.mapper.NotificationMapper;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class NotificationServiceImplTest {

    @Mock private NotificationMapper notificationMapper;

    @InjectMocks
    private NotificationServiceImpl notificationService;

    @BeforeEach
    void setUp() {
        SysUser user = new SysUser();
        user.setId(2L);
        user.setUsername("testuser");
        user.setStatus(1);
        LoginUser loginUser = new LoginUser(user, List.of("USER"));
        Authentication auth = new UsernamePasswordAuthenticationToken(loginUser, null, loginUser.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(auth);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void testCreateNotification() {
        notificationService.createNotification(2L, "测试标题", "测试内容", "SYSTEM", "/notifications");

        verify(notificationMapper).insert(argThat(n ->
                n.getUserId() == 2L &&
                "测试标题".equals(n.getTitle()) &&
                "测试内容".equals(n.getContent()) &&
                "SYSTEM".equals(n.getType()) &&
                !n.getRead() &&
                "/notifications".equals(n.getRelatedUrl())
        ));
    }

    @Test
    void testCreateNotificationWithNullUrl() {
        notificationService.createNotification(2L, "标题", "内容", "SYSTEM", null);

        verify(notificationMapper).insert(argThat(n ->
                n.getRelatedUrl() == null
        ));
    }

    @Test
    void testGetMyNotifications() {
        Notification notif = new Notification();
        notif.setId(1L);
        notif.setTitle("通知1");
        notif.setRead(false);

        when(notificationMapper.selectByUserId(eq(2L), eq(0), eq(20))).thenReturn(List.of(notif));

        List<Notification> result = notificationService.getMyNotifications(1, 20);

        assertEquals(1, result.size());
        assertEquals("通知1", result.get(0).getTitle());
    }

    @Test
    void testGetMyNotificationsDefaultPagination() {
        when(notificationMapper.selectByUserId(eq(2L), eq(0), eq(20))).thenReturn(List.of());

        List<Notification> result = notificationService.getMyNotifications(null, null);

        assertTrue(result.isEmpty());
    }

    @Test
    void testGetUnreadCount() {
        when(notificationMapper.countUnreadByUserId(2L)).thenReturn(5L);

        long count = notificationService.getUnreadCount();

        assertEquals(5L, count);
    }

    @Test
    void testGetUnreadCountZero() {
        when(notificationMapper.countUnreadByUserId(2L)).thenReturn(0L);

        long count = notificationService.getUnreadCount();

        assertEquals(0L, count);
    }

    @Test
    void testMarkAsRead() {
        notificationService.markAsRead(100L);

        verify(notificationMapper).markAsRead(100L);
    }

    @Test
    void testMarkAllAsRead() {
        notificationService.markAllAsRead();

        verify(notificationMapper).markAllAsReadByUserId(2L);
    }
}
