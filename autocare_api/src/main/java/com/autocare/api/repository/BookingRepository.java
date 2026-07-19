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

    @Query("""
               SELECT b
               FROM Booking b
               WHERE b.garage.id = :garageId
               AND b.mechanic IS NULL
               AND b.status = 'PENDING'
               ORDER BY b.createdAt DESC
           """)
    List<Booking> findWaitingBookingsByGarage(
            @Param("garageId") Integer garageId);

    @Query("SELECT b FROM Booking b JOIN b.slot s WHERE b.garage.id = :garageId " +
            "AND s.bookingDate = CURRENT_DATE " +
            "AND b.mechanic IS NULL " +
            "AND b.status IN ('PENDING', 'CONFIRMED')")
    List<Booking> findAvailableBookingsForToday(@Param("garageId") Integer garageId);

    @Query("""
               SELECT b
               FROM Booking b
               WHERE b.mechanic.id=:mechanicId
               AND b.status='CONFIRMED'
           """)
    List<Booking> findConfirmedBookings(
            @Param("mechanicId") Integer mechanicId);

    @Query("""
              SELECT b
              FROM Booking b
              WHERE b.mechanic.id=:mechanicId
              AND b.status='IN_PROGRESS'
           """)
    List<Booking> findRepairingBookings(
            @Param("mechanicId") Integer mechanicId);

    List<Booking> findByMechanic_IdOrderByCreatedAtDesc(Integer mechanicId);

    List<Booking> findByCreatedAtBetween(LocalDateTime from, LocalDateTime to);

}
