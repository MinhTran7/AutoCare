package com.autocare.api.repository;

import com.autocare.api.entity.Booking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

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

    @Query("SELECT b FROM Booking b JOIN b.slot s WHERE b.garage.id = :garageId " +
            "AND s.bookingDate = CURRENT_DATE " +
            "AND b.mechanic IS NULL " +
            "AND b.status IN ('PENDING', 'CONFIRMED')")
    List<Booking> findAvailableBookingsForToday(@Param("garageId") Integer garageId);

    List<Booking> findByCreatedAtBetween(LocalDateTime from, LocalDateTime to);

}
