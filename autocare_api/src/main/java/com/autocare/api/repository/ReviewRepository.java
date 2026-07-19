package com.autocare.api.repository;

import com.autocare.api.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ReviewRepository extends JpaRepository<Review, Integer> {

    Optional<Review> findByBooking_Id(Integer bookingId);

    boolean existsByBooking_Id(Integer bookingId);

    // FIX: đổi JOIN FETCH -> LEFT JOIN FETCH để không loại bỏ review
    // của những booking chưa có (hoặc thiếu) booking_items tương ứng.
    @Query("""
        SELECT DISTINCT r FROM Review r
        JOIN FETCH r.booking b
        LEFT JOIN FETCH b.bookingItems bi
        LEFT JOIN FETCH bi.service
        WHERE r.garage.id = :garageId AND r.isVisible = true
        ORDER BY r.createdAt DESC
        """)
    List<Review> findByGarage_IdAndIsVisibleTrueOrderByCreatedAtDesc(@Param("garageId") Integer garageId);

    List<Review> findByUser_IdOrderByCreatedAtDesc(Integer userId);

    List<Review> findByGarage_IdAndRatingAndIsVisibleTrue(Integer garageId, Integer rating);
}