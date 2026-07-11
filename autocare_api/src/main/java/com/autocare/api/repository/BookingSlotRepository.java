package com.autocare.api.repository;

import com.autocare.api.entity.BookingSlot;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;

public interface BookingSlotRepository extends JpaRepository<BookingSlot, Integer> {

    List<BookingSlot> findByGarage_IdAndBookingDateOrderByStartTimeAsc(Integer garageId, LocalDate bookingDate);
}