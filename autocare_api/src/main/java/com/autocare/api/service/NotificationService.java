package com.autocare.api.service;

import com.autocare.api.entity.Booking;
import com.autocare.api.entity.Notification;
import com.autocare.api.entity.User;
import com.autocare.api.repository.BookingRepository;
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
    private final BookingRepository bookingRepository;

    public NotificationService(
            NotificationRepository notificationRepository,
            UserRepository userRepository,
            BookingRepository bookingRepository
    ) {
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
        this.bookingRepository = bookingRepository;
    }

    // ── Lấy tất cả thông báo của user hiện tại ───────────────────────────────
    public List<Notification> getMyNotifications() {
        User currentUser = getCurrentUser();
        return notificationRepository
                .findByUser_IdOrderByCreatedAtDesc(currentUser.getId());
    }

    // ── Lấy thông báo chưa đọc ───────────────────────────────────────────────
    public List<Notification> getMyUnreadNotifications() {
        User currentUser = getCurrentUser();
        return notificationRepository
                .findByUser_IdAndIsReadFalseOrderByCreatedAtDesc(currentUser.getId());
    }

    // ── Đếm badge chưa đọc ───────────────────────────────────────────────────
    public long countUnread() {
        User currentUser = getCurrentUser();
        return notificationRepository
                .countByUser_IdAndIsReadFalse(currentUser.getId());
    }

    // ── Đánh dấu 1 thông báo đã đọc ─────────────────────────────────────────
    public Notification markAsRead(Integer notificationId) {
        User currentUser = getCurrentUser();

        Notification notification = notificationRepository
                .findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông báo"));

        if (!notification.getUserId().equals(currentUser.getId())) {
            throw new RuntimeException("Bạn không có quyền thực hiện thao tác này");
        }

        notification.setIsRead(true);
        return notificationRepository.save(notification);
    }

    // ── Đánh dấu tất cả đã đọc ───────────────────────────────────────────────
    public void markAllAsRead() {
        User currentUser = getCurrentUser();
        List<Notification> unread = notificationRepository
                .findByUser_IdAndIsReadFalseOrderByCreatedAtDesc(currentUser.getId());
        unread.forEach(n -> n.setIsRead(true));
        notificationRepository.saveAll(unread);
    }

    // ── Gửi thông báo (gọi nội bộ từ BookingStatusLogService) ────────────────
    public Notification send(Integer userId, Integer bookingId,
                             String type, String title, String body) {
        validateNotificationFields(type, title, body);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user #" + userId));

        // Lấy booking object nếu có bookingId
        Booking booking = null;
        if (bookingId != null) {
            booking = bookingRepository.findById(bookingId).orElse(null);
        }

        Notification notification = Notification.builder()
                .user(user)
                .booking(booking)
                .type(type)
                .title(title)
                .body(body)
                .isRead(false)
                .build();

        return notificationRepository.save(notification);
    }

    // ── Xoá thông báo ────────────────────────────────────────────────────────
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
        if (isBlank(type))  throw new RuntimeException("Loại thông báo không được để trống");
        if (isBlank(title)) throw new RuntimeException("Tiêu đề không được để trống");
        if (isBlank(body))  throw new RuntimeException("Nội dung không được để trống");
    }

    // ── Helper ───────────────────────────────────────────────────────────────
    private User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getName() == null) {
            throw new RuntimeException("Bạn chưa đăng nhập");
        }
        return userRepository
                .findByEmailOrPhone(auth.getName(), auth.getName())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}