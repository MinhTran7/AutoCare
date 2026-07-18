package com.autocare.api.service;

import com.autocare.api.entity.Booking;
import com.autocare.api.entity.BookingStatusLog;
import com.autocare.api.entity.User;
import com.autocare.api.repository.BookingRepository;
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
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;

    public BookingStatusLogService(
            BookingStatusLogRepository bookingStatusLogRepository,
            BookingRepository bookingRepository,
            UserRepository userRepository,
            @Lazy NotificationService notificationService
    ) {
        this.bookingStatusLogRepository = bookingStatusLogRepository;
        this.bookingRepository = bookingRepository;
        this.userRepository = userRepository;
        this.notificationService = notificationService;
    }

    // ── Lấy toàn bộ lịch sử trạng thái ──────────────────────────────────────
    public List<BookingStatusLog> getTimeline(Integer bookingId) {
        return bookingStatusLogRepository
                .findByBooking_IdOrderByChangedAtAsc(bookingId);
    }

    // ── Lấy trạng thái hiện tại ───────────────────────────────────────────────
    public String getCurrentStatus(Integer bookingId) {
        return bookingStatusLogRepository
                .findTopByBooking_IdOrderByChangedAtDesc(bookingId)
                .map(BookingStatusLog::getNewStatus)
                .orElse("PENDING");
    }

    // ── Ghi log + tự động gửi thông báo ──────────────────────────────────────
    public BookingStatusLog logStatusChange(Integer bookingId, String oldStatus,
                                            String newStatus, String note,
                                            Integer customerUserId) {
        User currentUser = getCurrentUser();

        // Lấy booking object
        Booking booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy booking #" + bookingId));

        // Tự resolve oldStatus từ log gần nhất
        String resolvedOldStatus = bookingStatusLogRepository
                .findTopByBooking_IdOrderByChangedAtDesc(bookingId)
                .map(BookingStatusLog::getNewStatus)
                .orElse(null);

        validateStatusTransition(resolvedOldStatus, newStatus);

        BookingStatusLog log = BookingStatusLog.builder()
                .booking(booking)
                .oldStatus(resolvedOldStatus)
                .newStatus(newStatus)
                .changedBy(currentUser)
                .note(note)
                .changedAt(LocalDateTime.now())
                .build();

        BookingStatusLog saved = bookingStatusLogRepository.save(log);

        // Tự động gửi thông báo cho khách
        Integer targetUserId = customerUserId;
        if (targetUserId == null) {
            // Tự lấy userId từ booking nếu TV4 không truyền
            try {
                targetUserId = booking.getVehicle().getUser().getId();
            } catch (Exception ignored) {}
        }
        if (targetUserId != null) {
            _sendStatusNotification(targetUserId, bookingId, newStatus);
        }

        return saved;
    }

    // Overload không cần customerUserId
    public BookingStatusLog logStatusChange(Integer bookingId, String oldStatus,
                                            String newStatus, String note) {
        return logStatusChange(bookingId, oldStatus, newStatus, note, null);
    }

    // ── Gửi thông báo theo trạng thái ────────────────────────────────────────
    private void _sendStatusNotification(Integer userId, Integer bookingId, String newStatus) {
        Map<String, String[]> messages = Map.of(
                "CONFIRMED",   new String[]{"booking_confirmed",
                        "Lịch hẹn đã được xác nhận ✓",
                        "Lịch hẹn #" + bookingId + " đã được thợ xác nhận."},
                "IN_PROGRESS", new String[]{"status_update",
                        "Xe đang được sửa chữa 🔧",
                        "Thợ đã bắt đầu thực hiện dịch vụ cho xe của bạn."},
                "COMPLETED",   new String[]{"invoice_ready",
                        "Dịch vụ hoàn thành 🎉",
                        "Xe của bạn đã sửa xong. Hoá đơn sẵn sàng để thanh toán."},
                "CANCELLED",   new String[]{"status_update",
                        "Lịch hẹn đã bị huỷ",
                        "Lịch hẹn #" + bookingId + " đã bị huỷ."}
        );

        if (messages.containsKey(newStatus)) {
            String[] msg = messages.get(newStatus);
            try {
                notificationService.send(userId, bookingId, msg[0], msg[1], msg[2]);
            } catch (Exception ignored) {}
        }
    }

    // ── Validate luồng trạng thái ─────────────────────────────────────────────
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
                    "Không thể chuyển trạng thái từ " + oldStatus + " sang " + newStatus);
        }
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
}