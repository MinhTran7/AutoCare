package com.autocare.api.repository;

import com.autocare.api.entity.BookingSparePart;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BookingSparePartRepository extends JpaRepository<BookingSparePart, Integer> {
    List<BookingSparePart> findByBookingId(Integer bookingId);
}