package com.autocare.api.repository;

import com.autocare.api.entity.Booking;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface BookingRepository extends JpaRepository<Booking, Integer> {
    long countByCreatedAtBetween(LocalDateTime from, LocalDateTime to);

    long countByStatus(String status);

    long countByBookingTypeAndStatusIn(String bookingType, List<String> statuses);

    List<Booking> findByCreatedAtBetween(LocalDateTime from, LocalDateTime to);
}
