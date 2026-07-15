package com.autocare.api.repository;

import com.autocare.api.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ReviewRepository extends JpaRepository<Review, Integer> {

    // Tìm review theo bookingId (mỗi booking chỉ có 1 review)
    Optional<Review> findByBookingId(Integer bookingId);

    // Kiểm tra booking đã được review chưa
    boolean existsByBookingId(Integer bookingId);

    // Lấy tất cả review của 1 garage (chỉ lấy review đang hiển thị)
    List<Review> findByGarageIdAndIsVisibleTrueOrderByCreatedAtDesc(Integer garageId);

    // Lấy tất cả review của 1 user
    List<Review> findByUserIdOrderByCreatedAtDesc(Integer userId);

    // Lấy review theo số sao (dùng cho filter)
    List<Review> findByGarageIdAndRatingAndIsVisibleTrue(Integer garageId, Integer rating);
}