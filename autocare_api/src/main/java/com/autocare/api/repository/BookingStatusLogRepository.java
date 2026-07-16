package com.autocare.api.repository;

import com.autocare.api.entity.BookingStatusLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface BookingStatusLogRepository extends JpaRepository<BookingStatusLog, Integer> {

    // Lấy toàn bộ lịch sử trạng thái của 1 booking, sắp xếp theo thời gian tăng dần
    // → dùng để vẽ Timeline Stepper trên app
    List<BookingStatusLog> findByBookingIdOrderByChangedAtAsc(Integer bookingId);

    // Lấy trạng thái mới nhất của 1 booking
    Optional<BookingStatusLog> findTopByBookingIdOrderByChangedAtDesc(Integer bookingId);

    // Kiểm tra booking đã từng có trạng thái cụ thể chưa
    boolean existsByBookingIdAndNewStatus(Integer bookingId, String newStatus);
}