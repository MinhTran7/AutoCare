package com.autocare.api.service;

import com.autocare.api.entity.Notification;
import com.autocare.api.entity.User;
import com.autocare.api.repository.NotificationRepository;
import com.autocare.api.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    public NotificationService(
            NotificationRepository notificationRepository,
            UserRepository userRepository
    ) {
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
    }

    // ── Lấy tất cả thông báo của user hiện tại ───────────────────────────────
    public List<Notification> getMyNotifications() {
        User currentUser = getCurrentUser();
        return notificationRepository
                .findByUserIdOrderByCreatedAtDesc(currentUser.getId());
    }

    // ── Lấy thông báo chưa đọc ───────────────────────────────────────────────
    public List<Notification> getMyUnreadNotifications() {
        User currentUser = getCurrentUser();
        return notificationRepository
                .findByUserIdAndIsReadFalseOrderByCreatedAtDesc(currentUser.getId());
    }

    // ── Đếm thông báo chưa đọc → hiển thị badge trên app ────────────────────
    public long countUnread() {
        User currentUser = getCurrentUser();
        return notificationRepository
                .countByUserIdAndIsReadFalse(currentUser.getId());
    }

    // ── Đánh dấu 1 thông báo đã đọc ─────────────────────────────────────────
    public Notification markAsRead(Integer notificationId) {
        User currentUser = getCurrentUser();

        Notification notification = notificationRepository
                .findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông báo"));

        // Chỉ cho phép đánh dấu thông báo của chính mình
        if (!notification.getUserId().equals(currentUser.getId())) {
            throw new RuntimeException("Bạn không có quyền thực hiện thao tác này");
        }

        notification.setIsRead(true);
        return notificationRepository.save(notification);
    }

    // ── Đánh dấu tất cả thông báo đã đọc ────────────────────────────────────
    public void markAllAsRead() {
        User currentUser = getCurrentUser();

        List<Notification> unread = notificationRepository
                .findByUserIdAndIsReadFalseOrderByCreatedAtDesc(currentUser.getId());

        unread.forEach(n -> n.setIsRead(true));
        notificationRepository.saveAll(unread);
    }

    // ── Gửi thông báo (dùng nội bộ từ Service khác) ──────────────────────────
    // Ví dụ: BookingService gọi hàm này sau khi xác nhận lịch
    public Notification send(Integer userId, Integer bookingId,
                             String type, String title, String body) {
        validateNotificationFields(type, title, body);

        Notification notification = Notification.builder()
                .userId(userId)
                .bookingId(bookingId)
                .type(type)
                .title(title)
                .body(body)
                .isRead(false)
                .build();

        return notificationRepository.save(notification);
    }

    // ── Xoá 1 thông báo ──────────────────────────────────────────────────────
    public void deleteNotification(Integer notificationId) {
        User currentUser = getCurrentUser();

        Notification notification = notificationRepository
                .findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông báo"));

        if (!notification.getUserId().equals(currentUser.getId())) {
            throw new RuntimeException("Bạn không có quyền thực hiện thao tác này");
        }

        notificationRepository.delete(notification);
    }

    // ── Validate ─────────────────────────────────────────────────────────────
    private void validateNotificationFields(String type, String title, String body) {
        if (isBlank(type)) {
            throw new RuntimeException("Loại thông báo không được để trống");
        }
        if (isBlank(title)) {
            throw new RuntimeException("Tiêu đề thông báo không được để trống");
        }
        if (isBlank(body)) {
            throw new RuntimeException("Nội dung thông báo không được để trống");
        }
    }

    // ── Helper ───────────────────────────────────────────────────────────────
    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder
                .getContext()
                .getAuthentication();

        if (authentication == null || authentication.getName() == null) {
            throw new RuntimeException("Bạn chưa đăng nhập");
        }

        String emailOrPhone = authentication.getName();

        return userRepository
                .findByEmailOrPhone(emailOrPhone, emailOrPhone)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}