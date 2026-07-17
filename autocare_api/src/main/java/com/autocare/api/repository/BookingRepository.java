package com.autocare.api.repository;

import com.autocare.api.entity.Booking;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface BookingRepository extends JpaRepository<Booking, Integer> {
    List<Booking> findByVehicle_UserIdOrderByCreatedAtDesc(Integer userId);

    long countByCreatedAtBetween(LocalDateTime from, LocalDateTime to);

    long countByStatus(Booking.BookingStatus status);

    long countByBookingTypeAndStatusIn(
            Booking.BookingType bookingType,
            List<Booking.BookingStatus> statuses
    );

    List<Booking> findByCreatedAtBetween(LocalDateTime from, LocalDateTime to);
}
