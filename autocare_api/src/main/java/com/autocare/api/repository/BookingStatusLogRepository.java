package com.autocare.api.repository;

import com.autocare.api.entity.BookingStatusLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface BookingStatusLogRepository extends JpaRepository<BookingStatusLog, Integer> {

    // Dùng booking.id thay vì bookingId (vì Entity dùng @ManyToOne Booking)
    List<BookingStatusLog> findByBooking_IdOrderByChangedAtAsc(Integer bookingId);

    Optional<BookingStatusLog> findTopByBooking_IdOrderByChangedAtDesc(Integer bookingId);

    boolean existsByBooking_IdAndNewStatus(Integer bookingId, String newStatus);
}