package com.autocare.api.service;

import com.autocare.api.entity.BookingStatusLog;
import com.autocare.api.entity.User;
import com.autocare.api.repository.BookingStatusLogRepository;
import com.autocare.api.repository.UserRepository;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
public class BookingStatusLogService {

    private final BookingStatusLogRepository bookingStatusLogRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    public BookingStatusLogService(
            BookingStatusLogRepository bookingStatusLogRepository,
            UserRepository userRepository,
            @Lazy NotificationService notificationService
    ) {
        this.bookingStatusLogRepository = bookingStatusLogRepository;
        this.userRepository = userRepository;
        this.notificationService = notificationService;
    }

    // ── Lấy toàn bộ lịch sử trạng thái của 1 booking ────────────────────────
    public List<BookingStatusLog> getTimeline(Integer bookingId) {
        return bookingStatusLogRepository
                .findByBookingIdOrderByChangedAtAsc(bookingId);
    }

    // ── Lấy trạng thái hiện tại của booking ──────────────────────────────────
    public String getCurrentStatus(Integer bookingId) {
        return bookingStatusLogRepository
                .findTopByBookingIdOrderByChangedAtDesc(bookingId)
                .map(BookingStatusLog::getNewStatus)
                .orElse("PENDING");
    }

    // ── Ghi log + tự động gửi thông báo cho khách ────────────────────────────
    public BookingStatusLog logStatusChange(Integer bookingId, String oldStatus,
                                            String newStatus, String note,
                                            Integer customerUserId) {
        User currentUser = getCurrentUser();

        String resolvedOldStatus = bookingStatusLogRepository
                .findTopByBookingIdOrderByChangedAtDesc(bookingId)
                .map(BookingStatusLog::getNewStatus)
                .orElse(null);

        validateStatusTransition(resolvedOldStatus, newStatus);

        BookingStatusLog log = BookingStatusLog.builder()
                .bookingId(bookingId)
                .oldStatus(resolvedOldStatus)
                .newStatus(newStatus)
                .changedBy(currentUser.getId())
                .note(note)
                .changedAt(LocalDateTime.now())
                .build();

        BookingStatusLog saved = bookingStatusLogRepository.save(log);

        // Tự động gửi thông báo cho khách sau khi lưu log
        if (customerUserId != null) {
            _sendStatusNotification(customerUserId, bookingId, newStatus);
        }

        return saved;
    }

    // Overload giữ tương thích với Controller cũ (không truyền customerUserId)
    public BookingStatusLog logStatusChange(Integer bookingId, String oldStatus,
                                            String newStatus, String note) {
        return logStatusChange(bookingId, oldStatus, newStatus, note, null);
    }

    // ── Gửi thông báo theo trạng thái mới ────────────────────────────────────
    private void _sendStatusNotification(Integer userId, Integer bookingId, String newStatus) {
        Map<String, String[]> messages = Map.of(
                "CONFIRMED",   new String[]{"booking_confirmed",
                        "Lịch hẹn đã được xác nhận ✓",
                        "Lịch hẹn #" + bookingId + " của bạn đã được thợ xác nhận."},
                "IN_PROGRESS", new String[]{"status_update",
                        "Xe đang được sửa chữa 🔧",
                        "Thợ đã bắt đầu thực hiện dịch vụ cho xe của bạn."},
                "COMPLETED",   new String[]{"invoice_ready",
                        "Dịch vụ hoàn thành 🎉",
                        "Xe của bạn đã sửa xong. Hoá đơn đã sẵn sàng để thanh toán."},
                "CANCELLED",   new String[]{"status_update",
                        "Lịch hẹn đã bị huỷ",
                        "Lịch hẹn #" + bookingId + " đã bị huỷ."}
        );

        if (messages.containsKey(newStatus)) {
            String[] msg = messages.get(newStatus);
            try {
                notificationService.send(userId, bookingId, msg[0], msg[1], msg[2]);
            } catch (Exception ignored) {
                // Không để lỗi notification làm hỏng luồng chính
            }
        }
    }

    // ── Kiểm tra booking đã từng ở trạng thái cụ thể chưa ───────────────────
    public boolean hasStatus(Integer bookingId, String status) {
        return bookingStatusLogRepository
                .existsByBookingIdAndNewStatus(bookingId, status);
    }

    // ── Validate luồng trạng thái hợp lệ ─────────────────────────────────────
    private void validateStatusTransition(String oldStatus, String newStatus) {
        if (oldStatus == null) return;

        boolean valid = switch (oldStatus) {
            case "PENDING"     -> newStatus.equals("CONFIRMED")   || newStatus.equals("CANCELLED");
            case "CONFIRMED"   -> newStatus.equals("IN_PROGRESS") || newStatus.equals("CANCELLED");
            case "IN_PROGRESS" -> newStatus.equals("COMPLETED");
            default            -> false;
        };

        if (!valid) {
            throw new RuntimeException(
                    "Không thể chuyển trạng thái từ " + oldStatus + " sang " + newStatus
            );
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
}