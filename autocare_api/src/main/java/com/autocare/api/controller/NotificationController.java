package com.autocare.api.controller;

import com.autocare.api.dto.response.NotificationResponse;
import com.autocare.api.entity.Notification;
import com.autocare.api.service.NotificationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin("*")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    // GET /api/notifications
    // Lấy tất cả thông báo của user hiện tại
    @GetMapping
    public ResponseEntity<List<NotificationResponse>> getMyNotifications() {
        List<NotificationResponse> notifications = notificationService
                .getMyNotifications()
                .stream()
                .map(NotificationResponse::new)
                .collect(Collectors.toList());

        return ResponseEntity.ok(notifications);
    }

    // GET /api/notifications/unread
    // Lấy thông báo chưa đọc
    @GetMapping("/unread")
    public ResponseEntity<List<NotificationResponse>> getUnread() {
        List<NotificationResponse> notifications = notificationService
                .getMyUnreadNotifications()
                .stream()
                .map(NotificationResponse::new)
                .collect(Collectors.toList());

        return ResponseEntity.ok(notifications);
    }

    // GET /api/notifications/unread/count
    // Đếm số thông báo chưa đọc → hiển thị badge trên app
    @GetMapping("/unread/count")
    public ResponseEntity<Map<String, Long>> countUnread() {
        long count = notificationService.countUnread();
        return ResponseEntity.ok(Map.of("count", count));
    }

    // PATCH /api/notifications/{id}/read
    // Đánh dấu 1 thông báo đã đọc
    @PatchMapping("/{id}/read")
    public ResponseEntity<NotificationResponse> markAsRead(
            @PathVariable Integer id
    ) {
        Notification notification = notificationService.markAsRead(id);
        return ResponseEntity.ok(new NotificationResponse(notification));
    }

    // PATCH /api/notifications/read-all
    // Đánh dấu tất cả đã đọc
    @PatchMapping("/read-all")
    public ResponseEntity<Map<String, String>> markAllAsRead() {
        notificationService.markAllAsRead();
        return ResponseEntity.ok(Map.of("message", "Đã đánh dấu tất cả thông báo là đã đọc"));
    }

    // DELETE /api/notifications/{id}
    // Xoá 1 thông báo
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> deleteNotification(
            @PathVariable Integer id
    ) {
        notificationService.deleteNotification(id);
        return ResponseEntity.ok(Map.of("message", "Xoá thông báo thành công"));
    }
}