package com.autocare.api.service;

import com.autocare.api.entity.Review;
import com.autocare.api.entity.User;
import com.autocare.api.repository.ReviewRepository;
import com.autocare.api.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final UserRepository userRepository;

    public ReviewService(
            ReviewRepository reviewRepository,
            UserRepository userRepository
    ) {
        this.reviewRepository = reviewRepository;
        this.userRepository = userRepository;
    }

    // ── Lấy tất cả review của 1 garage ───────────────────────────────────────
    public List<Review> getGarageReviews(Integer garageId) {
        return reviewRepository
                .findByGarageIdAndIsVisibleTrueOrderByCreatedAtDesc(garageId);
    }

    // ── Lấy review của user hiện tại ─────────────────────────────────────────
    public List<Review> getMyReviews() {
        User currentUser = getCurrentUser();
        return reviewRepository
                .findByUserIdOrderByCreatedAtDesc(currentUser.getId());
    }

    // ── Lấy review theo bookingId ─────────────────────────────────────────────
    public Review getByBookingId(Integer bookingId) {
        return reviewRepository
                .findByBookingId(bookingId)
                .orElseThrow(() -> new RuntimeException("Chưa có đánh giá cho booking này"));
    }

    // ── Tạo review sau khi dịch vụ hoàn thành ────────────────────────────────
    public Review createReview(Integer bookingId, Integer garageId,
                               Integer rating, String comment, String images) {
        User currentUser = getCurrentUser();

        // Mỗi booking chỉ được review 1 lần
        if (reviewRepository.existsByBookingId(bookingId)) {
            throw new RuntimeException("Bạn đã đánh giá booking này rồi");
        }

        validateRating(rating);

        Review review = Review.builder()
                .bookingId(bookingId)
                .userId(currentUser.getId())
                .garageId(garageId)
                .rating(rating)
                .comment(normalizeNullable(comment))
                .images(images)
                .isVisible(true)
                .build();

        return reviewRepository.save(review);
    }

    // ── Cập nhật review (chỉ được sửa review của chính mình) ─────────────────
    public Review updateReview(Integer bookingId, Integer rating,
                               String comment, String images) {
        User currentUser = getCurrentUser();

        Review review = reviewRepository
                .findByBookingId(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đánh giá"));

        if (!review.getUserId().equals(currentUser.getId())) {
            throw new RuntimeException("Bạn không có quyền sửa đánh giá này");
        }

        validateRating(rating);

        review.setRating(rating);
        review.setComment(normalizeNullable(comment));
        review.setImages(images);

        return reviewRepository.save(review);
    }

    // ── Xoá review (chỉ được xoá review của chính mình) ─────────────────────
    public void deleteReview(Integer bookingId) {
        User currentUser = getCurrentUser();

        Review review = reviewRepository
                .findByBookingId(bookingId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đánh giá"));

        if (!review.getUserId().equals(currentUser.getId())) {
            throw new RuntimeException("Bạn không có quyền xoá đánh giá này");
        }

        reviewRepository.delete(review);
    }

    // ── Ẩn/hiện review (dành cho Admin) ──────────────────────────────────────
    public Review toggleVisibility(Integer reviewId) {
        Review review = reviewRepository
                .findById(reviewId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đánh giá"));

        review.setIsVisible(!review.getIsVisible());
        return reviewRepository.save(review);
    }

    // ── Lấy review theo số sao (filter) ──────────────────────────────────────
    public List<Review> getGarageReviewsByRating(Integer garageId, Integer rating) {
        validateRating(rating);
        return reviewRepository
                .findByGarageIdAndRatingAndIsVisibleTrue(garageId, rating);
    }

    // ── Validate ─────────────────────────────────────────────────────────────
    private void validateRating(Integer rating) {
        if (rating == null || rating < 1 || rating > 5) {
            throw new RuntimeException("Số sao phải từ 1 đến 5");
        }
    }

    // ── Helper ───────────────────────────────────────────────────────────────
    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder
                .getContext()
                .getAuthentication();

        if (authentication == null || authentication.getName() == null) {
            throw new RuntimeException("Bạn chưa đăng nhập");
        }

        String emailOrPhone = authentication.getName();

        return userRepository
                .findByEmailOrPhone(emailOrPhone, emailOrPhone)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
    }

    private String normalizeNullable(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        return value.trim();
    }
}