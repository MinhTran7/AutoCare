package com.autocare.api.repository;

import com.autocare.api.entity.BookingItem;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface BookingItemRepository extends JpaRepository<BookingItem, Integer> {
    List<BookingItem> findByBooking_Id(Integer bookingId);
}